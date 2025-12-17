# NEO4J-PROJECT

CREATED BY YUNUS EMRE PAKSOY,
           NOBUKHOSI SIBANDA
           MUHAMMAD EHTESHAM

NYC 311 Service Requests — Graph Database (Neo4j)
===================================================

Overview
--------
This project models NYC 311 service requests as a Neo4j graph so you can explore relationships between
requests, agencies, complaint types, boroughs, and locations, and run analytics like hotspot detection,
agency workload, and resolution performance.

Tech Stack
----------
- Neo4j (graph database)
- Cypher (query language)
- APOC (optional but recommended for convenience functions)
- (Optional) Python for preprocessing/cleanup

Graph Model (Suggested)
-----------------------
Nodes:
- Request   (id, status, createdDate, closedDate, resolutionHours)
- Agency    (code, name)
- Complaint (type, descriptor)
- Borough   (name)
- Location  (address, zip, lat, lon)

Relationships:
- (Request)-[:BY_AGENCY]->(Agency)
- (Request)-[:HAS_COMPLAINT]->(Complaint)
- (Request)-[:IN_BOROUGH]->(Borough)
- (Borough)-[:LOCATED_AT]->(Location)

Installation
------------

Option A — Neo4j Desktop (Recommended)
1) Install Neo4j Desktop.
2) Create a new DBMS (Neo4j 5.x recommended).
3) Start the database and set a password.
4) Open Neo4j Browser (http://localhost:7474) and confirm you can connect.

Option B — Docker
Run Neo4j in Docker:
  docker run --name nyc311-neo4j -p 7474:7474 -p 7687:7687 \
    -e NEO4J_AUTH=neo4j/neo4jpassword \
    neo4j:5

Install APOC (Recommended)
--------------------------
Neo4j Desktop:
1) Select your DB → Plugins
2) Install “APOC”
3) Restart the database

Docker (common approach):
  docker run --name nyc311-neo4j -p 7474:7474 -p 7687:7687 \
    -e NEO4J_AUTH=neo4j/neo4jpassword \
    -e NEO4J_PLUGINS='["apoc"]' \
    neo4j:5

Data Setup
----------
1) Put your NYC 311 subset CSV(s) under:
   data\raw\

2) Recommended cleanup before import:
- Handle null Closed Date values (keep NULL or mark as not completed)
- Normalize borough names
- Ensure dates and numeric fields (lat/lon) are consistent

Importing into Neo4j (LOAD CSV)
-------------------------------

1) Create constraints/indexes (example)
Run in Neo4j Browser:

  CREATE CONSTRAINT request_id IF NOT EXISTS FOR (r:Request) REQUIRE r.id IS UNIQUE;
  CREATE CONSTRAINT agency_code IF NOT EXISTS FOR (a:Agency) REQUIRE a.code IS UNIQUE;
  CREATE CONSTRAINT complaint_key IF NOT EXISTS FOR (c:Complaint) REQUIRE c.key IS UNIQUE;
  CREATE CONSTRAINT borough_name IF NOT EXISTS FOR (b:Borough) REQUIRE b.name IS UNIQUE;
  CREATE CONSTRAINT location_key IF NOT EXISTS FOR (l:Location) REQUIRE l.key IS UNIQUE;

2) Copy CSV into Neo4j import directory
- Neo4j Desktop: place CSV in the DB’s “import/” folder
- Docker: mount a volume to /var/lib/neo4j/import

3) Example load script (adapt CSV column names)
Create a file (e.g., cypher\load.cypher) and adjust fields to match your dataset:

  LOAD CSV WITH HEADERS FROM 'file:///nyc311_subset.csv' AS row

  MERGE (a:Agency {code: row.Agency})
    ON CREATE SET a.name = row.AgencyName

  MERGE (c:Complaint {key: row.ComplaintType + '|' + coalesce(row.Descriptor,'')})
    SET c.type = row.ComplaintType,
        c.descriptor = row.Descriptor

  MERGE (b:Borough {name: row.Borough})

  MERGE (l:Location {key: coalesce(row.IncidentAddress,'') + '|' + coalesce(row.IncidentZip,'')})
    SET l.address = row.IncidentAddress,
        l.zip = row.IncidentZip,
        l.lat = toFloat(row.Latitude),
        l.lon = toFloat(row.Longitude)

  MERGE (r:Request {id: row.UniqueKey})
    SET r.status = row.Status,
        r.createdDate = date(row.CreatedDate),
        r.closedDate  = CASE WHEN row.ClosedDate IS NULL OR row.ClosedDate = '' THEN NULL ELSE date(row.ClosedDate) END,
        r.resolutionHours = CASE
          WHEN row.ClosedDate IS NULL OR row.ClosedDate = '' THEN NULL
          ELSE duration.between(datetime(row.CreatedDate), datetime(row.ClosedDate)).hours
        END

  MERGE (r)-[:BY_AGENCY]->(a)
  MERGE (r)-[:HAS_COMPLAINT]->(c)
  MERGE (r)-[:IN_BOROUGH]->(b)
  MERGE (b)-[:LOCATED_AT]->(l);

Then run in Neo4j Browser:
  :source cypher/load.cypher

Troubleshooting
---------------
- LOAD CSV cannot find file: ensure the CSV is in Neo4j’s configured import directory.
- APOC not found: confirm plugin installed and DB restarted.
- Date/float conversion errors: validate date formats and numeric columns.

