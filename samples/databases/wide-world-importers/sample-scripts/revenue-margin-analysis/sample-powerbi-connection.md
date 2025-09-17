# PowerBI Connection Setup for WideWorldImportersDW Revenue Analysis

This guide provides step-by-step instructions for connecting PowerBI to the WideWorldImportersDW database and using the revenue and margin analysis views.

## Prerequisites

- PowerBI Desktop installed
- Access to SQL Server instance with WideWorldImportersDW database
- Appropriate database permissions (db_datareader minimum)

## Connection Steps

### 1. Open PowerBI Desktop

1. Launch PowerBI Desktop
2. Click **Get Data** on the Home ribbon
3. Select **SQL Server** from the database options

### 2. Configure Database Connection

```
Server: [Your SQL Server Instance]
Database: WideWorldImportersDW
Data Connectivity mode: Import (recommended) or DirectQuery
```

**Example Connection Strings:**
- Local SQL Server: `localhost` or `.\SQLEXPRESS`
- Named Instance: `ServerName\InstanceName`
- Azure SQL Database: `servername.database.windows.net`

### 3. Authentication

Choose appropriate authentication method:
- **Windows Authentication** (for on-premises SQL Server)
- **SQL Server Authentication** (username/password)
- **Azure Active Directory** (for Azure SQL Database)

### 4. Select Data Tables/Views

Navigate to the **WideWorldImportersDW** database and select:

**Primary Views:**
- `dbo.vw_12MonthRevenueMarginsAnalysis` - Comprehensive trend analysis
- `dbo.vw_PowerBI_RevenueMarginTrends` - PowerBI-optimized view
- `dbo.vw_PowerBI_RevenueSummaryKPIs` - Summary KPIs for dashboard cards

**Supporting Tables (if needed):**
- `Fact.Sale` - Raw sales data
- `Dimension.Date` - Date dimension for custom time intelligence
- `Dimension.Customer` - Customer information
- `Dimension.City` - Geographic data

### 5. Data Transformation (Power Query)

After loading data, consider these transformations:

```m
// Ensure proper data types
= Table.TransformColumnTypes(Source,{
    {"SalesDate", type date},
    {"Revenue", Currency.Type},
    {"Profit", Currency.Type},
    {"MarginPercent", Percentage.Type}
})

// Create date hierarchy
= Table.AddColumn(#"Changed Type", "Year", each Date.Year([SalesDate]))
= Table.AddColumn(#"Added Year", "Month", each Date.Month([SalesDate]))
= Table.AddColumn(#"Added Month", "Quarter", each Date.QuarterOfYear([SalesDate]))
```

## Recommended Data Model Setup

### 1. Relationships

If using multiple tables, establish these relationships:
- `vw_PowerBI_RevenueMarginTrends[SalesDate]` → `Dimension.Date[Date]` (Many-to-One)
- `Fact.Sale[Customer Key]` → `Dimension.Customer[Customer Key]` (Many-to-One)

### 2. Calculated Measures

Create these DAX measures for enhanced analysis:

```dax
// Revenue Growth Rate
Revenue Growth % = 
VAR CurrentRevenue = SUM(vw_PowerBI_RevenueMarginTrends[Revenue])
VAR PreviousRevenue = CALCULATE(
    SUM(vw_PowerBI_RevenueMarginTrends[Revenue]),
    DATEADD(vw_PowerBI_RevenueMarginTrends[SalesDate], -1, MONTH)
)
RETURN
DIVIDE(CurrentRevenue - PreviousRevenue, PreviousRevenue, 0)

// Average Margin
Average Margin % = 
DIVIDE(
    SUM(vw_PowerBI_RevenueMarginTrends[Profit]),
    SUM(vw_PowerBI_RevenueMarginTrends[Revenue]),
    0
)

// Revenue Target Achievement
Revenue Achievement % = 
VAR RevenueTarget = 1000000 // Set your target
RETURN
DIVIDE(SUM(vw_PowerBI_RevenueMarginTrends[Revenue]), RevenueTarget, 0)

// YTD Revenue
YTD Revenue = 
TOTALYTD(
    SUM(vw_PowerBI_RevenueMarginTrends[Revenue]),
    vw_PowerBI_RevenueMarginTrends[SalesDate]
)

// Previous Year Same Period
PY Revenue = 
CALCULATE(
    SUM(vw_PowerBI_RevenueMarginTrends[Revenue]),
    SAMEPERIODLASTYEAR(vw_PowerBI_RevenueMarginTrends[SalesDate])
)
```

