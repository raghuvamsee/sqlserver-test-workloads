USE WideWorldImportersDW;
GO
CREATE TABLE Integration.StockItem_Staging (

    "Stock Item Staging Key" int IDENTITY(1,1) NOT NULL, 
    "WWI Stock Item ID" int NOT NULL, 
    "Stock Item" nvarchar(100) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    Color nvarchar(20) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    "Selling Package" nvarchar(50) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    "Buying Package" nvarchar(50) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    Brand nvarchar(50) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    Size nvarchar(20) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    "Lead Time Days" int NOT NULL, 
    "Quantity Per Outer" int NOT NULL, 
    "Is Chiller Stock" bit NOT NULL, 
    Barcode nvarchar(50) COLLATE Latin1_General_100_CI_AS NULL, 
    "Tax Rate" decimal(18, 3) NOT NULL, 
    "Unit Price" decimal(18, 2) NOT NULL, 
    "Recommended Retail Price" decimal(18, 2) NULL, 
    "Typical Weight Per Unit" decimal(18, 3) NOT NULL, 
    Photo varbinary NULL, 
    "Valid From" datetime2 NOT NULL, 
    "Valid To" datetime2 NOT NULL, 
    CONSTRAINT [PK_Integration_Stock_Item_Staging] PRIMARY KEY NONCLUSTERED ([Stock Item Staging Key] ASC)
)