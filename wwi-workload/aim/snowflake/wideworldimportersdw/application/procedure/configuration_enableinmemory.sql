USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE PROCEDURE Application.Configuration_EnableInMemory ()
RETURNS VARCHAR
LANGUAGE SQL
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
EXECUTE AS CALLER
AS
$$
	DECLARE
		SQL NVARCHAR := '';
		SQLDATAFOLDER NVARCHAR;
		MEMORYOPTIMIZEDFILEGROUPFOLDER NVARCHAR := :SQLDATAFOLDER || 'WideWorldImportersDW_InMemory_Data_1';
	BEGIN
--		--** SSC-FDM-TS0029 - SET NOCOUNT STATEMENT IS COMMENTED OUT, WHICH IS NOT APPLICABLE IN SNOWFLAKE. **
--		SET NOCOUNT ON;
		!!!RESOLVE EWI!!! /*** SSC-EWI-TS0089 - SET XACT_ABORT ON IS NOT SUPPORTED IN SNOWFLAKE. ***/!!!
		SET XACT_ABORT ON;
		IF (SERVERPROPERTY('IsXTPSupported') !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'SERVERPROPERTY' NODE ***/!!! = 0) THEN
			BEGIN
				SYSTEM$LOG_INFO('Warning: In-memory tables cannot be created on this edition.');
			END;
		ELSE
			BEGIN -- if in-memory can be created

				 
				BEGIN
					IF (CAST(SERVERPROPERTY('EngineEdition') !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'SERVERPROPERTY' NODE ***/!!! AS INT) <> 5   -- Not an Azure SQL DB
					) THEN
						BEGIN
							SQLDATAFOLDER :=
 							                !!!RESOLVE EWI!!! /*** SSC-EWI-0125 - SNOWCONVERT COULD NOT DETERMINE WHAT VALUE THIS VARIABLE HOLDS WHEN THE DYNAMIC SQL EXECUTES. THE ASSIGNMENT EXPRESSION WAS CONVERTED ON ITS OWN; PLEASE REVIEW THAT ITS VALUE IS COMPATIBLE WITH THE EXECUTE IMMEDIATE THAT USES IT. ***/!!!
 							                (SELECT
 							                		SUBSTRING(df.physical_name, 1, CHARINDEX('WideWorldImportersDW.mdf', df.physical_name, 1) - 1)
 							                				                                        FROM
 							                		!!!RESOLVE EWI!!! /*** SSC-EWI-TS0135 - SYSTEM TABLE sys.database_files DESCRIBES THE DATABASE'S PHYSICAL DATA AND LOG FILES, FOR WHICH SNOWFLAKE HAS NO PER-FILE, PER-FILEGROUP OR PER-DATA-SPACE OBJECT. FOR STORAGE SIZES READ THE PER-TABLE INFORMATION_SCHEMA.TABLE_STORAGE_METRICS.ACTIVE_BYTES. ***/!!!
 							                		sys.database_files AS df
 							                				                                        WHERE
 							                		df.file_id = 1);
							 
							IF (NOT EXISTS (SELECT 1 FROM
 							                		!!!RESOLVE EWI!!! /*** SSC-EWI-TS0141 - SYSTEM VIEW sys.filegroups REPORTS FILEGROUP STORAGE PLACEMENT, WHICH SNOWFLAKE MANAGES ITSELF AND EXPOSES IN NO INFORMATION_SCHEMA OR ACCOUNT_USAGE VIEW; THE REFERENCE WAS LEFT AS WRITTEN, SO REDESIGN THE LOOKUP FOR THE TARGET DATA-PLACEMENT REQUIREMENTS. ***/!!!
 							                		sys.filegroups
 							                				                                        WHERE
 							                		name = 'WWIDW_InMemory_Data'
							)) THEN
 							                				                                        BEGIN
 							                		SQL := '
ALTER DATABASE CURRENT
ADD FILEGROUP WWIDW_InMemory_Data CONTAINS MEMORY_OPTIMIZED_DATA;';
 							                		--** SSC-FDM-0131 - THE DYNAMIC SQL CODE COULD NOT BE PARSED, SO IT WAS LEFT UNCHANGED AND WILL BE EXECUTED AS-IS AT RUNTIME. PLEASE REVIEW THE GENERATED CODE. **
 							                		EXECUTE IMMEDIATE :SQL;
 							                		SQL := '
