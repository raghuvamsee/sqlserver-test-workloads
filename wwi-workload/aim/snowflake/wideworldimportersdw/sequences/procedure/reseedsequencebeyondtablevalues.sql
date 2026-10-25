USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE PROCEDURE Sequences.ReseedSequenceBeyondTableValues (SEQUENCENAME VARCHAR(128), SCHEMANAME VARCHAR(128), TABLENAME VARCHAR(128), COLUMNNAME VARCHAR(128))
RETURNS VARCHAR
LANGUAGE SQL
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
EXECUTE AS CALLER
AS
$$
    DECLARE
        SQL VARCHAR;
        CURRENTTABLEMAXIMUMVALUE BIGINT;
        NEWSEQUENCEVALUE BIGINT;
        CURRENTSEQUENCEMAXIMUMVALUE BIGINT;
        SEQUENCENEXTVALUE BIGINT;
        SEQUENCEINCREMENT BIGINT;
        SEQUENCEFQN VARCHAR;
        RS RESULTSET;
    BEGIN
        -- Ensures that the next sequence value is above the maximum value of the supplied table column
        -- Unquoted names resolve case-insensitively in SQL Server; converted objects are UPPER unless they need quoting.
        -- sys.sequences.current_value (last issued) = NEXT_VALUE - INCREMENT in Snowflake
        SELECT NEXT_VALUE, "INCREMENT" INTO :SEQUENCENEXTVALUE, :SEQUENCEINCREMENT
        FROM <%wideworldimportersdw%>.INFORMATION_SCHEMA.SEQUENCES
        WHERE UPPER(SEQUENCE_NAME) = UPPER(:SEQUENCENAME)
          AND UPPER(SEQUENCE_SCHEMA) = 'SEQUENCES';
        CURRENTSEQUENCEMAXIMUMVALUE := :SEQUENCENEXTVALUE - :SEQUENCEINCREMENT;
        SQL := 'SELECT COALESCE(MAX(' || IFF(REGEXP_LIKE(:COLUMNNAME, '^[A-Za-z_][A-Za-z0-9_$]*$'), UPPER(:COLUMNNAME), '"' || REPLACE(:COLUMNNAME, '"', '""') || '"') || '), 0) AS CURRENTVALUE FROM '
            || IFF(REGEXP_LIKE(:SCHEMANAME, '^[A-Za-z_][A-Za-z0-9_$]*$'), UPPER(:SCHEMANAME), '"' || REPLACE(:SCHEMANAME, '"', '""') || '"') || '.' || IFF(REGEXP_LIKE(:TABLENAME, '^[A-Za-z_][A-Za-z0-9_$]*$'), UPPER(:TABLENAME), '"' || REPLACE(:TABLENAME, '"', '""') || '"');
        RS := (EXECUTE IMMEDIATE :SQL);
        LET C1 CURSOR FOR RS;
        FOR R IN C1 DO
            CURRENTTABLEMAXIMUMVALUE := R.CURRENTVALUE;
        END FOR;
        IF (:CURRENTTABLEMAXIMUMVALUE >= :CURRENTSEQUENCEMAXIMUMVALUE) THEN
            NEWSEQUENCEVALUE := :CURRENTTABLEMAXIMUMVALUE + 1;
            -- Snowflake has no ALTER SEQUENCE ... RESTART WITH: advance by consuming one value
            -- with a temporary increment so the next value issued is NEWSEQUENCEVALUE.
            IF (:NEWSEQUENCEVALUE > :SEQUENCENEXTVALUE) THEN
                SEQUENCEFQN := 'SEQUENCES.' || IFF(REGEXP_LIKE(:SEQUENCENAME, '^[A-Za-z_][A-Za-z0-9_$]*$'), UPPER(:SEQUENCENAME), '"' || REPLACE(:SEQUENCENAME, '"', '""') || '"');
                EXECUTE IMMEDIATE 'ALTER SEQUENCE ' || :SEQUENCEFQN || ' SET INCREMENT = ' || (:NEWSEQUENCEVALUE - :SEQUENCENEXTVALUE)::VARCHAR;
                EXECUTE IMMEDIATE 'SELECT ' || :SEQUENCEFQN || '.NEXTVAL';
                EXECUTE IMMEDIATE 'ALTER SEQUENCE ' || :SEQUENCEFQN || ' SET INCREMENT = ' || :SEQUENCEINCREMENT::VARCHAR;
            END IF;
        END IF;
    END;
$$;