
WITH YearlyRevenueTrends AS (
    SELECT 
        d.[Calendar Year] AS [Year],
        d.[Calendar Year Label] AS [Year Label],
        
        SUM(s.[Total Excluding Tax]) AS [Revenue Excluding Tax],
        SUM(s.[Total Including Tax]) AS [Revenue Including Tax],
        SUM(s.[Tax Amount]) AS [Total Tax Amount],
        
        SUM(s.[Profit]) AS [Total Profit],
        
        SUM(s.[Quantity]) AS [Total Quantity],
        COUNT(s.[Sale Key]) AS [Transaction Count],
        COUNT(DISTINCT s.[Customer Key]) AS [Unique Customers],
        
        AVG(s.[Unit Price]) AS [Average Unit Price],
        AVG(s.[Tax Rate]) AS [Average Tax Rate]
        
    FROM [Fact].[Sale] s
    INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
    
    WHERE d.[Calendar Year] >= YEAR(GETDATE()) - 1
    
    GROUP BY 
        d.[Calendar Year],
        d.[Calendar Year Label]
),

YearlyTrendsWithCalculations AS (
    SELECT 
        *,
        
        CASE 
            WHEN [Revenue Excluding Tax] > 0 
            THEN ([Total Profit] / [Revenue Excluding Tax]) * 100 
            ELSE 0 
        END AS [Profit Margin Percentage],
        
        CASE 
            WHEN [Unique Customers] > 0 
            THEN [Revenue Excluding Tax] / [Unique Customers] 
            ELSE 0 
        END AS [Revenue Per Customer],
        
        CASE 
            WHEN [Transaction Count] > 0 
            THEN [Revenue Excluding Tax] / [Transaction Count] 
            ELSE 0 
        END AS [Average Transaction Value],
        
        LAG([Revenue Excluding Tax], 1) OVER (ORDER BY [Year]) AS [Previous Year Revenue],
        LAG([Total Profit], 1) OVER (ORDER BY [Year]) AS [Previous Year Profit],
        LAG([Profit Margin Percentage], 1) OVER (ORDER BY [Year]) AS [Previous Year Margin Percentage],
        LAG([Unique Customers], 1) OVER (ORDER BY [Year]) AS [Previous Year Customers],
        LAG([Transaction Count], 1) OVER (ORDER BY [Year]) AS [Previous Year Transactions]
        
    FROM (
        SELECT 
            *,
            CASE 
                WHEN [Revenue Excluding Tax] > 0 
                THEN ([Total Profit] / [Revenue Excluding Tax]) * 100 
                ELSE 0 
            END AS [Profit Margin Percentage]
        FROM YearlyRevenueTrends
    ) base
)

SELECT 
    [Year],
    [Year Label],
    
    [Revenue Excluding Tax],
    [Revenue Including Tax],
    [Total Profit],
    [Profit Margin Percentage],
    [Total Quantity],
    [Transaction Count],
    [Unique Customers],
    [Revenue Per Customer],
    [Average Transaction Value],
    [Average Unit Price],
    
    [Previous Year Revenue],
    [Previous Year Profit],
    [Previous Year Margin Percentage],
    [Previous Year Customers],
    [Previous Year Transactions],
    
    CASE 
        WHEN [Previous Year Revenue] > 0 
        THEN (([Revenue Excluding Tax] - [Previous Year Revenue]) / [Previous Year Revenue]) * 100 
        ELSE NULL 
    END AS [Revenue Growth Percentage],
    
    CASE 
        WHEN [Previous Year Profit] > 0 
        THEN (([Total Profit] - [Previous Year Profit]) / [Previous Year Profit]) * 100 
        ELSE NULL 
    END AS [Profit Growth Percentage],
    
    CASE 
        WHEN [Previous Year Margin Percentage] > 0 
        THEN [Profit Margin Percentage] - [Previous Year Margin Percentage]
        ELSE NULL 
    END AS [Margin Percentage Point Change],
    
    CASE 
        WHEN [Previous Year Customers] > 0 
        THEN (([Unique Customers] - [Previous Year Customers]) / CAST([Previous Year Customers] AS FLOAT)) * 100 
        ELSE NULL 
    END AS [Customer Growth Percentage],
    
    CASE 
        WHEN [Previous Year Transactions] > 0 
        THEN (([Transaction Count] - [Previous Year Transactions]) / CAST([Previous Year Transactions] AS FLOAT)) * 100 
        ELSE NULL 
    END AS [Transaction Growth Percentage]

FROM YearlyTrendsWithCalculations

ORDER BY [Year];
