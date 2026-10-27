USE WideWorldImportersDW;
GO
CREATE TABLE Dimension.Employee (

    "Employee Key" int NOT NULL CONSTRAINT [DF_Dimension_Employee_Employee_Key] DEFAULT (NEXT VALUE FOR [Sequences].[EmployeeKey]), 
    "WWI Employee ID" int NOT NULL, 
    Employee nvarchar(50) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    "Preferred Name" nvarchar(50) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    "Is Salesperson" bit NOT NULL, 
    Photo varbinary NULL, 
    "Valid From" datetime2 NOT NULL, 
    "Valid To" datetime2 NOT NULL, 
    "Lineage Key" int NOT NULL, 
    CONSTRAINT [PK_Dimension_Employee] PRIMARY KEY CLUSTERED ([Employee Key] ASC)
)