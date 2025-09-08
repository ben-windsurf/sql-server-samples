

WITH MonthlyTrends AS (
    SELECT 
        d.[Calendar Year] AS [Year],
        d.[Calendar Month Number] AS [Month Number],
        d.[Calendar Month Label] AS [Month Label],
        d.[Calendar Month Year Label] AS [Month Year],
        d.[Beginning of Month] AS [Month Start Date],
        
        SUM(s.[Total Excluding Tax]) AS [Revenue Excluding Tax],
        SUM(s.[Total Including Tax]) AS [Revenue Including Tax],
        SUM(s.[Tax Amount]) AS [Total Tax Amount],
        
        SUM(s.[Profit]) AS [Total Profit],
        
        SUM(s.[Quantity]) AS [Total Quantity],
        COUNT(*) AS [Transaction Count],
        
        CASE 
            WHEN SUM(s.[Total Excluding Tax]) > 0 
            THEN (SUM(s.[Profit]) / SUM(s.[Total Excluding Tax])) * 100 
            ELSE 0 
        END AS [Profit Margin Percentage],
        
        AVG(s.[Total Excluding Tax]) AS [Average Transaction Value],
        AVG(s.[Profit]) AS [Average Transaction Profit]
        
    FROM [Fact].[Sale] s
    INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
    WHERE 
        d.[Date] >= DATEADD(MONTH, -12, GETDATE())
        AND d.[Date] < GETDATE()
    GROUP BY 
        d.[Calendar Year],
        d.[Calendar Month Number],
        d.[Calendar Month Label],
        d.[Calendar Month Year Label],
        d.[Beginning of Month]
),

PreviousYearTrends AS (
    SELECT 
        d.[Calendar Year] AS [Previous Year],
        d.[Calendar Month Number] AS [Month Number],
        SUM(s.[Total Excluding Tax]) AS [Previous Year Revenue Excluding Tax],
        SUM(s.[Total Including Tax]) AS [Previous Year Revenue Including Tax],
        SUM(s.[Profit]) AS [Previous Year Profit],
        CASE 
            WHEN SUM(s.[Total Excluding Tax]) > 0 
            THEN (SUM(s.[Profit]) / SUM(s.[Total Excluding Tax])) * 100 
            ELSE 0 
        END AS [Previous Year Profit Margin Percentage]
        
    FROM [Fact].[Sale] s
    INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
    WHERE 
        d.[Date] >= DATEADD(MONTH, -24, GETDATE())
        AND d.[Date] < DATEADD(MONTH, -12, GETDATE())
    GROUP BY 
        d.[Calendar Year],
        d.[Calendar Month Number]
)

SELECT 
    mt.[Year],
    mt.[Month Number],
    mt.[Month Label],
    mt.[Month Year],
    mt.[Month Start Date],
    
    mt.[Revenue Excluding Tax],
    mt.[Revenue Including Tax],
    mt.[Total Tax Amount],
    mt.[Total Profit],
    mt.[Profit Margin Percentage],
    mt.[Total Quantity],
    mt.[Transaction Count],
    mt.[Average Transaction Value],
    mt.[Average Transaction Profit],
    
    pyt.[Previous Year Revenue Excluding Tax],
    pyt.[Previous Year Revenue Including Tax],
    pyt.[Previous Year Profit],
    pyt.[Previous Year Profit Margin Percentage],
    
    CASE 
        WHEN pyt.[Previous Year Revenue Excluding Tax] > 0 
        THEN ((mt.[Revenue Excluding Tax] - pyt.[Previous Year Revenue Excluding Tax]) / pyt.[Previous Year Revenue Excluding Tax]) * 100
        ELSE NULL 
    END AS [Revenue Growth Percentage],
    
    CASE 
        WHEN pyt.[Previous Year Profit] > 0 
        THEN ((mt.[Total Profit] - pyt.[Previous Year Profit]) / pyt.[Previous Year Profit]) * 100
        ELSE NULL 
    END AS [Profit Growth Percentage],
    
    (mt.[Profit Margin Percentage] - pyt.[Previous Year Profit Margin Percentage]) AS [Margin Improvement Points]
    
FROM MonthlyTrends mt
LEFT JOIN PreviousYearTrends pyt ON mt.[Month Number] = pyt.[Month Number]
ORDER BY 
    mt.[Year], 
    mt.[Month Number];
