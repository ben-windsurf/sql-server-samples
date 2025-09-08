CREATE PROCEDURE [Reports].[GetRevenueTrendsByDateRange]
@StartDate DATE = NULL,
@EndDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @StartDate IS NULL
        SET @StartDate = DATEADD(MONTH, -12, GETDATE());
    
    IF @EndDate IS NULL
        SET @EndDate = GETDATE();
    
    SELECT 
        d.[Calendar Year] AS [Year],
        d.[Calendar Month Number] AS [Month],
        d.[Calendar Month Label] AS [Month Label],
        d.[Calendar Quarter Label] AS [Quarter Label],
        d.[Date] AS [Period Date],
        SUM(s.[Total Excluding Tax]) AS [Revenue Excluding Tax],
        SUM(s.[Total Including Tax]) AS [Revenue Including Tax],
        SUM(s.[Profit]) AS [Total Profit],
        CASE 
            WHEN SUM(s.[Total Excluding Tax]) > 0 
            THEN (SUM(s.[Profit]) / SUM(s.[Total Excluding Tax])) * 100 
            ELSE 0 
        END AS [Profit Margin Percentage],
        COUNT(*) AS [Transaction Count],
        AVG(s.[Total Excluding Tax]) AS [Average Sale Value],
        MIN(s.[Total Excluding Tax]) AS [Min Sale Value],
        MAX(s.[Total Excluding Tax]) AS [Max Sale Value]
    FROM [Fact].[Sale] s
    INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
    WHERE d.[Date] >= @StartDate AND d.[Date] <= @EndDate
    GROUP BY 
        d.[Calendar Year],
        d.[Calendar Month Number], 
        d.[Calendar Month Label],
        d.[Calendar Quarter Label],
        d.[Date]
    ORDER BY d.[Date];
END;

GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Flexible revenue and margin trends analysis with customizable date range for PowerBI and Kyvos integration', @level0type = N'SCHEMA', @level0name = N'Reports', @level1type = N'PROCEDURE', @level1name = N'GetRevenueTrendsByDateRange';
