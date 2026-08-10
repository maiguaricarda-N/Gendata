CREATE DATABASE ABC_DATA;
USE ABC_DATA;

-- Customers Table
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(	50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products Table
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price > 0),
    stock INT NOT NULL CHECK (stock > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders Table
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Order_Items Table
CREATE TABLE Order_Items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Populate Customers
INSERT INTO Customers (first_name, last_name, email) VALUES
('John', 'Doe', 'john.doe@email.com'),
('Jane', 'Smith', 'jane.smith@email.com'),
('Michael', 'Brown', 'michael.brown@email.com'),
('Emily', 'Davis', 'emily.davis@email.com'),
('Daniel', 'Wilson', 'daniel.wilson@email.com'),
('Olivia', 'Taylor', 'olivia.taylor@email.com'),
('James', 'Anderson', 'james.anderson@email.com'),
('Sophia', 'Thomas', 'sophia.thomas@email.com'),
('William', 'Jackson', 'william.jackson@email.com'),
('Isabella', 'White', 'isabella.white@email.com');

-- Populate Products
INSERT INTO Products (product_name, price, stock) VALUES
('Gaming Chair', 250.00, 12),
('Bluetooth Speaker', 180.00, 25),
('Wireless Router', 130.00, 18),
('Mechanical Keyboard', 95.00, 30),
('USB-C Hub', 60.00, 40),
('Smartwatch', 320.00, 20),
('Portable SSD', 210.00, 22),
('Office Desk', 450.00, 10),
('LED Desk Lamp', 45.00, 35),
('Noise Cancelling Earbuds', 275.00, 16);

-- Populate Orders
INSERT INTO Orders (customer_id, order_date) VALUES
(1, '2023-06-01'), (2, '2023-06-02'), (3, '2023-06-03'),
(1, '2023-06-05'), (4, '2023-06-06'), (5, '2023-06-07'),
(6, '2023-06-08'), (7, '2023-06-09'), (8, '2023-06-10'),
(9, '2023-06-11'), (10, '2023-06-12');

-- Populate Order_Items
INSERT INTO Order_Items (order_id, product_id, quantity) VALUES
(1, 1, 1), (1, 4, 2), (2, 2, 1), (2, 5, 1),
(3, 3, 2), (3, 6, 1), (4, 1, 1), (4, 10, 2),
(5, 8, 1), (6, 7, 1), (6, 4, 1);

# SECTION A
# SELECT & WHERE THE CUSTOMERS
# RECENT CUSTOMERS
# CONFIRMING THE INSERTS
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;

# Recent Customers (registered in the last 30 days)
SELECT customer_id, first_name, last_name, email, registration_date
FROM customers
WHERE registration_date >= NOW() - INTERVAL 30 DAY;


 # Expensive Products (price > 50), highest to lowest
SELECT * FROM  products;

SELECT product_name, price
FROM products
WHERE price > 50
ORDER BY price DESC;

# Low Stock Products (stock < 5)
SELECT * FROM products;

SELECT product_name, stock
FROM products
WHERE stock < 5;

# section B : ORDER BY AND LIMIT
# Top 5 Most Expensive Products
SELECT  * FROM products;

SELECT  product_name, price
FROM products
ORDER BY price DESC
LIMIT 5;

# Latest Orders (5 most recent)
SELECT * FROM ORDERS;

SELECT order_id, customer_id, order_date
FROM orders
ORDER BY order_date DESC
LIMIT 5;

# SECTION C : UPDATE & DELETE
# Update Stock: increase Gaming Chair stock by 10
SELECT * FROM products;

SELECT product_name, stock
FROM products
WHERE product_name = 'Gaming Chair';

UPDATE products
SET stock = stock + 10
WHERE product_name = 'Gaming Chair';

SELECT product_name, stock
FROM products
WHERE product_name = 'Gaming Chair';


# Delete Test Data
SELECT * FROM order_items;
SELECT * FROM products;

# deleting the order_items in ref to product_id 
DELETE FROM order_items
WHERE product_id = 8;

 #checking  the product has been deleted
SELECT * FROM order_items;

# section D : AGGREGATES FUNCTIONS
# 8: Total Customers
SELECT * FROM customers;

SELECT COUNT(*) AS total_customers
FROM customers;
 
# 9. Total Orders and Revenue
SELECT COUNT(*) AS total_orders
FROM orders;

# total revenue
SELECT SUM(quantity * 
(SELECT price
     FROM products
     WHERE products.product_id = order_items.product_id)
) AS total_revenue
FROM order_items;

SELECT * FROM ORDER_ITEMS;
 
# 10. Average Product Price
SELECT * FROM products;
SELECT AVG(price) AS average_price
FROM products;

# Most and Least Expensive Product

# Most expensive:
SELECT product_name, price
FROM products
ORDER BY price DESC
LIMIT 1;

# least expensive
SELECT product_name, price
FROM products
ORDER BY price ASC
LIMIT 1;

SELECT * FROM products;

# 10: Orders per CUSTOMERS
SELECT * FROM CUSTOMERS;

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS order_count
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY c.customer_id;

# Grouping data with GROUP BY
# Filtering groups with HAVING
# Categorizing data with CASE WHEN
# Combining tables using JOINs (INNER, LEFT, RIGHT)
# Using combined queries (UNION / UNION ALL)

#SECTION A – GROUP BY & HAVING
# Customer Order Summary
# For each customer, calculate the total number of orders they have placed and the total order quantity across all orders.
# Show: customer_id, first_name, last_name, order_count, total_quantity
#CUSTOMER ORDER SUMMARY
SELECT c.customer_id, c.first_name, c.last_name, 
       COUNT(DISTINCT o.order_id) AS order_count, 
       SUM(oi.quantity) AS total_quantity
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
LEFT JOIN Order_Items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name;

#HIGH VALUE CUSTOMER

#High-Value Customers
#Find customers whose total spending exceeds 100.
#Show: customer_id, first_name, last_name, total_spent
SELECT c.customer_id, c.first_name, c.last_name, 
       SUM(oi.quantity * p.price) AS total_spent
FROM Customers c
INNER JOIN Orders o ON c.customer_id = o.customer_id
INNER JOIN Order_Items oi ON o.order_id = oi.order_id
INNER JOIN Products p ON oi.product_id = p.product_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(oi.quantity * p.price) > 100;

#Popular Products
#Find products that have been ordered more than 5 times in total.
#Show: product_name, total_quantity_ordered
SELECT p.product_name, SUM(oi.quantity) AS total_quantity_ordered
FROM Products p
INNER JOIN Order_Items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
HAVING SUM(oi.quantity) < 5;

SELECT * FROM order_items;

#SECTION B – CASE WHEN

#Product Price Categories
#Classify products as:
#Budget if price ≤ 20
#Standard if price > 20 and ≤ 50
#Premium if price > 50
#Show: product_name, price, price_categoryClassify products as:
SELECT * FROM products;
SELECT
    product_name,
    price,
    CASE
        WHEN price <= 20 THEN 'Budget'
        WHEN price > 20 AND price <= 50 THEN 'Standard'
        WHEN price > 50 THEN 'Premium'
    END AS price_category
FROM products;

#Customer Value Classification
#Classify customers based on total spending:
#Low if spending < 50
#Medium if spending ≥ 50 and < 150
#High if spending ≥ 150
#Show: customer_id, first_name, last_name, total_spent, value_category

SELECT
    customer_id,
    first_name,
    last_name,
    total_spent,
    CASE
        WHEN total_spent IS NULL THEN 'Low'
        WHEN total_spent < 50 THEN 'Low'
        WHEN total_spent < 150 THEN 'Medium'
        ELSE 'High'
    END AS value_category
FROM (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        (
            SELECT SUM(oi.quantity * (SELECT price FROM products WHERE product_id = oi.product_id))
            FROM order_items oi
            WHERE oi.order_id IN (SELECT order_id FROM orders WHERE customer_id = c.customer_id)
        ) AS total_spent
    FROM customers c
) AS customer_totals
ORDER BY total_spent DESC;

#SECTION C – JOINS
#Orders with Customer Info
#Retrieve all orders along with customer first and last names.
#Show: order_id, order_date, first_name, last_name, total_amount
SELECT * FROM ORDERS;
SELECT * FROM CUSTOMERS;
SELECT o.order_id, o.order_date, c.first_name, c.last_name, 
       SUM(oi.quantity * p.price) AS total_amount
FROM Orders o
INNER JOIN Customers c ON o.customer_id = c.customer_id
INNER JOIN Order_Items oi ON o.order_id = oi.order_id
INNER JOIN Products p ON oi.product_id = p.product_id
GROUP BY o.order_id, o.order_date, c.first_name, c.last_name;

#Order Details with Product Names
#Retrieve order items along with product names and prices.
#Show: order_id, product_name, quantity, unit_price
# Order Details with Product Names
SELECT
    oi.order_id,
    p.product_name,
    oi.quantity,
    p.price AS unit_price
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.product_id
ORDER BY oi.order_id;


#All Customers and Their Orders (Including Those Without Orders)
#Use a LEFT JOIN to include all customers, even if they haven’t placed an order.
#Show: customer_id, first_name, last_name, order_id, order_date
SELECT * FROM customers;
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    o.order_id,
    o.order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id;


# SECTION D – COMBINED QUERIES 

# Products Sold vs Never Sold
#Retrieve a list of all products, indicating whether they have been sold at least once.
#Columns: product_name, sold_status (Sold / Never Sold)
SELECT
    p.product_name,
    CASE
        WHEN COUNT(oi.order_id) > 0 THEN 'Sold'
        ELSE 'Never Sold'
    END AS sold_status
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY sold_status, p.product_name;
 
 
 #Customers Who Placed Orders vs Those Who Haven’t
#Use a combined query (UNION) to get two lists:
#Customers who have placed at least one order
#Customers who have not placed any orders
#Show: customer_id, first_name, last_name, order_status (Has Orders / No Orders)
# Customers Who Placed Orders vs Those Who Haven't (UNION)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    'Has Orders' AS order_status
FROM customers c
WHERE c.customer_id IN (SELECT customer_id FROM orders)
 
UNION
 
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    'No Orders' AS order_status
FROM customers c
WHERE c.customer_id NOT IN (SELECT customer_id FROM orders)
 
ORDER BY customer_id;