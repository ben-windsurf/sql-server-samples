# WideWorldImporters Data Generation

This directory contains scripts to generate 24 months of realistic WideWorldImporters revenue and margin data based on the patterns from the original `DataLoadSimulation.DailyProcessToCreateHistory` stored procedure.

## Files

- `generate_sample_data.py` - Main data generation script
- `upload_to_supabase.py` - Prepares data for Supabase upload
- `README.md` - This documentation

## Data Generation Features

The data generator implements sophisticated patterns from the WideWorldImporters stored procedures:

### Seasonal Variations
- **Q1/Q3**: Typically lower sales (seasonal variation < 1.0)
- **Q2/Q4**: Typically higher sales (seasonal variation > 1.0)
- **Bell curve calculations**: Smooth transitions within seasons using sine wave functions

### Yearly Growth
- **Configurable growth rates**: 3-15% annual growth
- **Gradual application**: Growth applied progressively throughout the year
- **Year-over-year baseline updates**: Base order counts updated at year boundaries

### Daily Variations
- **Random fluctuations**: ±20% daily variation for realistic business patterns
- **Weekend adjustments**: 40% Saturday, 20% Sunday of normal weekday volume
- **Weekday patterns**: Monday-Friday full volume

### Business Data
- **Customer Segments**: 8 realistic segments (Corporate, Retail, Wholesale, etc.)
- **Product Categories**: Multiple brands and colors with varying profitability
- **Margin Profiles**: Different profit margins by customer segment and brand
- **Financial Calculations**: Realistic tax rates, quantity variations, and pricing

## Usage

### 1. Generate Data

```bash
cd data-generation
python generate_sample_data.py
```

This creates:
- `wideworldimporters_24months_data.json` - Main dataset (24 months of orders)
- `data_summary_stats.json` - Summary statistics and breakdowns

### 2. Prepare for Supabase Upload

```bash
python upload_to_supabase.py
```

This creates:
- `supabase_insert_data.sql` - SQL INSERT statements for manual upload

### 3. Expected Output

The generator produces approximately:
- **40,000-50,000 orders** over 24 months
- **Realistic seasonal patterns** with Q4 peaks and Q1 valleys
- **8 customer segments** with different margin profiles
- **84 product combinations** (7 brands × 12 colors)
- **Revenue range**: $2-5 million total over 24 months
- **Profit margins**: 12-30% depending on segment and product

## Data Schema

Each generated order record contains:

```json
{
  "order_id": "uuid",
  "invoice_date": "YYYY-MM-DD",
  "customer_segment": "Corporate|Retail|Wholesale|...",
  "product_brand": "Northwind|Wide World Importers|...",
  "product_color": "Red|Blue|Green|...",
  "quantity": 1-20,
  "total_excluding_tax": 10.00-10000.00,
  "total_including_tax": 11.00-11000.00,
  "profit": 1.20-3000.00,
  "year": 2023-2024,
  "month": 1-12,
  "quarter": 1-4,
  "weekday": 1-7
}
```

## Integration with Dashboard

The generated data is designed to work seamlessly with the existing Flask dashboard:

- **Monthly trends**: Aggregated by year/month for trend analysis
- **Customer segments**: Grouped by customer_segment for performance comparison
- **Product categories**: Analyzed by product_brand and product_color
- **Rolling metrics**: Date-based calculations for 12-month rolling averages
- **KPI summaries**: Total revenue, profit, and margin calculations

## Customization

You can modify the generation parameters in `generate_sample_data.py`:

```python
# Base parameters
self.average_orders_per_day = 60        # Daily order volume
self.min_yearly_growth = 3              # Minimum annual growth %
self.max_yearly_growth = 15             # Maximum annual growth %
self.min_seasonal_variation = -10       # Seasonal variation range
self.max_seasonal_variation = 30
self.max_daily_variation = 20           # Daily fluctuation %

# Weekend adjustments
self.saturday_percentage = 40           # % of weekday volume
self.sunday_percentage = 20             # % of weekday volume
```

## Performance Notes

- **Generation time**: ~30-60 seconds for 24 months of data
- **Memory usage**: ~50-100 MB for full dataset
- **File sizes**: 
  - JSON: ~15-25 MB
  - SQL: ~20-35 MB
- **Supabase upload**: Batched in 1000-record chunks for optimal performance
