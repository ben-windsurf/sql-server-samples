
WITH MonthlyRevenue AS (
    SELECT 
        d.[Calendar Year],
        d.[Calendar Month Number],
        d.[Calendar Month Label],
        d.[Calendar Month Year Label],
        d.[Fiscal Year],
        d.[Fiscal Month Number],
        d.[Fiscal Month Label],
        
        SUM(s.[Total Excluding Tax]) AS [Revenue Excluding Tax],
        SUM(s.[Total Including Tax]) AS [Revenue Including Tax],
        SUM(s.[Tax Amount]) AS [Tax Amount],
        SUM(s.[Profit]) AS [Profit],
        
        SUM(s.[Quantity]) AS [Total Quantity],
        COUNT(DISTINCT s.[WWI Invoice ID]) AS [Invoice Count],
        COUNT(*) AS [Line Item Count]
        
    FROM [Fact].[Sale] s
    INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
    WHERE d.[Date] >= DATEADD(MONTH, -12, GETDATE())
      AND d.[Date] < GETDATE()
    GROUP BY 
        d.[Calendar Year],
        d.[Calendar Month Number],
        d.[Calendar Month Label],
        d.[Calendar Month Year Label],
        d.[Fiscal Year],
        d.[Fiscal Month Number],
        d.[Fiscal Month Label]
),
MonthlyTrends AS (
    SELECT *,
        LAG([Revenue Excluding Tax], 1) OVER (ORDER BY [Calendar Year], [Calendar Month Number]) AS [Previous Month Revenue],
        LAG([Profit], 1) OVER (ORDER BY [Calendar Year], [Calendar Month Number]) AS [Previous Month Profit],
        
        CASE 
            WHEN LAG([Revenue Excluding Tax], 1) OVER (ORDER BY [Calendar Year], [Calendar Month Number]) > 0
            THEN (([Revenue Excluding Tax] - LAG([Revenue Excluding Tax], 1) OVER (ORDER BY [Calendar Year], [Calendar Month Number])) 
                  / LAG([Revenue Excluding Tax], 1) OVER (ORDER BY [Calendar Year], [Calendar Month Number])) * 100
            ELSE NULL
        END AS [Revenue Growth Rate %],
        
        CASE 
            WHEN [Revenue Excluding Tax] > 0 
            THEN ([Profit] / [Revenue Excluding Tax]) * 100 
            ELSE 0 
        END AS [Margin Percentage],
        
        AVG([Revenue Excluding Tax]) OVER (ORDER BY [Calendar Year], [Calendar Month Number] 
                                          ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS [3Month Avg Revenue],
        AVG([Profit]) OVER (ORDER BY [Calendar Year], [Calendar Month Number] 
                           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS [3Month Avg Profit]
        
    FROM MonthlyRevenue
)
SELECT 
    [Calendar Month Year Label] AS [Month],
    [Revenue Excluding Tax],
    [Revenue Including Tax],
    [Profit],
    [Margin Percentage],
    [Revenue Growth Rate %],
    [Total Quantity],
    [Invoice Count],
    [3Month Avg Revenue],
    [3Month Avg Profit],
    
    LAG([Revenue Excluding Tax], 12) OVER (ORDER BY [Calendar Year], [Calendar Month Number]) AS [Same Month Last Year Revenue],
    LAG([Profit], 12) OVER (ORDER BY [Calendar Year], [Calendar Month Number]) AS [Same Month Last Year Profit]
    
FROM MonthlyTrends
ORDER BY [Calendar Year], [Calendar Month Number];
