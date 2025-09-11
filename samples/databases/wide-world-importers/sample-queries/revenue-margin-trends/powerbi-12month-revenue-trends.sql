
SELECT 
    d.[Calendar Year],
    d.[Calendar Month Number],
    d.[Calendar Month Label],
    d.[Calendar Quarter Number],
    d.[Quarter],
    
    SUM(s.[Total Including Tax]) as Revenue_Including_Tax,
    SUM(s.[Total Excluding Tax]) as Revenue_Excluding_Tax,
    SUM(s.[Tax Amount]) as Total_Tax_Amount,
    
    SUM(s.[Profit]) as Total_Margin,
    
    CASE 
        WHEN SUM(s.[Total Excluding Tax]) > 0 
        THEN (SUM(s.[Profit]) / SUM(s.[Total Excluding Tax])) * 100 
        ELSE 0 
    END as Margin_Percentage,
    
    COUNT(*) as Transaction_Count,
    SUM(s.[Quantity]) as Total_Quantity,
    
    AVG(s.[Total Including Tax]) as Avg_Transaction_Value,
    AVG(s.[Profit]) as Avg_Transaction_Margin,
    
    MIN(d.[Date]) as Period_Start_Date,
    MAX(d.[Date]) as Period_End_Date

FROM [Fact].[Sale] s
INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]

WHERE d.[Date] >= DATEADD(MONTH, -12, GETDATE())
  AND d.[Date] < GETDATE()

GROUP BY 
    d.[Calendar Year],
    d.[Calendar Month Number], 
    d.[Calendar Month Label],
    d.[Calendar Quarter Number],
    d.[Quarter]

ORDER BY 
    d.[Calendar Year], 
    d.[Calendar Month Number];


/*
SELECT 
    d.[Calendar Year],
    d.[Calendar Month Number],
    d.[Calendar Month Label],
    d.[Calendar Quarter Number],
    
    SUM(s.[Total Including Tax]) as Revenue_Including_Tax,
    SUM(s.[Total Excluding Tax]) as Revenue_Excluding_Tax,
    
    SUM(s.[Profit]) as Total_Margin,
    CASE 
        WHEN SUM(s.[Total Excluding Tax]) > 0 
        THEN (SUM(s.[Profit]) / SUM(s.[Total Excluding Tax])) * 100 
        ELSE 0 
    END as Margin_Percentage,
    
    COUNT(*) as Transaction_Count,
    SUM(s.[Quantity]) as Total_Quantity

FROM [Fact].[Sale] s
INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]

WHERE d.[Date] >= '2016-01-01'
  AND d.[Date] < '2017-01-01'

GROUP BY 
    d.[Calendar Year],
    d.[Calendar Month Number], 
    d.[Calendar Month Label],
    d.[Calendar Quarter Number]

ORDER BY 
    d.[Calendar Year], 
    d.[Calendar Month Number];
*/


SELECT 
    d.[Calendar Year],
    d.[Calendar Quarter Number],
    d.[Calendar Quarter Label],
    
    SUM(s.[Total Including Tax]) as Quarterly_Revenue_Including_Tax,
    SUM(s.[Total Excluding Tax]) as Quarterly_Revenue_Excluding_Tax,
    
    SUM(s.[Profit]) as Quarterly_Margin,
    CASE 
        WHEN SUM(s.[Total Excluding Tax]) > 0 
        THEN (SUM(s.[Profit]) / SUM(s.[Total Excluding Tax])) * 100 
        ELSE 0 
    END as Quarterly_Margin_Percentage,
    
    COUNT(*) as Quarterly_Transaction_Count,
    SUM(s.[Quantity]) as Quarterly_Total_Quantity

FROM [Fact].[Sale] s
INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]

WHERE d.[Date] >= DATEADD(MONTH, -12, GETDATE())
  AND d.[Date] < GETDATE()

GROUP BY 
    d.[Calendar Year],
    d.[Calendar Quarter Number],
    d.[Calendar Quarter Label]

ORDER BY 
    d.[Calendar Year], 
    d.[Calendar Quarter Number];
