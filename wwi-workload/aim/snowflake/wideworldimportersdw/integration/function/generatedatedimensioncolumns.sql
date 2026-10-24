USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE FUNCTION Integration.GenerateDateDimensionColumns (DATE DATE)
RETURNS TABLE(
              Date STRING /*** SSC-FDM-TS0012 - INFORMATION FOR THE COLUMN Date WAS NOT FOUND. STRING DATATYPE USED TO MATCH CAST AS STRING OPERATION ***/,
              "Day Number" STRING /*** SSC-FDM-TS0012 - INFORMATION FOR THE COLUMN "Day Number" WAS NOT FOUND. STRING DATATYPE USED TO MATCH CAST AS STRING OPERATION ***/,
              Day STRING /*** SSC-FDM-TS0012 - INFORMATION FOR THE COLUMN Day WAS NOT FOUND. STRING DATATYPE USED TO MATCH CAST AS STRING OPERATION ***/,
              Month STRING /*** SSC-FDM-TS0012 - INFORMATION FOR THE COLUMN Month WAS NOT FOUND. STRING DATATYPE USED TO MATCH CAST AS STRING OPERATION ***/,
              "Short Month" STRING /*** SSC-FDM-TS0012 - INFORMATION FOR THE COLUMN "Short Month" WAS NOT FOUND. STRING DATATYPE USED TO MATCH CAST AS STRING OPERATION ***/,
              "Calendar Month Number" STRING /*** SSC-FDM-TS0012 - INFORMATION FOR THE COLUMN "Calendar Month Number" WAS NOT FOUND. STRING DATATYPE USED TO MATCH CAST AS STRING OPERATION ***/,
              "Calendar Month Label" STRING /*** SSC-FDM-TS0012 - INFORMATION FOR THE COLUMN "Calendar Month Label" WAS NOT FOUND. STRING DATATYPE USED TO MATCH CAST AS STRING OPERATION ***/,
              "Calendar Year" STRING /*** SSC-FDM-TS0012 - INFORMATION FOR THE COLUMN "Calendar Year" WAS NOT FOUND. STRING DATATYPE USED TO MATCH CAST AS STRING OPERATION ***/,
              "Calendar Year Label" STRING /*** SSC-FDM-TS0012 - INFORMATION FOR THE COLUMN "Calendar Year Label" WAS NOT FOUND. STRING DATATYPE USED TO MATCH CAST AS STRING OPERATION ***/,
              "Fiscal Month Number" STRING /*** SSC-FDM-TS0012 - INFORMATION FOR THE COLUMN "Fiscal Month Number" WAS NOT FOUND. STRING DATATYPE USED TO MATCH CAST AS STRING OPERATION ***/,
              "Fiscal Month Label" STRING /*** SSC-FDM-TS0012 - INFORMATION FOR THE COLUMN "Fiscal Month Label" WAS NOT FOUND. STRING DATATYPE USED TO MATCH CAST AS STRING OPERATION ***/,
              "Fiscal Year" STRING /*** SSC-FDM-TS0012 - INFORMATION FOR THE COLUMN "Fiscal Year" WAS NOT FOUND. STRING DATATYPE USED TO MATCH CAST AS STRING OPERATION ***/,
              "Fiscal Year Label" STRING /*** SSC-FDM-TS0012 - INFORMATION FOR THE COLUMN "Fiscal Year Label" WAS NOT FOUND. STRING DATATYPE USED TO MATCH CAST AS STRING OPERATION ***/,
              "ISO Week Number" STRING /*** SSC-FDM-TS0012 - INFORMATION FOR THE COLUMN "ISO Week Number" WAS NOT FOUND. STRING DATATYPE USED TO MATCH CAST AS STRING OPERATION ***/
)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
AS
$$
              SELECT
                            DATE AS Date,
                            DAY(DATE :: TIMESTAMP) AS "Day Number",
                                          CAST(DECODE(DAYNAME(DATE), 'Mon', 'Monday', 'Tue', 'Tuesday', 'Wed', 'Wednesday', 'Thu', 'Thursday', 'Fri', 'Friday', 'Sat', 'Saturday', 'Sun', 'Sunday') AS NVARCHAR(10)) AS Day,
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