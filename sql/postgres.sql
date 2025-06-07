-- Visualizar tabelas bd schema public (Produção).

-- dataset customers
select * 
from customers
limit 10;

-- dataset geolocation
select * 
from geolocation
limit 10;

-- dataset order_items
select * 
from order_items
limit 10;

-- dataset order_payments
select * 
from order_payments
limit 10;

-- dataset order_reviews
select * 
from order_reviews
limit 10;

-- dataset orders
select * 
from orders
limit 10;

-- dataset products
select * 
from products
limit 10;

-- dataset sellers
select * 
from sellers
limit 10;

-- dataset product_category_name_translation
select * 
from product_category_name_translation
limit 10;

-- Criar bd stage (schema). 
create schema stage;

-- Copiar tabelas do bd public (Produção) para o bd stage.
create table stage.st_customers as table public.customers;
create table stage.st_geolocation as table public.geolocation;
create table stage.st_order_items as table public.order_items;
create table stage.st_order_payments as table public.order_payments;
create table stage.st_order_reviews as table public.order_reviews;
create table stage.st_orders as table public.orders;
create table stage.st_product_category_name_translation as table public.product_category_name_translation;
create table stage.st_products as table public.products;
create table stage.st_sellers as table public.sellers;

-- Exemplo tabela stage.st_customers:
select *
from stage.st_customers
limit 5;

-- Criar bd dw (Schema).
create schema if not exists dw;

-- Tabelas dimensão x fato.
-- Modelagem lógica disponível no arquivo README.md.

-- Modelagem física:
-- Criar tabelas dimensão:

-- dim_customers
create table dw.dim_customers (
	customer_id TEXT NOT NULL PRIMARY KEY,
	customer_unique_id TEXT NOT NULL,
	customer_city TEXT,
	customer_state TEXT
);

-- dim_sellers
create table dw.dim_sellers (
	seller_id TEXT NOT NULL PRIMARY KEY,
	seller_city TEXT,
	seller_state TEXT
);

-- dim_products
create table dw.dim_products (
	product_id TEXT NOT NULL PRIMARY KEY,
	product_category_name TEXT,
	product_category_name_english TEXT,
	product_weight_g INT,
	product_height_cm INT,
	product_length_cm INT,
	product_width_cm INT
);

-- dim_orders
create table dw.dim_orders (
	order_id TEXT NOT NULL PRIMARY KEY,
	order_status TEXT,
	order_purchase_timestamp TIMESTAMP, --data_compra
	order_approved_at TIMESTAMP, --data_aprovacao
	order_delivered_carrier_date TIMESTAMP, --data_envio
	order_delivered_customer_date TIMESTAMP, --data_entrega_cliente
	order_estimated_delivery_date TIMESTAMP --data_entrega_prevista
);

-- dim_time
create table dw.dim_time (
	date DATE PRIMARY KEY,
	year INT,
	month INT,
	day INT,
	month_name 	TEXT,
	weekday_name TEXT
);

-- fato
create table dw.fato_opr (
	fato_opr_id SERIAL NOT NULL PRIMARY KEY,
	order_id TEXT REFERENCES dw.dim_orders(order_id), 
	product_id TEXT REFERENCES dw.dim_products(product_id),
	seller_id TEXT REFERENCES dw.dim_sellers(seller_id),
	customer_id TEXT REFERENCES dw.dim_customers(customer_id),
	date TIMESTAMP REFERENCES dw.dim_time(date),
	price NUMERIC,
	freight_value NUMERIC,
	payment_value NUMERIC,
	payment_type TEXT,
	review_score INT
);

-- Carga das tabelas dimensão:
-- dw.dim_customers.
insert into dw.dim_customers (
	customer_id,
	customer_unique_id,
	customer_city,
	customer_state
) 
select distinct
	customer_id,
	customer_unique_id,
	customer_city,
	customer_state
from stage.st_customers;

select * from dw.dim_customers
limit 5;

-- dw.dim_sellers
insert into dw.dim_sellers (
	seller_id,
	seller_city,
	seller_state
)
select distinct
	seller_id,
	seller_city,
	seller_state
from stage.st_sellers;

select * from dw.dim_sellers
limit 5;

-- dw.dim_products
insert into dw.dim_products (
	product_id,
	product_category_name,
	product_category_name_english,
	product_weight_g,
	product_height_cm,
	product_length_cm,
	product_width_cm
)
select distinct
	p.product_id,
	p.product_category_name,
	t.product_category_name_english,
	p.product_weight_g,
	p.product_height_cm,
	p.product_length_cm,
	p.product_width_cm
from stage.st_products p
left join stage.st_product_category_name_translation t
on p.product_category_name = t.product_category_name;

select * from dw.dim_products
limit 5;

-- dw.dim_orders 
insert into dw.dim_orders (
	order_id,
	order_status,
	order_purchase_timestamp,
	order_approved_at,
	order_delivered_carrier_date,
	order_delivered_customer_date,
	order_estimated_delivery_date
)
select distinct
	order_id,
	order_status,
	order_purchase_timestamp, --data_compra
	order_approved_at, --data_aprovacao
	order_delivered_carrier_date, --data_envio
	order_delivered_customer_date, --data_entrega_cliente
	order_estimated_delivery_date TIMESTAMP --data_entrega_prevista
from stage.st_orders;

select * from dw.dim_customers
limit 5;

-- dim_time
insert into dw.dim_time (
    date,
    year,
    month,
    day,
    month_name,
    weekday_name
)
select distinct
    CAST(order_purchase_timestamp AS DATE) AS date,
    EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
    EXTRACT(MONTH FROM order_purchase_timestamp) AS month,
    EXTRACT(DAY FROM order_purchase_timestamp) AS day,
    TO_CHAR(order_purchase_timestamp, 'Month') AS month_name,
    TO_CHAR(order_purchase_timestamp, 'Day') AS weekday_name
FROM stage.st_orders;

select * from dw.dim_time
limit 5;

-- fato_opr
insert into dw.fato_opr (
	order_id, 
	product_id,
	seller_id,
	customer_id,
	date,
	price,
	freight_value,
	payment_value,
	payment_type,
	review_score
)
select 
	oi.order_id,
    oi.product_id,
    oi.seller_id,
    o.customer_id,
    CAST(o.order_purchase_timestamp as date) as purchase_date,
    oi.price,
    oi.freight_value,
    p.payment_value,
    p.payment_type,
    r.review_score
from stage.st_order_items oi
left join stage.st_orders o on oi.order_id = o.order_id
left join stage.st_order_payments p on oi.order_id = p.order_id
left join stage.st_order_reviews r on oi.order_id = r.order_id;

ALTER TABLE dw.fato_opr
ADD CONSTRAINT fk_fato_dim_orders
FOREIGN KEY (order_id)
REFERENCES dw.dim_orders(order_id);

select * from dw.fato_opr;







