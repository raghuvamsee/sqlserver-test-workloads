USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE PROCEDURE Application.Configuration_ApplyPartitionedColumnstoreIndexing ()
RETURNS VARCHAR
LANGUAGE SQL
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
EXECUTE AS OWNER
AS
$$
	DECLARE
		SQL NVARCHAR := '';
	BEGIN
--		--** SSC-FDM-TS0029 - SET NOCOUNT STATEMENT IS COMMENTED OUT, WHICH IS NOT APPLICABLE IN SNOWFLAKE. **
--		SET NOCOUNT ON;
		!!!RESOLVE EWI!!! /*** SSC-EWI-TS0089 - SET XACT_ABORT ON IS NOT SUPPORTED IN SNOWFLAKE. ***/!!!
		SET XACT_ABORT ON;
		IF (SERVERPROPERTY('IsXTPSupported') !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'SERVERPROPERTY' NODE ***/!!! = 0 -- TODO !! - currently no separate test for columnstore
		) THEN
			BEGIN                                    -- but same editions with XTP support columnstore

				SYSTEM$LOG_INFO('Warning: Columnstore indexes cannot be created on this edition.');
			END;
		ELSE
			BEGIN -- if columnstore can be created

				 
				BEGIN
					IF (NOT EXISTS (SELECT 1 FROM
							(
								SELECT
									CAST(null AS VARCHAR) AS name,
									CAST(null AS NUMBER(38, 0)) AS function_id,
									CAST(null AS VARCHAR) AS type_desc,
									CAST(null AS NUMBER(38, 0)) AS fanout,
									CAST(null AS BOOLEAN) AS boundary_value_on_right
								WHERE
									false
							) AS partition_functions
						WHERE
							name = 'PF_Date'
					)) THEN
						BEGIN
							SQL := '
CREATE PARTITION FUNCTION PF_Date(date)
AS RANGE RIGHT
FOR VALUES (N''20120101'',N''20130101'',N''20140101'', N''20150101'', N''20160101'', N''20170101'');';
							--** SSC-FDM-0131 - THE DYNAMIC SQL CODE COULD NOT BE PARSED, SO IT WAS LEFT UNCHANGED AND WILL BE EXECUTED AS-IS AT RUNTIME. PLEASE REVIEW THE GENERATED CODE. **
							EXECUTE IMMEDIATE :SQL;
							SYSTEM$LOG_INFO('Created partition function PF_Date');
						END;
					END IF;
					IF (NOT EXISTS (SELECT 1 FROM
							(
								SELECT
									CAST(null AS VARCHAR) AS name,
									CAST(null AS NUMBER(38, 0)) AS function_id
								WHERE
									false
							) AS partition_schemes
						WHERE
							name = 'PS_Date'
					)) THEN
						BEGIN
							-- for Azure DB, assign to primary filegroup
							IF (SERVERPROPERTY('EngineEdition') !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'SERVERPROPERTY' NODE ***/!!! = 5) THEN
								SQL := '
CREATE PARTITION SCHEME PS_Date
AS PARTITION PF_Date
ALL TO ([PRIMARY]);';
							END IF;
							-- for other engine editions, assign to user data filegroup
							IF (SERVERPROPERTY('EngineEdition') !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'SERVERPROPERTY' NODE ***/!!! != 5) THEN
								SQL := '
