select count(*) as negative_revenue
from fact_sales fs
where fs.revenue < 0;

select count(*) as missing_products
from fact_sales fs
left join dim_products dp 
on fs.product_id = dp.product_id 
where dp.product_id is null;

select count(*) as missing_customers
from fact_sales fs
left join dim_customers dc 
on fs.customer_id = dc.customer_id 
where dc.customer_id is null;
