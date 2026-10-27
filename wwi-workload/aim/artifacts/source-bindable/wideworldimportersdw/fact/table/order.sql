USE ${wideworldimportersdw};
GO

CREATE TABLE Fact.[Order] (
  "Order Key" bigint IDENTITY(1, 1) NOT NULL,
  "City Key" int NOT NULL,
  "Customer Key" int NOT NULL,
  "Stock Item Key" int NOT NULL,
  "Order Date Key" date NOT NULL,
  "Picked Date Key" date NULL,
  "Salesperson Key" int NOT NULL,
  "Picker Key" int NULL,
  "WWI Order ID" int NOT NULL,
  "WWI Backorder ID" int NULL,
  Description nvarchar(100) COLLATE Latin1_General_100_CI_AS NOT NULL,
  Package nvarchar(50) COLLATE Latin1_General_100_CI_AS NOT NULL,
  Quantity int NOT NULL,
  "Unit Price" decimal(18, 2) NOT NULL,
  "Tax Rate" decimal(18, 3) NOT NULL,
  "Total Excluding Tax" decimal(18, 2) NOT NULL,
  "Tax Amount" decimal(18, 2) NOT NULL,
  "Total Including Tax" decimal(18, 2) NOT NULL,
  "Lineage Key" int NOT NULL,
  CONSTRAINT [PK_Fact_Order] PRIMARY KEY NONCLUSTERED ([Order Key] ASC, [Order Date Key] ASC)
)

ALTER TABLE [Fact].[Order]
ADD CONSTRAINT [FK_Fact_Order_City_Key_Dimension_City] FOREIGN KEY ([City Key]) REFERENCES [Dimension].[City] ([City Key]);

ALTER TABLE [Fact].[Order]
ADD CONSTRAINT [FK_Fact_Order_Customer_Key_Dimension_Customer] FOREIGN KEY ([Customer Key]) REFERENCES [Dimension].[Customer] ([Customer Key]);

ALTER TABLE [Fact].[Order]
ADD CONSTRAINT [FK_Fact_Order_Order_Date_Key_Dimension_Date] FOREIGN KEY ([Order Date Key]) REFERENCES [Dimension].[Date] ([Date]);

ALTER TABLE [Fact].[Order]
ADD CONSTRAINT [FK_Fact_Order_Picked_Date_Key_Dimension_Date] FOREIGN KEY ([Picked Date Key]) REFERENCES [Dimension].[Date] ([Date]);

ALTER TABLE [Fact].[Order]
ADD CONSTRAINT [FK_Fact_Order_Picker_Key_Dimension_Employee] FOREIGN KEY ([Picker Key]) REFERENCES [Dimension].[Employee] ([Employee Key]);

ALTER TABLE [Fact].[Order]
ADD CONSTRAINT [FK_Fact_Order_Salesperson_Key_Dimension_Employee] FOREIGN KEY ([Salesperson Key]) REFERENCES [Dimension].[Employee] ([Employee Key]);

ALTER TABLE [Fact].[Order]
ADD CONSTRAINT [FK_Fact_Order_Stock_Item_Key_Dimension_Stock Item] FOREIGN KEY ([Stock Item Key]) REFERENCES [Dimension].[Stock Item] ([Stock Item Key]);