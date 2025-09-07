#!/usr/bin/env python3
"""
Generate Margin Analysis Visualizations for WideWorldImportersDW
This script creates detailed margin analysis charts and profitability insights.
"""

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import pyodbc
import numpy as np
from datetime import datetime, timedelta
import warnings
warnings.filterwarnings('ignore')

plt.style.use('seaborn-v0_8')
sns.set_palette("husl")

SERVER = 'localhost'
DATABASE = 'WideWorldImportersDW'
USERNAME = ''
PASSWORD = ''

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

def get_sample_margin_data():
    """Generate sample margin data by product category"""
    categories = ['Electronics', 'Clothing', 'Home & Garden', 'Sports', 'Books', 'Toys']
    months = pd.date_range(start='2023-01-01', end='2023-12-31', freq='M')
    
    np.random.seed(42)
    data = []
    
    for category in categories:
        base_margin = np.random.uniform(10, 25)  # Base margin between 10-25%
        
        for i, month in enumerate(months):
            seasonal_factor = 1 + 0.3 * np.sin(2 * np.pi * i / 12)
            noise = np.random.normal(0, 2)
            
            margin = base_margin * seasonal_factor + noise
            revenue = np.random.uniform(50000, 200000) * seasonal_factor
            profit = revenue * (margin / 100)
            
            data.append({
                'Category': category,
                'Year': month.year,
                'Month': month.month,
                'Month_Label': month.strftime('%b'),
                'Month_Year': month.strftime('%Y-%m'),
                'Revenue': revenue,
                'Profit': profit,
                'Margin_Percentage': margin,
                'Units_Sold': int(np.random.uniform(100, 1000))
            })
    
    return pd.DataFrame(data)

def fetch_margin_by_category(conn):
    """Fetch margin data by product category from database"""
    query = """
    SELECT 
        si.[Color] as Category,  -- Using Color as proxy for category
        d.[Calendar Year] as [Year],
        d.[Calendar Month Number] as [Month],
        d.[Calendar Month Label] as [Month_Label],
        CONCAT(d.[Calendar Year], '-', FORMAT(d.[Calendar Month Number], '00')) as [Month_Year],
        SUM(s.[Total Including Tax]) as [Revenue],
        SUM(s.[Profit]) as [Profit],
        CASE 
            WHEN SUM(s.[Total Excluding Tax]) > 0 
            THEN (SUM(s.[Profit]) / SUM(s.[Total Excluding Tax])) * 100 
            ELSE 0 
        END as [Margin_Percentage],
        SUM(s.[Quantity]) as [Units_Sold]
    FROM [Fact].[Sale] s
    INNER JOIN [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
    INNER JOIN [Dimension].[Stock Item] si ON s.[Stock Item Key] = si.[Stock Item Key]
    WHERE d.[Date] >= DATEADD(MONTH, -12, GETDATE())
        AND d.[Date] < DATEADD(MONTH, 0, GETDATE())
        AND si.[Color] IS NOT NULL
        AND si.[Color] != 'N/A'
    GROUP BY 
        si.[Color],
        d.[Calendar Year], 
        d.[Calendar Month Number], 
        d.[Calendar Month Label]
    ORDER BY [Category], [Year], [Month]
    """
    
    try:
        return pd.read_sql(query, conn)
    except Exception as e:
        print(f"Error fetching category data: {e}")
        return get_sample_margin_data()

def create_margin_heatmap(df, output_path='margin_heatmap.png'):
    """Create margin percentage heatmap by category and month"""
    plt.figure(figsize=(14, 8))
    
    pivot_data = df.pivot_table(values='Margin_Percentage', 
                               index='Category', 
                               columns='Month_Label', 
                               aggfunc='mean')
    
    sns.heatmap(pivot_data, annot=True, fmt='.1f', cmap='RdYlGn', 
                center=pivot_data.mean().mean(), cbar_kws={'label': 'Margin %'})
    
    plt.title('Margin Percentage Heatmap by Category and Month', 
              fontsize=16, fontweight='bold', pad=20)
    plt.xlabel('Month', fontsize=12)
    plt.ylabel('Product Category', fontsize=12)
    plt.tight_layout()
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.show()
    print(f"Margin heatmap saved as {output_path}")

