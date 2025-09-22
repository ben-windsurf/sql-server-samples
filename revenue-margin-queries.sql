
WITH MonthlyTrends AS (
    SELECT 
        d.[Calendar Year] as Year,
        d.[Calendar Month Number] as Month,
        d.[Calendar Month Label] as MonthLabel,
        d.[Calendar Month Year Label] as MonthYear,
        SUM(s.[Total Excluding Tax]) as Revenue,
        SUM(s.[Profit]) as Margin,
        COUNT(*) as TransactionCount,
        AVG(s.[Unit Price]) as AvgUnitPrice
    FROM [Fact].[Sale] s
    INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
    WHERE d.[Date] >= DATEADD(MONTH, -12, GETDATE())
        AND d.[Date] < GETDATE()
    GROUP BY 
        d.[Calendar Year],
        d.[Calendar Month Number],
        d.[Calendar Month Label],
        d.[Calendar Month Year Label]
)
SELECT 
    Year,
    Month,
    MonthLabel,
    MonthYear,
    Revenue,
    Margin,
    CASE 
        WHEN Revenue > 0 THEN (Margin / Revenue) * 100 
        ELSE 0 
    END as MarginPercentage,
    TransactionCount,
    AvgUnitPrice,
    LAG(Revenue, 1) OVER (ORDER BY Year, Month) as PrevMonthRevenue,
    LAG(Margin, 1) OVER (ORDER BY Year, Month) as PrevMonthMargin,
    CASE 
        WHEN LAG(Revenue, 1) OVER (ORDER BY Year, Month) > 0 
        THEN ((Revenue - LAG(Revenue, 1) OVER (ORDER BY Year, Month)) / LAG(Revenue, 1) OVER (ORDER BY Year, Month)) * 100
        ELSE 0 
    END as RevenueGrowthPercent,
    CASE 
        WHEN LAG(Margin, 1) OVER (ORDER BY Year, Month) > 0 
        THEN ((Margin - LAG(Margin, 1) OVER (ORDER BY Year, Month)) / LAG(Margin, 1) OVER (ORDER BY Year, Month)) * 100
        ELSE 0 
    END as MarginGrowthPercent
FROM MonthlyTrends
ORDER BY Year, Month;

WITH QuarterlyTrends AS (
    SELECT 
        d.[Calendar Year] as Year,
        d.[Calendar Quarter Number] as Quarter,
        d.[Calendar Quarter Label] as QuarterLabel,
        SUM(s.[Total Excluding Tax]) as Revenue,
        SUM(s.[Profit]) as Margin,
        COUNT(*) as TransactionCount
    FROM [Fact].[Sale] s
    INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
    WHERE d.[Date] >= DATEADD(MONTH, -12, GETDATE())
        AND d.[Date] < GETDATE()
    GROUP BY 
        d.[Calendar Year],
        d.[Calendar Quarter Number],
        d.[Calendar Quarter Label]
)
SELECT 
    Year,
    Quarter,
    QuarterLabel,
    Revenue,
    Margin,
    CASE 
        WHEN Revenue > 0 THEN (Margin / Revenue) * 100 
        ELSE 0 
    END as MarginPercentage,
    TransactionCount
FROM QuarterlyTrends
ORDER BY Year, Quarter;

SELECT TOP 10
    si.[Stock Item] as ProductName,
    SUM(s.[Total Excluding Tax]) as TotalRevenue,
    SUM(s.[Profit]) as TotalMargin,
    CASE 
        WHEN SUM(s.[Total Excluding Tax]) > 0 
        THEN (SUM(s.[Profit]) / SUM(s.[Total Excluding Tax])) * 100 
        ELSE 0 
    END as MarginPercentage,
    COUNT(*) as SalesCount
FROM [Fact].[Sale] s
INNER JOIN [Dimension].[Stock Item] si ON s.[Stock Item Key] = si.[Stock Item Key]
INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
WHERE d.[Date] >= DATEADD(MONTH, -12, GETDATE())
    AND d.[Date] < GETDATE()
GROUP BY si.[Stock Item]
ORDER BY TotalRevenue DESC;

SELECT TOP 10
    c.[Customer] as CustomerName,
    SUM(s.[Total Excluding Tax]) as TotalRevenue,
    SUM(s.[Profit]) as TotalMargin,
    CASE 
        WHEN SUM(s.[Total Excluding Tax]) > 0 
        THEN (SUM(s.[Profit]) / SUM(s.[Total Excluding Tax])) * 100 
        ELSE 0 
    END as MarginPercentage,
    COUNT(*) as OrderCount
FROM [Fact].[Sale] s
INNER JOIN [Dimension].[Customer] c ON s.[Customer Key] = c.[Customer Key]
INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
WHERE d.[Date] >= DATEADD(MONTH, -12, GETDATE())
    AND d.[Date] < GETDATE()
GROUP BY c.[Customer]
ORDER BY TotalRevenue DESC;
