USE WideWorldImportersDW;
GO
CREATE TABLE Dimension.[Transaction Type] (

    "Transaction Type Key" int NOT NULL CONSTRAINT [DF_Dimension_Transaction_Type_Transaction_Type_Key] DEFAULT (NEXT VALUE FOR [Sequences].[TransactionTypeKey]), 
    "WWI Transaction Type ID" int NOT NULL, 
    "Transaction Type" nvarchar(50) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    "Valid From" datetime2 NOT NULL, 
    "Valid To" datetime2 NOT NULL, 
    "Lineage Key" int NOT NULL, 
    CONSTRAINT [PK_Dimension_Transaction_Type] PRIMARY KEY CLUSTERED ([Transaction Type Key] ASC)
)