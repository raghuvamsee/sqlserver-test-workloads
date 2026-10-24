USE WideWorldImportersDW;
GO
CREATE TABLE Integration.StockHolding_Staging (

    "Stock Holding Staging Key" bigint IDENTITY(1,1) NOT NULL, 
    "Stock Item Key" int NULL, 
    "Quantity On Hand" int NULL, 
    "Bin Location" nvarchar(20) COLLATE Latin1_General_100_CI_AS NULL, 
    "Last Stocktake Quantity" int NULL, 
    "Last Cost Price" decimal(18, 2) NULL, 
    "Reorder Level" int NULL, 
    "Target Stock Level" int NULL, 
    "WWI Stock Item ID" int NULL, 
    CONSTRAINT [PK_Integration_Stock_Holding_Staging] PRIMARY KEY NONCLUSTERED ([Stock Holding Staging Key] ASC)
)