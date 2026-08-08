CREATE DATABASE sampleDB;

USE sampleDB;

CREATE TABLE customers(
customer_name varchar(100),
email varchar(100),
age int
);

INSERT INTO customers (customer_name,email,age)
VALUES
("Alice","alice@gmail.com","25"),
("John","john@gmail.com","27");

SELECT * FROM customers;

# alter our data add a new column 

ALTER TABLE customers
add column phone_number VARCHAR(10);

SELECT * FROM customers;

# RENAME THE COLUMN

ALTER TABLE customers
rename column phone_number to nambari_ya_simu;

SELECT * FROM customers;


# updating records
update customers
set nambari_ya_simu = "9712345678"
where customer_name = "John";

SELECT * FROM customers;CREATE DATABASE sampleDB;


