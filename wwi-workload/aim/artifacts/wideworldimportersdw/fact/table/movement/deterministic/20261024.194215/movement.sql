USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE TABLE Fact.Movement (

       "Movement Key" BIGINT IDENTITY(1,1) ORDER NOT NULL,
       "Date Key" DATE NOT NULL,
       "Stock Item Key" INT NOT NULL,
       "Customer Key" INT NULL,
       "Supplier Key" INT NULL,
       "Transaction Type Key" INT NOT NULL,
       "WWI Stock Item Transaction ID" INT NOT NULL,
       "WWI Invoice ID" INT NULL,
       "WWI Purchase Order ID" INT NULL,
       Quantity INT NOT NULL,
       "Lineage Key" INT NOT NULL,
       CONSTRAINT PK_Fact_Movement PRIMARY KEY ("Movement Key", "Date Key")
   )
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
;

ALTER TABLE Fact.Movement
    ADD CONSTRAINT FK_Fact_Movement_Customer_Key_Dimension_Customer FOREIGN KEY ("Customer Key") REFERENCES Dimension.Customer ("Customer Key");

ALTER TABLE Fact.Movement
ADD CONSTRAINT FK_Fact_Movement_Date_Key_Dimension_Date FOREIGN KEY ("Date Key") REFERENCES Dimension.Date (Date);

ALTER TABLE Fact.Movement
ADD CONSTRAINT "FK_Fact_Movement_Stock_Item_Key_Dimension_Stock Item" FOREIGN KEY ("Stock Item Key") REFERENCES Dimension."Stock Item" ("Stock Item Key");

ALTER TABLE Fact.Movement
ADD CONSTRAINT FK_Fact_Movement_Supplier_Key_Dimension_Supplier FOREIGN KEY ("Supplier Key") REFERENCES Dimension.Supplier ("Supplier Key");

ALTER TABLE Fact.Movement
ADD CONSTRAINT "FK_Fact_Movement_Transaction_Type_Key_Dimension_Transaction Type" FOREIGN KEY ("Transaction Type Key") REFERENCES Dimension."Transaction Type" ("Transaction Type Key");