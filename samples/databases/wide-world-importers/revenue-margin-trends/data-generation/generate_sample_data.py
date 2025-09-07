#!/usr/bin/env python3
"""
Generate 24 months of realistic WideWorldImporters revenue and margin data
Based on the patterns from DataLoadSimulation.DailyProcessToCreateHistory stored procedure
"""

import json
import random
import math
from datetime import datetime, timedelta, date
from typing import List, Dict, Any
import uuid

class WideWorldImportersDataGenerator:
    def __init__(self, start_date: str = "2023-01-01", end_date: str = "2024-12-31"):
        self.start_date = datetime.strptime(start_date, "%Y-%m-%d").date()
        self.end_date = datetime.strptime(end_date, "%Y-%m-%d").date()
        
        self.average_orders_per_day = 60  # Increased from 30 for more realistic volume
        self.saturday_percentage = 40
        self.sunday_percentage = 20
        self.min_yearly_growth = 3
        self.max_yearly_growth = 15
        self.min_seasonal_variation = -10
        self.max_seasonal_variation = 30
        self.max_daily_variation = 20
        
        self.customer_segments = [
            "Novelty Shop", "Supermarket", "Computer Store", "Gift Store", 
            "Corporate", "Retail", "Wholesale", "Restaurant"
        ]
        
        self.product_brands = [
            "Northwind", "Wide World Importers", "Fabrikam", "Contoso",
            "Adventure Works", "Tailspin Toys", "Fourth Coffee"
        ]
        
        self.product_colors = [
            "Red", "Blue", "Green", "Yellow", "Black", "White", "Purple", 
            "Orange", "Pink", "Gray", "Brown", "Silver"
        ]
        
        self.seasonal_variations = self._generate_seasonal_variations()
        
    def _generate_seasonal_variations(self) -> Dict[int, Dict[int, Dict[str, float]]]:
        """Generate seasonal variations for each year and season"""
        variations = {}
        
        for year in range(self.start_date.year, self.end_date.year + 1):
            variations[year] = {}
            yearly_variation = 1 + (self.min_yearly_growth + 
                                  random.random() * (self.max_yearly_growth - self.min_yearly_growth)) / 100
            
            for season in range(1, 5):  # Q1, Q2, Q3, Q4
                seasonal_var = 1 + (self.min_seasonal_variation + 
                                  random.random() * (self.max_seasonal_variation - self.min_seasonal_variation)) / 100
                
                if season % 2 == 1:
                    seasonal_var = 1 / seasonal_var
                    
                variations[year][season] = {
                    'yearly_variation': yearly_variation,
                    'seasonal_variation': seasonal_var
                }
                
        return variations
    
    def _get_season(self, current_date: date) -> int:
        """Get season (1-4) for a given date"""
        return math.ceil(current_date.month / 3)
    
    def _calculate_seasonal_effect(self, current_date: date, seasonal_variation: float) -> float:
        """Calculate seasonal bell curve effect"""
        year = current_date.year
        season = self._get_season(current_date)
        
        season_start = date(year, (season * 3) - 2, 1)
        days_in_season = 90
        x = min(1.0, (current_date - season_start).days / days_in_season)
        
        season_effect = (math.sin(2 * math.pi * (x - 0.25)) + 1) / 2
        return ((seasonal_variation - 1) * season_effect) + 1
    
    def _calculate_daily_orders(self, current_date: date, base_orders: int) -> int:
        """Calculate number of orders for a specific date"""
        year = current_date.year
        season = self._get_season(current_date)
        weekday = current_date.weekday()  # 0=Monday, 6=Sunday
        
        variations = self.seasonal_variations[year][season]
        yearly_variation = variations['yearly_variation']
        seasonal_variation = variations['seasonal_variation']
        
        season_effect = self._calculate_seasonal_effect(current_date, seasonal_variation)
        
        days_from_year_start = (current_date - date(year, 1, 1)).days
        yearly_effect = 1 + ((yearly_variation - 1) * (days_from_year_start / 365))
        
        daily_effect = random.random()
        if daily_effect < 0.5:
            daily_effect = -daily_effect
        daily_effect = 1 + daily_effect * (self.max_daily_variation / 100)
        
        weekend_multiplier = 1.0
        if weekday == 5:  # Saturday
            weekend_multiplier = self.saturday_percentage / 100
        elif weekday == 6:  # Sunday
            weekend_multiplier = self.sunday_percentage / 100
            
        orders = int(base_orders * daily_effect * season_effect * yearly_effect * weekend_multiplier)
        return max(1, orders)  # Ensure at least 1 order per day
    
    def _generate_order_data(self, current_date: date, num_orders: int) -> List[Dict[str, Any]]:
        """Generate individual order records for a date"""
        orders = []
        
        for _ in range(num_orders):
            customer_segment = random.choice(self.customer_segments)
            
            brand = random.choice(self.product_brands)
            color = random.choice(self.product_colors)
            
            base_price = random.uniform(10, 500)  # Base item price
            quantity = random.randint(1, 20)
            
            total_excluding_tax = base_price * quantity
            tax_rate = 0.1  # 10% tax
            total_including_tax = total_excluding_tax * (1 + tax_rate)
            
            margin_rate = self._get_margin_rate(customer_segment, brand)
            profit = total_excluding_tax * margin_rate
            
            order = {
                'order_id': str(uuid.uuid4()),
                'invoice_date': current_date.isoformat(),
                'customer_segment': customer_segment,
                'product_brand': brand,
                'product_color': color,
                'quantity': quantity,
                'total_excluding_tax': round(total_excluding_tax, 2),
                'total_including_tax': round(total_including_tax, 2),
                'profit': round(profit, 2),
                'year': current_date.year,
                'month': current_date.month,
                'quarter': self._get_season(current_date),
                'weekday': current_date.weekday() + 1  # 1=Monday, 7=Sunday
            }
            
            orders.append(order)
            
        return orders
    
    def _get_margin_rate(self, customer_segment: str, brand: str) -> float:
        """Get realistic margin rate based on customer segment and brand"""
        base_margins = {
            "Corporate": 0.15,
            "Wholesale": 0.12,
            "Supermarket": 0.18,
            "Retail": 0.25,
            "Novelty Shop": 0.30,
            "Computer Store": 0.22,
            "Gift Store": 0.28,
            "Restaurant": 0.20
        }
        
        brand_multipliers = {
            "Wide World Importers": 1.2,
            "Northwind": 1.1,
            "Fabrikam": 1.0,
            "Contoso": 0.9,
            "Adventure Works": 1.15,
            "Tailspin Toys": 1.25,
            "Fourth Coffee": 1.05
        }
        
        base_margin = base_margins.get(customer_segment, 0.20)
        brand_multiplier = brand_multipliers.get(brand, 1.0)
        
        variation = random.uniform(0.8, 1.2)
        
        return base_margin * brand_multiplier * variation
    
    def generate_data(self) -> List[Dict[str, Any]]:
        """Generate complete dataset for the date range"""
        all_orders = []
        current_date = self.start_date
        base_orders = self.average_orders_per_day
        
        print(f"Generating data from {self.start_date} to {self.end_date}")
        
        while current_date <= self.end_date:
            daily_orders = self._calculate_daily_orders(current_date, base_orders)
            
            orders = self._generate_order_data(current_date, daily_orders)
            all_orders.extend(orders)
            
            if current_date.day == 1:
                print(f"Generated data for {current_date.strftime('%Y-%m')}: {daily_orders} orders")
            
            current_date += timedelta(days=1)
            
            if current_date.day == 1 and current_date.month == 1:
                year = current_date.year - 1
                if year in self.seasonal_variations:
                    yearly_growth = self.seasonal_variations[year][1]['yearly_variation']
                    base_orders = int(base_orders * yearly_growth)
                    print(f"Updated base orders for {current_date.year}: {base_orders}")
        
        print(f"Generated {len(all_orders)} total orders")
        return all_orders
    
    def save_to_json(self, data: List[Dict[str, Any]], filename: str):
        """Save generated data to JSON file"""
        with open(filename, 'w') as f:
            json.dump(data, f, indent=2, default=str)
        print(f"Data saved to {filename}")
    
    def get_summary_stats(self, data: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Generate summary statistics for the dataset"""
        if not data:
            return {}
        
        total_revenue = sum(order['total_excluding_tax'] for order in data)
        total_profit = sum(order['profit'] for order in data)
        total_orders = len(data)
        
        monthly_stats = {}
        for order in data:
            month_key = f"{order['year']}-{order['month']:02d}"
            if month_key not in monthly_stats:
                monthly_stats[month_key] = {
                    'revenue': 0, 'profit': 0, 'orders': 0
                }
            monthly_stats[month_key]['revenue'] += order['total_excluding_tax']
            monthly_stats[month_key]['profit'] += order['profit']
            monthly_stats[month_key]['orders'] += 1
        
        segment_stats = {}
        for order in data:
            segment = order['customer_segment']
            if segment not in segment_stats:
                segment_stats[segment] = {'revenue': 0, 'profit': 0, 'orders': 0}
            segment_stats[segment]['revenue'] += order['total_excluding_tax']
            segment_stats[segment]['profit'] += order['profit']
            segment_stats[segment]['orders'] += 1
        
        return {
            'total_revenue': round(total_revenue, 2),
            'total_profit': round(total_profit, 2),
            'total_orders': total_orders,
            'average_margin': round((total_profit / total_revenue) * 100, 2) if total_revenue > 0 else 0,
            'monthly_breakdown': monthly_stats,
            'customer_segments': segment_stats,
            'date_range': {
                'start': self.start_date.isoformat(),
                'end': self.end_date.isoformat()
            }
        }

def main():
    """Main function to generate and save data"""
    print("WideWorldImporters Data Generator")
    print("=" * 40)
    
    generator = WideWorldImportersDataGenerator("2023-01-01", "2024-12-31")
    
    data = generator.generate_data()
    
    output_file = "wideworldimporters_24months_data.json"
    generator.save_to_json(data, output_file)
    
    stats = generator.get_summary_stats(data)
    stats_file = "data_summary_stats.json"
    with open(stats_file, 'w') as f:
        json.dump(stats, f, indent=2, default=str)
    
    print(f"\nSummary Statistics:")
    print(f"Total Revenue: ${stats['total_revenue']:,.2f}")
    print(f"Total Profit: ${stats['total_profit']:,.2f}")
    print(f"Total Orders: {stats['total_orders']:,}")
    print(f"Average Margin: {stats['average_margin']:.2f}%")
    print(f"Monthly Data Points: {len(stats['monthly_breakdown'])}")
    print(f"Customer Segments: {len(stats['customer_segments'])}")
    
    print(f"\nFiles generated:")
    print(f"- {output_file} (main dataset)")
    print(f"- {stats_file} (summary statistics)")

if __name__ == "__main__":
    main()
