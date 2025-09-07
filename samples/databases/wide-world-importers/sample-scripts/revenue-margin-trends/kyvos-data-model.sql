
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Kyvos')
BEGIN
    EXEC('CREATE SCHEMA [Kyvos]')
END
GO

IF OBJECT_ID('[Kyvos].[RevenueMarginSummary]', 'U') IS NOT NULL
    DROP TABLE [Kyvos].[RevenueMarginSummary];
GO

IF OBJECT_ID('[Kyvos].[DailyRevenueMargin]', 'U') IS NOT NULL
    DROP TABLE [Kyvos].[DailyRevenueMargin];
GO

CREATE TABLE [Kyvos].[RevenueMarginSummary] (
    [SummaryKey] BIGINT IDENTITY(1,1) NOT NULL,
    [DateKey] INT NOT NULL,
    [Year] INT NOT NULL,
    [Month] INT NOT NULL,
    [Quarter] INT NOT NULL,
    [MonthLabel] NVARCHAR(20) NOT NULL,
    [MonthYearLabel] NVARCHAR(20) NOT NULL,
    [RevenueIncludingTax] DECIMAL(18,2) NOT NULL,
    [RevenueExcludingTax] DECIMAL(18,2) NOT NULL,
    [TotalTaxAmount] DECIMAL(18,2) NOT NULL,
    [TotalProfit] DECIMAL(18,2) NOT NULL,
    [MarginPercentage] DECIMAL(5,2) NOT NULL,
    [TransactionCount] INT NOT NULL,
    [AverageUnitPrice] DECIMAL(18,2) NOT NULL,
    [TotalQuantitySold] INT NOT NULL,
    [CreatedDate] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [PK_Kyvos_RevenueMarginSummary] PRIMARY KEY CLUSTERED ([SummaryKey] ASC)
);
GO

CREATE TABLE [Kyvos].[DailyRevenueMargin] (
    [DailyKey] BIGINT IDENTITY(1,1) NOT NULL,
    [Date] DATE NOT NULL,
    [DateKey] INT NOT NULL,
    [Year] INT NOT NULL,
    [Month] INT NOT NULL,
    [Day] INT NOT NULL,
    [DayOfWeek] NVARCHAR(20) NOT NULL,
    [DayOfWeekNumber] INT NOT NULL,
    [RevenueIncludingTax] DECIMAL(18,2) NOT NULL,
    [RevenueExcludingTax] DECIMAL(18,2) NOT NULL,
    [TotalProfit] DECIMAL(18,2) NOT NULL,
    [MarginPercentage] DECIMAL(5,2) NOT NULL,
    [TransactionCount] INT NOT NULL,
    [CreatedDate] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [PK_Kyvos_DailyRevenueMargin] PRIMARY KEY CLUSTERED ([DailyKey] ASC)
);
GO

CREATE NONCLUSTERED INDEX [IX_Kyvos_RevenueMarginSummary_Date]
    ON [Kyvos].[RevenueMarginSummary]([Year] ASC, [Month] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_Kyvos_RevenueMarginSummary_DateKey]
    ON [Kyvos].[RevenueMarginSummary]([DateKey] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_Kyvos_DailyRevenueMargin_Date]
    ON [Kyvos].[DailyRevenueMargin]([Date] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_Kyvos_DailyRevenueMargin_YearMonth]
    ON [Kyvos].[DailyRevenueMargin]([Year] ASC, [Month] ASC);
GO

