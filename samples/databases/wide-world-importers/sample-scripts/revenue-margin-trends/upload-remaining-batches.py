#!/usr/bin/env python3
"""
Upload remaining batches to complete the 1000 record upload
This script uploads batches 6-10 to complete the dataset.
"""

import subprocess
import json
import os

PROJECT_ID = "kzujalwtfxipkvjeqtms"

def run_mcp_execute_sql(query: str) -> dict:
    """Execute SQL using MCP command"""
    try:
        cmd = [
            'mcp-cli', 'tool', 'call', 'execute_sql',
            '--server', 'supabase',
            '--input', json.dumps({
                'project_id': PROJECT_ID,
                'query': query
            })
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return {"success": True, "output": result.stdout}
        
    except subprocess.CalledProcessError as e:
        print(f"MCP command failed: {e}")
        return {"success": False, "error": str(e)}

def upload_remaining_data():
    """Upload the remaining data from CSV in smaller batches"""
    print("Uploading remaining data to complete 1000 records...")
    
    import pandas as pd
    df = pd.read_csv('wide_world_importers_data.csv')
    
    remaining_df = df.iloc[500:1000]  # Records 501-1000
    
    print(f"Uploading {len(remaining_df)} remaining records...")
    
    batch_size = 50
    successful_batches = 0
    
    for i in range(0, len(remaining_df), batch_size):
        batch = remaining_df.iloc[i:i + batch_size]
        
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
        
        insert_sql = f"""INSERT INTO "wide-world-importers" ({column_names})
VALUES
    {values_part};"""
        
        result = run_mcp_execute_sql(insert_sql)
        
        if result.get('success', True):
            successful_batches += 1
            print(f"  ✓ Batch {i//batch_size + 1} uploaded successfully ({len(batch)} records)")
        else:
            print(f"  ✗ Batch {i//batch_size + 1} failed: {result.get('error', 'Unknown error')}")
    
    print(f"\nCompleted: {successful_batches} batches uploaded")
    return successful_batches > 0

if __name__ == "__main__":
    upload_remaining_data()
