USE WideWorldImportersDW;
GO
CREATE TABLE Integration.Lineage (

    "Lineage Key" int NOT NULL CONSTRAINT [DF_Integration_Lineage_Lineage_Key] DEFAULT (NEXT VALUE FOR [Sequences].[LineageKey]), 
    "Data Load Started" datetime2 NOT NULL, 
    "Table Name" sysname NOT NULL, 
    "Data Load Completed" datetime2 NULL, 
    "Was Successful" bit NOT NULL, 
    "Source System Cutoff Time" datetime2 NOT NULL, 
    CONSTRAINT [PK_Integration_Lineage] PRIMARY KEY CLUSTERED ([Lineage Key] ASC)
)