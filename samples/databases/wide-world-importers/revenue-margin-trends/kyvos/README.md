# Kyvos OLAP Cube for Revenue and Margin Trends

This directory contains Kyvos Analytics Platform definitions for creating OLAP cubes to analyze 12-month revenue and margin trends from the WideWorldImportersDW database.

## Files

- `WWI-Revenue-Margin-Cube.xml` - Main cube definition file
- `dimension-hierarchies.xml` - Date and customer dimension hierarchies
- `calculated-measures.xml` - MDX calculated measures for trend analysis
- `sample-mdx-queries.mdx` - Sample MDX queries for common analysis scenarios
- `cube-deployment-script.sql` - SQL script for cube deployment preparation

## Cube Overview

### Fact Tables
- **Fact.Sale** - Primary sales transactions with revenue and profit measures
- **Fact.Order** - Order data for pipeline analysis
- **Fact.Transaction** - Financial transaction details

### Dimensions
- **Date** - Rich date dimension with calendar and fiscal hierarchies
- **Customer** - Customer segmentation and geographic attributes
- **Product** - Stock item categories and product attributes
- **Employee** - Salesperson and organizational hierarchy
- **Geography** - City, state, and sales territory dimensions

### Measures
- **Base Measures**: Revenue Excluding Tax, Revenue Including Tax, Profit, Quantity
- **Calculated Measures**: Margin %, YoY Growth %, Rolling 12M totals, Trend indicators

## Setup Instructions

### 1. Prerequisites
- Kyvos Analytics Platform (version 2024.1 or later)
- Access to WideWorldImportersDW database
- Kyvos Cube Designer permissions
- SQL Server OLAP Services (optional, for hybrid deployment)

### 2. Import Cube Definition
1. Open Kyvos Cube Designer
2. Go to **File** → **Import Cube Definition**
3. Select `WWI-Revenue-Margin-Cube.xml`
4. Configure data source connection:
   - **Connection Type**: SQL Server
   - **Server**: Your SQL Server instance
   - **Database**: WideWorldImportersDW
   - **Authentication**: Windows/SQL Server authentication

### 3. Configure Dimensions
1. Review dimension hierarchies in the Cube Designer
2. Modify date hierarchies if needed:
   - **Calendar Hierarchy**: Year → Quarter → Month → Date
   - **Fiscal Hierarchy**: Fiscal Year → Fiscal Quarter → Fiscal Month → Date
   - **Week Hierarchy**: Year → Week → Date
3. Set up customer hierarchies:
   - **Geographic**: Sales Territory → State Province → City → Customer
   - **Segmentation**: Customer Category → Buying Group → Customer

### 4. Deploy Cube
1. Click **Build** → **Deploy Cube**
2. Select deployment target (Kyvos Server or SQL Server Analysis Services)
3. Configure processing options:
   - **Full Process**: Complete cube build (recommended for initial deployment)
   - **Incremental Process**: Update with new data only
4. Monitor deployment progress in the Build Log

### 5. Process Cube Data
1. After successful deployment, go to **Cube Management**
2. Select the WWI Revenue Margin cube
3. Click **Process** → **Process Full**
4. Wait for processing to complete (may take 10-30 minutes depending on data volume)

## Cube Structure

### Measure Groups

#### Sales Measure Group
- **Revenue Excluding Tax**: SUM([Fact].[Sale].[Total Excluding Tax])
- **Revenue Including Tax**: SUM([Fact].[Sale].[Total Including Tax])
- **Profit**: SUM([Fact].[Sale].[Profit])
- **Quantity**: SUM([Fact].[Sale].[Quantity])
- **Invoice Count**: COUNT(DISTINCT [Fact].[Sale].[WWI Invoice ID])

#### Calculated Measures
- **Margin %**: [Profit] / [Revenue Excluding Tax] * 100
- **Revenue YoY Growth %**: ([Revenue Excluding Tax] - [Revenue Excluding Tax PY]) / [Revenue Excluding Tax PY] * 100
- **Rolling 12M Revenue**: SUM(LastPeriods(12, [Date].[Calendar].[Month].CurrentMember), [Revenue Excluding Tax])
- **Revenue Trend**: Custom MDX for trend direction indicators

### Dimension Hierarchies

#### Date Dimension
```
Calendar Hierarchy:
├── All Periods
    ├── Calendar Year (2013, 2014, 2015, ...)
        ├── Calendar Quarter (Q1, Q2, Q3, Q4)
            ├── Calendar Month (Jan, Feb, Mar, ...)
                └── Date (2013-01-01, 2013-01-02, ...)

Fiscal Hierarchy:
├── All Fiscal Periods
    ├── Fiscal Year (FY2013, FY2014, ...)
        ├── Fiscal Quarter (FQ1, FQ2, FQ3, FQ4)
            ├── Fiscal Month (Jul, Aug, Sep, ...)
                └── Date
```

#### Customer Dimension
```
Geographic Hierarchy:
├── All Customers
    ├── Sales Territory (External, Far West, Great Lakes, ...)
        ├── State Province (California, Illinois, Texas, ...)
            ├── City (Los Angeles, Chicago, Houston, ...)
                └── Customer (Tailspin Toys, Wingtip Toys, ...)

Category Hierarchy:
├── All Categories
    ├── Customer Category (Novelty Shop, Supermarket, Computer Store, ...)
        ├── Buying Group (Tailspin Toys, Wingtip Toys, ...)
            └── Customer
```

