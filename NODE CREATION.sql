#CREATE Request
LOAD CSV WITH HEADERS FROM 'file:///311_Service_Requests_from_2010_to_Present_20251210.csv' AS row
WITH row
WHERE row.`Unique Key` IS NOT NULL
MERGE (r:Request {uniqueKey: toInteger(row.`Unique Key`)})
SET r.status            = row.`Status`,
    r.createdDate = row.`Created Date`,
    r.closedDate  = row.`Closed Date`;
#CREATE Agency
LOAD CSV WITH HEADERS FROM 'file:///311_Service_Requests_from_2010_to_Present_20251210.csv' AS row
WITH row
WHERE row.Agency IS NOT NULL
MATCH (r:Request {uniqueKey: toInteger(row.`Unique Key`)})
MERGE (a:Agency {code: row.Agency})
ON CREATE SET a.name = row.`Agency Name`
MERGE (r)-[:BY_AGENCY]->(a);
#CREATE Complaint
LOAD CSV WITH HEADERS FROM 'file:///311_Service_Requests_from_2010_to_Present_20251210.csv' AS row
WITH row
WHERE row.`Complaint Type` IS NOT NULL AND row.`Complaint Type` <> ''
MATCH (r:Request {uniqueKey: toInteger(row.`Unique Key`)})
MERGE (ct:Complaint {name: row.`Complaint Type`})
ON CREATE SET ct.desriptor = row.`Descriptor`
MERGE (r)-[:HAS_COMPLAINT]->(ct);
#CREATE Borough
LOAD CSV WITH HEADERS FROM 'file:///311_Service_Requests_from_2010_to_Present_20251210.csv' AS row
WITH row
WHERE row.Borough IS NOT NULL AND row.Borough <> ''
MATCH (r:Request {uniqueKey: toInteger(row.`Unique Key`)})
MERGE (b:Borough {Borough: row.Borough})
MERGE (r)-[:IN_BOROUGH]->(b);

#CREATE Location
LOAD CSV WITH HEADERS FROM 'file:///311_Service_Requests_from_2010_to_Present_20251210.csv' AS row
WITH row
WHERE row.`Incident Address` IS NOT NULL AND row.`Incident Address` <> ''
MATCH (b:Borough {uniqueKey: toInteger(row.`Unique Key`)})
MERGE (loc:Location {
    Address: row.`Incident Address`,
    incidentZip:     row.`Incident Zip`
})
ON CREATE SET
    loc.latitude  = CASE WHEN row.Latitude  IS NULL OR row.Latitude  = '' THEN NULL ELSE toFloat(row.Latitude)  END,
    loc.longitude = CASE WHEN row.Longitude IS NULL OR row.Longitude = '' THEN NULL ELSE toFloat(row.Longitude) END,
    loc.location = CASE WHEN row.Location IS NULL OR row.Location = '' THEN NULL ELSE toFloat(row.Location) END,
MERGE (r)-[:AT_LOCATION]->(loc);