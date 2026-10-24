USE ${wideworldimportersdw};
GO

CREATE TABLE Integration.Sale_Staging (
  "Sale Staging Key" bigint IDENTITY(1, 1) NOT NULL,
  "City Key" int NULL,
  "Customer Key" int NULL,
  "Bill To Customer Key" int NULL,
  "Stock Item Key" int NULL,
  "Invoice Date Key" date NULL,
  "Delivery Date Key" date NULL,
  "Salesperson Key" int NULL,
  "WWI Invoice ID" int NULL,
  Description nvarchar(100) COLLATE Latin1_General_100_CI_AS NULL,
  Package nvarchar(50) COLLATE Latin1_General_100_CI_AS NULL,
  Quantity int NULL,
  "Unit Price" decimal(18, 2) NULL,
  "Tax Rate" decimal(18, 3) NULL,
  "Total Excluding Tax" decimal(18, 2) NULL,
  "Tax Amount" decimal(18, 2) NULL,
  Profit decimal(18, 2) NULL,
  "Total Including Tax" decimal(18, 2) NULL,
  "Total Dry Items" int NULL,
  "Total Chiller Items" int NULL,
  "WWI City ID" int NULL,
  "WWI Customer ID" int NULL,
  "WWI Bill To Customer ID" int NULL,
  "WWI Stock Item ID" int NULL,
  "WWI Salesperson ID" int NULL,
  "Last Modified When" datetime2 NULL,
  CONSTRAINT [PK_Integration_Sale_Staging] PRIMARY KEY NONCLUSTERED ([Sale Staging Key] ASC)
)