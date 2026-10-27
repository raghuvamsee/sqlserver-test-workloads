USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE TABLE Integration.Purchase_Staging (

       "Purchase Staging Key" BIGINT IDENTITY(1,1) ORDER NOT NULL,
       "Date Key" DATE NULL,
       "Supplier Key" INT NULL,
       "Stock Item Key" INT NULL,
       "WWI Purchase Order ID" INT NULL,
       "Ordered Outers" INT NULL,
       "Ordered Quantity" INT NULL,
       "Received Outers" INT NULL,
       Package NVARCHAR(50) COLLATE 'EN-CI-AS' /*** SSC-PRF-0002 - CASE INSENSITIVE COLUMNS CAN DECREASE THE PERFORMANCE OF QUERIES ***/ /*** SSC-FDM-TS0002 - COLLATION FOR VALUE 100 NOT SUPPORTED ***/ NULL,
       "Is Order Finalized" BOOLEAN NULL,
       "WWI Supplier ID" INT NULL,
       "WWI Stock Item ID" INT NULL,
       "Last Modified When" TIMESTAMP_NTZ(7) NULL,
       CONSTRAINT PK_Integration_Purchase_Staging PRIMARY KEY ("Purchase Staging Key")
   )
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
;