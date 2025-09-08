-- WIDE WORLD IMPORTERS DENORMALIZED TABLE

    CREATE TABLE IF NOT EXISTS "wide-world-importers" (
        -- Primary identifiers
        sale_key BIGINT PRIMARY KEY,
        wwi_invoice_id INTEGER NOT NULL,
        
        -- Date dimensions
        invoice_date DATE NOT NULL,
        delivery_date DATE,
        calendar_year INTEGER NOT NULL,
        calendar_month_number INTEGER NOT NULL,
        calendar_month_label VARCHAR(3) NOT NULL,
        calendar_month_year_label VARCHAR(8) NOT NULL,
        calendar_quarter_number INTEGER NOT NULL,
        calendar_quarter_label VARCHAR(2) NOT NULL,
        day_of_week VARCHAR(10) NOT NULL,
        day_of_week_number INTEGER NOT NULL,
        is_weekend BOOLEAN NOT NULL,
        fiscal_year INTEGER NOT NULL,
        fiscal_month_number INTEGER NOT NULL,
        
        -- Customer dimensions
        customer_key INTEGER NOT NULL,
        wwi_customer_id INTEGER NOT NULL,
        customer_name VARCHAR(100) NOT NULL,
        customer_category VARCHAR(50) NOT NULL,
        buying_group VARCHAR(50) NOT NULL,
        primary_contact VARCHAR(50) NOT NULL,
        customer_postal_code VARCHAR(10) NOT NULL,
        
        -- Product dimensions
        stock_item_key INTEGER NOT NULL,
        wwi_stock_item_id INTEGER NOT NULL,
        product_name VARCHAR(100) NOT NULL,
        product_color VARCHAR(20) NOT NULL,
        product_brand VARCHAR(50) NOT NULL,
        product_size VARCHAR(20) NOT NULL,
        selling_package VARCHAR(50) NOT NULL,
        buying_package VARCHAR(50) NOT NULL,
        is_chiller_stock BOOLEAN NOT NULL,
        product_barcode VARCHAR(50),
        
        -- Geography dimensions
        city_key INTEGER NOT NULL,
        wwi_city_id INTEGER NOT NULL,
        city_name VARCHAR(50) NOT NULL,
        state_province VARCHAR(50) NOT NULL,
        country VARCHAR(50) NOT NULL,
        continent VARCHAR(30) NOT NULL,
        sales_territory VARCHAR(50) NOT NULL,
        region VARCHAR(50) NOT NULL,
        subregion VARCHAR(50) NOT NULL,
        city_population INTEGER,
        
        -- Employee dimensions
        salesperson_key INTEGER NOT NULL,
        wwi_employee_id INTEGER NOT NULL,
        salesperson_name VARCHAR(50) NOT NULL,
        salesperson_preferred_name VARCHAR(50) NOT NULL,
        
        -- Transaction facts
        description VARCHAR(100) NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price DECIMAL(18,2) NOT NULL,
        tax_rate DECIMAL(18,3) NOT NULL,
        total_excluding_tax DECIMAL(18,2) NOT NULL,
        tax_amount DECIMAL(18,2) NOT NULL,
        profit DECIMAL(18,2) NOT NULL,
        total_including_tax DECIMAL(18,2) NOT NULL,
        margin_percentage DECIMAL(5,2) NOT NULL,
        total_dry_items INTEGER NOT NULL,
        total_chiller_items INTEGER NOT NULL,
        
        -- Metadata
        lineage_key INTEGER NOT NULL DEFAULT 1,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );
    
    -- Create indexes for common query patterns
    CREATE INDEX IF NOT EXISTS idx_wwi_invoice_date ON "wide-world-importers"(invoice_date);
    CREATE INDEX IF NOT EXISTS idx_wwi_customer ON "wide-world-importers"(customer_key);
    CREATE INDEX IF NOT EXISTS idx_wwi_product ON "wide-world-importers"(stock_item_key);
    CREATE INDEX IF NOT EXISTS idx_wwi_territory ON "wide-world-importers"(sales_territory);
    CREATE INDEX IF NOT EXISTS idx_wwi_month_year ON "wide-world-importers"(calendar_year, calendar_month_number);
    CREATE INDEX IF NOT EXISTS idx_wwi_margin ON "wide-world-importers"(margin_percentage);
    