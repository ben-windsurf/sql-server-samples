#!/usr/bin/env python3
"""
Generate Revenue Trend Visualizations for WideWorldImportersDW
This script creates sample revenue and margin trend charts using matplotlib and seaborn.
"""

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import pyodbc
from datetime import datetime, timedelta
import numpy as np
import warnings
warnings.filterwarnings('ignore')

SERVER = 'localhost'  # or your SQL Server instance
DATABASE = 'WideWorldImportersDW'
USERNAME = ''  # Leave empty for Windows Authentication
PASSWORD = ''  # Leave empty for Windows Authentication

def get_connection():
    """Create database connection"""
    if USERNAME and PASSWORD:
        conn_str = f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={SERVER};DATABASE={DATABASE};UID={USERNAME};PWD={PASSWORD}'
    else:
        conn_str = f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={SERVER};DATABASE={DATABASE};Trusted_Connection=yes'
    
    try:
        return pyodbc.connect(conn_str)
    except Exception as e:
        print(f"Error connecting to database: {e}")
        print("Using sample data instead...")
        return None

def get_sample_data():
    """Generate sample data if database connection fails"""
    dates = pd.date_range(start='2023-01-01', end='2023-12-31', freq='M')
    np.random.seed(42)
    
    data = []
    base_revenue = 1000000
    base_margin = 15.0
    
    for i, date in enumerate(dates):
        seasonal_factor = 1 + 0.2 * np.sin(2 * np.pi * i / 12)
        trend_factor = 1 + 0.05 * i / 12
        noise = np.random.normal(0, 0.1)
        
        revenue = base_revenue * seasonal_factor * trend_factor * (1 + noise)
        margin = base_margin + 2 * np.sin(2 * np.pi * i / 12) + np.random.normal(0, 1)
        profit = revenue * (margin / 100)
        
        data.append({
            'Year': date.year,
            'Month': date.month,
            'Month_Label': date.strftime('%b'),
            'Month_Year_Label': date.strftime('%b-%Y'),
            'Revenue_Including_Tax': revenue,
            'Revenue_Excluding_Tax': revenue * 0.9,
            'Total_Profit': profit,
            'Margin_Percentage': margin,
            'Transaction_Count': int(1000 + 200 * seasonal_factor + np.random.normal(0, 50))
        })
    
    return pd.DataFrame(data)

def fetch_revenue_data(conn):
    """Fetch revenue data from database"""
    query = """
    SELECT 
        d.[Calendar Year] as [Year],
        d.[Calendar Month Number] as [Month],
        d.[Calendar Month Label] as [Month_Label],
        d.[Calendar Month Year Label] as [Month_Year_Label],
        SUM(s.[Total Including Tax]) as [Revenue_Including_Tax],
        SUM(s.[Total Excluding Tax]) as [Revenue_Excluding_Tax],
        SUM(s.[Profit]) as [Total_Profit],
        CASE 
            WHEN SUM(s.[Total Excluding Tax]) > 0 
            THEN (SUM(s.[Profit]) / SUM(s.[Total Excluding Tax])) * 100 
            ELSE 0 
        END as [Margin_Percentage],
        COUNT(s.[Sale Key]) as [Transaction_Count]
    FROM [Fact].[Sale] s
    INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
    WHERE d.[Date] >= DATEADD(MONTH, -12, GETDATE())
        AND d.[Date] < DATEADD(MONTH, 0, GETDATE())
    GROUP BY 
        d.[Calendar Year], 
        d.[Calendar Month Number], 
        d.[Calendar Month Label],
        d.[Calendar Month Year Label]
    ORDER BY [Year], [Month]
    """
    
    try:
        return pd.read_sql(query, conn)
    except Exception as e:
        print(f"Error fetching data: {e}")
        return get_sample_data()

def create_revenue_trend_chart(df, output_path='revenue_trends.png'):
    """Create revenue trend line chart"""
    plt.figure(figsize=(14, 8))
    
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(14, 10))
    
    ax1.plot(df['Month_Year_Label'], df['Revenue_Including_Tax'], 
             marker='o', linewidth=2, markersize=6, color='#2E86AB', label='Revenue Including Tax')
    ax1.plot(df['Month_Year_Label'], df['Revenue_Excluding_Tax'], 
             marker='s', linewidth=2, markersize=6, color='#A23B72', label='Revenue Excluding Tax')
    
    ax1.set_title('12-Month Revenue Trends - WideWorldImportersDW', fontsize=16, fontweight='bold', pad=20)
    ax1.set_xlabel('Month', fontsize=12)
    ax1.set_ylabel('Revenue ($)', fontsize=12)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.tick_params(axis='x', rotation=45)
    
    from matplotlib.ticker import FuncFormatter
    ax1.yaxis.set_major_formatter(FuncFormatter(lambda x, p: f'${x:,.0f}'))
    
    ax2.plot(df['Month_Year_Label'], df['Margin_Percentage'], 
             marker='D', linewidth=2, markersize=6, color='#F18F01', label='Margin %')
    
    ax2.set_title('12-Month Margin Percentage Trends', fontsize=16, fontweight='bold', pad=20)
    ax2.set_xlabel('Month', fontsize=12)
    ax2.set_ylabel('Margin Percentage (%)', fontsize=12)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.tick_params(axis='x', rotation=45)
    
    avg_margin = df['Margin_Percentage'].mean()
    ax2.axhline(y=avg_margin, color='red', linestyle='--', alpha=0.7, 
                label=f'Average: {avg_margin:.1f}%')
    ax2.legend(fontsize=10)
    
    plt.tight_layout()
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.show()
    print(f"Revenue trend chart saved as {output_path}")

