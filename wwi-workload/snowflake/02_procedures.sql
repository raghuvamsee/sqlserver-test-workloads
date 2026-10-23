-- WideWorldImportersDW stored procedures and functions, converted from T-SQL to Snowflake Scripting.
-- Run after 01_schema.sql.

USE DATABASE WIDEWORLDIMPORTERSDW;

CREATE OR REPLACE FUNCTION "Integration"."GenerateDateDimensionColumns"(D DATE)
RETURNS TABLE (
    "Date" DATE, "Day Number" INT, "Day" VARCHAR(10), "Month" VARCHAR(10), "Short Month" VARCHAR(3),
    "Calendar Month Number" INT, "Calendar Month Label" VARCHAR(20), "Calendar Year" INT, "Calendar Year Label" VARCHAR(10),
    "Fiscal Month Number" INT, "Fiscal Month Label" VARCHAR(20), "Fiscal Year" INT, "Fiscal Year Label" VARCHAR(10),
    "ISO Week Number" INT
)
AS
$$
    SELECT D,
           DAY(D),
           TO_VARCHAR(DAY(D)),
           DECODE(MONTH(D), 1, 'January', 2, 'February', 3, 'March', 4, 'April', 5, 'May', 6, 'June', 7, 'July', 8, 'August', 9, 'September', 10, 'October', 11, 'November', 12, 'December'),
           MONTHNAME(D),
           MONTH(D),
           'CY' || YEAR(D) || '-' || MONTHNAME(D),
           YEAR(D),
           'CY' || YEAR(D),
           CASE WHEN MONTH(D) IN (11, 12) THEN MONTH(D) - 10 ELSE MONTH(D) + 2 END,
           'FY' || CASE WHEN MONTH(D) IN (11, 12) THEN YEAR(D) + 1 ELSE YEAR(D) END || '-' || MONTHNAME(D),
           CASE WHEN MONTH(D) IN (11, 12) THEN YEAR(D) + 1 ELSE YEAR(D) END,
           'FY' || CASE WHEN MONTH(D) IN (11, 12) THEN YEAR(D) + 1 ELSE YEAR(D) END,
           WEEKISO(D)
$$;

CREATE OR REPLACE PROCEDURE "Integration"."PopulateDateDimensionForYear"(YEAR_NUMBER INT)
RETURNS INT
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
BEGIN
    BEGIN TRANSACTION;
    INSERT INTO "Dimension"."Date"
        ("Date", "Day Number", "Day", "Month", "Short Month", "Calendar Month Number", "Calendar Month Label", "Calendar Year", "Calendar Year Label", "Fiscal Month Number", "Fiscal Month Label", "Fiscal Year", "Fiscal Year Label", "ISO Week Number")
    SELECT f."Date", f."Day Number", f."Day", f."Month", f."Short Month", f."Calendar Month Number", f."Calendar Month Label", f."Calendar Year", f."Calendar Year Label", f."Fiscal Month Number", f."Fiscal Month Label", f."Fiscal Year", f."Fiscal Year Label", f."ISO Week Number"
    FROM (SELECT DATEADD(day, ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1, DATE_FROM_PARTS(:year_number, 1, 1)) AS d
          FROM TABLE(GENERATOR(ROWCOUNT => 366))) AS g,
         TABLE("Integration"."GenerateDateDimensionColumns"(g.d)) AS f
    WHERE YEAR(g.d) = :year_number
      AND NOT EXISTS (SELECT 1 FROM "Dimension"."Date" AS dd WHERE dd."Date" = g.d);
    COMMIT;
    RETURN 0;
EXCEPTION
    WHEN OTHER THEN
        ROLLBACK;
        RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE "Integration"."GetLastETLCutoffTime"(TABLE_NAME VARCHAR)
RETURNS TIMESTAMP_NTZ(7)
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    cutoff_time TIMESTAMP_NTZ(7);
    row_count INT;
    invalid_etl_table_name EXCEPTION (-20001, 'Invalid ETL table name');
BEGIN
    SELECT COUNT(*), MAX("Cutoff Time") INTO :row_count, :cutoff_time
    FROM "Integration"."ETL Cutoff"
    WHERE "Table Name" = :table_name;

    IF (row_count = 0) THEN
        RAISE invalid_etl_table_name;
    END IF;

    RETURN cutoff_time;
END;
$$;

CREATE OR REPLACE PROCEDURE "Integration"."GetLineageKey"(TABLE_NAME VARCHAR, NEW_CUTOFF_TIME TIMESTAMP_NTZ)
RETURNS INT
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    lineage_key INT;
BEGIN
    SELECT "Sequences"."LineageKey".NEXTVAL INTO :lineage_key;

    INSERT INTO "Integration"."Lineage"
        ("Lineage Key", "Data Load Started", "Table Name", "Data Load Completed",
         "Was Successful", "Source System Cutoff Time")
    VALUES
        (:lineage_key, CURRENT_TIMESTAMP()::TIMESTAMP_NTZ, :table_name, NULL,
         FALSE, :new_cutoff_time);

    RETURN lineage_key;
END;
$$;

CREATE OR REPLACE PROCEDURE "Integration"."MigrateStagedCityData"()
RETURNS INT
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    end_of_time TIMESTAMP_NTZ(7) DEFAULT '9999-12-31 23:59:59.9999999'::TIMESTAMP_NTZ(7);
    lineage_key INT;
BEGIN
    BEGIN TRANSACTION;
    SELECT "Lineage Key" INTO :lineage_key
    FROM "Integration"."Lineage"
    WHERE "Table Name" = 'City'
      AND "Data Load Completed" IS NULL
    ORDER BY "Lineage Key" DESC
    LIMIT 1;

    UPDATE "Dimension"."City" AS d
        SET "Valid To" = rtco."Valid From"
    FROM (SELECT "WWI City ID", MIN("Valid From") AS "Valid From"
          FROM "Integration"."City_Staging"
          GROUP BY "WWI City ID") AS rtco
    WHERE d."WWI City ID" = rtco."WWI City ID"
      AND d."Valid To" = :end_of_time;

    INSERT INTO "Dimension"."City"
        ("WWI City ID", "City", "State Province", "Country", "Continent", "Sales Territory", "Region", "Subregion", "Location", "Latest Recorded Population", "Valid From", "Valid To", "Lineage Key")
    SELECT "WWI City ID", "City", "State Province", "Country", "Continent", "Sales Territory", "Region", "Subregion", "Location", "Latest Recorded Population", "Valid From", "Valid To", :lineage_key
    FROM "Integration"."City_Staging";

    UPDATE "Integration"."Lineage"
        SET "Data Load Completed" = CURRENT_TIMESTAMP()::TIMESTAMP_NTZ,
            "Was Successful" = TRUE
    WHERE "Lineage Key" = :lineage_key;

    UPDATE "Integration"."ETL Cutoff"
        SET "Cutoff Time" = (SELECT "Source System Cutoff Time"
                             FROM "Integration"."Lineage"
                             WHERE "Lineage Key" = :lineage_key)
    WHERE "Table Name" = 'City';
    COMMIT;
    RETURN 0;
EXCEPTION
    WHEN OTHER THEN
        ROLLBACK;
        RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE "Integration"."MigrateStagedCustomerData"()
RETURNS INT
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    end_of_time TIMESTAMP_NTZ(7) DEFAULT '9999-12-31 23:59:59.9999999'::TIMESTAMP_NTZ(7);
    lineage_key INT;
