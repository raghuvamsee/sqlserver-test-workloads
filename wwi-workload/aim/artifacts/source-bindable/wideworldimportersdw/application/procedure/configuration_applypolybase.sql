USE ${wideworldimportersdw};
GO

CREATE PROCEDURE Application.Configuration_ApplyPolybase
AS
  BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF SERVERPROPERTY(N'IsPolybaseInstalled') = 0
      BEGIN
        PRINT N'Warning: Either Polybase cannot be created on this edition or it has not been installed.';
      END
    ELSE
      BEGIN -- if installed

        IF (
          SELECT
            value
          FROM
            sys.configurations
          WHERE
            name = 'hadoop connectivity'
        ) NOT IN (1, 4, 7)
          BEGIN
            PRINT N'Warning: Hadoop connectivity has not been enabled. It must be set to 1, 4, or 7 for Azure Storage connectivity.';
          END
        ELSE
          BEGIN -- if Polybase can be created

            DECLARE
              @SQL nvarchar(max) = N'';
            BEGIN TRY
              SET @SQL = N'
CREATE EXTERNAL DATA SOURCE AzureStorage
WITH
(
	TYPE=HADOOP, LOCATION = ''wasbs://data@sqldwdatasets.blob.core.windows.net''
);';
              EXECUTE (
              /*<<BARE:@SQL#37452158~src=Lyo8PEBTUUwjMzc0NTIxNTh+d3M9MSwwfnNyYz1Da05TUlVGVVJTQkZXRlJGVWs1QlRDQkVRVlJCSUZOUFZWSkRSU0JCZW5WeVpWTjBiM0poWjJVS1YwbFVTQW9vQ2dsVVdWQkZQVWhCUkU5UFVDd2dURTlEUVZSSlQwNGdQU0FuZDJGelluTTZMeTlrWVhSaFFITnhiR1IzWkdGMFlYTmxkSE11WW14dllpNWpiM0psTG5kcGJtUnZkM011Ym1WMEp3b3BPdz09Ki8KQ1JFQVRFIEVYVEVSTkFMIERBVEEgU09VUkNFIEF6dXJlU3RvcmFnZQpXSVRICigKCVRZUEU9SEFET09QLCBMT0NBVElPTiA9ICd3YXNiczovL2RhdGFAc3FsZHdkYXRhc2V0cy5ibG9iLmNvcmUud2luZG93cy5uZXQnCik7Lyo+PkBTUUwqLw==*/
              /*<<@SQL#37452158~ws=1,0~src=CkNSRUFURSBFWFRFUk5BTCBEQVRBIFNPVVJDRSBBenVyZVN0b3JhZ2UKV0lUSAooCglUWVBFPUhBRE9PUCwgTE9DQVRJT04gPSAnd2FzYnM6Ly9kYXRhQHNxbGR3ZGF0YXNldHMuYmxvYi5jb3JlLndpbmRvd3MubmV0JwopOw==*/
              CREATE EXTERNAL DATA SOURCE AzureStorage
              WITH (
                TYPE = HADOOP,
                LOCATION = 'wasbs://data@sqldwdatasets.blob.core.windows.net'
              ); /*>>@SQL*/ /*>>BARE:@SQL*/

              );
              SET @SQL = N'
