USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE TABLE Integration.StockHolding_Staging (

       "Stock Holding Staging Key" BIGINT IDENTITY(1,1) ORDER NOT NULL,
       "Stock Item Key" INT NULL,
       "Quantity On Hand" INT NULL,
       "Bin Location" NVARCHAR(20) COLLATE 'EN-CI-AS' /*** SSC-PRF-0002 - CASE INSENSITIVE COLUMNS CAN DECREASE THE PERFORMANCE OF QUERIES ***/ /*** SSC-FDM-TS0002 - COLLATION FOR VALUE 100 NOT SUPPORTED ***/ NULL,
       "Last Stocktake Quantity" INT NULL,
       "Last Cost Price" DECIMAL(18, 2) NULL,
       "Reorder Level" INT NULL,
       "Target Stock Level" INT NULL,
       "WWI Stock Item ID" INT NULL,
       CONSTRAINT PK_Integration_Stock_Holding_Staging PRIMARY KEY ("Stock Holding Staging Key")
   )
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
;