
WITH MonthlyMetrics AS (
    SELECT 
        d.[Calendar Year],
        d.[Calendar Month Number],
        d.[Calendar Month Label],
        
        SUM(s.[Total Including Tax]) as Revenue_Including_Tax,
        SUM(s.[Total Excluding Tax]) as Revenue_Excluding_Tax,
        SUM(s.[Profit]) as Total_Margin,
        COUNT(*) as Transaction_Count,
        
        CASE 
            WHEN SUM(s.[Total Excluding Tax]) > 0 
            THEN (SUM(s.[Profit]) / SUM(s.[Total Excluding Tax])) * 100 
            ELSE 0 
        END as Margin_Percentage

    FROM [Fact].[Sale] s
    INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
    
    WHERE d.[Date] >= DATEADD(YEAR, -2, GETDATE())
      AND d.[Date] < GETDATE()
    
    GROUP BY 
        d.[Calendar Year],
        d.[Calendar Month Number], 
        d.[Calendar Month Label]
),

YoYComparison AS (
    SELECT 
        curr.[Calendar Year],
        curr.[Calendar Month Number],
        curr.[Calendar Month Label],
        
        curr.Revenue_Including_Tax as Current_Revenue_Including_Tax,
        curr.Revenue_Excluding_Tax as Current_Revenue_Excluding_Tax,
        curr.Total_Margin as Current_Margin,
        curr.Margin_Percentage as Current_Margin_Percentage,
        curr.Transaction_Count as Current_Transaction_Count,
        
        prev.Revenue_Including_Tax as Previous_Revenue_Including_Tax,
        prev.Revenue_Excluding_Tax as Previous_Revenue_Excluding_Tax,
        prev.Total_Margin as Previous_Margin,
        prev.Margin_Percentage as Previous_Margin_Percentage,
        prev.Transaction_Count as Previous_Transaction_Count,
        
        CASE 
            WHEN prev.Revenue_Including_Tax > 0 
            THEN ((curr.Revenue_Including_Tax - prev.Revenue_Including_Tax) / prev.Revenue_Including_Tax) * 100
            ELSE NULL 
        END as Revenue_Growth_Percentage,
        
        CASE 
            WHEN prev.Total_Margin > 0 
            THEN ((curr.Total_Margin - prev.Total_Margin) / prev.Total_Margin) * 100
            ELSE NULL 
        END as Margin_Growth_Percentage,
        
        curr.Revenue_Including_Tax - prev.Revenue_Including_Tax as Revenue_Change_Amount,
        curr.Total_Margin - prev.Total_Margin as Margin_Change_Amount,
        curr.Margin_Percentage - prev.Margin_Percentage as Margin_Percentage_Change

    FROM MonthlyMetrics curr
    LEFT JOIN MonthlyMetrics prev 
        ON curr.[Calendar Month Number] = prev.[Calendar Month Number]
        AND curr.[Calendar Year] = prev.[Calendar Year] + 1
)

SELECT 
    [Calendar Year],
    [Calendar Month Number],
    [Calendar Month Label],
    
    Current_Revenue_Including_Tax,
    Current_Revenue_Excluding_Tax,
    Current_Margin,
    Current_Margin_Percentage,
    Current_Transaction_Count,
    
    Previous_Revenue_Including_Tax,
    Previous_Revenue_Excluding_Tax,
    Previous_Margin,
    Previous_Margin_Percentage,
    Previous_Transaction_Count,
    
    Revenue_Growth_Percentage,
    Margin_Growth_Percentage,
    Revenue_Change_Amount,
    Margin_Change_Amount,
    Margin_Percentage_Change,
    
    CASE 
        WHEN Revenue_Growth_Percentage > 0 THEN 'Growth'
        WHEN Revenue_Growth_Percentage < 0 THEN 'Decline'
        ELSE 'Flat'
    END as Revenue_Trend,
    
    CASE 
        WHEN Margin_Growth_Percentage > 0 THEN 'Improving'
        WHEN Margin_Growth_Percentage < 0 THEN 'Declining'
        ELSE 'Stable'
    END as Margin_Trend

FROM YoYComparison

WHERE [Calendar Year] = (SELECT MAX([Calendar Year]) FROM YoYComparison)

ORDER BY [Calendar Year], [Calendar Month Number];


WITH Rolling12Months AS (
    SELECT 
        'Current 12 Months' as Period_Label,
        SUM(s.[Total Including Tax]) as Revenue_Including_Tax,
        SUM(s.[Total Excluding Tax]) as Revenue_Excluding_Tax,
        SUM(s.[Profit]) as Total_Margin,
        COUNT(*) as Transaction_Count,
        CASE 
            WHEN SUM(s.[Total Excluding Tax]) > 0 
            THEN (SUM(s.[Profit]) / SUM(s.[Total Excluding Tax])) * 100 
            ELSE 0 
        END as Margin_Percentage

    FROM [Fact].[Sale] s
    INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
    WHERE d.[Date] >= DATEADD(MONTH, -12, GETDATE())
      AND d.[Date] < GETDATE()

    UNION ALL

    SELECT 
        'Previous 12 Months' as Period_Label,
        SUM(s.[Total Including Tax]) as Revenue_Including_Tax,
        SUM(s.[Total Excluding Tax]) as Revenue_Excluding_Tax,
        SUM(s.[Profit]) as Total_Margin,
        COUNT(*) as Transaction_Count,
        CASE 
            WHEN SUM(s.[Total Excluding Tax]) > 0 
            THEN (SUM(s.[Profit]) / SUM(s.[Total Excluding Tax])) * 100 
            ELSE 0 
        END as Margin_Percentage

    FROM [Fact].[Sale] s
    INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
    WHERE d.[Date] >= DATEADD(MONTH, -24, GETDATE())
      AND d.[Date] < DATEADD(MONTH, -12, GETDATE())
)

SELECT 
    Period_Label,
    Revenue_Including_Tax,
    Revenue_Excluding_Tax,
    Total_Margin,
    Margin_Percentage,
    Transaction_Count,
    
    Revenue_Including_Tax / NULLIF(Transaction_Count, 0) as Avg_Revenue_Per_Transaction,
    Total_Margin / NULLIF(Transaction_Count, 0) as Avg_Margin_Per_Transaction

FROM Rolling12Months
ORDER BY Period_Label DESC;
