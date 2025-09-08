#!/usr/bin/env python3
"""
Generate 12 months of sample WideWorldImportersDW data for Supabase
This script creates realistic sales data based on the WWI schema and uploads it to Supabase.
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import json
import random
from typing import List, Dict, Any

np.random.seed(42)
random.seed(42)

def generate_date_dimension(start_date: datetime, end_date: datetime) -> pd.DataFrame:
    """Generate date dimension data for the specified range"""
    dates = pd.date_range(start=start_date, end=end_date, freq='D')
    
    date_data = []
    for date in dates:
        date_data.append({
            'date_key': date.strftime('%Y%m%d'),
            'date': date.strftime('%Y-%m-%d'),
            'calendar_year': date.year,
            'calendar_month_number': date.month,
            'calendar_month_label': date.strftime('%b'),
            'calendar_month_year_label': date.strftime('%b-%Y'),
            'calendar_quarter_number': (date.month - 1) // 3 + 1,
            'calendar_quarter_label': f'Q{(date.month - 1) // 3 + 1}',
            'day_of_week': date.strftime('%A'),
            'day_of_week_number': date.weekday() + 1,
            'is_weekend': date.weekday() >= 5,
            'fiscal_year': date.year if date.month >= 7 else date.year - 1,
            'fiscal_month_number': ((date.month - 7) % 12) + 1
        })
    
    return pd.DataFrame(date_data)

def generate_customer_dimension(num_customers: int = 500) -> pd.DataFrame:
    """Generate customer dimension data"""
    categories = ['Retail', 'Corporate', 'Government', 'Educational', 'Healthcare']
    buying_groups = ['Standard', 'Premium', 'Enterprise', 'Bulk', 'Wholesale']
    
    customer_names = [
        'Acme Corp', 'Global Industries', 'Tech Solutions', 'Metro Services',
        'Prime Retail', 'City Hospital', 'State University', 'Local Government',
        'Regional Bank', 'Community Center', 'Downtown Store', 'Suburban Mall',
        'Industrial Supply', 'Medical Center', 'School District', 'Public Works'
    ]
    
    customers = []
    for i in range(num_customers):
        base_name = random.choice(customer_names)
        customer_name = f"{base_name} #{i+1:03d}"
        
        customers.append({
            'customer_key': i + 1,
            'wwi_customer_id': i + 1000,
            'customer': customer_name,
            'bill_to_customer': customer_name,
            'category': random.choice(categories),
            'buying_group': random.choice(buying_groups),
            'primary_contact': f"Contact {i+1:03d}",
            'postal_code': f"{random.randint(10000, 99999)}",
            'valid_from': '2020-01-01',
            'valid_to': '2030-12-31'
        })
    
    return pd.DataFrame(customers)

def generate_stock_item_dimension(num_items: int = 200) -> pd.DataFrame:
    """Generate stock item dimension data"""
    colors = ['Red', 'Blue', 'Green', 'Yellow', 'Black', 'White', 'Gray', 'Orange', 'Purple', 'Brown']
    brands = ['Premium', 'Standard', 'Economy', 'Deluxe', 'Professional', 'Commercial']
    sizes = ['Small', 'Medium', 'Large', 'XL', '10mm', '20mm', '50mm', '100mm']
    packages = ['Each', 'Box', 'Carton', 'Pallet', 'Case', 'Bundle']
    
    product_types = [
        'Widget', 'Gadget', 'Tool', 'Component', 'Assembly', 'Part',
        'Device', 'Instrument', 'Equipment', 'Accessory', 'Supply', 'Material'
    ]
    
    stock_items = []
    for i in range(num_items):
        product_type = random.choice(product_types)
        brand = random.choice(brands)
        color = random.choice(colors)
        size = random.choice(sizes)
        
        unit_price = round(random.uniform(5.0, 500.0), 2)
        tax_rate = random.choice([0.0, 0.05, 0.10, 0.15])
        
        stock_items.append({
            'stock_item_key': i + 1,
            'wwi_stock_item_id': i + 2000,
            'stock_item': f"{brand} {color} {product_type} {size}",
            'color': color,
            'selling_package': random.choice(packages),
            'buying_package': random.choice(packages),
            'brand': brand,
            'size': size,
            'lead_time_days': random.randint(1, 30),
            'quantity_per_outer': random.randint(1, 50),
            'is_chiller_stock': random.choice([True, False]),
            'barcode': f"BAR{i+1:06d}",
            'tax_rate': tax_rate,
            'unit_price': unit_price,
            'recommended_retail_price': round(unit_price * 1.3, 2),
            'typical_weight_per_unit': round(random.uniform(0.1, 10.0), 3),
            'valid_from': '2020-01-01',
            'valid_to': '2030-12-31'
        })
    
    return pd.DataFrame(stock_items)

def generate_city_dimension(num_cities: int = 50) -> pd.DataFrame:
    """Generate city dimension data"""
    cities = [
        'New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix',
        'Philadelphia', 'San Antonio', 'San Diego', 'Dallas', 'San Jose',
        'Austin', 'Jacksonville', 'Fort Worth', 'Columbus', 'Charlotte',
        'San Francisco', 'Indianapolis', 'Seattle', 'Denver', 'Washington'
    ]
    
    states = ['NY', 'CA', 'IL', 'TX', 'AZ', 'PA', 'FL', 'OH', 'NC', 'WA', 'CO', 'DC']
    sales_territories = ['North', 'South', 'East', 'West', 'Central']
    
    city_data = []
    for i in range(num_cities):
        city_name = random.choice(cities)
        state = random.choice(states)
        
        city_data.append({
            'city_key': i + 1,
            'wwi_city_id': i + 3000,
            'city': f"{city_name} {i+1:02d}",
            'state_province': state,
            'country': 'United States',
            'continent': 'North America',
            'sales_territory': random.choice(sales_territories),
            'region': random.choice(['Northeast', 'Southeast', 'Midwest', 'Southwest', 'West']),
            'subregion': f"Subregion {i+1:02d}",
            'location': f"POINT(-{random.uniform(70, 120)} {random.uniform(25, 50)})",
            'latest_recorded_population': random.randint(50000, 2000000),
            'valid_from': '2020-01-01',
            'valid_to': '2030-12-31'
        })
    
    return pd.DataFrame(city_data)

def generate_employee_dimension(num_employees: int = 50) -> pd.DataFrame:
    """Generate employee (salesperson) dimension data"""
    first_names = ['John', 'Jane', 'Mike', 'Sarah', 'David', 'Lisa', 'Chris', 'Amy', 'Tom', 'Kate']
    last_names = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez']
    
    employees = []
    for i in range(num_employees):
        first_name = random.choice(first_names)
        last_name = random.choice(last_names)
        
        employees.append({
            'employee_key': i + 1,
            'wwi_employee_id': i + 4000,
            'employee': f"{first_name} {last_name}",
            'preferred_name': first_name,
            'is_salesperson': True,
            'photo': None,
            'valid_from': '2020-01-01',
            'valid_to': '2030-12-31'
        })
    
    return pd.DataFrame(employees)

def generate_denormalized_sales_data(
    date_df: pd.DataFrame,
    customer_df: pd.DataFrame,
    stock_item_df: pd.DataFrame,
    city_df: pd.DataFrame,
    employee_df: pd.DataFrame,
    num_sales: int = 50000
) -> pd.DataFrame:
    """Generate sales fact table data with realistic patterns"""
    
    sales_data = []
    sale_key = 1
    
    for _, date_row in date_df.iterrows():
        date_obj = datetime.strptime(date_row['date'], '%Y-%m-%d')
        
        month = date_obj.month
        if month in [11, 12]:  # Holiday season
            seasonal_factor = 1.4
        elif month in [1, 2]:  # Post-holiday slump
            seasonal_factor = 0.7
        elif month in [6, 7, 8]:  # Summer
            seasonal_factor = 1.1
        else:
            seasonal_factor = 1.0
        
        weekend_factor = 0.6 if date_row['is_weekend'] else 1.0
        
        base_daily_sales = 50
        daily_sales = int(base_daily_sales * seasonal_factor * weekend_factor * random.uniform(0.5, 1.5))
        
        for _ in range(daily_sales):
            customer = customer_df.sample(1).iloc[0]
            stock_item = stock_item_df.sample(1).iloc[0]
            city = city_df.sample(1).iloc[0]
            employee = employee_df.sample(1).iloc[0]
            
            quantity = random.randint(1, 20)
            unit_price = stock_item['unit_price'] * random.uniform(0.8, 1.2)  # Price variation
            
            total_excluding_tax = round(quantity * unit_price, 2)
            tax_amount = round(total_excluding_tax * stock_item['tax_rate'], 2)
            total_including_tax = total_excluding_tax + tax_amount
            
            if customer['category'] == 'Corporate':
                margin_rate = random.uniform(0.15, 0.25)
            elif customer['category'] == 'Retail':
                margin_rate = random.uniform(0.20, 0.35)
            else:
                margin_rate = random.uniform(0.10, 0.30)
            
            profit = round(total_excluding_tax * margin_rate, 2)
            margin_percentage = round(margin_rate * 100, 2)
            
            sales_data.append({
                'sale_key': sale_key,
                'wwi_invoice_id': sale_key + 10000,
                'invoice_date': date_row['date'],
                'delivery_date': (date_obj + timedelta(days=random.randint(1, 7))).strftime('%Y-%m-%d'),
                'calendar_year': date_row['calendar_year'],
                'calendar_month_number': date_row['calendar_month_number'],
                'calendar_month_label': date_row['calendar_month_label'],
                'calendar_month_year_label': date_row['calendar_month_year_label'],
                'calendar_quarter_number': date_row['calendar_quarter_number'],
                'calendar_quarter_label': date_row['calendar_quarter_label'],
                'day_of_week': date_row['day_of_week'],
                'day_of_week_number': date_row['day_of_week_number'],
                'is_weekend': date_row['is_weekend'],
                'fiscal_year': date_row['fiscal_year'],
                'fiscal_month_number': date_row['fiscal_month_number'],
                'customer_key': customer['customer_key'],
                'wwi_customer_id': customer['wwi_customer_id'],
                'customer_name': customer['customer'],
                'customer_category': customer['category'],
                'buying_group': customer['buying_group'],
                'primary_contact': customer['primary_contact'],
                'customer_postal_code': customer['postal_code'],
                'stock_item_key': stock_item['stock_item_key'],
                'wwi_stock_item_id': stock_item['wwi_stock_item_id'],
                'product_name': stock_item['stock_item'],
                'product_color': stock_item['color'],
                'product_brand': stock_item['brand'],
                'product_size': stock_item['size'],
                'selling_package': stock_item['selling_package'],
                'buying_package': stock_item['buying_package'],
                'is_chiller_stock': stock_item['is_chiller_stock'],
                'product_barcode': stock_item['barcode'],
                'city_key': city['city_key'],
                'wwi_city_id': city['wwi_city_id'],
                'city_name': city['city'],
                'state_province': city['state_province'],
                'country': city['country'],
                'continent': city['continent'],
                'sales_territory': city['sales_territory'],
                'region': city['region'],
                'subregion': city['subregion'],
                'city_population': city['latest_recorded_population'],
                'salesperson_key': employee['employee_key'],
                'wwi_employee_id': employee['wwi_employee_id'],
                'salesperson_name': employee['employee'],
                'salesperson_preferred_name': employee['preferred_name'],
                'description': stock_item['stock_item'],
                'quantity': quantity,
                'unit_price': round(unit_price, 2),
                'tax_rate': stock_item['tax_rate'],
                'total_excluding_tax': total_excluding_tax,
                'tax_amount': tax_amount,
                'profit': profit,
                'total_including_tax': total_including_tax,
                'margin_percentage': margin_percentage,
                'total_dry_items': quantity if not stock_item['is_chiller_stock'] else 0,
                'total_chiller_items': quantity if stock_item['is_chiller_stock'] else 0,
                'lineage_key': 1
            })
            
            sale_key += 1
            
            if len(sales_data) >= num_sales:
                break
        
        if len(sales_data) >= num_sales:
            break
    
    return pd.DataFrame(sales_data)

def create_denormalized_table_schema() -> str:
    """Return SQL DDL statement for creating denormalized wide-world-importers table"""
    
    return """
    CREATE TABLE IF NOT EXISTS "wide-world-importers" (
        -- Primary identifiers
        sale_key BIGINT PRIMARY KEY,
        wwi_invoice_id INTEGER NOT NULL,
        
        -- Date dimensions
        invoice_date DATE NOT NULL,
        delivery_date DATE,
        calendar_year INTEGER NOT NULL,
        calendar_month_number INTEGER NOT NULL,
        calendar_month_label VARCHAR(3) NOT NULL,
        calendar_month_year_label VARCHAR(8) NOT NULL,
        calendar_quarter_number INTEGER NOT NULL,
        calendar_quarter_label VARCHAR(2) NOT NULL,
        day_of_week VARCHAR(10) NOT NULL,
        day_of_week_number INTEGER NOT NULL,
        is_weekend BOOLEAN NOT NULL,
        fiscal_year INTEGER NOT NULL,
        fiscal_month_number INTEGER NOT NULL,
        
        -- Customer dimensions
        customer_key INTEGER NOT NULL,
        wwi_customer_id INTEGER NOT NULL,
        customer_name VARCHAR(100) NOT NULL,
        customer_category VARCHAR(50) NOT NULL,
        buying_group VARCHAR(50) NOT NULL,
        primary_contact VARCHAR(50) NOT NULL,
        customer_postal_code VARCHAR(10) NOT NULL,
        
        -- Product dimensions
        stock_item_key INTEGER NOT NULL,
        wwi_stock_item_id INTEGER NOT NULL,
        product_name VARCHAR(100) NOT NULL,
        product_color VARCHAR(20) NOT NULL,
        product_brand VARCHAR(50) NOT NULL,
        product_size VARCHAR(20) NOT NULL,
        selling_package VARCHAR(50) NOT NULL,
        buying_package VARCHAR(50) NOT NULL,
        is_chiller_stock BOOLEAN NOT NULL,
        product_barcode VARCHAR(50),
        
        -- Geography dimensions
        city_key INTEGER NOT NULL,
        wwi_city_id INTEGER NOT NULL,
        city_name VARCHAR(50) NOT NULL,
        state_province VARCHAR(50) NOT NULL,
        country VARCHAR(50) NOT NULL,
        continent VARCHAR(30) NOT NULL,
        sales_territory VARCHAR(50) NOT NULL,
        region VARCHAR(50) NOT NULL,
        subregion VARCHAR(50) NOT NULL,
        city_population INTEGER,
        
        -- Employee dimensions
        salesperson_key INTEGER NOT NULL,
        wwi_employee_id INTEGER NOT NULL,
        salesperson_name VARCHAR(50) NOT NULL,
        salesperson_preferred_name VARCHAR(50) NOT NULL,
        
        -- Transaction facts
        description VARCHAR(100) NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price DECIMAL(18,2) NOT NULL,
        tax_rate DECIMAL(18,3) NOT NULL,
        total_excluding_tax DECIMAL(18,2) NOT NULL,
        tax_amount DECIMAL(18,2) NOT NULL,
        profit DECIMAL(18,2) NOT NULL,
        total_including_tax DECIMAL(18,2) NOT NULL,
        margin_percentage DECIMAL(5,2) NOT NULL,
        total_dry_items INTEGER NOT NULL,
        total_chiller_items INTEGER NOT NULL,
        
        -- Metadata
        lineage_key INTEGER NOT NULL DEFAULT 1,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );
    
    -- Create indexes for common query patterns
    CREATE INDEX IF NOT EXISTS idx_wwi_invoice_date ON "wide-world-importers"(invoice_date);
    CREATE INDEX IF NOT EXISTS idx_wwi_customer ON "wide-world-importers"(customer_key);
    CREATE INDEX IF NOT EXISTS idx_wwi_product ON "wide-world-importers"(stock_item_key);
    CREATE INDEX IF NOT EXISTS idx_wwi_territory ON "wide-world-importers"(sales_territory);
    CREATE INDEX IF NOT EXISTS idx_wwi_month_year ON "wide-world-importers"(calendar_year, calendar_month_number);
    CREATE INDEX IF NOT EXISTS idx_wwi_margin ON "wide-world-importers"(margin_percentage);
    """

def main():
    """Main function to generate and prepare data for Supabase"""
    print("Generating 12 months of WideWorldImportersDW sample data...")
    print("=" * 60)
    
    end_date = datetime.now().replace(day=1) - timedelta(days=1)  # Last day of previous month
    start_date = end_date.replace(day=1) - timedelta(days=365)    # 12 months ago
    
    print(f"Date range: {start_date.strftime('%Y-%m-%d')} to {end_date.strftime('%Y-%m-%d')}")
    
    print("\nGenerating dimension tables...")
    date_df = generate_date_dimension(start_date, end_date)
    customer_df = generate_customer_dimension(500)
    stock_item_df = generate_stock_item_dimension(200)
    city_df = generate_city_dimension(50)
    employee_df = generate_employee_dimension(50)
    
    print(f"- Date dimension: {len(date_df)} records")
    print(f"- Customer dimension: {len(customer_df)} records")
    print(f"- Stock Item dimension: {len(stock_item_df)} records")
    print(f"- City dimension: {len(city_df)} records")
    print(f"- Employee dimension: {len(employee_df)} records")
    
    print("\nGenerating denormalized sales data...")
    sales_df = generate_denormalized_sales_data(
        date_df, customer_df, stock_item_df, city_df, employee_df, 
        num_sales=1000
    )
    print(f"- Denormalized sales data: {len(sales_df)} records")
    
    print("\nSaving data to CSV file...")
    sales_df.to_csv('wide_world_importers_data.csv', index=False)
    
    print("\nGenerating Supabase table schema...")
    schema = create_denormalized_table_schema()
    with open('wide_world_importers_schema.sql', 'w') as f:
        f.write("-- WIDE WORLD IMPORTERS DENORMALIZED TABLE\n")
        f.write(schema)
    
    print("\nData Summary:")
    print("=" * 40)
    
    total_revenue = sales_df['total_including_tax'].sum()
    total_profit = sales_df['profit'].sum()
    avg_margin = (total_profit / sales_df['total_excluding_tax'].sum()) * 100
    
    print(f"Total Revenue (12 months):     ${total_revenue:,.2f}")
    print(f"Total Profit (12 months):      ${total_profit:,.2f}")
    print(f"Average Margin Percentage:     {avg_margin:.2f}%")
    print(f"Total Transactions:            {len(sales_df):,}")
    print(f"Average Revenue per Month:     ${total_revenue/12:,.2f}")
    print(f"Date Range:                    {start_date.strftime('%Y-%m-%d')} to {end_date.strftime('%Y-%m-%d')}")
    
    monthly_stats = sales_df.groupby(sales_df['invoice_date'].str[:7]).agg({
        'total_including_tax': 'sum',
        'profit': 'sum',
        'sale_key': 'count'
    }).round(2)
    monthly_stats['margin_pct'] = (monthly_stats['profit'] / 
                                  sales_df.groupby(sales_df['invoice_date'].str[:7])['total_excluding_tax'].sum() * 100).round(2)
    
    print(f"\nMonthly Breakdown:")
    print(monthly_stats.to_string())
    
    print(f"\nFiles created:")
    print("- wide_world_importers_data.csv")
    print("- wide_world_importers_schema.sql")
    
    print(f"\nReady for Supabase import!")
    
    return sales_df

if __name__ == "__main__":
    main()
