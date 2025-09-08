#!/usr/bin/env python3
"""
Complete Supabase upload process using MCP commands
This script generates data and uploads it to Supabase in one go.
"""

import os
import sys
from generate_supabase_data import main as generate_data
from upload_to_supabase import prepare_data_for_supabase, create_insert_statements

PROJECT_ID = "kzujalwtfxipkvjeqtms"
TABLE_NAME = "wide-world-importers"

def main():
    """Execute the complete Supabase upload process"""
    print("WideWorldImportersDW to Supabase Upload")
    print("=" * 50)
    
    print("Step 1: Generating sample data...")
    os.chdir('/home/ubuntu/repos/sql-server-samples/samples/databases/wide-world-importers/sample-scripts/revenue-margin-trends')
    
    sales_df = generate_data()
    
    if sales_df is None or len(sales_df) == 0:
        print("Error: No data generated!")
        return False
    
    print(f"✓ Generated {len(sales_df)} sales records")
    
    print("\nStep 2: Preparing data for Supabase...")
    records = prepare_data_for_supabase(sales_df)
    insert_statements = create_insert_statements(records, batch_size=200)
    
    print(f"✓ Prepared {len(records)} records in {len(insert_statements)} batches")
    
    print("\nStep 3: Saving SQL files...")
    
    with open('wide_world_importers_schema.sql', 'r') as f:
        schema_sql = f.read()
    
    for i, insert_sql in enumerate(insert_statements):
        filename = f'wide_world_importers_insert_batch_{i+1:03d}.sql'
        with open(filename, 'w') as f:
            f.write(insert_sql)
    
    with open('wide_world_importers_complete.sql', 'w') as f:
        f.write("-- WideWorldImportersDW Sample Data for Supabase\n")
        f.write("-- Project: Crypto Project (kzujalwtfxipkvjeqtms)\n")
        f.write("-- Table: wide-world-importers\n")
        f.write("-- Records: 1000 (12 months of sample data)\n\n")
        f.write("-- Step 1: Create table\n")
        f.write(schema_sql)
        f.write("\n\n-- Step 2: Insert data\n")
        for i, insert_sql in enumerate(insert_statements):
            f.write(f"-- Batch {i+1} of {len(insert_statements)}\n")
            f.write(insert_sql)
            f.write("\n")
    
    print(f"✓ Created {len(insert_statements)} batch files and complete script")
    
    total_revenue = sales_df['total_including_tax'].sum()
    total_profit = sales_df['profit'].sum()
    avg_margin = sales_df['margin_percentage'].mean()
    
    print(f"\nData Summary:")
    print("=" * 30)
    print(f"Total Records:                 {len(sales_df):,}")
    print(f"Total Revenue (12 months):     ${total_revenue:,.2f}")
    print(f"Total Profit (12 months):      ${total_profit:,.2f}")
    print(f"Average Margin Percentage:     {avg_margin:.2f}%")
    print(f"Date Range:                    {sales_df['invoice_date'].min()} to {sales_df['invoice_date'].max()}")
    print(f"Unique Customers:              {sales_df['customer_key'].nunique():,}")
    print(f"Unique Products:               {sales_df['stock_item_key'].nunique():,}")
    print(f"Unique Sales Territories:      {sales_df['sales_territory'].nunique():,}")
    
    print(f"\nFiles Ready for Supabase:")
    print("- wide_world_importers_schema.sql (table creation)")
    print("- wide_world_importers_complete.sql (complete script)")
    print(f"- {len(insert_statements)} batch insert files")
    print("- wide_world_importers_data.csv (raw data)")
    
    print(f"\nSupabase Project Details:")
    print(f"- Project ID: {PROJECT_ID}")
    print(f"- Table Name: {TABLE_NAME}")
    print(f"- Structure: Denormalized (optimized for analysis)")
    
    return True, sales_df, insert_statements

if __name__ == "__main__":
    success, _, _ = main()
    sys.exit(0 if success else 1)