CREATE PARTITION SCHEME PS_Date
AS PARTITION PF_Date
ALL TO ([USERDATA]);';
							END IF;
							--** SSC-FDM-0131 - THE DYNAMIC SQL CODE COULD NOT BE PARSED, SO IT WAS LEFT UNCHANGED AND WILL BE EXECUTED AS-IS AT RUNTIME. PLEASE REVIEW THE GENERATED CODE. **
							--** SSC-FDM-0131 - THE DYNAMIC SQL CODE COULD NOT BE PARSED, SO IT WAS LEFT UNCHANGED AND WILL BE EXECUTED AS-IS AT RUNTIME. PLEASE REVIEW THE GENERATED CODE. **
							--** SSC-FDM-0131 - THE DYNAMIC SQL CODE COULD NOT BE PARSED, SO IT WAS LEFT UNCHANGED AND WILL BE EXECUTED AS-IS AT RUNTIME. PLEASE REVIEW THE GENERATED CODE. **
							EXECUTE IMMEDIATE :SQL;
							SYSTEM$LOG_INFO('Created partition scheme PS_Date');
						END;
					END IF;
					IF (NOT EXISTS (SELECT 1 FROM
							--** SSC-FDM-TS0079 - INDEX METADATA FOR STANDARD TABLES IS NOT SUPPORTED IN SNOWFLAKE. INFORMATION_SCHEMA.INDEXES IS USED AS A WORKAROUND FOR HYBRID TABLES. **
							INFORMATION_SCHEMA.INDEXES
						WHERE
							NAME = 'CCX_Fact_Movement'
					)) THEN
						BEGIN
BEGIN TRANSACTION;
							SQL :=
							!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
							'

DROP INDEX [FK_Fact_Movement_Customer_Key] ON Fact.Movement;
DROP INDEX [FK_Fact_Movement_Date_Key] ON Fact.Movement;
DROP INDEX [FK_Fact_Movement_Stock_Item_Key] ON Fact.Movement;
DROP INDEX [FK_Fact_Movement_Supplier_Key] ON Fact.Movement;
DROP INDEX [FK_Fact_Movement_Transaction_Type_Key] ON Fact.Movement;
DROP INDEX [IX_Integration_Movement_WWI_Stock_Item_Transaction_ID] ON Fact.Movement;

ALTER TABLE IF EXISTS Fact.Movement DROP CONSTRAINT PK_Fact_Movement;

--CREATE CLUSTERED INDEX CCX_Fact_Movement
--ON Fact.Movement
--(
--	[Date Key]
--)
--ON PS_Date([Date Key])

--CREATE CLUSTERED COLUMNSTORE INDEX CCX_Fact_Movement
--ON Fact.Movement WITH (DROP_EXISTING = ON)
--ON PS_Date([Date Key])

ALTER TABLE IF EXISTS Fact.Movement
ADD  CONSTRAINT PK_Fact_Movement PRIMARY KEY ("Movement Key", "Date Key");

--CREATE NONCLUSTERED INDEX [FK_Fact_Movement_Customer_Key]
--ON [Fact].[Movement]
--(
--	[Customer Key]
--)
--ON PS_Date([Date Key])

--CREATE NONCLUSTERED INDEX [FK_Fact_Movement_Date_Key]
--ON [Fact].[Movement]
--(
--	[Date Key]
--)
--ON PS_Date([Date Key])

--CREATE NONCLUSTERED INDEX [FK_Fact_Movement_Stock_Item_Key]
--ON [Fact].[Movement]
--(
--	[Stock Item Key]
--)
--ON PS_Date([Date Key])

--CREATE NONCLUSTERED INDEX [FK_Fact_Movement_Supplier_Key]
--ON [Fact].[Movement]
--(
--	[Supplier Key]
--)
--ON PS_Date([Date Key])

--CREATE NONCLUSTERED INDEX [FK_Fact_Movement_Transaction_Type_Key]
--ON [Fact].[Movement]
--(
--	[Transaction Type Key]
--)
--ON PS_Date([Date Key])

--CREATE NONCLUSTERED INDEX [IX_Integration_Movement_WWI_Stock_Item_Transaction_ID]
--ON [Fact].[Movement]
--(
--	[WWI Stock Item Transaction ID]
--)
--ON PS_Date([Date Key])

