# Revenue and Margin Analysis for WideWorldImportersDW

This directory contains SQL queries and documentation for analyzing 12-month revenue and margin trends in the WideWorldImportersDW data warehouse, with compatibility for both PowerBI and Kyvos OLAP platforms.

## Contents

- `12-month-revenue-margin-trends.sql` - Comprehensive SQL view for revenue and margin trend analysis
- `powerbi-revenue-trends-view.sql` - PowerBI-optimized view with pre-calculated measures
- `kyvos-mdx-examples.mdx` - MDX query examples leveraging existing SSAS cube infrastructure
- `sample-powerbi-connection.md` - PowerBI connection setup and configuration
- `kyvos-integration-guide.md` - Kyvos integration instructions and best practices

## Prerequisites

1. WideWorldImportersDW sample database deployed and populated
2. SQL Server 2016 or higher / Azure SQL Database
3. For Kyvos integration: Existing SSAS multidimensional cube deployed
4. For PowerBI: PowerBI Desktop or PowerBI Service access

## Quick Start

### SQL Server Direct Query
```sql
-- Execute the main trend analysis query
EXEC sp_executesql N'SELECT * FROM [dbo].[vw_12MonthRevenueMarginsAnalysis]'
```

### PowerBI Connection
1. Open PowerBI Desktop
2. Get Data > SQL Server
3. Use the connection details from `sample-powerbi-connection.md`
4. Import the `vw_PowerBI_RevenueMarginTrends` view

### Kyvos Integration
1. Connect Kyvos to the existing WideWorldImporters SSAS cube
2. Use the MDX examples in `kyvos-mdx-examples.mdx`
3. Follow the integration guide for optimal performance

## Key Metrics Included

- **Revenue Metrics**: Total Excluding Tax, Total Including Tax
- **Margin Metrics**: Profit, Margin Percentage
- **Time Intelligence**: Month-over-month growth, Year-over-year comparison
- **Trend Analysis**: Rolling 12-month averages, seasonal patterns

## Data Sources

The queries leverage the following WideWorldImportersDW tables:
- `Fact.Sale` - Primary sales transaction data
- `Dimension.Date` - Comprehensive date dimension with calendar and fiscal periods
- Existing SSAS cube measures for MDX compatibility

## Compatibility

- **PowerBI**: Optimized column names, pre-calculated measures, efficient data types
- **Kyvos**: Leverages existing SSAS cube structure and MDX measures
- **SQL Server**: Compatible with SQL Server 2016+ and Azure SQL Database
- **Performance**: Includes proper indexing recommendations and query optimization
