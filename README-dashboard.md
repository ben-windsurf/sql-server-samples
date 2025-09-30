# WideWorldImporters Revenue & Margin Dashboard

This dashboard provides comprehensive analysis of revenue and margin trends from the WideWorldImportersDW database over the last 12 months.

## Features

- **Monthly Revenue & Margin Trends**: Interactive line chart showing revenue, margin, and margin percentage over time
- **Quarterly Performance**: Bar chart comparing quarterly revenue and margin performance
- **Top Products Analysis**: Table showing the top 10 products by revenue with margin metrics
- **Customer Segment Analysis**: Table showing the top 10 customers by revenue with performance metrics
- **Key Metrics**: Summary cards showing total revenue, margin, average margin percentage, and transaction count

## Files Structure

```
├── revenue-margin-queries.sql     # SQL queries for extracting trend data
├── data-importer.py              # Python script for importing data to Supabase
├── dashboard/
│   ├── index.html                # Main dashboard HTML file
│   └── edge-function.js          # Supabase Edge Function for hosting
└── README-dashboard.md           # This documentation file
```

## Setup Instructions

### 1. Database Queries

The SQL queries in `revenue-margin-queries.sql` are designed to work with the WideWorldImportersDW database:

- **Monthly Trends**: Aggregates sales data by month with growth calculations
- **Quarterly Summary**: Groups data by quarters for broader trend analysis
- **Top Products**: Identifies best-performing products by revenue and margin
- **Customer Analysis**: Shows top customers by revenue with margin metrics

### 2. Data Import Setup

1. Install required Python packages:
   ```bash
   pip install requests
   ```

2. Set your Supabase API key:
   ```bash
   export SUPABASE_API_KEY='your_supabase_anon_key_here'
   ```

3. Run the data importer:
   ```bash
   python data-importer.py
   ```

The importer will:
- Create necessary tables in Supabase
- Generate sample data for demonstration
- Import the data into the dashboard tables

### 3. Dashboard Deployment

#### Option 1: Local Development
Simply open `dashboard/index.html` in a web browser. The dashboard will connect to the Supabase project to fetch data.

#### Option 2: Supabase Edge Function
Deploy the dashboard as a Supabase Edge Function for production hosting:

1. Install Supabase CLI
2. Deploy the edge function:
   ```bash
   supabase functions deploy dashboard --project-ref kzujalwtfxipkvjeqtms
   ```

### 4. Configuration

Update the Supabase configuration in `dashboard/index.html`:

```javascript
const SUPABASE_URL = 'https://kzujalwtfxipkvjeqtms.supabase.co';
const SUPABASE_ANON_KEY = 'your_anon_key_here';
```

## Database Schema

The dashboard uses the following Supabase tables:

### monthly_trends
- `year`, `month`: Time dimensions
- `revenue`, `margin`: Financial metrics
- `margin_percentage`: Calculated margin percentage
- `transaction_count`: Number of transactions
- `revenue_growth_percent`, `margin_growth_percent`: Month-over-month growth

### quarterly_trends
- `year`, `quarter`: Time dimensions
- `revenue`, `margin`: Aggregated quarterly metrics
- `margin_percentage`: Quarterly margin percentage

### top_products
- `product_name`: Product identifier
- `total_revenue`, `total_margin`: Product performance metrics
- `sales_count`: Number of sales transactions

### top_customers
- `customer_name`: Customer identifier
- `total_revenue`, `total_margin`: Customer value metrics
- `order_count`: Number of orders placed

## Usage

1. **Refresh Data**: Click the "Refresh Data" button to reload all dashboard data
2. **Interactive Charts**: Hover over chart elements to see detailed values
3. **Responsive Design**: Dashboard adapts to different screen sizes
4. **Real-time Updates**: Data refreshes automatically from Supabase

## Technical Details

- **Frontend**: Pure HTML/CSS/JavaScript with Chart.js for visualizations
- **Backend**: Supabase for data storage and API
- **Data Source**: WideWorldImportersDW SQL Server database
- **Styling**: Modern responsive design with gradient themes
- **Charts**: Line charts for trends, bar charts for comparisons

## Customization

To modify the dashboard:

1. **Add New Metrics**: Update the SQL queries and add corresponding chart/table logic
2. **Change Time Periods**: Modify the date filters in the SQL queries
3. **Styling**: Update the CSS in `index.html` for different themes
4. **Data Sources**: Modify `data-importer.py` to connect to actual SQL Server database

## Troubleshooting

- **No Data Displayed**: Check Supabase API key and project configuration
- **Chart Not Loading**: Verify Chart.js CDN is accessible
- **Import Errors**: Ensure Supabase tables are created correctly
- **CORS Issues**: Use the Edge Function deployment for production

## Performance Considerations

- Data is aggregated at import time for fast dashboard loading
- Charts are optimized for datasets up to 12 months
- Tables are limited to top 10 results for performance
- Indexes are created on date and key columns for efficient queries
