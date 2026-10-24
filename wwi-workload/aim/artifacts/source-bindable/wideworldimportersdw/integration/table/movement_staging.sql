USE ${wideworldimportersdw};
GO

CREATE TABLE Integration.Movement_Staging (
  "Movement Staging Key" bigint IDENTITY(1, 1) NOT NULL,
  "Date Key" date NULL,
  "Stock Item Key" int NULL,
  "Customer Key" int NULL,
  "Supplier Key" int NULL,
  "Transaction Type Key" int NULL,
  "WWI Stock Item Transaction ID" int NULL,
  "WWI Invoice ID" int NULL,
  "WWI Purchase Order ID" int NULL,
  Quantity int NULL,
  "WWI Stock Item ID" int NULL,
  "WWI Customer ID" int NULL,
  "WWI Supplier ID" int NULL,
  "WWI Transaction Type ID" int NULL,
  "Last Modifed When" datetime2 NULL,
  CONSTRAINT [PK_Integration_Movement_Staging] PRIMARY KEY NONCLUSTERED ([Movement Staging Key] ASC)
)