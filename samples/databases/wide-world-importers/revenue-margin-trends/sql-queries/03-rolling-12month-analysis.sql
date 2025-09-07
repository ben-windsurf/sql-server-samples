
WITH DailyRevenue AS (
    SELECT 
        d.[Date],
        d.[Calendar Year],
        d.[Calendar Month Number],
        d.[Calendar Month Year Label],
        d.[Calendar Week Label],
        
        SUM(s.[Total Excluding Tax]) AS [Daily Revenue Excluding Tax],
        SUM(s.[Total Including Tax]) AS [Daily Revenue Including Tax],
        SUM(s.[Profit]) AS [Daily Profit],
        SUM(s.[Quantity]) AS [Daily Quantity],
        COUNT(DISTINCT s.[WWI Invoice ID]) AS [Daily Invoice Count]
        
    FROM [Fact].[Sale] s
    INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
    WHERE d.[Date] >= DATEADD(MONTH, -15, GETDATE()) -- Extra months for rolling calculations
      AND d.[Date] < GETDATE()
    GROUP BY 
        d.[Date],
        d.[Calendar Year],
        d.[Calendar Month Number],
        d.[Calendar Month Year Label],
        d.[Calendar Week Label]
),
Rolling12MonthMetrics AS (
    SELECT 
        [Date],
        [Calendar Month Year Label],
        [Daily Revenue Excluding Tax],
        [Daily Profit],
        
        SUM([Daily Revenue Excluding Tax]) OVER (ORDER BY [Date] 
                                               ROWS BETWEEN 364 PRECEDING AND CURRENT ROW) AS [Rolling 12M Revenue],
        SUM([Daily Profit]) OVER (ORDER BY [Date] 
                                 ROWS BETWEEN 364 PRECEDING AND CURRENT ROW) AS [Rolling 12M Profit],
        SUM([Daily Quantity]) OVER (ORDER BY [Date] 
                                   ROWS BETWEEN 364 PRECEDING AND CURRENT ROW) AS [Rolling 12M Quantity],
        
        AVG([Daily Revenue Excluding Tax]) OVER (ORDER BY [Date] 
                                               ROWS BETWEEN 364 PRECEDING AND CURRENT ROW) AS [Rolling 12M Avg Daily Revenue],
        AVG([Daily Profit]) OVER (ORDER BY [Date] 
                                 ROWS BETWEEN 364 PRECEDING AND CURRENT ROW) AS [Rolling 12M Avg Daily Profit],
        
        SUM([Daily Revenue Excluding Tax]) OVER (ORDER BY [Date] 
                                               ROWS BETWEEN 182 PRECEDING AND CURRENT ROW) AS [Rolling 6M Revenue],
        SUM([Daily Profit]) OVER (ORDER BY [Date] 
                                 ROWS BETWEEN 182 PRECEDING AND CURRENT ROW) AS [Rolling 6M Profit],
        
        SUM([Daily Revenue Excluding Tax]) OVER (ORDER BY [Date] 
                                               ROWS BETWEEN 91 PRECEDING AND CURRENT ROW) AS [Rolling 3M Revenue],
        SUM([Daily Profit]) OVER (ORDER BY [Date] 
                                 ROWS BETWEEN 91 PRECEDING AND CURRENT ROW) AS [Rolling 3M Profit]
        
    FROM DailyRevenue
),
MonthEndSummary AS (
    SELECT 
        [Date],
        [Calendar Month Year Label],
        [Rolling 12M Revenue],
        [Rolling 12M Profit],
        [Rolling 12M Quantity],
        [Rolling 12M Avg Daily Revenue],
        [Rolling 12M Avg Daily Profit],
        [Rolling 6M Revenue],
        [Rolling 6M Profit],
        [Rolling 3M Revenue],
        [Rolling 3M Profit],
        
        CASE 
            WHEN [Rolling 12M Revenue] > 0 
            THEN ([Rolling 12M Profit] / [Rolling 12M Revenue]) * 100 
            ELSE 0 
        END AS [Rolling 12M Margin %],
        
        CASE 
            WHEN [Rolling 6M Revenue] > 0 
            THEN ([Rolling 6M Profit] / [Rolling 6M Revenue]) * 100 
            ELSE 0 
        END AS [Rolling 6M Margin %],
        
        CASE 
            WHEN [Rolling 3M Revenue] > 0 
            THEN ([Rolling 3M Profit] / [Rolling 3M Revenue]) * 100 
            ELSE 0 
        END AS [Rolling 3M Margin %],
        
        LAG([Rolling 12M Revenue], 30) OVER (ORDER BY [Date]) AS [Rolling 12M Revenue 30 Days Ago],
        LAG([Rolling 12M Profit], 30) OVER (ORDER BY [Date]) AS [Rolling 12M Profit 30 Days Ago],
        
        ROW_NUMBER() OVER (PARTITION BY [Calendar Month Year Label] ORDER BY [Date] DESC) as rn
        
    FROM Rolling12MonthMetrics
    WHERE [Date] >= DATEADD(MONTH, -12, GETDATE()) -- Focus on last 12 months for output
)
SELECT 
    [Date] AS [Report Date],
    [Calendar Month Year Label] AS [Month],
    [Rolling 12M Revenue],
    [Rolling 12M Profit],
    [Rolling 12M Margin %],
    [Rolling 12M Quantity],
    [Rolling 12M Avg Daily Revenue],
    [Rolling 12M Avg Daily Profit],
    
    [Rolling 6M Revenue],
    [Rolling 6M Profit],
    [Rolling 6M Margin %],
    [Rolling 3M Revenue],
    [Rolling 3M Profit],
    [Rolling 3M Margin %],
    
    CASE 
        WHEN [Rolling 12M Revenue 30 Days Ago] > 0
        THEN (([Rolling 12M Revenue] - [Rolling 12M Revenue 30 Days Ago]) 
              / [Rolling 12M Revenue 30 Days Ago]) * 100
        ELSE NULL
    END AS [30-Day Rolling Revenue Growth %],
    
    CASE 
        WHEN [Rolling 12M Profit 30 Days Ago] > 0
        THEN (([Rolling 12M Profit] - [Rolling 12M Profit 30 Days Ago]) 
              / [Rolling 12M Profit 30 Days Ago]) * 100
        ELSE NULL
    END AS [30-Day Rolling Profit Growth %]
    
FROM MonthEndSummary
WHERE rn = 1 -- Only month-end dates for cleaner reporting
ORDER BY [Date];
