CREATE VIEW [Reports].[MonthlyMarginTrends]
AS
SELECT 
    d.[Calendar Year] AS [Year],
    d.[Calendar Month Number] AS [Month],
    d.[Calendar Month Label] AS [Month Label],
    d.[Date] AS [Period Date],
    SUM(s.[Profit]) AS [Total Profit],
    SUM(s.[Total Excluding Tax]) AS [Total Revenue],
    CASE 
        WHEN SUM(s.[Total Excluding Tax]) > 0 
        THEN (SUM(s.[Profit]) / SUM(s.[Total Excluding Tax])) * 100 
        ELSE 0 
    END AS [Profit Margin Percentage],
    AVG(s.[Profit]) AS [Average Profit Per Sale],
    COUNT(*) AS [Transaction Count]
FROM [Fact].[Sale] s
INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
WHERE d.[Date] >= DATEADD(MONTH, -12, GETDATE())
GROUP BY 
    d.[Calendar Year],
    d.[Calendar Month Number], 
    d.[Calendar Month Label],
    d.[Date]
ORDER BY d.[Date];

GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Monthly margin trends for the last 12 months from WideWorldImportersDW', @level0type = N'SCHEMA', @level0name = N'Reports', @level1type = N'VIEW', @level1name = N'MonthlyMarginTrends';
