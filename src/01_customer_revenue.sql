select dc.customer_id
	 , dc.full_name
	 , count(fs.sale_id) as total_orders
	 , sum(fs.revenue) as total_revenue
from dim_customers dc 
left join fact_sales fs
on dc.customer_id  = fs.customer_id 
group by dc.customer_id 
order by total_revenue desc;
