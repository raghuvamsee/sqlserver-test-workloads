USE WideWorldImportersDW;
GO
CREATE TABLE Fact.[Stock Holding] (

    "Stock Holding Key" bigint IDENTITY(1,1) NOT NULL, 
    "Stock Item Key" int NOT NULL, 
    "Quantity On Hand" int NOT NULL, 
    "Bin Location" nvarchar(20) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    "Last Stocktake Quantity" int NOT NULL, 
    "Last Cost Price" decimal(18, 2) NOT NULL, 
    "Reorder Level" int NOT NULL, 
    "Target Stock Level" int NOT NULL, 
    "Lineage Key" int NOT NULL, 
    CONSTRAINT [PK_Fact_Stock_Holding] PRIMARY KEY NONCLUSTERED ([Stock Holding Key] ASC)
)

ALTER TABLE [Fact].[Stock Holding]
    ADD CONSTRAINT [FK_Fact_Stock_Holding_Stock_Item_Key_Dimension_Stock Item] FOREIGN KEY ([Stock Item Key]) REFERENCES [Dimension].[Stock Item] ([Stock Item Key]);