DROP INDEX [FK_Fact_Order_City_Key] ON Fact.[Order];
DROP INDEX [FK_Fact_Order_Customer_Key] ON Fact.[Order];
DROP INDEX [FK_Fact_Order_Order_Date_Key] ON Fact.[Order];
DROP INDEX [FK_Fact_Order_Picked_Date_Key] ON Fact.[Order];
DROP INDEX [FK_Fact_Order_Picker_Key] ON Fact.[Order];
DROP INDEX [FK_Fact_Order_Salesperson_Key] ON Fact.[Order];
DROP INDEX [FK_Fact_Order_Stock_Item_Key] ON Fact.[Order];
DROP INDEX [IX_Integration_Order_WWI_Order_ID] ON Fact.[Order];

ALTER TABLE IF EXISTS Fact."Order" DROP CONSTRAINT PK_Fact_Order;

--CREATE CLUSTERED INDEX CCX_Fact_Order
--ON Fact.[Order]
--(
--	[Order Date Key]
--)
--ON PS_Date([Order Date Key])

--CREATE CLUSTERED COLUMNSTORE INDEX CCX_Fact_Order
--ON Fact.[Order] WITH (DROP_EXISTING = ON)
--ON PS_Date([Order Date Key])

ALTER TABLE IF EXISTS Fact."Order"
ADD  CONSTRAINT PK_Fact_Order PRIMARY KEY ("Order Key", "Order Date Key");

--CREATE NONCLUSTERED INDEX [FK_Fact_Order_City_Key]
--ON [Fact].[Order]
--(
--	[City Key]
--)
--ON PS_Date([Order Date Key])

--CREATE NONCLUSTERED INDEX [FK_Fact_Order_Customer_Key]
--ON [Fact].[Order]
--(
--	[Customer Key]
--)
--ON PS_Date([Order Date Key])

--CREATE NONCLUSTERED INDEX [FK_Fact_Order_Order_Date_Key]
--ON [Fact].[Order]
--(
--	[Order Date Key]
--)
--ON PS_Date([Order Date Key])

--CREATE NONCLUSTERED INDEX [FK_Fact_Order_Picked_Date_Key]
--ON [Fact].[Order]
--(
--	[Picked Date Key]
--)
--ON PS_Date([Order Date Key])

--CREATE NONCLUSTERED INDEX [FK_Fact_Order_Picker_Key]
--ON [Fact].[Order]
--(
--	[Picker Key] ASC
--)
--ON PS_Date([Order Date Key])

--CREATE NONCLUSTERED INDEX [FK_Fact_Order_Salesperson_Key]
--ON [Fact].[Order]
--(
--	[Salesperson Key]
--)
--ON PS_Date([Order Date Key])

--CREATE NONCLUSTERED INDEX [FK_Fact_Order_Stock_Item_Key]
--ON [Fact].[Order]
--(
--	[Stock Item Key]
--)
--ON PS_Date([Order Date Key])

--CREATE NONCLUSTERED INDEX [IX_Integration_Order_WWI_Order_ID]
--ON [Fact].[Order]
--(
--	[WWI Order ID]
--)
--ON PS_Date([Order Date Key])

DROP INDEX [FK_Fact_Purchase_Date_Key] ON Fact.Purchase;
DROP INDEX [FK_Fact_Purchase_Stock_Item_Key] ON Fact.Purchase;
DROP INDEX [FK_Fact_Purchase_Supplier_Key] ON Fact.Purchase;

ALTER TABLE IF EXISTS Fact.Purchase DROP CONSTRAINT PK_Fact_Purchase;

--CREATE CLUSTERED INDEX CCX_Fact_Purchase
--ON Fact.Purchase
--(
--	[Date Key]
--)
--ON PS_Date([Date Key])

--CREATE CLUSTERED COLUMNSTORE INDEX CCX_Fact_Purchase
--ON Fact.Purchase WITH (DROP_EXISTING = ON)
--ON PS_Date([Date Key])

ALTER TABLE IF EXISTS Fact.Purchase
ADD CONSTRAINT PK_Fact_Purchase PRIMARY KEY ("Purchase Key", "Date Key");

