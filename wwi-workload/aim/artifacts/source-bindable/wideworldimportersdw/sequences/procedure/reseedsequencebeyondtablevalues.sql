USE ${wideworldimportersdw};
GO

CREATE PROCEDURE Sequences.ReseedSequenceBeyondTableValues @SequenceName sysname, @SchemaName sysname, @TableName sysname, @ColumnName sysname
AS
  BEGIN
    -- Ensures that the next sequence value is above the maximum value of the supplied table column
    SET NOCOUNT ON;
    DECLARE
      @SQL nvarchar(max);
    DECLARE
      @CurrentTableMaximumValue bigint;
    DECLARE
      @NewSequenceValue bigint;
    DECLARE
      @CurrentSequenceMaximumValue bigint = (
        SELECT
          CAST(current_value AS bigint)
        FROM
          sys.sequences
        WHERE
          name = @SequenceName
          AND SCHEMA_NAME(schema_id) = N'Sequences'
      );
    CREATE TABLE #CurrentValue (
      CurrentValue bigint
    )
    SET @SQL = N'INSERT #CurrentValue (CurrentValue) SELECT COALESCE(MAX(' + QUOTENAME(@ColumnName) + N'), 0) FROM ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + N';';
    EXECUTE (
--             /*<<BARE:@SQL#5243762~src=Lyo8PFVOUkVTT0xWRUQ6QFNRTCM1MjQzNzYyfndzPTAsMH5zcmM9UUZOUlRBPT0qL0BTUUwvKj4+VU5SRVNPTFZFRDpAU1FMKi8=*/ /*<<UNRESOLVED:@SQL#5243762~ws=0,0~src=QFNRTA==*/  @SQL /*>>UNRESOLVED:@SQL*/ /*>>BARE:@SQL*/

    );
    SET @CurrentTableMaximumValue = (
      SELECT
        CurrentValue
      FROM
        #CurrentValue
    );
    DROP TABLE #CurrentValue;
    IF @CurrentTableMaximumValue >= @CurrentSequenceMaximumValue
      BEGIN
        SET @NewSequenceValue = @CurrentTableMaximumValue + 1;
        SET @SQL = N'ALTER SEQUENCE Sequences.' + QUOTENAME(@SequenceName) + N' RESTART WITH ' + CAST(@NewSequenceValue AS nvarchar(20)) + N';';
        EXECUTE (
--                 /*<<BARE:@SQL#11494622~src=Lyo8PFVOUkVTT0xWRUQ6QFNRTCMxMTQ5NDYyMn53cz0wLDB+c3JjPVFGTlJUQT09Ki9AU1FMLyo+PlVOUkVTT0xWRUQ6QFNRTCov*/ /*<<UNRESOLVED:@SQL#11494622~ws=0,0~src=QFNRTA==*/  @SQL /*>>UNRESOLVED:@SQL*/ /*>>BARE:@SQL*/

        );
      END;
  END;