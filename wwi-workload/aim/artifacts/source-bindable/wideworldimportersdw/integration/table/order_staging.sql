USE ${wideworldimportersdw};
GO

CREATE TABLE Integration.Order_Staging (
  "Order Staging Key" bigint IDENTITY(1, 1) NOT NULL,
  "City Key" int NULL,
  "Customer Key" int NULL,
  "Stock Item Key" int NULL,
  "Order Date Key" date NULL,
  "Picked Date Key" date NULL,
  "Salesperson Key" int NULL,
  "Picker Key" int NULL,
  "WWI Order ID" int NULL,
  "WWI Backorder ID" int NULL,
  Description nvarchar(100) COLLATE Latin1_General_100_CI_AS NULL,
  Package nvarchar(50) COLLATE Latin1_General_100_CI_AS NULL,
  Quantity int NULL,
  "Unit Price" decimal(18, 2) NULL,
  "Tax Rate" decimal(18, 3) NULL,
  "Total Excluding Tax" decimal(18, 2) NULL,
  "Tax Amount" decimal(18, 2) NULL,
  "Total Including Tax" decimal(18, 2) NULL,
  "Lineage Key" int NULL,
  "WWI City ID" int NULL,
  "WWI Customer ID" int NULL,
  "WWI Stock Item ID" int NULL,
  "WWI Salesperson ID" int NULL,
  "WWI Picker ID" int NULL,
  "Last Modified When" datetime2 NULL,
  CONSTRAINT [PK_Integration_Order_Staging] PRIMARY KEY NONCLUSTERED ([Order Staging Key] ASC)
)