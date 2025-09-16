
WITH QuarterlyRevenueTrends AS (
    SELECT 
        d.[Calendar Year] AS [Year],
        d.[Calendar Quarter Number] AS [Quarter Number],
        d.[Calendar Quarter Label] AS [Quarter Label],
        d.[Calendar Quarter Year Label] AS [Quarter Year],
        
        SUM(s.[Total Excluding Tax]) AS [Revenue Excluding Tax],
        SUM(s.[Total Including Tax]) AS [Revenue Including Tax],
        SUM(s.[Tax Amount]) AS [Total Tax Amount],
        
        SUM(s.[Profit]) AS [Total Profit],
        
        SUM(s.[Quantity]) AS [Total Quantity],
        COUNT(s.[Sale Key]) AS [Transaction Count],
        
        AVG(s.[Unit Price]) AS [Average Unit Price]
        
    FROM [Fact].[Sale] s
    INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
    
    WHERE d.[Date] >= DATEADD(MONTH, -12, GETDATE())
      AND d.[Date] < GETDATE()
    
    GROUP BY 
        d.[Calendar Year],
        d.[Calendar Quarter Number],
        d.[Calendar Quarter Label],
        d.[Calendar Quarter Year Label]
),

QuarterlyTrendsWithCalculations AS (
    SELECT 
        *,
        
        CASE 
            WHEN [Revenue Excluding Tax] > 0 
            THEN ([Total Profit] / [Revenue Excluding Tax]) * 100 
            ELSE 0 
        END AS [Profit Margin Percentage],
        
        LAG([Revenue Excluding Tax], 1) OVER (ORDER BY [Year], [Quarter Number]) AS [Previous Quarter Revenue],
        LAG([Total Profit], 1) OVER (ORDER BY [Year], [Quarter Number]) AS [Previous Quarter Profit],
        
        LAG([Revenue Excluding Tax], 4) OVER (ORDER BY [Year], [Quarter Number]) AS [Same Quarter Previous Year Revenue],
        LAG([Total Profit], 4) OVER (ORDER BY [Year], [Quarter Number]) AS [Same Quarter Previous Year Profit]
        
    FROM QuarterlyRevenueTrends
)

SELECT 
    [Year],
    [Quarter Number],
    [Quarter Label],
    [Quarter Year],
    
    [Revenue Excluding Tax],
    [Revenue Including Tax],
    [Total Tax Amount],
    
    [Total Profit],
    [Profit Margin Percentage],
    
    [Total Quantity],
    [Transaction Count],
    [Average Unit Price],
    
    CASE 
        WHEN [Previous Quarter Revenue] > 0 
        THEN (([Revenue Excluding Tax] - [Previous Quarter Revenue]) / [Previous Quarter Revenue]) * 100 
        ELSE NULL 
    END AS [QoQ Revenue Growth Percentage],
    
    CASE 
        WHEN [Previous Quarter Profit] > 0 
        THEN (([Total Profit] - [Previous Quarter Profit]) / [Previous Quarter Profit]) * 100 
        ELSE NULL 
    END AS [QoQ Profit Growth Percentage],
    
    CASE 
        WHEN [Same Quarter Previous Year Revenue] > 0 
        THEN (([Revenue Excluding Tax] - [Same Quarter Previous Year Revenue]) / [Same Quarter Previous Year Revenue]) * 100 
        ELSE NULL 
    END AS [YoY Revenue Growth Percentage],
    
    CASE 
        WHEN [Same Quarter Previous Year Profit] > 0 
        THEN (([Total Profit] - [Same Quarter Previous Year Profit]) / [Same Quarter Previous Year Profit]) * 100 
        ELSE NULL 
    END AS [YoY Profit Growth Percentage]

FROM QuarterlyTrendsWithCalculations

ORDER BY [Year], [Quarter Number];
