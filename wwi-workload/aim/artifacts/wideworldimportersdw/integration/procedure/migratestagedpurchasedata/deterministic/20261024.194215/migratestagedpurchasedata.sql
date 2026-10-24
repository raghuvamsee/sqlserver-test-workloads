USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE PROCEDURE Integration.MigrateStagedPurchaseData ()
RETURNS VARCHAR
LANGUAGE SQL
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
EXECUTE AS OWNER
AS
$$
	DECLARE
		LINEAGEKEY INT;
	BEGIN
--		--** SSC-FDM-TS0029 - SET NOCOUNT STATEMENT IS COMMENTED OUT, WHICH IS NOT APPLICABLE IN SNOWFLAKE. **
--		SET NOCOUNT ON;
--		--** SSC-FDM-TS0037 - SET XACT_ABORT ON STATEMENT IS NOT APPLICABLE IN SNOWFLAKE AS IT HAS EQUIVALENT DEFAULT BEHAVIOR. **
--		SET XACT_ABORT ON;

		BEGIN TRANSACTION;
		LINEAGEKEY := (SELECT
			TOP 1
				"Lineage Key"
			                              FROM
				Integration.Lineage
			                              WHERE
				"Table Name" = 'Purchase'
			                              AND "Data Load Completed" IS NULL
			                              ORDER BY "Lineage Key" DESC);

		-- Find the dimension keys required

		UPDATE Integration.Purchase_Staging p
		    SET
				p."Supplier Key" = COALESCE((SELECT
					TOP 1
						s."Supplier Key"
		                                 FROM
						Dimension.Supplier AS s
		                                 WHERE
						s."WWI Supplier ID" = p."WWI Supplier ID"
		                                 AND p."Last Modified When" > s."Valid From"
		                                 AND p."Last Modified When" <= s."Valid To"
							 ORDER BY s."Valid From"
				), 0),
				p."Stock Item Key" = COALESCE((SELECT
					TOP 1
						si."Stock Item Key"
		                                       FROM
						Dimension."Stock Item" AS si
		                                       WHERE
						si."WWI Stock Item ID" = p."WWI Stock Item ID"
		                                       AND p."Last Modified When" > si."Valid From"
		                                       AND p."Last Modified When" <= si."Valid To"
							       ORDER BY si."Valid From"
				), 0);
		-- Remove any existing entries for any of these purchase orders
		DELETE FROM
		    Fact.Purchase AS p
		WHERE
		    p."WWI Purchase Order ID" IN (SELECT
					"WWI Purchase Order ID"
				FROM
					Integration.Purchase_Staging
		    );

		-- Insert all current details for these purchase orders

		INSERT INTO Fact.Purchase
		    ("Date Key", "Supplier Key", "Stock Item Key", "WWI Purchase Order ID", "Ordered Outers", "Ordered Quantity", "Received Outers", Package, "Is Order Finalized", "Lineage Key")
		SELECT
		    "Date Key",
		    "Supplier Key",
		    "Stock Item Key",
		    "WWI Purchase Order ID",
		    "Ordered Outers",
		    "Ordered Quantity",
		    "Received Outers",
		    Package,
		    "Is Order Finalized",
		    :LINEAGEKEY
		FROM
		    Integration.Purchase_Staging;

		UPDATE Integration.Lineage
		    SET
				"Data Load Completed" = CURRENT_TIMESTAMP(),
				"Was Successful" = 1
		WHERE
				"Lineage Key" = :LINEAGEKEY;

		UPDATE Integration."ETL Cutoff"
		    SET
				"Cutoff Time" = (SELECT
						"Source System Cutoff Time"
		                         FROM
						Integration.Lineage
		                         WHERE
						"Lineage Key" = :LINEAGEKEY
				)
		FROM
				Integration."ETL Cutoff"
		WHERE
				"Table Name" = 'Purchase';
		COMMIT;
		RETURN 0;
	END;
$$;