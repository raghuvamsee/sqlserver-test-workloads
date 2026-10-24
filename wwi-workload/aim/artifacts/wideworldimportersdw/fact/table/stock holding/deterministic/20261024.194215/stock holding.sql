USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE TABLE Fact."Stock Holding" (

       "Stock Holding Key" BIGINT IDENTITY(1,1) ORDER NOT NULL,
       "Stock Item Key" INT NOT NULL,
       "Quantity On Hand" INT NOT NULL,
       "Bin Location" NVARCHAR(20) COLLATE 'EN-CI-AS' /*** SSC-PRF-0002 - CASE INSENSITIVE COLUMNS CAN DECREASE THE PERFORMANCE OF QUERIES ***/ /*** SSC-FDM-TS0002 - COLLATION FOR VALUE 100 NOT SUPPORTED ***/ NOT NULL,
       "Last Stocktake Quantity" INT NOT NULL,
       "Last Cost Price" DECIMAL(18, 2) NOT NULL,
       "Reorder Level" INT NOT NULL,
       "Target Stock Level" INT NOT NULL,
       "Lineage Key" INT NOT NULL,
       CONSTRAINT PK_Fact_Stock_Holding PRIMARY KEY ("Stock Holding Key")
   )
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
;

ALTER TABLE Fact."Stock Holding"
    ADD CONSTRAINT "FK_Fact_Stock_Holding_Stock_Item_Key_Dimension_Stock Item" FOREIGN KEY ("Stock Item Key") REFERENCES Dimension."Stock Item" ("Stock Item Key");