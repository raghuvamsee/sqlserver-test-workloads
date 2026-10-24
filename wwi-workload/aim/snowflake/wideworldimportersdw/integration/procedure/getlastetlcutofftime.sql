USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE PROCEDURE Integration.GetLastETLCutoffTime (TABLENAME VARCHAR(128))
RETURNS TABLE()
LANGUAGE SQL
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
EXECUTE AS OWNER
AS
$$
    DECLARE
        ProcedureResultSet RESULTSET;
    BEGIN
--        --** SSC-FDM-TS0029 - SET NOCOUNT STATEMENT IS COMMENTED OUT, WHICH IS NOT APPLICABLE IN SNOWFLAKE. **
--        SET NOCOUNT ON;
--        --** SSC-FDM-TS0037 - SET XACT_ABORT ON STATEMENT IS NOT APPLICABLE IN SNOWFLAKE AS IT HAS EQUIVALENT DEFAULT BEHAVIOR. **
--        SET XACT_ABORT ON;
        ProcedureResultSet := (
        SELECT
            "Cutoff Time" AS CutoffTime
        FROM
            Integration."ETL Cutoff"
        WHERE
            "Table Name" = :TABLENAME);
        IF (SQLROWCOUNT = 0) THEN
            BEGIN
                SYSTEM$LOG_INFO('Invalid ETL table name');
                CALL <%AIM_DB%>.PUBLIC.THROW_UDP(51000, 'Invalid ETL table name', 1);
                --** SSC-FDM-TS0144 - THE PROCEDURE RETURNED RESULT SETS THROUGH SNOWFLAKE'S SINGLE RETURN CHANNEL. THE SOURCE INTEGER STATUS WAS NOT RETURNED. **
                RETURN TABLE(ProcedureResultSet);
            END;
        END IF;
        --** SSC-FDM-TS0144 - THE PROCEDURE RETURNED RESULT SETS THROUGH SNOWFLAKE'S SINGLE RETURN CHANNEL. THE SOURCE INTEGER STATUS WAS NOT RETURNED. **
        RETURN TABLE(ProcedureResultSet);
    END;
$$;