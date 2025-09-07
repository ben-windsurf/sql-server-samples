# PowerBI Revenue and Margin Trends Dashboard

This directory contains PowerBI templates and configuration files for visualizing 12-month revenue and margin trends from the WideWorldImportersDW database.

## Files

- `Revenue-Margin-Trends.pbit` - Main PowerBI template file
- `data-model-config.json` - Data model configuration settings
- `sample-parameters.json` - Sample parameter values for testing

## Setup Instructions

### 1. Prerequisites
- PowerBI Desktop (latest version recommended)
- Access to WideWorldImportersDW database
- SQL Server connection permissions

### 2. Opening the Template
1. Download and open `Revenue-Margin-Trends.pbit` in PowerBI Desktop
2. When prompted, enter your database connection parameters:
   - **Server**: Your SQL Server instance name
   - **Database**: WideWorldImportersDW
   - **Date Range Start**: Start date for analysis (default: 12 months ago)
   - **Date Range End**: End date for analysis (default: current date)

### 3. Data Source Configuration
1. Go to **Home** → **Transform Data** → **Data Source Settings**
2. Select the WideWorldImportersDW connection
3. Click **Change Source** and update:
   - Server name
   - Database name
   - Authentication method (Windows/SQL Server)
4. Click **OK** and **Close**

### 4. Refresh Data
1. Click **Home** → **Refresh** to load the latest data
2. Wait for all queries to complete (may take 2-5 minutes depending on data volume)

## Dashboard Features

### Overview Page
- **Revenue Trend Line Chart**: Monthly revenue over 12 months
- **Margin Trend Line Chart**: Monthly profit margins over 12 months
- **KPI Cards**: Current month vs. previous month comparisons
- **YTD Summary**: Year-to-date totals and growth rates

### Detailed Analysis Page
- **Revenue by Customer Segment**: Bar chart showing segment performance
- **Product Category Performance**: Matrix showing top products by revenue and margin
- **Geographic Distribution**: Map visualization of sales by region
- **Seasonal Patterns**: Heatmap showing monthly patterns across years

### Trend Analysis Page
- **Rolling 12-Month Metrics**: Line charts with rolling averages
- **Year-over-Year Comparison**: Side-by-side monthly comparisons
- **Growth Rate Analysis**: Waterfall charts showing growth drivers
- **Forecast Indicators**: Trend lines with confidence intervals

## Customization Options

### Date Range Parameters
- Modify the date range by updating parameters in **Home** → **Transform Data** → **Manage Parameters**
- Available parameters:
  - `StartDate`: Beginning of analysis period
  - `EndDate`: End of analysis period
  - `FiscalYearStart`: Fiscal year start month (1-12)

### Filter Options
- **Customer Segment**: Filter by customer categories
- **Product Categories**: Focus on specific product lines
- **Geographic Regions**: Analyze specific territories
- **Date Granularity**: Switch between daily, weekly, monthly views

### Visual Customizations
- **Color Themes**: Modify colors in **View** → **Themes**
- **Chart Types**: Right-click visuals to change chart types
- **Formatting**: Use the Format pane to adjust fonts, colors, and layouts

## Data Model Details

### Primary Tables
- **FactSales**: Main sales fact table with revenue and profit measures
- **DimDate**: Date dimension with calendar and fiscal hierarchies
- **DimCustomer**: Customer dimension for segmentation
- **DimProduct**: Product dimension for category analysis

### Key Measures
- **Revenue Excluding Tax**: Base revenue measure
- **Revenue Including Tax**: Total revenue with tax
- **Profit**: Margin measure (Revenue - Cost)
- **Margin %**: Calculated as Profit / Revenue Excluding Tax
- **YoY Growth %**: Year-over-year growth calculation
- **Rolling 12M Revenue**: 12-month rolling sum

### Relationships
- FactSales → DimDate (Invoice Date Key)
- FactSales → DimCustomer (Customer Key)
- FactSales → DimProduct (Stock Item Key)
- FactSales → DimCity (City Key)

## Performance Optimization

### Query Performance
- Date filters are applied at the source level
- Aggregations are pre-calculated where possible
- DirectQuery mode is used for real-time data

### Refresh Strategy
- **Scheduled Refresh**: Set up automatic refresh in PowerBI Service
- **Incremental Refresh**: Configure for large datasets (>1GB)
- **Real-time Updates**: Use DirectQuery for live dashboards

## Troubleshooting

### Common Issues

**Connection Errors**
- Verify SQL Server instance name and database name
- Check network connectivity and firewall settings
- Ensure proper authentication credentials

**Slow Performance**
- Reduce date range for initial testing
- Check SQL Server performance and indexing
- Consider using Import mode instead of DirectQuery

**Missing Data**
- Verify WideWorldImportersDW contains sample data
- Check date range parameters match available data
- Ensure all required tables and columns exist

**Visual Errors**
- Refresh data model after schema changes
- Check measure calculations for divide-by-zero errors
- Verify relationship integrity between tables

### Support Resources
- PowerBI Community Forums
- Microsoft PowerBI Documentation
- WideWorldImporters Sample Database Documentation

## Advanced Features

### Custom Calculations
Add custom DAX measures for specific business requirements:

```dax
Revenue Growth % = 
DIVIDE(
    [Revenue Excluding Tax] - [Revenue Excluding Tax Previous Month],
    [Revenue Excluding Tax Previous Month],
    0
) * 100

Margin Trend = 
IF(
    [Margin % Current Month] > [Margin % Previous Month],
    "↗ Improving",
    IF(
        [Margin % Current Month] < [Margin % Previous Month],
        "↘ Declining",
        "→ Stable"
    )
)
```

### Export Options
- **PDF Reports**: File → Export → Export to PDF
- **PowerPoint**: File → Export → Export to PowerPoint
- **Excel Data**: Right-click visuals → Export Data
- **Image Files**: Right-click visuals → Export as Image

## Version History
- v1.0: Initial template with basic revenue and margin trends
- Future versions will include forecasting and advanced analytics features
