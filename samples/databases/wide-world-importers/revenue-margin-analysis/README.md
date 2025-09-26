# WideWorldImporters Revenue & Margin Trends Analysis

This solution provides comprehensive 12-month revenue and margin trend analysis from the WideWorldImportersDW database, with full compatibility for PowerBI and Kyvos analytics platforms.

## Overview

The solution extracts, processes, and visualizes revenue and margin trends from the WideWorldImporters data warehouse, providing insights into business performance over a rolling 12-month period. Data is stored in Supabase for real-time access and presented through an interactive HTML dashboard.

## Features

- **SQL Queries**: Optimized queries for WideWorldImportersDW database
- **PowerBI/Kyvos Compatibility**: Standard data formats and structures
- **Supabase Integration**: Cloud storage via MCP connection
- **Interactive Visualization**: Professional HTML dashboard with Chart.js
- **Data Export**: CSV and JSON formats for external analysis
- **Responsive Design**: Works on desktop and mobile devices

## Directory Structure

```
revenue-margin-analysis/
├── sql/
│   └── revenue_margin_trends.sql     # Main SQL queries
├── scripts/
│   └── data_processor.py             # Data processing and Supabase integration
├── visualization/
│   ├── index.html                    # Main dashboard
│   ├── styles.css                    # Styling
│   ├── script.js                     # JavaScript functionality
│   └── data.json                     # Sample data (generated)
├── exports/
│   ├── revenue_margin_trends.csv     # PowerBI-compatible CSV
│   ├── revenue_margin_trends.json    # Kyvos-compatible JSON
│   ├── supabase_data.json           # Supabase-ready data
│   └── metadata.json                # Data structure metadata
└── README.md                         # This file
```

## Database Schema

The solution uses the following WideWorldImportersDW tables:

### Fact.Sale
- `[Total Including Tax]` - Total revenue including tax
- `[Total Excluding Tax]` - Revenue excluding tax
- `[Profit]` - Margin/profit amount
- `[Tax Amount]` - Tax component
- `[Invoice Date Key]` - Links to date dimension

### Dimension.Date
- `[Calendar Month Year Label]` - Month-year display format
- `[Calendar Year]` - Year number
- `[Calendar Month Number]` - Month number
- `[Year Month Key]` - Sortable year-month key

## SQL Query Features

The main query (`revenue_margin_trends.sql`) provides:

1. **Rolling 12-Month Window**: Automatically adjusts to current date
2. **Monthly Aggregations**: Revenue, margin, and transaction counts
3. **Growth Calculations**: Month-over-month percentage changes
4. **Year-to-Date Totals**: Running totals within each year
5. **PowerBI/Kyvos Format**: Clean, standardized column names and data types

### Key Metrics

- **Total Revenue**: Sum of all sales including tax
- **Total Margin**: Profit from all transactions
- **Margin Percentage**: Profit margin as percentage of revenue
- **Revenue Growth**: Month-over-month revenue change percentage
- **Margin Growth**: Month-over-month margin change percentage
- **Transaction Count**: Number of sales transactions
- **Average Transaction Value**: Revenue per transaction

## Usage Instructions

### 1. Execute SQL Queries

Run the SQL queries against your WideWorldImportersDW database:

```sql
-- Execute the main query from sql/revenue_margin_trends.sql
-- This will return 12 months of trend data
```

### 2. Process Data

Run the Python data processor:

```bash
cd scripts/
python data_processor.py
```

This will:
- Generate sample data (or process real SQL results)
- Export PowerBI/Kyvos compatible files
- Prepare data for Supabase storage
- Create visualization data files

### 3. View Dashboard

Open `visualization/index.html` in a web browser to view the interactive dashboard.

### 4. Supabase Integration

The solution includes MCP integration for Supabase. To use with real Supabase data:

1. Ensure Supabase MCP server is configured
2. Create the revenue trends table in Supabase
3. Use the MCP commands to insert processed data
4. Configure the dashboard to fetch from Supabase

## PowerBI Integration

To use with PowerBI:

1. Import `exports/revenue_margin_trends.csv`
2. Use the provided column mappings in `metadata.json`
3. Create visualizations using the standardized field names
4. Set up automatic refresh if connected to live Supabase data

## Kyvos Integration

To use with Kyvos:

1. Import `exports/revenue_margin_trends.json`
2. Use the data structure defined in `metadata.json`
3. Create OLAP cubes using the time and measure dimensions
4. Set up scheduled data refreshes

## Dashboard Features

The HTML dashboard provides:

- **KPI Cards**: Key metrics with growth indicators
- **Interactive Charts**: Line, bar, and combined chart types
- **Data Table**: Detailed monthly breakdown
- **Export Functions**: Download data in multiple formats
- **Responsive Design**: Works on all device sizes
- **Real-time Updates**: Refresh from Supabase integration

## Customization

### Adding New Metrics

1. Modify the SQL query to include additional calculations
2. Update the data processor to handle new fields
3. Add new chart datasets in the JavaScript
4. Update the data table columns

### Styling Changes

Modify `visualization/styles.css` to customize:
- Color schemes
- Layout and spacing
- Chart appearances
- Responsive breakpoints

### Chart Types

The dashboard supports:
- Line charts for trend analysis
- Bar charts for period comparisons
- Combined charts for multiple metrics
- Growth rate visualizations

## Technical Requirements

- **Database**: SQL Server with WideWorldImportersDW
- **Python**: 3.7+ for data processing
- **Browser**: Modern browser with JavaScript enabled
- **Supabase**: Account and project for cloud storage (optional)

## Data Compatibility

The solution ensures compatibility with:

- **PowerBI**: Standard CSV format with proper data types
- **Kyvos**: JSON format with hierarchical structure
- **Excel**: Direct CSV import capability
- **Tableau**: Standard data source format
- **Other BI Tools**: Generic CSV/JSON formats

## Performance Considerations

- SQL queries use proper indexing on date columns
- Data is pre-aggregated at monthly level
- Charts are optimized for 12-month datasets
- Responsive design minimizes mobile data usage

## Security Notes

- No sensitive data is exposed in the visualization
- All database connections should use proper authentication
- Supabase integration uses secure MCP protocols
- Export files should be handled according to data governance policies

## Support and Maintenance

For issues or enhancements:

1. Check the SQL query execution plans for performance
2. Verify data types match between database and visualization
3. Ensure Supabase MCP connection is properly configured
4. Test dashboard functionality across different browsers

## License

This solution is part of the Microsoft SQL Server samples repository and follows the same licensing terms.
