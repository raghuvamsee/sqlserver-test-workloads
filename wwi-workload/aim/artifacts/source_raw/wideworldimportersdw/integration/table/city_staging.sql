USE WideWorldImportersDW;
GO
CREATE TABLE Integration.City_Staging (

    "City Staging Key" int IDENTITY(1,1) NOT NULL, 
    "WWI City ID" int NOT NULL, 
    City nvarchar(50) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    "State Province" nvarchar(50) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    Country nvarchar(60) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    Continent nvarchar(30) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    "Sales Territory" nvarchar(50) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    Region nvarchar(30) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    Subregion nvarchar(30) COLLATE Latin1_General_100_CI_AS NOT NULL, 
    Location geography NULL, 
    "Latest Recorded Population" bigint NOT NULL, 
    "Valid From" datetime2 NOT NULL, 
    "Valid To" datetime2 NOT NULL, 
    CONSTRAINT [PK_Integration_City_Staging] PRIMARY KEY CLUSTERED ([City Staging Key] ASC)
)