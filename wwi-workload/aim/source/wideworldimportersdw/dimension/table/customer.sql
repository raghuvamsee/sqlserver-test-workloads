USE WideWorldImportersDW;
GO
CREATE TABLE Dimension.Customer (

    "Customer Key" int NOT NULL CONSTRAINT [DF_Dimension_Customer_Customer_Key] DEFAULT (NEXT VALUE FOR [Sequences].[CustomerKey]), 
    "WWI Customer ID" int NOT NULL, 
    Customer nvarchar(100) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    "Bill To Customer" nvarchar(100) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    Category nvarchar(50) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    "Buying Group" nvarchar(50) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    "Primary Contact" nvarchar(50) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    "Postal Code" nvarchar(10) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    "Valid From" datetime2 NOT NULL, 
    "Valid To" datetime2 NOT NULL, 
    "Lineage Key" int NOT NULL, 
    CONSTRAINT [PK_Dimension_Customer] PRIMARY KEY CLUSTERED ([Customer Key] ASC)
)