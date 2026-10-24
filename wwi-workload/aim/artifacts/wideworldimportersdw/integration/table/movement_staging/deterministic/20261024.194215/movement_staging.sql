USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE TABLE Integration.Movement_Staging (

       "Movement Staging Key" BIGINT IDENTITY(1,1) ORDER NOT NULL,
       "Date Key" DATE NULL,
       "Stock Item Key" INT NULL,
       "Customer Key" INT NULL,
       "Supplier Key" INT NULL,
       "Transaction Type Key" INT NULL,
       "WWI Stock Item Transaction ID" INT NULL,
       "WWI Invoice ID" INT NULL,
       "WWI Purchase Order ID" INT NULL,
       Quantity INT NULL,
       "WWI Stock Item ID" INT NULL,
       "WWI Customer ID" INT NULL,
       "WWI Supplier ID" INT NULL,
       "WWI Transaction Type ID" INT NULL,
       "Last Modifed When" TIMESTAMP_NTZ(7) NULL,
       CONSTRAINT PK_Integration_Movement_Staging PRIMARY KEY ("Movement Staging Key")
   )
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
;