with customer_stats as (
	select dc.customer_id
		 , dc.full_name
		 , dc.country
		 , dc.segment
		 , count(fs.sale_id) as total_orders
		 , coalesce(sum(fs.revenue), 0) as total_revenue
		 , coalesce(sum(fs.revenue), 0) / count(fs.sale_id) as avg_order_value
		 , max(fs.sale_date) as last_order_date
		 , current_date - max(fs.sale_date) as days_since_last_order
		 , case 
			 when count(sale_id) <= 1 then null
		 	 else (max(sale_date) - min(sale_date)) / (count(*) - 1) 
		   end as avg_days_between_orders
	from dim_customers dc
	left join fact_sales fs
	on dc.customer_id = fs.customer_id
	group by dc.customer_id
), 
rfm_score as (
	select *
		 , ntile(4) over(order by days_since_last_order desc) as recency_score
		 , ntile(4) over(order by total_orders asc) as frequency_score
		 , ntile(4) over(order by total_revenue asc) as monetary_score
	from customer_stats cs
)
select * from rfm_score;
