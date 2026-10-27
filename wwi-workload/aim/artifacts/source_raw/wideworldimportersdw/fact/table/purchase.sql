USE WideWorldImportersDW;
GO
CREATE TABLE Fact.Purchase (

    "Purchase Key" bigint IDENTITY(1,1) NOT NULL, 
    "Date Key" date NOT NULL, 
    "Supplier Key" int NOT NULL, 
    "Stock Item Key" int NOT NULL, 
    "WWI Purchase Order ID" int NULL, 
    "Ordered Outers" int NOT NULL, 
    "Ordered Quantity" int NOT NULL, 
    "Received Outers" int NOT NULL, 
    Package nvarchar(50) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    "Is Order Finalized" bit NOT NULL, 
    "Lineage Key" int NOT NULL, 
    CONSTRAINT [PK_Fact_Purchase] PRIMARY KEY NONCLUSTERED ([Purchase Key] ASC, [Date Key] ASC)
)

ALTER TABLE [Fact].[Purchase]
    ADD CONSTRAINT [FK_Fact_Purchase_Date_Key_Dimension_Date] FOREIGN KEY ([Date Key]) REFERENCES [Dimension].[Date] ([Date]);
ALTER TABLE [Fact].[Purchase]
    ADD CONSTRAINT [FK_Fact_Purchase_Stock_Item_Key_Dimension_Stock Item] FOREIGN KEY ([Stock Item Key]) REFERENCES [Dimension].[Stock Item] ([Stock Item Key]);
ALTER TABLE [Fact].[Purchase]
    ADD CONSTRAINT [FK_Fact_Purchase_Supplier_Key_Dimension_Supplier] FOREIGN KEY ([Supplier Key]) REFERENCES [Dimension].[Supplier] ([Supplier Key]);