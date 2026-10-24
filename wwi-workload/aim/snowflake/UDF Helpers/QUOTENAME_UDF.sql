USE DATABASE <%wideworldimportersdw%>;

-- <copyright file="QUOTENAME_UDF.sql" company="Snowflake Inc">
--        Copyright (c) 2019-2025 Snowflake Inc. All rights reserved.
-- </copyright>

-- =========================================================================================================
-- Description: The QUOTENAME_UDF() function makes a valid SQL Server delimited identifier by returning a
-- Unicode string with the delimiters added. The closing delimiter is doubled inside the name, and NULL is
-- returned for an input longer than 128 UTF-16 code units or for an unsupported delimiter.
-- The one-argument form uses " instead of SQL Server's [ default, so that its result remains a valid
-- Snowflake quoted identifier when it is spliced into dynamic SQL.
-- =========================================================================================================

CREATE OR REPLACE FUNCTION <%wideworldimportersdw%>.PUBLIC.QUOTENAME_UDF(STR VARCHAR) 
RETURNS VARCHAR 
LANGUAGE SQL 
IMMUTABLE
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "udf",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
AS
$$
    SELECT
      CASE
        WHEN STR IS NULL THEN NULL
        WHEN LENGTH(STR) + REGEXP_COUNT(STR, '[\\x{10000}-\\x{10FFFF}]') > 128 THEN NULL
        ELSE '"' || REPLACE(STR, '"', '""') || '"'
      END
$$;

CREATE OR REPLACE FUNCTION <%wideworldimportersdw%>.PUBLIC.QUOTENAME_UDF(STR VARCHAR,QUOTECHAR VARCHAR)
RETURNS VARCHAR 
LANGUAGE SQL 
IMMUTABLE
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "udf",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
AS
$$
    SELECT
      CASE
        WHEN STR IS NULL OR QUOTECHAR IS NULL THEN NULL
        WHEN LENGTH(STR) + REGEXP_COUNT(STR, '[\\x{10000}-\\x{10FFFF}]') > 128 THEN NULL
        WHEN QUOTECHAR = '' OR LEFT(QUOTECHAR, 1) IN ('[', ']') THEN '[' || REPLACE(STR, ']', ']]') || ']'
        WHEN LEFT(QUOTECHAR, 1) = '"' THEN '"' || REPLACE(STR, '"', '""') || '"'
        WHEN LEFT(QUOTECHAR, 1) = '''' THEN '''' || REPLACE(STR, '''', '''''') || ''''
        WHEN LEFT(QUOTECHAR, 1) IN ('(', ')') THEN '(' || REPLACE(STR, ')', '))') || ')'
        WHEN LEFT(QUOTECHAR, 1) IN ('<', '>') THEN '<' || REPLACE(STR, '>', '>>') || '>'
        WHEN LEFT(QUOTECHAR, 1) IN ('{', '}') THEN '{' || REPLACE(STR, '}', '}}') || '}'
        WHEN LEFT(QUOTECHAR, 1) = '`' THEN '`' || REPLACE(STR, '`', '``') || '`'
        ELSE NULL
      END
$$;