CREATE EXTERNAL FILE FORMAT CommaDelimitedTextFileFormat
WITH
(
	FORMAT_TYPE = DELIMITEDTEXT,
	FORMAT_OPTIONS
	(
		FIELD_TERMINATOR = '',''
	)
);';
              EXECUTE (
              /*<<BARE:@SQL#15630868~src=Lyo8PEBTUUwjMTU2MzA4Njh+d3M9MSwwfnNyYz1Da05TUlVGVVJTQkZXRlJGVWs1QlRDQkdTVXhGSUVaUFVrMUJWQ0JEYjIxdFlVUmxiR2x0YVhSbFpGUmxlSFJHYVd4bFJtOXliV0YwQ2xkSlZFZ0tLQW9KUms5U1RVRlVYMVJaVUVVZ1BTQkVSVXhKVFVsVVJVUlVSVmhVTEFvSlJrOVNUVUZVWDA5UVZFbFBUbE1LQ1NnS0NRbEdTVVZNUkY5VVJWSk5TVTVCVkU5U0lEMGdKeXduQ2drcENpazcqLwpDUkVBVEUgRVhURVJOQUwgRklMRSBGT1JNQVQgQ29tbWFEZWxpbWl0ZWRUZXh0RmlsZUZvcm1hdApXSVRICigKCUZPUk1BVF9UWVBFID0gREVMSU1JVEVEVEVYVCwKCUZPUk1BVF9PUFRJT05TCgkoCgkJRklFTERfVEVSTUlOQVRPUiA9ICcsJwoJKQopOy8qPj5AU1FMKi8=*/
              /*<<@SQL#15630868~ws=1,0~src=CkNSRUFURSBFWFRFUk5BTCBGSUxFIEZPUk1BVCBDb21tYURlbGltaXRlZFRleHRGaWxlRm9ybWF0CldJVEgKKAoJRk9STUFUX1RZUEUgPSBERUxJTUlURURURVhULAoJRk9STUFUX09QVElPTlMKCSgKCQlGSUVMRF9URVJNSU5BVE9SID0gJywnCgkpCik7*/
              CREATE EXTERNAL FILE FORMAT CommaDelimitedTextFileFormat
              WITH (
                FORMAT_TYPE = DELIMITEDTEXT,
                FORMAT_OPTIONS (FIELD_TERMINATOR = ',')
              ); /*>>@SQL*/ /*>>BARE:@SQL*/

              );
              SET @SQL = N'