ALTER DATABASE CURRENT
ADD FILE (name = N''WWIDW_InMemory_Data_1'', filename = ''' || :MEMORYOPTIMIZEDFILEGROUPFOLDER || ''')
TO FILEGROUP WWIDW_InMemory_Data;';
 							                		--** SSC-FDM-0131 - THE DYNAMIC SQL CODE COULD NOT BE PARSED, SO IT WAS LEFT UNCHANGED AND WILL BE EXECUTED AS-IS AT RUNTIME. PLEASE REVIEW THE GENERATED CODE. **
 							                		EXECUTE IMMEDIATE :SQL;

 							                				                                        END;
							END IF;
						         END;
					END IF;
					SQL := '
ALTER DATABASE CURRENT
SET MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT = ON;';
					--** SSC-FDM-0131 - THE DYNAMIC SQL CODE COULD NOT BE PARSED, SO IT WAS LEFT UNCHANGED AND WILL BE EXECUTED AS-IS AT RUNTIME. PLEASE REVIEW THE GENERATED CODE. **
					EXECUTE IMMEDIATE :SQL;
					IF (NOT EXISTS (SELECT 1 FROM
							INFORMATION_SCHEMA.TABLES
						WHERE
							TABLE_NAME = 'Customer_Staging'
							AND is_memory_optimized !!!RESOLVE EWI!!! /*** SSC-EWI-0003 - SYSTEM COLUMN 'is_memory_optimized' FOR BUILT-IN OBJECT 'SYS.TABLES' HAS NOT BEEN TRANSLATED. ***/!!! <> 0)) THEN
						BEGIN
							SQL := '
DROP TABLE IF EXISTS Integration.Customer_Staging;';
							EXECUTE IMMEDIATE :SQL;
							SQL := 'CREATE OR REPLACE TABLE Integration.Customer_Staging
(
   "Customer Staging Key" INT IDENTITY(1,1) ORDER NOT NULL,
   "WWI Customer ID" INT NOT NULL,
   Customer NVARCHAR(100) NOT NULL,
   "Bill To Customer" NVARCHAR(100) NOT NULL,
   Category NVARCHAR(50) NOT NULL,
   "Buying Group" NVARCHAR(50) NOT NULL,
   "Primary Contact" NVARCHAR(50) NOT NULL,
   "Postal Code" NVARCHAR(10) NOT NULL,
   "Valid From" TIMESTAMP_NTZ(7) NOT NULL,
   "Valid To" TIMESTAMP_NTZ(7) NOT NULL,
   CONSTRAINT PK_Integration_Customer_Staging PRIMARY KEY ("Customer Staging Key")
) WITH (MEMORY_OPTIMIZED = ON ,DURABILITY = SCHEMA_ONLY)
   ;' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionMemoryOptimized' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionFileTable' NODE ***/!!!;
							--** SSC-FDM-0019 - SEMANTIC INFORMATION COULD NOT BE LOADED FOR [Integration].[Customer_Staging]. CHECK IF THE NAME IS INVALID OR DUPLICATED. **
							EXECUTE IMMEDIATE :SQL;
END;
					END IF;
					IF (NOT EXISTS (SELECT 1 FROM
							INFORMATION_SCHEMA.TABLES
						WHERE
							TABLE_NAME = 'Employee_Staging'
							AND is_memory_optimized !!!RESOLVE EWI!!! /*** SSC-EWI-0003 - SYSTEM COLUMN 'is_memory_optimized' FOR BUILT-IN OBJECT 'SYS.TABLES' HAS NOT BEEN TRANSLATED. ***/!!! <> 0)) THEN
						BEGIN
							SQL := '
DROP TABLE IF EXISTS Integration.Employee_Staging;';
							EXECUTE IMMEDIATE :SQL;
							SQL := 'CREATE OR REPLACE TABLE Integration.Employee_Staging
