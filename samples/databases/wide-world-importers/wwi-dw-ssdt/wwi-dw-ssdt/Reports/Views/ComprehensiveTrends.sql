CREATE VIEW [Reports].[ComprehensiveTrends]
AS
WITH MonthlyData AS (
    SELECT 
        d.[Calendar Year] AS [Year],
        d.[Calendar Month Number] AS [Month],
        d.[Calendar Month Label] AS [Month Label],
        d.[Date] AS [Period Date],
        SUM(s.[Total Excluding Tax]) AS [Revenue],
        SUM(s.[Profit]) AS [Profit],
        COUNT(*) AS [Transaction Count]
    FROM [Fact].[Sale] s
    INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
    WHERE d.[Date] >= DATEADD(MONTH, -24, GETDATE())
    GROUP BY d.[Calendar Year], d.[Calendar Month Number], d.[Calendar Month Label], d.[Date]
),
TrendData AS (
    SELECT *,
        CASE WHEN [Revenue] > 0 THEN ([Profit] / [Revenue]) * 100 ELSE 0 END AS [Margin Percentage],
        LAG([Revenue], 12) OVER (ORDER BY [Year], [Month]) AS [Revenue Previous Year],
        LAG([Profit], 12) OVER (ORDER BY [Year], [Month]) AS [Profit Previous Year],
        AVG([Revenue]) OVER (ORDER BY [Year], [Month] ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS [Revenue 3Month Average]
    FROM MonthlyData
)
SELECT 
    [Year], [Month], [Month Label], [Period Date],
    [Revenue], [Profit], [Margin Percentage], [Transaction Count],
    [Revenue Previous Year], [Profit Previous Year],
    CASE 
        WHEN [Revenue Previous Year] > 0 
        THEN (([Revenue] - [Revenue Previous Year]) / [Revenue Previous Year]) * 100 
        ELSE NULL 
    END AS [Revenue YoY Growth Percentage],
    [Revenue 3Month Average]
FROM TrendData
WHERE [Period Date] >= DATEADD(MONTH, -12, GETDATE())
ORDER BY [Period Date];

GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Comprehensive 12-month revenue and margin trends with year-over-year comparisons from WideWorldImportersDW', @level0type = N'SCHEMA', @level0name = N'Reports', @level1type = N'VIEW', @level1name = N'ComprehensiveTrends';