CREATE EXTERNAL TABLE dbo.CityPopulationStatistics
(
	CityID int NOT NULL,
	StateProvinceCode nvarchar(5) NOT NULL,
	CityName nvarchar(50) NOT NULL,
	YearNumber int NOT NULL,
	LatestRecordedPopulation bigint NULL
)
WITH
(
	LOCATION = ''/'',
	DATA_SOURCE = AzureStorage,
	FILE_FORMAT = CommaDelimitedTextFileFormat,
	REJECT_TYPE = VALUE,
	REJECT_VALUE = 4 -- skipping 1 header row per file
);';
              EXECUTE (
              /*<<BARE:@SQL#23772686~src=Lyo8PEBTUUwjMjM3NzI2ODZ+d3M9MSwwfnNyYz1Da05TUlVGVVJTQkZXRlJGVWs1QlRDQlVRVUpNUlNCa1ltOHVRMmwwZVZCdmNIVnNZWFJwYjI1VGRHRjBhWE4wYVdOekNpZ0tDVU5wZEhsSlJDQnBiblFnVGs5VUlFNVZURXdzQ2dsVGRHRjBaVkJ5YjNacGJtTmxRMjlrWlNCdWRtRnlZMmhoY2lnMUtTQk9UMVFnVGxWTVRDd0tDVU5wZEhsT1lXMWxJRzUyWVhKamFHRnlLRFV3S1NCT1QxUWdUbFZNVEN3S0NWbGxZWEpPZFcxaVpYSWdhVzUwSUU1UFZDQk9WVXhNTEFvSlRHRjBaWE4wVW1WamIzSmtaV1JRYjNCMWJHRjBhVzl1SUdKcFoybHVkQ0JPVlV4TUNpa0tWMGxVU0Fvb0NnbE1UME5CVkVsUFRpQTlJQ2N2Snl3S0NVUkJWRUZmVTA5VlVrTkZJRDBnUVhwMWNtVlRkRzl5WVdkbExBb0pSa2xNUlY5R1QxSk5RVlFnUFNCRGIyMXRZVVJsYkdsdGFYUmxaRlJsZUhSR2FXeGxSbTl5YldGMExBb0pVa1ZLUlVOVVgxUlpVRVVnUFNCV1FVeFZSU3dLQ1ZKRlNrVkRWRjlXUVV4VlJTQTlJRFFnTFMwZ2MydHBjSEJwYm1jZ01TQm9aV0ZrWlhJZ2NtOTNJSEJsY2lCbWFXeGxDaWs3Ki8KQ1JFQVRFIEVYVEVSTkFMIFRBQkxFIGRiby5DaXR5UG9wdWxhdGlvblN0YXRpc3RpY3MKKAoJQ2l0eUlEIGludCBOT1QgTlVMTCwKCVN0YXRlUHJvdmluY2VDb2RlIG52YXJjaGFyKDUpIE5PVCBOVUxMLAoJQ2l0eU5hbWUgbnZhcmNoYXIoNTApIE5PVCBOVUxMLAoJWWVhck51bWJlciBpbnQgTk9UIE5VTEwsCglMYXRlc3RSZWNvcmRlZFBvcHVsYXRpb24gYmlnaW50IE5VTEwKKQpXSVRICigKCUxPQ0FUSU9OID0gJy8nLAoJREFUQV9TT1VSQ0UgPSBBenVyZVN0b3JhZ2UsCglGSUxFX0ZPUk1BVCA9IENvbW1hRGVsaW1pdGVkVGV4dEZpbGVGb3JtYXQsCglSRUpFQ1RfVFlQRSA9IFZBTFVFLAoJUkVKRUNUX1ZBTFVFID0gNCAtLSBza2lwcGluZyAxIGhlYWRlciByb3cgcGVyIGZpbGUKKTsvKj4+QFNRTCov*/
              /*<<@SQL#23772686~ws=1,0~src=CkNSRUFURSBFWFRFUk5BTCBUQUJMRSBkYm8uQ2l0eVBvcHVsYXRpb25TdGF0aXN0aWNzCigKCUNpdHlJRCBpbnQgTk9UIE5VTEwsCglTdGF0ZVByb3ZpbmNlQ29kZSBudmFyY2hhcig1KSBOT1QgTlVMTCwKCUNpdHlOYW1lIG52YXJjaGFyKDUwKSBOT1QgTlVMTCwKCVllYXJOdW1iZXIgaW50IE5PVCBOVUxMLAoJTGF0ZXN0UmVjb3JkZWRQb3B1bGF0aW9uIGJpZ2ludCBOVUxMCikKV0lUSAooCglMT0NBVElPTiA9ICcvJywKCURBVEFfU09VUkNFID0gQXp1cmVTdG9yYWdlLAoJRklMRV9GT1JNQVQgPSBDb21tYURlbGltaXRlZFRleHRGaWxlRm9ybWF0LAoJUkVKRUNUX1RZUEUgPSBWQUxVRSwKCVJFSkVDVF9WQUxVRSA9IDQgLS0gc2tpcHBpbmcgMSBoZWFkZXIgcm93IHBlciBmaWxlCik7*/
              CREATE EXTERNAL TABLE dbo.CityPopulationStatistics (
                CityID int NOT NULL,
                StateProvinceCode nvarchar(5) NOT NULL,
                CityName nvarchar(50) NOT NULL,
                YearNumber int NOT NULL,
                LatestRecordedPopulation bigint NULL
              )
              WITH (
                LOCATION = '/',
                DATA_SOURCE = AzureStorage,
                FILE_FORMAT = CommaDelimitedTextFileFormat,
                REJECT_TYPE = VALUE,
                REJECT_VALUE = 4 -- skipping 1 header row per file

              ); /*>>@SQL*/ /*>>BARE:@SQL*/

              );
            END TRY
            BEGIN CATCH
              PRINT N'Unable to apply Polybase connectivity to Azure storage';
              THROW;
            END CATCH;
          END; -- if connectivity enabled

      END; -- of Polybase is allowed and installed

  END;