BEGIN
    BEGIN TRANSACTION;
    SELECT "Lineage Key" INTO :lineage_key
    FROM "Integration"."Lineage"
    WHERE "Table Name" = 'Customer'
      AND "Data Load Completed" IS NULL
    ORDER BY "Lineage Key" DESC
    LIMIT 1;

    UPDATE "Dimension"."Customer" AS d
        SET "Valid To" = rtco."Valid From"
    FROM (SELECT "WWI Customer ID", MIN("Valid From") AS "Valid From"
          FROM "Integration"."Customer_Staging"
          GROUP BY "WWI Customer ID") AS rtco
    WHERE d."WWI Customer ID" = rtco."WWI Customer ID"
      AND d."Valid To" = :end_of_time;

    INSERT INTO "Dimension"."Customer"
        ("WWI Customer ID", "Customer", "Bill To Customer", "Category", "Buying Group", "Primary Contact", "Postal Code", "Valid From", "Valid To", "Lineage Key")
    SELECT "WWI Customer ID", "Customer", "Bill To Customer", "Category", "Buying Group", "Primary Contact", "Postal Code", "Valid From", "Valid To", :lineage_key
    FROM "Integration"."Customer_Staging";

    UPDATE "Integration"."Lineage"
        SET "Data Load Completed" = CURRENT_TIMESTAMP()::TIMESTAMP_NTZ,
            "Was Successful" = TRUE
    WHERE "Lineage Key" = :lineage_key;

    UPDATE "Integration"."ETL Cutoff"
        SET "Cutoff Time" = (SELECT "Source System Cutoff Time"
                             FROM "Integration"."Lineage"
                             WHERE "Lineage Key" = :lineage_key)
    WHERE "Table Name" = 'Customer';
    COMMIT;
    RETURN 0;
EXCEPTION
    WHEN OTHER THEN
        ROLLBACK;
        RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE "Integration"."MigrateStagedEmployeeData"()
RETURNS INT
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    end_of_time TIMESTAMP_NTZ(7) DEFAULT '9999-12-31 23:59:59.9999999'::TIMESTAMP_NTZ(7);
    lineage_key INT;
BEGIN
    BEGIN TRANSACTION;
    SELECT "Lineage Key" INTO :lineage_key
    FROM "Integration"."Lineage"
    WHERE "Table Name" = 'Employee'
      AND "Data Load Completed" IS NULL
    ORDER BY "Lineage Key" DESC
    LIMIT 1;

    UPDATE "Dimension"."Employee" AS d
        SET "Valid To" = rtco."Valid From"
    FROM (SELECT "WWI Employee ID", MIN("Valid From") AS "Valid From"
          FROM "Integration"."Employee_Staging"
          GROUP BY "WWI Employee ID") AS rtco
    WHERE d."WWI Employee ID" = rtco."WWI Employee ID"
      AND d."Valid To" = :end_of_time;

    INSERT INTO "Dimension"."Employee"
        ("WWI Employee ID", "Employee", "Preferred Name", "Is Salesperson", "Photo", "Valid From", "Valid To", "Lineage Key")
    SELECT "WWI Employee ID", "Employee", "Preferred Name", "Is Salesperson", "Photo", "Valid From", "Valid To", :lineage_key
    FROM "Integration"."Employee_Staging";

    UPDATE "Integration"."Lineage"
        SET "Data Load Completed" = CURRENT_TIMESTAMP()::TIMESTAMP_NTZ,
            "Was Successful" = TRUE
    WHERE "Lineage Key" = :lineage_key;

    UPDATE "Integration"."ETL Cutoff"
        SET "Cutoff Time" = (SELECT "Source System Cutoff Time"
                             FROM "Integration"."Lineage"
                             WHERE "Lineage Key" = :lineage_key)
    WHERE "Table Name" = 'Employee';
    COMMIT;
    RETURN 0;
EXCEPTION
    WHEN OTHER THEN
        ROLLBACK;
        RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE "Integration"."MigrateStagedPaymentMethodData"()
RETURNS INT
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    end_of_time TIMESTAMP_NTZ(7) DEFAULT '9999-12-31 23:59:59.9999999'::TIMESTAMP_NTZ(7);
    lineage_key INT;
BEGIN
    BEGIN TRANSACTION;
    SELECT "Lineage Key" INTO :lineage_key
    FROM "Integration"."Lineage"
    WHERE "Table Name" = 'Payment Method'
      AND "Data Load Completed" IS NULL
    ORDER BY "Lineage Key" DESC
    LIMIT 1;

    UPDATE "Dimension"."Payment Method" AS d
        SET "Valid To" = rtco."Valid From"
    FROM (SELECT "WWI Payment Method ID", MIN("Valid From") AS "Valid From"
          FROM "Integration"."PaymentMethod_Staging"
          GROUP BY "WWI Payment Method ID") AS rtco
    WHERE d."WWI Payment Method ID" = rtco."WWI Payment Method ID"
      AND d."Valid To" = :end_of_time;

    INSERT INTO "Dimension"."Payment Method"
        ("WWI Payment Method ID", "Payment Method", "Valid From", "Valid To", "Lineage Key")
    SELECT "WWI Payment Method ID", "Payment Method", "Valid From", "Valid To", :lineage_key
    FROM "Integration"."PaymentMethod_Staging";

    UPDATE "Integration"."Lineage"
        SET "Data Load Completed" = CURRENT_TIMESTAMP()::TIMESTAMP_NTZ,
            "Was Successful" = TRUE
    WHERE "Lineage Key" = :lineage_key;

    UPDATE "Integration"."ETL Cutoff"
        SET "Cutoff Time" = (SELECT "Source System Cutoff Time"
                             FROM "Integration"."Lineage"
                             WHERE "Lineage Key" = :lineage_key)
    WHERE "Table Name" = 'Payment Method';
    COMMIT;
    RETURN 0;
EXCEPTION
    WHEN OTHER THEN
        ROLLBACK;
        RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE "Integration"."MigrateStagedStockItemData"()
RETURNS INT
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    end_of_time TIMESTAMP_NTZ(7) DEFAULT '9999-12-31 23:59:59.9999999'::TIMESTAMP_NTZ(7);
    lineage_key INT;
BEGIN
    BEGIN TRANSACTION;
    SELECT "Lineage Key" INTO :lineage_key
    FROM "Integration"."Lineage"
    WHERE "Table Name" = 'Stock Item'
      AND "Data Load Completed" IS NULL
    ORDER BY "Lineage Key" DESC
    LIMIT 1;

    UPDATE "Dimension"."Stock Item" AS d
        SET "Valid To" = rtco."Valid From"
    FROM (SELECT "WWI Stock Item ID", MIN("Valid From") AS "Valid From"
          FROM "Integration"."StockItem_Staging"
          GROUP BY "WWI Stock Item ID") AS rtco
    WHERE d."WWI Stock Item ID" = rtco."WWI Stock Item ID"
      AND d."Valid To" = :end_of_time;

    INSERT INTO "Dimension"."Stock Item"
        ("WWI Stock Item ID", "Stock Item", "Color", "Selling Package", "Buying Package", "Brand", "Size", "Lead Time Days", "Quantity Per Outer", "Is Chiller Stock", "Barcode", "Tax Rate", "Unit Price", "Recommended Retail Price", "Typical Weight Per Unit", "Photo", "Valid From", "Valid To", "Lineage Key")
    SELECT "WWI Stock Item ID", "Stock Item", "Color", "Selling Package", "Buying Package", "Brand", "Size", "Lead Time Days", "Quantity Per Outer", "Is Chiller Stock", "Barcode", "Tax Rate", "Unit Price", "Recommended Retail Price", "Typical Weight Per Unit", "Photo", "Valid From", "Valid To", :lineage_key
    FROM "Integration"."StockItem_Staging";

    UPDATE "Integration"."Lineage"
        SET "Data Load Completed" = CURRENT_TIMESTAMP()::TIMESTAMP_NTZ,
            "Was Successful" = TRUE
    WHERE "Lineage Key" = :lineage_key;

    UPDATE "Integration"."ETL Cutoff"
        SET "Cutoff Time" = (SELECT "Source System Cutoff Time"
                             FROM "Integration"."Lineage"
                             WHERE "Lineage Key" = :lineage_key)
    WHERE "Table Name" = 'Stock Item';
    COMMIT;
    RETURN 0;