--CREATE NONCLUSTERED INDEX [FK_Fact_Purchase_Date_Key]
--ON [Fact].[Purchase]
--(
--	[Date Key]
--)
--ON PS_Date([Date Key])

--CREATE NONCLUSTERED INDEX [FK_Fact_Purchase_Stock_Item_Key]
--ON [Fact].[Purchase]
--(
--	[Stock Item Key]
--)
--ON PS_Date([Date Key])

--CREATE NONCLUSTERED INDEX [FK_Fact_Purchase_Supplier_Key]
--ON [Fact].[Purchase]
--(
--	[Supplier Key]
--)
--ON PS_Date([Date Key])

DROP INDEX [FK_Fact_Sale_Bill_To_Customer_Key] ON Fact.Sale;
DROP INDEX [FK_Fact_Sale_City_Key] ON Fact.Sale;
DROP INDEX [FK_Fact_Sale_Customer_Key] ON Fact.Sale;
DROP INDEX [FK_Fact_Sale_Delivery_Date_Key] ON Fact.Sale;
DROP INDEX [FK_Fact_Sale_Invoice_Date_Key] ON Fact.Sale;
DROP INDEX [FK_Fact_Sale_Salesperson_Key] ON Fact.Sale;
DROP INDEX [FK_Fact_Sale_Stock_Item_Key] ON Fact.Sale;

ALTER TABLE IF EXISTS Fact.Sale DROP CONSTRAINT PK_Fact_Sale;

--CREATE CLUSTERED INDEX CCX_Fact_Sale
--ON Fact.Sale
--(
--	[Invoice Date Key]
--)
--ON PS_Date([Invoice Date Key])

--CREATE CLUSTERED COLUMNSTORE INDEX CCX_Fact_Sale
--ON Fact.Sale WITH (DROP_EXISTING = ON)
--ON PS_Date([Invoice Date Key])

ALTER TABLE IF EXISTS Fact.Sale
ADD CONSTRAINT PK_Fact_Sale PRIMARY KEY ("Sale Key", "Invoice Date Key");

--CREATE NONCLUSTERED INDEX [FK_Fact_Sale_Bill_To_Customer_Key]
--ON [Fact].[Sale]
--(
--	[Bill To Customer Key]
--)
--ON PS_Date([Invoice Date Key])

--CREATE NONCLUSTERED INDEX [FK_Fact_Sale_City_Key]
--ON [Fact].[Sale]
--(
--	[City Key]
--)
--ON PS_Date([Invoice Date Key])

--CREATE NONCLUSTERED INDEX [FK_Fact_Sale_Customer_Key]
--ON [Fact].[Sale]
--(
--	[Customer Key]
--)
--ON PS_Date([Invoice Date Key])

--CREATE NONCLUSTERED INDEX [FK_Fact_Sale_Delivery_Date_Key]
--ON [Fact].[Sale]
--(
--	[Delivery Date Key]
--)
--ON PS_Date([Invoice Date Key])

--CREATE NONCLUSTERED INDEX [FK_Fact_Sale_Invoice_Date_Key]
--ON [Fact].[Sale]
--(
--	[Invoice Date Key]
--)
--ON PS_Date([Invoice Date Key])

--CREATE NONCLUSTERED INDEX [FK_Fact_Sale_Salesperson_Key]
--ON [Fact].[Sale]
--(
--	[Salesperson Key]
--)
--ON PS_Date([Invoice Date Key])

--CREATE NONCLUSTERED INDEX [FK_Fact_Sale_Stock_Item_Key]
--ON [Fact].[Sale]
--(
--	[Stock Item Key]
--)
--ON PS_Date([Invoice Date Key])

ALTER TABLE IF EXISTS Fact."Stock Holding" DROP CONSTRAINT PK_Fact_Stock_Holding;

ALTER TABLE IF EXISTS Fact."Stock Holding"
ADD CONSTRAINT PK_Fact_Stock_Holding PRIMARY KEY ("Stock Holding Key");

