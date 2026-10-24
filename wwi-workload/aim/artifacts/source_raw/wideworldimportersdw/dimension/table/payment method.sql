USE WideWorldImportersDW;
GO
CREATE TABLE Dimension.[Payment Method] (

    "Payment Method Key" int NOT NULL CONSTRAINT [DF_Dimension_Payment_Method_Payment_Method_Key] DEFAULT (NEXT VALUE FOR [Sequences].[PaymentMethodKey]), 
    "WWI Payment Method ID" int NOT NULL, 
    "Payment Method" nvarchar(50) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    "Valid From" datetime2 NOT NULL, 
    "Valid To" datetime2 NOT NULL, 
    "Lineage Key" int NOT NULL, 
    CONSTRAINT [PK_Dimension_Payment_Method] PRIMARY KEY CLUSTERED ([Payment Method Key] ASC)
)