def create_performance_dashboard(df, output_path='performance_dashboard.png'):
    """Create comprehensive performance dashboard"""
    fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(16, 12))
    
    ax1.bar(df['Month_Label'], df['Revenue_Including_Tax'], alpha=0.7, color='#2E86AB', label='Revenue')
    ax1_twin = ax1.twinx()
    ax1_twin.plot(df['Month_Label'], df['Total_Profit'], color='#F18F01', marker='o', 
                  linewidth=3, markersize=8, label='Profit')
    
    ax1.set_title('Monthly Revenue vs Profit', fontsize=14, fontweight='bold')
    ax1.set_ylabel('Revenue ($)', color='#2E86AB')
    ax1_twin.set_ylabel('Profit ($)', color='#F18F01')
    ax1.tick_params(axis='x', rotation=45)
    
    colors = ['#FF6B6B' if x < df['Margin_Percentage'].mean() else '#4ECDC4' 
              for x in df['Margin_Percentage']]
    ax2.bar(df['Month_Label'], df['Margin_Percentage'], color=colors, alpha=0.8)
    ax2.axhline(y=df['Margin_Percentage'].mean(), color='red', linestyle='--', alpha=0.7)
    ax2.set_title('Monthly Margin Percentage', fontsize=14, fontweight='bold')
    ax2.set_ylabel('Margin %')
    ax2.tick_params(axis='x', rotation=45)
    
    ax3.fill_between(df['Month_Label'], df['Transaction_Count'], alpha=0.6, color='#95E1D3')
    ax3.plot(df['Month_Label'], df['Transaction_Count'], color='#3D5A80', linewidth=2, marker='o')
    ax3.set_title('Monthly Transaction Volume', fontsize=14, fontweight='bold')
    ax3.set_ylabel('Transaction Count')
    ax3.tick_params(axis='x', rotation=45)
    
    revenue_growth = df['Revenue_Including_Tax'].pct_change() * 100
    colors = ['#FF6B6B' if x < 0 else '#4ECDC4' for x in revenue_growth[1:]]
    ax4.bar(df['Month_Label'][1:], revenue_growth[1:], color=colors, alpha=0.8)
    ax4.axhline(y=0, color='black', linestyle='-', alpha=0.5)
    ax4.set_title('Month-over-Month Revenue Growth', fontsize=14, fontweight='bold')
    ax4.set_ylabel('Growth Rate (%)')
    ax4.tick_params(axis='x', rotation=45)
    
    plt.suptitle('WideWorldImportersDW - 12-Month Performance Dashboard', 
                 fontsize=18, fontweight='bold', y=0.98)
    plt.tight_layout()
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.show()
    print(f"Performance dashboard saved as {output_path}")

def create_summary_stats(df):
    """Print summary statistics"""
    print("\n" + "="*60)
    print("WIDEWORLDIMPORTERSDW - 12-MONTH REVENUE & MARGIN SUMMARY")
    print("="*60)
    
    total_revenue = df['Revenue_Including_Tax'].sum()
    total_profit = df['Total_Profit'].sum()
    avg_margin = df['Margin_Percentage'].mean()
    total_transactions = df['Transaction_Count'].sum()
    
    print(f"Total Revenue (12 months):     ${total_revenue:,.2f}")
    print(f"Total Profit (12 months):      ${total_profit:,.2f}")
    print(f"Average Margin Percentage:     {avg_margin:.2f}%")
    print(f"Total Transactions:            {total_transactions:,}")
    print(f"Average Revenue per Month:     ${total_revenue/12:,.2f}")
    print(f"Average Transactions per Month: {total_transactions/12:,.0f}")
    
    best_revenue_month = df.loc[df['Revenue_Including_Tax'].idxmax()]
    worst_revenue_month = df.loc[df['Revenue_Including_Tax'].idxmin()]
    best_margin_month = df.loc[df['Margin_Percentage'].idxmax()]
    
    print(f"\nBest Revenue Month:            {best_revenue_month['Month_Year_Label']} (${best_revenue_month['Revenue_Including_Tax']:,.2f})")
    print(f"Worst Revenue Month:           {worst_revenue_month['Month_Year_Label']} (${worst_revenue_month['Revenue_Including_Tax']:,.2f})")
    print(f"Best Margin Month:             {best_margin_month['Month_Year_Label']} ({best_margin_month['Margin_Percentage']:.2f}%)")
    print("="*60)

def main():
    """Main execution function"""
    print("WideWorldImportersDW Revenue Trend Analysis")
    print("=" * 50)
    
    conn = get_connection()
    
    print("Fetching revenue data...")
    df = fetch_revenue_data(conn)
    
    if conn:
        conn.close()
    
    print(f"Loaded {len(df)} months of data")
    
    print("Creating revenue trend charts...")
    create_revenue_trend_chart(df)
    
    print("Creating performance dashboard...")
    create_performance_dashboard(df)
    
    create_summary_stats(df)
    
    print("\nVisualization generation completed!")
    print("Files created:")
    print("- revenue_trends.png")
    print("- performance_dashboard.png")

if __name__ == "__main__":
    main()
