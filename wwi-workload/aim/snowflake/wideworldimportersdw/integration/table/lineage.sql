USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE TABLE Integration.Lineage (

       "Lineage Key" INT NOT NULL DEFAULT (Sequences.LineageKey.NEXTVAL) /*** SSC-FDM-0012 - CONSTRAINT NAME 'DF_Integration_Lineage_Lineage_Key' IN DEFAULT EXPRESSION CONSTRAINT IS NOT SUPPORTED IN SNOWFLAKE ***/,
       "Data Load Started" TIMESTAMP_NTZ(7) NOT NULL,
       "Table Name" VARCHAR(128) NOT NULL,
       "Data Load Completed" TIMESTAMP_NTZ(7) NULL,
       "Was Successful" BOOLEAN NOT NULL,
       "Source System Cutoff Time" TIMESTAMP_NTZ(7) NOT NULL,
       CONSTRAINT PK_Integration_Lineage PRIMARY KEY ("Lineage Key")
   )
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
;