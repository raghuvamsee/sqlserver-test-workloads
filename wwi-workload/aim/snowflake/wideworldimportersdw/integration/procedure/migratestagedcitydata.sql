USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE PROCEDURE Integration.MigrateStagedCityData ()
RETURNS VARCHAR
LANGUAGE SQL
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
EXECUTE AS OWNER
AS
$$
    DECLARE
        ENDOFTIME TIMESTAMP_NTZ(7) := '99991231 23:59:59.9999999';
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
                "Table Name" = 'City'
                                          AND "Data Load Completed" IS NULL
                                          ORDER BY "Lineage Key" DESC);
        UPDATE Dimension.City c
            SET
                c."Valid To" = rtco."Valid From"
            FROM
                (
                    WITH RowsToCloseOff
        AS
        (
            SELECT
                c."WWI City ID",
                MIN(c."Valid From") AS "Valid From"
            FROM
                Integration.City_Staging AS c
            GROUP BY
                c."WWI City ID"
        )
                    SELECT
            *
                    FROM
            RowsToCloseOff
                ) AS rtco
            WHERE
                c."WWI City ID" = rtco."WWI City ID"
                AND (c."Valid To" = :ENDOFTIME);

        INSERT INTO Dimension.City
            ("WWI City ID", City, "State Province", Country, Continent, "Sales Territory", Region, Subregion, Location, "Latest Recorded Population", "Valid From", "Valid To", "Lineage Key")
        SELECT
            "WWI City ID",
            City,
            "State Province",
            Country,
            Continent,
            "Sales Territory",
            Region,
            Subregion,
            Location,
            "Latest Recorded Population",
            "Valid From",
            "Valid To",
            :LINEAGEKEY
        FROM
            Integration.City_Staging;

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
                "Table Name" = 'City';
        COMMIT;
        RETURN 0;
    END;
$$;