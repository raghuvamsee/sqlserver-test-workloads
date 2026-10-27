USE ${wideworldimportersdw};
GO

CREATE TABLE Dimension.Supplier (
  "Supplier Key" int NOT NULL CONSTRAINT [DF_Dimension_Supplier_Supplier_Key] DEFAULT (NEXT VALUE FOR [Sequences].[SupplierKey] ),
  "WWI Supplier ID" int NOT NULL,
  Supplier nvarchar(100) COLLATE Latin1_General_100_CI_AS NOT NULL,
  Category nvarchar(50) COLLATE Latin1_General_100_CI_AS NOT NULL,
  "Primary Contact" nvarchar(50) COLLATE Latin1_General_100_CI_AS NOT NULL,
  "Supplier Reference" nvarchar(20) COLLATE Latin1_General_100_CI_AS NULL,
  "Payment Days" int NOT NULL,
  "Postal Code" nvarchar(10) COLLATE Latin1_General_100_CI_AS NOT NULL,
  "Valid From" datetime2 NOT NULL,
  "Valid To" datetime2 NOT NULL,
  "Lineage Key" int NOT NULL,
  CONSTRAINT [PK_Dimension_Supplier] PRIMARY KEY CLUSTERED ([Supplier Key] ASC)
)