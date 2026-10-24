USE WideWorldImportersDW;
GO
CREATE TABLE Integration.Employee_Staging (

    "Employee Staging Key" int IDENTITY(1,1) NOT NULL, 
    "WWI Employee ID" int NOT NULL, 
    Employee nvarchar(50) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    "Preferred Name" nvarchar(50) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    "Is Salesperson" bit NOT NULL, 
    Photo varbinary NULL, 
    "Valid From" datetime2 NOT NULL, 
    "Valid To" datetime2 NOT NULL, 
    CONSTRAINT [PK_Integration_Employee_Staging] PRIMARY KEY NONCLUSTERED ([Employee Staging Key] ASC)
)