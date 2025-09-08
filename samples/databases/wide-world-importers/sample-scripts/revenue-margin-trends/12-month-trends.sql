
WITH MonthlyMetrics AS (
    SELECT 
        d.[Calendar Year] as [Year],
        d.[Calendar Month Number] as [Month],
        d.[Calendar Month Label] as [Month Label],
        d.[Calendar Month Year Label] as [Month Year Label],
        COUNT(s.[Sale Key]) as [Transaction Count],
        SUM(s.[Total Including Tax]) as [Revenue Including Tax],
        SUM(s.[Total Excluding Tax]) as [Revenue Excluding Tax],
        SUM(s.[Tax Amount]) as [Total Tax Amount],
        SUM(s.[Profit]) as [Total Profit],
        CASE 
            WHEN SUM(s.[Total Excluding Tax]) > 0 
            THEN (SUM(s.[Profit]) / SUM(s.[Total Excluding Tax])) * 100 
            ELSE 0 
        END as [Margin Percentage],
        AVG(s.[Unit Price]) as [Average Unit Price],
        SUM(s.[Quantity]) as [Total Quantity Sold]
    FROM [Fact].[Sale] s
    INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
    WHERE d.[Date] >= DATEADD(MONTH, -12, GETDATE())
        AND d.[Date] < DATEADD(MONTH, 0, GETDATE())
    GROUP BY 
        d.[Calendar Year], 
        d.[Calendar Month Number], 
        d.[Calendar Month Label],
        d.[Calendar Month Year Label]
),
RollingMetrics AS (
    SELECT *,
        SUM([Revenue Including Tax]) OVER (
            ORDER BY [Year], [Month] 
            ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
        ) as [Rolling 12M Revenue Including Tax],
        SUM([Total Profit]) OVER (
            ORDER BY [Year], [Month] 
            ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
        ) as [Rolling 12M Profit],
        LAG([Revenue Including Tax], 12) OVER (
            ORDER BY [Year], [Month]
        ) as [Revenue Same Month Last Year],
        LAG([Margin Percentage], 1) OVER (
            ORDER BY [Year], [Month]
        ) as [Previous Month Margin]
    FROM MonthlyMetrics
)
SELECT 
    [Year],
    [Month],
    [Month Label],
    [Month Year Label],
    [Transaction Count],
    FORMAT([Revenue Including Tax], 'C', 'en-US') as [Revenue Including Tax],
    FORMAT([Revenue Excluding Tax], 'C', 'en-US') as [Revenue Excluding Tax],
    FORMAT([Total Tax Amount], 'C', 'en-US') as [Total Tax Amount],
    FORMAT([Total Profit], 'C', 'en-US') as [Total Profit],
    FORMAT([Margin Percentage], 'N2') + '%' as [Margin Percentage],
    FORMAT([Average Unit Price], 'C', 'en-US') as [Average Unit Price],
    FORMAT([Total Quantity Sold], 'N0') as [Total Quantity Sold],
    FORMAT([Rolling 12M Revenue Including Tax], 'C', 'en-US') as [Rolling 12M Revenue],
    FORMAT([Rolling 12M Profit], 'C', 'en-US') as [Rolling 12M Profit],
    CASE 
        WHEN [Revenue Same Month Last Year] IS NOT NULL AND [Revenue Same Month Last Year] > 0
        THEN FORMAT((([Revenue Including Tax] - [Revenue Same Month Last Year]) / [Revenue Same Month Last Year]) * 100, 'N2') + '%'
        ELSE 'N/A'
    END as [YoY Revenue Growth],
    CASE 
        WHEN [Previous Month Margin] IS NOT NULL
        THEN FORMAT([Margin Percentage] - [Previous Month Margin], 'N2') + ' pp'
        ELSE 'N/A'
    END as [MoM Margin Change]
FROM RollingMetrics
ORDER BY [Year], [Month];