EXCEPTION
    WHEN OTHER THEN
        ROLLBACK;
        RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE "Integration"."MigrateStagedSupplierData"()
RETURNS INT
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    end_of_time TIMESTAMP_NTZ(7) DEFAULT '9999-12-31 23:59:59.9999999'::TIMESTAMP_NTZ(7);
    lineage_key INT;
BEGIN
    BEGIN TRANSACTION;
    SELECT "Lineage Key" INTO :lineage_key
    FROM "Integration"."Lineage"
    WHERE "Table Name" = 'Supplier'
      AND "Data Load Completed" IS NULL
    ORDER BY "Lineage Key" DESC
    LIMIT 1;

    UPDATE "Dimension"."Supplier" AS d
        SET "Valid To" = rtco."Valid From"
    FROM (SELECT "WWI Supplier ID", MIN("Valid From") AS "Valid From"
          FROM "Integration"."Supplier_Staging"
          GROUP BY "WWI Supplier ID") AS rtco
    WHERE d."WWI Supplier ID" = rtco."WWI Supplier ID"
      AND d."Valid To" = :end_of_time;

    INSERT INTO "Dimension"."Supplier"
        ("WWI Supplier ID", "Supplier", "Category", "Primary Contact", "Supplier Reference", "Payment Days", "Postal Code", "Valid From", "Valid To", "Lineage Key")
    SELECT "WWI Supplier ID", "Supplier", "Category", "Primary Contact", "Supplier Reference", "Payment Days", "Postal Code", "Valid From", "Valid To", :lineage_key
    FROM "Integration"."Supplier_Staging";

    UPDATE "Integration"."Lineage"
        SET "Data Load Completed" = CURRENT_TIMESTAMP()::TIMESTAMP_NTZ,
            "Was Successful" = TRUE
    WHERE "Lineage Key" = :lineage_key;

    UPDATE "Integration"."ETL Cutoff"
        SET "Cutoff Time" = (SELECT "Source System Cutoff Time"
                             FROM "Integration"."Lineage"
                             WHERE "Lineage Key" = :lineage_key)
    WHERE "Table Name" = 'Supplier';
    COMMIT;
    RETURN 0;
EXCEPTION
    WHEN OTHER THEN
        ROLLBACK;
        RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE "Integration"."MigrateStagedTransactionTypeData"()
RETURNS INT
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    end_of_time TIMESTAMP_NTZ(7) DEFAULT '9999-12-31 23:59:59.9999999'::TIMESTAMP_NTZ(7);
    lineage_key INT;
BEGIN
    BEGIN TRANSACTION;
    SELECT "Lineage Key" INTO :lineage_key
    FROM "Integration"."Lineage"
    WHERE "Table Name" = 'Transaction Type'
      AND "Data Load Completed" IS NULL
    ORDER BY "Lineage Key" DESC
    LIMIT 1;

    UPDATE "Dimension"."Transaction Type" AS d
        SET "Valid To" = rtco."Valid From"
    FROM (SELECT "WWI Transaction Type ID", MIN("Valid From") AS "Valid From"
          FROM "Integration"."TransactionType_Staging"
          GROUP BY "WWI Transaction Type ID") AS rtco
    WHERE d."WWI Transaction Type ID" = rtco."WWI Transaction Type ID"
      AND d."Valid To" = :end_of_time;

    INSERT INTO "Dimension"."Transaction Type"
        ("WWI Transaction Type ID", "Transaction Type", "Valid From", "Valid To", "Lineage Key")
    SELECT "WWI Transaction Type ID", "Transaction Type", "Valid From", "Valid To", :lineage_key
    FROM "Integration"."TransactionType_Staging";

    UPDATE "Integration"."Lineage"
        SET "Data Load Completed" = CURRENT_TIMESTAMP()::TIMESTAMP_NTZ,
            "Was Successful" = TRUE
    WHERE "Lineage Key" = :lineage_key;

    UPDATE "Integration"."ETL Cutoff"
        SET "Cutoff Time" = (SELECT "Source System Cutoff Time"
                             FROM "Integration"."Lineage"
                             WHERE "Lineage Key" = :lineage_key)
    WHERE "Table Name" = 'Transaction Type';
    COMMIT;
    RETURN 0;
EXCEPTION
    WHEN OTHER THEN
        ROLLBACK;
        RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE "Integration"."MigrateStagedMovementData"()
