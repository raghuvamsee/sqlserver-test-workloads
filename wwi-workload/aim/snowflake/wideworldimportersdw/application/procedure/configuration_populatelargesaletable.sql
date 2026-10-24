USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE PROCEDURE Application.Configuration_PopulateLargeSaleTable (ESTIMATEDROWSFOR2012 BIGINT DEFAULT 12000000)
RETURNS VARCHAR
LANGUAGE SQL
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
EXECUTE AS OWNER
AS
$$
	DECLARE
		RETURNVALUE INT;
		LINEAGEKEY INT := Sequences.LineageKey.NEXTVAL;
		ORDERCOUNTER BIGINT := 0;
		NUMBEROFSALESPERDAY BIGINT := TRUNC(:ESTIMATEDROWSFOR2012 / 365);
		DATECOUNTER DATE := '20120101';
		STARTINGSALEKEY BIGINT;
		MAXIMUMSALEKEY BIGINT;
		OUTPUTCOUNTER VARCHAR(20);
	BEGIN
--		--** SSC-FDM-TS0029 - SET NOCOUNT STATEMENT IS COMMENTED OUT, WHICH IS NOT APPLICABLE IN SNOWFLAKE. **
--		SET NOCOUNT ON;
--		--** SSC-FDM-TS0037 - SET XACT_ABORT ON STATEMENT IS NOT APPLICABLE IN SNOWFLAKE AS IT HAS EQUIVALENT DEFAULT BEHAVIOR. **
--		SET XACT_ABORT ON;
		CALL Integration.PopulateDateDimensionForYear(2012);
		CALL Application.Configuration_ApplyPartitionedColumnstoreIndexing();

INSERT INTO Integration.Lineage
("Lineage Key", "Data Load Started", "Table Name", "Data Load Completed", "Was Successful", "Source System Cutoff Time") VALUES
(:LINEAGEKEY, CURRENT_TIMESTAMP(), 'Sale', NULL, 0, '20121231');
		MAXIMUMSALEKEY := (SELECT
				MAX("Sale Key") FROM
				Fact.Sale
		);
		SYSTEM$LOG_INFO('Targeting ' || CAST(:NUMBEROFSALESPERDAY AS VARCHAR(20)) || ' sales per day.');
		IF (:NUMBEROFSALESPERDAY > 50000) THEN
			BEGIN
				SYSTEM$LOG_INFO('WARNING: Limiting sales to 40000 per day');
				NUMBEROFSALESPERDAY := 50000;
			END;
		END IF;

		-- DROP CONSTRAINTS
		ALTER TABLE IF EXISTS Fact.Sale DROP CONSTRAINT FK_Fact_Sale_City_Key_Dimension_City;
		ALTER TABLE IF EXISTS Fact.Sale DROP CONSTRAINT FK_Fact_Sale_Customer_Key_Dimension_Customer;
		ALTER TABLE IF EXISTS Fact.Sale DROP CONSTRAINT FK_Fact_Sale_Delivery_Date_Key_Dimension_Date;
		ALTER TABLE IF EXISTS Fact.Sale DROP CONSTRAINT FK_Fact_Sale_Invoice_Date_Key_Dimension_Date;
		ALTER TABLE IF EXISTS Fact.Sale DROP CONSTRAINT FK_Fact_Sale_Salesperson_Key_Dimension_Employee;
		ALTER TABLE IF EXISTS Fact.Sale DROP CONSTRAINT "FK_Fact_Sale_Stock_Item_Key_Dimension_Stock Item";
		ALTER TABLE IF EXISTS Fact.Sale DROP CONSTRAINT FK_Fact_Sale_Bill_To_Customer_Key_Dimension_Customer;
		ALTER TABLE IF EXISTS Fact.Sale DROP CONSTRAINT PK_Fact_Sale;
-- ** SSC-EWI-0001 - UNRECOGNIZED TOKEN ON LINE '48' COLUMN '14' OF THE SOURCE CODE STARTING AT 'IF'. EXPECTED 'If Statement' GRAMMAR. LAST MATCHING TOKEN WAS 'EXISTS' ON LINE '48' COLUMN '17'. **
--		                                                               IF EXISTS [FK_Fact_Sale_Bill_To_Customer_Key] ON [Fact].[Sale]
		WHILE (:DATECOUNTER < '2012-12-31') LOOP
			OUTPUTCOUNTER := LEFT(TO_VARCHAR(:DATECOUNTER, 'yyyymmdd'), 20);
			--** SSC-FDM-TS0019 - RAISERROR ERROR MESSAGE MAY DIFFER BECAUSE OF THE SQL SERVER STRING FORMAT **
			SELECT
				<%AIM_DB%>.PUBLIC.RAISERROR_UDF(:OUTPUTCOUNTER, 0, 1, array_construct());
			STARTINGSALEKEY := :MAXIMUMSALEKEY - :NUMBEROFSALESPERDAY - FLOOR(RANDOM() * 20000);
			ORDERCOUNTER := 0;
