#!/usr/bin/env python3
"""
Upload CSV data to Supabase using MCP commands
This script reads the generated CSV and uploads it in batches.
"""

import pandas as pd
import json
import sys

PROJECT_ID = "kzujalwtfxipkvjeqtms"
TABLE_NAME = "wide-world-importers"

def create_insert_sql_from_csv(csv_file: str, batch_size: int = 100) -> list:
    """Create SQL INSERT statements from CSV data"""
    print(f"Reading CSV file: {csv_file}")
    df = pd.read_csv(csv_file)
    
    print(f"Loaded {len(df)} records from CSV")
    
    records = df.to_dict('records')
    
    insert_statements = []
    
    for i in range(0, len(records), batch_size):
        batch = records[i:i + batch_size]
        
        if not batch:
            continue
            
        columns = list(batch[0].keys())
        column_names = ', '.join([f'"{col}"' for col in columns])
        
        values_clauses = []
        for record in batch:
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
        
        insert_statements.append(insert_sql)
    
    return insert_statements

def main():
    """Main execution function"""
    print("CSV to Supabase Upload Process")
    print("=" * 40)
    
    insert_statements = create_insert_sql_from_csv('wide_world_importers_data.csv', batch_size=100)
    
    print(f"Created {len(insert_statements)} batch INSERT statements")
    
    for i, insert_sql in enumerate(insert_statements[:5]):  # First 5 batches
        filename = f'batch_{i+1:03d}.sql'
        with open(filename, 'w') as f:
            f.write(insert_sql)
        print(f"Saved {filename}")
    
    print(f"\nReady for MCP upload:")
    print(f"- Project ID: {PROJECT_ID}")
    print(f"- Table: {TABLE_NAME}")
    print(f"- Total batches: {len(insert_statements)}")
    print(f"- Batch files created: batch_001.sql to batch_005.sql")
    
    return insert_statements

if __name__ == "__main__":
    main()
