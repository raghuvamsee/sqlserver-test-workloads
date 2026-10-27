USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE TABLE Integration.Transaction_Staging (

       "Transaction Staging Key" BIGINT IDENTITY(1,1) ORDER NOT NULL,
       "Date Key" DATE NULL,
       "Customer Key" INT NULL,
       "Bill To Customer Key" INT NULL,
       "Supplier Key" INT NULL,
       "Transaction Type Key" INT NULL,
       "Payment Method Key" INT NULL,
       "WWI Customer Transaction ID" INT NULL,
       "WWI Supplier Transaction ID" INT NULL,
       "WWI Invoice ID" INT NULL,
       "WWI Purchase Order ID" INT NULL,
       "Supplier Invoice Number" NVARCHAR(20) COLLATE 'EN-CI-AS' /*** SSC-PRF-0002 - CASE INSENSITIVE COLUMNS CAN DECREASE THE PERFORMANCE OF QUERIES ***/ /*** SSC-FDM-TS0002 - COLLATION FOR VALUE 100 NOT SUPPORTED ***/ NULL,
       "Total Excluding Tax" DECIMAL(18, 2) NULL,
       "Tax Amount" DECIMAL(18, 2) NULL,
       "Total Including Tax" DECIMAL(18, 2) NULL,
       "Outstanding Balance" DECIMAL(18, 2) NULL,
       "Is Finalized" BOOLEAN NULL,
       "WWI Customer ID" INT NULL,
       "WWI Bill To Customer ID" INT NULL,
       "WWI Supplier ID" INT NULL,
       "WWI Transaction Type ID" INT NULL,
       "WWI Payment Method ID" INT NULL,
       "Last Modified When" TIMESTAMP_NTZ(7) NULL,
       CONSTRAINT PK_Integration_Transaction_Staging PRIMARY KEY ("Transaction Staging Key")
   )
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
;