### 3. Calculated Columns

Add these calculated columns for enhanced filtering:

```dax
// Revenue Size Category
Revenue Category = 
SWITCH(
    TRUE(),
    vw_PowerBI_RevenueMarginTrends[Revenue] >= 100000, "Large",
    vw_PowerBI_RevenueMarginTrends[Revenue] >= 50000, "Medium",
    "Small"
)

// Margin Performance
Margin Performance = 
SWITCH(
    TRUE(),
    vw_PowerBI_RevenueMarginTrends[MarginPercent] >= 20, "Excellent",
    vw_PowerBI_RevenueMarginTrends[MarginPercent] >= 15, "Good",
    vw_PowerBI_RevenueMarginTrends[MarginPercent] >= 10, "Average",
    "Below Average"
)
```

## Sample Dashboard Layout

### Page 1: Executive Summary
- **KPI Cards**: Current Month Revenue, Margin %, Growth Rate
- **Line Chart**: 12-Month Revenue Trend
- **Gauge**: Revenue Target Achievement
- **Donut Chart**: Revenue by Margin Category

### Page 2: Detailed Analysis
- **Matrix**: Monthly Revenue and Margin by Year
- **Column Chart**: Month-over-Month Growth
- **Scatter Plot**: Revenue vs. Margin by Month
- **Table**: Top/Bottom Performing Months

### Page 3: Comparative Analysis
- **Line Chart**: Current Year vs. Previous Year Revenue
- **Waterfall Chart**: Revenue Growth Contributors
- **Heat Map**: Monthly Performance Matrix
- **Slicer Panel**: Date Range, Customer Category filters

## Performance Optimization Tips

### 1. Import vs. DirectQuery
- **Import Mode**: Better performance for smaller datasets (<1GB)
- **DirectQuery**: Real-time data but slower performance
- **Composite Model**: Mix of both for optimal balance

### 2. Data Reduction
```m
// Filter to relevant date range during import
= Table.SelectRows(Source, each [SalesDate] >= #date(2020,1,1))

// Remove unnecessary columns
= Table.RemoveColumns(Source, {"Column1", "Column2"})
```

### 3. Aggregations
- Use the PowerBI-optimized views which pre-aggregate data
- Consider creating aggregation tables for large datasets
- Use SUMMARIZE functions in DAX for complex calculations

## Refresh Schedule

### Automatic Refresh (PowerBI Service)
1. Publish report to PowerBI Service
2. Configure data source credentials
3. Set refresh schedule (daily/weekly recommended)
4. Monitor refresh history for failures

### Manual Refresh
- Click **Refresh** in PowerBI Desktop
- Use **Refresh Now** in PowerBI Service
- Schedule during off-peak hours for large datasets

## Troubleshooting

### Common Connection Issues
1. **Firewall**: Ensure SQL Server port (1433) is open
2. **Authentication**: Verify credentials and permissions
3. **Network**: Check VPN/network connectivity
4. **SSL**: May need to disable SSL for local connections

### Performance Issues
1. **Reduce data volume**: Filter date ranges, remove unused columns
2. **Optimize queries**: Use views instead of complex joins
3. **Check indexes**: Ensure proper indexing on date and key columns
4. **Monitor refresh times**: Identify slow-loading tables

### Data Quality Issues
1. **Null values**: Handle with COALESCE or ISNULL in SQL views
2. **Data types**: Ensure consistent formatting (dates, currencies)
3. **Duplicates**: Check for duplicate records in source data
4. **Relationships**: Verify foreign key relationships are valid

## Security Considerations

- Use least-privilege database accounts
- Implement row-level security if needed
- Secure connection strings and credentials
- Regular access reviews for PowerBI workspaces
- Consider Azure AD integration for enterprise deployments
