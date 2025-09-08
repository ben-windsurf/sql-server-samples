#!/usr/bin/env python3
"""
Upload all batches to Supabase using MCP commands
This script uploads all remaining batch files to complete the data upload.
"""

import subprocess
import json
import os
import glob

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
        
        output_lines = result.stdout.strip().split('\n')
        for line in output_lines:
            if line.startswith('Tool result:'):
                result_json = line.replace('Tool result:', '').strip()
                return {"success": True, "result": result_json}
        
        return {"success": True, "output": result.stdout}
        
    except subprocess.CalledProcessError as e:
        print(f"MCP command failed: {e}")
        print(f"stdout: {e.stdout}")
        print(f"stderr: {e.stderr}")
        return {"success": False, "error": str(e)}
    except Exception as e:
        print(f"Error executing MCP command: {e}")
        return {"success": False, "error": str(e)}

def upload_batch_file(batch_file: str) -> bool:
    """Upload a single batch file"""
    print(f"Uploading {batch_file}...")
    
    try:
        with open(batch_file, 'r') as f:
            sql_content = f.read().strip()
        
        if not sql_content:
            print(f"  ✗ Empty file: {batch_file}")
            return False
        
        if sql_content.endswith(';'):
            sql_content = sql_content[:-1]
        
        result = run_mcp_execute_sql(sql_content)
        
        if result.get('success', True):
            print(f"  ✓ Successfully uploaded {batch_file}")
            return True
        else:
            print(f"  ✗ Failed to upload {batch_file}: {result.get('error', 'Unknown error')}")
            return False
            
    except Exception as e:
        print(f"  ✗ Error reading {batch_file}: {e}")
        return False

def main():
    """Main execution function"""
    print("Uploading All Batches to Supabase")
    print("=" * 40)
    
    batch_files = sorted(glob.glob('batch_*.sql'))
    
    if not batch_files:
        print("No batch files found!")
        return False
    
    print(f"Found {len(batch_files)} batch files to upload")
    
    successful_uploads = 0
    failed_uploads = 0
    
    for batch_file in batch_files:
        if upload_batch_file(batch_file):
            successful_uploads += 1
        else:
            failed_uploads += 1
    
    print(f"\nUpload Summary:")
    print(f"✓ Successful uploads: {successful_uploads}")
    print(f"✗ Failed uploads: {failed_uploads}")
    print(f"Total files processed: {len(batch_files)}")
    
    if failed_uploads == 0:
        print("\n🎉 All batches uploaded successfully!")
        return True
    else:
        print(f"\n⚠️  {failed_uploads} batches failed to upload")
        return False

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)
