--создание таблицы с 'грязными' данными
CREATE TABLE IF NOT EXISTS raw_staging_sales (
    sale_id INTEGER,
    customer_id INTEGER,
    product_id INTEGER,
    sale_date TIMESTAMP,
    quantity INTEGER,
    revenue DECIMAL(10,2),
    status VARCHAR(20),
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO raw_staging_sales (sale_id, customer_id, product_id, sale_date, quantity, revenue, status, load_timestamp) VALUES
(1, 1, 1, '2025-01-20 10:30:00', 1, 75000.00, 'Completed', CURRENT_TIMESTAMP),
(2, 2, 2, '2025-02-25 14:15:00', 2, 5000.00, 'Completed', CURRENT_TIMESTAMP),
(1, 1, 1, '2025-01-20 10:30:00', 1, 75000.00, 'Completed', '2026-01-01 00:00:00'),
(100, 4, 5, '2026-01-15 10:00:00', 10, 999999.00, 'Completed', CURRENT_TIMESTAMP),
(101, 2, 3, '2026-01-16 12:00:00', 1, -5000.00, 'Completed', CURRENT_TIMESTAMP),
(2, 2, 2, '2025-02-25 14:15:00', 2, 5000.00, 'Completed', '2026-01-02 00:00:00'),
(200, 1, 1, '2026-01-20 10:30:00', 1, 85000.00, 'Completed', CURRENT_TIMESTAMP),
(201, 2, 4, '2026-01-21 11:00:00', 1, 9000.00, 'Completed', CURRENT_TIMESTAMP),
(202, 3, 5, '2026-01-22 09:15:00', 1, 65000.00, 'Completed', CURRENT_TIMESTAMP),
(203, 4, 2, '2026-01-23 14:30:00', 2, 3000.00, 'Completed', CURRENT_TIMESTAMP),
(204, 5, 1, '2026-01-24 16:45:00', 1, 70000.00, 'Completed', CURRENT_TIMESTAMP),
(205, 1, 4, '2026-01-25 12:00:00', 1, 8500.00, 'Completed', CURRENT_TIMESTAMP),
(206, 2, 5, '2026-01-26 08:30:00', 1, 55000.00, 'Completed', CURRENT_TIMESTAMP),
(207, 3, 2, '2026-01-27 10:00:00', 3, 6000.00, 'Completed', CURRENT_TIMESTAMP),
(208, 4, 1, '2026-01-28 13:20:00', 1, 78000.00, 'Completed', CURRENT_TIMESTAMP),
(209, 5, 4, '2026-01-29 15:10:00', 1, 8200.00, 'Completed', CURRENT_TIMESTAMP),
(210, 1, 5, '2026-01-30 11:30:00', 2, 110000.00, 'Completed', CURRENT_TIMESTAMP);

--журнал для записей с аномалиями
CREATE TABLE IF NOT EXISTS fraud_alerts (
    alert_id SERIAL PRIMARY KEY,
    sale_id INTEGER,
    customer_id INTEGER,
    product_id INTEGER,
    sale_date TIMESTAMP,
    revenue DECIMAL(10,2),
    anomaly_type VARCHAR(50),
    detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

with 
--cte для дедупликации
deduped as (
	select *
		 , row_number() over (partition by sale_id order by load_timestamp desc) as rn
    from raw_staging_sales
),
--определение avg и stddev отдельно для каждой категории товаров
category_stats as (
	select dp.category
		 , avg(d.revenue) as avg_revenue
		 , stddev(d.revenue) as stddev_revenue
	from deduped d
	join dim_products dp
	on d.product_id  = dp.product_id 
	where d.rn = 1 
		and d.revenue >= 0
	group by dp.category 
),
--помечаем аномалии
clean_sales as (
	select d.sale_id
		 , d.customer_id
		 , d.product_id
		 , d.sale_date
		 , d.quantity
		 , d.revenue
		 , d.status
		 , cs.avg_revenue
		 , cs.stddev_revenue
		 , case
		 		when d.revenue < 0 then true 
		 		when cs.avg_revenue is null then true
		 		when d.revenue > cs.avg_revenue + 3 * cs.stddev_revenue then true
		 		when d.revenue < cs.avg_revenue - 3 * cs.stddev_revenue then true
		 		else false
		   end as is_anomaly
	from deduped d
	left join dim_products dp on d.product_id = dp.product_id
	left join category_stats cs on dp.category = cs.category 
	where d.rn = 1
),
--вставляем в журнал аномалий записи
insert_fraud as (
	insert into fraud_alerts (sale_id, customer_id, product_id, sale_date, revenue, anomaly_type)
	select sale_id
		 , customer_id
		 , product_id
		 , sale_date
		 , revenue
		 , case
		 		when revenue < 0 then 'negative revenue'
		 		when avg_revenue is null then 'missing product'
		 		when revenue > avg_revenue + 3 * stddev_revenue then 'high_outlier'
		 		when revenue < avg_revenue - 3 * stddev_revenue then 'low_outlier'
	   		end as anomaly_type
	from clean_sales cs
	where is_anomaly = true
)
--вставляем чистые данные в основную таблицу
insert into fact_sales (sale_id, customer_id, product_id, sale_date, quantity, revenue, status)
select sale_id
	 , customer_id
	 , product_id
	 , sale_date
	 , quantity
	 , revenue
	 , status
from clean_sales cs
where is_anomaly = false
on conflict (sale_id)
do update set
	customer_id = excluded.customer_id,
	product_id = excluded.product_id,
	sale_date = excluded.sale_date,
	quantity = excluded.quantity,
	revenue = excluded.revenue,
	status = excluded.status;