--CREATE CLUSTERED COLUMNSTORE INDEX CCX_Fact_Stock_Holding
--ON Fact.[Stock Holding]

DROP INDEX [FK_Fact_Transaction_Bill_To_Customer_Key] ON Fact.[Transaction];
DROP INDEX [FK_Fact_Transaction_Customer_Key] ON Fact.[Transaction];
DROP INDEX [FK_Fact_Transaction_Date_Key] ON Fact.[Transaction];
DROP INDEX [FK_Fact_Transaction_Payment_Method_Key] ON Fact.[Transaction];
DROP INDEX [FK_Fact_Transaction_Supplier_Key] ON Fact.[Transaction];
DROP INDEX [FK_Fact_Transaction_Transaction_Type_Key] ON Fact.[Transaction];

ALTER TABLE IF EXISTS Fact.Transaction DROP CONSTRAINT PK_Fact_Transaction;

--CREATE CLUSTERED INDEX CCX_Fact_Transaction
--ON Fact.[Transaction]
--(
--	[Date Key]
--)
--ON PS_Date([Date Key])

--CREATE CLUSTERED COLUMNSTORE INDEX CCX_Fact_Transaction
--ON Fact.[Transaction] WITH (DROP_EXISTING = ON)
--ON PS_Date([Date Key])

ALTER TABLE IF EXISTS Fact.Transaction
ADD CONSTRAINT PK_Fact_Transaction PRIMARY KEY ("Transaction Key", "Date Key");

--CREATE NONCLUSTERED INDEX [FK_Fact_Transaction_Bill_To_Customer_Key]
--ON [Fact].[Transaction]
--(
--	[Bill To Customer Key]
--)
--ON PS_Date([Date Key])

--CREATE NONCLUSTERED INDEX [FK_Fact_Transaction_Customer_Key]
--ON [Fact].[Transaction]
--(
--	[Customer Key]
--)
--ON PS_Date([Date Key])

--CREATE NONCLUSTERED INDEX [FK_Fact_Transaction_Date_Key]
--ON [Fact].[Transaction]
--(
--	[Date Key]
--)
--ON PS_Date([Date Key])

--CREATE NONCLUSTERED INDEX [FK_Fact_Transaction_Payment_Method_Key]
--ON [Fact].[Transaction]
--(
--	[Payment Method Key]
--)
--ON PS_Date([Date Key])

--CREATE NONCLUSTERED INDEX [FK_Fact_Transaction_Supplier_Key]
--ON [Fact].[Transaction]
--(
--	[Supplier Key]
--)
--ON PS_Date([Date Key])

--CREATE NONCLUSTERED INDEX [FK_Fact_Transaction_Transaction_Type_Key]
--ON [Fact].[Transaction]
--(
--	[Transaction Type Key]
--)
--ON PS_Date([Date Key])';
							BEGIN
								DROP INDEX
								[FK_Fact_Movement_Customer_Key] ON Fact.Movement;
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[FK_Fact_Movement_Date_Key] ON Fact.Movement;
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[FK_Fact_Movement_Stock_Item_Key] ON Fact.Movement;
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[FK_Fact_Movement_Supplier_Key] ON Fact.Movement;
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[FK_Fact_Movement_Transaction_Type_Key] ON Fact.Movement;
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[IX_Integration_Movement_WWI_Stock_Item_Transaction_ID] ON Fact.Movement;
								ALTER TABLE IF EXISTS Fact.Movement DROP CONSTRAINT PK_Fact_Movement;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE CLUSTERED INDEX CCX_Fact_Movement ON
--								Fact.Movement (
--									[Date Key]
--								)
--								ON PS_Date ([Date Key])
								                       ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE CLUSTERED COLUMNSTORE INDEX CCX_Fact_Movement ON
