USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE TABLE Integration.Sale_Staging (

       "Sale Staging Key" BIGINT IDENTITY(1,1) ORDER NOT NULL,
       "City Key" INT NULL,
       "Customer Key" INT NULL,
       "Bill To Customer Key" INT NULL,
       "Stock Item Key" INT NULL,
       "Invoice Date Key" DATE NULL,
       "Delivery Date Key" DATE NULL,
       "Salesperson Key" INT NULL,
       "WWI Invoice ID" INT NULL,
       Description NVARCHAR(100) COLLATE 'EN-CI-AS' /*** SSC-PRF-0002 - CASE INSENSITIVE COLUMNS CAN DECREASE THE PERFORMANCE OF QUERIES ***/ /*** SSC-FDM-TS0002 - COLLATION FOR VALUE 100 NOT SUPPORTED ***/ NULL,
       Package NVARCHAR(50) COLLATE 'EN-CI-AS' /*** SSC-PRF-0002 - CASE INSENSITIVE COLUMNS CAN DECREASE THE PERFORMANCE OF QUERIES ***/ /*** SSC-FDM-TS0002 - COLLATION FOR VALUE 100 NOT SUPPORTED ***/ NULL,
       Quantity INT NULL,
       "Unit Price" DECIMAL(18, 2) NULL,
       "Tax Rate" DECIMAL(18, 3) NULL,
       "Total Excluding Tax" DECIMAL(18, 2) NULL,
       "Tax Amount" DECIMAL(18, 2) NULL,
       Profit DECIMAL(18, 2) NULL,
       "Total Including Tax" DECIMAL(18, 2) NULL,
       "Total Dry Items" INT NULL,
       "Total Chiller Items" INT NULL,
       "WWI City ID" INT NULL,
       "WWI Customer ID" INT NULL,
       "WWI Bill To Customer ID" INT NULL,
       "WWI Stock Item ID" INT NULL,
       "WWI Salesperson ID" INT NULL,
       "Last Modified When" TIMESTAMP_NTZ(7) NULL,
       CONSTRAINT PK_Integration_Sale_Staging PRIMARY KEY ("Sale Staging Key")
   )
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
;