USE DATABASE <%wideworldimportersdw%>;

!!!RESOLVE EWI!!! /*** SSC-EWI-0120 - SEQUENCE OPTIONS 'MIN VALUE, MAX VALUE' WERE REMOVED, THEY ARE NOT SUPPORTED IN SNOWFLAKE ***/!!!
CREATE SEQUENCE Sequences.LineageKey
    START WITH 1
    INCREMENT BY 1
-- ** SSC-EWI-0001 - UNRECOGNIZED TOKEN ON LINE '10' COLUMN '5' OF THE SOURCE CODE STARTING AT 'CACHE'. EXPECTED 'CACHE' GRAMMAR. LAST MATCHING TOKEN WAS 'CACHE' ON LINE '10' COLUMN '5'. **
--    CACHE

--ALTER SEQUENCE [Sequences].[LineageKey] RESTART WITH 13
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}';