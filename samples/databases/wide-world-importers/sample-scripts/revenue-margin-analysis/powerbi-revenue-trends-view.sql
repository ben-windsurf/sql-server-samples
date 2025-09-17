
CREATE VIEW [dbo].[vw_PowerBI_RevenueMarginTrends]
AS
SELECT 
    d.[Date] AS SalesDate,
    d.[Calendar Year] AS Year,
    d.[Calendar Month Number] AS MonthNum,
    d.[Calendar Month Label] AS Month,
    d.[Calendar Quarter Label] AS Quarter,
    d.[Calendar Month Year Label] AS MonthYear,
    
    SUM(s.[Total Excluding Tax]) AS Revenue,
    SUM(s.[Total Including Tax]) AS RevenueWithTax,
    SUM(s.[Profit]) AS Profit,
    SUM(s.[Tax Amount]) AS TaxAmount,
    
    CASE 
        WHEN SUM(s.[Total Excluding Tax]) > 0 
        THEN (SUM(s.[Profit]) / SUM(s.[Total Excluding Tax])) * 100.0 
        ELSE 0 
    END AS MarginPercent,
    
    SUM(s.[Quantity]) AS QuantitySold,
    COUNT(DISTINCT s.[WWI Invoice ID]) AS InvoiceCount,
    COUNT(DISTINCT s.[Customer Key]) AS CustomerCount,
    
    AVG(s.[Total Excluding Tax]) AS AvgTransactionValue,
    AVG(s.[Unit Price]) AS AvgUnitPrice,
    
    CASE 
        WHEN (SUM(s.[Profit]) / NULLIF(SUM(s.[Total Excluding Tax]), 0)) * 100.0 >= 20 THEN 'High Margin'
        WHEN (SUM(s.[Profit]) / NULLIF(SUM(s.[Total Excluding Tax]), 0)) * 100.0 >= 10 THEN 'Medium Margin'
        ELSE 'Low Margin'
    END AS MarginCategory,
    
    CASE 
        WHEN SUM(s.[Total Excluding Tax]) >= 100000 THEN 'Large'
        WHEN SUM(s.[Total Excluding Tax]) >= 50000 THEN 'Medium'
        ELSE 'Small'
    END AS RevenueSize

FROM [Fact].[Sale] s
INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
WHERE d.[Date] >= DATEADD(MONTH, -24, GETDATE()) -- Last 24 months for trend analysis
GROUP BY 
    d.[Date],
    d.[Calendar Year],
    d.[Calendar Month Number],
    d.[Calendar Month Label],
    d.[Calendar Quarter Label],
    d.[Calendar Month Year Label];

GO

CREATE VIEW [dbo].[vw_PowerBI_RevenueSummaryKPIs]
AS
WITH CurrentPeriod AS (
    SELECT 
        SUM([Total Excluding Tax]) AS CurrentRevenue,
        SUM([Profit]) AS CurrentProfit,
        COUNT(DISTINCT [WWI Invoice ID]) AS CurrentInvoices
    FROM [Fact].[Sale] s
    INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
    WHERE d.[Date] >= DATEADD(MONTH, -1, GETDATE())
      AND d.[Date] < DATEADD(DAY, 1, EOMONTH(GETDATE(), -1))
),
PreviousPeriod AS (
    SELECT 
        SUM([Total Excluding Tax]) AS PreviousRevenue,
        SUM([Profit]) AS PreviousProfit,
        COUNT(DISTINCT [WWI Invoice ID]) AS PreviousInvoices
    FROM [Fact].[Sale] s
    INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
    WHERE d.[Date] >= DATEADD(MONTH, -2, GETDATE())
      AND d.[Date] < DATEADD(MONTH, -1, GETDATE())
),
YearAgo AS (
    SELECT 
        SUM([Total Excluding Tax]) AS YearAgoRevenue,
        SUM([Profit]) AS YearAgoProfit,
        COUNT(DISTINCT [WWI Invoice ID]) AS YearAgoInvoices
    FROM [Fact].[Sale] s
    INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
    WHERE d.[Date] >= DATEADD(MONTH, -13, GETDATE())
      AND d.[Date] < DATEADD(MONTH, -12, GETDATE())
)
SELECT 
    CAST(c.CurrentRevenue AS DECIMAL(18,2)) AS CurrentMonthRevenue,
    CAST(c.CurrentProfit AS DECIMAL(18,2)) AS CurrentMonthProfit,
    CAST(CASE WHEN c.CurrentRevenue > 0 THEN (c.CurrentProfit / c.CurrentRevenue) * 100.0 ELSE 0 END AS DECIMAL(5,2)) AS CurrentMonthMarginPercent,
    c.CurrentInvoices AS CurrentMonthInvoices,
    
    CAST(p.PreviousRevenue AS DECIMAL(18,2)) AS PreviousMonthRevenue,
    CAST(p.PreviousProfit AS DECIMAL(18,2)) AS PreviousMonthProfit,
    CAST(CASE WHEN p.PreviousRevenue > 0 THEN (p.PreviousProfit / p.PreviousRevenue) * 100.0 ELSE 0 END AS DECIMAL(5,2)) AS PreviousMonthMarginPercent,
    
    CAST(CASE WHEN p.PreviousRevenue > 0 THEN ((c.CurrentRevenue - p.PreviousRevenue) / p.PreviousRevenue) * 100.0 ELSE 0 END AS DECIMAL(5,2)) AS MonthOverMonthGrowthPercent,
    
    CAST(y.YearAgoRevenue AS DECIMAL(18,2)) AS YearAgoRevenue,
    CAST(CASE WHEN y.YearAgoRevenue > 0 THEN ((c.CurrentRevenue - y.YearAgoRevenue) / y.YearAgoRevenue) * 100.0 ELSE 0 END AS DECIMAL(5,2)) AS YearOverYearGrowthPercent,
    
    CASE 
        WHEN c.CurrentRevenue > p.PreviousRevenue THEN 'Increasing'
        WHEN c.CurrentRevenue < p.PreviousRevenue THEN 'Decreasing'
        ELSE 'Stable'
    END AS RevenueDirection,
    
    CASE 
        WHEN (c.CurrentProfit / NULLIF(c.CurrentRevenue, 0)) > (p.PreviousProfit / NULLIF(p.PreviousRevenue, 0)) THEN 'Improving'
        WHEN (c.CurrentProfit / NULLIF(c.CurrentRevenue, 0)) < (p.PreviousProfit / NULLIF(p.PreviousRevenue, 0)) THEN 'Declining'
        ELSE 'Stable'
    END AS MarginDirection

FROM CurrentPeriod c
CROSS JOIN PreviousPeriod p
CROSS JOIN YearAgo y;

GO

/*
DIVIDE(
    [Current Month Revenue] - [Previous Month Revenue],
    [Previous Month Revenue],
    0
) * 100

IF(
    [Current Month Margin Percent] > [Previous Month Margin Percent],
    "↗ Improving",
    IF(
        [Current Month Margin Percent] < [Previous Month Margin Percent],
        "↘ Declining",
        "→ Stable"
    )
)

DIVIDE([Current Month Revenue], [Revenue Target], 0) * 100
*/
