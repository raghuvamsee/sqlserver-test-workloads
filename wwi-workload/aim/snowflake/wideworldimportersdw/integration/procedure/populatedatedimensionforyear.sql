USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE PROCEDURE Integration.PopulateDateDimensionForYear (YEARNUMBER INT)
RETURNS VARCHAR
LANGUAGE SQL
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
EXECUTE AS OWNER
AS
$$
    DECLARE
        DATECOUNTER DATE := DATE_FROM_PARTS(:YEARNUMBER, 1, 1);
    BEGIN
--        --** SSC-FDM-TS0029 - SET NOCOUNT STATEMENT IS COMMENTED OUT, WHICH IS NOT APPLICABLE IN SNOWFLAKE. **
--        SET NOCOUNT ON;
--        --** SSC-EWI-TS0089 - SET XACT_ABORT ON IS NOT SUPPORTED IN SNOWFLAKE; the explicit transaction + ROLLBACK handler below gives the same all-or-nothing behaviour. **
--        SET XACT_ABORT ON;
        BEGIN

            -- Set-based equivalent of the source's per-day WHILE loop (one INSERT per missing day was
            -- far too slow in Snowflake): insert every day of the year that is not already present.
            -- A NULL year makes the source loop condition false, so nothing is inserted.
            IF (:YEARNUMBER IS NOT NULL) THEN
                CREATE OR REPLACE TEMPORARY TABLE Integration.PopulateDateDimensionForYear_Days AS
                SELECT cal.d
                FROM (SELECT DATEADD(day, ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1, :DATECOUNTER) AS d
                      FROM TABLE(GENERATOR(ROWCOUNT => 366))) cal
                LEFT JOIN Dimension.Date x ON x.Date = cal.d
                WHERE YEAR(cal.d) = :YEARNUMBER AND x.Date IS NULL;
                -- temp-table DDL above stays outside the transaction (DDL would commit it)
                BEGIN TRANSACTION;
                INSERT INTO Dimension.Date
                    (Date, "Day Number", Day, Month, "Short Month", "Calendar Month Number", "Calendar Month Label", "Calendar Year", "Calendar Year Label", "Fiscal Month Number", "Fiscal Month Label", "Fiscal Year", "Fiscal Year Label", "ISO Week Number")
                SELECT
                    g.Date,
                    g."Day Number",
                    g.Day,
                    g.Month,
                    g."Short Month",
                    g."Calendar Month Number",
                    g."Calendar Month Label",
                    g."Calendar Year",
                    g."Calendar Year Label",
                    g."Fiscal Month Number",
                    g."Fiscal Month Label",
                    g."Fiscal Year",
                    g."Fiscal Year Label",
                    g."ISO Week Number"
                FROM
                    Integration.PopulateDateDimensionForYear_Days days,
                    TABLE(Integration.GenerateDateDimensionColumns(days.d)) g;
                COMMIT;
                DROP TABLE IF EXISTS Integration.PopulateDateDimensionForYear_Days;
            END IF;
        EXCEPTION
            WHEN OTHER THEN
                IF (CURRENT_TRANSACTION() IS NOT NULL) THEN
                    BEGIN
                        ROLLBACK;
                    EXCEPTION
                        WHEN OTHER THEN
                            NULL;
                    END;
                END IF;
                SYSTEM$LOG_INFO('Unable to populate dates for the year');
                RAISE;
            RETURN COALESCE(TRUNC( -1) :: INT, 0);
        END;
        RETURN 0;
    END;
$$;