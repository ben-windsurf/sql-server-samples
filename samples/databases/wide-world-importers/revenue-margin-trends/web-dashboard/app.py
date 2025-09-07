from flask import Flask, render_template, jsonify, request
from flask_cors import CORS
import pyodbc
import json
from datetime import datetime, timedelta
import os
from typing import Dict, List, Any

app = Flask(__name__)
CORS(app)

DB_CONFIG = {
    'server': os.getenv('DB_SERVER', 'localhost'),
    'database': 'WideWorldImportersDW',
    'driver': '{ODBC Driver 17 for SQL Server}',
    'trusted_connection': 'yes'
}

def get_db_connection():
    """Create database connection"""
    conn_str = f"DRIVER={DB_CONFIG['driver']};SERVER={DB_CONFIG['server']};DATABASE={DB_CONFIG['database']};Trusted_Connection={DB_CONFIG['trusted_connection']}"
    return pyodbc.connect(conn_str)

def execute_query(query: str, params: tuple = None) -> List[Dict[str, Any]]:
    """Execute SQL query and return results as list of dictionaries"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
        
        columns = [column[0] for column in cursor.description]
        results = []
        
        for row in cursor.fetchall():
            results.append(dict(zip(columns, row)))
        
        conn.close()
        return results
    
    except Exception as e:
        print(f"Database error: {str(e)}")
        return []

@app.route('/')
def index():
    """Main dashboard page"""
    return render_template('dashboard.html')

@app.route('/api/monthly-trends')
def monthly_trends():
    """Get monthly revenue and margin trends"""
    start_date = request.args.get('start_date', '2016-01-01')
    end_date = request.args.get('end_date', '2016-12-31')
    
    query = """
    WITH MonthlyData AS (
        SELECT 
            d.[Calendar Year] as Year,
            d.[Calendar Month Number] as MonthNumber,
            d.[Calendar Month Label] as Month,
            CONCAT(d.[Calendar Year], '-', FORMAT(d.[Calendar Month Number], '00')) as YearMonth,
            SUM(s.[Total Excluding Tax]) as RevenueExcludingTax,
            SUM(s.[Total Including Tax]) as RevenueIncludingTax,
            SUM(s.[Profit]) as Profit,
            COUNT(*) as TransactionCount
        FROM Fact.Sale s
        INNER JOIN Dimension.Date d ON s.[Invoice Date Key] = d.Date
        WHERE d.Date BETWEEN ? AND ?
        GROUP BY 
            d.[Calendar Year],
            d.[Calendar Month Number],
            d.[Calendar Month Label]
    ),
    TrendsWithGrowth AS (
        SELECT *,
            CASE 
                WHEN LAG(RevenueExcludingTax) OVER (ORDER BY Year, MonthNumber) > 0 
                THEN ((RevenueExcludingTax - LAG(RevenueExcludingTax) OVER (ORDER BY Year, MonthNumber)) / LAG(RevenueExcludingTax) OVER (ORDER BY Year, MonthNumber)) * 100
                ELSE 0 
            END as RevenueGrowthRate,
            CASE 
                WHEN RevenueExcludingTax > 0 
                THEN (Profit / RevenueExcludingTax) * 100 
                ELSE 0 
            END as MarginPercentage
        FROM MonthlyData
    )
    SELECT * FROM TrendsWithGrowth
    ORDER BY Year, MonthNumber
    """
    
    results = execute_query(query, (start_date, end_date))
    return jsonify(results)

@app.route('/api/customer-segments')
def customer_segments():
    """Get customer segment performance"""
    start_date = request.args.get('start_date', '2016-01-01')
    end_date = request.args.get('end_date', '2016-12-31')
    
    query = """
    SELECT 
        c.[Customer Category] as CustomerSegment,
        SUM(s.[Total Excluding Tax]) as SegmentRevenueExcludingTax,
        SUM(s.[Profit]) as SegmentProfit,
        COUNT(DISTINCT s.[Customer Key]) as UniqueCustomers,
        COUNT(*) as TransactionCount,
        CASE 
            WHEN SUM(s.[Total Excluding Tax]) > 0 
            THEN (SUM(s.[Profit]) / SUM(s.[Total Excluding Tax])) * 100 
            ELSE 0 
        END as SegmentMarginPercentage
    FROM Fact.Sale s
    INNER JOIN Dimension.Date d ON s.[Invoice Date Key] = d.Date
    INNER JOIN Dimension.Customer c ON s.[Customer Key] = c.[Customer Key]
    WHERE d.Date BETWEEN ? AND ?
    GROUP BY c.[Customer Category]
    ORDER BY SegmentRevenueExcludingTax DESC
    """
    
    results = execute_query(query, (start_date, end_date))
    return jsonify(results)

@app.route('/api/product-categories')
def product_categories():
    """Get product category performance"""
    start_date = request.args.get('start_date', '2016-01-01')
    end_date = request.args.get('end_date', '2016-12-31')
    
    query = """
    SELECT TOP 10
        si.[Brand] as ProductBrand,
        si.[Color] as ProductColor,
        SUM(s.[Total Excluding Tax]) as ProductRevenueExcludingTax,
        SUM(s.[Profit]) as ProductProfit,
        SUM(s.[Quantity]) as TotalQuantity,
        CASE 
            WHEN SUM(s.[Total Excluding Tax]) > 0 
            THEN (SUM(s.[Profit]) / SUM(s.[Total Excluding Tax])) * 100 
            ELSE 0 
        END as ProductMarginPercentage
    FROM Fact.Sale s
    INNER JOIN Dimension.Date d ON s.[Invoice Date Key] = d.Date
    INNER JOIN Dimension.[Stock Item] si ON s.[Stock Item Key] = si.[Stock Item Key]
    WHERE d.Date BETWEEN ? AND ?
        AND si.[Brand] IS NOT NULL
        AND si.[Color] IS NOT NULL
    GROUP BY si.[Brand], si.[Color]
    ORDER BY ProductRevenueExcludingTax DESC
    """
    
    results = execute_query(query, (start_date, end_date))
    return jsonify(results)

@app.route('/api/rolling-metrics')
def rolling_metrics():
    """Get rolling 12-month metrics"""
    end_date = request.args.get('end_date', '2016-12-31')
    
    query = """
    WITH DailyMetrics AS (
        SELECT 
            d.Date as ReportDate,
            SUM(s.[Total Excluding Tax]) as DailyRevenue,
            SUM(s.[Profit]) as DailyProfit
        FROM Fact.Sale s
        INNER JOIN Dimension.Date d ON s.[Invoice Date Key] = d.Date
        WHERE d.Date <= ?
        GROUP BY d.Date
    ),
    Rolling12M AS (
        SELECT 
            ReportDate,
            SUM(DailyRevenue) OVER (
                ORDER BY ReportDate 
                ROWS BETWEEN 364 PRECEDING AND CURRENT ROW
            ) as Rolling12MRevenue,
            SUM(DailyProfit) OVER (
                ORDER BY ReportDate 
                ROWS BETWEEN 364 PRECEDING AND CURRENT ROW
            ) as Rolling12MProfit
        FROM DailyMetrics
    )
    SELECT 
        ReportDate,
        Rolling12MRevenue,
        Rolling12MProfit,
        CASE 
            WHEN Rolling12MRevenue > 0 
            THEN (Rolling12MProfit / Rolling12MRevenue) * 100 
            ELSE 0 
        END as Rolling12MMarginPercentage
    FROM Rolling12M
    WHERE ReportDate >= DATEADD(year, -2, ?)
    ORDER BY ReportDate
    """
    
    results = execute_query(query, (end_date, end_date))
    return jsonify(results)

@app.route('/api/kpi-summary')
def kpi_summary():
    """Get KPI summary metrics"""
    start_date = request.args.get('start_date', '2016-01-01')
    end_date = request.args.get('end_date', '2016-12-31')
    
    query = """
    WITH CurrentPeriod AS (
        SELECT 
            SUM(s.[Total Excluding Tax]) as TotalRevenue,
            SUM(s.[Profit]) as TotalProfit,
            COUNT(*) as TotalTransactions,
            COUNT(DISTINCT s.[Customer Key]) as UniqueCustomers
        FROM Fact.Sale s
        INNER JOIN Dimension.Date d ON s.[Invoice Date Key] = d.Date
        WHERE d.Date BETWEEN ? AND ?
    ),
    PreviousPeriod AS (
        SELECT 
            SUM(s.[Total Excluding Tax]) as PrevTotalRevenue,
            SUM(s.[Profit]) as PrevTotalProfit
        FROM Fact.Sale s
        INNER JOIN Dimension.Date d ON s.[Invoice Date Key] = d.Date
        WHERE d.Date BETWEEN DATEADD(year, -1, ?) AND DATEADD(year, -1, ?)
    )
    SELECT 
        cp.TotalRevenue,
        cp.TotalProfit,
        cp.TotalTransactions,
        cp.UniqueCustomers,
        CASE 
            WHEN cp.TotalRevenue > 0 
            THEN (cp.TotalProfit / cp.TotalRevenue) * 100 
            ELSE 0 
        END as OverallMarginPercentage,
        CASE 
            WHEN pp.PrevTotalRevenue > 0 
            THEN ((cp.TotalRevenue - pp.PrevTotalRevenue) / pp.PrevTotalRevenue) * 100 
            ELSE 0 
        END as YoYRevenueGrowth,
        CASE 
            WHEN pp.PrevTotalProfit > 0 
            THEN ((cp.TotalProfit - pp.PrevTotalProfit) / pp.PrevTotalProfit) * 100 
            ELSE 0 
        END as YoYProfitGrowth
    FROM CurrentPeriod cp
    CROSS JOIN PreviousPeriod pp
    """
    
    results = execute_query(query, (start_date, end_date, start_date, end_date))
    return jsonify(results[0] if results else {})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
