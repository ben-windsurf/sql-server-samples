# Revenue and Margin Trends Queries for WideWorldImportersDW

This directory contains SQL and MDX queries for analyzing 12-month revenue and margin trends from the WideWorldImportersDW database, compatible with both PowerBI and Kyvos analytics platforms.

## Contents

- `powerbi-12month-revenue-trends.sql` - T-SQL query for PowerBI integration
- `powerbi-yoy-revenue-comparison.sql` - T-SQL query with year-over-year comparisons
- `kyvos-mdx-revenue-trends.mdx` - MDX query for Kyvos integration with SSAS cubes
- `sample-powerbi-connection.md` - PowerBI connection and usage instructions

## Database Schema

The queries leverage the following WideWorldImportersDW tables:

### Fact.Sale
- `[Total Including Tax]` - Revenue including tax
- `[Total Excluding Tax]` - Revenue excluding tax  
- `[Profit]` - Margin/profit amount
- `[Invoice Date Key]` - Date key for time-based analysis

### Dimension.Date
- `[Date]` - Primary date field
- `[Calendar Year]` - Calendar year
- `[Calendar Month Number]` - Month number (1-12)
- `[Calendar Month Label]` - Month label (e.g., "CY2023-Jan")
- `[Calendar Quarter Number]` - Quarter number (1-4)

## SSAS Cube Measures

For Kyvos/MDX integration, the following measures are available:

- `[Sales Total Including Tax]` - Revenue including tax
- `[Sales Total Excluding Tax]` - Revenue excluding tax
- `[Sales Profit]` - Margin/profit
- `[Sales Total Including Tax Invoice YTD]` - Year-to-date revenue including tax
- `[Sales Total Excluding Tax Invoice YTD]` - Year-to-date revenue excluding tax

## Usage

### PowerBI Integration
1. Connect to WideWorldImportersDW database
2. Import the T-SQL queries as data sources
3. Create visualizations using the returned data structure
4. Use the date fields for time-based filtering and grouping

### Kyvos Integration
1. Connect to the WideWorldImporters SSAS cube
2. Execute the MDX queries through Kyvos interface
3. Leverage the pre-built time intelligence measures
4. Use Invoice Date dimension for time-based analysis

## Performance Notes

- Queries leverage columnstore indexes on Fact.Sale table
- Date filtering uses indexed Invoice Date Key field
- Aggregations are optimized for large data volumes
- Consider date range parameters for better performance on large datasets