RETURNS INT
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    lineage_key INT;
BEGIN
    BEGIN TRANSACTION;
    SELECT "Lineage Key" INTO :lineage_key
    FROM "Integration"."Lineage"
    WHERE "Table Name" = 'Movement'
      AND "Data Load Completed" IS NULL
    ORDER BY "Lineage Key" DESC
    LIMIT 1;

    -- Find the dimension keys required
    UPDATE "Integration"."Movement_Staging" AS st
        SET "Stock Item Key" = COALESCE(k.dim_key, 0)
    FROM (SELECT s."Movement Staging Key" AS staging_key, d."Stock Item Key" AS dim_key
          FROM "Integration"."Movement_Staging" AS s
          LEFT JOIN "Dimension"."Stock Item" AS d
                ON d."WWI Stock Item ID" = s."WWI Stock Item ID"
                AND s."Last Modifed When" > d."Valid From"
                AND s."Last Modifed When" <= d."Valid To"
          QUALIFY ROW_NUMBER() OVER (PARTITION BY s."Movement Staging Key" ORDER BY d."Valid From") = 1) AS k
    WHERE st."Movement Staging Key" = k.staging_key;

    UPDATE "Integration"."Movement_Staging" AS st
        SET "Customer Key" = COALESCE(k.dim_key, 0)
    FROM (SELECT s."Movement Staging Key" AS staging_key, d."Customer Key" AS dim_key
          FROM "Integration"."Movement_Staging" AS s
          LEFT JOIN "Dimension"."Customer" AS d
                ON d."WWI Customer ID" = s."WWI Customer ID"
                AND s."Last Modifed When" > d."Valid From"
                AND s."Last Modifed When" <= d."Valid To"
          QUALIFY ROW_NUMBER() OVER (PARTITION BY s."Movement Staging Key" ORDER BY d."Valid From") = 1) AS k
    WHERE st."Movement Staging Key" = k.staging_key;

    UPDATE "Integration"."Movement_Staging" AS st
        SET "Supplier Key" = COALESCE(k.dim_key, 0)
    FROM (SELECT s."Movement Staging Key" AS staging_key, d."Supplier Key" AS dim_key
          FROM "Integration"."Movement_Staging" AS s
          LEFT JOIN "Dimension"."Supplier" AS d
                ON d."WWI Supplier ID" = s."WWI Supplier ID"
                AND s."Last Modifed When" > d."Valid From"
                AND s."Last Modifed When" <= d."Valid To"
          QUALIFY ROW_NUMBER() OVER (PARTITION BY s."Movement Staging Key" ORDER BY d."Valid From") = 1) AS k
    WHERE st."Movement Staging Key" = k.staging_key;

    UPDATE "Integration"."Movement_Staging" AS st
        SET "Transaction Type Key" = COALESCE(k.dim_key, 0)
    FROM (SELECT s."Movement Staging Key" AS staging_key, d."Transaction Type Key" AS dim_key
          FROM "Integration"."Movement_Staging" AS s
          LEFT JOIN "Dimension"."Transaction Type" AS d
                ON d."WWI Transaction Type ID" = s."WWI Transaction Type ID"
                AND s."Last Modifed When" > d."Valid From"
                AND s."Last Modifed When" <= d."Valid To"
          QUALIFY ROW_NUMBER() OVER (PARTITION BY s."Movement Staging Key" ORDER BY d."Valid From") = 1) AS k
    WHERE st."Movement Staging Key" = k.staging_key;

    -- Merge the data into the fact table
    MERGE INTO "Fact"."Movement" AS m
    USING "Integration"."Movement_Staging" AS ms
    ON m."WWI Stock Item Transaction ID" = ms."WWI Stock Item Transaction ID"
    WHEN MATCHED THEN
        UPDATE SET "Date Key" = ms."Date Key",
                   "Stock Item Key" = ms."Stock Item Key",
                   "Customer Key" = ms."Customer Key",
                   "Supplier Key" = ms."Supplier Key",
                   "Transaction Type Key" = ms."Transaction Type Key",
                   "WWI Invoice ID" = ms."WWI Invoice ID",
                   "WWI Purchase Order ID" = ms."WWI Purchase Order ID",
                   "Quantity" = ms."Quantity",
                   "Lineage Key" = :lineage_key
    WHEN NOT MATCHED THEN
        INSERT ("Date Key", "Stock Item Key", "Customer Key", "Supplier Key", "Transaction Type Key", "WWI Stock Item Transaction ID", "WWI Invoice ID", "WWI Purchase Order ID", "Quantity", "Lineage Key")
        VALUES (ms."Date Key", ms."Stock Item Key", ms."Customer Key", ms."Supplier Key", ms."Transaction Type Key", ms."WWI Stock Item Transaction ID", ms."WWI Invoice ID", ms."WWI Purchase Order ID", ms."Quantity", :lineage_key);

    UPDATE "Integration"."Lineage"
        SET "Data Load Completed" = CURRENT_TIMESTAMP()::TIMESTAMP_NTZ,
            "Was Successful" = TRUE
    WHERE "Lineage Key" = :lineage_key;

    UPDATE "Integration"."ETL Cutoff"
        SET "Cutoff Time" = (SELECT "Source System Cutoff Time"
                             FROM "Integration"."Lineage"
                             WHERE "Lineage Key" = :lineage_key)
    WHERE "Table Name" = 'Movement';
    COMMIT;
    RETURN 0;
EXCEPTION
    WHEN OTHER THEN
        ROLLBACK;
        RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE "Integration"."MigrateStagedOrderData"()
RETURNS INT
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    lineage_key INT;
BEGIN
    BEGIN TRANSACTION;
    SELECT "Lineage Key" INTO :lineage_key
    FROM "Integration"."Lineage"
    WHERE "Table Name" = 'Order'
      AND "Data Load Completed" IS NULL
    ORDER BY "Lineage Key" DESC
    LIMIT 1;

    -- Find the dimension keys required
    UPDATE "Integration"."Order_Staging" AS st
        SET "City Key" = COALESCE(k.dim_key, 0)
    FROM (SELECT s."Order Staging Key" AS staging_key, d."City Key" AS dim_key
          FROM "Integration"."Order_Staging" AS s
          LEFT JOIN "Dimension"."City" AS d
                ON d."WWI City ID" = s."WWI City ID"
                AND s."Last Modified When" > d."Valid From"
                AND s."Last Modified When" <= d."Valid To"
          QUALIFY ROW_NUMBER() OVER (PARTITION BY s."Order Staging Key" ORDER BY d."Valid From") = 1) AS k
    WHERE st."Order Staging Key" = k.staging_key;

    UPDATE "Integration"."Order_Staging" AS st
        SET "Customer Key" = COALESCE(k.dim_key, 0)
    FROM (SELECT s."Order Staging Key" AS staging_key, d."Customer Key" AS dim_key
          FROM "Integration"."Order_Staging" AS s
          LEFT JOIN "Dimension"."Customer" AS d
                ON d."WWI Customer ID" = s."WWI Customer ID"
                AND s."Last Modified When" > d."Valid From"
                AND s."Last Modified When" <= d."Valid To"
          QUALIFY ROW_NUMBER() OVER (PARTITION BY s."Order Staging Key" ORDER BY d."Valid From") = 1) AS k
    WHERE st."Order Staging Key" = k.staging_key;

    UPDATE "Integration"."Order_Staging" AS st
        SET "Stock Item Key" = COALESCE(k.dim_key, 0)
    FROM (SELECT s."Order Staging Key" AS staging_key, d."Stock Item Key" AS dim_key
          FROM "Integration"."Order_Staging" AS s
          LEFT JOIN "Dimension"."Stock Item" AS d
                ON d."WWI Stock Item ID" = s."WWI Stock Item ID"
                AND s."Last Modified When" > d."Valid From"
                AND s."Last Modified When" <= d."Valid To"
          QUALIFY ROW_NUMBER() OVER (PARTITION BY s."Order Staging Key" ORDER BY d."Valid From") = 1) AS k
    WHERE st."Order Staging Key" = k.staging_key;

    UPDATE "Integration"."Order_Staging" AS st
        SET "Salesperson Key" = COALESCE(k.dim_key, 0)
    FROM (SELECT s."Order Staging Key" AS staging_key, d."Employee Key" AS dim_key
          FROM "Integration"."Order_Staging" AS s
          LEFT JOIN "Dimension"."Employee" AS d
                ON d."WWI Employee ID" = s."WWI Salesperson ID"
                AND s."Last Modified When" > d."Valid From"
                AND s."Last Modified When" <= d."Valid To"
          QUALIFY ROW_NUMBER() OVER (PARTITION BY s."Order Staging Key" ORDER BY d."Valid From") = 1) AS k
    WHERE st."Order Staging Key" = k.staging_key;

    UPDATE "Integration"."Order_Staging" AS st
        SET "Picker Key" = COALESCE(k.dim_key, 0)
    FROM (SELECT s."Order Staging Key" AS staging_key, d."Employee Key" AS dim_key
          FROM "Integration"."Order_Staging" AS s
          LEFT JOIN "Dimension"."Employee" AS d
                ON d."WWI Employee ID" = s."WWI Picker ID"
                AND s."Last Modified When" > d."Valid From"
                AND s."Last Modified When" <= d."Valid To"
          QUALIFY ROW_NUMBER() OVER (PARTITION BY s."Order Staging Key" ORDER BY d."Valid From") = 1) AS k
    WHERE st."Order Staging Key" = k.staging_key;

    -- Remove any existing entries for any of these orders
    DELETE FROM "Fact"."Order"
    WHERE "WWI Order ID" IN (SELECT "WWI Order ID" FROM "Integration"."Order_Staging");

    -- Insert all current details for these orders
    INSERT INTO "Fact"."Order"
        ("City Key", "Customer Key", "Stock Item Key", "Order Date Key", "Picked Date Key", "Salesperson Key", "Picker Key", "WWI Order ID", "WWI Backorder ID", "Description", "Package", "Quantity", "Unit Price", "Tax Rate", "Total Excluding Tax", "Tax Amount", "Total Including Tax", "Lineage Key")
    SELECT "City Key", "Customer Key", "Stock Item Key", "Order Date Key", "Picked Date Key", "Salesperson Key", "Picker Key", "WWI Order ID", "WWI Backorder ID", "Description", "Package", "Quantity", "Unit Price", "Tax Rate", "Total Excluding Tax", "Tax Amount", "Total Including Tax", :lineage_key
    FROM "Integration"."Order_Staging";

    UPDATE "Integration"."Lineage"
        SET "Data Load Completed" = CURRENT_TIMESTAMP()::TIMESTAMP_NTZ,
            "Was Successful" = TRUE
    WHERE "Lineage Key" = :lineage_key;

    UPDATE "Integration"."ETL Cutoff"
        SET "Cutoff Time" = (SELECT "Source System Cutoff Time"
                             FROM "Integration"."Lineage"
                             WHERE "Lineage Key" = :lineage_key)
    WHERE "Table Name" = 'Order';
    COMMIT;
    RETURN 0;
