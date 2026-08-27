select customer_id
	 , max(sale_date) as last_order_date
	 , current_date - max(sale_date) as days_since_last_order
	 , (max(sale_date) - min(sale_date)) / (count(*) - 1) as avg_days_between_orders
from fact_sales as t
group by customer_id
having count(*) > 1
order by days_since_last_order desc;
