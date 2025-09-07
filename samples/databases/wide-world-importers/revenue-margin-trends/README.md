# 12-Month Revenue and Margin Trends for WideWorldImportersDW

This directory contains SQL queries, PowerBI templates, and Kyvos OLAP cube definitions for analyzing 12-month revenue and margin trends in the WideWorldImportersDW database.

## Contents

- **SQL Queries** (`sql-queries/`)
  - Monthly revenue and margin trend queries
  - Year-over-year comparison queries
  - Rolling 12-month calculations
  - Both calendar and fiscal year variations

- **PowerBI Templates** (`powerbi/`)
  - Revenue and margin trend dashboard template (.pbit)
  - Data model configuration
  - Pre-built visualizations for trend analysis

- **Kyvos OLAP Definitions** (`kyvos/`)
  - Cube schema definitions
  - MDX calculated measures
  - Sample MDX queries for trend analysis

## Key Metrics

### Revenue Metrics
- **Total Excluding Tax**: Base revenue without tax
- **Total Including Tax**: Total revenue including tax
- **Tax Amount**: Tax component of sales

### Margin Metrics
- **Profit**: Direct profit margin from sales
- **Margin Percentage**: Calculated as Profit / Total Excluding Tax
- **Margin Trend**: Month-over-month margin changes

## Data Sources

The analysis uses the following WideWorldImportersDW tables:
- `Fact.Sale` - Primary sales data with revenue and profit measures
- `Dimension.Date` - Rich date dimension with calendar and fiscal hierarchies
- `Dimension.Customer` - Customer segmentation for detailed analysis
- `Dimension.Stock Item` - Product categorization

## Quick Start

### PowerBI Setup
1. Open the template file `powerbi/Revenue-Margin-Trends.pbit`
2. Configure data source to point to your WideWorldImportersDW instance
3. Refresh data to load the latest trends
4. Customize date ranges and filters as needed

### Kyvos Setup
1. Import the cube definition from `kyvos/WWI-Revenue-Margin-Cube.xml`
2. Configure connection to WideWorldImportersDW database
3. Process the cube to build aggregations
4. Use the sample MDX queries for analysis

### Direct SQL Usage
1. Execute queries from `sql-queries/` directory
2. Modify date ranges in WHERE clauses as needed
3. Export results to your preferred visualization tool

## Date Range Configuration

All queries support both calendar and fiscal year analysis:
- **Calendar Year**: January-December periods
- **Fiscal Year**: Configurable fiscal year start (default: July-June)

Modify the date filters in queries to focus on specific periods:
```sql
WHERE d.[Calendar Year] = 2016
-- OR
WHERE d.[Fiscal Year] = 2016
```

## Visualization Features

### Trend Analysis
- Monthly revenue and margin line charts
- Year-over-year comparison bars
- Rolling 12-month averages
- Seasonal pattern identification

### KPI Dashboards
- Current month vs. previous month
- Year-to-date totals
- Margin percentage trends
- Top performing periods

### Detailed Breakdowns
- Revenue by customer segment
- Margin by product category
- Geographic revenue distribution
- Salesperson performance metrics

## Prerequisites

- WideWorldImportersDW database (SQL Server 2016+)
- PowerBI Desktop (for PowerBI templates)
- Kyvos Analytics Platform (for OLAP cubes)
- SQL Server Management Studio (for direct query execution)

## Support

For issues or questions:
1. Check the troubleshooting section in each platform's subdirectory
2. Verify database connectivity and permissions
3. Ensure WideWorldImportersDW contains sample data for the desired date ranges

## License

This sample is provided under the same license as the WideWorldImporters sample database.