EXCEPTION
    WHEN OTHER THEN
        ROLLBACK;
        RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE "Integration"."MigrateStagedPurchaseData"()
RETURNS INT
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    lineage_key INT;
BEGIN
    BEGIN TRANSACTION;
    SELECT "Lineage Key" INTO :lineage_key
    FROM "Integration"."Lineage"
    WHERE "Table Name" = 'Purchase'
      AND "Data Load Completed" IS NULL
    ORDER BY "Lineage Key" DESC
    LIMIT 1;

    -- Find the dimension keys required
    UPDATE "Integration"."Purchase_Staging" AS st
        SET "Supplier Key" = COALESCE(k.dim_key, 0)
    FROM (SELECT s."Purchase Staging Key" AS staging_key, d."Supplier Key" AS dim_key
          FROM "Integration"."Purchase_Staging" AS s
          LEFT JOIN "Dimension"."Supplier" AS d
                ON d."WWI Supplier ID" = s."WWI Supplier ID"
                AND s."Last Modified When" > d."Valid From"
                AND s."Last Modified When" <= d."Valid To"
          QUALIFY ROW_NUMBER() OVER (PARTITION BY s."Purchase Staging Key" ORDER BY d."Valid From") = 1) AS k
    WHERE st."Purchase Staging Key" = k.staging_key;

    UPDATE "Integration"."Purchase_Staging" AS st
        SET "Stock Item Key" = COALESCE(k.dim_key, 0)
    FROM (SELECT s."Purchase Staging Key" AS staging_key, d."Stock Item Key" AS dim_key
          FROM "Integration"."Purchase_Staging" AS s
          LEFT JOIN "Dimension"."Stock Item" AS d
                ON d."WWI Stock Item ID" = s."WWI Stock Item ID"
                AND s."Last Modified When" > d."Valid From"
                AND s."Last Modified When" <= d."Valid To"
          QUALIFY ROW_NUMBER() OVER (PARTITION BY s."Purchase Staging Key" ORDER BY d."Valid From") = 1) AS k
    WHERE st."Purchase Staging Key" = k.staging_key;

    -- Remove any existing entries for any of these purchase orders
    DELETE FROM "Fact"."Purchase"
    WHERE "WWI Purchase Order ID" IN (SELECT "WWI Purchase Order ID" FROM "Integration"."Purchase_Staging");

    -- Insert all current details for these purchase orders
    INSERT INTO "Fact"."Purchase"
        ("Date Key", "Supplier Key", "Stock Item Key", "WWI Purchase Order ID", "Ordered Outers", "Ordered Quantity", "Received Outers", "Package", "Is Order Finalized", "Lineage Key")
    SELECT "Date Key", "Supplier Key", "Stock Item Key", "WWI Purchase Order ID", "Ordered Outers", "Ordered Quantity", "Received Outers", "Package", "Is Order Finalized", :lineage_key
    FROM "Integration"."Purchase_Staging";

    UPDATE "Integration"."Lineage"
        SET "Data Load Completed" = CURRENT_TIMESTAMP()::TIMESTAMP_NTZ,
            "Was Successful" = TRUE
    WHERE "Lineage Key" = :lineage_key;

    UPDATE "Integration"."ETL Cutoff"
        SET "Cutoff Time" = (SELECT "Source System Cutoff Time"
                             FROM "Integration"."Lineage"
                             WHERE "Lineage Key" = :lineage_key)
    WHERE "Table Name" = 'Purchase';
    COMMIT;
    RETURN 0;
EXCEPTION
    WHEN OTHER THEN
        ROLLBACK;
        RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE "Integration"."MigrateStagedSaleData"()
