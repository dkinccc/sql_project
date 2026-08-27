with revenue as (
	select dc.customer_id as customer_id
	 	, dc.full_name as full_name
	 	, count(fs.sale_id) as total_orders
	 	, coalesce(sum(fs.revenue), 0) as total_revenue
	from dim_customers dc 
	left join fact_sales fs
	on dc.customer_id  = fs.customer_id 
	group by dc.customer_id 
)

select customer_id
	 , full_name
	 , total_orders
	 , total_revenue
	 , dense_rank() over (order by total_revenue desc) as revenue_rank
	 , round(
	   		(total_revenue / (select sum(total_revenue) from revenue) * 100), 2
	   ) as revenue_share_percent
from revenue
order by total_revenue desc;
