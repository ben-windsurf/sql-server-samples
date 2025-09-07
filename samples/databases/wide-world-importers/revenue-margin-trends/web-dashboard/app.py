from flask import Flask, render_template, jsonify, request
from flask_cors import CORS
import json
from datetime import datetime, timedelta
import os
from typing import Dict, List, Any, Optional
from supabase import create_client, Client

app = Flask(__name__)
CORS(app)

SUPABASE_CONFIG = {
    'url': os.getenv('SUPABASE_URL', ''),
    'key': os.getenv('SUPABASE_ANON_KEY', ''),
}

def get_supabase_client() -> Client:
    """Create Supabase client connection"""
    if not SUPABASE_CONFIG['url'] or not SUPABASE_CONFIG['key']:
        raise ValueError("SUPABASE_URL and SUPABASE_ANON_KEY environment variables must be set")
    
    return create_client(SUPABASE_CONFIG['url'], SUPABASE_CONFIG['key'])

def execute_supabase_query(table: str, select_fields: str = "*", filters: Optional[Dict[str, Any]] = None, 
                           order_by: Optional[str] = None, limit: Optional[int] = None) -> List[Dict[str, Any]]:
    """Execute Supabase query and return results as list of dictionaries"""
    try:
        supabase = get_supabase_client()
        query = supabase.table(table).select(select_fields)
        
        if filters:
            for field, value in filters.items():
                if isinstance(value, tuple) and len(value) == 2:
                    query = query.gte(field, value[0]).lte(field, value[1])
                else:
                    query = query.eq(field, value)
        
        if order_by:
            query = query.order(order_by)
        
        if limit:
            query = query.limit(limit)
        
        response = query.execute()
        return response.data
    
    except Exception as e:
        print(f"Supabase error: {str(e)}")
        return []

@app.route('/')
def index():
    """Main dashboard page"""
    return render_template('dashboard.html')

@app.route('/api/monthly-trends')
def monthly_trends():
    """Get monthly revenue and margin trends"""
    start_date = request.args.get('start_date', '2023-01-01')
    end_date = request.args.get('end_date', '2024-12-31')
    
    try:
        filters = {
            'invoice_date': (start_date, end_date)
        }
        
        data = execute_supabase_query(
            table='revenue_margin_data',
            select_fields='year, month, total_excluding_tax, total_including_tax, profit',
            filters=filters,
            order_by='year, month'
        )
        
        monthly_data = {}
        for record in data:
            key = f"{record['year']}-{record['month']:02d}"
            if key not in monthly_data:
                monthly_data[key] = {
                    'Year': record['year'],
                    'MonthNumber': record['month'],
                    'Month': datetime(record['year'], record['month'], 1).strftime('%B'),
                    'YearMonth': key,
                    'RevenueExcludingTax': 0,
                    'RevenueIncludingTax': 0,
                    'Profit': 0,
                    'TransactionCount': 0
                }
            
            monthly_data[key]['RevenueExcludingTax'] += record['total_excluding_tax']
            monthly_data[key]['RevenueIncludingTax'] += record['total_including_tax']
            monthly_data[key]['Profit'] += record['profit']
            monthly_data[key]['TransactionCount'] += 1
        
        results = []
        prev_revenue = None
        
        for key in sorted(monthly_data.keys()):
            month_data = monthly_data[key]
            
            if prev_revenue and prev_revenue > 0:
                growth_rate = ((month_data['RevenueExcludingTax'] - prev_revenue) / prev_revenue) * 100
            else:
                growth_rate = 0
            
            if month_data['RevenueExcludingTax'] > 0:
                margin_percentage = (month_data['Profit'] / month_data['RevenueExcludingTax']) * 100
            else:
                margin_percentage = 0
            
            month_data['RevenueGrowthRate'] = round(growth_rate, 2)
            month_data['MarginPercentage'] = round(margin_percentage, 2)
            
            results.append(month_data)
            prev_revenue = month_data['RevenueExcludingTax']
        
        return jsonify(results)
    
    except Exception as e:
        print(f"Error in monthly_trends: {str(e)}")
        return jsonify([])