RETURNS INT
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    lineage_key INT;
BEGIN
    BEGIN TRANSACTION;
    SELECT "Lineage Key" INTO :lineage_key
    FROM "Integration"."Lineage"
    WHERE "Table Name" = 'Sale'
      AND "Data Load Completed" IS NULL
    ORDER BY "Lineage Key" DESC
    LIMIT 1;

    -- Find the dimension keys required
    UPDATE "Integration"."Sale_Staging" AS st
        SET "City Key" = COALESCE(k.dim_key, 0)
    FROM (SELECT s."Sale Staging Key" AS staging_key, d."City Key" AS dim_key
          FROM "Integration"."Sale_Staging" AS s
          LEFT JOIN "Dimension"."City" AS d
                ON d."WWI City ID" = s."WWI City ID"
                AND s."Last Modified When" > d."Valid From"
                AND s."Last Modified When" <= d."Valid To"
          QUALIFY ROW_NUMBER() OVER (PARTITION BY s."Sale Staging Key" ORDER BY d."Valid From") = 1) AS k
    WHERE st."Sale Staging Key" = k.staging_key;

    UPDATE "Integration"."Sale_Staging" AS st
        SET "Customer Key" = COALESCE(k.dim_key, 0)
    FROM (SELECT s."Sale Staging Key" AS staging_key, d."Customer Key" AS dim_key
          FROM "Integration"."Sale_Staging" AS s
          LEFT JOIN "Dimension"."Customer" AS d
                ON d."WWI Customer ID" = s."WWI Customer ID"
                AND s."Last Modified When" > d."Valid From"
                AND s."Last Modified When" <= d."Valid To"
          QUALIFY ROW_NUMBER() OVER (PARTITION BY s."Sale Staging Key" ORDER BY d."Valid From") = 1) AS k
    WHERE st."Sale Staging Key" = k.staging_key;

    UPDATE "Integration"."Sale_Staging" AS st
        SET "Bill To Customer Key" = COALESCE(k.dim_key, 0)
    FROM (SELECT s."Sale Staging Key" AS staging_key, d."Customer Key" AS dim_key
          FROM "Integration"."Sale_Staging" AS s
          LEFT JOIN "Dimension"."Customer" AS d
                ON d."WWI Customer ID" = s."WWI Bill To Customer ID"
                AND s."Last Modified When" > d."Valid From"
                AND s."Last Modified When" <= d."Valid To"
          QUALIFY ROW_NUMBER() OVER (PARTITION BY s."Sale Staging Key" ORDER BY d."Valid From") = 1) AS k
    WHERE st."Sale Staging Key" = k.staging_key;

    UPDATE "Integration"."Sale_Staging" AS st
        SET "Stock Item Key" = COALESCE(k.dim_key, 0)
    FROM (SELECT s."Sale Staging Key" AS staging_key, d."Stock Item Key" AS dim_key
          FROM "Integration"."Sale_Staging" AS s
          LEFT JOIN "Dimension"."Stock Item" AS d
                ON d."WWI Stock Item ID" = s."WWI Stock Item ID"
                AND s."Last Modified When" > d."Valid From"
                AND s."Last Modified When" <= d."Valid To"
          QUALIFY ROW_NUMBER() OVER (PARTITION BY s."Sale Staging Key" ORDER BY d."Valid From") = 1) AS k
    WHERE st."Sale Staging Key" = k.staging_key;

    UPDATE "Integration"."Sale_Staging" AS st
        SET "Salesperson Key" = COALESCE(k.dim_key, 0)
    FROM (SELECT s."Sale Staging Key" AS staging_key, d."Employee Key" AS dim_key
          FROM "Integration"."Sale_Staging" AS s
          LEFT JOIN "Dimension"."Employee" AS d
                ON d."WWI Employee ID" = s."WWI Salesperson ID"
                AND s."Last Modified When" > d."Valid From"
                AND s."Last Modified When" <= d."Valid To"
          QUALIFY ROW_NUMBER() OVER (PARTITION BY s."Sale Staging Key" ORDER BY d."Valid From") = 1) AS k
    WHERE st."Sale Staging Key" = k.staging_key;

    -- Remove any existing entries for any of these invoices
    DELETE FROM "Fact"."Sale"
    WHERE "WWI Invoice ID" IN (SELECT "WWI Invoice ID" FROM "Integration"."Sale_Staging");

    -- Insert all current details for these invoices
    INSERT INTO "Fact"."Sale"
        ("City Key", "Customer Key", "Bill To Customer Key", "Stock Item Key", "Invoice Date Key", "Delivery Date Key", "Salesperson Key", "WWI Invoice ID", "Description", "Package", "Quantity", "Unit Price", "Tax Rate", "Total Excluding Tax", "Tax Amount", "Profit", "Total Including Tax", "Total Dry Items", "Total Chiller Items", "Lineage Key")
    SELECT "City Key", "Customer Key", "Bill To Customer Key", "Stock Item Key", "Invoice Date Key", "Delivery Date Key", "Salesperson Key", "WWI Invoice ID", "Description", "Package", "Quantity", "Unit Price", "Tax Rate", "Total Excluding Tax", "Tax Amount", "Profit", "Total Including Tax", "Total Dry Items", "Total Chiller Items", :lineage_key
    FROM "Integration"."Sale_Staging";

    UPDATE "Integration"."Lineage"
        SET "Data Load Completed" = CURRENT_TIMESTAMP()::TIMESTAMP_NTZ,
            "Was Successful" = TRUE
    WHERE "Lineage Key" = :lineage_key;

    UPDATE "Integration"."ETL Cutoff"
        SET "Cutoff Time" = (SELECT "Source System Cutoff Time"
                             FROM "Integration"."Lineage"
                             WHERE "Lineage Key" = :lineage_key)
    WHERE "Table Name" = 'Sale';
    COMMIT;
    RETURN 0;
EXCEPTION
    WHEN OTHER THEN
        ROLLBACK;
        RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE "Integration"."MigrateStagedStockHoldingData"()
RETURNS INT
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    lineage_key INT;
BEGIN
    BEGIN TRANSACTION;
    SELECT "Lineage Key" INTO :lineage_key
    FROM "Integration"."Lineage"
    WHERE "Table Name" = 'Stock Holding'
      AND "Data Load Completed" IS NULL
    ORDER BY "Lineage Key" DESC
    LIMIT 1;

    -- Find the dimension keys required
    UPDATE "Integration"."StockHolding_Staging" AS st
        SET "Stock Item Key" = COALESCE(k.dim_key, 0)
    FROM (SELECT s."Stock Holding Staging Key" AS staging_key, d."Stock Item Key" AS dim_key
          FROM "Integration"."StockHolding_Staging" AS s
          LEFT JOIN "Dimension"."Stock Item" AS d
                ON d."WWI Stock Item ID" = s."WWI Stock Item ID"
          QUALIFY ROW_NUMBER() OVER (PARTITION BY s."Stock Holding Staging Key" ORDER BY d."Valid To" DESC) = 1) AS k
    WHERE st."Stock Holding Staging Key" = k.staging_key;

    -- Remove all existing holdings (DELETE rather than TRUNCATE so it stays inside the transaction)
    DELETE FROM "Fact"."Stock Holding";

    -- Insert all current stock holdings
    INSERT INTO "Fact"."Stock Holding"
        ("Stock Item Key", "Quantity On Hand", "Bin Location", "Last Stocktake Quantity", "Last Cost Price", "Reorder Level", "Target Stock Level", "Lineage Key")
    SELECT "Stock Item Key", "Quantity On Hand", "Bin Location", "Last Stocktake Quantity", "Last Cost Price", "Reorder Level", "Target Stock Level", :lineage_key
    FROM "Integration"."StockHolding_Staging";

    UPDATE "Integration"."Lineage"
        SET "Data Load Completed" = CURRENT_TIMESTAMP()::TIMESTAMP_NTZ,
            "Was Successful" = TRUE
    WHERE "Lineage Key" = :lineage_key;

    UPDATE "Integration"."ETL Cutoff"
        SET "Cutoff Time" = (SELECT "Source System Cutoff Time"
                             FROM "Integration"."Lineage"
                             WHERE "Lineage Key" = :lineage_key)
    WHERE "Table Name" = 'Stock Holding';
    COMMIT;
    RETURN 0;
EXCEPTION
    WHEN OTHER THEN
        ROLLBACK;
        RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE "Integration"."MigrateStagedTransactionData"()
