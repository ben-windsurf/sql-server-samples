
WITH MonthlyRevenueTrends AS (
    SELECT 
        d.[Calendar Year] AS [Year],
        d.[Calendar Month Number] AS [Month Number],
        d.[Calendar Month Label] AS [Month Label],
        d.[Calendar Month Year Label] AS [Month Year],
        
        SUM(s.[Total Excluding Tax]) AS [Revenue Excluding Tax],
        SUM(s.[Total Including Tax]) AS [Revenue Including Tax],
        SUM(s.[Tax Amount]) AS [Total Tax Amount],
        
        SUM(s.[Profit]) AS [Total Profit],
        
        SUM(s.[Quantity]) AS [Total Quantity],
        COUNT(s.[Sale Key]) AS [Transaction Count],
        
        AVG(s.[Unit Price]) AS [Average Unit Price],
        AVG(s.[Tax Rate]) AS [Average Tax Rate]
        
    FROM [Fact].[Sale] s
    INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
    
    WHERE d.[Date] >= DATEADD(MONTH, -12, GETDATE())
      AND d.[Date] < GETDATE()
    
    GROUP BY 
        d.[Calendar Year],
        d.[Calendar Month Number],
        d.[Calendar Month Label],
        d.[Calendar Month Year Label]
),

TrendsWithCalculations AS (
    SELECT 
        *,
        
        CASE 
            WHEN [Revenue Excluding Tax] > 0 
            THEN ([Total Profit] / [Revenue Excluding Tax]) * 100 
            ELSE 0 
        END AS [Profit Margin Percentage],
        
        CASE 
            WHEN [Revenue Including Tax] > 0 
            THEN ([Total Tax Amount] / [Revenue Including Tax]) * 100 
            ELSE 0 
        END AS [Tax Rate Percentage],
        
        LAG([Revenue Excluding Tax], 1) OVER (ORDER BY [Year], [Month Number]) AS [Previous Month Revenue],
        LAG([Total Profit], 1) OVER (ORDER BY [Year], [Month Number]) AS [Previous Month Profit]
        
    FROM MonthlyRevenueTrends
)

SELECT 
    [Year],
    [Month Number],
    [Month Label],
    [Month Year],
    
    [Revenue Excluding Tax],
    [Revenue Including Tax],
    [Total Tax Amount],
    
    [Total Profit],
    [Profit Margin Percentage],
    
    [Total Quantity],
    [Transaction Count],
    
    [Average Unit Price],
    [Average Tax Rate],
    [Tax Rate Percentage],
    
    CASE 
        WHEN [Previous Month Revenue] > 0 
        THEN (([Revenue Excluding Tax] - [Previous Month Revenue]) / [Previous Month Revenue]) * 100 
        ELSE NULL 
    END AS [Revenue Growth Percentage],
    
    CASE 
        WHEN [Previous Month Profit] > 0 
        THEN (([Total Profit] - [Previous Month Profit]) / [Previous Month Profit]) * 100 
        ELSE NULL 
    END AS [Profit Growth Percentage]

FROM TrendsWithCalculations

ORDER BY [Year], [Month Number];
