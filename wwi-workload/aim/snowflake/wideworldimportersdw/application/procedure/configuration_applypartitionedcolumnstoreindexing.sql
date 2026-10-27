USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE PROCEDURE Application.Configuration_ApplyPartitionedColumnstoreIndexing ()
RETURNS VARCHAR
LANGUAGE SQL
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
EXECUTE AS OWNER
AS
$$
  BEGIN
--    --** SSC-FDM-TS0029 - SET NOCOUNT STATEMENT IS COMMENTED OUT, WHICH IS NOT APPLICABLE IN SNOWFLAKE. **
--    SET NOCOUNT ON;
--    SET XACT_ABORT ON;  -- not applicable in Snowflake
    -- The source procedure creates the PF_Date partition function / PS_Date partition scheme and rebuilds
    -- the Fact tables as partitioned clustered columnstore indexes. These are SQL Server physical-storage
    -- features with no Snowflake counterpart: Snowflake stores every table in compressed columnar
    -- micro-partitions automatically, so the equivalent end state already exists and no DDL is needed.
    -- Data and result sets are unchanged by the source procedure, so this is a no-op.
    RETURN '';
  END;
$$;