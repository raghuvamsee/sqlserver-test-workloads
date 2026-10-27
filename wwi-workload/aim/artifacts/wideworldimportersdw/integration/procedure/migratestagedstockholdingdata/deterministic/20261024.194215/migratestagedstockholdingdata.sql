USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE PROCEDURE Integration.MigrateStagedStockHoldingData ()
RETURNS VARCHAR
LANGUAGE SQL
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
EXECUTE AS OWNER
AS
$$
    DECLARE
        LINEAGEKEY INT;
    BEGIN
--        --** SSC-FDM-TS0029 - SET NOCOUNT STATEMENT IS COMMENTED OUT, WHICH IS NOT APPLICABLE IN SNOWFLAKE. **
--        SET NOCOUNT ON;
--        --** SSC-FDM-TS0037 - SET XACT_ABORT ON STATEMENT IS NOT APPLICABLE IN SNOWFLAKE AS IT HAS EQUIVALENT DEFAULT BEHAVIOR. **
--        SET XACT_ABORT ON;

        BEGIN TRANSACTION;
        LINEAGEKEY := (SELECT
            TOP 1
                "Lineage Key"
                                          FROM
                Integration.Lineage
                                          WHERE
                "Table Name" = 'Stock Holding'
                                          AND "Data Load Completed" IS NULL
                                          ORDER BY "Lineage Key" DESC);

        -- Find the dimension keys required

        UPDATE Integration.StockHolding_Staging s
            SET
                s."Stock Item Key" = COALESCE((SELECT
                    TOP 1
                        si."Stock Item Key"
                                               FROM
                        Dimension."Stock Item" AS si
                                               WHERE
                        si."WWI Stock Item ID" = s."WWI Stock Item ID"
                                               ORDER BY si."Valid To" DESC), 0);

        -- Remove all existing holdings

        TRUNCATE TABLE Fact."Stock Holding";

        -- Insert all current stock holdings

        INSERT INTO Fact."Stock Holding"
            ("Stock Item Key", "Quantity On Hand", "Bin Location", "Last Stocktake Quantity", "Last Cost Price", "Reorder Level", "Target Stock Level", "Lineage Key")
        SELECT
            "Stock Item Key",
            "Quantity On Hand",
            "Bin Location",
            "Last Stocktake Quantity",
            "Last Cost Price",
            "Reorder Level",
            "Target Stock Level",
            :LINEAGEKEY
        FROM
            Integration.StockHolding_Staging;

        UPDATE Integration.Lineage
            SET
                "Data Load Completed" = CURRENT_TIMESTAMP(),
                "Was Successful" = 1
        WHERE
                "Lineage Key" = :LINEAGEKEY;

        UPDATE Integration."ETL Cutoff"
            SET
                "Cutoff Time" = (SELECT
                        "Source System Cutoff Time"
                                 FROM
                        Integration.Lineage
                                 WHERE
                        "Lineage Key" = :LINEAGEKEY
                )
        FROM
                Integration."ETL Cutoff"
        WHERE
                "Table Name" = 'Stock Holding';
        COMMIT;
        RETURN 0;
    END;
$$;