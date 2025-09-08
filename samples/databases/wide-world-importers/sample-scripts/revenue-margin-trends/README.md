# Revenue and Margin Trends Analysis

This directory contains SQL queries for analyzing 12-month revenue and margin trends in the WideWorldImportersDW sample database, with compatibility for PowerBI and Kyvos platforms.

## Overview

The WideWorldImportersDW database contains comprehensive sales data with revenue and profit information stored in the `Fact.Sale` table. These queries leverage the existing data warehouse structure to provide business intelligence insights for revenue and margin analysis.

## Files Description

### 1. `12-month-revenue-margin-trends.sql`
**Purpose**: Comprehensive 12-month revenue and margin analysis with year-over-year comparisons.

**Key Features**:
- Monthly revenue aggregation (`Total Excluding Tax`, `Total Including Tax`)
- Profit margin calculations using the `Profit` column from `Fact.Sale`
- Year-over-year growth percentages
- Average transaction values and profit per transaction
- Margin improvement analysis

**Sample Output Columns**:
- `Revenue Excluding Tax`, `Revenue Including Tax`, `Total Profit`
- `Profit Margin Percentage`, `Revenue Growth Percentage`
- `Previous Year Revenue Excluding Tax`, `Margin Improvement Points`

### 2. `powerbi-revenue-trends.sql`
**Purpose**: PowerBI-optimized query with simplified column names and pre-calculated measures.

**Key Features**:
- Simplified column names for PowerBI consumption (`Revenue`, `Profit`, `ProfitMarginPercent`)
- Pre-calculated time period flags (`Current Month`, `Last 3 Months`, etc.)
- Profitability status categories (`Profitable`, `Break Even`, `Loss`)
- Margin categories (`High Margin (20%+)`, `Medium Margin (10-20%)`, etc.)
- Separate summary metrics query for KPI cards

**PowerBI Integration**:
- Import both queries as separate tables
- Use the main query for detailed analysis and visualizations
- Use the summary query for KPI cards and dashboard metrics

### 3. `kyvos-compatible-trends.sql`
**Purpose**: OLAP-style hierarchical structure compatible with Kyvos cube analysis.

**Key Features**:
- Hierarchical time dimensions (Year > Quarter > Month)
- Customer and product hierarchies for drill-down analysis
- SSAS cube naming conventions (`Sales_Total_Excluding_Tax`, `Sales_Profit`)
- Time intelligence calculations (YTD, previous year comparisons)
- Compatible with MDX-style analysis patterns

**Kyvos Integration**:
- Use the hierarchical structure for cube building
- Leverage time intelligence measures for trend analysis
- Compatible with existing SSAS cube patterns in the sample database

## Data Sources

### Fact Table
- **`Fact.Sale`**: Contains transaction-level sales data with revenue and profit columns
  - `Total Excluding Tax`: Revenue before tax
  - `Total Including Tax`: Revenue including tax
  - `Profit`: Calculated profit margin per transaction
  - `Quantity`: Units sold
  - `Unit Price`: Price per unit

### Dimension Tables
- **`Dimension.Date`**: Comprehensive date dimension with calendar and fiscal hierarchies
- **`Dimension.Customer`**: Customer information including territory and category
- **`Dimension.Stock Item`**: Product information including brand and color

## Usage Instructions

### For PowerBI
1. Connect to your WideWorldImportersDW database
2. Import the `powerbi-revenue-trends.sql` query as a new table
3. Import the summary metrics query as a separate table for KPIs
4. Create relationships between tables if needed
5. Build visualizations using the simplified column names

**Recommended Visualizations**:
- Line chart for monthly revenue trends
- Bar chart for profit margin by product/customer
- KPI cards for growth percentages
- Matrix table for detailed drill-down analysis

### For Kyvos
1. Use the `kyvos-compatible-trends.sql` query as a data source
2. Build cube dimensions using the hierarchical structure:
   - Time: Year > Quarter > Month
   - Customer: Territory > City > Customer
   - Product: Brand > Product > Color
3. Create measures using the aggregated values
4. Implement time intelligence using the YTD calculations

### For General Analysis
1. Run the `12-month-revenue-margin-trends.sql` query for comprehensive analysis
2. Adjust the date filters as needed for different time periods
3. Export results to Excel or other analysis tools
4. Use the year-over-year comparisons for trend identification

## Customization Options

### Date Range Modification
```sql
-- Change the 12-month period
WHERE d.[Date] >= DATEADD(MONTH, -18, GETDATE())  -- 18 months instead of 12
```

### Additional Filters
```sql
-- Filter by customer category
AND c.[Category] = 'Retail'

-- Filter by product brand
AND si.[Brand] = 'Wide World Importers'

-- Filter by sales territory
AND c.[Sales Territory] = 'Great Lakes'
```

### Custom Margin Calculations
```sql
-- Alternative margin calculation
(s.[Total Including Tax] - s.[Tax Amount] - (s.[Total Excluding Tax] - s.[Profit])) / s.[Total Including Tax] * 100 AS [Alternative Margin]
```

## Performance Considerations

- The queries use appropriate indexes on date keys for optimal performance
- Consider adding WHERE clauses to limit data volume for large datasets
- The `Fact.Sale` table uses columnstore indexing for analytical workloads
- Date filtering is optimized using the partitioned structure

## Integration with Existing SSAS Cubes

These queries follow the same patterns as the existing SSAS cube measures in the WideWorldImporters sample:
- Time intelligence calculations match the YTD patterns in `Wide World Importers.cube`
- Measure naming conventions align with existing cube structure
- Hierarchical dimensions mirror the cube design

## Sample Results

The queries will return data similar to:

| Month Year | Revenue Excluding Tax | Total Profit | Profit Margin Percentage | Revenue Growth Percentage |
|------------|----------------------|--------------|-------------------------|---------------------------|
| Jan-2024   | $125,000.00         | $25,000.00   | 20.00%                  | 15.5%                     |
| Feb-2024   | $135,000.00         | $28,000.00   | 20.74%                  | 12.3%                     |
| Mar-2024   | $142,000.00         | $30,000.00   | 21.13%                  | 18.7%                     |

## Prerequisites

- SQL Server 2016 or higher (or Azure SQL Database)
- WideWorldImportersDW sample database installed
- Appropriate read permissions on the data warehouse tables
- PowerBI Desktop (for PowerBI integration)
- Kyvos platform (for Kyvos integration)

## Related Resources

- [WideWorldImporters Sample Database Documentation](../../../README.md)
- [PowerBI Dashboards](../../power-bi-dashboards/README.md)
- [SSAS Cube Project](../../wwi-ssasmd/README.md)
- [Data Warehouse SSDT Project](../../wwi-dw-ssdt/README.md)
