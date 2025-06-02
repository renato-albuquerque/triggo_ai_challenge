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







