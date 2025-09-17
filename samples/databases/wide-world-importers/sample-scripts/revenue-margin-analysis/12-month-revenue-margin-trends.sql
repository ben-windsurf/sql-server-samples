
CREATE VIEW [dbo].[vw_12MonthRevenueMarginsAnalysis]
AS
WITH MonthlyRevenueTrends AS (
    SELECT 
        d.[Calendar Year] AS RevenueYear,
        d.[Calendar Month Number] AS MonthNumber,
        d.[Calendar Month Label] AS MonthLabel,
        d.[Calendar Month Year Label] AS MonthYearLabel,
        d.[Beginning of Month] AS MonthStartDate,
        
        SUM(s.[Total Excluding Tax]) AS RevenueExcludingTax,
        SUM(s.[Total Including Tax]) AS RevenueIncludingTax,
        SUM(s.[Profit]) AS TotalProfit,
        SUM(s.[Tax Amount]) AS TotalTaxAmount,
        
        SUM(s.[Quantity]) AS TotalQuantitySold,
        COUNT(DISTINCT s.[WWI Invoice ID]) AS InvoiceCount,
        COUNT(DISTINCT s.[Customer Key]) AS UniqueCustomers,
        
        AVG(s.[Total Excluding Tax]) AS AvgTransactionValue,
        AVG(s.[Unit Price]) AS AvgUnitPrice
        
    FROM [Fact].[Sale] s
    INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
    WHERE d.[Date] >= DATEADD(MONTH, -12, GETDATE()) -- Rolling 12 months
    GROUP BY 
        d.[Calendar Year],
        d.[Calendar Month Number],
        d.[Calendar Month Label],
        d.[Calendar Month Year Label],
        d.[Beginning of Month]
),
MarginCalculations AS (
    SELECT 
        *,
        CASE 
            WHEN RevenueExcludingTax > 0 
            THEN (TotalProfit / RevenueExcludingTax) * 100.0 
            ELSE 0 
        END AS MarginPercentage,
        
        CASE 
            WHEN RevenueExcludingTax > 0 
            THEN (TotalTaxAmount / RevenueExcludingTax) * 100.0 
            ELSE 0 
        END AS EffectiveTaxRate,
        
        CASE 
            WHEN UniqueCustomers > 0 
            THEN RevenueExcludingTax / UniqueCustomers 
            ELSE 0 
        END AS RevenuePerCustomer
        
    FROM MonthlyRevenueTrends
),
TrendAnalysis AS (
    SELECT 
        *,
        LAG(RevenueExcludingTax, 1) OVER (ORDER BY RevenueYear, MonthNumber) AS PreviousMonthRevenue,
        LAG(TotalProfit, 1) OVER (ORDER BY RevenueYear, MonthNumber) AS PreviousMonthProfit,
        LAG(MarginPercentage, 1) OVER (ORDER BY RevenueYear, MonthNumber) AS PreviousMonthMargin,
        
        LAG(RevenueExcludingTax, 12) OVER (ORDER BY RevenueYear, MonthNumber) AS SameMonthLastYearRevenue,
        LAG(TotalProfit, 12) OVER (ORDER BY RevenueYear, MonthNumber) AS SameMonthLastYearProfit,
        LAG(MarginPercentage, 12) OVER (ORDER BY RevenueYear, MonthNumber) AS SameMonthLastYearMargin,
        
        AVG(RevenueExcludingTax) OVER (ORDER BY RevenueYear, MonthNumber ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS ThreeMonthAvgRevenue,
        AVG(MarginPercentage) OVER (ORDER BY RevenueYear, MonthNumber ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS ThreeMonthAvgMargin
        
    FROM MarginCalculations
)
SELECT 
    RevenueYear,
    MonthNumber,
    MonthLabel,
    MonthYearLabel,
    MonthStartDate,
    
    CAST(RevenueExcludingTax AS DECIMAL(18,2)) AS RevenueExcludingTax,
    CAST(RevenueIncludingTax AS DECIMAL(18,2)) AS RevenueIncludingTax,
    CAST(TotalProfit AS DECIMAL(18,2)) AS TotalProfit,
    CAST(TotalTaxAmount AS DECIMAL(18,2)) AS TotalTaxAmount,
    
    CAST(MarginPercentage AS DECIMAL(5,2)) AS MarginPercentage,
    CAST(EffectiveTaxRate AS DECIMAL(5,2)) AS EffectiveTaxRate,
    CAST(RevenuePerCustomer AS DECIMAL(18,2)) AS RevenuePerCustomer,
    
    TotalQuantitySold,
    InvoiceCount,
    UniqueCustomers,
    CAST(AvgTransactionValue AS DECIMAL(18,2)) AS AvgTransactionValue,
    CAST(AvgUnitPrice AS DECIMAL(18,2)) AS AvgUnitPrice,
    
    CASE 
        WHEN PreviousMonthRevenue > 0 
        THEN CAST(((RevenueExcludingTax - PreviousMonthRevenue) / PreviousMonthRevenue) * 100.0 AS DECIMAL(5,2))
        ELSE NULL 
    END AS MonthOverMonthRevenueGrowthPct,
    
    CASE 
        WHEN PreviousMonthMargin IS NOT NULL 
        THEN CAST((MarginPercentage - PreviousMonthMargin) AS DECIMAL(5,2))
        ELSE NULL 
    END AS MonthOverMonthMarginChange,
    
    CASE 
        WHEN SameMonthLastYearRevenue > 0 
        THEN CAST(((RevenueExcludingTax - SameMonthLastYearRevenue) / SameMonthLastYearRevenue) * 100.0 AS DECIMAL(5,2))
        ELSE NULL 
    END AS YearOverYearRevenueGrowthPct,
    
    CASE 
        WHEN SameMonthLastYearMargin IS NOT NULL 
        THEN CAST((MarginPercentage - SameMonthLastYearMargin) AS DECIMAL(5,2))
        ELSE NULL 
    END AS YearOverYearMarginChange,
    
    CAST(ThreeMonthAvgRevenue AS DECIMAL(18,2)) AS ThreeMonthAvgRevenue,
    CAST(ThreeMonthAvgMargin AS DECIMAL(5,2)) AS ThreeMonthAvgMargin,
    
    CASE 
        WHEN MarginPercentage >= 20 THEN 'High'
        WHEN MarginPercentage >= 10 THEN 'Medium'
        ELSE 'Low'
    END AS MarginCategory,
    
    CASE 
        WHEN MonthOverMonthRevenueGrowthPct > 5 THEN 'Growing'
        WHEN MonthOverMonthRevenueGrowthPct < -5 THEN 'Declining'
        ELSE 'Stable'
    END AS RevenueGrowthTrend

FROM TrendAnalysis
WHERE MonthStartDate IS NOT NULL
ORDER BY RevenueYear DESC, MonthNumber DESC;

GO

CREATE NONCLUSTERED INDEX [IX_Sale_InvoiceDateKey_Performance]
ON [Fact].[Sale] ([Invoice Date Key])
INCLUDE ([Total Excluding Tax], [Total Including Tax], [Profit], [Tax Amount], [Quantity], [WWI Invoice ID], [Customer Key], [Unit Price])
WHERE [Invoice Date Key] >= CAST(DATEADD(MONTH, -24, GETDATE()) AS DATE);

GO

/*
SELECT TOP 12
    MonthYearLabel,
    RevenueExcludingTax,
    TotalProfit,
    MarginPercentage,
    MonthOverMonthRevenueGrowthPct,
    YearOverYearRevenueGrowthPct,
    MarginCategory,
    RevenueGrowthTrend
FROM [dbo].[vw_12MonthRevenueMarginsAnalysis]
ORDER BY RevenueYear DESC, MonthNumber DESC;

SELECT 
    MarginCategory,
    COUNT(*) AS MonthCount,
    AVG(MarginPercentage) AS AvgMarginPct,
    AVG(RevenueExcludingTax) AS AvgRevenue
FROM [dbo].[vw_12MonthRevenueMarginsAnalysis]
GROUP BY MarginCategory
ORDER BY AvgMarginPct DESC;
*/