(
   "Employee Staging Key" INT IDENTITY(1,1) ORDER NOT NULL,
   "WWI Employee ID" INT NOT NULL,
   Employee NVARCHAR(50) NOT NULL,
   "Preferred Name" NVARCHAR(50) NOT NULL,
   "Is Salesperson" BOOLEAN NOT NULL,
   Photo VARBINARY NULL,
   "Valid From" TIMESTAMP_NTZ(7) NOT NULL,
   "Valid To" TIMESTAMP_NTZ(7) NOT NULL,
   CONSTRAINT PK_Integration_Employee_Staging PRIMARY KEY ("Employee Staging Key")
) WITH (MEMORY_OPTIMIZED = ON ,DURABILITY = SCHEMA_ONLY)
   ;' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionMemoryOptimized' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionFileTable' NODE ***/!!!;
							--** SSC-FDM-0019 - SEMANTIC INFORMATION COULD NOT BE LOADED FOR [Integration].[Employee_Staging]. CHECK IF THE NAME IS INVALID OR DUPLICATED. **
							EXECUTE IMMEDIATE :SQL;
END;
					END IF;
					IF (NOT EXISTS (SELECT 1 FROM
							INFORMATION_SCHEMA.TABLES
						WHERE
							TABLE_NAME = 'Movement_Staging'
							AND is_memory_optimized !!!RESOLVE EWI!!! /*** SSC-EWI-0003 - SYSTEM COLUMN 'is_memory_optimized' FOR BUILT-IN OBJECT 'SYS.TABLES' HAS NOT BEEN TRANSLATED. ***/!!! <> 0)) THEN
						BEGIN
							SQL := '
DROP TABLE IF EXISTS Integration.Movement_Staging;';
							EXECUTE IMMEDIATE :SQL;
							SQL := 'CREATE OR REPLACE TABLE Integration.Movement_Staging
(
   "Movement Staging Key" BIGINT IDENTITY(1,1) ORDER NOT NULL,
   "Date Key" DATE NULL,
   "Stock Item Key" INT NULL,
   "Customer Key" INT NULL,
   "Supplier Key" INT NULL,
   "Transaction Type Key" INT NULL,
   "WWI Stock Item Transaction ID" INT NULL,
   "WWI Invoice ID" INT NULL,
   "WWI Purchase Order ID" INT NULL,
   Quantity INT NULL,
   "WWI Stock Item ID" INT NULL,
   "WWI Customer ID" INT NULL,
   "WWI Supplier ID" INT NULL,
   "WWI Transaction Type ID" INT NULL,
   "Last Modifed When" TIMESTAMP_NTZ(7) NULL,
   CONSTRAINT PK_Integration_Movement_Staging PRIMARY KEY ("Movement Staging Key")
) WITH (MEMORY_OPTIMIZED = ON ,DURABILITY = SCHEMA_ONLY)
   ;' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionMemoryOptimized' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionFileTable' NODE ***/!!!;
							--** SSC-FDM-0019 - SEMANTIC INFORMATION COULD NOT BE LOADED FOR [Integration].[Movement_Staging]. CHECK IF THE NAME IS INVALID OR DUPLICATED. **
							EXECUTE IMMEDIATE :SQL;
END;
					END IF;
					IF (NOT EXISTS (SELECT 1 FROM
							INFORMATION_SCHEMA.TABLES
						WHERE
							TABLE_NAME = 'Order_Staging'
							AND is_memory_optimized !!!RESOLVE EWI!!! /*** SSC-EWI-0003 - SYSTEM COLUMN 'is_memory_optimized' FOR BUILT-IN OBJECT 'SYS.TABLES' HAS NOT BEEN TRANSLATED. ***/!!! <> 0)) THEN
						BEGIN
							SQL := '
