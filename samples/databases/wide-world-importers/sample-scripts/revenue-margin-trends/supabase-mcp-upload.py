#!/usr/bin/env python3
"""
Execute the actual Supabase upload using MCP commands
This script uses the MCP Supabase integration to create tables and insert data.
"""

import subprocess
import json
import sys
import os
from upload_to_supabase import main as prepare_upload

PROJECT_ID = "kzujalwtfxipkvjeqtms"
TABLE_NAME = "wide-world-importers"

def run_mcp_command(server: str, tool_name: str, input_data: dict) -> dict:
    """Execute MCP command and return result"""
    try:
        cmd = [
            'mcp-cli', 'tool', 'call', tool_name,
            '--server', server,
            '--input', json.dumps(input_data)
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        
        output_lines = result.stdout.strip().split('\n')
        for line in output_lines:
            if line.startswith('Tool result:'):
                result_json = line.replace('Tool result:', '').strip()
                return json.loads(result_json)
        
        return {"success": True, "output": result.stdout}
        
    except subprocess.CalledProcessError as e:
        print(f"MCP command failed: {e}")
        print(f"stdout: {e.stdout}")
        print(f"stderr: {e.stderr}")
        return {"success": False, "error": str(e)}
    except Exception as e:
        print(f"Error executing MCP command: {e}")
        return {"success": False, "error": str(e)}

def create_table():
    """Create the wide-world-importers table in Supabase"""
    print("Creating table in Supabase...")
    
    with open('wide_world_importers_schema.sql', 'r') as f:
        schema_sql = f.read()
    
    result = run_mcp_command('supabase', 'apply_migration', {
        'project_id': PROJECT_ID,
        'name': 'create_wide_world_importers_table',
        'query': schema_sql
    })
    
    if result.get('success', True):
        print("✓ Table created successfully")
        return True
    else:
        print(f"✗ Failed to create table: {result.get('error', 'Unknown error')}")
        return False

def insert_data_batch(batch_sql: str, batch_num: int) -> bool:
    """Insert a batch of data into Supabase"""
    print(f"Inserting batch {batch_num}...")
    
    result = run_mcp_command('supabase', 'execute_sql', {
        'project_id': PROJECT_ID,
        'query': batch_sql
    })
    
    if result.get('success', True):
        print(f"✓ Batch {batch_num} inserted successfully")
        return True
    else:
        print(f"✗ Failed to insert batch {batch_num}: {result.get('error', 'Unknown error')}")
        return False

def verify_data():
    """Verify the data was inserted correctly"""
    print("Verifying data insertion...")
    
    count_query = f'SELECT COUNT(*) as record_count FROM "{TABLE_NAME}";'
    result = run_mcp_command('supabase', 'execute_sql', {
        'project_id': PROJECT_ID,
        'query': count_query
    })
    
    if result.get('success', True):
        print(f"✓ Data verification successful")
        return True
    else:
        print(f"✗ Data verification failed: {result.get('error', 'Unknown error')}")
        return False

def get_summary_stats():
    """Get summary statistics from the uploaded data"""
    print("Getting summary statistics...")
    
    stats_query = f'''
    SELECT 
        COUNT(*) as total_records,
        SUM(total_including_tax) as total_revenue,
        SUM(profit) as total_profit,
        AVG(margin_percentage) as avg_margin,
        MIN(invoice_date) as min_date,
        MAX(invoice_date) as max_date,
        COUNT(DISTINCT customer_key) as unique_customers,
        COUNT(DISTINCT stock_item_key) as unique_products,
        COUNT(DISTINCT sales_territory) as unique_territories
    FROM "{TABLE_NAME}";
    '''
    
    result = run_mcp_command('supabase', 'execute_sql', {
        'project_id': PROJECT_ID,
        'query': stats_query
    })
    
    if result.get('success', True):
        print("✓ Summary statistics retrieved")
        return True
    else:
        print(f"✗ Failed to get summary statistics: {result.get('error', 'Unknown error')}")
        return False

def main():
    """Main execution function"""
    print("Supabase MCP Upload Process")
    print("=" * 40)
    
    print("Step 1: Preparing data and SQL statements...")
    success, sales_df, insert_statements = prepare_upload()
    
    if not success:
        print("Failed to prepare data")
        return False
    
    print("Step 2: Creating table in Supabase...")
    if not create_table():
        return False
    
    print("Step 3: Inserting data in batches...")
    for i, batch_sql in enumerate(insert_statements):
        if not insert_data_batch(batch_sql, i + 1):
            print(f"Failed at batch {i + 1}")
            return False
    
    print("Step 4: Verifying data...")
    if not verify_data():
        return False
    
    print("Step 5: Getting summary statistics...")
    if not get_summary_stats():
        return False
    
    print("\n" + "=" * 40)
    print("✓ Upload completed successfully!")
    print(f"✓ Table '{TABLE_NAME}' created in Supabase project {PROJECT_ID}")
    print(f"✓ {len(insert_statements)} batches of data inserted")
    print("✓ Data verification passed")
    
    return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