INSERT INTO Fact.Sale
	("City Key", "Customer Key", "Bill To Customer Key", "Stock Item Key", "Invoice Date Key", "Delivery Date Key", "Salesperson Key", "WWI Invoice ID", Description, Package, Quantity, "Unit Price", "Tax Rate", "Total Excluding Tax", "Tax Amount", Profit, "Total Including Tax", "Total Dry Items", "Total Chiller Items", "Lineage Key")
SELECT
--			!!!RESOLVE EWI!!! /*** SSC-EWI-0040 - THE 'TOP WITH A ROW COUNT THAT IS NOT AN INTEGER CONSTANT' CLAUSE IS NOT SUPPORTED IN SNOWFLAKE ***/!!! TOP(:NUMBEROFSALESPERDAY)
				"City Key",
				"Customer Key",
				"Bill To Customer Key",
				"Stock Item Key",
				:DATECOUNTER,
				DATEADD(day, 1, :DATECOUNTER),
				"Salesperson Key",
				"WWI Invoice ID",
				Description,
				Package,
				Quantity,
				"Unit Price",
				"Tax Rate",
				"Total Excluding Tax",
				"Tax Amount",
				Profit,
				"Total Including Tax",
				"Total Dry Items",
				"Total Chiller Items",
				:LINEAGEKEY
FROM
				Fact.Sale
WHERE
				"Sale Key" > :STARTINGSALEKEY
	and "Invoice Date Key" >='2013-01-01'
ORDER BY "Sale Key";
			DATECOUNTER := DATEADD(day, 1, :DATECOUNTER);
		END LOOP;
		--** SSC-FDM-TS0019 - RAISERROR ERROR MESSAGE MAY DIFFER BECAUSE OF THE SQL SERVER STRING FORMAT **
		SELECT
			<%AIM_DB%>.PUBLIC.RAISERROR_UDF('Compressing all open Rowgroups', 0, 1, array_construct());
--		--** SSC-FDM-0055 - ALTER INDEX IS NOT APPLICABLE IN SNOWFLAKE. STANDARD TABLES DO NOT USE USER-MANAGED INDEXES. **

--ALTER INDEX CCX_Fact_Sale
--ON Fact.Sale
--REORGANIZE WITH (COMPRESS_ALL_ROW_GROUPS = ON)
                                              ;

UPDATE Integration.Lineage
SET
				"Data Load Completed" = CURRENT_TIMESTAMP(),
				"Was Successful" = 1;
		-- Add back Constraints
		--** SSC-FDM-TS0019 - RAISERROR ERROR MESSAGE MAY DIFFER BECAUSE OF THE SQL SERVER STRING FORMAT **
		SELECT
			<%AIM_DB%>.PUBLIC.RAISERROR_UDF('Adding Constraints', 0, 1, array_construct());

ALTER TABLE Fact.Sale
ADD CONSTRAINT PK_Fact_Sale PRIMARY KEY ("Sale Key", "Invoice Date Key");

ALTER TABLE Fact.Sale
		ADD CONSTRAINT FK_Fact_Sale_Bill_To_Customer_Key_Dimension_Customer
FOREIGN KEY("Bill To Customer Key")
REFERENCES Dimension.Customer ("Customer Key");
--		--** SSC-FDM-TS0054 - CHECK CONSTRAINT STATEMENT REMOVED, ENABLING/DISABLING CONSTRAINTS IS NOT APPLICABLE IN SNOWFLAKE **

--ALTER TABLE Fact.Sale
--		CHECK CONSTRAINT FK_Fact_Sale_Bill_To_Customer_Key_Dimension_Customer
		                                                                     ;

ALTER TABLE Fact.Sale
		ADD CONSTRAINT "FK_Fact_Sale_Stock_Item_Key_Dimension_Stock Item"
FOREIGN KEY("Stock Item Key")
REFERENCES Dimension."Stock Item" ("Stock Item Key");
--		--** SSC-FDM-TS0054 - CHECK CONSTRAINT STATEMENT REMOVED, ENABLING/DISABLING CONSTRAINTS IS NOT APPLICABLE IN SNOWFLAKE **

--ALTER TABLE Fact.Sale
--		CHECK CONSTRAINT "FK_Fact_Sale_Stock_Item_Key_Dimension_Stock Item"
		                                                                   ;

