# WideWorldImporters Revenue & Margin Trends Dashboard

An interactive web-based dashboard for visualizing 12-month revenue and margin trends using generated WideWorldImporters data stored in Supabase.

## Features

### Interactive Visualizations
- **Monthly Revenue & Margin Trends**: Line chart showing revenue and profit trends over time with margin percentage overlay
- **Customer Segment Performance**: Doughnut chart displaying revenue distribution across customer categories
- **Top Product Categories**: Bar chart of highest-performing product brands and colors
- **Rolling 12-Month Metrics**: Line chart showing rolling 12-month revenue, profit, and margin trends
- **KPI Summary Cards**: Key performance indicators with year-over-year growth comparisons

### Dashboard Controls
- **Date Range Selection**: Custom start and end date inputs for flexible analysis periods
- **Quick Date Filters**: One-click buttons for Year-to-Date (YTD), 12-month (12M), and 24-month (24M) views
- **Real-time Data Refresh**: Manual refresh button to update all visualizations with latest data
- **Responsive Design**: Optimized for desktop, tablet, and mobile viewing

## Prerequisites

### Supabase Requirements
- **Supabase project** with the `revenue_margin_data` table populated
- **Supabase URL and API key** for database connectivity
- **Generated data** from the data-generation scripts (24 months of realistic WideWorldImporters data)

### Python Requirements
- **Python 3.8+** (tested with Python 3.12)
- **Flask** web framework for backend API
- **Supabase Python client** for database connectivity

## Installation

1. **Clone the repository** (if not already done):
   ```bash
   git clone https://github.com/ben-windsurf/sql-server-samples.git
   cd sql-server-samples/samples/databases/wide-world-importers/revenue-margin-trends/web-dashboard
   ```

2. **Install Python dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Configure Supabase connection** by setting environment variables:
   ```bash
   export SUPABASE_URL="https://your-project-id.supabase.co"
   export SUPABASE_ANON_KEY="your-anon-key"
   ```

## Data Setup

Before running the dashboard, you need to generate and upload the sample data:

1. **Generate sample data**:
   ```bash
   cd ../data-generation
   python generate_sample_data.py
   ```

2. **Set up Supabase table** (using MCP tools or Supabase dashboard):
   ```sql
   CREATE TABLE revenue_margin_data (
     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
     order_id UUID NOT NULL,
     invoice_date DATE NOT NULL,
     customer_segment TEXT NOT NULL,
     product_brand TEXT NOT NULL,
     product_color TEXT NOT NULL,
     quantity INTEGER NOT NULL,
     total_excluding_tax DECIMAL(10,2) NOT NULL,
     total_including_tax DECIMAL(10,2) NOT NULL,
     profit DECIMAL(10,2) NOT NULL,
     year INTEGER NOT NULL,
     month INTEGER NOT NULL,
     quarter INTEGER NOT NULL,
     weekday INTEGER NOT NULL,
     created_at TIMESTAMP DEFAULT NOW()
   );
   
   CREATE INDEX idx_invoice_date ON revenue_margin_data(invoice_date);
   CREATE INDEX idx_customer_segment ON revenue_margin_data(customer_segment);
   CREATE INDEX idx_product_brand ON revenue_margin_data(product_brand);
   ```

3. **Upload data to Supabase** using the generated SQL file or MCP tools

## Running the Dashboard

1. **Start the Flask development server**:
   ```bash
   python app.py
   ```

2. **Access the dashboard**:
   Open your web browser and navigate to: `http://localhost:5000`

3. **Interact with the dashboard**:
   - Use date controls to select analysis period (default: 2023-2024)
   - Click quick filter buttons for common date ranges
   - Hover over charts for detailed data points
   - Use the refresh button to update data

## API Endpoints

The dashboard backend provides RESTful API endpoints for data access:

### `/api/monthly-trends`
**Parameters**: `start_date`, `end_date`  
**Returns**: Monthly aggregated revenue, profit, and margin data with growth rates

### `/api/customer-segments`
**Parameters**: `start_date`, `end_date`  
**Returns**: Customer segment performance with revenue, profit, and margin breakdowns

### `/api/product-categories`
**Parameters**: `start_date`, `end_date`  
**Returns**: Top 10 product categories by revenue with margin analysis

### `/api/rolling-metrics`
**Parameters**: `end_date`  
**Returns**: Rolling 12-month revenue, profit, and margin calculations

### `/api/kpi-summary`
**Parameters**: `start_date`, `end_date`  
**Returns**: Key performance indicators with year-over-year comparisons

## Data Generation Features

The dashboard displays data generated using sophisticated patterns from WideWorldImporters:

### Seasonal Variations
- **Q1/Q3**: Typically lower sales periods
- **Q2/Q4**: Higher sales with holiday and seasonal peaks
- **Bell curve calculations**: Smooth seasonal transitions

### Yearly Growth
- **3-15% annual growth**: Configurable realistic growth rates
- **Progressive application**: Growth applied gradually throughout the year

### Customer Segments
- **8 realistic segments**: Corporate, Retail, Wholesale, Novelty Shop, etc.
- **Different margin profiles**: Varying profitability by segment type
- **Volume patterns**: Different order frequencies and sizes

### Product Categories
- **7 brands**: Northwind, Wide World Importers, Fabrikam, etc.
- **12 colors**: Full spectrum of product color variations
- **Margin variations**: Different profitability by brand and color combinations

## Customization