INSERT INTO [Kyvos].[RevenueMarginSummary] (
    [DateKey], [Year], [Month], [Quarter], [MonthLabel], [MonthYearLabel],
    [RevenueIncludingTax], [RevenueExcludingTax], [TotalTaxAmount], [TotalProfit],
    [MarginPercentage], [TransactionCount], [AverageUnitPrice], [TotalQuantitySold]
)
SELECT 
    d.[Year Month Key] as [DateKey],
    d.[Calendar Year] as [Year],
    d.[Calendar Month Number] as [Month],
    d.[Calendar Quarter Number] as [Quarter],
    d.[Calendar Month Label] as [MonthLabel],
    d.[Calendar Month Year Label] as [MonthYearLabel],
    SUM(s.[Total Including Tax]) as [RevenueIncludingTax],
    SUM(s.[Total Excluding Tax]) as [RevenueExcludingTax],
    SUM(s.[Tax Amount]) as [TotalTaxAmount],
    SUM(s.[Profit]) as [TotalProfit],
    CASE 
        WHEN SUM(s.[Total Excluding Tax]) > 0 
        THEN (SUM(s.[Profit]) / SUM(s.[Total Excluding Tax])) * 100 
        ELSE 0 
    END as [MarginPercentage],
    COUNT(s.[Sale Key]) as [TransactionCount],
    AVG(s.[Unit Price]) as [AverageUnitPrice],
    SUM(s.[Quantity]) as [TotalQuantitySold]
FROM [Fact].[Sale] s
INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
WHERE d.[Date] >= DATEADD(YEAR, -2, GETDATE())  -- Load 2 years of data
GROUP BY 
    d.[Year Month Key],
    d.[Calendar Year], 
    d.[Calendar Month Number], 
    d.[Calendar Quarter Number],
    d.[Calendar Month Label],
    d.[Calendar Month Year Label];
GO

INSERT INTO [Kyvos].[DailyRevenueMargin] (
    [Date], [DateKey], [Year], [Month], [Day], [DayOfWeek], [DayOfWeekNumber],
    [RevenueIncludingTax], [RevenueExcludingTax], [TotalProfit], 
    [MarginPercentage], [TransactionCount]
)
SELECT 
    d.[Date] as [Date],
    d.[Date Key] as [DateKey],
    d.[Calendar Year] as [Year],
    d.[Calendar Month Number] as [Month],
    d.[Day Number] as [Day],
    d.[Day of Week] as [DayOfWeek],
    d.[Day of Week Number] as [DayOfWeekNumber],
    SUM(s.[Total Including Tax]) as [RevenueIncludingTax],
    SUM(s.[Total Excluding Tax]) as [RevenueExcludingTax],
    SUM(s.[Profit]) as [TotalProfit],
    CASE 
        WHEN SUM(s.[Total Excluding Tax]) > 0 
        THEN (SUM(s.[Profit]) / SUM(s.[Total Excluding Tax])) * 100 
        ELSE 0 
    END as [MarginPercentage],
    COUNT(s.[Sale Key]) as [TransactionCount]
FROM [Fact].[Sale] s
INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
WHERE d.[Date] >= DATEADD(MONTH, -13, GETDATE())  -- Load 13 months of daily data
GROUP BY 
    d.[Date],
    d.[Date Key],
    d.[Calendar Year], 
    d.[Calendar Month Number], 
    d.[Day Number],
    d.[Day of Week],
    d.[Day of Week Number];
GO

CREATE OR ALTER VIEW [Kyvos].[RevenueMarginCubeView] AS
SELECT 
    rms.[Year],
    rms.[Month],
    rms.[Quarter],
    rms.[MonthLabel],
    rms.[MonthYearLabel],
    rms.[RevenueIncludingTax],
    rms.[RevenueExcludingTax],
    rms.[TotalProfit],
    rms.[MarginPercentage],
    rms.[TransactionCount],
    rms.[AverageUnitPrice],
    rms.[TotalQuantitySold],
    LAG(rms.[RevenueIncludingTax], 1) OVER (ORDER BY rms.[Year], rms.[Month]) as [PreviousMonthRevenue],
    LAG(rms.[RevenueIncludingTax], 12) OVER (ORDER BY rms.[Year], rms.[Month]) as [SameMonthLastYearRevenue],
    SUM(rms.[RevenueIncludingTax]) OVER (
        ORDER BY rms.[Year], rms.[Month] 
        ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
    ) as [Rolling12MonthRevenue],
    SUM(rms.[TotalProfit]) OVER (
        ORDER BY rms.[Year], rms.[Month] 
        ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
    ) as [Rolling12MonthProfit]
