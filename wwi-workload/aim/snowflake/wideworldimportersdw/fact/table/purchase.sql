USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE TABLE Fact.Purchase (

       "Purchase Key" BIGINT IDENTITY(1,1) ORDER NOT NULL,
       "Date Key" DATE NOT NULL,
       "Supplier Key" INT NOT NULL,
       "Stock Item Key" INT NOT NULL,
       "WWI Purchase Order ID" INT NULL,
       "Ordered Outers" INT NOT NULL,
       "Ordered Quantity" INT NOT NULL,
       "Received Outers" INT NOT NULL,
       Package NVARCHAR(50) COLLATE 'EN-CI-AS' /*** SSC-PRF-0002 - CASE INSENSITIVE COLUMNS CAN DECREASE THE PERFORMANCE OF QUERIES ***/ /*** SSC-FDM-TS0002 - COLLATION FOR VALUE 100 NOT SUPPORTED ***/ NOT NULL,
       "Is Order Finalized" BOOLEAN NOT NULL,
       "Lineage Key" INT NOT NULL,
       CONSTRAINT PK_Fact_Purchase PRIMARY KEY ("Purchase Key", "Date Key")
   )
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
;

ALTER TABLE Fact.Purchase
    ADD CONSTRAINT FK_Fact_Purchase_Date_Key_Dimension_Date FOREIGN KEY ("Date Key") REFERENCES Dimension.Date (Date);

ALTER TABLE Fact.Purchase
ADD CONSTRAINT "FK_Fact_Purchase_Stock_Item_Key_Dimension_Stock Item" FOREIGN KEY ("Stock Item Key") REFERENCES Dimension."Stock Item" ("Stock Item Key");

ALTER TABLE Fact.Purchase
ADD CONSTRAINT FK_Fact_Purchase_Supplier_Key_Dimension_Supplier FOREIGN KEY ("Supplier Key") REFERENCES Dimension.Supplier ("Supplier Key");