@app.route('/api/customer-segments')
def customer_segments():
    """Get customer segment performance"""
    start_date = request.args.get('start_date', '2023-01-01')
    end_date = request.args.get('end_date', '2024-12-31')
    
    try:
        filters = {
            'invoice_date': (start_date, end_date)
        }
        
        data = execute_supabase_query(
            table='revenue_margin_data',
            select_fields='customer_segment, total_excluding_tax, profit, order_id',
            filters=filters
        )
        
        segment_data = {}
        for record in data:
            segment = record['customer_segment']
            if segment not in segment_data:
                segment_data[segment] = {
                    'CustomerSegment': segment,
                    'SegmentRevenueExcludingTax': 0,
                    'SegmentProfit': 0,
                    'UniqueCustomers': 0,  # Note: We don't have customer IDs, so this will be order count
                    'TransactionCount': 0
                }
            
            segment_data[segment]['SegmentRevenueExcludingTax'] += record['total_excluding_tax']
            segment_data[segment]['SegmentProfit'] += record['profit']
            segment_data[segment]['TransactionCount'] += 1
        
        results = []
        for segment_info in segment_data.values():
            if segment_info['SegmentRevenueExcludingTax'] > 0:
                margin_percentage = (segment_info['SegmentProfit'] / segment_info['SegmentRevenueExcludingTax']) * 100
            else:
                margin_percentage = 0
            
            segment_info['SegmentMarginPercentage'] = round(margin_percentage, 2)
            segment_info['UniqueCustomers'] = segment_info['TransactionCount']  # Approximate
            results.append(segment_info)
        
        results.sort(key=lambda x: x['SegmentRevenueExcludingTax'], reverse=True)
        
        return jsonify(results)
    
    except Exception as e:
        print(f"Error in customer_segments: {str(e)}")
        return jsonify([])

@app.route('/api/product-categories')
def product_categories():
    """Get product category performance"""
    start_date = request.args.get('start_date', '2023-01-01')
    end_date = request.args.get('end_date', '2024-12-31')
    
    try:
        filters = {
            'invoice_date': (start_date, end_date)
        }
        
        data = execute_supabase_query(
            table='revenue_margin_data',
            select_fields='product_brand, product_color, total_excluding_tax, profit, quantity',
            filters=filters
        )
        
        product_data = {}
        for record in data:
            key = f"{record['product_brand']}_{record['product_color']}"
            if key not in product_data:
                product_data[key] = {
                    'ProductBrand': record['product_brand'],
                    'ProductColor': record['product_color'],
                    'ProductRevenueExcludingTax': 0,
                    'ProductProfit': 0,
                    'TotalQuantity': 0
                }
            
            product_data[key]['ProductRevenueExcludingTax'] += record['total_excluding_tax']
            product_data[key]['ProductProfit'] += record['profit']
            product_data[key]['TotalQuantity'] += record['quantity']
        
        results = []
        for product_info in product_data.values():
            if product_info['ProductRevenueExcludingTax'] > 0:
                margin_percentage = (product_info['ProductProfit'] / product_info['ProductRevenueExcludingTax']) * 100
            else:
                margin_percentage = 0
            
            product_info['ProductMarginPercentage'] = round(margin_percentage, 2)
            results.append(product_info)
        
        results.sort(key=lambda x: x['ProductRevenueExcludingTax'], reverse=True)
        results = results[:10]
        
        return jsonify(results)
    
    except Exception as e:
        print(f"Error in product_categories: {str(e)}")
        return jsonify([])

