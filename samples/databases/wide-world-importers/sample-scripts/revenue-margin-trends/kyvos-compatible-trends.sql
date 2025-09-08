

SELECT 
    d.[Calendar Year] AS [Year],
    d.[Calendar Quarter Number] AS [Quarter],
    d.[Calendar Quarter Label] AS [QuarterLabel],
    d.[Calendar Month Number] AS [Month],
    d.[Calendar Month Label] AS [MonthLabel],
    d.[Beginning of Month] AS [MonthStartDate],
    
    c.[Sales Territory] AS [Territory],
    c.[City] AS [City],
    c.[Customer] AS [Customer],
    c.[Category] AS [CustomerCategory],
    
    si.[Brand] AS [Brand],
    si.[Stock Item] AS [Product],
    si.[Color] AS [Color],
    
    SUM(s.[Total Excluding Tax]) AS [Sales_Total_Excluding_Tax],
    SUM(s.[Total Including Tax]) AS [Sales_Total_Including_Tax],
    SUM(s.[Tax Amount]) AS [Sales_Tax_Amount],
    SUM(s.[Profit]) AS [Sales_Profit],
    SUM(s.[Quantity]) AS [Sales_Quantity],
    COUNT(*) AS [Sales_Count],
    
    AVG(s.[Unit Price]) AS [Average_Unit_Price],
    AVG(s.[Total Excluding Tax]) AS [Average_Sale_Value],
    
    CASE 
        WHEN SUM(s.[Total Excluding Tax]) > 0 
        THEN (SUM(s.[Profit]) / SUM(s.[Total Excluding Tax])) * 100 
        ELSE 0 
    END AS [Profit_Margin_Percentage],
    
    SUM(s.[Total Excluding Tax]) - SUM(s.[Profit]) AS [Total_Cost],
    
    CASE 
        WHEN SUM(s.[Quantity]) > 0 
        THEN SUM(s.[Profit]) / SUM(s.[Quantity]) 
        ELSE 0 
    END AS [Profit_Per_Unit]
    
FROM [Fact].[Sale] s
INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
INNER JOIN [Dimension].[Customer] c ON s.[Customer Key] = c.[Customer Key]
INNER JOIN [Dimension].[Stock Item] si ON s.[Stock Item Key] = si.[Stock Item Key]
WHERE 
    d.[Date] >= DATEADD(MONTH, -12, GETDATE())
    AND d.[Date] < GETDATE()
GROUP BY 
    d.[Calendar Year],
    d.[Calendar Quarter Number],
    d.[Calendar Quarter Label],
    d.[Calendar Month Number],
    d.[Calendar Month Label],
    d.[Beginning of Month],
    c.[Sales Territory],
    c.[City],
    c.[Customer],
    c.[Category],
    si.[Brand],
    si.[Stock Item],
    si.[Color]
ORDER BY 
    d.[Calendar Year],
    d.[Calendar Quarter Number],
    d.[Calendar Month Number],
    c.[Sales Territory],
    c.[City],
    si.[Brand];


WITH YTD_Calculations AS (
    SELECT 
        d.[Calendar Year] AS [Year],
        d.[Calendar Month Number] AS [Month],
        d.[Calendar Month Label] AS [MonthLabel],
        
        SUM(SUM(s.[Total Excluding Tax])) OVER (
            PARTITION BY d.[Calendar Year] 
            ORDER BY d.[Calendar Month Number] 
            ROWS UNBOUNDED PRECEDING
        ) AS [Sales_Total_Excluding_Tax_YTD],
        
        SUM(SUM(s.[Profit])) OVER (
            PARTITION BY d.[Calendar Year] 
            ORDER BY d.[Calendar Month Number] 
            ROWS UNBOUNDED PRECEDING
        ) AS [Sales_Profit_YTD],
        
        SUM(s.[Total Excluding Tax]) AS [Sales_Total_Excluding_Tax_Current],
        SUM(s.[Profit]) AS [Sales_Profit_Current],
        
        LAG(SUM(s.[Total Excluding Tax]), 12) OVER (
            ORDER BY d.[Calendar Year], d.[Calendar Month Number]
        ) AS [Sales_Total_Excluding_Tax_Previous_Year],
        
        LAG(SUM(s.[Profit]), 12) OVER (
            ORDER BY d.[Calendar Year], d.[Calendar Month Number]
        ) AS [Sales_Profit_Previous_Year]
        
    FROM [Fact].[Sale] s
    INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
    WHERE 
        d.[Date] >= DATEADD(MONTH, -24, GETDATE())
        AND d.[Date] < GETDATE()
    GROUP BY 
        d.[Calendar Year],
        d.[Calendar Month Number],
        d.[Calendar Month Label]
)

SELECT 
    [Year],
    [Month],
    [MonthLabel],
    
    [Sales_Total_Excluding_Tax_Current],
    [Sales_Profit_Current],
    
    [Sales_Total_Excluding_Tax_YTD],
    [Sales_Profit_YTD],
    
    [Sales_Total_Excluding_Tax_Previous_Year],
    [Sales_Profit_Previous_Year],
    
    CASE 
        WHEN [Sales_Total_Excluding_Tax_Previous_Year] > 0 
        THEN (([Sales_Total_Excluding_Tax_Current] - [Sales_Total_Excluding_Tax_Previous_Year]) / [Sales_Total_Excluding_Tax_Previous_Year]) * 100
        ELSE NULL 
    END AS [Revenue_Growth_Percentage],
    
    CASE 
        WHEN [Sales_Profit_Previous_Year] > 0 
        THEN (([Sales_Profit_Current] - [Sales_Profit_Previous_Year]) / [Sales_Profit_Previous_Year]) * 100
        ELSE NULL 
    END AS [Profit_Growth_Percentage],
    
    CASE 
        WHEN [Sales_Total_Excluding_Tax_Current] > 0 
        THEN ([Sales_Profit_Current] / [Sales_Total_Excluding_Tax_Current]) * 100 
        ELSE 0 
    END AS [Current_Profit_Margin_Percentage],
    
    CASE 
        WHEN [Sales_Total_Excluding_Tax_YTD] > 0 
        THEN ([Sales_Profit_YTD] / [Sales_Total_Excluding_Tax_YTD]) * 100 
        ELSE 0 
    END AS [YTD_Profit_Margin_Percentage]
    
FROM YTD_Calculations
WHERE [Year] >= YEAR(DATEADD(MONTH, -12, GETDATE()))
ORDER BY [Year], [Month];
