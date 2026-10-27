USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE TABLE Dimension."Payment Method" (

       "Payment Method Key" INT NOT NULL DEFAULT (Sequences.PaymentMethodKey.NEXTVAL) /*** SSC-FDM-0012 - CONSTRAINT NAME 'DF_Dimension_Payment_Method_Payment_Method_Key' IN DEFAULT EXPRESSION CONSTRAINT IS NOT SUPPORTED IN SNOWFLAKE ***/,
       "WWI Payment Method ID" INT NOT NULL,
       "Payment Method" NVARCHAR(50) COLLATE 'EN-CI-AS' /*** SSC-PRF-0002 - CASE INSENSITIVE COLUMNS CAN DECREASE THE PERFORMANCE OF QUERIES ***/ /*** SSC-FDM-TS0002 - COLLATION FOR VALUE 100 NOT SUPPORTED ***/ NOT NULL,
       "Valid From" TIMESTAMP_NTZ(7) NOT NULL,
       "Valid To" TIMESTAMP_NTZ(7) NOT NULL,
       "Lineage Key" INT NOT NULL,
       CONSTRAINT PK_Dimension_Payment_Method PRIMARY KEY ("Payment Method Key")
   )
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
;