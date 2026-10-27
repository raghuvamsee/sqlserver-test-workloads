USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE TABLE Fact."Order" (

       "Order Key" BIGINT IDENTITY(1,1) ORDER NOT NULL,
       "City Key" INT NOT NULL,
       "Customer Key" INT NOT NULL,
       "Stock Item Key" INT NOT NULL,
       "Order Date Key" DATE NOT NULL,
       "Picked Date Key" DATE NULL,
       "Salesperson Key" INT NOT NULL,
       "Picker Key" INT NULL,
       "WWI Order ID" INT NOT NULL,
       "WWI Backorder ID" INT NULL,
       Description NVARCHAR(100) COLLATE 'EN-CI-AS' /*** SSC-PRF-0002 - CASE INSENSITIVE COLUMNS CAN DECREASE THE PERFORMANCE OF QUERIES ***/ /*** SSC-FDM-TS0002 - COLLATION FOR VALUE 100 NOT SUPPORTED ***/ NOT NULL,
       Package NVARCHAR(50) COLLATE 'EN-CI-AS' /*** SSC-PRF-0002 - CASE INSENSITIVE COLUMNS CAN DECREASE THE PERFORMANCE OF QUERIES ***/ /*** SSC-FDM-TS0002 - COLLATION FOR VALUE 100 NOT SUPPORTED ***/ NOT NULL,
       Quantity INT NOT NULL,
       "Unit Price" DECIMAL(18, 2) NOT NULL,
       "Tax Rate" DECIMAL(18, 3) NOT NULL,
       "Total Excluding Tax" DECIMAL(18, 2) NOT NULL,
       "Tax Amount" DECIMAL(18, 2) NOT NULL,
       "Total Including Tax" DECIMAL(18, 2) NOT NULL,
       "Lineage Key" INT NOT NULL,
       CONSTRAINT PK_Fact_Order PRIMARY KEY ("Order Key", "Order Date Key")
   )
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
;

ALTER TABLE Fact."Order"
    ADD CONSTRAINT FK_Fact_Order_City_Key_Dimension_City FOREIGN KEY ("City Key") REFERENCES Dimension.City ("City Key");

ALTER TABLE Fact."Order"
ADD CONSTRAINT FK_Fact_Order_Customer_Key_Dimension_Customer FOREIGN KEY ("Customer Key") REFERENCES Dimension.Customer ("Customer Key");

ALTER TABLE Fact."Order"
ADD CONSTRAINT FK_Fact_Order_Order_Date_Key_Dimension_Date FOREIGN KEY ("Order Date Key") REFERENCES Dimension.Date (Date);

ALTER TABLE Fact."Order"
ADD CONSTRAINT FK_Fact_Order_Picked_Date_Key_Dimension_Date FOREIGN KEY ("Picked Date Key") REFERENCES Dimension.Date (Date);

ALTER TABLE Fact."Order"
ADD CONSTRAINT FK_Fact_Order_Picker_Key_Dimension_Employee FOREIGN KEY ("Picker Key") REFERENCES Dimension.Employee ("Employee Key");

ALTER TABLE Fact."Order"
ADD CONSTRAINT FK_Fact_Order_Salesperson_Key_Dimension_Employee FOREIGN KEY ("Salesperson Key") REFERENCES Dimension.Employee ("Employee Key");

ALTER TABLE Fact."Order"
ADD CONSTRAINT "FK_Fact_Order_Stock_Item_Key_Dimension_Stock Item" FOREIGN KEY ("Stock Item Key") REFERENCES Dimension."Stock Item" ("Stock Item Key");