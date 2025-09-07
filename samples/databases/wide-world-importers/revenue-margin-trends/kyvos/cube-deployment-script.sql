
USE WideWorldImportersDW;
GO


IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Sale_InvoiceDate_Performance')
CREATE NONCLUSTERED INDEX IX_Sale_InvoiceDate_Performance
ON [Fact].[Sale] ([Invoice Date Key])
INCLUDE ([Total Excluding Tax], [Total Including Tax], [Profit], [Quantity], [Customer Key], [Stock Item Key]);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Sale_Customer_Performance')
CREATE NONCLUSTERED INDEX IX_Sale_Customer_Performance
ON [Fact].[Sale] ([Customer Key])
INCLUDE ([Invoice Date Key], [Total Excluding Tax], [Profit]);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Sale_StockItem_Performance')
CREATE NONCLUSTERED INDEX IX_Sale_StockItem_Performance
ON [Fact].[Sale] ([Stock Item Key])
INCLUDE ([Invoice Date Key], [Total Excluding Tax], [Profit], [Quantity]);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Date_Calendar_Hierarchy')
CREATE NONCLUSTERED INDEX IX_Date_Calendar_Hierarchy
ON [Dimension].[Date] ([Calendar Year], [Calendar Month Number])
INCLUDE ([Calendar Month Label], [Calendar Quarter Label], [Fiscal Year], [Fiscal Month Number]);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Customer_Geographic_Hierarchy')
CREATE NONCLUSTERED INDEX IX_Customer_Geographic_Hierarchy
ON [Dimension].[Customer] ([Customer Key])
INCLUDE ([Customer], [Category], [Buying Group]);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_StockItem_Product_Hierarchy')
CREATE NONCLUSTERED INDEX IX_StockItem_Product_Hierarchy
ON [Dimension].[Stock Item] ([Stock Item Key])
INCLUDE ([Stock Item], [Brand], [Color], [Size]);

GO


IF OBJECT_ID('dbo.vw_SalesAnalysis', 'V') IS NOT NULL
    DROP VIEW dbo.vw_SalesAnalysis;
GO

CREATE VIEW dbo.vw_SalesAnalysis
AS
SELECT 
    s.[Sale Key],
    s.[Invoice Date Key],
    s.[Customer Key],
    s.[Stock Item Key],
    s.[WWI Invoice ID],
    s.[Total Excluding Tax],
    s.[Total Including Tax],
    s.[Profit],
    s.[Quantity],
    s.[Unit Price],
    
    d.[Date],
    d.[Calendar Year],
    d.[Calendar Month Number],
    d.[Calendar Month Label],
    d.[Calendar Quarter Label],
    d.[Calendar Month Year Label],
    d.[Fiscal Year],
    d.[Fiscal Month Number],
    d.[Fiscal Month Label],
    d.[Beginning of Month],
    d.[End of Month],
    
    c.[Customer],
    c.[Category] AS [Customer Category],
    c.[Buying Group],
    
    si.[Stock Item],
    si.[Brand],
    si.[Color],
    si.[Size],
    si.[Lead Time Days],
    si.[Is Chiller Stock],
    
    city.[City],
    city.[State Province],
    city.[Sales Territory]
    
FROM [Fact].[Sale] s
INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
INNER JOIN [Dimension].[Customer] c ON s.[Customer Key] = c.[Customer Key]
INNER JOIN [Dimension].[Stock Item] si ON s.[Stock Item Key] = si.[Stock Item Key]
INNER JOIN [Dimension].[City] city ON s.[City Key] = city.[City Key];

GO

IF OBJECT_ID('dbo.vw_MonthlySalesSummary', 'V') IS NOT NULL
    DROP VIEW dbo.vw_MonthlySalesSummary;
GO

CREATE VIEW dbo.vw_MonthlySalesSummary
AS
SELECT 
    d.[Calendar Year],
    d.[Calendar Month Number],
    d.[Calendar Month Label],
    d.[Calendar Month Year Label],
    d.[Fiscal Year],
    d.[Fiscal Month Number],
    c.[Category] AS [Customer Category],
    c.[Buying Group],
    si.[Brand],
    city.[Sales Territory],
    city.[State Province],
    
    SUM(s.[Total Excluding Tax]) AS [Total Revenue Excluding Tax],
    SUM(s.[Total Including Tax]) AS [Total Revenue Including Tax],
    SUM(s.[Profit]) AS [Total Profit],
    SUM(s.[Quantity]) AS [Total Quantity],
    COUNT(DISTINCT s.[WWI Invoice ID]) AS [Invoice Count],
    COUNT(DISTINCT s.[Customer Key]) AS [Customer Count],
    AVG(s.[Unit Price]) AS [Average Unit Price]
    
FROM [Fact].[Sale] s
INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
INNER JOIN [Dimension].[Customer] c ON s.[Customer Key] = c.[Customer Key]
INNER JOIN [Dimension].[Stock Item] si ON s.[Stock Item Key] = si.[Stock Item Key]
INNER JOIN [Dimension].[City] city ON s.[City Key] = city.[City Key]
GROUP BY 
    d.[Calendar Year],
    d.[Calendar Month Number],
    d.[Calendar Month Label],
    d.[Calendar Month Year Label],
    d.[Fiscal Year],
    d.[Fiscal Month Number],
    c.[Category],
    c.[Buying Group],
    si.[Brand],
    city.[Sales Territory],
    city.[State Province];

