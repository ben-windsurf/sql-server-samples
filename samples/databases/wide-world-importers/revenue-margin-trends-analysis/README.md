# WideWorldImportersDW 12-Month Revenue and Margin Trends Analysis

This analysis provides comprehensive SQL queries for extracting 12-month revenue and margin trends from the WideWorldImportersDW data warehouse, optimized for both PowerBI and Kyvos OLAP platforms.

## Quick Start

### For PowerBI Users
1. Connect to your WideWorldImportersDW database
2. Import the following views:
   ```sql
   SELECT * FROM [Reports].[MonthlyRevenueTrends]
   SELECT * FROM [Reports].[MonthlyMarginTrends]
   SELECT * FROM [Reports].[ComprehensiveTrends]
   ```

### For Kyvos Users
1. Use the provided views as data sources for cube creation
2. Implement the recommended dimension and measure structures
3. Follow the MDX query examples for trend analysis

## Key Features

- **Rolling 12-month analysis** with automatic date calculations
- **Year-over-year comparisons** for growth tracking
- **Profit margin calculations** with percentage and absolute values
- **Multiple time granularities**: Monthly, quarterly, and weekly views
- **PowerBI and Kyvos optimized** query structures
- **Performance optimized** for columnstore indexes

## Files Structure

```
wwi-dw-ssdt/Reports/
├── Views/
│   ├── MonthlyRevenueTrends.sql      # Monthly revenue analysis
│   ├── MonthlyMarginTrends.sql       # Monthly margin analysis
│   ├── ComprehensiveTrends.sql       # Combined analysis with YoY
│   ├── QuarterlyTrends.sql           # Quarterly aggregations
│   └── WeeklyTrends.sql              # Weekly trend analysis
├── Stored Procedures/
│   └── GetRevenueTrendsByDateRange.sql # Flexible date range analysis
└── README.md                         # Detailed documentation
```

## Sample Queries

### Basic Revenue Trend
```sql
SELECT 
    [Month Label],
    [Revenue Excluding Tax],
    [Transaction Count]
FROM [Reports].[MonthlyRevenueTrends]
ORDER BY [Period Date];
```

### Margin Analysis with Growth
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

### Custom Date Range Analysis
```sql
EXEC [Reports].[GetRevenueTrendsByDateRange] 
    @StartDate = '2024-01-01', 
    @EndDate = '2024-12-31';
```

## Platform Compatibility

### PowerBI Integration
- Standard SQL constructs for optimal import performance
- Pre-calculated measures for faster dashboard rendering
- Date dimension integration for time intelligence functions

### Kyvos OLAP Integration
- Dimensional modeling compatible structure
- Optimized for cube processing and MDX queries
- Hierarchical time dimensions for drill-down analysis

## Performance Notes

- Queries leverage existing columnstore indexes on Fact.Sale table
- Date filtering optimized for partition elimination
- Aggregations pre-calculated for common business scenarios
- Suitable for both DirectQuery and Import modes in PowerBI

## Installation

1. Deploy the SQL files to your WideWorldImportersDW database
2. Ensure the Reports schema exists (created automatically)
3. Verify data availability in Fact.Sale and Dimension.Date tables
4. Test queries with your specific date ranges

## Support

For detailed documentation, usage examples, and troubleshooting, see the complete README.md in the Reports folder.
