USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE PROCEDURE Application.Configuration_ConfigureForEnterpriseEdition ()
RETURNS VARCHAR
LANGUAGE SQL
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
EXECUTE AS CALLER
AS
$$
	BEGIN
		CALL Application.Configuration_ApplyPartitionedColumnstoreIndexing();
		CALL Application.Configuration_EnableInMemory();
		CALL Application.Configuration_ApplyPolybase();
	END;
$$;