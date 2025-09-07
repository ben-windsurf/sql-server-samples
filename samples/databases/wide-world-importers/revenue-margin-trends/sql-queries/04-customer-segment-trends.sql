
WITH CustomerSegmentRevenue AS (
    SELECT 
        d.[Calendar Month Year Label],
        d.[Calendar Year],
        d.[Calendar Month Number],
        c.[Customer Category] AS [Customer Segment],
        c.[Buying Group] AS [Buying Group],
        city.[State Province] AS [State Province],
        city.[Sales Territory] AS [Sales Territory],
        
        SUM(s.[Total Excluding Tax]) AS [Segment Revenue Excluding Tax],
        SUM(s.[Total Including Tax]) AS [Segment Revenue Including Tax],
        SUM(s.[Profit]) AS [Segment Profit],
        SUM(s.[Quantity]) AS [Segment Quantity],
        
        COUNT(DISTINCT s.[Customer Key]) AS [Active Customers],
        COUNT(DISTINCT s.[WWI Invoice ID]) AS [Invoice Count],
        AVG(s.[Unit Price]) AS [Average Unit Price],
        
        SUM(s.[Total Excluding Tax]) / NULLIF(COUNT(DISTINCT s.[Customer Key]), 0) AS [Revenue Per Customer],
        SUM(s.[Profit]) / NULLIF(COUNT(DISTINCT s.[Customer Key]), 0) AS [Profit Per Customer]
        
    FROM [Fact].[Sale] s
    INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
    INNER JOIN [Dimension].[Customer] c ON s.[Customer Key] = c.[Customer Key]
    INNER JOIN [Dimension].[City] city ON s.[City Key] = city.[City Key]
    WHERE d.[Date] >= DATEADD(MONTH, -12, GETDATE())
      AND d.[Date] < GETDATE()
    GROUP BY 
        d.[Calendar Month Year Label],
        d.[Calendar Year],
        d.[Calendar Month Number],
        c.[Customer Category],
        c.[Buying Group],
        city.[State Province],
        city.[Sales Territory]
),
SegmentTrends AS (
    SELECT *,
        CASE 
            WHEN [Segment Revenue Excluding Tax] > 0 
            THEN ([Segment Profit] / [Segment Revenue Excluding Tax]) * 100 
            ELSE 0 
        END AS [Segment Margin %],
        
        LAG([Segment Revenue Excluding Tax], 1) OVER (
            PARTITION BY [Customer Segment], [Buying Group], [State Province] 
            ORDER BY [Calendar Year], [Calendar Month Number]
        ) AS [Previous Month Segment Revenue],
        
        LAG([Segment Profit], 1) OVER (
            PARTITION BY [Customer Segment], [Buying Group], [State Province] 
            ORDER BY [Calendar Year], [Calendar Month Number]
        ) AS [Previous Month Segment Profit],
        
        AVG([Segment Revenue Excluding Tax]) OVER (
            PARTITION BY [Customer Segment], [Buying Group], [State Province] 
            ORDER BY [Calendar Year], [Calendar Month Number] 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS [3Month Avg Segment Revenue],
        
        AVG([Segment Profit]) OVER (
            PARTITION BY [Customer Segment], [Buying Group], [State Province] 
            ORDER BY [Calendar Year], [Calendar Month Number] 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS [3Month Avg Segment Profit]
        
    FROM CustomerSegmentRevenue
),
SegmentRanking AS (
    SELECT *,
        CASE 
            WHEN [Previous Month Segment Revenue] > 0
            THEN (([Segment Revenue Excluding Tax] - [Previous Month Segment Revenue]) 
                  / [Previous Month Segment Revenue]) * 100
            ELSE NULL
        END AS [Segment Revenue Growth %],
        
        RANK() OVER (
            PARTITION BY [Calendar Month Year Label] 
            ORDER BY [Segment Revenue Excluding Tax] DESC
        ) AS [Revenue Rank],
        
        RANK() OVER (
            PARTITION BY [Calendar Month Year Label] 
            ORDER BY [Segment Margin %] DESC
        ) AS [Margin Rank],
        
        SUM([Segment Revenue Excluding Tax]) OVER (PARTITION BY [Calendar Month Year Label]) AS [Total Monthly Revenue],
        
        LAG([Segment Revenue Excluding Tax], 12) OVER (
            PARTITION BY [Customer Segment], [Buying Group], [State Province] 
            ORDER BY [Calendar Year], [Calendar Month Number]
        ) AS [Same Month Last Year Revenue]
        
    FROM SegmentTrends
)
SELECT 
    [Calendar Month Year Label] AS [Month],
    [Customer Segment],
    [Buying Group],
    [State Province],
    [Sales Territory],
    [Segment Revenue Excluding Tax],
    [Segment Profit],
    [Segment Margin %],
    [Segment Revenue Growth %],
    [Active Customers],
    [Revenue Per Customer],
    [Profit Per Customer],
    [Invoice Count],
    [Average Unit Price],
    [Revenue Rank],
    [Margin Rank],
    [3Month Avg Segment Revenue],
    [3Month Avg Segment Profit],
    
    CASE 
        WHEN [Total Monthly Revenue] > 0 
        THEN ([Segment Revenue Excluding Tax] / [Total Monthly Revenue]) * 100 
        ELSE 0 
    END AS [Segment Share %],
    
    CASE 
        WHEN [Same Month Last Year Revenue] > 0
        THEN (([Segment Revenue Excluding Tax] - [Same Month Last Year Revenue]) 
              / [Same Month Last Year Revenue]) * 100
        ELSE NULL
    END AS [YoY Revenue Growth %]
    
FROM SegmentRanking
ORDER BY [Calendar Year], [Calendar Month Number], [Revenue Rank];
