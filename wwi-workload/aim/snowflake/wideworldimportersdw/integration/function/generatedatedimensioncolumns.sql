USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE FUNCTION Integration.GenerateDateDimensionColumns (DATE DATE)
RETURNS TABLE(
              Date DATE,
              "Day Number" INT,
              Day VARCHAR(10),
              Month VARCHAR(10),
              "Short Month" VARCHAR(3),
              "Calendar Month Number" INT,
              "Calendar Month Label" VARCHAR(10),
              "Calendar Year" INT,
              "Calendar Year Label" VARCHAR(10),
              "Fiscal Month Number" INT,
              "Fiscal Month Label" VARCHAR(20),
              "Fiscal Year" INT,
              "Fiscal Year Label" VARCHAR(10),
              "ISO Week Number" INT
)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
AS
$$
              SELECT
                            DATE AS Date,
                            DAY(DATE :: TIMESTAMP) AS "Day Number",
                                          CAST(DAY(DATE :: TIMESTAMP) AS NVARCHAR(10)) AS Day,
                                          CAST(TO_CHAR(DATE, 'MMMM') AS NVARCHAR(10)) AS Month,
                                          CAST(SUBSTRING(TO_CHAR(DATE, 'MMMM'), 1, 3) AS NVARCHAR(3)) AS "Short Month",
                            MONTH(DATE :: TIMESTAMP) AS "Calendar Month Number",
                                          CAST('CY' || CAST(YEAR(DATE :: TIMESTAMP) AS NVARCHAR(4)) || '-' || SUBSTRING(TO_CHAR(DATE, 'MMMM'), 1, 3) AS NVARCHAR(10)) AS "Calendar Month Label",
                            YEAR(DATE :: TIMESTAMP) AS "Calendar Year",
                                          CAST('CY' || CAST(YEAR(DATE :: TIMESTAMP) AS NVARCHAR(4)) AS NVARCHAR(10)) AS "Calendar Year Label",
                                          CASE WHEN MONTH(DATE :: TIMESTAMP) IN (11, 12)
                                               THEN MONTH(DATE :: TIMESTAMP) - 10
                                               ELSE MONTH(DATE :: TIMESTAMP) + 2
                                          END AS "Fiscal Month Number",
                                          CAST('FY' || CAST(CASE WHEN MONTH(DATE :: TIMESTAMP) IN (11, 12)
                                                                 THEN YEAR(DATE :: TIMESTAMP) + 1
                                                                 ELSE YEAR(DATE :: TIMESTAMP)
                                                            END AS NVARCHAR(4)) || '-' || SUBSTRING(TO_CHAR(DATE, 'MMMM'), 1, 3) AS NVARCHAR(20)) AS "Fiscal Month Label",
                                          CASE WHEN MONTH(DATE :: TIMESTAMP) IN (11, 12)
                                               THEN YEAR(DATE :: TIMESTAMP) + 1
                                               ELSE YEAR(DATE :: TIMESTAMP)
                                          END AS "Fiscal Year",
                                          CAST('FY' || CAST(CASE WHEN MONTH(DATE :: TIMESTAMP) IN (11, 12)
                                                                 THEN YEAR(DATE :: TIMESTAMP) + 1
                                                                 ELSE YEAR(DATE :: TIMESTAMP)
                                                            END AS NVARCHAR(4)) AS NVARCHAR(10)) AS "Fiscal Year Label",
                            DATE_PART(weekiso, DATE :: TIMESTAMP) AS "ISO Week Number"
$$;