DROP TABLE IF EXISTS Integration.Order_Staging;';
							EXECUTE IMMEDIATE :SQL;
							SQL := 'CREATE OR REPLACE TABLE Integration.Order_Staging (
   "Order Staging Key" BIGINT IDENTITY(1,1) ORDER NOT NULL,
   "City Key" INT NULL,
   "Customer Key" INT NULL,
   "Stock Item Key" INT NULL,
   "Order Date Key" DATE NULL,
   "Picked Date Key" DATE NULL,
   "Salesperson Key" INT NULL,
   "Picker Key" INT NULL,
   "WWI Order ID" INT NULL,
   "WWI Backorder ID" INT NULL,
   Description NVARCHAR(100) NULL,
   Package NVARCHAR(50) NULL,
   Quantity INT NULL,
   "Unit Price" DECIMAL(18, 2) NULL,
   "Tax Rate" DECIMAL(18, 3) NULL,
   "Total Excluding Tax" DECIMAL(18, 2) NULL,
   "Tax Amount" DECIMAL(18, 2) NULL,
   "Total Including Tax" DECIMAL(18, 2) NULL,
   "Lineage Key" INT NULL,
   "WWI City ID" INT NULL,
   "WWI Customer ID" INT NULL,
   "WWI Stock Item ID" INT NULL,
   "WWI Salesperson ID" INT NULL,
   "WWI Picker ID" INT NULL,
   "Last Modified When" TIMESTAMP_NTZ(7) NULL,
   CONSTRAINT PK_Integration_Order_Staging PRIMARY KEY ("Order Staging Key")
) WITH (MEMORY_OPTIMIZED = ON ,DURABILITY = SCHEMA_ONLY)
   ;' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionMemoryOptimized' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionFileTable' NODE ***/!!!;
							--** SSC-FDM-0019 - SEMANTIC INFORMATION COULD NOT BE LOADED FOR [Integration].[Order_Staging]. CHECK IF THE NAME IS INVALID OR DUPLICATED. **
							EXECUTE IMMEDIATE :SQL;
END;
					END IF;
					IF (NOT EXISTS (SELECT 1 FROM
							INFORMATION_SCHEMA.TABLES
						WHERE
							TABLE_NAME = 'PaymentMethod_Staging'
							AND is_memory_optimized !!!RESOLVE EWI!!! /*** SSC-EWI-0003 - SYSTEM COLUMN 'is_memory_optimized' FOR BUILT-IN OBJECT 'SYS.TABLES' HAS NOT BEEN TRANSLATED. ***/!!! <> 0)) THEN
						BEGIN
							SQL := '
DROP TABLE IF EXISTS Integration.PaymentMethod_Staging;';
							EXECUTE IMMEDIATE :SQL;
							SQL := 'CREATE OR REPLACE TABLE Integration.PaymentMethod_Staging
(
   "Payment Method Staging Key" INT IDENTITY(1,1) ORDER NOT NULL,
   "WWI Payment Method ID" INT NOT NULL,
   "Payment Method" NVARCHAR(50) NOT NULL,
   "Valid From" TIMESTAMP_NTZ(7) NOT NULL,
   "Valid To" TIMESTAMP_NTZ(7) NOT NULL,
   CONSTRAINT PK_Integration_Payment_Method_Staging PRIMARY KEY ("Payment Method Staging Key")
) WITH (MEMORY_OPTIMIZED = ON ,DURABILITY = SCHEMA_ONLY)
   ;' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionMemoryOptimized' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionFileTable' NODE ***/!!!;
							--** SSC-FDM-0019 - SEMANTIC INFORMATION COULD NOT BE LOADED FOR [Integration].[PaymentMethod_Staging]. CHECK IF THE NAME IS INVALID OR DUPLICATED. **
							EXECUTE IMMEDIATE :SQL;
END;
					END IF;
					IF (NOT EXISTS (SELECT 1 FROM
							INFORMATION_SCHEMA.TABLES
						WHERE
							TABLE_NAME = 'Purchase_Staging'
							AND is_memory_optimized !!!RESOLVE EWI!!! /*** SSC-EWI-0003 - SYSTEM COLUMN 'is_memory_optimized' FOR BUILT-IN OBJECT 'SYS.TABLES' HAS NOT BEEN TRANSLATED. ***/!!! <> 0)) THEN
						BEGIN
							SQL := '
DROP TABLE IF EXISTS Integration.Purchase_Staging;';
							EXECUTE IMMEDIATE :SQL;
							SQL := 'CREATE OR REPLACE TABLE Integration.Purchase_Staging
