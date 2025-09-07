# WideWorldImporters Revenue & Margin Trends - Web Dashboard

Interactive web-based dashboard for visualizing 12-month revenue and margin trends from the WideWorldImportersDW database using Python Flask backend and JavaScript frontend with Chart.js.

## Features

### 📊 Interactive Visualizations
- **Monthly Revenue & Margin Trends**: Line chart showing revenue, profit, and margin percentage over time
- **Customer Segment Performance**: Doughnut chart displaying revenue distribution by customer segments
- **Product Category Analysis**: Bar chart with top-performing product categories
- **Rolling 12-Month Metrics**: Trend analysis with rolling calculations
- **KPI Summary Cards**: Key performance indicators with year-over-year comparisons

### 🎛️ Dashboard Controls
- **Date Range Selection**: Custom start/end date pickers
- **Quick Date Filters**: YTD, 12M, 24M preset options
- **Real-time Data Refresh**: Update visualizations with new date ranges
- **Responsive Design**: Works on desktop, tablet, and mobile devices

### 🔧 Technical Features
- **RESTful API**: Clean separation between backend data and frontend visualization
- **Error Handling**: Graceful handling of database connection issues
- **Performance Optimized**: Efficient SQL queries with proper indexing
- **Modern UI**: Bootstrap 5 with custom styling and Font Awesome icons

## Prerequisites

### Database Requirements
- SQL Server with WideWorldImportersDW sample database installed
- ODBC Driver 17 for SQL Server (or compatible version)
- Database user with read access to Fact.Sale and Dimension tables

### Python Requirements
- Python 3.8 or higher
- pip package manager

## Installation

### 1. Install Python Dependencies
```bash
cd web-dashboard
pip install -r requirements.txt
```

### 2. Configure Database Connection
Edit the database configuration in `app.py`:

```python
DB_CONFIG = {
    'server': 'your-server-name',  # e.g., 'localhost' or 'server.database.windows.net'
    'database': 'WideWorldImportersDW',
    'driver': '{ODBC Driver 17 for SQL Server}',
    'trusted_connection': 'yes'  # or 'no' for SQL authentication
}
```

For SQL Server Authentication, modify the connection string:
```python
# For SQL Server Authentication
conn_str = f"DRIVER={DB_CONFIG['driver']};SERVER={DB_CONFIG['server']};DATABASE={DB_CONFIG['database']};UID=your_username;PWD=your_password"
```

### 3. Environment Variables (Optional)
Create a `.env` file for environment-specific configuration:
```
DB_SERVER=localhost
DB_DATABASE=WideWorldImportersDW
DB_USERNAME=your_username
DB_PASSWORD=your_password
FLASK_ENV=development
```

## Running the Dashboard

### 1. Start the Flask Application
```bash
python app.py
```

The dashboard will be available at: `http://localhost:5000`

### 2. Access the Dashboard
Open your web browser and navigate to `http://localhost:5000`

## API Endpoints

The dashboard provides several REST API endpoints for data access:

### `/api/monthly-trends`
Returns monthly revenue and margin trends with growth calculations.

**Parameters:**
- `start_date` (optional): Start date in YYYY-MM-DD format
- `end_date` (optional): End date in YYYY-MM-DD format

**Response:**
```json
[
  {
    "Year": 2016,
    "MonthNumber": 1,
    "Month": "January",
    "YearMonth": "2016-01",
    "RevenueExcludingTax": 1234567.89,
    "RevenueIncludingTax": 1358024.68,
    "Profit": 123456.78,
    "TransactionCount": 1500,
    "RevenueGrowthRate": 5.2,
    "MarginPercentage": 10.0
  }
]
```

### `/api/customer-segments`
Returns customer segment performance metrics.

### `/api/product-categories`
Returns top product category performance data.

### `/api/rolling-metrics`
Returns rolling 12-month calculations.

### `/api/kpi-summary`
Returns key performance indicators and year-over-year comparisons.

## Customization

### Adding New Visualizations
1. Create a new API endpoint in `app.py`
2. Add the corresponding chart container in `dashboard.html`
3. Implement the chart rendering function in `dashboard.js`

### Modifying Chart Styles
Edit the Chart.js configuration in `dashboard.js` to customize:
- Colors and themes
- Chart types (line, bar, doughnut, etc.)
- Axis formatting
- Tooltip content
- Legend positioning

### Database Query Optimization
The dashboard includes optimized SQL queries with:
- Proper JOIN conditions
- Indexed column usage
- Aggregation at appropriate levels
- Date range filtering

## Troubleshooting

### Common Issues

**Database Connection Errors**
- Verify SQL Server is running and accessible
- Check ODBC driver installation
- Confirm database name and server address
- Validate user permissions

**No Data Displayed**
- Check date range parameters
- Verify WideWorldImportersDW sample data exists
- Review browser console for JavaScript errors
- Check Flask application logs

**Performance Issues**
- Ensure proper database indexing (see `../kyvos/cube-deployment-script.sql`)
- Limit date ranges for large datasets
- Consider implementing data caching for frequently accessed queries

### Browser Compatibility
- Modern browsers with ES6+ support required
- Chrome 70+, Firefox 65+, Safari 12+, Edge 79+

## Development

### Project Structure
```
web-dashboard/
├── app.py                 # Flask backend application
├── requirements.txt       # Python dependencies
├── templates/
│   └── dashboard.html    # Main dashboard template
├── static/
│   └── dashboard.js      # Frontend JavaScript
└── README.md             # This file
```

### Adding New Features
1. Backend: Add new API endpoints in `app.py`
2. Frontend: Update `dashboard.html` and `dashboard.js`
3. Testing: Verify with different date ranges and data scenarios

## Security Considerations

- Use parameterized queries to prevent SQL injection
- Implement proper authentication for production deployments
- Configure CORS settings appropriately
- Use HTTPS in production environments
- Validate and sanitize user inputs

## Performance Tips

- Use connection pooling for high-traffic scenarios
- Implement caching for frequently accessed data
- Consider using async/await for multiple API calls
- Optimize SQL queries with proper indexing
- Use CDN for static assets in production

## License

This dashboard is part of the SQL Server samples repository and follows the same licensing terms.