SELECT 
    d.[Calendar Year] as [Year],
    d.[Calendar Quarter Number] as [Quarter],
    d.[Calendar Quarter Label] as [Quarter Label],
    COUNT(s.[Sale Key]) as [Transaction Count],
    SUM(s.[Total Including Tax]) as [Revenue Including Tax],
    SUM(s.[Total Excluding Tax]) as [Revenue Excluding Tax],
    SUM(s.[Profit]) as [Total Profit],
    CASE 
        WHEN SUM(s.[Total Excluding Tax]) > 0 
        THEN (SUM(s.[Profit]) / SUM(s.[Total Excluding Tax])) * 100 
        ELSE 0 
    END as [Margin Percentage]
FROM [Fact].[Sale] s
INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
WHERE d.[Date] >= DATEADD(MONTH, -12, GETDATE())
    AND d.[Date] < DATEADD(MONTH, 0, GETDATE())
GROUP BY 
    d.[Calendar Year], 
    d.[Calendar Quarter Number], 
    d.[Calendar Quarter Label]
ORDER BY [Year], [Quarter];

SELECT TOP 20
    si.[Stock Item] as [Product Name],
    si.[Brand] as [Brand],
    si.[Size] as [Size],
    COUNT(s.[Sale Key]) as [Transaction Count],
    SUM(s.[Total Including Tax]) as [Revenue Including Tax],
    SUM(s.[Profit]) as [Total Profit],
    CASE 
        WHEN SUM(s.[Total Excluding Tax]) > 0 
        THEN (SUM(s.[Profit]) / SUM(s.[Total Excluding Tax])) * 100 
        ELSE 0 
    END as [Margin Percentage],
    AVG(s.[Unit Price]) as [Average Unit Price],
    SUM(s.[Quantity]) as [Total Quantity Sold]
FROM [Fact].[Sale] s
INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
INNER JOIN [Dimension].[Stock Item] si ON s.[Stock Item Key] = si.[Stock Item Key]
WHERE d.[Date] >= DATEADD(MONTH, -12, GETDATE())
    AND d.[Date] < DATEADD(MONTH, 0, GETDATE())
GROUP BY 
    si.[Stock Item],
    si.[Brand],
    si.[Size]
ORDER BY [Revenue Including Tax] DESC;

SELECT 
    c.[Sales Territory] as [Sales Territory],
    COUNT(s.[Sale Key]) as [Transaction Count],
    SUM(s.[Total Including Tax]) as [Revenue Including Tax],
    SUM(s.[Total Excluding Tax]) as [Revenue Excluding Tax],
    SUM(s.[Profit]) as [Total Profit],
    CASE 
        WHEN SUM(s.[Total Excluding Tax]) > 0 
        THEN (SUM(s.[Profit]) / SUM(s.[Total Excluding Tax])) * 100 
        ELSE 0 
    END as [Margin Percentage],
    AVG(s.[Unit Price]) as [Average Unit Price]
FROM [Fact].[Sale] s
INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
INNER JOIN [Dimension].[City] c ON s.[City Key] = c.[City Key]
WHERE d.[Date] >= DATEADD(MONTH, -12, GETDATE())
    AND d.[Date] < DATEADD(MONTH, 0, GETDATE())
GROUP BY c.[Sales Territory]
ORDER BY [Revenue Including Tax] DESC;

SELECT 
    d.[Date] as [Date],
    d.[Day of Week] as [Day of Week],
    COUNT(s.[Sale Key]) as [Transaction Count],
    SUM(s.[Total Including Tax]) as [Revenue Including Tax],
    SUM(s.[Profit]) as [Total Profit],
    CASE 
        WHEN SUM(s.[Total Excluding Tax]) > 0 
        THEN (SUM(s.[Profit]) / SUM(s.[Total Excluding Tax])) * 100 
        ELSE 0 
    END as [Margin Percentage]
FROM [Fact].[Sale] s
INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
WHERE d.[Date] >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
    AND d.[Date] < DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0)
GROUP BY 
    d.[Date],
    d.[Day of Week],
    d.[Day of Week Number]
ORDER BY d.[Date];
