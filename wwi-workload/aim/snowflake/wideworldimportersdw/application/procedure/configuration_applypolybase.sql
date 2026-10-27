USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE PROCEDURE dbo.Configuration_ApplyPolybase ()
RETURNS VARCHAR
LANGUAGE SQL
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
EXECUTE AS CALLER
AS
$$
  BEGIN
--    --** SSC-FDM-TS0029 - SET NOCOUNT STATEMENT IS COMMENTED OUT, WHICH IS NOT APPLICABLE IN SNOWFLAKE. **
--    SET NOCOUNT ON;
--    SET XACT_ABORT ON;  -- not applicable in Snowflake
    -- Polybase (EXTERNAL DATA SOURCE / FILE FORMAT / EXTERNAL TABLE over Hadoop) does not exist in Snowflake.
    -- SERVERPROPERTY('IsPolybaseInstalled') is therefore always 0 here, so the source's first branch applies:
    -- emit the warning and make no changes. (Snowflake equivalent would be a STAGE + EXTERNAL TABLE, created
    -- manually when needed.)
    SYSTEM$LOG_INFO('Warning: Either Polybase cannot be created on this edition or it has not been installed.');
    RETURN '';
  END;
$$;