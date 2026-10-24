USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE TABLE Integration."ETL Cutoff" (

       "Table Name" VARCHAR(128) NOT NULL,
       "Cutoff Time" TIMESTAMP_NTZ(7) NOT NULL,
       CONSTRAINT PK_Integration_ETL_Cutoff PRIMARY KEY ("Table Name")
   )
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
;