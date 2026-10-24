USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE PROCEDURE dbo.Configuration_ApplyPolybase ()
RETURNS VARCHAR
LANGUAGE SQL
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
EXECUTE AS CALLER
AS
$$
	DECLARE
		SQL NVARCHAR := '';
	BEGIN
--		--** SSC-FDM-TS0029 - SET NOCOUNT STATEMENT IS COMMENTED OUT, WHICH IS NOT APPLICABLE IN SNOWFLAKE. **
--		SET NOCOUNT ON;
		!!!RESOLVE EWI!!! /*** SSC-EWI-TS0089 - SET XACT_ABORT ON IS NOT SUPPORTED IN SNOWFLAKE. ***/!!!
		SET XACT_ABORT ON;
		IF (SERVERPROPERTY('IsPolybaseInstalled') !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'SERVERPROPERTY' NODE ***/!!! = 0) THEN
			BEGIN
				SYSTEM$LOG_INFO('Warning: Either Polybase cannot be created on this edition or it has not been installed.');
END;
		ELSE
			BEGIN -- if installed

				IF ((SELECT
						value
					FROM
						!!!RESOLVE EWI!!! /*** SSC-EWI-TS0046 - SYSTEM TABLE sys.configurations IS NOT SUPPORTED IN SNOWFLAKE ***/!!!
						sys.configurations
					WHERE
						name = 'hadoop connectivity') NOT IN (1, 4, 7)) THEN
					BEGIN
						SYSTEM$LOG_INFO('Warning: Hadoop connectivity has not been enabled. It must be set to 1, 4, or 7 for Azure Storage connectivity.');
					END;
				ELSE
					BEGIN -- if Polybase can be created

						 
						BEGIN
							SQL := 'CREATE OR REPLACE STAGE AzureStorage
URL = ''azure://sqldwdatasets.blob.core.windows.net/data/'';';
							!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'CREATE EXTERNAL DATA SOURCE' NODE ***/!!!
							EXECUTE IMMEDIATE :SQL;
							SQL := 'CREATE FILE FORMAT IF NOT EXISTS CommaDelimitedTextFileFormat
TYPE = CSV
FIELD_DELIMITER = '',''
COMPRESSION = AUTO;';
							!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'CREATE EXTERNAL FILE FORMAT' NODE ***/!!!
							EXECUTE IMMEDIATE :SQL;
							SQL := '-- skipping 1 header row per file
CREATE OR REPLACE EXTERNAL TABLE CityPopulationStatistics
(
   CityID INT AS (VALUE:c1 :: INT),
   StateProvinceCode STRING AS (VALUE:c2 :: STRING),
   CityName STRING AS (VALUE:c3 :: STRING),
   YearNumber INT AS (VALUE:c4 :: INT),
   LatestRecordedPopulation NUMBER(19, 0) AS (VALUE:c5 :: NUMBER(19, 0))
)
LOCATION = @AzureStorage
FILE_FORMAT = (FORMAT_NAME = ''CommaDelimitedTextFileFormat'')
AUTO_REFRESH = false
REFRESH_ON_CREATE = true;';
							-- skipping 1 header row per file
							--** SSC-FDM-TS0068 - FILE FORMAT OPTION 'REJECT_TYPE' WAS NOT TRANSLATED BECAUSE IT HAS NO SNOWFLAKE EQUIVALENT AND MAY CAUSE A FUNCTIONAL DIFFERENCE. **
							--** SSC-FDM-TS0068 - FILE FORMAT OPTION 'REJECT_VALUE' WAS NOT TRANSLATED BECAUSE IT HAS NO SNOWFLAKE EQUIVALENT AND MAY CAUSE A FUNCTIONAL DIFFERENCE. **
							EXECUTE IMMEDIATE :SQL !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'CreateExternalTableStart' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionExternalLocation' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionDataSource' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionFileFormat' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionRejectType' NODE ***/!!!!!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableOptionRejectValue' NODE ***/!!!;
						EXCEPTION
							WHEN OTHER THEN
								SYSTEM$LOG_INFO('Unable to apply Polybase connectivity to Azure storage');
								RAISE;
						END;
					END; -- if connectivity enabled

				END IF;
			END; -- of Polybase is allowed and installed

		END IF;
		RETURN '';
	END;
$$;