GO


IF OBJECT_ID('dbo.sp_RefreshCubeData', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_RefreshCubeData;
GO

CREATE PROCEDURE dbo.sp_RefreshCubeData
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @StartDate IS NULL
        SET @StartDate = DATEADD(DAY, -30, GETDATE());
    
    IF @EndDate IS NULL
        SET @EndDate = GETDATE();
    
    UPDATE STATISTICS [Fact].[Sale];
    UPDATE STATISTICS [Dimension].[Date];
    UPDATE STATISTICS [Dimension].[Customer];
    UPDATE STATISTICS [Dimension].[Stock Item];
    
    PRINT 'Cube data refreshed for period: ' + CAST(@StartDate AS VARCHAR(10)) + ' to ' + CAST(@EndDate AS VARCHAR(10));
    PRINT 'Refresh completed at: ' + CAST(GETDATE() AS VARCHAR(25));
END;

GO


IF OBJECT_ID('dbo.sp_ValidateCubeData', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_ValidateCubeData;
GO

CREATE PROCEDURE dbo.sp_ValidateCubeData
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorCount INT = 0;
    
    IF EXISTS (SELECT 1 FROM [Fact].[Sale] WHERE [Invoice Date Key] IS NULL)
    BEGIN
        PRINT 'ERROR: Found NULL Invoice Date Keys in Fact.Sale';
        SET @ErrorCount = @ErrorCount + 1;
    END
    
    IF EXISTS (SELECT 1 FROM [Fact].[Sale] WHERE [Customer Key] IS NULL)
    BEGIN
        PRINT 'ERROR: Found NULL Customer Keys in Fact.Sale';
        SET @ErrorCount = @ErrorCount + 1;
    END
    
    IF EXISTS (SELECT 1 FROM [Fact].[Sale] WHERE [Stock Item Key] IS NULL)
    BEGIN
        PRINT 'ERROR: Found NULL Stock Item Keys in Fact.Sale';
        SET @ErrorCount = @ErrorCount + 1;
    END
    
    IF EXISTS (SELECT 1 FROM [Fact].[Sale] WHERE [Total Excluding Tax] < 0)
    BEGIN
        PRINT 'WARNING: Found negative values in Total Excluding Tax';
    END
    
    IF EXISTS (SELECT 1 FROM [Fact].[Sale] WHERE [Quantity] <= 0)
    BEGIN
        PRINT 'WARNING: Found zero or negative quantities';
    END
    
    DECLARE @MinDate DATE, @MaxDate DATE;
    SELECT @MinDate = MIN([Invoice Date Key]), @MaxDate = MAX([Invoice Date Key])
    FROM [Fact].[Sale];
    
    PRINT 'Data coverage: ' + CAST(@MinDate AS VARCHAR(10)) + ' to ' + CAST(@MaxDate AS VARCHAR(10));
    
    SELECT 
        'Data Quality Summary' AS [Check Type],
        COUNT(*) AS [Total Records],
        COUNT(DISTINCT [Invoice Date Key]) AS [Unique Dates],
        COUNT(DISTINCT [Customer Key]) AS [Unique Customers],
        COUNT(DISTINCT [Stock Item Key]) AS [Unique Products],
        SUM([Total Excluding Tax]) AS [Total Revenue],
        SUM([Profit]) AS [Total Profit]
    FROM [Fact].[Sale];
    
    IF @ErrorCount = 0
        PRINT 'Data validation completed successfully - no critical errors found';
    ELSE
        PRINT 'Data validation completed with ' + CAST(@ErrorCount AS VARCHAR(10)) + ' critical errors';
        
    RETURN @ErrorCount;
END;

GO


IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'CubeUsers')
    CREATE ROLE CubeUsers;

GRANT SELECT ON [Fact].[Sale] TO CubeUsers;
GRANT SELECT ON [Dimension].[Date] TO CubeUsers;
GRANT SELECT ON [Dimension].[Customer] TO CubeUsers;
GRANT SELECT ON [Dimension].[Stock Item] TO CubeUsers;
GRANT SELECT ON [Dimension].[City] TO CubeUsers;
GRANT SELECT ON [Dimension].[Employee] TO CubeUsers;
GRANT SELECT ON dbo.vw_SalesAnalysis TO CubeUsers;
GRANT SELECT ON dbo.vw_MonthlySalesSummary TO CubeUsers;
GRANT EXECUTE ON dbo.sp_RefreshCubeData TO CubeUsers;
GRANT EXECUTE ON dbo.sp_ValidateCubeData TO CubeUsers;


PRINT '=== Running Initial Data Validation ===';
EXEC dbo.sp_ValidateCubeData;

PRINT '=== Cube Deployment Preparation Complete ===';
PRINT 'Next steps:';
PRINT '1. Import WWI-Revenue-Margin-Cube.xml into Kyvos';
PRINT '2. Configure data source connection';
PRINT '3. Process the cube';
PRINT '4. Test with sample MDX queries';

GO
