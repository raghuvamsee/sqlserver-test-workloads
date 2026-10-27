USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE PROCEDURE Integration.MigrateStagedSaleData ()
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
				"Table Name" = 'Sale'
			                              AND "Data Load Completed" IS NULL
			                              ORDER BY "Lineage Key" DESC);

		-- Find the dimension keys required

		UPDATE Integration.Sale_Staging s
		    SET
				s."City Key" = COALESCE((SELECT
					TOP 1
						c."City Key"
		                                 FROM
						Dimension.City AS c
		                                 WHERE
						c."WWI City ID" = s."WWI City ID"
		                                 AND s."Last Modified When" > c."Valid From"
		                                 AND s."Last Modified When" <= c."Valid To"
							 ORDER BY c."Valid From"
				), 0),
				s."Customer Key" = COALESCE((SELECT
					TOP 1
						c."Customer Key"
		                                       FROM
						Dimension.Customer AS c
		                                       WHERE
						c."WWI Customer ID" = s."WWI Customer ID"
		                                       AND s."Last Modified When" > c."Valid From"
		                                       AND s."Last Modified When" <= c."Valid To"
							       ORDER BY c."Valid From"
				), 0),
				s."Bill To Customer Key" = COALESCE((SELECT
					TOP 1
						c."Customer Key"
		                                             FROM
						Dimension.Customer AS c
		                                             WHERE
						c."WWI Customer ID" = s."WWI Bill To Customer ID"
		                                             AND s."Last Modified When" > c."Valid From"
		                                             AND s."Last Modified When" <= c."Valid To"
							             ORDER BY c."Valid From"
				), 0),
				s."Stock Item Key" = COALESCE((SELECT
					TOP 1
						si."Stock Item Key"
		                                       FROM
						Dimension."Stock Item" AS si
		                                       WHERE
						si."WWI Stock Item ID" = s."WWI Stock Item ID"
		                                       AND s."Last Modified When" > si."Valid From"
		                                       AND s."Last Modified When" <= si."Valid To"
							       ORDER BY si."Valid From"
				), 0),
				s."Salesperson Key" = COALESCE((SELECT
					TOP 1
						e."Employee Key"
		                                        FROM
						Dimension.Employee AS e
		                                        WHERE
						e."WWI Employee ID" = s."WWI Salesperson ID"
		                                        AND s."Last Modified When" > e."Valid From"
		                                        AND s."Last Modified When" <= e."Valid To"
							        ORDER BY e."Valid From"
				), 0);
		-- Remove any existing entries for any of these invoices
		DELETE FROM
		    Fact.Sale AS s
		WHERE
		    s."WWI Invoice ID" IN (SELECT
					"WWI Invoice ID"
				FROM
					Integration.Sale_Staging
		    );

		-- Insert all current details for these invoices

		INSERT INTO Fact.Sale
		    ("City Key", "Customer Key", "Bill To Customer Key", "Stock Item Key", "Invoice Date Key", "Delivery Date Key", "Salesperson Key", "WWI Invoice ID", Description, Package, Quantity, "Unit Price", "Tax Rate", "Total Excluding Tax", "Tax Amount", Profit, "Total Including Tax", "Total Dry Items", "Total Chiller Items", "Lineage Key")
		SELECT
		    "City Key",
		    "Customer Key",
		    "Bill To Customer Key",
		    "Stock Item Key",
		    "Invoice Date Key",
		    "Delivery Date Key",
		    "Salesperson Key",
		    "WWI Invoice ID",
		    Description,
		    Package,
		    Quantity,
		    "Unit Price",
		    "Tax Rate",
		    "Total Excluding Tax",
		    "Tax Amount",
		    Profit,
		    "Total Including Tax",
		    "Total Dry Items",
		    "Total Chiller Items",
		    :LINEAGEKEY
		FROM
		    Integration.Sale_Staging;

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
				"Table Name" = 'Sale';
		COMMIT;
		RETURN 0;
	END;
$$;