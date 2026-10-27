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
        !!!RESOLVE EWI!!! /*** SSC-EWI-TS0089 - SET XACT_ABORT ON IS NOT SUPPORTED IN SNOWFLAKE. ***/!!!
        SET XACT_ABORT ON;
        BEGIN

            BEGIN TRANSACTION;
            WHILE (YEAR(:DATECOUNTER :: TIMESTAMP) = :YEARNUMBER) LOOP
                IF (NOT EXISTS (SELECT 1 FROM
                        Dimension.Date
                    WHERE
                        Date = :DATECOUNTER
                )) THEN
                    BEGIN
                        INSERT INTO Dimension.Date
                            (Date, "Day Number", Day, Month, "Short Month", "Calendar Month Number", "Calendar Month Label", "Calendar Year", "Calendar Year Label", "Fiscal Month Number", "Fiscal Month Label", "Fiscal Year", "Fiscal Year Label", "ISO Week Number")
                        SELECT
                            Date,
                            "Day Number",
                            Day,
                            Month,
                            "Short Month",
                            "Calendar Month Number",
                            "Calendar Month Label",
                            "Calendar Year",
                            "Calendar Year Label",
                            "Fiscal Month Number",
                            "Fiscal Month Label",
                            "Fiscal Year",
                            "Fiscal Year Label",
                            "ISO Week Number"
                        FROM
                            TABLE(Integration.GenerateDateDimensionColumns(:DATECOUNTER));
                    END;
                END IF;
                DATECOUNTER := DATEADD(day, 1, :DATECOUNTER);
            END LOOP;
            COMMIT;
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