#!/usr/bin/env python3
"""
Upload the corrected 12-month distributed data to Supabase
This script uploads the newly generated data with proper seasonal distribution.
"""

import pandas as pd
import subprocess
import json
import os

PROJECT_ID = "kzujalwtfxipkvjeqtms"
TABLE_NAME = "wide-world-importers"

def run_mcp_execute_sql(query: str) -> dict:
    """Execute SQL using MCP command"""
    try:
        result = subprocess.run([
            'mcp-cli', 'tool', 'call', 'execute_sql',
            '--server', 'supabase',
            '--input', json.dumps({
                'project_id': PROJECT_ID,
                'query': query
            })
        ], capture_output=True, text=True, check=True)
        
        return {"success": True, "output": result.stdout}
        
    except subprocess.CalledProcessError as e:
        print(f"MCP command failed: {e}")
        return {"success": False, "error": str(e)}

def upload_corrected_data():
    """Upload the corrected 12-month data to Supabase"""
    print("Uploading corrected 12-month distributed data to Supabase...")
    
    df = pd.read_csv('wide_world_importers_data.csv')
    print(f"Loaded {len(df)} records from CSV")
    
    monthly_counts = df.groupby(['calendar_month_number', 'calendar_month_label']).size().reset_index(name='count')
    print("\nMonthly distribution verification:")
    for _, row in monthly_counts.iterrows():
        print(f"  {row['calendar_month_label']}: {row['count']} records")
    
    batch_size = 50
    successful_batches = 0
    total_batches = (len(df) + batch_size - 1) // batch_size
    
    print(f"\nUploading {len(df)} records in {total_batches} batches of {batch_size} records each...")
    
    for i in range(0, len(df), batch_size):
        batch = df.iloc[i:i + batch_size]
        batch_num = (i // batch_size) + 1
        
        if len(batch) == 0:
            continue
        
        records = batch.to_dict('records')
        
        columns = list(records[0].keys())
        column_names = ', '.join([f'"{col}"' for col in columns])
        
        values_clauses = []
        for record in records:
            values = []
            for col in columns:
                value = record[col]
                if pd.isna(value) or value is None:
                    values.append('NULL')
                elif isinstance(value, str):
                    escaped_value = value.replace("'", "''")
                    values.append(f"'{escaped_value}'")
                elif isinstance(value, bool):
                    values.append('TRUE' if value else 'FALSE')
                else:
                    values.append(str(value))
            values_clauses.append(f"({', '.join(values)})")
        
        values_part = ',\n    '.join(values_clauses)
        
        insert_sql = f"""INSERT INTO "{TABLE_NAME}" ({column_names})
VALUES
    {values_part};"""
        
        result = run_mcp_execute_sql(insert_sql)
        
        if result.get('success', True):
            successful_batches += 1
            print(f"  ✓ Batch {batch_num}/{total_batches} uploaded successfully ({len(batch)} records)")
        else:
            print(f"  ✗ Batch {batch_num}/{total_batches} failed: {result.get('error', 'Unknown error')}")
    
    print(f"\nUpload Summary:")
    print(f"✓ Successful batches: {successful_batches}/{total_batches}")
    print(f"✓ Total records uploaded: {successful_batches * batch_size}")
    
    return successful_batches == total_batches

if __name__ == "__main__":
    success = upload_corrected_data()
    exit(0 if success else 1)
