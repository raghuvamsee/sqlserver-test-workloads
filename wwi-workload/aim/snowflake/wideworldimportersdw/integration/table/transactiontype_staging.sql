USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE TABLE Integration.TransactionType_Staging (

       "Transaction Type Staging Key" INT IDENTITY(1,1) ORDER NOT NULL,
       "WWI Transaction Type ID" INT NOT NULL,
       "Transaction Type" NVARCHAR(50) COLLATE 'EN-CI-AS' /*** SSC-PRF-0002 - CASE INSENSITIVE COLUMNS CAN DECREASE THE PERFORMANCE OF QUERIES ***/ /*** SSC-FDM-TS0002 - COLLATION FOR VALUE 100 NOT SUPPORTED ***/ NOT NULL,
       "Valid From" TIMESTAMP_NTZ(7) NOT NULL,
       "Valid To" TIMESTAMP_NTZ(7) NOT NULL,
       CONSTRAINT PK_Integration_Transaction_Type_Staging PRIMARY KEY ("Transaction Type Staging Key")
   )
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
;