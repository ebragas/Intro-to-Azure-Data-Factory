
USE datamart;
GO

-- 1. Clean-up
DROP PROCEDURE dbo.usp_Populate_US_Sales;
DROP TABLE dbo.US_Sales;
DROP TABLE stage.US_Sales;
DROP SCHEMA stage;
GO



-- 2. Create schema stage
IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'stage')
DROP SCHEMA stage;
GO

CREATE SCHEMA stage;
GO



-- 3. STAGE
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'stage' AND TABLE_NAME = 'US_Sales')
DROP TABLE stage.US_Sales;
GO

CREATE TABLE stage.US_Sales(
	ProductID VARCHAR(50) NULL,
	Date VARCHAR(50) NULL,
	Zip VARCHAR(50) NULL,
	Units VARCHAR(50) NULL,
	Revenue VARCHAR(50) NULL
);
GO



-- 4. DBO
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'US_Sales')
DROP TABLE dbo.US_Sales;
GO

CREATE TABLE dbo.US_Sales(
	ProductID INT NULL ,
	TotalRevenue MONEY NULL ,
	SliceStart DATETIME NULL ,
	SliceEnd DATETIME NULL ,
	WindowStart DATETIME NULL ,
	WindowEnd DATETIME NULL
);
GO



-- 5. Create Transform Procedure
CREATE PROC dbo.usp_Populate_US_Sales
	@SliceStart DATETIME ,
	@SliceEnd DATETIME ,
	@WindowStart DATETIME ,
	@WindowEnd datetime
AS
INSERT INTO dbo.US_sales (
		ProductID ,
		TotalRevenue ,
		SliceStart ,
		SliceEnd ,
		WindowStart ,
		WindowEnd )

SELECT	ProductID ,
		SUM(CAST(Revenue AS MONEY)) ,
		@SliceStart ,
		@SliceEnd ,
		@WindowStart ,
		@WindowEnd
FROM	stage.US_sales
GROUP BY ProductID;
GO


-- Test
SELECT	*
FROM	dbo.US_Sales

SELECT	*
FROM	stage.US_Sales

TRUNCATE TABLE stage.US_Sales

SELECT	CAST(SliceStart AS DATE)
FROM	dbo.US_Sales
GROUP BY CAST(SliceStart AS DATE)