FROM [Kyvos].[RevenueMarginSummary] rms;
GO

CREATE OR ALTER PROCEDURE [Kyvos].[RefreshRevenueMarginData]
AS
BEGIN
    SET NOCOUNT ON;
    
    TRUNCATE TABLE [Kyvos].[RevenueMarginSummary];
    TRUNCATE TABLE [Kyvos].[DailyRevenueMargin];
    
    INSERT INTO [Kyvos].[RevenueMarginSummary] (
        [DateKey], [Year], [Month], [Quarter], [MonthLabel], [MonthYearLabel],
        [RevenueIncludingTax], [RevenueExcludingTax], [TotalTaxAmount], [TotalProfit],
        [MarginPercentage], [TransactionCount], [AverageUnitPrice], [TotalQuantitySold]
    )
    SELECT 
        d.[Year Month Key] as [DateKey],
        d.[Calendar Year] as [Year],
        d.[Calendar Month Number] as [Month],
        d.[Calendar Quarter Number] as [Quarter],
        d.[Calendar Month Label] as [MonthLabel],
        d.[Calendar Month Year Label] as [MonthYearLabel],
        SUM(s.[Total Including Tax]) as [RevenueIncludingTax],
        SUM(s.[Total Excluding Tax]) as [RevenueExcludingTax],
        SUM(s.[Tax Amount]) as [TotalTaxAmount],
        SUM(s.[Profit]) as [TotalProfit],
        CASE 
            WHEN SUM(s.[Total Excluding Tax]) > 0 
            THEN (SUM(s.[Profit]) / SUM(s.[Total Excluding Tax])) * 100 
            ELSE 0 
        END as [MarginPercentage],
        COUNT(s.[Sale Key]) as [TransactionCount],
        AVG(s.[Unit Price]) as [AverageUnitPrice],
        SUM(s.[Quantity]) as [TotalQuantitySold]
    FROM [Fact].[Sale] s
    INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
    WHERE d.[Date] >= DATEADD(YEAR, -2, GETDATE())
    GROUP BY 
        d.[Year Month Key],
        d.[Calendar Year], 
        d.[Calendar Month Number], 
        d.[Calendar Quarter Number],
        d.[Calendar Month Label],
        d.[Calendar Month Year Label];
    
    INSERT INTO [Kyvos].[DailyRevenueMargin] (
        [Date], [DateKey], [Year], [Month], [Day], [DayOfWeek], [DayOfWeekNumber],
        [RevenueIncludingTax], [RevenueExcludingTax], [TotalProfit], 
        [MarginPercentage], [TransactionCount]
    )
    SELECT 
        d.[Date] as [Date],
        d.[Date Key] as [DateKey],
        d.[Calendar Year] as [Year],
        d.[Calendar Month Number] as [Month],
        d.[Day Number] as [Day],
        d.[Day of Week] as [DayOfWeek],
        d.[Day of Week Number] as [DayOfWeekNumber],
        SUM(s.[Total Including Tax]) as [RevenueIncludingTax],
        SUM(s.[Total Excluding Tax]) as [RevenueExcludingTax],
        SUM(s.[Profit]) as [TotalProfit],
        CASE 
            WHEN SUM(s.[Total Excluding Tax]) > 0 
            THEN (SUM(s.[Profit]) / SUM(s.[Total Excluding Tax])) * 100 
            ELSE 0 
        END as [MarginPercentage],
        COUNT(s.[Sale Key]) as [TransactionCount]
    FROM [Fact].[Sale] s
    INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
    WHERE d.[Date] >= DATEADD(MONTH, -13, GETDATE())
    GROUP BY 
        d.[Date],
        d.[Date Key],
        d.[Calendar Year], 
        d.[Calendar Month Number], 
        d.[Day Number],
        d.[Day of Week],
        d.[Day of Week Number];
    
    PRINT 'Kyvos revenue margin data refresh completed successfully.';
END;
GO


PRINT 'Kyvos data model created successfully. Execute [Kyvos].[RefreshRevenueMarginData] to refresh data.';
