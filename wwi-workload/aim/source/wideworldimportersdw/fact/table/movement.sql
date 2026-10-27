USE WideWorldImportersDW;
GO
CREATE TABLE Fact.Movement (

    "Movement Key" bigint IDENTITY(1,1) NOT NULL, 
    "Date Key" date NOT NULL, 
    "Stock Item Key" int NOT NULL, 
    "Customer Key" int NULL, 
    "Supplier Key" int NULL, 
    "Transaction Type Key" int NOT NULL, 
    "WWI Stock Item Transaction ID" int NOT NULL, 
    "WWI Invoice ID" int NULL, 
    "WWI Purchase Order ID" int NULL, 
    Quantity int NOT NULL, 
    "Lineage Key" int NOT NULL, 
    CONSTRAINT [PK_Fact_Movement] PRIMARY KEY NONCLUSTERED ([Movement Key] ASC, [Date Key] ASC)
)

ALTER TABLE [Fact].[Movement]
    ADD CONSTRAINT [FK_Fact_Movement_Customer_Key_Dimension_Customer] FOREIGN KEY ([Customer Key]) REFERENCES [Dimension].[Customer] ([Customer Key]);
ALTER TABLE [Fact].[Movement]
    ADD CONSTRAINT [FK_Fact_Movement_Date_Key_Dimension_Date] FOREIGN KEY ([Date Key]) REFERENCES [Dimension].[Date] ([Date]);
ALTER TABLE [Fact].[Movement]
    ADD CONSTRAINT [FK_Fact_Movement_Stock_Item_Key_Dimension_Stock Item] FOREIGN KEY ([Stock Item Key]) REFERENCES [Dimension].[Stock Item] ([Stock Item Key]);
ALTER TABLE [Fact].[Movement]
    ADD CONSTRAINT [FK_Fact_Movement_Supplier_Key_Dimension_Supplier] FOREIGN KEY ([Supplier Key]) REFERENCES [Dimension].[Supplier] ([Supplier Key]);
ALTER TABLE [Fact].[Movement]
    ADD CONSTRAINT [FK_Fact_Movement_Transaction_Type_Key_Dimension_Transaction Type] FOREIGN KEY ([Transaction Type Key]) REFERENCES [Dimension].[Transaction Type] ([Transaction Type Key]);