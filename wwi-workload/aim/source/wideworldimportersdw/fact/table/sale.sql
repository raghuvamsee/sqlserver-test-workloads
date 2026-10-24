USE WideWorldImportersDW;
GO
CREATE TABLE Fact.Sale (

    "Sale Key" bigint IDENTITY(1,1) NOT NULL, 
    "City Key" int NOT NULL, 
    "Customer Key" int NOT NULL, 
    "Bill To Customer Key" int NOT NULL, 
    "Stock Item Key" int NOT NULL, 
    "Invoice Date Key" date NOT NULL, 
    "Delivery Date Key" date NULL, 
    "Salesperson Key" int NOT NULL, 
    "WWI Invoice ID" int NOT NULL, 
    Description nvarchar(100) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    Package nvarchar(50) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    Quantity int NOT NULL, 
    "Unit Price" decimal(18, 2) NOT NULL, 
    "Tax Rate" decimal(18, 3) NOT NULL, 
    "Total Excluding Tax" decimal(18, 2) NOT NULL, 
    "Tax Amount" decimal(18, 2) NOT NULL, 
    Profit decimal(18, 2) NOT NULL, 
    "Total Including Tax" decimal(18, 2) NOT NULL, 
    "Total Dry Items" int NOT NULL, 
    "Total Chiller Items" int NOT NULL, 
    "Lineage Key" int NOT NULL, 
    CONSTRAINT [PK_Fact_Sale] PRIMARY KEY NONCLUSTERED ([Sale Key] ASC, [Invoice Date Key] ASC)
)

ALTER TABLE [Fact].[Sale]
    ADD CONSTRAINT [FK_Fact_Sale_Bill_To_Customer_Key_Dimension_Customer] FOREIGN KEY ([Bill To Customer Key]) REFERENCES [Dimension].[Customer] ([Customer Key]);
ALTER TABLE [Fact].[Sale]
    ADD CONSTRAINT [FK_Fact_Sale_City_Key_Dimension_City] FOREIGN KEY ([City Key]) REFERENCES [Dimension].[City] ([City Key]);
ALTER TABLE [Fact].[Sale]
    ADD CONSTRAINT [FK_Fact_Sale_Customer_Key_Dimension_Customer] FOREIGN KEY ([Customer Key]) REFERENCES [Dimension].[Customer] ([Customer Key]);
ALTER TABLE [Fact].[Sale]
    ADD CONSTRAINT [FK_Fact_Sale_Delivery_Date_Key_Dimension_Date] FOREIGN KEY ([Delivery Date Key]) REFERENCES [Dimension].[Date] ([Date]);
ALTER TABLE [Fact].[Sale]
    ADD CONSTRAINT [FK_Fact_Sale_Invoice_Date_Key_Dimension_Date] FOREIGN KEY ([Invoice Date Key]) REFERENCES [Dimension].[Date] ([Date]);
ALTER TABLE [Fact].[Sale]
    ADD CONSTRAINT [FK_Fact_Sale_Salesperson_Key_Dimension_Employee] FOREIGN KEY ([Salesperson Key]) REFERENCES [Dimension].[Employee] ([Employee Key]);
ALTER TABLE [Fact].[Sale]
    ADD CONSTRAINT [FK_Fact_Sale_Stock_Item_Key_Dimension_Stock Item] FOREIGN KEY ([Stock Item Key]) REFERENCES [Dimension].[Stock Item] ([Stock Item Key]);