### Modifying Visualizations
- **Chart.js configuration**: Edit `static/dashboard.js` to customize chart appearance, colors, and behavior
- **Dashboard layout**: Modify `templates/dashboard.html` to adjust grid layout, add new sections, or change styling
- **CSS styling**: Update the `<style>` section in the HTML template for custom themes and responsive behavior

### Adding New Metrics
1. **Create new API endpoint** in `app.py` following the existing pattern
2. **Add chart container** in the HTML template
3. **Implement chart rendering** in `dashboard.js` with appropriate Chart.js configuration
4. **Update dashboard refresh** logic to include the new endpoint

### Supabase Query Optimization
- **Indexes**: Ensure proper indexing on `invoice_date`, `customer_segment`, and `product_brand` for optimal performance
- **Query tuning**: Modify Supabase queries in `app.py` for specific business requirements
- **Caching**: Consider implementing caching for frequently accessed aggregations

## Troubleshooting

### Supabase Connection Issues
- **Verify Supabase URL and API key** are correctly set in environment variables
- **Check project status** in Supabase dashboard
- **Validate table exists** and has data populated
- **Test connection** using Supabase dashboard or SQL editor

### Data Issues
- **Empty charts**: Ensure data generation scripts have been run and data uploaded to Supabase
- **Date range errors**: Verify date ranges match the generated data period (2023-2024)
- **Missing segments**: Check that all customer segments and product categories are present in the data

### Performance Issues
- **Large datasets**: The generated data (~40-50k records) should perform well with proper indexing
- **Slow queries**: Review Supabase query performance in the dashboard
- **Memory usage**: Monitor Flask application memory usage

## Security Considerations

### Supabase Security
- **Row Level Security (RLS)**: Configure RLS policies if needed for multi-tenant scenarios
- **API key management**: Use environment variables and secure credential stores
- **Network security**: Configure Supabase network restrictions if required

### Web Application Security
- **Input validation**: All date parameters are validated and sanitized
- **CORS configuration**: Adjust CORS settings in `app.py` for production deployment
- **HTTPS**: Use reverse proxy (nginx, Apache) with SSL certificates for production

## Performance Optimization

### Supabase Level
- **Indexes**: Ensure proper indexing on frequently queried columns
- **Query optimization**: Use Supabase's query performance insights
- **Connection pooling**: Supabase handles connection pooling automatically

### Application Level
- **Caching**: Add Redis or in-memory caching for frequently accessed aggregations
- **Async processing**: Consider async endpoints for complex calculations
- **Data pagination**: Implement pagination for very large result sets

### Frontend Optimization
- **Chart.js performance**: Use data decimation for large datasets
- **Lazy loading**: Implement progressive loading for charts
- **Browser caching**: Configure appropriate cache headers for static assets

## Development and Deployment

### Development Workflow
1. **Local development**: Use the Flask development server for testing and debugging
2. **Data setup**: Ensure Supabase table is populated with generated data
3. **Testing**: Verify all API endpoints return expected data structures
4. **Frontend testing**: Test responsive design across different screen sizes and browsers

### Production Deployment
1. **WSGI server**: Use Gunicorn, uWSGI, or similar for production deployment
2. **Reverse proxy**: Configure nginx or Apache for static file serving and SSL termination
3. **Environment variables**: Use secure credential management for Supabase credentials
4. **Monitoring**: Implement application monitoring and logging

### Docker Deployment
```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 5000
ENV FLASK_ENV=production
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
```

## Technical Architecture

### Backend Stack
- **Flask**: Lightweight Python web framework
- **Supabase Python client**: PostgreSQL database connectivity via Supabase
- **Flask-CORS**: Cross-Origin Resource Sharing support

### Frontend Stack
- **Bootstrap 5**: Responsive CSS framework
- **Chart.js**: Interactive charting library
- **D3.js**: Data visualization utilities
- **Font Awesome**: Icon library

### Data Flow
1. **User interaction** triggers JavaScript event handlers
2. **AJAX requests** sent to Flask API endpoints
3. **Supabase queries** executed against revenue_margin_data table
4. **JSON responses** returned to frontend
5. **Chart.js rendering** updates visualizations

## Data Schema

The `revenue_margin_data` table contains:

```sql
- id: UUID (Primary Key)
- order_id: UUID (Unique order identifier)
- invoice_date: DATE (Transaction date)
- customer_segment: TEXT (Business segment)
- product_brand: TEXT (Product brand)
- product_color: TEXT (Product color)
- quantity: INTEGER (Order quantity)
- total_excluding_tax: DECIMAL(10,2) (Revenue excluding tax)
- total_including_tax: DECIMAL(10,2) (Revenue including tax)
- profit: DECIMAL(10,2) (Profit amount)
- year: INTEGER (Year for aggregation)
- month: INTEGER (Month for aggregation)
- quarter: INTEGER (Quarter for aggregation)
- weekday: INTEGER (Day of week, 1=Monday)
- created_at: TIMESTAMP (Record creation time)
```

## Contributing

### Code Style
- **Python**: Follow PEP 8 guidelines
- **JavaScript**: Use ES6+ features and consistent formatting
- **SQL**: Use proper indentation and aliasing

### Testing
- **Unit tests**: Add tests for new API endpoints
- **Integration tests**: Verify Supabase connectivity and query results
- **Frontend tests**: Test chart rendering and user interactions

### Documentation
- **API documentation**: Update endpoint descriptions for new features
- **README updates**: Keep installation and configuration instructions current
- **Code comments**: Add comments for complex business logic or calculations
