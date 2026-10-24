USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE PROCEDURE Integration.MigrateStagedTransactionData ()
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
				"Table Name" = 'Transaction'
			                              AND "Data Load Completed" IS NULL
			                              ORDER BY "Lineage Key" DESC);

		-- Find the dimension keys required

		UPDATE Integration.Transaction_Staging t
		    SET
				t."Customer Key" = COALESCE((SELECT
					TOP 1
						c."Customer Key"
		                                     FROM
						Dimension.Customer AS c
		                                     WHERE
						c."WWI Customer ID" = t."WWI Customer ID"
		                                     AND t."Last Modified When" > c."Valid From"
		                                     AND t."Last Modified When" <= c."Valid To"
							     ORDER BY c."Valid From"
				), 0),
				t."Bill To Customer Key" = COALESCE((SELECT
					TOP 1
						c."Customer Key"
		                                             FROM
						Dimension.Customer AS c
		                                             WHERE
						c."WWI Customer ID" = t."WWI Bill To Customer ID"
		                                             AND t."Last Modified When" > c."Valid From"
		                                             AND t."Last Modified When" <= c."Valid To"
							             ORDER BY c."Valid From"
				), 0),
				t."Supplier Key" = COALESCE((SELECT
					TOP 1
						s."Supplier Key"
		                                     FROM
						Dimension.Supplier AS s
		                                     WHERE
						s."WWI Supplier ID" = t."WWI Supplier ID"
		                                     AND t."Last Modified When" > s."Valid From"
		                                     AND t."Last Modified When" <= s."Valid To"
							     ORDER BY s."Valid From"
				), 0),
				t."Transaction Type Key" = COALESCE((SELECT
					TOP 1
						tt."Transaction Type Key"
		                                             FROM
						Dimension."Transaction Type" AS tt
		                                             WHERE
						tt."WWI Transaction Type ID" = t."WWI Transaction Type ID"
		                                             AND t."Last Modified When" > tt."Valid From"
		                                             AND t."Last Modified When" <= tt."Valid To"
							             ORDER BY tt."Valid From"
				), 0),
				t."Payment Method Key" = COALESCE((SELECT
					TOP 1
						pm."Payment Method Key"
		                                             FROM
						Dimension."Payment Method" AS pm
		                                             WHERE
						pm."WWI Payment Method ID" = t."WWI Payment Method ID"
		                                             AND t."Last Modified When" > pm."Valid From"
		                                             AND t."Last Modified When" <= pm."Valid To"
							             ORDER BY pm."Valid From"
				), 0);

		-- Insert all the transactions

		INSERT INTO Fact.Transaction
		    ("Date Key", "Customer Key", "Bill To Customer Key", "Supplier Key", "Transaction Type Key", "Payment Method Key", "WWI Customer Transaction ID", "WWI Supplier Transaction ID", "WWI Invoice ID", "WWI Purchase Order ID", "Supplier Invoice Number", "Total Excluding Tax", "Tax Amount", "Total Including Tax", "Outstanding Balance", "Is Finalized", "Lineage Key")
		SELECT
		    "Date Key",
		    "Customer Key",
		    "Bill To Customer Key",
		    "Supplier Key",
		    "Transaction Type Key",
		    "Payment Method Key",
		    "WWI Customer Transaction ID",
		    "WWI Supplier Transaction ID",
		    "WWI Invoice ID",
		    "WWI Purchase Order ID",
		    "Supplier Invoice Number",
		    "Total Excluding Tax",
		    "Tax Amount",
		    "Total Including Tax",
		    "Outstanding Balance",
		    "Is Finalized",
		    :LINEAGEKEY
		FROM
		    Integration.Transaction_Staging;

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
				"Table Name" = 'Transaction';
		COMMIT;
		RETURN 0;
	END;
$$;