RETURNS INT
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    lineage_key INT;
BEGIN
    BEGIN TRANSACTION;
    SELECT "Lineage Key" INTO :lineage_key
    FROM "Integration"."Lineage"
    WHERE "Table Name" = 'Transaction'
      AND "Data Load Completed" IS NULL
    ORDER BY "Lineage Key" DESC
    LIMIT 1;

    -- Find the dimension keys required
    UPDATE "Integration"."Transaction_Staging" AS st
        SET "Customer Key" = COALESCE(k.dim_key, 0)
    FROM (SELECT s."Transaction Staging Key" AS staging_key, d."Customer Key" AS dim_key
          FROM "Integration"."Transaction_Staging" AS s
          LEFT JOIN "Dimension"."Customer" AS d
                ON d."WWI Customer ID" = s."WWI Customer ID"
                AND s."Last Modified When" > d."Valid From"
                AND s."Last Modified When" <= d."Valid To"
          QUALIFY ROW_NUMBER() OVER (PARTITION BY s."Transaction Staging Key" ORDER BY d."Valid From") = 1) AS k
    WHERE st."Transaction Staging Key" = k.staging_key;

    UPDATE "Integration"."Transaction_Staging" AS st
        SET "Bill To Customer Key" = COALESCE(k.dim_key, 0)
    FROM (SELECT s."Transaction Staging Key" AS staging_key, d."Customer Key" AS dim_key
          FROM "Integration"."Transaction_Staging" AS s
          LEFT JOIN "Dimension"."Customer" AS d
                ON d."WWI Customer ID" = s."WWI Bill To Customer ID"
                AND s."Last Modified When" > d."Valid From"
                AND s."Last Modified When" <= d."Valid To"
          QUALIFY ROW_NUMBER() OVER (PARTITION BY s."Transaction Staging Key" ORDER BY d."Valid From") = 1) AS k
    WHERE st."Transaction Staging Key" = k.staging_key;

    UPDATE "Integration"."Transaction_Staging" AS st
        SET "Supplier Key" = COALESCE(k.dim_key, 0)
    FROM (SELECT s."Transaction Staging Key" AS staging_key, d."Supplier Key" AS dim_key
          FROM "Integration"."Transaction_Staging" AS s
          LEFT JOIN "Dimension"."Supplier" AS d
                ON d."WWI Supplier ID" = s."WWI Supplier ID"
                AND s."Last Modified When" > d."Valid From"
                AND s."Last Modified When" <= d."Valid To"
          QUALIFY ROW_NUMBER() OVER (PARTITION BY s."Transaction Staging Key" ORDER BY d."Valid From") = 1) AS k
    WHERE st."Transaction Staging Key" = k.staging_key;

    UPDATE "Integration"."Transaction_Staging" AS st
        SET "Transaction Type Key" = COALESCE(k.dim_key, 0)
    FROM (SELECT s."Transaction Staging Key" AS staging_key, d."Transaction Type Key" AS dim_key
          FROM "Integration"."Transaction_Staging" AS s
          LEFT JOIN "Dimension"."Transaction Type" AS d
                ON d."WWI Transaction Type ID" = s."WWI Transaction Type ID"
                AND s."Last Modified When" > d."Valid From"
                AND s."Last Modified When" <= d."Valid To"
          QUALIFY ROW_NUMBER() OVER (PARTITION BY s."Transaction Staging Key" ORDER BY d."Valid From") = 1) AS k
    WHERE st."Transaction Staging Key" = k.staging_key;

    UPDATE "Integration"."Transaction_Staging" AS st
        SET "Payment Method Key" = COALESCE(k.dim_key, 0)
    FROM (SELECT s."Transaction Staging Key" AS staging_key, d."Payment Method Key" AS dim_key
          FROM "Integration"."Transaction_Staging" AS s
          LEFT JOIN "Dimension"."Payment Method" AS d
                ON d."WWI Payment Method ID" = s."WWI Payment Method ID"
                AND s."Last Modified When" > d."Valid From"
                AND s."Last Modified When" <= d."Valid To"
          QUALIFY ROW_NUMBER() OVER (PARTITION BY s."Transaction Staging Key" ORDER BY d."Valid From") = 1) AS k
    WHERE st."Transaction Staging Key" = k.staging_key;

    -- Insert all the transactions
    INSERT INTO "Fact"."Transaction"
        ("Date Key", "Customer Key", "Bill To Customer Key", "Supplier Key", "Transaction Type Key", "Payment Method Key", "WWI Customer Transaction ID", "WWI Supplier Transaction ID", "WWI Invoice ID", "WWI Purchase Order ID", "Supplier Invoice Number", "Total Excluding Tax", "Tax Amount", "Total Including Tax", "Outstanding Balance", "Is Finalized", "Lineage Key")
    SELECT "Date Key", "Customer Key", "Bill To Customer Key", "Supplier Key", "Transaction Type Key", "Payment Method Key", "WWI Customer Transaction ID", "WWI Supplier Transaction ID", "WWI Invoice ID", "WWI Purchase Order ID", "Supplier Invoice Number", "Total Excluding Tax", "Tax Amount", "Total Including Tax", "Outstanding Balance", "Is Finalized", :lineage_key
    FROM "Integration"."Transaction_Staging";

    UPDATE "Integration"."Lineage"
        SET "Data Load Completed" = CURRENT_TIMESTAMP()::TIMESTAMP_NTZ,
            "Was Successful" = TRUE
    WHERE "Lineage Key" = :lineage_key;

    UPDATE "Integration"."ETL Cutoff"
        SET "Cutoff Time" = (SELECT "Source System Cutoff Time"
                             FROM "Integration"."Lineage"
                             WHERE "Lineage Key" = :lineage_key)
    WHERE "Table Name" = 'Transaction';
    COMMIT;
    RETURN 0;
