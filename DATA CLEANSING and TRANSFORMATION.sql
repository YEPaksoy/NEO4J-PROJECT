#DATA CLEANSING

#FOR Request

MATCH (r: Request)
WHERE r.'Closed Date' IN ['', NULL]
DETACH DELETE (r);

MATCH (r: Request)
WHERE r.'Created Date' IN ['', NULL]
DETACH DELETE (r);

MATCH (r: Request)
WHERE r.'Status' IN ['', NULL]
DETACH DELETE (r);

MATCH (r: Request)
WHERE r.'Unique Key' IN ['', NULL]
DETACH DELETE (r);

#FOR Agency

MATCH (a: Agency)
WHERE a.'Name' IN ['', NULL]
DETACH DELETE (a);  

WHERE a.'Unique Key' IN ['', NULL]
DETACH DELETE (a);  

MATCH (a: Agency)
WHERE a.'Code' IN ['', NULL]
DETACH DELETE (a);  

#FOR Complaint Type

MATCH (ct: Complaint)
WHERE ct.'Complaint' IN ['', NULL]
DETACH DELETE (ct);

MATCH (ct: Complaint)
WHERE ct.'Unique Key' IN ['', NULL]
DETACH DELETE (ct);

MATCH (ct: Complaint)
WHERE ct.'Descriptor' IN ['', NULL]
DETACH DELETE (ct);

#FOR Borough
MATCH (b: Borough)
WHERE b.'Borough' IN ['', NULL]
DETACH DELETE (b);

MATCH (b: Borough)
WHERE b.'Unique Key' IN ['', NULL]
DETACH DELETE (b);

#FOR Location

MATCH (l: Location)
WHERE l.'Latitude' IN ['', NULL]
DETACH DELETE (l); 

MATCH (l: Location)
WHERE l.'Longitude' IN ['', NULL]
DETACH DELETE (l);  

MATCH (l: Location)
WHERE l.'Location' IN ['', NULL]
DETACH DELETE (l);  

MATCH (l: Location)
WHERE l.'Address Type' IN ['', NULL]
DETACH DELETE (l);

MATCH (l: Location)
WHERE l.'Incident Zip' IN ['', NULL]
DETACH DELETE (l);

MATCH (l: Location)
WHERE l.'Incident Address' IN ['', NULL]
DETACH DELETE (l);

MATCH (l: Location)
WHERE l.'Unique Key' IN ['', NULL]
DETACH DELETE (l);

#DATA TRANSFORMATION

#Name Normalization

MATCH (b:Borough)
SET b.name = trim(b.name);


#Resolution Hours derivation
MATCH (r: Request)
WHERE r.'Closed Date' <> 'Not Completed Yet'
AND r.'Created Date' IS NOT NULL
AND r.'Closed Date' IS NOT NULL
WITH r,
        apoc.date.parse(r.'Created Date','s','MM/dd/yyyy hh:mm:ss') AS createdSec,
        apoc.date.parse(r.'Closed Date','s','MM/dd/yyyy hh:mm:ss') AS closedSec
WHERE createdSec IS NOT NULL AND closedSec IS NOT NULL AND closedSec >= createdSec
SET r.'Created Date'   =
datetime({epochSeconds: createdSec}),
    r.'Closed Date' =
datetime({epochSeconds: closedSec}),
    r.'Resolution Hours' = (closedSec -
createdSec) / 3600.0;


# isNoiseComplaint derivation

MATCH (r:Request) -[:HAS_COMPLAINT]->(ct: Complaint)
SET r.isNoiseComplaint = CASE
WHEN ct.'Complaint' STARTS WITH 'Noise' THEN true
ELSE false
END;

