# PowerBI Connection and Usage Guide

## Database Connection

### Connection String
```
Server: [Your SQL Server Instance]
Database: WideWorldImportersDW
Authentication: [Windows Authentication or SQL Server Authentication]
```

### Data Source Configuration
1. Open PowerBI Desktop
2. Get Data > SQL Server
3. Enter server and database details
4. Choose DirectQuery or Import mode (Import recommended for better performance)

## Using the T-SQL Queries

### Method 1: Advanced Editor
1. Get Data > SQL Server
2. Click "Advanced options"
3. Paste the T-SQL query into the "SQL statement" field
4. Click OK to load data

### Method 2: Transform Data
1. Connect to WideWorldImportersDW database
2. Select "Transform Data"
3. Home > Advanced Editor
4. Replace the generated query with the provided T-SQL
5. Click "Done" and "Close & Apply"

## Query Parameters

### Date Range Parameters
You can parameterize the date ranges for dynamic filtering:

```sql
-- Add parameters in PowerBI
DECLARE @StartDate DATE = ?StartDate?
DECLARE @EndDate DATE = ?EndDate?

-- Use in WHERE clause
WHERE d.[Date] >= @StartDate
  AND d.[Date] < @EndDate
```

### Creating Parameters in PowerBI
1. Home > Transform Data
2. Manage Parameters > New Parameter
3. Create parameters for StartDate and EndDate
4. Reference parameters in Advanced Editor using ?ParameterName? syntax

## Recommended Visualizations

### 1. Revenue Trend Line Chart
- **X-axis**: Calendar Month Label
- **Y-axis**: Revenue_Including_Tax
- **Legend**: Calendar Year
- **Chart Type**: Line Chart

### 2. Margin Analysis
- **X-axis**: Calendar Month Label  
- **Y-axis**: Margin_Percentage
- **Secondary Y-axis**: Total_Margin
- **Chart Type**: Combo Chart (Line + Column)

### 3. Year-over-Year Comparison
- **X-axis**: Calendar Month Label
- **Y-axis**: Revenue_Growth_Percentage
- **Color**: Revenue_Trend (Growth/Decline/Flat)
- **Chart Type**: Column Chart

### 4. Quarterly Summary
- **Rows**: Calendar Quarter Label
- **Values**: 
  - Quarterly_Revenue_Including_Tax
  - Quarterly_Margin
  - Quarterly_Margin_Percentage
- **Chart Type**: Table or Matrix

## Performance Optimization

### 1. Date Filtering
Always apply date filters to limit data volume:
```sql
WHERE d.[Date] >= DATEADD(MONTH, -12, GETDATE())
```

### 2. Aggregation Level
Consider pre-aggregating data at monthly or quarterly level for better performance.

### 3. Indexes
The queries leverage existing columnstore indexes on Fact.Sale table for optimal performance.

### 4. DirectQuery vs Import
- **Import Mode**: Better performance for smaller datasets, enables all PowerBI features
- **DirectQuery**: Real-time data, better for large datasets, some feature limitations

## Sample Dashboard Layout

```
+------------------+------------------+
|   Revenue Trend  |  Margin Analysis |
|   (Line Chart)   |  (Combo Chart)   |
+------------------+------------------+
|        Year-over-Year Growth        |
|         (Column Chart)              |
+-------------------------------------+
|         Quarterly Summary           |
|           (Table)                   |
+-------------------------------------+
```

## Filters and Slicers

### Recommended Slicers
- Calendar Year
- Calendar Quarter  
- Date Range (Start/End Date)

### Filter Hierarchy
1. Year > Quarter > Month
2. Date Range (for custom periods)

## Data Refresh

### Scheduled Refresh
1. Publish to PowerBI Service
2. Configure data source credentials
3. Set up scheduled refresh (daily/weekly)

### Real-time Updates
Use DirectQuery mode for real-time data updates without scheduled refresh.

## Troubleshooting

### Common Issues
1. **Connection Timeout**: Increase command timeout in connection settings
2. **Memory Issues**: Use DirectQuery mode or reduce date range
3. **Performance**: Add date filters and consider data aggregation

### Query Optimization
- Always include date filters
- Use appropriate indexes
- Consider partitioning for large datasets
- Monitor query execution plans
