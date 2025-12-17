#AGGREGATIONS

#COMPLAINT TYPES CITYWIDE

MATCH (r:Request)-[:HAS_COMPLAINT]->
(ct: Complaint)
RETURN ct.'Complaint Type' AS complaintType,
        COUNT (r) AS numRequests
ORDER BY numRequests DESC
LIMIT 10;


#NOISE VS. NON-NOUSE PER BOROUGH

MATCH (r:Request)-[:IN_BOROUGH]->(b:Borough) 
WHERE r.isNoiseComplaint IS NOT NULL
RETURN b. 'Borough' AS borough,
       SUM(CASE WHEN r. isNoiseComplaint THEN 1
ELSE 0 END) AS noiseRequests,
       COUNT (r) AS totalRequests,
       round (100.0 * SUM (CASE WHEN
r. isNoiseComplaint THEN 1 ELSE 0 END) /
COUNT (r), 2)
       AS pctNoise
ORDER BY pctNoise DESC;

#COMPLAINT PER BOROUGH AND AGENCY

MATCH (r:Request)-[:IN_BOROUGH]-> (b:Borough),
      (r)-[:BY_AGENCY]->(a: Agency)
RETURN b.'Borough' AS borough,
       a.'Code' AS agencyCode,
       a. 'Name' AS agencyName,
COUNT (r) AS numRequests
ORDER BY borough, numRequests DESC;

#AVERAGE RESOLUTION HOURS PER BOROUGH

MATCH (r:Request)-[:IN_BOROUGH]->(b:Borough
) WHERE r. 'Resolution Hours' IS NOT NULL
RETURN b. 'Borough' AS borough,
       COUNT (r) AS numRequests,
       round (AVG(r. 'Resolution Hours'), 2) AS
avgResolutionHours
ORDER BY avgResolutionhours DESC;

#AVERAGE RESOLUTION HOURS PER COMPLAINT TYPE

MATCH (r:Request) -[:HAS_COMPLAINT]->
(ct: Complaint) WHERE r. 'Resolution Hours' IS NOT NULL
RETURN ct.'Complaint Type' AS complaintType,
       COUNT (r) AS numRequests,
       round (AVG (r. 'Resolution Hours'), 2) AS
avgResolutionHours
ORDER BY avgResolutionHours DESC
LIMIT 10;

#AGENCIES BY NUMBER OF REQUESTS

MATCH (r:Request)-[:BY_AGENCY]->(a:Agency)
RETURN a.'Code' AS agencyCode,
       a.'Name' AS agencyName,
       COUNT (r) AS numRequests
ORDER BY numRequests DESC
LIMIT 10;

#COMPLAINTS BY AVERAGE RESOLUTION HOURS

MATCH (r:Request)-[:BY_AGENCY]-(a:Agency)
WHERE r. 'Resolution Hours' IS NOT NULL
RETURN a. Code AS agencycode,
       a.'Name' AS agencyName,
       COUNT (r) AS numRequests,
       ROUND (AVG (r. 'Resolution Hours')) AS
avgResolutionHours
ORDER BY avgResolutionHours DESC;

#COMPLAINTS PER BOROUGH

MATCH (r:Request)-[:IN_BOROUGH]->(b:Borough)
RETURN b. 'Borough' AS borough,
       COUNT (r) AS numRequests
ORDER BY numRequests DESC;

#TOP COMPLIANTS FOR NYPD
MATCH (r:Request)-[:BY_AGENCY] ->(a:Agency
{Code: 'NYPD' })
MATCH (r)-[:HAS_COMPLAINT]->(c:Complaint)
RETURN c. 'Complaint Type' AS complaintType,
       a. Name,
      COUNT (*)            AS numRequests
ORDER BY numRequests DESC
LIMIT 10;

#NYPD AVERAGE RESOLUTION TIME BY COMPLAINT TYPE

MATCH (r:Request)-[:BY_AGENCY]->(a:Agency
{Code: 'NYPD' })
MATCH (r:Request) -[:HAS_COMPLAINT]->
(c: Complaint)
WHERE r. 'Resolution Hours' IS NOT NULL
RETURN c. 'Complaint Type' AS complaintType,
       COUNT (*)            AS numRequests,
       round (AVG (r.'Resolution Hours'), 2) AS avgResolutionHours
ORDER BY avgResolutionHours DESC
LIMIT 10;

#TOP COMPLIANTS OVERALL
MATCH (r:Request)-[:BY_AGENCY]->(a:Agency)
RETURN a.'Code' AS agencyCode,
       a.'Name' AS agencyName,
       COUNT (r) AS numRequests
ORDER BY numRequests DESC
LIMIT 10;