# Revenue and Margin Trends Analysis Queries

This directory contains SQL queries for analyzing 12-month revenue and margin trends in the WideWorldImportersDW database. These queries are designed to be compatible with both PowerBI and Kyvos analytics platforms.

## Overview

The WideWorldImportersDW database contains comprehensive sales data with the following key measures:
- **Revenue**: `Total Excluding Tax` (net revenue), `Total Including Tax` (gross revenue)
- **Margins**: `Profit` (absolute profit), calculated profit margin percentages
- **Volume**: `Quantity` (units sold), transaction counts
- **Pricing**: `Unit Price`, `Tax Rate`

## Query Files

### 1. 12-month-revenue-margin-trends.sql
**Purpose**: Monthly revenue and margin analysis over a rolling 12-month period

**Key Features**:
- Monthly aggregation of revenue and profit metrics
- Profit margin percentage calculations
- Month-over-month growth analysis
- Rolling 12-month window using `DATEADD(MONTH, -12, GETDATE())`

**Output Columns**:
- Year, Month Number, Month Label, Month Year
- Revenue Excluding Tax, Revenue Including Tax, Total Tax Amount
- Total Profit, Profit Margin Percentage
- Total Quantity, Transaction Count
- Average Unit Price, Average Tax Rate
- Revenue Growth Percentage, Profit Growth Percentage

### 2. quarterly-revenue-summary.sql
**Purpose**: Executive-level quarterly revenue and margin summary

**Key Features**:
- Quarterly aggregation for executive reporting
- Quarter-over-quarter and year-over-year comparisons
- Suitable for high-level dashboard visualizations

**Output Columns**:
- Year, Quarter Number, Quarter Label, Quarter Year
- Revenue and profit metrics
- QoQ and YoY growth percentages
- Volume and pricing metrics

### 3. year-over-year-comparison.sql
**Purpose**: Annual performance comparison between current and previous year

**Key Features**:
- Yearly aggregation with previous year comparisons
- Customer and transaction analysis
- Revenue per customer calculations
- Comprehensive growth metrics

**Output Columns**:
- Current year and previous year metrics
- Revenue, profit, and margin growth percentages
- Customer and transaction growth analysis
- Average transaction value calculations

## PowerBI Integration

### Data Source Configuration
1. Connect PowerBI to your SQL Server instance hosting WideWorldImportersDW
2. Import the query results as datasets
3. Use the provided column names for automatic field recognition

### Recommended Visualizations
- **Line Charts**: Monthly/quarterly revenue and profit trends
- **Bar Charts**: Year-over-year comparisons
- **KPI Cards**: Current period metrics and growth percentages
- **Tables**: Detailed monthly/quarterly breakdowns

### PowerBI-Specific Notes
- All monetary values are formatted as DECIMAL(18,2) for proper currency display
- Percentage calculations are provided as numeric values (multiply by 100 for display)
- Date fields use standard SQL Server date formats compatible with PowerBI

## Kyvos Integration

### OLAP Cube Compatibility
- Queries use standard SQL syntax compatible with Kyvos SQL interface
- Aggregation functions (SUM, AVG, COUNT) are optimized for OLAP processing
- Date hierarchies leverage existing dimension table structure

### Kyvos-Specific Considerations
- Window functions (LAG, OVER) are used for trend calculations
- CTEs (Common Table Expressions) provide modular query structure
- Standard ANSI SQL constructs ensure cross-platform compatibility

### Performance Optimization
- Queries filter on date ranges to limit data volume
- Proper indexing on `Invoice Date Key` recommended for performance
- Consider materializing results for frequently accessed reports

## Database Schema Dependencies

### Required Tables
- `Fact.Sale`: Primary fact table containing sales transactions
- `Dimension.Date`: Date dimension with calendar hierarchies

### Key Relationships
- `Fact.Sale.Invoice Date Key` → `Dimension.Date.Date`
- Foreign key relationships to customer, product, and employee dimensions

### Required Columns
**Fact.Sale**:
- `Sale Key`, `Invoice Date Key`
- `Total Excluding Tax`, `Total Including Tax`, `Tax Amount`
- `Profit`, `Quantity`, `Unit Price`, `Tax Rate`
- `Customer Key` (for customer analysis)

**Dimension.Date**:
- `Date`, `Calendar Year`, `Calendar Month Number`
- `Calendar Month Label`, `Calendar Quarter Number`
- Various date hierarchy fields for grouping

## Usage Examples

### Basic Monthly Trends
```sql
-- Execute the 12-month trends query
-- Results show monthly revenue and margin progression
```

### Executive Dashboard
```sql
-- Execute the quarterly summary query
-- Results suitable for executive-level reporting
```

### Performance Analysis
```sql
-- Execute the year-over-year comparison query
-- Results show annual performance metrics
```

## Data Quality Notes

- Queries include NULL handling for division operations
- Growth calculations handle zero/negative base values appropriately
- Date filtering ensures consistent 12-month rolling windows
- All percentage calculations are bounded and validated

## Troubleshooting

### Common Issues
1. **No Data Returned**: Verify WideWorldImportersDW database is populated with recent data
2. **Performance Issues**: Ensure proper indexing on date columns
3. **Incorrect Dates**: Check system date settings for rolling window calculations

### Validation Steps
1. Verify total revenue matches source system reports
2. Check profit margin calculations against business rules
3. Validate date ranges produce expected number of periods
4. Confirm growth calculations align with business expectations

## Support

For questions about these queries or the WideWorldImportersDW database structure, refer to:
- WideWorldImporters sample database documentation
- SQL Server Analysis Services cube definitions
- PowerBI and Kyvos platform documentation