--								Fact.Movement
--								WITH (DROP_EXISTING = ON)
--								ON PS_Date ([Date Key])
								                       ;
								ALTER TABLE Fact.Movement
								ADD CONSTRAINT PK_Fact_Movement PRIMARY KEY ("Movement Key", "Date Key");
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [FK_Fact_Movement_Customer_Key] ON
--								[Fact].[Movement] (
--									[Customer Key]
--								)
--								ON PS_Date ([Date Key])
								                       ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [FK_Fact_Movement_Date_Key] ON
--								[Fact].[Movement] (
--									[Date Key]
--								)
--								ON PS_Date ([Date Key])
								                       ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [FK_Fact_Movement_Stock_Item_Key] ON
--								[Fact].[Movement] (
--									[Stock Item Key]
--								)
--								ON PS_Date ([Date Key])
								                       ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [FK_Fact_Movement_Supplier_Key] ON
--								[Fact].[Movement] (
--									[Supplier Key]
--								)
--								ON PS_Date ([Date Key])
								                       ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [FK_Fact_Movement_Transaction_Type_Key] ON
--								[Fact].[Movement] (
--									[Transaction Type Key]
--								)
--								ON PS_Date ([Date Key])
								                       ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [IX_Integration_Movement_WWI_Stock_Item_Transaction_ID] ON
--								[Fact].[Movement] (
--									[WWI Stock Item Transaction ID]
--								)
--								ON PS_Date ([Date Key])
								                       ;
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[FK_Fact_Order_City_Key] ON Fact.[Order];
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[FK_Fact_Order_Customer_Key] ON Fact.[Order];
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[FK_Fact_Order_Order_Date_Key] ON Fact.[Order];
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[FK_Fact_Order_Picked_Date_Key] ON Fact.[Order];
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[FK_Fact_Order_Picker_Key] ON Fact.[Order];
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[FK_Fact_Order_Salesperson_Key] ON Fact.[Order];
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[FK_Fact_Order_Stock_Item_Key] ON Fact.[Order];
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[IX_Integration_Order_WWI_Order_ID] ON Fact.[Order];
								ALTER TABLE IF EXISTS Fact."Order" DROP CONSTRAINT PK_Fact_Order;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE CLUSTERED INDEX CCX_Fact_Order ON
--								Fact.[Order] (
--									[Order Date Key]
--								)
--								ON PS_Date ([Order Date Key])
								                             ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE CLUSTERED COLUMNSTORE INDEX CCX_Fact_Order ON
--								Fact.[Order]
--								WITH (DROP_EXISTING = ON)
--								ON PS_Date ([Order Date Key])
								                             ;
								ALTER TABLE Fact."Order"
								ADD CONSTRAINT PK_Fact_Order PRIMARY KEY ("Order Key", "Order Date Key");
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [FK_Fact_Order_City_Key] ON
--								[Fact].[Order] (
--									[City Key]
--								)
--								ON PS_Date ([Order Date Key])
								                             ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [FK_Fact_Order_Customer_Key] ON
--								[Fact].[Order] (
--									[Customer Key]
--								)
--								ON PS_Date ([Order Date Key])
								                             ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [FK_Fact_Order_Order_Date_Key] ON
--								[Fact].[Order] (
--									[Order Date Key]
--								)
--								ON PS_Date ([Order Date Key])
								                             ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [FK_Fact_Order_Picked_Date_Key] ON
--								[Fact].[Order] (
--									[Picked Date Key]
--								)
--								ON PS_Date ([Order Date Key])
								                             ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [FK_Fact_Order_Picker_Key] ON
--								[Fact].[Order] (
--									[Picker Key] ASC
--								)
--								ON PS_Date ([Order Date Key])
								                             ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [FK_Fact_Order_Salesperson_Key] ON
--								[Fact].[Order] (
--									[Salesperson Key]
--								)
--								ON PS_Date ([Order Date Key])
								                             ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [FK_Fact_Order_Stock_Item_Key] ON
--								[Fact].[Order] (
--									[Stock Item Key]
--								)
--								ON PS_Date ([Order Date Key])
								                             ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [IX_Integration_Order_WWI_Order_ID] ON
