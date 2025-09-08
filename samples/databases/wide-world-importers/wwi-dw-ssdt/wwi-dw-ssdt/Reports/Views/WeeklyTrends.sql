CREATE VIEW [Reports].[WeeklyTrends]
AS
SELECT 
    d.[Calendar Year] AS [Year],
    d.[Calendar Week Number] AS [Week Number],
    d.[Calendar Week Label] AS [Week Label],
    MIN(d.[Date]) AS [Week Start Date],
    MAX(d.[Date]) AS [Week End Date],
    SUM(s.[Total Excluding Tax]) AS [Revenue Excluding Tax],
    SUM(s.[Total Including Tax]) AS [Revenue Including Tax],
    SUM(s.[Profit]) AS [Total Profit],
    CASE 
        WHEN SUM(s.[Total Excluding Tax]) > 0 
        THEN (SUM(s.[Profit]) / SUM(s.[Total Excluding Tax])) * 100 
        ELSE 0 
    END AS [Profit Margin Percentage],
    COUNT(*) AS [Transaction Count],
    AVG(s.[Total Excluding Tax]) AS [Average Sale Value]
FROM [Fact].[Sale] s
INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
WHERE d.[Date] >= DATEADD(WEEK, -52, GETDATE())
GROUP BY 
    d.[Calendar Year],
    d.[Calendar Week Number],
    d.[Calendar Week Label]
ORDER BY d.[Calendar Year], d.[Calendar Week Number];

GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Weekly revenue and margin trends for the last 52 weeks from WideWorldImportersDW', @level0type = N'SCHEMA', @level0name = N'Reports', @level1type = N'VIEW', @level1name = N'WeeklyTrends';