## MDX Query Examples

### Monthly Revenue Trend
```mdx
SELECT 
    [Measures].[Revenue Excluding Tax] ON COLUMNS,
    [Date].[Calendar].[Month].Members ON ROWS
FROM [WWI Revenue Margin Cube]
WHERE [Date].[Calendar].[Year].[2016]
```

### Year-over-Year Growth Analysis
```mdx
WITH 
MEMBER [Measures].[Revenue Growth %] AS
    ([Measures].[Revenue Excluding Tax] - 
     ([Measures].[Revenue Excluding Tax], ParallelPeriod([Date].[Calendar].[Year], 1))) /
    ([Measures].[Revenue Excluding Tax], ParallelPeriod([Date].[Calendar].[Year], 1)) * 100

SELECT 
    {[Measures].[Revenue Excluding Tax], [Measures].[Revenue Growth %]} ON COLUMNS,
    [Date].[Calendar].[Month].Members ON ROWS
FROM [WWI Revenue Margin Cube]
WHERE [Date].[Calendar].[Year].[2016]
```

### Top 10 Customers by Revenue
```mdx
SELECT 
    [Measures].[Revenue Excluding Tax] ON COLUMNS,
    TopCount([Customer].[Customer].[Customer].Members, 10, [Measures].[Revenue Excluding Tax]) ON ROWS
FROM [WWI Revenue Margin Cube]
WHERE [Date].[Calendar].[Year].[2016]
```

### Rolling 12-Month Analysis
```mdx
WITH 
MEMBER [Measures].[Rolling 12M Revenue] AS
    SUM(LastPeriods(12, [Date].[Calendar].[Month].CurrentMember), [Measures].[Revenue Excluding Tax])

SELECT 
    {[Measures].[Revenue Excluding Tax], [Measures].[Rolling 12M Revenue]} ON COLUMNS,
    [Date].[Calendar].[Month].Members ON ROWS
FROM [WWI Revenue Margin Cube]
```

### Margin Analysis by Product Category
```mdx
WITH 
MEMBER [Measures].[Margin %] AS
    [Measures].[Profit] / [Measures].[Revenue Excluding Tax] * 100

SELECT 
    {[Measures].[Revenue Excluding Tax], [Measures].[Profit], [Measures].[Margin %]} ON COLUMNS,
    [Product].[Stock Item].[Stock Item].Members ON ROWS
FROM [WWI Revenue Margin Cube]
WHERE [Date].[Calendar].[Year].[2016]
```

## Performance Optimization

### Aggregation Design
- **Monthly Aggregations**: Pre-calculate monthly totals for faster queries
- **Customer Segment Aggregations**: Aggregate by customer categories
- **Product Category Aggregations**: Aggregate by major product groups
- **Geographic Aggregations**: Aggregate by sales territories and states

### Partitioning Strategy
- **Date Partitioning**: Partition by year for better performance
- **Incremental Processing**: Process only new/changed data
- **Parallel Processing**: Enable parallel processing for large cubes

### Index Optimization
- Create indexes on fact table foreign keys
- Optimize dimension table primary keys
- Consider columnstore indexes for fact tables

## Monitoring and Maintenance

### Performance Monitoring
- Monitor query response times
- Track cube processing duration
- Monitor memory and CPU usage during processing

### Regular Maintenance
- **Daily**: Incremental processing for new data
- **Weekly**: Full processing of dimensions
- **Monthly**: Full cube processing and optimization
- **Quarterly**: Review and optimize aggregation design

## Troubleshooting

### Common Issues

**Cube Processing Errors**
- Check data source connectivity
- Verify dimension key integrity
- Review processing logs for specific errors

**Slow Query Performance**
- Check aggregation design
- Review MDX query efficiency
- Consider additional partitioning

**Memory Issues**
- Increase Kyvos server memory allocation
- Optimize dimension hierarchies
- Consider cube partitioning

### Support Resources
- Kyvos Documentation Portal
- Kyvos Community Forums
- Microsoft Analysis Services Documentation

## Advanced Features

### Custom Calculations
Create advanced MDX calculations for specific business requirements:

```mdx
-- Seasonal Index Calculation
MEMBER [Measures].[Seasonal Index] AS
    [Measures].[Revenue Excluding Tax] / 
    AVG([Date].[Calendar].[Month].Members, [Measures].[Revenue Excluding Tax])

-- Trend Direction Indicator
MEMBER [Measures].[Trend Direction] AS
    IIF([Measures].[Revenue Excluding Tax] > 
        ([Measures].[Revenue Excluding Tax], [Date].[Calendar].CurrentMember.PrevMember),
        "↗", "↘")
```

### Integration Options
- **Excel Integration**: Connect Excel PivotTables to Kyvos cubes
- **PowerBI Integration**: Use Kyvos as a data source for PowerBI
- **Tableau Integration**: Connect Tableau to Kyvos OLAP cubes
- **Custom Applications**: Use Kyvos REST APIs for custom dashboards

## Version History
- v1.0: Initial cube definition with basic revenue and margin measures
- Future versions will include predictive analytics and advanced KPIs
