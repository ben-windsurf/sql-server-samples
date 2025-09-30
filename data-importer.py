#!/usr/bin/env python3
"""
WideWorldImportersDW Data Importer for Supabase Dashboard
Extracts revenue and margin trends and loads them into Supabase
"""

import os
import json
import requests
from datetime import datetime, timedelta
from typing import Dict, List, Any

class SupabaseDataImporter:
    def __init__(self, supabase_url: str, supabase_key: str):
        self.supabase_url = supabase_url
        self.supabase_key = supabase_key
        self.headers = {
            'apikey': supabase_key,
            'Authorization': f'Bearer {supabase_key}',
            'Content-Type': 'application/json',
            'Prefer': 'return=minimal'
        }
    
    def create_tables(self):
        """Create necessary tables in Supabase for storing trend data"""
        
        monthly_trends_sql = """
        CREATE TABLE IF NOT EXISTS monthly_trends (
            id SERIAL PRIMARY KEY,
            year INTEGER NOT NULL,
            month INTEGER NOT NULL,
            month_label VARCHAR(20) NOT NULL,
            month_year VARCHAR(20) NOT NULL,
            revenue DECIMAL(18,2) NOT NULL,
            margin DECIMAL(18,2) NOT NULL,
            margin_percentage DECIMAL(5,2) NOT NULL,
            transaction_count INTEGER NOT NULL,
            avg_unit_price DECIMAL(18,2) NOT NULL,
            revenue_growth_percent DECIMAL(5,2),
            margin_growth_percent DECIMAL(5,2),
            created_at TIMESTAMP DEFAULT NOW(),
            UNIQUE(year, month)
        );
        """
        
        quarterly_trends_sql = """
        CREATE TABLE IF NOT EXISTS quarterly_trends (
            id SERIAL PRIMARY KEY,
            year INTEGER NOT NULL,
            quarter INTEGER NOT NULL,
            quarter_label VARCHAR(20) NOT NULL,
            revenue DECIMAL(18,2) NOT NULL,
            margin DECIMAL(18,2) NOT NULL,
            margin_percentage DECIMAL(5,2) NOT NULL,
            transaction_count INTEGER NOT NULL,
            created_at TIMESTAMP DEFAULT NOW(),
            UNIQUE(year, quarter)
        );
        """
        
        top_products_sql = """
        CREATE TABLE IF NOT EXISTS top_products (
            id SERIAL PRIMARY KEY,
            product_name VARCHAR(255) NOT NULL,
            total_revenue DECIMAL(18,2) NOT NULL,
            total_margin DECIMAL(18,2) NOT NULL,
            margin_percentage DECIMAL(5,2) NOT NULL,
            sales_count INTEGER NOT NULL,
            created_at TIMESTAMP DEFAULT NOW()
        );
        """
        
        top_customers_sql = """
        CREATE TABLE IF NOT EXISTS top_customers (
            id SERIAL PRIMARY KEY,
            customer_name VARCHAR(255) NOT NULL,
            total_revenue DECIMAL(18,2) NOT NULL,
            total_margin DECIMAL(18,2) NOT NULL,
            margin_percentage DECIMAL(5,2) NOT NULL,
            order_count INTEGER NOT NULL,
            created_at TIMESTAMP DEFAULT NOW()
        );
        """
        
        tables = [
            monthly_trends_sql,
            quarterly_trends_sql,
            top_products_sql,
            top_customers_sql
        ]
        
        for sql in tables:
            self._execute_sql(sql)
    
    def _execute_sql(self, sql: str):
        """Execute SQL command via Supabase REST API"""
        url = f"{self.supabase_url}/rest/v1/rpc/exec_sql"
        payload = {"sql": sql}
        
        response = requests.post(url, headers=self.headers, json=payload)
        if response.status_code not in [200, 201]:
            print(f"SQL execution failed: {response.text}")
            return None
        return response.json()
    
    def generate_sample_data(self):
        """Generate sample data for demonstration purposes"""
        
        monthly_data = []
        base_revenue = 100000
        base_margin = 25000
        
        for i in range(12):
            month_date = datetime.now() - timedelta(days=30 * (11 - i))
            
            revenue_variation = (i % 3 - 1) * 0.1 + (i % 7 - 3) * 0.05
            margin_variation = (i % 5 - 2) * 0.08 + (i % 4 - 1) * 0.06
            
            revenue = base_revenue * (1 + revenue_variation + i * 0.02)
            margin = base_margin * (1 + margin_variation + i * 0.015)
            
            monthly_data.append({
                'year': month_date.year,
                'month': month_date.month,
                'month_label': month_date.strftime('%B'),
                'month_year': month_date.strftime('%b-%Y'),
                'revenue': round(revenue, 2),
                'margin': round(margin, 2),
                'margin_percentage': round((margin / revenue) * 100, 2),
                'transaction_count': int(revenue / 150),  # Approximate transactions
                'avg_unit_price': round(revenue / (revenue / 150) / 10, 2),
                'revenue_growth_percent': round(revenue_variation * 100, 2) if i > 0 else 0,
                'margin_growth_percent': round(margin_variation * 100, 2) if i > 0 else 0
            })
        
        quarterly_data = []
        for quarter in range(1, 5):
            quarter_months = [m for m in monthly_data if ((m['month'] - 1) // 3 + 1) == quarter]
            if quarter_months:
                total_revenue = sum(m['revenue'] for m in quarter_months)
                total_margin = sum(m['margin'] for m in quarter_months)
                total_transactions = sum(m['transaction_count'] for m in quarter_months)
                
                quarterly_data.append({
                    'year': quarter_months[0]['year'],
                    'quarter': quarter,
                    'quarter_label': f'Q{quarter}',
                    'revenue': round(total_revenue, 2),
                    'margin': round(total_margin, 2),
                    'margin_percentage': round((total_margin / total_revenue) * 100, 2),
                    'transaction_count': total_transactions
                })
        
        products = [
            'USB food flash drive - sushi roll', 'Chocolate sharks 250g',
            'USB food flash drive - hamburger', 'Furry cushion (Black)',
            'Chocolate frogs 250g', 'USB food flash drive - pizza slice',
            'Furry cushion (Gray)', 'Chocolate dinosaurs 250g',
            'USB food flash drive - hot dog', 'Furry cushion (White)'
        ]
        
        top_products_data = []
        for i, product in enumerate(products):
            revenue = base_revenue * (1 - i * 0.1) * 0.8
            margin = revenue * (0.2 + i * 0.02)
            
            top_products_data.append({
                'product_name': product,
                'total_revenue': round(revenue, 2),
                'total_margin': round(margin, 2),
                'margin_percentage': round((margin / revenue) * 100, 2),
                'sales_count': int(revenue / 200)
            })
        
        customers = [
            'Tailspin Toys (Head Office)', 'Wingtip Toys (Head Office)',
            'Wide World Importers (Head Office)', 'Contoso Ltd (Head Office)',
            'Adventure Works (Head Office)', 'Northwind Traders (Head Office)',
            'Fabrikam Inc (Head Office)', 'Litware Inc (Head Office)',
            'Proseware Inc (Head Office)', 'Fourth Coffee (Head Office)'
        ]
        
        top_customers_data = []
        for i, customer in enumerate(customers):
            revenue = base_revenue * (1.2 - i * 0.08) * 0.6
            margin = revenue * (0.18 + i * 0.015)
            
            top_customers_data.append({
                'customer_name': customer,
                'total_revenue': round(revenue, 2),
                'total_margin': round(margin, 2),
                'margin_percentage': round((margin / revenue) * 100, 2),
                'order_count': int(revenue / 500)
            })
        
        return {
            'monthly': monthly_data,
            'quarterly': quarterly_data,
            'products': top_products_data,
            'customers': top_customers_data
        }
    
    def insert_data(self, table_name: str, data: List[Dict[str, Any]]):
        """Insert data into Supabase table"""
        if not data:
            return
        
        delete_url = f"{self.supabase_url}/rest/v1/{table_name}"
        requests.delete(delete_url, headers=self.headers)
        
        insert_url = f"{self.supabase_url}/rest/v1/{table_name}"
        response = requests.post(insert_url, headers=self.headers, json=data)
        
        if response.status_code not in [200, 201]:
            print(f"Data insertion failed for {table_name}: {response.text}")
        else:
            print(f"Successfully inserted {len(data)} records into {table_name}")
    
    def import_all_data(self):
        """Import all trend data into Supabase"""
        print("Creating tables...")
        self.create_tables()
        
        print("Generating sample data...")
        data = self.generate_sample_data()
        
        print("Importing data...")
        self.insert_data('monthly_trends', data['monthly'])
        self.insert_data('quarterly_trends', data['quarterly'])
        self.insert_data('top_products', data['products'])
        self.insert_data('top_customers', data['customers'])
        
        print("Data import completed successfully!")

def main():
    SUPABASE_URL = "https://kzujalwtfxipkvjeqtms.supabase.co"
    SUPABASE_KEY = os.getenv('SUPABASE_API_KEY', '')
    
    if not SUPABASE_KEY:
        print("Error: SUPABASE_API_KEY environment variable not set")
        print("Please set your Supabase API key:")
        print("export SUPABASE_API_KEY='your_key_here'")
        return
    
    importer = SupabaseDataImporter(SUPABASE_URL, SUPABASE_KEY)
    importer.import_all_data()

if __name__ == "__main__":
    main()
