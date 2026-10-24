USE ${wideworldimportersdw};
GO

CREATE TABLE Dimension.City (
  "City Key" int NOT NULL CONSTRAINT [DF_Dimension_City_City_Key] DEFAULT (NEXT VALUE FOR [Sequences].[CityKey] ),
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
  "Lineage Key" int NOT NULL,
  CONSTRAINT [PK_Dimension_City] PRIMARY KEY CLUSTERED ([City Key] ASC)
)