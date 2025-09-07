
WITH FiscalMonthlyRevenue AS (
    SELECT 
        d.[Fiscal Year],
        d.[Fiscal Month Number],
        d.[Fiscal Month Label],
        d.[Calendar Month Year Label],
        d.[Beginning of Month] AS [Month Start Date],
        
        SUM(s.[Total Excluding Tax]) AS [Revenue Excluding Tax],
        SUM(s.[Total Including Tax]) AS [Revenue Including Tax],
        SUM(s.[Tax Amount]) AS [Tax Amount],
        SUM(s.[Profit]) AS [Profit],
        
        SUM(s.[Quantity]) AS [Total Quantity],
        COUNT(DISTINCT s.[WWI Invoice ID]) AS [Invoice Count],
        COUNT(DISTINCT s.[Customer Key]) AS [Active Customers],
        AVG(s.[Unit Price]) AS [Average Unit Price]
        
    FROM [Fact].[Sale] s
    INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
    WHERE d.[Date] >= DATEADD(MONTH, -12, GETDATE())
      AND d.[Date] < GETDATE()
    GROUP BY 
        d.[Fiscal Year],
        d.[Fiscal Month Number],
        d.[Fiscal Month Label],
        d.[Calendar Month Year Label],
        d.[Beginning of Month]
),
FiscalTrends AS (
    SELECT *,
        LAG([Revenue Excluding Tax], 1) OVER (ORDER BY [Fiscal Year], [Fiscal Month Number]) AS [Previous Fiscal Month Revenue],
        LAG([Profit], 1) OVER (ORDER BY [Fiscal Year], [Fiscal Month Number]) AS [Previous Fiscal Month Profit],
        
        CASE 
            WHEN LAG([Revenue Excluding Tax], 1) OVER (ORDER BY [Fiscal Year], [Fiscal Month Number]) > 0
            THEN (([Revenue Excluding Tax] - LAG([Revenue Excluding Tax], 1) OVER (ORDER BY [Fiscal Year], [Fiscal Month Number])) 
                  / LAG([Revenue Excluding Tax], 1) OVER (ORDER BY [Fiscal Year], [Fiscal Month Number])) * 100
            ELSE NULL
        END AS [Fiscal Revenue Growth Rate %],
        
        CASE 
            WHEN [Revenue Excluding Tax] > 0 
            THEN ([Profit] / [Revenue Excluding Tax]) * 100 
            ELSE 0 
        END AS [Margin Percentage],
        
        SUM([Revenue Excluding Tax]) OVER (PARTITION BY [Fiscal Year] 
                                          ORDER BY [Fiscal Month Number] 
                                          ROWS UNBOUNDED PRECEDING) AS [Fiscal YTD Revenue],
        SUM([Profit]) OVER (PARTITION BY [Fiscal Year] 
                           ORDER BY [Fiscal Month Number] 
                           ROWS UNBOUNDED PRECEDING) AS [Fiscal YTD Profit],
        
        AVG([Revenue Excluding Tax]) OVER (ORDER BY [Fiscal Year], [Fiscal Month Number] 
                                          ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS [Fiscal Quarter Avg Revenue]
        
    FROM FiscalMonthlyRevenue
)
SELECT 
    [Fiscal Year],
    [Fiscal Month Label] AS [Fiscal Month],
    [Calendar Month Year Label] AS [Calendar Month],
    [Month Start Date],
    [Revenue Excluding Tax],
    [Revenue Including Tax],
    [Profit],
    [Margin Percentage],
    [Fiscal Revenue Growth Rate %],
    [Fiscal YTD Revenue],
    [Fiscal YTD Profit],
    [Total Quantity],
    [Invoice Count],
    [Active Customers],
    [Average Unit Price],
    [Fiscal Quarter Avg Revenue],
    
    LAG([Revenue Excluding Tax], 12) OVER (ORDER BY [Fiscal Year], [Fiscal Month Number]) AS [Same Fiscal Month Last Year Revenue],
    LAG([Profit], 12) OVER (ORDER BY [Fiscal Year], [Fiscal Month Number]) AS [Same Fiscal Month Last Year Profit],
    
    CASE 
        WHEN LAG([Revenue Excluding Tax], 12) OVER (ORDER BY [Fiscal Year], [Fiscal Month Number]) > 0
        THEN (([Revenue Excluding Tax] - LAG([Revenue Excluding Tax], 12) OVER (ORDER BY [Fiscal Year], [Fiscal Month Number])) 
              / LAG([Revenue Excluding Tax], 12) OVER (ORDER BY [Fiscal Year], [Fiscal Month Number])) * 100
        ELSE NULL
    END AS [Fiscal YoY Revenue Growth %]
    
FROM FiscalTrends
ORDER BY [Fiscal Year], [Fiscal Month Number];
