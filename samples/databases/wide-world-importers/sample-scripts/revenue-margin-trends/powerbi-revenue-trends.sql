

SELECT 
    d.[Date] AS [Date],
    d.[Calendar Year] AS [Year],
    d.[Calendar Quarter Number] AS [Quarter],
    d.[Calendar Month Number] AS [Month],
    d.[Calendar Month Label] AS [MonthName],
    d.[Calendar Month Year Label] AS [MonthYear],
    d.[Calendar Week Number] AS [Week],
    
    c.[Customer] AS [Customer],
    c.[Category] AS [CustomerCategory],
    c.[City] AS [CustomerCity],
    si.[Stock Item] AS [Product],
    si.[Brand] AS [ProductBrand],
    si.[Color] AS [ProductColor],
    
    s.[Total Excluding Tax] AS [Revenue],
    s.[Total Including Tax] AS [RevenueWithTax],
    s.[Tax Amount] AS [TaxAmount],
    s.[Profit] AS [Profit],
    s.[Quantity] AS [Quantity],
    s.[Unit Price] AS [UnitPrice],
    
    CASE 
        WHEN s.[Total Excluding Tax] > 0 
        THEN (s.[Profit] / s.[Total Excluding Tax]) * 100 
        ELSE 0 
    END AS [ProfitMarginPercent],
    
    s.[Total Excluding Tax] - s.[Profit] AS [Cost],
    
    CASE 
        WHEN s.[Quantity] > 0 
        THEN s.[Profit] / s.[Quantity] 
        ELSE 0 
    END AS [ProfitPerUnit],
    
    CASE 
        WHEN d.[Date] >= DATEADD(MONTH, -1, GETDATE()) THEN 'Current Month'
        WHEN d.[Date] >= DATEADD(MONTH, -3, GETDATE()) THEN 'Last 3 Months'
        WHEN d.[Date] >= DATEADD(MONTH, -6, GETDATE()) THEN 'Last 6 Months'
        WHEN d.[Date] >= DATEADD(MONTH, -12, GETDATE()) THEN 'Last 12 Months'
        ELSE 'Older'
    END AS [TimePeriod],
    
    CASE 
        WHEN s.[Profit] > 0 THEN 'Profitable'
        WHEN s.[Profit] = 0 THEN 'Break Even'
        ELSE 'Loss'
    END AS [ProfitabilityStatus],
    
    CASE 
        WHEN (s.[Profit] / s.[Total Excluding Tax]) * 100 >= 20 THEN 'High Margin (20%+)'
        WHEN (s.[Profit] / s.[Total Excluding Tax]) * 100 >= 10 THEN 'Medium Margin (10-20%)'
        WHEN (s.[Profit] / s.[Total Excluding Tax]) * 100 >= 0 THEN 'Low Margin (0-10%)'
        ELSE 'Negative Margin'
    END AS [MarginCategory]
    
FROM [Fact].[Sale] s
INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
INNER JOIN [Dimension].[Customer] c ON s.[Customer Key] = c.[Customer Key]
INNER JOIN [Dimension].[Stock Item] si ON s.[Stock Item Key] = si.[Stock Item Key]
WHERE 
    d.[Date] >= DATEADD(MONTH, -24, GETDATE())
    AND d.[Date] < GETDATE()
ORDER BY 
    d.[Date] DESC;


SELECT 
    'Summary Metrics' AS [MetricType],
    
    SUM(CASE WHEN d.[Date] >= DATEADD(MONTH, -1, GETDATE()) THEN s.[Total Excluding Tax] ELSE 0 END) AS [CurrentMonthRevenue],
    SUM(CASE WHEN d.[Date] >= DATEADD(MONTH, -1, GETDATE()) THEN s.[Profit] ELSE 0 END) AS [CurrentMonthProfit],
    
    SUM(CASE WHEN d.[Date] >= DATEADD(MONTH, -12, GETDATE()) THEN s.[Total Excluding Tax] ELSE 0 END) AS [Last12MonthsRevenue],
    SUM(CASE WHEN d.[Date] >= DATEADD(MONTH, -12, GETDATE()) THEN s.[Profit] ELSE 0 END) AS [Last12MonthsProfit],
    
    SUM(CASE WHEN d.[Date] >= DATEADD(MONTH, -24, GETDATE()) AND d.[Date] < DATEADD(MONTH, -12, GETDATE()) THEN s.[Total Excluding Tax] ELSE 0 END) AS [Previous12MonthsRevenue],
    SUM(CASE WHEN d.[Date] >= DATEADD(MONTH, -24, GETDATE()) AND d.[Date] < DATEADD(MONTH, -12, GETDATE()) THEN s.[Profit] ELSE 0 END) AS [Previous12MonthsProfit],
    
    CASE 
        WHEN SUM(CASE WHEN d.[Date] >= DATEADD(MONTH, -24, GETDATE()) AND d.[Date] < DATEADD(MONTH, -12, GETDATE()) THEN s.[Total Excluding Tax] ELSE 0 END) > 0
        THEN ((SUM(CASE WHEN d.[Date] >= DATEADD(MONTH, -12, GETDATE()) THEN s.[Total Excluding Tax] ELSE 0 END) - 
               SUM(CASE WHEN d.[Date] >= DATEADD(MONTH, -24, GETDATE()) AND d.[Date] < DATEADD(MONTH, -12, GETDATE()) THEN s.[Total Excluding Tax] ELSE 0 END)) /
               SUM(CASE WHEN d.[Date] >= DATEADD(MONTH, -24, GETDATE()) AND d.[Date] < DATEADD(MONTH, -12, GETDATE()) THEN s.[Total Excluding Tax] ELSE 0 END)) * 100
        ELSE 0
    END AS [RevenueGrowthPercent],
    
    CASE 
        WHEN SUM(CASE WHEN d.[Date] >= DATEADD(MONTH, -12, GETDATE()) THEN s.[Total Excluding Tax] ELSE 0 END) > 0
        THEN (SUM(CASE WHEN d.[Date] >= DATEADD(MONTH, -12, GETDATE()) THEN s.[Profit] ELSE 0 END) / 
              SUM(CASE WHEN d.[Date] >= DATEADD(MONTH, -12, GETDATE()) THEN s.[Total Excluding Tax] ELSE 0 END)) * 100
        ELSE 0
    END AS [AverageMarginPercent]
    
FROM [Fact].[Sale] s
INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
WHERE 
    d.[Date] >= DATEADD(MONTH, -24, GETDATE())
    AND d.[Date] < GETDATE();
