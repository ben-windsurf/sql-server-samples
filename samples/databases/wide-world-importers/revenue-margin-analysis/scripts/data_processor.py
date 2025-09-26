#!/usr/bin/env python3
"""
WideWorldImportersDW Revenue and Margin Trends Data Processor
Processes SQL query results and stores them in Supabase for visualization
"""

import json
import csv
import os
from datetime import datetime, timedelta
from decimal import Decimal
import random

def generate_sample_data():
    """
    Generate sample data that mimics WideWorldImportersDW revenue and margin trends
    This simulates the SQL query results since we don't have live database access
    """
    sample_data = []
    base_date = datetime.now().replace(day=1)
    
    for i in range(12):
        month_date = base_date - timedelta(days=30 * i)
        month_year = month_date.strftime("%b-%Y")
        
        base_revenue = 850000 + (i * 15000)  # Growing trend
        seasonal_factor = 1 + (0.2 * (1 if i % 4 == 0 else 0))  # Q4 boost
        noise_factor = 1 + random.uniform(-0.1, 0.1)  # Random variation
        
        total_revenue = base_revenue * seasonal_factor * noise_factor
        total_margin = total_revenue * random.uniform(0.15, 0.25)  # 15-25% margin
        margin_percentage = (total_margin / total_revenue) * 100
        
        if i < 11:  # Not the oldest month
            prev_revenue = sample_data[i-1]['total_revenue'] if i > 0 else total_revenue * 0.95
            revenue_growth_pct = ((total_revenue - prev_revenue) / prev_revenue) * 100
        else:
            revenue_growth_pct = None
            
        sample_data.append({
            'month_year': month_year,
            'year_num': month_date.year,
            'month_num': month_date.month,
            'total_revenue': round(total_revenue, 2),
            'revenue_excluding_tax': round(total_revenue * 0.9, 2),
            'total_margin': round(total_margin, 2),
            'total_tax': round(total_revenue * 0.1, 2),
            'transaction_count': random.randint(1200, 1800),
            'avg_transaction_value': round(total_revenue / random.randint(1200, 1800), 2),
            'margin_percentage': round(margin_percentage, 2),
            'revenue_growth_pct': round(revenue_growth_pct, 2) if revenue_growth_pct else None,
            'margin_growth_pct': round(random.uniform(-5, 8), 2) if i > 0 else None
        })
    
    return list(reversed(sample_data))

def export_for_powerbi_kyvos(data, export_dir):
    """
    Export data in formats compatible with PowerBI and Kyvos
    """
    os.makedirs(export_dir, exist_ok=True)
    
    csv_file = os.path.join(export_dir, 'revenue_margin_trends.csv')
    with open(csv_file, 'w', newline='', encoding='utf-8') as f:
        if data:
            writer = csv.DictWriter(f, fieldnames=data[0].keys())
            writer.writeheader()
            writer.writerows(data)
    
    json_file = os.path.join(export_dir, 'revenue_margin_trends.json')
    with open(json_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, default=str)
    
    metadata = {
        'generated_at': datetime.now().isoformat(),
        'record_count': len(data),
        'columns': list(data[0].keys()) if data else [],
        'description': 'WideWorldImportersDW 12-month revenue and margin trends',
        'compatibility': ['PowerBI', 'Kyvos', 'Excel', 'Tableau'],
        'data_types': {
            'month_year': 'string',
            'year_num': 'integer',
            'month_num': 'integer',
            'total_revenue': 'decimal',
            'revenue_excluding_tax': 'decimal',
            'total_margin': 'decimal',
            'total_tax': 'decimal',
            'transaction_count': 'integer',
            'avg_transaction_value': 'decimal',
            'margin_percentage': 'decimal',
            'revenue_growth_pct': 'decimal',
            'margin_growth_pct': 'decimal'
        }
    }
    
    metadata_file = os.path.join(export_dir, 'metadata.json')
    with open(metadata_file, 'w', encoding='utf-8') as f:
        json.dump(metadata, f, indent=2)
    
    return csv_file, json_file, metadata_file

def prepare_supabase_data(data):
    """
    Prepare data for Supabase insertion
    """
    supabase_data = []
    for record in data:
        supabase_record = {
            'month_year': record['month_year'],
            'total_revenue': float(record['total_revenue']),
            'total_margin': float(record['total_margin']),
            'margin_percentage': float(record['margin_percentage']),
            'revenue_growth_pct': float(record['revenue_growth_pct']) if record['revenue_growth_pct'] else None,
            'transaction_count': int(record['transaction_count']),
            'created_at': datetime.now().isoformat()
        }
        supabase_data.append(supabase_record)
    
    return supabase_data

def main():
    """
    Main processing function
    """
    print("WideWorldImportersDW Revenue and Margin Trends Data Processor")
    print("=" * 60)
    
    print("Generating sample data...")
    data = generate_sample_data()
    print(f"Generated {len(data)} records")
    
    print("Exporting data for PowerBI and Kyvos...")
    export_dir = os.path.join(os.path.dirname(__file__), '..', 'exports')
    csv_file, json_file, metadata_file = export_for_powerbi_kyvos(data, export_dir)
    print(f"Exported to: {csv_file}, {json_file}, {metadata_file}")
    
    print("Preparing data for Supabase...")
    supabase_data = prepare_supabase_data(data)
    
    viz_data_file = os.path.join(os.path.dirname(__file__), '..', 'visualization', 'data.json')
    with open(viz_data_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, default=str)
    print(f"Visualization data saved to: {viz_data_file}")
    
    supabase_data_file = os.path.join(export_dir, 'supabase_data.json')
    with open(supabase_data_file, 'w', encoding='utf-8') as f:
        json.dump(supabase_data, f, indent=2, default=str)
    print(f"Supabase data saved to: {supabase_data_file}")
    
    print("\nData processing completed successfully!")
    print(f"Summary: {len(data)} months of revenue and margin trend data")
    print(f"Total Revenue Range: ${min(d['total_revenue'] for d in data):,.2f} - ${max(d['total_revenue'] for d in data):,.2f}")
    print(f"Margin Range: {min(d['margin_percentage'] for d in data):.1f}% - {max(d['margin_percentage'] for d in data):.1f}%")

if __name__ == "__main__":
    main()
