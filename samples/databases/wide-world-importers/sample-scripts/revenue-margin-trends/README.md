# 12-Month Revenue and Margin Trend Visualizations

This sample demonstrates how to create 12-month revenue and margin trend visualizations for the WideWorldImportersDW database that work with both Power BI and Kyvos platforms.

## Contents

[About this sample](#about-this-sample)<br/>
[Before you begin](#before-you-begin)<br/>
[Running the sample](#running-the-sample)<br/>
[Power BI Dashboard](#power-bi-dashboard)<br/>
[Kyvos Integration](#kyvos-integration)<br/>
[Sample details](#sample-details)<br/>
[Disclaimers](#disclaimers)<br/>

## About this sample

1. **Applies to:** SQL Server 2016 (or higher), Azure SQL Database
1. **Key features:** Power BI, Kyvos, Analysis Services, Time Series Analysis
1. **Workload:** BI Analytics, Revenue Analysis, Margin Analysis
1. **Programming Language:** T-SQL, Power BI Desktop, Python
1. **Authors:** Devin AI
1. **Update history:** September 2025 - initial revision

## Before you begin

**Software prerequisites:**

1. [WideWorldImportersDW](../../../wwi-dw-ssdt/) sample database running in SQL Server 2016 (or higher) or Azure SQL Database
1. Power BI Desktop for viewing .pbix files
1. SQL Server Management Studio for running T-SQL queries
1. (Optional) Python 3.7+ for running visualization scripts
1. (Optional) Kyvos platform for OLAP analysis

## Running the sample

### SQL Queries

1. Execute the queries in `12-month-trends.sql` against your WideWorldImportersDW database
2. The queries will return monthly revenue and margin metrics for the past 12 months
3. Use `kyvos-data-model.sql` to create optimized summary tables for Kyvos integration

### Power BI Dashboard

1. Open `WWIDW-Revenue-Margin-Trends.pbix` in Power BI Desktop
2. Update the data source connection to point to your WideWorldImportersDW database
3. Refresh the data to load current metrics
4. Explore the interactive visualizations:
   - 12-month revenue trend lines
   - Margin percentage trends
   - Year-over-year comparisons
   - Monthly KPI cards

### Python Visualization Scripts

1. Install required packages: `pip install pandas matplotlib seaborn pyodbc`
2. Update database connection strings in the Python scripts
3. Run `generate-revenue-trends.py` to create sample revenue charts
4. Run `generate-margin-analysis.py` to create margin trend visualizations

## Power BI Dashboard

The `WWIDW-Revenue-Margin-Trends.pbix` dashboard includes:

- **Revenue Trends**: Line chart showing 12-month revenue including and excluding tax
- **Margin Analysis**: Line chart displaying margin percentage trends over time
- **YoY Comparison**: Bar chart comparing year-over-year revenue growth
- **KPI Cards**: Current month vs previous month metrics
- **Interactive Filters**: Date slicers and dimension filters

## Kyvos Integration

For Kyvos platform integration:

1. Execute `kyvos-data-model.sql` to create optimized summary tables
2. Use the pre-aggregated data for faster OLAP queries
3. Import the dimensional model into Kyvos for cube creation
4. Leverage the indexed time-series data for interactive analysis

## Sample details

The solution leverages the existing WideWorldImportersDW schema:

- **Fact.Sale table**: Contains revenue (`Total Including Tax`, `Total Excluding Tax`) and profit data
- **Dimension.Date table**: Provides comprehensive time dimensions for trending analysis
- **Analysis Services cubes**: Pre-built measures for consistent calculations

Key metrics calculated:
- Monthly revenue totals (including and excluding tax)
- Monthly profit and margin percentages
- Rolling 12-month windows
- Year-over-year growth comparisons
- Month-over-month changes

## Disclaimers

The code included in this sample is not intended to be used for production purposes.