@app.route('/api/rolling-metrics')
def rolling_metrics():
    """Get rolling 12-month metrics"""
    end_date = request.args.get('end_date', '2024-12-31')
    
    try:
        end_date_obj = datetime.strptime(end_date, '%Y-%m-%d')
        start_date_obj = end_date_obj - timedelta(days=730)  # 2 years
        start_date = start_date_obj.strftime('%Y-%m-%d')
        
        filters = {
            'invoice_date': (start_date, end_date)
        }
        
        data = execute_supabase_query(
            table='revenue_margin_data',
            select_fields='invoice_date, total_excluding_tax, profit',
            filters=filters,
            order_by='invoice_date'
        )
        
        daily_metrics = {}
        for record in data:
            date_str = record['invoice_date']
            if date_str not in daily_metrics:
                daily_metrics[date_str] = {
                    'ReportDate': date_str,
                    'DailyRevenue': 0,
                    'DailyProfit': 0
                }
            
            daily_metrics[date_str]['DailyRevenue'] += record['total_excluding_tax']
            daily_metrics[date_str]['DailyProfit'] += record['profit']
        
        sorted_dates = sorted(daily_metrics.keys())
        results = []
        
        for i, current_date in enumerate(sorted_dates):
            start_idx = max(0, i - 364)
            rolling_dates = sorted_dates[start_idx:i+1]
            
            rolling_revenue = sum(daily_metrics[d]['DailyRevenue'] for d in rolling_dates)
            rolling_profit = sum(daily_metrics[d]['DailyProfit'] for d in rolling_dates)
            
            if rolling_revenue > 0:
                margin_percentage = (rolling_profit / rolling_revenue) * 100
            else:
                margin_percentage = 0
            
            current_date_obj = datetime.strptime(current_date, '%Y-%m-%d')
            if current_date_obj >= end_date_obj - timedelta(days=365):
                results.append({
                    'ReportDate': current_date,
                    'Rolling12MRevenue': round(rolling_revenue, 2),
                    'Rolling12MProfit': round(rolling_profit, 2),
                    'Rolling12MMarginPercentage': round(margin_percentage, 2)
                })
        
        return jsonify(results)
    
    except Exception as e:
        print(f"Error in rolling_metrics: {str(e)}")
        return jsonify([])

@app.route('/api/kpi-summary')
def kpi_summary():
    """Get KPI summary metrics"""
    start_date = request.args.get('start_date', '2023-01-01')
    end_date = request.args.get('end_date', '2024-12-31')
    
    try:
        start_date_obj = datetime.strptime(start_date, '%Y-%m-%d')
        end_date_obj = datetime.strptime(end_date, '%Y-%m-%d')
        period_length = (end_date_obj - start_date_obj).days
        
        prev_end_date_obj = start_date_obj - timedelta(days=1)
        prev_start_date_obj = prev_end_date_obj - timedelta(days=period_length)
        
        prev_start_date = prev_start_date_obj.strftime('%Y-%m-%d')
        prev_end_date = prev_end_date_obj.strftime('%Y-%m-%d')
        
        current_filters = {
            'invoice_date': (start_date, end_date)
        }
        
        current_data = execute_supabase_query(
            table='revenue_margin_data',
            select_fields='total_excluding_tax, profit, order_id',
            filters=current_filters
        )
        
        prev_filters = {
            'invoice_date': (prev_start_date, prev_end_date)
        }
        
        prev_data = execute_supabase_query(
            table='revenue_margin_data',
            select_fields='total_excluding_tax, profit',
            filters=prev_filters
        )
        
        total_revenue = sum(record['total_excluding_tax'] for record in current_data)
        total_profit = sum(record['profit'] for record in current_data)
        total_transactions = len(current_data)
        unique_customers = len(set(record['order_id'] for record in current_data))  # Approximate
        
        prev_total_revenue = sum(record['total_excluding_tax'] for record in prev_data)
        prev_total_profit = sum(record['profit'] for record in prev_data)
        
        if total_revenue > 0:
            overall_margin_percentage = (total_profit / total_revenue) * 100
        else:
            overall_margin_percentage = 0
        
        if prev_total_revenue > 0:
            yoy_revenue_growth = ((total_revenue - prev_total_revenue) / prev_total_revenue) * 100
        else:
            yoy_revenue_growth = 0
        
        if prev_total_profit > 0:
            yoy_profit_growth = ((total_profit - prev_total_profit) / prev_total_profit) * 100
        else:
            yoy_profit_growth = 0
        
        result = {
            'TotalRevenue': round(total_revenue, 2),
            'TotalProfit': round(total_profit, 2),
            'TotalTransactions': total_transactions,
            'UniqueCustomers': unique_customers,
            'OverallMarginPercentage': round(overall_margin_percentage, 2),
            'YoYRevenueGrowth': round(yoy_revenue_growth, 2),
            'YoYProfitGrowth': round(yoy_profit_growth, 2)
        }
        
        return jsonify(result)
    
    except Exception as e:
        print(f"Error in kpi_summary: {str(e)}")
        return jsonify({})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