--								[Fact].[Order] (
--									[WWI Order ID]
--								)
--								ON PS_Date ([Order Date Key])
								                             ;
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[FK_Fact_Purchase_Date_Key] ON Fact.Purchase;
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[FK_Fact_Purchase_Stock_Item_Key] ON Fact.Purchase;
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[FK_Fact_Purchase_Supplier_Key] ON Fact.Purchase;
								ALTER TABLE IF EXISTS Fact.Purchase DROP CONSTRAINT PK_Fact_Purchase;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE CLUSTERED INDEX CCX_Fact_Purchase ON
--								Fact.Purchase (
--									[Date Key]
--								)
--								ON PS_Date ([Date Key])
								                       ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE CLUSTERED COLUMNSTORE INDEX CCX_Fact_Purchase ON
--								Fact.Purchase
--								WITH (DROP_EXISTING = ON)
--								ON PS_Date ([Date Key])
								                       ;
								ALTER TABLE Fact.Purchase
								ADD CONSTRAINT PK_Fact_Purchase PRIMARY KEY ("Purchase Key", "Date Key");
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [FK_Fact_Purchase_Date_Key] ON
--								[Fact].[Purchase] (
--									[Date Key]
--								)
--								ON PS_Date ([Date Key])
								                       ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [FK_Fact_Purchase_Stock_Item_Key] ON
--								[Fact].[Purchase] (
--									[Stock Item Key]
--								)
--								ON PS_Date ([Date Key])
								                       ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [FK_Fact_Purchase_Supplier_Key] ON
--								[Fact].[Purchase] (
--									[Supplier Key]
--								)
--								ON PS_Date ([Date Key])
								                       ;
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[FK_Fact_Sale_Bill_To_Customer_Key] ON Fact.Sale;
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[FK_Fact_Sale_City_Key] ON Fact.Sale;
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[FK_Fact_Sale_Customer_Key] ON Fact.Sale;
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[FK_Fact_Sale_Delivery_Date_Key] ON Fact.Sale;
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[FK_Fact_Sale_Invoice_Date_Key] ON Fact.Sale;
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[FK_Fact_Sale_Salesperson_Key] ON Fact.Sale;
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[FK_Fact_Sale_Stock_Item_Key] ON Fact.Sale;
								ALTER TABLE IF EXISTS Fact.Sale DROP CONSTRAINT PK_Fact_Sale;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE CLUSTERED INDEX CCX_Fact_Sale ON
--								Fact.Sale (
--									[Invoice Date Key]
--								)
--								ON PS_Date ([Invoice Date Key])
								                               ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE CLUSTERED COLUMNSTORE INDEX CCX_Fact_Sale ON
--								Fact.Sale
--								WITH (DROP_EXISTING = ON)
--								ON PS_Date ([Invoice Date Key])
								                               ;
								ALTER TABLE Fact.Sale
								ADD CONSTRAINT PK_Fact_Sale PRIMARY KEY ("Sale Key", "Invoice Date Key");
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [FK_Fact_Sale_Bill_To_Customer_Key] ON
--								[Fact].[Sale] (
--									[Bill To Customer Key]
--								)
--								ON PS_Date ([Invoice Date Key])
								                               ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [FK_Fact_Sale_City_Key] ON
--								[Fact].[Sale] (
--									[City Key]
--								)
--								ON PS_Date ([Invoice Date Key])
								                               ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [FK_Fact_Sale_Customer_Key] ON
--								[Fact].[Sale] (
--									[Customer Key]
--								)
--								ON PS_Date ([Invoice Date Key])
								                               ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [FK_Fact_Sale_Delivery_Date_Key] ON
--								[Fact].[Sale] (
--									[Delivery Date Key]
--								)
--								ON PS_Date ([Invoice Date Key])
								                               ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [FK_Fact_Sale_Invoice_Date_Key] ON
