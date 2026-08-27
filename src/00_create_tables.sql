CREATE TABLE IF NOT EXISTS dim_customers (
    customer_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    country VARCHAR(50),
    registration_date DATE DEFAULT CURRENT_DATE,
    segment VARCHAR(20) CHECK (segment IN ('VIP', 'Standard', 'Trial'))
);

CREATE TABLE IF NOT EXISTS dim_products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category VARCHAR(50),
    subcategory VARCHAR(50),
    base_price DECIMAL(10,2) CHECK (base_price > 0)
);

CREATE TABLE IF NOT EXISTS fact_sales (
    sale_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    sale_date TIMESTAMP NOT NULL DEFAULT NOW(),
    quantity INTEGER CHECK (quantity > 0),
    revenue DECIMAL(10,2) CHECK (revenue >= 0),
    status VARCHAR(20) DEFAULT 'Completed',
    
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES dim_customers(customer_id),
    CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES dim_products(product_id)
);

INSERT INTO dim_customers (full_name, email, country, registration_date, segment) VALUES
('Анна Иванова', 'anna@mail.ru', 'Россия', '2025-01-15', 'VIP'),
('Петр Смирнов', 'petr@yandex.ru', 'Россия', '2025-02-20', 'Standard'),
('John Doe', 'john@gmail.com', 'USA', '2025-03-01', 'Standard'),
('Maria Garcia', 'maria@yahoo.com', 'Spain', '2025-04-10', 'VIP'),
('Elena Petrova', 'elena@bk.ru', 'Россия', '2026-01-01', 'Trial');

INSERT INTO dim_products (product_name, category, subcategory, base_price) VALUES
('Ноутбук X1', 'Электроника', 'Ноутбуки', 75000.00),
('Мышь Bluetooth', 'Электроника', 'Аксессуары', 2500.00),
('Кофеварка Pro', 'Бытовая техника', 'Кофемашины', 12000.00),
('Наушники Studio', 'Электроника', 'Аудио', 8500.00),
('Смартфон Z', 'Электроника', 'Телефоны', 55000.00),
('Чехол для смартфона', 'Электроника', 'Аксессуары', 1200.00);

INSERT INTO fact_sales (customer_id, product_id, sale_date, quantity, revenue, status) VALUES
(1, 1, '2025-01-20 10:30:00', 1, 75000.00, 'Completed'),
(2, 2, '2025-02-25 14:15:00', 2, 5000.00, 'Completed'),
(3, 3, '2025-03-05 09:00:00', 1, 12000.00, 'Completed'),
(1, 4, '2025-03-15 16:45:00', 1, 8500.00, 'Completed'),
(4, 5, '2025-04-12 11:20:00', 1, 55000.00, 'Completed'),
(2, 6, '2025-04-20 13:10:00', 3, 3600.00, 'Completed'),
(5, 2, '2026-01-05 10:00:00', 1, 2500.00, 'Completed'),
(1, 3, '2026-01-10 12:00:00', 1, 12000.00, 'Completed'),
(3, 5, '2026-01-15 15:30:00', 1, 55000.00, 'Completed'),
(4, 1, '2026-01-20 09:45:00', 1, 75000.00, 'Completed'),
(2, 4, '2026-01-22 11:00:00', 2, 17000.00, 'Completed'),
(1, 6, '2026-01-25 14:20:00', 5, 6000.00, 'Completed'),
(3, 2, '2026-02-01 10:15:00', 1, 2500.00, 'Completed'),
(5, 3, '2026-02-02 16:00:00', 1, 12000.00, 'Completed'),
(1, 5, '2026-02-05 09:30:00', 1, 55000.00, 'Completed'),
(4, 6, '2026-02-10 11:50:00', 2, 2400.00, 'Completed'),
(2, 1, '2026-02-15 13:40:00', 1, 75000.00, 'Completed'),
(3, 4, '2026-02-20 15:00:00', 1, 8500.00, 'Completed'),
(1, 2, '2026-03-01 10:00:00', 2, 5000.00, 'Completed'),
(5, 5, '2026-03-02 11:30:00', 1, 55000.00, 'Completed'),
(4, 3, '2026-03-05 14:00:00', 1, 12000.00, 'Completed'),
(2, 6, '2026-03-07 16:30:00', 4, 4800.00, 'Completed'),
(1, 4, '2026-03-10 09:20:00', 1, 8500.00, 'Completed'),
(3, 1, '2026-03-12 11:00:00', 1, 75000.00, 'Completed'),
(5, 2, '2026-03-15 10:45:00', 3, 7500.00, 'Completed'),
(4, 5, '2026-04-01 12:30:00', 1, 55000.00, 'Completed'),
(1, 3, '2026-04-02 09:00:00', 2, 24000.00, 'Completed'),
(2, 1, '2026-04-05 13:15:00', 1, 75000.00, 'Completed'),
(3, 6, '2026-04-07 15:30:00', 1, 1200.00, 'Completed'),
(5, 4, '2026-04-10 16:00:00', 1, 8500.00, 'Completed');