(
   "Purchase Staging Key" BIGINT IDENTITY(1,1) ORDER NOT NULL,
   "Date Key" DATE NULL,
   "Supplier Key" INT NULL,
   "Stock Item Key" INT NULL,
   "WWI Purchase Order ID" INT NULL,
   "Ordered Outers" INT NULL,
   "Ordered Quantity" INT NULL,
   "Received Outers" INT NULL,
   Package NVARCHAR(50) NULL,
   "Is Order Finalized" BOOLEAN NULL,
   "WWI Supplier ID" INT NULL,
   "WWI Stock Item ID" INT NULL,
   "Last Modified When" TIMESTAMP_NTZ(7) NULL,
   CONSTRAINT PK_Integration_Purchase_Staging PRIMARY KEY ("Purchase Staging Key")
) WITH (MEMORY_OPTIMIZED = ON ,DURABILITY = SCHEMA_ONLY)
   ;' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionMemoryOptimized' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionFileTable' NODE ***/!!!;
							--** SSC-FDM-0019 - SEMANTIC INFORMATION COULD NOT BE LOADED FOR [Integration].[Purchase_Staging]. CHECK IF THE NAME IS INVALID OR DUPLICATED. **
							EXECUTE IMMEDIATE :SQL;
END;
					END IF;
					IF (NOT EXISTS (SELECT 1 FROM
							INFORMATION_SCHEMA.TABLES
						WHERE
							TABLE_NAME = 'Sale_Staging'
							AND is_memory_optimized !!!RESOLVE EWI!!! /*** SSC-EWI-0003 - SYSTEM COLUMN 'is_memory_optimized' FOR BUILT-IN OBJECT 'SYS.TABLES' HAS NOT BEEN TRANSLATED. ***/!!! <> 0)) THEN
						BEGIN
							SQL := '
DROP TABLE IF EXISTS Integration.Sale_Staging;';
							EXECUTE IMMEDIATE :SQL;
							SQL := 'CREATE OR REPLACE TABLE Integration.Sale_Staging
(
   "Sale Staging Key" BIGINT IDENTITY(1,1) ORDER NOT NULL,
   "City Key" INT NULL,
   "Customer Key" INT NULL,
   "Bill To Customer Key" INT NULL,
   "Stock Item Key" INT NULL,
   "Invoice Date Key" DATE NULL,
   "Delivery Date Key" DATE NULL,
   "Salesperson Key" INT NULL,
   "WWI Invoice ID" INT NULL,
   Description NVARCHAR(100) NULL,
   Package NVARCHAR(50) NULL,
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
) WITH (MEMORY_OPTIMIZED = ON ,DURABILITY = SCHEMA_ONLY)
   ;' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionMemoryOptimized' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionFileTable' NODE ***/!!!;
							--** SSC-FDM-0019 - SEMANTIC INFORMATION COULD NOT BE LOADED FOR [Integration].[Sale_Staging]. CHECK IF THE NAME IS INVALID OR DUPLICATED. **
							EXECUTE IMMEDIATE :SQL;
END;
					END IF;
					IF (NOT EXISTS (SELECT 1 FROM
							INFORMATION_SCHEMA.TABLES
						WHERE
							TABLE_NAME = 'StockHolding_Staging'
							AND is_memory_optimized !!!RESOLVE EWI!!! /*** SSC-EWI-0003 - SYSTEM COLUMN 'is_memory_optimized' FOR BUILT-IN OBJECT 'SYS.TABLES' HAS NOT BEEN TRANSLATED. ***/!!! <> 0)) THEN
						BEGIN
							SQL := '
DROP TABLE IF EXISTS Integration.StockHolding_Staging;';
							EXECUTE IMMEDIATE :SQL;
							SQL := 'CREATE OR REPLACE TABLE Integration.StockHolding_Staging
(
   "Stock Holding Staging Key" BIGINT IDENTITY(1,1) ORDER NOT NULL,
   "Stock Item Key" INT NULL,
   "Quantity On Hand" INT NULL,
   "Bin Location" NVARCHAR(20) NULL,
   "Last Stocktake Quantity" INT NULL,
   "Last Cost Price" DECIMAL(18, 2) NULL,
   "Reorder Level" INT NULL,
   "Target Stock Level" INT NULL,
   "WWI Stock Item ID" INT NULL,
   CONSTRAINT PK_Integration_Stock_Holding_Staging PRIMARY KEY ("Stock Holding Staging Key")
) WITH (MEMORY_OPTIMIZED = ON ,DURABILITY = SCHEMA_ONLY)
   ;' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionMemoryOptimized' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionFileTable' NODE ***/!!!;
							--** SSC-FDM-0019 - SEMANTIC INFORMATION COULD NOT BE LOADED FOR [Integration].[StockHolding_Staging]. CHECK IF THE NAME IS INVALID OR DUPLICATED. **
							EXECUTE IMMEDIATE :SQL;
