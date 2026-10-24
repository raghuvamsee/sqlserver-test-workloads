USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE PROCEDURE Integration.MigrateStagedOrderData ()
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
				"Table Name" = 'Order'
			                              AND "Data Load Completed" IS NULL
			                              ORDER BY "Lineage Key" DESC);

		-- Find the dimension keys required

		UPDATE Integration.Order_Staging o
		    SET
				o."City Key" = COALESCE((SELECT
					TOP 1
						c."City Key"
		                                 FROM
						Dimension.City AS c
		                                 WHERE
						c."WWI City ID" = o."WWI City ID"
		                                 AND o."Last Modified When" > c."Valid From"
		                                 AND o."Last Modified When" <= c."Valid To"
							 ORDER BY c."Valid From"
				), 0),
				o."Customer Key" = COALESCE((SELECT
					TOP 1
						c."Customer Key"
		                                     FROM
						Dimension.Customer AS c
		                                     WHERE
						c."WWI Customer ID" = o."WWI Customer ID"
		                                     AND o."Last Modified When" > c."Valid From"
		                                     AND o."Last Modified When" <= c."Valid To"
											 ORDER BY c."Valid From"
				), 0),
				o."Stock Item Key" = COALESCE((SELECT
					TOP 1
						si."Stock Item Key"
		                                       FROM
						Dimension."Stock Item" AS si
		                                       WHERE
						si."WWI Stock Item ID" = o."WWI Stock Item ID"
		                                       AND o."Last Modified When" > si."Valid From"
		                                       AND o."Last Modified When" <= si."Valid To"
			                       ORDER BY si."Valid From"
				), 0),
				o."Salesperson Key" = COALESCE((SELECT
					TOP 1
						e."Employee Key"
		                                     FROM
						Dimension.Employee AS e
		                                     WHERE
						e."WWI Employee ID" = o."WWI Salesperson ID"
		                                     AND o."Last Modified When" > e."Valid From"
		                                     AND o."Last Modified When" <= e."Valid To"
							     ORDER BY e."Valid From"
				), 0),
				o."Picker Key" = COALESCE((SELECT
					TOP 1
						e."Employee Key"
		                                   FROM
						Dimension.Employee AS e
		                                   WHERE
						e."WWI Employee ID" = o."WWI Picker ID"
		                                   AND o."Last Modified When" > e."Valid From"
		                                   AND o."Last Modified When" <= e."Valid To"
							   ORDER BY e."Valid From"
				), 0);
		-- Remove any existing entries for any of these orders
		DELETE FROM
		    Fact."Order" AS o
		WHERE
		    o."WWI Order ID" IN (SELECT
					"WWI Order ID"
				FROM
					Integration.Order_Staging
		    );

		-- Insert all current details for these orders

		INSERT INTO Fact."Order"
		    ("City Key", "Customer Key", "Stock Item Key", "Order Date Key", "Picked Date Key", "Salesperson Key", "Picker Key", "WWI Order ID", "WWI Backorder ID", Description, Package, Quantity, "Unit Price", "Tax Rate", "Total Excluding Tax", "Tax Amount", "Total Including Tax", "Lineage Key")
		SELECT
		    "City Key",
		    "Customer Key",
		    "Stock Item Key",
		    "Order Date Key",
		    "Picked Date Key",
		    "Salesperson Key",
		    "Picker Key",
		    "WWI Order ID",
		    "WWI Backorder ID",
		    Description,
		    Package,
		    Quantity,
		    "Unit Price",
		    "Tax Rate",
		    "Total Excluding Tax",
		    "Tax Amount",
		    "Total Including Tax",
		    :LINEAGEKEY
		FROM
		    Integration.Order_Staging;

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
				"Table Name" = 'Order';
		COMMIT;
		RETURN 0;
	END;
$$;