EXCEPTION
    WHEN OTHER THEN
        ROLLBACK;
        RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE "Sequences"."ReseedSequenceBeyondTableValues"(SEQUENCE_NAME VARCHAR, SCHEMA_NAME VARCHAR, TABLE_NAME VARCHAR, COLUMN_NAME VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    quoted_sequence VARCHAR DEFAULT '"Sequences"."' || REPLACE(SEQUENCE_NAME, '"', '""') || '"';
    quoted_table VARCHAR DEFAULT '"' || REPLACE(SCHEMA_NAME, '"', '""') || '"."' || REPLACE(TABLE_NAME, '"', '""') || '"';
    quoted_column VARCHAR DEFAULT '"' || REPLACE(COLUMN_NAME, '"', '""') || '"';
    sql_text VARCHAR;
    table_max BIGINT;
    next_value BIGINT;
BEGIN
    -- Ensures that the next sequence value is above the maximum value of the supplied table column.
    -- Snowflake can't restart a sequence, so it is advanced by drawing the missing values.
    sql_text := 'SELECT COALESCE(MAX(' || quoted_column || '), 0) FROM ' || quoted_table;
    EXECUTE IMMEDIATE :sql_text;
    SELECT $1 INTO :table_max FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

    sql_text := 'SELECT ' || quoted_sequence || '.NEXTVAL';
    EXECUTE IMMEDIATE :sql_text;
    SELECT $1 INTO :next_value FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

    IF (table_max >= next_value) THEN
        sql_text := 'SELECT MAX(v) FROM (SELECT ' || quoted_sequence || '.NEXTVAL AS v FROM TABLE(GENERATOR(ROWCOUNT => '
                    || (table_max - next_value + 1) || ')))';
        EXECUTE IMMEDIATE :sql_text;
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE "Sequences"."ReseedAllSequences"()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
BEGIN
    CALL "Sequences"."ReseedSequenceBeyondTableValues"('CityKey', 'Dimension', 'City', 'City Key');
    CALL "Sequences"."ReseedSequenceBeyondTableValues"('CustomerKey', 'Dimension', 'Customer', 'Customer Key');
    CALL "Sequences"."ReseedSequenceBeyondTableValues"('EmployeeKey', 'Dimension', 'Employee', 'Employee Key');
    CALL "Sequences"."ReseedSequenceBeyondTableValues"('LineageKey', 'Integration', 'Lineage', 'Lineage Key');
    CALL "Sequences"."ReseedSequenceBeyondTableValues"('PaymentMethodKey', 'Dimension', 'Payment Method', 'Payment Method Key');
    CALL "Sequences"."ReseedSequenceBeyondTableValues"('StockItemKey', 'Dimension', 'Stock Item', 'Stock Item Key');
    CALL "Sequences"."ReseedSequenceBeyondTableValues"('SupplierKey', 'Dimension', 'Supplier', 'Supplier Key');
    CALL "Sequences"."ReseedSequenceBeyondTableValues"('TransactionTypeKey', 'Dimension', 'Transaction Type', 'Transaction Type Key');
END;
$$;

CREATE OR REPLACE PROCEDURE "Application"."Configuration_ReseedETL"()
RETURNS INT
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    starting_etl_cutoff_time TIMESTAMP_NTZ(7) DEFAULT '2012-12-31'::TIMESTAMP_NTZ(7);
    start_of_time TIMESTAMP_NTZ(7) DEFAULT '2013-01-01'::TIMESTAMP_NTZ(7);
    end_of_time TIMESTAMP_NTZ(7) DEFAULT '9999-12-31 23:59:59.9999999'::TIMESTAMP_NTZ(7);
BEGIN
    UPDATE "Integration"."ETL Cutoff"
        SET "Cutoff Time" = :starting_etl_cutoff_time;

    TRUNCATE TABLE "Fact"."Movement";
    TRUNCATE TABLE "Fact"."Order";
    TRUNCATE TABLE "Fact"."Purchase";
    TRUNCATE TABLE "Fact"."Sale";
    TRUNCATE TABLE "Fact"."Stock Holding";
    TRUNCATE TABLE "Fact"."Transaction";

    DELETE FROM "Dimension"."City";
    DELETE FROM "Dimension"."Customer";
    DELETE FROM "Dimension"."Employee";
    DELETE FROM "Dimension"."Payment Method";
    DELETE FROM "Dimension"."Stock Item";
    DELETE FROM "Dimension"."Supplier";
    DELETE FROM "Dimension"."Transaction Type";

    INSERT INTO "Dimension"."City"
        ("City Key", "WWI City ID", "City", "State Province", "Country", "Continent", "Sales Territory", "Region", "Subregion",
         "Location", "Latest Recorded Population", "Valid From", "Valid To", "Lineage Key")
    VALUES
        (0, 0, 'Unknown', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A',
         NULL, 0, :start_of_time, :end_of_time, 0);

    INSERT INTO "Dimension"."Customer"
        ("Customer Key", "WWI Customer ID", "Customer", "Bill To Customer", "Category", "Buying Group",
         "Primary Contact", "Postal Code", "Valid From", "Valid To", "Lineage Key")
    VALUES
        (0, 0, 'Unknown', 'N/A', 'N/A', 'N/A',
         'N/A', 'N/A', :start_of_time, :end_of_time, 0);

    INSERT INTO "Dimension"."Employee"
        ("Employee Key", "WWI Employee ID", "Employee", "Preferred Name",
         "Is Salesperson", "Photo", "Valid From", "Valid To", "Lineage Key")
    VALUES
        (0, 0, 'Unknown', 'N/A',
         FALSE, NULL, :start_of_time, :end_of_time, 0);

    INSERT INTO "Dimension"."Payment Method"
        ("Payment Method Key", "WWI Payment Method ID", "Payment Method", "Valid From", "Valid To", "Lineage Key")
    VALUES
        (0, 0, 'Unknown', :start_of_time, :end_of_time, 0);

    INSERT INTO "Dimension"."Stock Item"
        ("Stock Item Key", "WWI Stock Item ID", "Stock Item", "Color", "Selling Package", "Buying Package",
         "Brand", "Size", "Lead Time Days", "Quantity Per Outer", "Is Chiller Stock",
         "Barcode", "Tax Rate", "Unit Price", "Recommended Retail Price", "Typical Weight Per Unit",
         "Photo", "Valid From", "Valid To", "Lineage Key")
    VALUES
        (0, 0, 'Unknown', 'N/A', 'N/A', 'N/A',
         'N/A', 'N/A', 0, 0, FALSE,
         'N/A', 0, 0, 0, 0,
         NULL, :start_of_time, :end_of_time, 0);

    INSERT INTO "Dimension"."Supplier"
        ("Supplier Key", "WWI Supplier ID", "Supplier", "Category", "Primary Contact", "Supplier Reference",
         "Payment Days", "Postal Code", "Valid From", "Valid To", "Lineage Key")
    VALUES
        (0, 0, 'Unknown', 'N/A', 'N/A', 'N/A',
         0, 'N/A', :start_of_time, :end_of_time, 0);

    INSERT INTO "Dimension"."Transaction Type"
        ("Transaction Type Key", "WWI Transaction Type ID", "Transaction Type", "Valid From", "Valid To", "Lineage Key")
    VALUES
        (0, 0, 'Unknown', :start_of_time, :end_of_time, 0);

    RETURN 0;
END;
$$;

CREATE OR REPLACE PROCEDURE "Application"."Configuration_PopulateLargeSaleTable"(ESTIMATED_ROWS_FOR_2012 BIGINT DEFAULT 12000000)
RETURNS INT
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    lineage_key INT;
    number_of_sales_per_day BIGINT;
    date_counter DATE DEFAULT '2012-01-01'::DATE;
    starting_sale_key BIGINT;
    maximum_sale_key BIGINT;
BEGIN
    CALL "Integration"."PopulateDateDimensionForYear"(2012);

    SELECT "Sequences"."LineageKey".NEXTVAL INTO :lineage_key;

    INSERT INTO "Integration"."Lineage"
        ("Lineage Key", "Data Load Started", "Table Name", "Data Load Completed", "Was Successful",
         "Source System Cutoff Time")
    VALUES
        (:lineage_key, CURRENT_TIMESTAMP()::TIMESTAMP_NTZ, 'Sale', NULL, FALSE, '2012-12-31'::TIMESTAMP_NTZ);

    number_of_sales_per_day := FLOOR(estimated_rows_for_2012 / 365);
    SELECT MAX("Sale Key") INTO :maximum_sale_key FROM "Fact"."Sale";

    SYSTEM$LOG_INFO('Targeting ' || number_of_sales_per_day || ' sales per day.');
    IF (number_of_sales_per_day > 50000) THEN
        SYSTEM$LOG_WARN('WARNING: Limiting sales to 40000 per day');
        number_of_sales_per_day := 50000;
    END IF;

    WHILE (date_counter < '2012-12-31'::DATE) DO
        starting_sale_key := maximum_sale_key - number_of_sales_per_day - FLOOR(UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) * 20000);

        INSERT INTO "Fact"."Sale"
            ("City Key", "Customer Key", "Bill To Customer Key", "Stock Item Key", "Invoice Date Key", "Delivery Date Key", "Salesperson Key", "WWI Invoice ID", "Description", "Package", "Quantity", "Unit Price", "Tax Rate", "Total Excluding Tax", "Tax Amount", "Profit", "Total Including Tax", "Total Dry Items", "Total Chiller Items", "Lineage Key")
        SELECT "City Key", "Customer Key", "Bill To Customer Key", "Stock Item Key", :date_counter,
               DATEADD(day, 1, :date_counter), "Salesperson Key", "WWI Invoice ID", "Description",
               "Package", "Quantity", "Unit Price", "Tax Rate", "Total Excluding Tax",
               "Tax Amount", "Profit", "Total Including Tax", "Total Dry Items", "Total Chiller Items",
               :lineage_key
        FROM "Fact"."Sale"
        WHERE "Sale Key" > :starting_sale_key
          AND "Invoice Date Key" >= '2013-01-01'::DATE
        QUALIFY ROW_NUMBER() OVER (ORDER BY "Sale Key") <= :number_of_sales_per_day;

        date_counter := DATEADD(day, 1, date_counter);
    END WHILE;

    UPDATE "Integration"."Lineage"
        SET "Data Load Completed" = CURRENT_TIMESTAMP()::TIMESTAMP_NTZ,
            "Was Successful" = TRUE;

    RETURN 0;
END;
$$;