END;
					END IF;
					IF (NOT EXISTS (SELECT 1 FROM
							INFORMATION_SCHEMA.TABLES
						WHERE
							TABLE_NAME = 'StockItem_Staging'
							AND is_memory_optimized !!!RESOLVE EWI!!! /*** SSC-EWI-0003 - SYSTEM COLUMN 'is_memory_optimized' FOR BUILT-IN OBJECT 'SYS.TABLES' HAS NOT BEEN TRANSLATED. ***/!!! <> 0)) THEN
						BEGIN
							SQL := '
DROP TABLE IF EXISTS Integration.StockItem_Staging;';
							EXECUTE IMMEDIATE :SQL;
							SQL := 'CREATE OR REPLACE TABLE Integration.StockItem_Staging
(
   "Stock Item Staging Key" INT IDENTITY(1,1) ORDER NOT NULL,
   "WWI Stock Item ID" INT NOT NULL,
   "Stock Item" NVARCHAR(100) NOT NULL,
   Color NVARCHAR(20) NOT NULL,
   "Selling Package" NVARCHAR(50) NOT NULL,
   "Buying Package" NVARCHAR(50) NOT NULL,
   Brand NVARCHAR(50) NOT NULL,
   Size NVARCHAR(20) NOT NULL,
   "Lead Time Days" INT NOT NULL,
   "Quantity Per Outer" INT NOT NULL,
   "Is Chiller Stock" BOOLEAN NOT NULL,
   Barcode NVARCHAR(50) NULL,
   "Tax Rate" DECIMAL(18, 3) NOT NULL,
   "Unit Price" DECIMAL(18, 2) NOT NULL,
   "Recommended Retail Price" DECIMAL(18, 2) NULL,
   "Typical Weight Per Unit" DECIMAL(18, 3) NOT NULL,
   Photo VARBINARY NULL,
   "Valid From" TIMESTAMP_NTZ(7) NOT NULL,
   "Valid To" TIMESTAMP_NTZ(7) NOT NULL,
   CONSTRAINT PK_Integration_Stock_Item_Staging PRIMARY KEY ("Stock Item Staging Key")
) WITH (MEMORY_OPTIMIZED = ON ,DURABILITY = SCHEMA_ONLY)
   ;' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionMemoryOptimized' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionFileTable' NODE ***/!!!;
							--** SSC-FDM-0019 - SEMANTIC INFORMATION COULD NOT BE LOADED FOR [Integration].[StockItem_Staging]. CHECK IF THE NAME IS INVALID OR DUPLICATED. **
							EXECUTE IMMEDIATE :SQL;
END;
					END IF;
					IF (NOT EXISTS (SELECT 1 FROM
							INFORMATION_SCHEMA.TABLES
						WHERE
							TABLE_NAME = 'Supplier_Staging'
							AND is_memory_optimized !!!RESOLVE EWI!!! /*** SSC-EWI-0003 - SYSTEM COLUMN 'is_memory_optimized' FOR BUILT-IN OBJECT 'SYS.TABLES' HAS NOT BEEN TRANSLATED. ***/!!! <> 0)) THEN
						BEGIN
							SQL := '
DROP TABLE IF EXISTS Integration.Supplier_Staging;';
							EXECUTE IMMEDIATE :SQL;
							SQL := 'CREATE OR REPLACE TABLE Integration.Supplier_Staging
