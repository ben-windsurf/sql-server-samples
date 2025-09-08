CREATE VIEW [Reports].[MonthlyRevenueTrends]
AS
SELECT 
    d.[Calendar Year] AS [Year],
    d.[Calendar Month Number] AS [Month],
    d.[Calendar Month Label] AS [Month Label],
    d.[Date] AS [Period Date],
    SUM(s.[Total Excluding Tax]) AS [Revenue Excluding Tax],
    SUM(s.[Total Including Tax]) AS [Revenue Including Tax],
    COUNT(*) AS [Transaction Count],
    AVG(s.[Total Excluding Tax]) AS [Average Sale Value]
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
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Monthly revenue trends for the last 12 months from WideWorldImportersDW', @level0type = N'SCHEMA', @level0name = N'Reports', @level1type = N'VIEW', @level1name = N'MonthlyRevenueTrends';
