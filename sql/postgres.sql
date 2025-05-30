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

select *
from stage.st_customers
limit 5;





