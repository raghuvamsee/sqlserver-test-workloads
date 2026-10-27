USE WideWorldImportersDW;
GO
CREATE TABLE Fact.[Transaction] (

    "Transaction Key" bigint IDENTITY(1,1) NOT NULL, 
    "Date Key" date NOT NULL, 
    "Customer Key" int NULL, 
    "Bill To Customer Key" int NULL, 
    "Supplier Key" int NULL, 
    "Transaction Type Key" int NOT NULL, 
    "Payment Method Key" int NULL, 
    "WWI Customer Transaction ID" int NULL, 
    "WWI Supplier Transaction ID" int NULL, 
    "WWI Invoice ID" int NULL, 
    "WWI Purchase Order ID" int NULL, 
    "Supplier Invoice Number" nvarchar(20) COLLATE Latin1_General_100_CI_AS NULL, 
    "Total Excluding Tax" decimal(18, 2) NOT NULL, 
    "Tax Amount" decimal(18, 2) NOT NULL, 
    "Total Including Tax" decimal(18, 2) NOT NULL, 
    "Outstanding Balance" decimal(18, 2) NOT NULL, 
    "Is Finalized" bit NOT NULL, 
    "Lineage Key" int NOT NULL, 
    CONSTRAINT [PK_Fact_Transaction] PRIMARY KEY NONCLUSTERED ([Transaction Key] ASC, [Date Key] ASC)
)

ALTER TABLE [Fact].[Transaction]
    ADD CONSTRAINT [FK_Fact_Transaction_Bill_To_Customer_Key_Dimension_Customer] FOREIGN KEY ([Bill To Customer Key]) REFERENCES [Dimension].[Customer] ([Customer Key]);
ALTER TABLE [Fact].[Transaction]
    ADD CONSTRAINT [FK_Fact_Transaction_Customer_Key_Dimension_Customer] FOREIGN KEY ([Customer Key]) REFERENCES [Dimension].[Customer] ([Customer Key]);
ALTER TABLE [Fact].[Transaction]
    ADD CONSTRAINT [FK_Fact_Transaction_Date_Key_Dimension_Date] FOREIGN KEY ([Date Key]) REFERENCES [Dimension].[Date] ([Date]);
ALTER TABLE [Fact].[Transaction]
    ADD CONSTRAINT [FK_Fact_Transaction_Payment_Method_Key_Dimension_Payment Method] FOREIGN KEY ([Payment Method Key]) REFERENCES [Dimension].[Payment Method] ([Payment Method Key]);
ALTER TABLE [Fact].[Transaction]
    ADD CONSTRAINT [FK_Fact_Transaction_Supplier_Key_Dimension_Supplier] FOREIGN KEY ([Supplier Key]) REFERENCES [Dimension].[Supplier] ([Supplier Key]);
ALTER TABLE [Fact].[Transaction]
    ADD CONSTRAINT [FK_Fact_Transaction_Transaction_Type_Key_Dimension_Transaction Type] FOREIGN KEY ([Transaction Type Key]) REFERENCES [Dimension].[Transaction Type] ([Transaction Type Key]);