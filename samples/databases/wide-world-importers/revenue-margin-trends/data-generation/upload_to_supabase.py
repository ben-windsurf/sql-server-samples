#!/usr/bin/env python3
"""
Upload generated WideWorldImporters data to Supabase using MCP integration
"""

import json
import sys
import os
from typing import List, Dict, Any

def load_generated_data(filename: str) -> List[Dict[str, Any]]:
    """Load the generated data from JSON file"""
    try:
        with open(filename, 'r') as f:
            data = json.load(f)
        print(f"Loaded {len(data)} records from {filename}")
        return data
    except FileNotFoundError:
        print(f"Error: File {filename} not found. Please run generate_sample_data.py first.")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in {filename}: {e}")
        sys.exit(1)

def format_data_for_sql(data: List[Dict[str, Any]]) -> str:
    """Format data for SQL INSERT statements"""
    if not data:
        return ""
    
    insert_statements = []
    batch_size = 1000  # Insert in batches of 1000 records
    
    for i in range(0, len(data), batch_size):
        batch = data[i:i + batch_size]
        values = []
        
        for record in batch:
            value_str = f"""(
                '{record['order_id']}',
                '{record['invoice_date']}',
                '{record['customer_segment']}',
                '{record['product_brand']}',
                '{record['product_color']}',
                {record['quantity']},
                {record['total_excluding_tax']},
                {record['total_including_tax']},
                {record['profit']},
                {record['year']},
                {record['month']},
                {record['quarter']},
                {record['weekday']}
            )"""
            values.append(value_str)
        
        insert_sql = f"""
INSERT INTO revenue_margin_data (
    order_id, invoice_date, customer_segment, product_brand, product_color,
    quantity, total_excluding_tax, total_including_tax, profit,
    year, month, quarter, weekday
) VALUES {','.join(values)};
"""
        insert_statements.append(insert_sql)
    
    return '\n'.join(insert_statements)

def create_sql_file(data: List[Dict[str, Any]], filename: str):
    """Create SQL file with all INSERT statements"""
    sql_content = format_data_for_sql(data)
    
    with open(filename, 'w') as f:
        f.write("-- Generated WideWorldImporters data for Supabase\n")
        f.write("-- This file contains INSERT statements for 24 months of realistic data\n\n")
        f.write(sql_content)
    
    print(f"SQL file created: {filename}")
    print(f"File size: {os.path.getsize(filename) / 1024 / 1024:.2f} MB")

def main():
    """Main function to process and prepare data for Supabase upload"""
    print("WideWorldImporters Supabase Upload Preparation")
    print("=" * 50)
    
    data_file = "wideworldimporters_24months_data.json"
    data = load_generated_data(data_file)
    
    sql_file = "supabase_insert_data.sql"
    create_sql_file(data, sql_file)
    
    try:
        with open("data_summary_stats.json", 'r') as f:
            stats = json.load(f)
        
        print(f"\nData Summary:")
        print(f"Total Records: {len(data):,}")
        print(f"Total Revenue: ${stats['total_revenue']:,.2f}")
        print(f"Total Profit: ${stats['total_profit']:,.2f}")
        print(f"Average Margin: {stats['average_margin']:.2f}%")
        print(f"Date Range: {stats['date_range']['start']} to {stats['date_range']['end']}")
        print(f"Customer Segments: {len(stats['customer_segments'])}")
        
    except FileNotFoundError:
        print("Warning: Summary stats file not found")
    
    print(f"\nFiles ready for Supabase upload:")
    print(f"- {data_file} (JSON format)")
    print(f"- {sql_file} (SQL INSERT statements)")
    print(f"\nNext steps:")
    print("1. Use MCP tools to create Supabase project and table")
    print("2. Execute the SQL file or use MCP execute_sql with batched inserts")
    print("3. Verify data upload with SELECT COUNT(*) FROM revenue_margin_data")

if __name__ == "__main__":
    main()