(
   "Supplier Staging Key" INT IDENTITY(1,1) ORDER NOT NULL,
   "WWI Supplier ID" INT NOT NULL,
   Supplier NVARCHAR(100) NOT NULL,
   Category NVARCHAR(50) NOT NULL,
   "Primary Contact" NVARCHAR(50) NOT NULL,
   "Supplier Reference" NVARCHAR(20) NULL,
   "Payment Days" INT NOT NULL,
   "Postal Code" NVARCHAR(10) NOT NULL,
   "Valid From" TIMESTAMP_NTZ(7) NOT NULL,
   "Valid To" TIMESTAMP_NTZ(7) NOT NULL,
   CONSTRAINT PK_Integration_Supplier_Staging PRIMARY KEY ("Supplier Staging Key")
) WITH (MEMORY_OPTIMIZED = ON ,DURABILITY = SCHEMA_ONLY)
   ;' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionMemoryOptimized' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionFileTable' NODE ***/!!!;
							--** SSC-FDM-0019 - SEMANTIC INFORMATION COULD NOT BE LOADED FOR [Integration].[Supplier_Staging]. CHECK IF THE NAME IS INVALID OR DUPLICATED. **
							EXECUTE IMMEDIATE :SQL;
END;
					END IF;
					IF (NOT EXISTS (SELECT 1 FROM
							INFORMATION_SCHEMA.TABLES
						WHERE
							TABLE_NAME = 'Transaction_Staging'
							AND is_memory_optimized !!!RESOLVE EWI!!! /*** SSC-EWI-0003 - SYSTEM COLUMN 'is_memory_optimized' FOR BUILT-IN OBJECT 'SYS.TABLES' HAS NOT BEEN TRANSLATED. ***/!!! <> 0)) THEN
						BEGIN
							SQL := '
DROP TABLE IF EXISTS Integration.Transaction_Staging;';
							EXECUTE IMMEDIATE :SQL;
							SQL := 'CREATE OR REPLACE TABLE Integration.Transaction_Staging
(
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
   "Supplier Invoice Number" NVARCHAR(20) NULL,
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
) WITH (MEMORY_OPTIMIZED = ON ,DURABILITY = SCHEMA_ONLY)
   ;' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionMemoryOptimized' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionFileTable' NODE ***/!!!;
							--** SSC-FDM-0019 - SEMANTIC INFORMATION COULD NOT BE LOADED FOR [Integration].[Transaction_Staging]. CHECK IF THE NAME IS INVALID OR DUPLICATED. **
							EXECUTE IMMEDIATE :SQL;
END;
					END IF;
					IF (NOT EXISTS (SELECT 1 FROM
							INFORMATION_SCHEMA.TABLES
						WHERE
							TABLE_NAME = 'TransactionType_Staging'
							AND is_memory_optimized !!!RESOLVE EWI!!! /*** SSC-EWI-0003 - SYSTEM COLUMN 'is_memory_optimized' FOR BUILT-IN OBJECT 'SYS.TABLES' HAS NOT BEEN TRANSLATED. ***/!!! <> 0)) THEN
						BEGIN
							SQL := '
DROP TABLE IF EXISTS Integration.TransactionType_Staging;';
							EXECUTE IMMEDIATE :SQL;
							SQL := 'CREATE OR REPLACE TABLE Integration.TransactionType_Staging
(
   "Transaction Type Staging Key" INT IDENTITY(1,1) ORDER NOT NULL,
   "WWI Transaction Type ID" INT NOT NULL,
   "Transaction Type" NVARCHAR(50) NOT NULL,
   "Valid From" TIMESTAMP_NTZ(7) NOT NULL,
   "Valid To" TIMESTAMP_NTZ(7) NOT NULL
    CONSTRAINT PK_Integration_Transaction_Type_Staging PRIMARY KEY ("Transaction Type Staging Key")
) WITH (MEMORY_OPTIMIZED = ON ,DURABILITY = SCHEMA_ONLY)
   ;' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionMemoryOptimized' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionFileTable' NODE ***/!!!;
							--** SSC-FDM-0019 - SEMANTIC INFORMATION COULD NOT BE LOADED FOR [Integration].[TransactionType_Staging]. CHECK IF THE NAME IS INVALID OR DUPLICATED. **
							EXECUTE IMMEDIATE :SQL;
END;
					END IF;
				EXCEPTION
					WHEN OTHER THEN
						SYSTEM$LOG_INFO('Unable to apply in-memory tables');
						RAISE;
				END;
			END; -- of in-memory is allowed

		END IF;
	END;
$$;