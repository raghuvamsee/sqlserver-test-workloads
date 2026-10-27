USE WideWorldImportersDW;
GO
CREATE TABLE Integration.[ETL Cutoff] (

    "Table Name" sysname NOT NULL, 
    "Cutoff Time" datetime2 NOT NULL, 
    CONSTRAINT [PK_Integration_ETL_Cutoff] PRIMARY KEY CLUSTERED ([Table Name] ASC)
)