def create_profitability_analysis(df, output_path='profitability_analysis.png'):
    """Create comprehensive profitability analysis dashboard"""
    fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(16, 12))
    
    categories = df['Category'].unique()[:6]  # Top 6 categories
    category_margins = [df[df['Category'] == cat]['Margin_Percentage'].values for cat in categories]
    
    bp = ax1.boxplot(category_margins, labels=categories, patch_artist=True)
    colors = plt.cm.Set3(np.linspace(0, 1, len(categories)))
    for patch, color in zip(bp['boxes'], colors):
        patch.set_facecolor(color)
    
    ax1.set_title('Margin Distribution by Category', fontsize=14, fontweight='bold')
    ax1.set_ylabel('Margin Percentage (%)')
    ax1.tick_params(axis='x', rotation=45)
    ax1.grid(True, alpha=0.3)
    
    for i, category in enumerate(categories):
        cat_data = df[df['Category'] == category]
        ax2.scatter(cat_data['Revenue'], cat_data['Profit'], 
                   alpha=0.7, s=60, label=category, color=colors[i])
    
    ax2.set_title('Revenue vs Profit by Category', fontsize=14, fontweight='bold')
    ax2.set_xlabel('Revenue ($)')
    ax2.set_ylabel('Profit ($)')
    ax2.legend(bbox_to_anchor=(1.05, 1), loc='upper left')
    ax2.grid(True, alpha=0.3)
    
    top_categories = df.groupby('Category')['Revenue'].sum().nlargest(4).index
    
    for category in top_categories:
        cat_data = df[df['Category'] == category].groupby('Month_Label')['Margin_Percentage'].mean()
        ax3.plot(cat_data.index, cat_data.values, marker='o', linewidth=2, label=category)
    
    ax3.set_title('Monthly Margin Trends - Top Categories', fontsize=14, fontweight='bold')
    ax3.set_xlabel('Month')
    ax3.set_ylabel('Average Margin %')
    ax3.legend()
    ax3.grid(True, alpha=0.3)
    ax3.tick_params(axis='x', rotation=45)
    
    category_profit = df.groupby('Category')['Profit'].sum().nlargest(8)
    colors_pie = plt.cm.Set3(np.linspace(0, 1, len(category_profit)))
    
    wedges, texts, autotexts = ax4.pie(category_profit.values, labels=category_profit.index, 
                                      autopct='%1.1f%%', colors=colors_pie, startangle=90)
    ax4.set_title('Profit Contribution by Category', fontsize=14, fontweight='bold')
    
    for autotext in autotexts:
        autotext.set_color('white')
        autotext.set_fontweight('bold')
    
    plt.suptitle('WideWorldImportersDW - Profitability Analysis Dashboard', 
                 fontsize=18, fontweight='bold', y=0.98)
    plt.tight_layout()
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.show()
    print(f"Profitability analysis saved as {output_path}")

def main():
    """Main execution function"""
    print("WideWorldImportersDW Margin Analysis")
    print("=" * 40)
    
    conn = get_connection()
    
    print("Fetching margin data by category...")
    df = fetch_margin_by_category(conn)
    
    if conn:
        conn.close()
    
    print(f"Loaded {len(df)} records across {df['Category'].nunique()} categories")
    
    print("Creating margin heatmap...")
    create_margin_heatmap(df)
    
    print("Creating profitability analysis...")
    create_profitability_analysis(df)
    
    print("\nMargin analysis completed!")
    print("Files created:")
    print("- margin_heatmap.png")
    print("- profitability_analysis.png")

if __name__ == "__main__":
    main()
