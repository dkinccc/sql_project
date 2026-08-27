CREATE INDEX IF NOT EXISTS idx_fact_sales_customer ON fact_sales(customer_id);
CREATE INDEX IF NOT EXISTS idx_fact_sales_date ON fact_sales(sale_date);
CREATE INDEX IF NOT EXISTS idx_fact_sales_product ON fact_sales(product_id);