--								[Fact].[Sale] (
--									[Invoice Date Key]
--								)
--								ON PS_Date ([Invoice Date Key])
								                               ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [FK_Fact_Sale_Salesperson_Key] ON
--								[Fact].[Sale] (
--									[Salesperson Key]
--								)
--								ON PS_Date ([Invoice Date Key])
								                               ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [FK_Fact_Sale_Stock_Item_Key] ON
--								[Fact].[Sale] (
--									[Stock Item Key]
--								)
--								ON PS_Date ([Invoice Date Key])
								                               ;
								ALTER TABLE IF EXISTS Fact."Stock Holding" DROP CONSTRAINT PK_Fact_Stock_Holding;
								ALTER TABLE Fact."Stock Holding"
								ADD CONSTRAINT PK_Fact_Stock_Holding PRIMARY KEY ("Stock Holding Key");
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE CLUSTERED COLUMNSTORE INDEX CCX_Fact_Stock_Holding ON
--								Fact.[Stock Holding]
								                    ;
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[FK_Fact_Transaction_Bill_To_Customer_Key] ON Fact.[Transaction];
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[FK_Fact_Transaction_Customer_Key] ON Fact.[Transaction];
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[FK_Fact_Transaction_Date_Key] ON Fact.[Transaction];
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[FK_Fact_Transaction_Payment_Method_Key] ON Fact.[Transaction];
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[FK_Fact_Transaction_Supplier_Key] ON Fact.[Transaction];
								!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropIndex' NODE ***/!!!
								DROP INDEX
								[FK_Fact_Transaction_Transaction_Type_Key] ON Fact.[Transaction];
								ALTER TABLE IF EXISTS Fact.Transaction DROP CONSTRAINT PK_Fact_Transaction;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE CLUSTERED INDEX CCX_Fact_Transaction ON
--								Fact.[Transaction] (
--									[Date Key]
--								)
--								ON PS_Date ([Date Key])
								                       ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE CLUSTERED COLUMNSTORE INDEX CCX_Fact_Transaction ON
--								Fact.[Transaction]
--								WITH (DROP_EXISTING = ON)
--								ON PS_Date ([Date Key])
								                       ;
								ALTER TABLE Fact.Transaction
								ADD CONSTRAINT PK_Fact_Transaction PRIMARY KEY ("Transaction Key", "Date Key");
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [FK_Fact_Transaction_Bill_To_Customer_Key] ON
--								[Fact].[Transaction] (
--									[Bill To Customer Key]
--								)
--								ON PS_Date ([Date Key])
								                       ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [FK_Fact_Transaction_Customer_Key] ON
--								[Fact].[Transaction] (
--									[Customer Key]
--								)
--								ON PS_Date ([Date Key])
								                       ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [FK_Fact_Transaction_Date_Key] ON
--								[Fact].[Transaction] (
--									[Date Key]
--								)
--								ON PS_Date ([Date Key])
								                       ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [FK_Fact_Transaction_Payment_Method_Key] ON
--								[Fact].[Transaction] (
--									[Payment Method Key]
--								)
--								ON PS_Date ([Date Key])
								                       ;
--								--** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--								CREATE NONCLUSTERED INDEX [FK_Fact_Transaction_Supplier_Key] ON
--								[Fact].[Transaction] (
--									[Supplier Key]
--								)
--								ON PS_Date ([Date Key])
								                       ;
								CREATE NONCLUSTERED INDEX [FK_Fact_Transaction_Transaction_Type_Key] ON
								[Fact].[Transaction] (
									[Transaction Type Key]
								)
								ON PS_Date ([Date Key]);
							END;
							COMMIT;
							SYSTEM$LOG_INFO('Applied partitioned columnstore indexing');
						END;
					END IF;
				EXCEPTION
					WHEN OTHER THEN
						SYSTEM$LOG_INFO('Unable to apply partitioned columnstore indexing');
						RAISE;
				END;
			END; -- of partitioned columnstore is allowed

		END IF;
	END;
$$;