ALTER TABLE Fact.Sale
		ADD  CONSTRAINT FK_Fact_Sale_Salesperson_Key_Dimension_Employee
FOREIGN KEY("Salesperson Key")
REFERENCES Dimension.Employee ("Employee Key");
--		--** SSC-FDM-TS0054 - CHECK CONSTRAINT STATEMENT REMOVED, ENABLING/DISABLING CONSTRAINTS IS NOT APPLICABLE IN SNOWFLAKE **

--ALTER TABLE Fact.Sale
--		CHECK CONSTRAINT FK_Fact_Sale_Salesperson_Key_Dimension_Employee
		                                                                ;

ALTER TABLE Fact.Sale
		ADD  CONSTRAINT FK_Fact_Sale_Invoice_Date_Key_Dimension_Date
FOREIGN KEY("Invoice Date Key")
REFERENCES Dimension.Date (Date);
--		--** SSC-FDM-TS0054 - CHECK CONSTRAINT STATEMENT REMOVED, ENABLING/DISABLING CONSTRAINTS IS NOT APPLICABLE IN SNOWFLAKE **

--ALTER TABLE Fact.Sale
--		CHECK CONSTRAINT FK_Fact_Sale_Invoice_Date_Key_Dimension_Date
		                                                             ;

ALTER TABLE Fact.Sale
		ADD CONSTRAINT FK_Fact_Sale_Delivery_Date_Key_Dimension_Date
FOREIGN KEY("Delivery Date Key")
REFERENCES Dimension.Date (Date);
--		--** SSC-FDM-TS0054 - CHECK CONSTRAINT STATEMENT REMOVED, ENABLING/DISABLING CONSTRAINTS IS NOT APPLICABLE IN SNOWFLAKE **

--ALTER TABLE Fact.Sale
--		CHECK CONSTRAINT FK_Fact_Sale_Delivery_Date_Key_Dimension_Date
		                                                              ;

ALTER TABLE Fact.Sale
		ADD CONSTRAINT FK_Fact_Sale_Customer_Key_Dimension_Customer
FOREIGN KEY("Customer Key")
REFERENCES Dimension.Customer ("Customer Key");
--		--** SSC-FDM-TS0054 - CHECK CONSTRAINT STATEMENT REMOVED, ENABLING/DISABLING CONSTRAINTS IS NOT APPLICABLE IN SNOWFLAKE **

--ALTER TABLE Fact.Sale
--		CHECK CONSTRAINT FK_Fact_Sale_Customer_Key_Dimension_Customer
		                                                             ;

ALTER TABLE Fact.Sale
		ADD  CONSTRAINT FK_Fact_Sale_City_Key_Dimension_City
FOREIGN KEY("City Key")
REFERENCES Dimension.City ("City Key");
--		--** SSC-FDM-TS0054 - CHECK CONSTRAINT STATEMENT REMOVED, ENABLING/DISABLING CONSTRAINTS IS NOT APPLICABLE IN SNOWFLAKE **

--ALTER TABLE Fact.Sale
--		CHECK CONSTRAINT FK_Fact_Sale_City_Key_Dimension_City
		                                                     ;
		-- Recreate indexes
		--** SSC-FDM-TS0019 - RAISERROR ERROR MESSAGE MAY DIFFER BECAUSE OF THE SQL SERVER STRING FORMAT **
		SELECT
			<%AIM_DB%>.PUBLIC.RAISERROR_UDF('Adding Non-clustered Indexes', 0, 1, array_construct());
--		--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE NONCLUSTERED INDEX [FK_Fact_Sale_Salesperson_Key] ON [Fact].[Sale] ([Salesperson Key] ASC)
                                                                                                 ;
--		--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE NONCLUSTERED INDEX [FK_Fact_Sale_Invoice_Date_Key] ON [Fact].[Sale] ([Invoice Date Key] ASC)
                                                                                                   ;
--		--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE NONCLUSTERED INDEX [FK_Fact_Sale_Delivery_Date_Key] ON [Fact].[Sale] ([Delivery Date Key] ASC)
                                                                                                     ;
--		--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE NONCLUSTERED INDEX [FK_Fact_Sale_Bill_To_Customer_Key] ON [Fact].[Sale] ([Bill To Customer Key] ASC)
                                                                                                           ;
--		--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE NONCLUSTERED INDEX [FK_Fact_Sale_City_Key] ON [Fact].[Sale] ([City Key] ASC)
                                                                                   ;
--		--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE NONCLUSTERED INDEX [FK_Fact_Sale_Customer_Key] ON [Fact].[Sale] ([Customer Key] ASC)
                                                                                           ;
		RETURN 0;
	END;
$$;