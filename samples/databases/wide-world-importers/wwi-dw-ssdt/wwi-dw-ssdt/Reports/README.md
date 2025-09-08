# WideWorldImportersDW Revenue and Margin Trends Analysis

This folder contains SQL views and stored procedures for analyzing 12-month revenue and margin trends in the WideWorldImportersDW data warehouse, optimized for PowerBI and Kyvos OLAP platforms.

## Overview

The trending analysis queries provide comprehensive insights into:
- Monthly, quarterly, and weekly revenue trends
- Profit margin analysis and calculations
- Year-over-year growth comparisons
- Rolling averages and trend indicators

## Views Available

### 1. MonthlyRevenueTrends
**Purpose**: Monthly revenue analysis for the last 12 months
**Key Metrics**:
- Revenue Excluding Tax
- Revenue Including Tax
- Transaction Count
- Average Sale Value

**Usage**:
```sql
SELECT * FROM [Reports].[MonthlyRevenueTrends]
ORDER BY [Period Date];
```

### 2. MonthlyMarginTrends
**Purpose**: Monthly profit margin analysis for the last 12 months
**Key Metrics**:
- Total Profit
- Total Revenue
- Profit Margin Percentage
- Average Profit Per Sale
- Transaction Count

**Usage**:
```sql
SELECT * FROM [Reports].[MonthlyMarginTrends]
WHERE [Profit Margin Percentage] > 10
ORDER BY [Period Date];
```

### 3. ComprehensiveTrends
**Purpose**: Combined revenue and margin analysis with year-over-year comparisons
**Key Metrics**:
- Revenue and Profit
- Margin Percentage
- Previous Year Comparisons
- Year-over-Year Growth Percentage
- 3-Month Rolling Average

**Usage**:
```sql
SELECT 
    [Month Label],
    [Revenue],
    [Profit],
    [Margin Percentage],
    [Revenue YoY Growth Percentage]
FROM [Reports].[ComprehensiveTrends]
WHERE [Revenue YoY Growth Percentage] IS NOT NULL
ORDER BY [Period Date];
```

### 4. QuarterlyTrends
**Purpose**: Quarterly aggregated trends for the last 4 quarters
**Usage**:
```sql
SELECT * FROM [Reports].[QuarterlyTrends]
ORDER BY [Year], [Quarter];
```

### 5. WeeklyTrends
**Purpose**: Weekly trends for the last 52 weeks
**Usage**:
```sql
SELECT * FROM [Reports].[WeeklyTrends]
WHERE [Week Start Date] >= DATEADD(MONTH, -3, GETDATE())
ORDER BY [Week Start Date];
```

## Stored Procedures

### GetRevenueTrendsByDateRange
**Purpose**: Flexible analysis with custom date ranges
**Parameters**:
- @StartDate (optional): Start date for analysis (defaults to 12 months ago)
- @EndDate (optional): End date for analysis (defaults to current date)

**Usage**:
```sql
-- Last 6 months
EXEC [Reports].[GetRevenueTrendsByDateRange] 
    @StartDate = '2024-03-01', 
    @EndDate = '2024-08-31';

-- Default 12 months
EXEC [Reports].[GetRevenueTrendsByDateRange];
```

## PowerBI Integration

### Recommended Data Source Configuration
1. Connect to WideWorldImportersDW database
2. Import the following views as tables:
   - `Reports.MonthlyRevenueTrends`
   - `Reports.MonthlyMarginTrends`
   - `Reports.ComprehensiveTrends`

### Sample PowerBI DAX Measures
```dax
// Revenue Growth Rate
Revenue Growth % = 
DIVIDE(
    [Revenue] - [Revenue Previous Year],
    [Revenue Previous Year],
    0
) * 100

// Margin Trend Indicator
Margin Trend = 
IF(
    [Profit Margin Percentage] > AVERAGE([Profit Margin Percentage]),
    "Above Average",
    "Below Average"
)
```

## Kyvos OLAP Integration

### Cube Design Recommendations
1. **Time Dimension**: Use the Date dimension with Calendar Year, Quarter, Month, Week hierarchies
2. **Measures**: 
   - Revenue Excluding Tax (SUM)
   - Revenue Including Tax (SUM)
   - Total Profit (SUM)
   - Profit Margin Percentage (CALCULATED)
   - Transaction Count (COUNT)

### MDX Query Examples
```mdx
-- Monthly Revenue Trend
SELECT 
    [Measures].[Revenue Excluding Tax] ON COLUMNS,
    [Date].[Calendar].[Month].MEMBERS ON ROWS
FROM [WideWorldImportersDW]
WHERE [Date].[Calendar Year].[2024]

-- Profit Margin Analysis
SELECT 
    {[Measures].[Total Profit], [Measures].[Profit Margin Percentage]} ON COLUMNS,
    [Date].[Calendar Quarter].MEMBERS ON ROWS
FROM [WideWorldImportersDW]
```

## Performance Considerations

### Indexing Recommendations
The queries are optimized for the existing columnstore indexes on the Fact.Sale table. For optimal performance:

1. Ensure the clustered columnstore index `CCX_Fact_Sale` is maintained
2. Consider adding nonclustered indexes on frequently filtered date ranges
3. Update statistics regularly for the Date dimension

### Query Optimization Tips
1. Use date range parameters to limit data scope
2. Consider materialized views for frequently accessed trend data
3. Implement incremental refresh strategies for PowerBI datasets

## Data Refresh Strategy

### For PowerBI
- Schedule daily refresh for real-time trending
- Use incremental refresh for large datasets
- Consider DirectQuery for real-time requirements

### For Kyvos
- Process cubes after ETL completion
- Implement partition strategies based on date ranges
- Use incremental processing for performance

## Troubleshooting

### Common Issues
1. **No data returned**: Check date ranges and ensure ETL processes have completed
2. **Performance issues**: Verify columnstore index health and statistics currency
3. **Incorrect calculations**: Validate date dimension joins and aggregation logic

### Validation Queries
```sql
-- Check data availability
SELECT MIN([Invoice Date Key]), MAX([Invoice Date Key])
FROM [Fact].[Sale];

-- Verify trend calculations
SELECT 
    [Month Label],
    [Revenue],
    [Revenue Previous Year],
    [Revenue YoY Growth Percentage]
FROM [Reports].[ComprehensiveTrends]
WHERE [Revenue Previous Year] IS NOT NULL;
```

## Support and Maintenance

For questions or issues with these trending analysis queries:
1. Verify the WideWorldImportersDW database is properly deployed
2. Ensure the Reports schema exists and has appropriate permissions
3. Check that the underlying Fact.Sale and Dimension.Date tables contain data
4. Review the ETL processes for data currency

## Version History
- v1.0: Initial implementation with monthly, quarterly, and weekly trends
- Includes PowerBI and Kyvos compatibility optimizations
- Supports rolling 12-month analysis with year-over-year comparisons
