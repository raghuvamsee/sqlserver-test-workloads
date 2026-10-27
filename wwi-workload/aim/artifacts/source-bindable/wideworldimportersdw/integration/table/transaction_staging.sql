USE ${wideworldimportersdw};
GO

CREATE TABLE Integration.Transaction_Staging (
  "Transaction Staging Key" bigint IDENTITY(1, 1) NOT NULL,
  "Date Key" date NULL,
  "Customer Key" int NULL,
  "Bill To Customer Key" int NULL,
  "Supplier Key" int NULL,
  "Transaction Type Key" int NULL,
  "Payment Method Key" int NULL,
  "WWI Customer Transaction ID" int NULL,
  "WWI Supplier Transaction ID" int NULL,
  "WWI Invoice ID" int NULL,
  "WWI Purchase Order ID" int NULL,
  "Supplier Invoice Number" nvarchar(20) COLLATE Latin1_General_100_CI_AS NULL,
  "Total Excluding Tax" decimal(18, 2) NULL,
  "Tax Amount" decimal(18, 2) NULL,
  "Total Including Tax" decimal(18, 2) NULL,
  "Outstanding Balance" decimal(18, 2) NULL,
  "Is Finalized" bit NULL,
  "WWI Customer ID" int NULL,
  "WWI Bill To Customer ID" int NULL,
  "WWI Supplier ID" int NULL,
  "WWI Transaction Type ID" int NULL,
  "WWI Payment Method ID" int NULL,
  "Last Modified When" datetime2 NULL,
  CONSTRAINT [PK_Integration_Transaction_Staging] PRIMARY KEY NONCLUSTERED ([Transaction Staging Key] ASC)
)