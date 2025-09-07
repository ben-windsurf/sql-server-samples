#!/usr/bin/env python3
"""
Test script to verify Flask app imports and basic functionality
"""

import os
import sys

os.environ['SUPABASE_URL'] = 'https://placeholder.supabase.co'
os.environ['SUPABASE_ANON_KEY'] = 'placeholder-key'

try:
    from app import app
    print("✅ Flask app imports successfully")
    
    print("\n📍 Available routes:")
    for rule in app.url_map.iter_rules():
        print(f"  {rule.rule} -> {rule.endpoint}")
    
    print(f"\n🔧 Environment variables:")
    print(f"  SUPABASE_URL: {os.environ.get('SUPABASE_URL', 'Not set')}")
    print(f"  SUPABASE_ANON_KEY: {'Set' if os.environ.get('SUPABASE_ANON_KEY') else 'Not set'}")
    
    with app.app_context():
        print("✅ Flask app context created successfully")
    
    print("\n🎯 Flask app is ready for testing once Supabase is configured")
    
except ImportError as e:
    print(f"❌ Import error: {e}")
    print("Missing dependencies - check requirements.txt")
except Exception as e:
    print(f"❌ Error: {e}")
    print("App configuration issue")
