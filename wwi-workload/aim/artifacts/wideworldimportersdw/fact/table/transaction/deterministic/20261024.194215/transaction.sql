USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE TABLE Fact.Transaction (

       "Transaction Key" BIGINT IDENTITY(1,1) ORDER NOT NULL,
       "Date Key" DATE NOT NULL,
       "Customer Key" INT NULL,
       "Bill To Customer Key" INT NULL,
       "Supplier Key" INT NULL,
       "Transaction Type Key" INT NOT NULL,
       "Payment Method Key" INT NULL,
       "WWI Customer Transaction ID" INT NULL,
       "WWI Supplier Transaction ID" INT NULL,
       "WWI Invoice ID" INT NULL,
       "WWI Purchase Order ID" INT NULL,
       "Supplier Invoice Number" NVARCHAR(20) COLLATE 'EN-CI-AS' /*** SSC-PRF-0002 - CASE INSENSITIVE COLUMNS CAN DECREASE THE PERFORMANCE OF QUERIES ***/ /*** SSC-FDM-TS0002 - COLLATION FOR VALUE 100 NOT SUPPORTED ***/ NULL,
       "Total Excluding Tax" DECIMAL(18, 2) NOT NULL,
       "Tax Amount" DECIMAL(18, 2) NOT NULL,
       "Total Including Tax" DECIMAL(18, 2) NOT NULL,
       "Outstanding Balance" DECIMAL(18, 2) NOT NULL,
       "Is Finalized" BOOLEAN NOT NULL,
       "Lineage Key" INT NOT NULL,
       CONSTRAINT PK_Fact_Transaction PRIMARY KEY ("Transaction Key", "Date Key")
   )
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
;

ALTER TABLE Fact.Transaction
    ADD CONSTRAINT FK_Fact_Transaction_Bill_To_Customer_Key_Dimension_Customer FOREIGN KEY ("Bill To Customer Key") REFERENCES Dimension.Customer ("Customer Key");

ALTER TABLE Fact.Transaction
ADD CONSTRAINT FK_Fact_Transaction_Customer_Key_Dimension_Customer FOREIGN KEY ("Customer Key") REFERENCES Dimension.Customer ("Customer Key");

ALTER TABLE Fact.Transaction
ADD CONSTRAINT FK_Fact_Transaction_Date_Key_Dimension_Date FOREIGN KEY ("Date Key") REFERENCES Dimension.Date (Date);

ALTER TABLE Fact.Transaction
ADD CONSTRAINT "FK_Fact_Transaction_Payment_Method_Key_Dimension_Payment Method" FOREIGN KEY ("Payment Method Key") REFERENCES Dimension."Payment Method" ("Payment Method Key");

ALTER TABLE Fact.Transaction
ADD CONSTRAINT FK_Fact_Transaction_Supplier_Key_Dimension_Supplier FOREIGN KEY ("Supplier Key") REFERENCES Dimension.Supplier ("Supplier Key");

ALTER TABLE Fact.Transaction
ADD CONSTRAINT "FK_Fact_Transaction_Transaction_Type_Key_Dimension_Transaction Type" FOREIGN KEY ("Transaction Type Key") REFERENCES Dimension."Transaction Type" ("Transaction Type Key");