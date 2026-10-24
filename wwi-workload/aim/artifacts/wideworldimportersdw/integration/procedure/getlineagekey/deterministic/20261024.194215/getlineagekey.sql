USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE PROCEDURE Integration.GetLineageKey (TABLENAME VARCHAR(128), NEWCUTOFFTIME TIMESTAMP_NTZ(7))
RETURNS TABLE()
LANGUAGE SQL
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
EXECUTE AS OWNER
AS
$$
    DECLARE
        DATALOADSTARTEDWHEN TIMESTAMP_NTZ(7) := CURRENT_TIMESTAMP();
        ProcedureResultSet RESULTSET;
    BEGIN
--        --** SSC-FDM-TS0029 - SET NOCOUNT STATEMENT IS COMMENTED OUT, WHICH IS NOT APPLICABLE IN SNOWFLAKE. **
--        SET NOCOUNT ON;
--        --** SSC-FDM-TS0037 - SET XACT_ABORT ON STATEMENT IS NOT APPLICABLE IN SNOWFLAKE AS IT HAS EQUIVALENT DEFAULT BEHAVIOR. **
--        SET XACT_ABORT ON;

        INSERT INTO Integration.Lineage
            ("Data Load Started", "Table Name", "Data Load Completed", "Was Successful", "Source System Cutoff Time") VALUES
            (:DATALOADSTARTEDWHEN, :TABLENAME, NULL,
             0, :NEWCUTOFFTIME);
        ProcedureResultSet := (
        SELECT
        TOP 1
            "Lineage Key" AS LineageKey
        FROM
            Integration.Lineage
        WHERE
            "Table Name" = :TABLENAME
        AND "Data Load Started" = :DATALOADSTARTEDWHEN
        ORDER BY LineageKey DESC);
        --** SSC-FDM-TS0144 - THE PROCEDURE RETURNED RESULT SETS THROUGH SNOWFLAKE'S SINGLE RETURN CHANNEL. THE SOURCE INTEGER STATUS WAS NOT RETURNED. **
        RETURN TABLE(ProcedureResultSet);
    END;
$$;