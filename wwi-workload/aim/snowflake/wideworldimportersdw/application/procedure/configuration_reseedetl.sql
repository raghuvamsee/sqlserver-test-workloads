USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE PROCEDURE Application.Configuration_ReseedETL ()
RETURNS VARCHAR
LANGUAGE SQL
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
EXECUTE AS OWNER
AS
$$
	DECLARE
		STARTINGETLCUTOFFTIME TIMESTAMP_NTZ(7) := '20121231';
		STARTOFTIME TIMESTAMP_NTZ(7) := '20130101';
		ENDOFTIME TIMESTAMP_NTZ(7) := '99991231 23:59:59.9999999';
	BEGIN
--		--** SSC-FDM-TS0029 - SET NOCOUNT STATEMENT IS COMMENTED OUT, WHICH IS NOT APPLICABLE IN SNOWFLAKE. **
--		SET NOCOUNT ON;

		UPDATE Integration."ETL Cutoff"
			SET
				"Cutoff Time" = :STARTINGETLCUTOFFTIME;

		TRUNCATE TABLE Fact.Movement;
		TRUNCATE TABLE Fact."Order";
		TRUNCATE TABLE Fact.Purchase;
		TRUNCATE TABLE Fact.Sale;
		TRUNCATE TABLE Fact."Stock Holding";
		TRUNCATE TABLE Fact.Transaction;
		DELETE FROM
			Dimension.City;
		DELETE FROM
			Dimension.Customer;
		DELETE FROM
			Dimension.Employee;
		DELETE FROM
			Dimension."Payment Method";
		DELETE FROM
			Dimension."Stock Item";
		DELETE FROM
			Dimension.Supplier;
		DELETE FROM
			Dimension."Transaction Type";

		   INSERT INTO Dimension.City
		       ("City Key", "WWI City ID", City, "State Province", Country, Continent, "Sales Territory", Region, Subregion, Location, "Latest Recorded Population", "Valid From", "Valid To", "Lineage Key") VALUES
		       (0, 0, 'Unknown', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A',
		        NULL, 0, :STARTOFTIME, :ENDOFTIME, 0);

		   INSERT INTO Dimension.Customer
		       ("Customer Key", "WWI Customer ID", Customer, "Bill To Customer", Category, "Buying Group", "Primary Contact", "Postal Code", "Valid From", "Valid To", "Lineage Key") VALUES
		       (0, 0, 'Unknown', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', :STARTOFTIME, :ENDOFTIME, 0);

		   INSERT INTO Dimension.Employee
		       ("Employee Key", "WWI Employee ID", Employee, "Preferred Name", "Is Salesperson", Photo, "Valid From", "Valid To", "Lineage Key") VALUES
		       (0, 0, 'Unknown', 'N/A',
		        0, NULL, :STARTOFTIME, :ENDOFTIME, 0);

		   INSERT INTO Dimension."Payment Method"
		       ("Payment Method Key", "WWI Payment Method ID", "Payment Method", "Valid From", "Valid To", "Lineage Key") VALUES
		       (0, 0, 'Unknown', :STARTOFTIME, :ENDOFTIME, 0);

		   INSERT INTO Dimension."Stock Item"
		       ("Stock Item Key", "WWI Stock Item ID", "Stock Item", Color, "Selling Package", "Buying Package", Brand, Size, "Lead Time Days", "Quantity Per Outer", "Is Chiller Stock", Barcode, "Tax Rate", "Unit Price", "Recommended Retail Price", "Typical Weight Per Unit", Photo, "Valid From", "Valid To", "Lineage Key") VALUES
		       (0, 0, 'Unknown', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 0, 0, 0, 'N/A', 0, 0, 0, 0,
		        NULL, :STARTOFTIME, :ENDOFTIME, 0);

		   INSERT INTO Dimension.Supplier
		       ("Supplier Key", "WWI Supplier ID", Supplier, Category, "Primary Contact", "Supplier Reference", "Payment Days", "Postal Code", "Valid From", "Valid To", "Lineage Key") VALUES
		       (0, 0, 'Unknown', 'N/A', 'N/A', 'N/A',
		        0, 'N/A', :STARTOFTIME, :ENDOFTIME, 0);

		   INSERT INTO Dimension."Transaction Type"
		       ("Transaction Type Key", "WWI Transaction Type ID", "Transaction Type", "Valid From", "Valid To", "Lineage Key") VALUES
		       (0, 0, 'Unknown', :STARTOFTIME, :ENDOFTIME, 0);
	END;
$$;