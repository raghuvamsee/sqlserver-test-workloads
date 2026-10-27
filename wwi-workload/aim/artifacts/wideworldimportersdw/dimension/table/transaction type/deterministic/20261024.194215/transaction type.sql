USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE TABLE Dimension."Transaction Type" (

       "Transaction Type Key" INT NOT NULL DEFAULT (Sequences.TransactionTypeKey.NEXTVAL) /*** SSC-FDM-0012 - CONSTRAINT NAME 'DF_Dimension_Transaction_Type_Transaction_Type_Key' IN DEFAULT EXPRESSION CONSTRAINT IS NOT SUPPORTED IN SNOWFLAKE ***/,
       "WWI Transaction Type ID" INT NOT NULL,
       "Transaction Type" NVARCHAR(50) COLLATE 'EN-CI-AS' /*** SSC-PRF-0002 - CASE INSENSITIVE COLUMNS CAN DECREASE THE PERFORMANCE OF QUERIES ***/ /*** SSC-FDM-TS0002 - COLLATION FOR VALUE 100 NOT SUPPORTED ***/ NOT NULL,
       "Valid From" TIMESTAMP_NTZ(7) NOT NULL,
       "Valid To" TIMESTAMP_NTZ(7) NOT NULL,
       "Lineage Key" INT NOT NULL,
       CONSTRAINT PK_Dimension_Transaction_Type PRIMARY KEY ("Transaction Type Key")
   )
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
;