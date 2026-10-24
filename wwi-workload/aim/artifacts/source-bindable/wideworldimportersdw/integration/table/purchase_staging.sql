USE ${wideworldimportersdw};
GO

CREATE TABLE Integration.Purchase_Staging (
  "Purchase Staging Key" bigint IDENTITY(1, 1) NOT NULL,
  "Date Key" date NULL,
  "Supplier Key" int NULL,
  "Stock Item Key" int NULL,
  "WWI Purchase Order ID" int NULL,
  "Ordered Outers" int NULL,
  "Ordered Quantity" int NULL,
  "Received Outers" int NULL,
  Package nvarchar(50) COLLATE Latin1_General_100_CI_AS NULL,
  "Is Order Finalized" bit NULL,
  "WWI Supplier ID" int NULL,
  "WWI Stock Item ID" int NULL,
  "Last Modified When" datetime2 NULL,
  CONSTRAINT [PK_Integration_Purchase_Staging] PRIMARY KEY NONCLUSTERED ([Purchase Staging Key] ASC)
)