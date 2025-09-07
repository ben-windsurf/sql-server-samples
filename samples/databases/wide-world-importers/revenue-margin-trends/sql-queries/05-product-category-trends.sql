
WITH ProductCategoryRevenue AS (
    SELECT 
        d.[Calendar Month Year Label],
        d.[Calendar Year],
        d.[Calendar Month Number],
        si.[Stock Item] AS [Product Name],
        si.[Color] AS [Product Color],
        si.[Brand] AS [Product Brand],
        si.[Size] AS [Product Size],
        si.[Lead Time Days] AS [Lead Time Days],
        si.[Is Chiller Stock] AS [Is Chiller Stock],
        
        SUM(s.[Total Excluding Tax]) AS [Product Revenue Excluding Tax],
        SUM(s.[Total Including Tax]) AS [Product Revenue Including Tax],
        SUM(s.[Profit]) AS [Product Profit],
        SUM(s.[Quantity]) AS [Product Quantity],
        
        COUNT(DISTINCT s.[WWI Invoice ID]) AS [Invoice Count],
        COUNT(DISTINCT s.[Customer Key]) AS [Customer Count],
        AVG(s.[Unit Price]) AS [Average Unit Price],
        MIN(s.[Unit Price]) AS [Min Unit Price],
        MAX(s.[Unit Price]) AS [Max Unit Price],
        
        SUM(s.[Total Excluding Tax]) / NULLIF(SUM(s.[Quantity]), 0) AS [Revenue Per Unit],
        SUM(s.[Profit]) / NULLIF(SUM(s.[Quantity]), 0) AS [Profit Per Unit]
        
    FROM [Fact].[Sale] s
    INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
    INNER JOIN [Dimension].[Stock Item] si ON s.[Stock Item Key] = si.[Stock Item Key]
    WHERE d.[Date] >= DATEADD(MONTH, -12, GETDATE())
      AND d.[Date] < GETDATE()
    GROUP BY 
        d.[Calendar Month Year Label],
        d.[Calendar Year],
        d.[Calendar Month Number],
        si.[Stock Item],
        si.[Color],
        si.[Brand],
        si.[Size],
        si.[Lead Time Days],
        si.[Is Chiller Stock]
),
ProductTrends AS (
    SELECT *,
        CASE 
            WHEN [Product Revenue Excluding Tax] > 0 
            THEN ([Product Profit] / [Product Revenue Excluding Tax]) * 100 
            ELSE 0 
        END AS [Product Margin %],
        
        LAG([Product Revenue Excluding Tax], 1) OVER (
            PARTITION BY [Product Name], [Product Color], [Product Brand] 
            ORDER BY [Calendar Year], [Calendar Month Number]
        ) AS [Previous Month Product Revenue],
        
        LAG([Product Profit], 1) OVER (
            PARTITION BY [Product Name], [Product Color], [Product Brand] 
            ORDER BY [Calendar Year], [Calendar Month Number]
        ) AS [Previous Month Product Profit],
        
        LAG([Product Quantity], 1) OVER (
            PARTITION BY [Product Name], [Product Color], [Product Brand] 
            ORDER BY [Calendar Year], [Calendar Month Number]
        ) AS [Previous Month Product Quantity],
        
        AVG([Product Revenue Excluding Tax]) OVER (
            PARTITION BY [Product Name], [Product Color], [Product Brand] 
            ORDER BY [Calendar Year], [Calendar Month Number] 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS [3Month Avg Product Revenue],
        
        AVG([Product Quantity]) OVER (
            PARTITION BY [Product Name], [Product Color], [Product Brand] 
            ORDER BY [Calendar Year], [Calendar Month Number] 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS [3Month Avg Product Quantity]
        
    FROM ProductCategoryRevenue
),
ProductRanking AS (
    SELECT *,
        CASE 
            WHEN [Previous Month Product Revenue] > 0
            THEN (([Product Revenue Excluding Tax] - [Previous Month Product Revenue]) 
                  / [Previous Month Product Revenue]) * 100
            ELSE NULL
        END AS [Product Revenue Growth %],
        
        CASE 
            WHEN [Previous Month Product Quantity] > 0
            THEN (([Product Quantity] - [Previous Month Product Quantity]) 
                  / [Previous Month Product Quantity]) * 100
            ELSE NULL
        END AS [Product Quantity Growth %],
        
        RANK() OVER (
            PARTITION BY [Calendar Month Year Label] 
            ORDER BY [Product Revenue Excluding Tax] DESC
        ) AS [Revenue Rank],
        
        RANK() OVER (
            PARTITION BY [Calendar Month Year Label] 
            ORDER BY [Product Margin %] DESC
        ) AS [Margin Rank],
        
        RANK() OVER (
            PARTITION BY [Calendar Month Year Label] 
            ORDER BY [Product Quantity] DESC
        ) AS [Quantity Rank],
        
        SUM([Product Revenue Excluding Tax]) OVER (PARTITION BY [Calendar Month Year Label]) AS [Total Monthly Revenue],
        
        LAG([Product Revenue Excluding Tax], 12) OVER (
            PARTITION BY [Product Name], [Product Color], [Product Brand] 
            ORDER BY [Calendar Year], [Calendar Month Number]
        ) AS [Same Month Last Year Revenue],
        
        LAG([Product Quantity], 12) OVER (
            PARTITION BY [Product Name], [Product Color], [Product Brand] 
            ORDER BY [Calendar Year], [Calendar Month Number]
        ) AS [Same Month Last Year Quantity]
        
    FROM ProductTrends
)
SELECT 
    [Calendar Month Year Label] AS [Month],
    [Product Name],
    [Product Brand],
    [Product Color],
    [Product Size],
    [Is Chiller Stock],
    [Lead Time Days],
    [Product Revenue Excluding Tax],
    [Product Profit],
    [Product Margin %],
    [Product Quantity],
    [Product Revenue Growth %],
    [Product Quantity Growth %],
    [Customer Count],
    [Invoice Count],
    [Revenue Per Unit],
    [Profit Per Unit],
    [Average Unit Price],
    [Revenue Rank],
    [Margin Rank],
    [Quantity Rank],
    [3Month Avg Product Revenue],
    [3Month Avg Product Quantity],
    
    CASE 
        WHEN [Total Monthly Revenue] > 0 
        THEN ([Product Revenue Excluding Tax] / [Total Monthly Revenue]) * 100 
        ELSE 0 
    END AS [Product Share %],
    
    CASE 
        WHEN [Same Month Last Year Revenue] > 0
        THEN (([Product Revenue Excluding Tax] - [Same Month Last Year Revenue]) 
              / [Same Month Last Year Revenue]) * 100
        ELSE NULL
    END AS [YoY Revenue Growth %],
    
    CASE 
        WHEN [Same Month Last Year Quantity] > 0
        THEN (([Product Quantity] - [Same Month Last Year Quantity]) 
              / [Same Month Last Year Quantity]) * 100
        ELSE NULL
    END AS [YoY Quantity Growth %]
    
FROM ProductRanking
WHERE [Revenue Rank] <= 50 -- Focus on top 50 products by revenue each month
ORDER BY [Calendar Year], [Calendar Month Number], [Revenue Rank];
