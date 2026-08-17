#section a – indexing
#1. basic index creation
#first, check the existing indexes.

select * from orders
where order_date >= '2023-01-01'
and order_date < '2024-01-01';

#2. full-text index
#create a fulltext index on products(product_name) and use it to search for products containing chair or desk.
create index order_date_index
on orders(order_date);

select * from products
where match(product_name) against('chair');

select * from products
where match(product_name) against('desk');

#3. Analyze Index Usage
#Use EXPLAIN to check which queries use indexes.
#Test joins between orders and customers filtering by order_date.

select * from customers; 

select * from customers
join orders
    on customers.customer_id = orders.customer_id
where orders.order_date >= '2023-01-01'
and orders.order_date < '2024-01-01';

#3. Analyze Index Usage
#Use EXPLAIN to check which queries use indexes.
#Test joins between orders and customers filtering by order_date.

select  * from orders o
join customers c on o.customer_id = c.customer_id
where o.order_date >= '2023-06-01';

create index idx_orders_order_date on orders(order_date);

#section b – partitioning
#4. range partitioning
#step 1: create a copy of orders

select constraint_name
from information_schema.key_column_usage
where table_schema = 'abc_data'
  and table_name = 'orders'
  and referenced_table_name is not null;
  
alter table orders drop foreign key orders_ibfk_1;

alter table orders
drop primary key,
add primary key (order_id, order_date);
alter table orders
partition by range (year(order_date)) (
   partition p2023 values less than (2024),
   partition p2024 values less than (2025),
   partition p_future values less than maxvalue
);


# hasrsh partitioning
alter table customers
partition by hash(customer_id)
partitions 4;

#Validate even distribution:

select partition_name, table_rows
from information_schema.partitions
where table_schema = 'abc_data'
and table_name = 'customers';

#SECTION C – QUERY OPTIMIZATION
#7. Optimize a Heavy Join Query
#Before — baseline:


select c.customer_id, c.first_name, c.last_name,
       sum(oi.quantity * p.price) as total_spent
from customers c
join orders o on c.customer_id = o.customer_id
join order_items oi on o.order_id = oi.order_id
join products p on oi.product_id = p.product_id
group by c.customer_id, c.first_name, c.last_name;


create index idx_orderitems_order on order_items(order_id);
create index idx_orderitems_product on order_items(product_id);
create index idx_orders_customer on orders(customer_id);

#8.Optimize Aggregates
select p.product_name,
       sum(oi.quantity) as total_quantity,
       sum(oi.quantity * p.price) as total_revenue
from order_items oi
join products p on oi.product_id = p.product_id
group by p.product_name;

create index idx_orderitems_product_id on order_items(product_id);
create index idx_products_product_id on products(product_id);


#9.Optimize Date Filters
select month(order_date) as order_month, count(*) as total_orders
from orders
group by month(order_date);

create index idx_orders_order_date on orders(order_date);


#BONUS TASK – Combined Performance
#Create a query joining all four tables to show customer-level metrics: customer_id, total_orders, total_quantity, total_spent.
#Ensure it runs efficiently using indexes and partitions.
#Verify performance using EXPLAIN.

select c.customer_id,
       count(distinct o.order_id) as total_orders,
       sum(oi.quantity) as total_quantity,
       sum(oi.quantity * p.price) as total_spent
from customers c
join orders o on c.customer_id = o.customer_id
join order_items oi on o.order_id = oi.order_id
join products p on oi.product_id = p.product_id
group by c.customer_id;