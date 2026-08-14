CREATE DATABASE Ecommerce_analysis;
USE Ecommerce_analysis;
CREATE TABLE customers(
	customer_id INT primary key,
    customer_name VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    city VARCHAR(20),
    state VARCHAR(20),
    country VARCHAR(20),
    signup_date DATE
);

CREATE TABLE products(
	product_id INT PRIMARY KEY,
	product_name VARCHAR(150),
    category VARCHAR(50),
    subcategory VARCHAR(100),
    unit_price DECIMAL (12,2),
    cost_price DECIMAL(12,2)
);

CREATE TABLE orders(
	order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    order_status VARCHAR(50),
    payment_method VARCHAR(50),
    
    foreign key (customer_id)
		references customers(customer_id)
);

CREATE TABLE order_items(
	order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(12,2),
    discount DECIMAL(5,2),
    
    FOREIGN KEY (order_id)
		REFERENCES orders(order_id),
        
	foreign key (product_id)
		references products(product_id)
);

SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;

SHOW TABLES;
SELECT * FROM customers LIMIT 10;
SELECT * FROM products LIMIT 10;
SELECT * FROM orders LIMIT 5;
SELECT * FROM order_items LIMIT 5;

-- CHECK DUPLICATE VALUES 
SELECT customer_id , COUNT(*) AS count FROM customers
GROUP BY customer_id 
HAVING COUNT(*) > 1;
-- Check Duplicates 
SELECT product_id ,COUNT(*) AS count FROM products
GROUP BY product_id 
HAVING COUNT(*)>1;

-- CHECK FOR MISSING VALUE-- 
SELECT SUM(customer_id IS NULL) AS missing_customer_id, 
SUM(customer_name IS NULL) AS missing_name,
SUM(gender IS NULL) AS missing_gender,
SUM(age IS NULL) AS missing_age,
SUM(city IS NULL) AS missing_city,
SUM(signup_date IS NULL) AS missing_signup_date 
FROM customers;

SELECT
    SUM(product_id IS NULL) AS missing_product_id,
    SUM(product_name IS NULL) AS missing_product_name,
    SUM(category IS NULL) AS missing_category,
    SUM(unit_price IS NULL) AS missing_unit_price,
    SUM(cost_price IS NULL) AS missing_cost_price
FROM products;

-- Count the number of male,female and others 
SELECT gender, COUNT(*) AS customers 
FROM customers
GROUP BY gender
ORDER BY customers DESC;    -- To order the larger group first then smaller we use - ORDER BY DESC

-- Count of customer by state
SELECT state , COUNT(*) AS customers
FROM customers 
GROUP BY state;

-- Count of Product categories from products
SELECT category , COUNT(*) AS products 
FROM products
GROUP BY category;

-- Count of Order Status
SELECT order_status ,COUNT(*)  AS orders
FROM orders
GROUP BY order_status;

-- Count of payment methods for orders
SELECT payment_method , count(*)
FROM orders
GROUP BY payment_method;

-- 5 Cities have the highest number of customers
SELECT city , COUNT(*) AS customers
FROM customers
GROUP BY city 
ORDER BY customers DESC 
LIMIT 5;

-- 3 Product categories have the highest number of products
SELECT category ,COUNT(*) AS products
FROM products
GROUP BY category 
ORDER BY products DESC      -- Order by gives top to bottom values 
LIMIT 3;

-- Total revenue generated from all order items
SELECT SUM(quantity*unit_price*(1-discount)) AS revenue
FROM order_items;

-- JOIN OPERATIONS 
-- INNER JOIN
-- Show customer name and order id for every order.
SELECT c.customer_name , o.order_id 
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id;
-- Show the customer nme and order date for every order.
SELECT c.customer_name, o.order_date 
FROM customers c 
INNER JOIN orders o 
ON c.customer_id = o.customer_id;

-- LEFT JOIN
-- Show every customer name and their order ID, including customers who have no orders.
SELECT c.customer_name,o.order_id 
FROM customers c 
LEFT JOIN orders o
ON c.customer_id = o.customer_id;
-- Find all customers who have never placed an order.  (LEFT JOIN + WHERE Clause)
SELECT c.customer_name
FROM customers c
LEFT JOIN orders o 
ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
-- How many orders has each customer placed?    (LEFT JOIN + COUNT)
SELECT c.customer_name, COUNT(o.order_id) AS order_placed
FROM customers c 
LEFT JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_name, c.customer_id
ORDER BY order_placed DESC
LIMIT 5;

-- What is the revenue generated from Delivered orders ?
SELECT o.order_id , SUM(oi.quantity* oi.unit_price * (1-oi.discount)) AS revenue
FROM orders o 
INNER JOIN order_items oi
ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered'
GROUP BY o.order_id;

-- What is the total revenue amount generated from Delivered orders?
SELECT SUM(oi.quantity * oi.unit_price *(1-oi.discount)) AS total_revenue
FROM orders o
INNER JOIN order_items oi
ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered';

-- Which customers generated the highest revenue? (Multiple Joins)
SELECT c.customer_id,c.customer_name,SUM(oi.quantity * oi.unit_price * (1-oi.discount)) AS revenue
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
INNER JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY c.customer_id,c.customer_name
ORDER BY revenue DESC
LIMIT 5;

-- Which product categories generate the most revenue?
SELECT p.category , SUM(oi.quantity * oi.unit_price * (1-oi.discount)) AS revenue
FROM products p 
INNER JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY revenue DESC
LIMIT 5;

-- What percentage of the total revenue comes from each category? (SUB-QUERIES)
SELECT category , revenue , revenue / SUM(revenue) OVER() *  100 AS revenue_percentage
FROM (
	SELECT p.category , SUM(oi.quantity * oi.unit_price * (1-oi.discount)) AS revenue
    FROM products p
    INNER JOIN order_items oi
    ON p.product_id = oi.product_id
    GROUP BY p.category
) AS category_sales
ORDER BY revenue DESC;

-- Which month generated the highest revenue?
SELECT YEAR(o.order_date) AS Year ,MONTH(o.order_date) AS Month, SUM(oi.quantity * oi.unit_price * (1-oi.discount)) AS revenue
FROM orders o 
INNER JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY Year,Month
ORDER BY revenue DESC
LIMIT 5;

-- What is the monthly revenue trend?
SELECT date_format(o.order_date,'%Y-%m') AS Monthly_Trend ,  SUM(oi.quantity * oi.unit_price * (1-oi.discount)) AS revenue
FROM orders o
INNER JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY Monthly_Trend
ORDER BY Monthly_Trend;

-- What is the monthly revenue trend? Now using LAG() for previous month revenue also
SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS monthly_trend,SUM(oi.quantity * oi.unit_price*(1-oi.discount)) AS revenue 
,LAG(SUM(oi.quantity * oi.unit_price*(1-oi.discount))) OVER(order by DATE_FORMAT(o.order_date,'%Y-%m')) 
AS previous_revenue
FROM orders o 
INNER JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY monthly_trend
ORDER BY monthly_trend;

-- Per Month Change in revenue 
SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS monthly_trend,SUM(oi.quantity * oi.unit_price*(1-oi.discount)) AS revenue 
,LAG(SUM(oi.quantity * oi.unit_price*(1-oi.discount))) OVER(order by DATE_FORMAT(o.order_date,'%Y-%m')) 
AS previous_revenue,
SUM(oi.quantity * oi.unit_price*(1-oi.discount)) - LAG(SUM(oi.quantity * oi.unit_price*(1-oi.discount))) OVER(order by DATE_FORMAT(o.order_date,'%Y-%m')) 
AS revenue_change
FROM orders o 
INNER JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY monthly_trend
ORDER BY monthly_trend;

-- By what percentage did revenue increase/decrease compared with the previous month?
SELECT monthly_trend,revenue, previous_revenue,revenue_change , 
revenue_change / previous_revenue * 100 AS revenue_percentage
FROM(
SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS monthly_trend,
SUM(oi.quantity * oi.unit_price*(1-oi.discount)) AS revenue,
LAG(SUM(oi.quantity * oi.unit_price*(1-oi.discount))) OVER(order by DATE_FORMAT(o.order_date,'%Y-%m')) 
AS previous_revenue,
SUM(oi.quantity * oi.unit_price*(1-oi.discount)) - LAG(SUM(oi.quantity * oi.unit_price*(1-oi.discount))) OVER(order by DATE_FORMAT(o.order_date,'%Y-%m')) 
AS revenue_change
FROM orders o 
INNER JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY monthly_trend)
AS revenue_trend
GROUP BY monthly_trend
ORDER BY monthly_trend;

-- Find the rank of top 10 customers by revenue using the rank().
SELECT c.customer_id,c.customer_name,SUM(oi.quantity*oi.unit_price*(1-discount)) AS revenue,
RANK() OVER(ORDER BY SUM(oi.quantity*oi.unit_price*(1-discount)) DESC) AS customer_rank
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
INNER JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY c.customer_id , c.customer_name
ORDER BY customer_rank
LIMIT 10;

-- Find the rank of top 10 customers by revenue using the DENSE_RANK().
SELECT c.customer_id,c.customer_name,SUM(oi.quantity*oi.unit_price*(1-discount)) AS revenue,
DENSE_RANK() OVER(ORDER BY SUM(oi.quantity*oi.unit_price*(1-discount)) DESC) AS customer_rank
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
INNER JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY c.customer_id , c.customer_name
ORDER BY customer_rank;

-- final the latest order per customer (using ROW_NUMBER()) where order_number = 1
SELECT *
FROM(
	SELECT c.customer_id , c.customer_name , o.order_id , o.order_date 
    ,ROW_NUMBER() OVER(PARTITION BY c.customer_id ORDER BY o.order_date DESC) AS order_number
    FROM customers c 
   INNER JOIN orders o
   ON c.customer_id = o.customer_id
) AS latest_orders
WHERE order_number = 1
ORDER BY order_number;

-- What is each customer's total revenue AND what percentage of the total revenue did that customer generate?
SELECT customer_id,customer_name ,customer_revenue , (customer_revenue / SUM(customer_revenue)OVER()) * 100 AS percentage
FROM (
	SELECT c.customer_id , c.customer_name , SUM(oi.quantity * oi.unit_price * (1-oi.discount)) AS customer_revenue
	FROM customers c
    INNER JOIN orders o 
    ON c.customer_id = o.customer_id 
    INNER JOIN order_items oi
    ON o.order_id = oi.order_id  	
    GROUP BY c.customer_id , c.customer_name
) AS customers_revenue
ORDER BY customer_revenue DESC;

-- How many customers placed more than one order?
SELECT c.customer_id , c.customer_name , COUNT(o.order_id) AS order_count
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id 
HAVING COUNT(o.order_id) > 1;

-- What is repeated customers rate ?
SELECT customer_id , customer_name , order_count , (order_count / SUM(order_count)OVER()) * 100 AS order_rate
, SUM(order_count)OVER()
FROM(
	SELECT c.customer_id , c.customer_name ,
    COUNT(o.order_id) AS order_count
    FROM customers c
    INNER JOIN orders o 
    ON c.customer_id = o.customer_id
    GROUP BY c.customer_id 
    HAVING COUNT(o.order_id) > 1
)AS customers_rate;

-- Classify customers revenue into High, Medium, and Low-value customers.
SELECT customer_id,customer_name,customer_revenue,
CASE WHEN customer_revenue>= 1500000 THEN 'HIGH VALUE'
WHEN customer_revenue >= 500000 THEN 'MEDIUM VALUE'
ELSE 'LOW VALUE'
END AS customer_segment 
FROM (
	SELECT c.customer_id , c.customer_name , SUM(oi.quantity * oi.unit_price *(1-oi.discount)) AS customer_revenue
    FROM customers c 
    INNER JOIN orders o 
    ON c.customer_id = o.customer_id
    INNER JOIN order_items oi
	ON o.order_id = oi.order_id
    GROUP BY c.customer_id,c.customer_name
) AS revenue_classify;

-- How many High, Medium, and Low-value customers do we have?
SELECT customer_segment , COUNT(*) AS customers
FROM(
SELECT customer_id,customer_name,customer_revenue,
CASE WHEN customer_revenue>= 1500000 THEN 'HIGH VALUE'
WHEN customer_revenue >= 500000 THEN 'MEDIUM VALUE'
ELSE 'LOW VALUE'
END AS customer_segment 
FROM (
	SELECT c.customer_id , c.customer_name , SUM(oi.quantity * oi.unit_price *(1-oi.discount)) AS customer_revenue
    FROM customers c 
    INNER JOIN orders o 
    ON c.customer_id = o.customer_id
    INNER JOIN order_items oi
	ON o.order_id = oi.order_id
    GROUP BY c.customer_id,c.customer_name
) AS revenue_classify)
AS customer_values
GROUP BY customer_segment;

-- How much revenue does each segment generate and percentage of total revenue comes from each customer segment ?
SELECT customer_segment , COUNT(*) AS segment_count , SUM(customer_revenue) AS segment_revenue 
, (
SUM(customer_revenue)/SUM(SUM(customer_revenue))OVER()) * 100 AS segment_revenue_percentage
FROM(
SELECT customer_id , customer_name , customer_revenue,
CASE WHEN customer_revenue >= 1500000 THEN "HIGH VALUE"
WHEN customer_revenue >= 500000 THEN "MEDIUM VALUE"
ELSE "LOW VALUE"
END AS customer_segment
FROM(
	SELECT c.customer_id , c.customer_name , SUM(oi.quantity * oi.unit_price * (1-oi.discount)) AS customer_revenue
    FROM customers c
    INNER JOIN orders o 
    ON c.customer_id = o.customer_id
    INNER JOIN order_items oi
    ON o.order_id = oi.order_id
    GROUP BY c.customer_id , c.customer_name
)AS revenue_segment
) AS segment_count
GROUP BY customer_segment;

-- Which products have never appeared in any order?
SELECT p.product_id , p.product_name , oi.order_item_id 
FROM products p 
LEFT JOIN order_items oi
ON p.product_id = oi.product_id
WHERE oi.order_item_id IS NULL;

-- Which products have the highest average price?
SELECT product_id , product_name , AVG(unit_price) AS average_price
FROM products 
GROUP BY product_id , product_name
ORDER BY average_price DESC;

-- Which products have the highest profit margin?
SELECT product_id , product_name , unit_price-cost_price as Profit
from products 
GROUP BY product_id , product_name
ORDER BY profit DESC
LIMIT 10;

-- Which product categories have the highest average unit price?
SELECT category , AVG(unit_price) AS average_price
from products
GROUP BY category;

-- Which product categories have the highest average profit per product?
SELECT category , AVG(unit_price-cost_price) AS average_profit
FROM products 
GROUP BY category
ORDER BY average_profit DESC;

-- How many products are there in each category?
SELECT category , COUNT(*) AS total_products
FROM products
GROUP BY category
ORDER BY total_products DESC;

-- Which category sold the most units?
SELECT p.category , SUM(oi.quantity) AS order_quantity
FROM products p
INNER JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.category;

-- Which category generated the highest total profit?
SELECT p.category , SUM(oi.quantity * (p.unit_price - p.cost_price)) AS total_profit
FROM products p
INNER JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.category;

-- How many orders are Delivered, Cancelled, Pending, etc.?
SELECT order_status, COUNT(*) AS order_status_count
FROM orders 
GROUP BY order_status
ORDER BY order_status_count DESC;

-- What is the average revenue generated per order?
SELECT AVG(revenue) AS average_revenue
FROM (
	SELECT order_id AS id , SUM(quantity * unit_price * (1-discount)) AS revenue 
    FROM order_items oi
    GROUP BY order_id
) AS average_revenue_per_order;

-- Top 10 products by total revenue
SELECT p.product_name, SUM(oi.quantity * oi.unit_price * (1-oi.discount)) AS revenue
FROM products p 
INNER JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY revenue DESC 
LIMIT 10;

-- Top 10 products by total profit
SELECT p.product_name , SUM(oi.quantity * oi.unit_price * (1-oi.discount) - p.cost_price) AS profit
FROM products p
INNER JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY profit DESC
LIMIT 10;

-- Which customers placed the most orders?
SELECT c.customer_name , 
COUNT(*) as order_count
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_name,o.order_status
ORDER BY order_count DESC 
LIMIT 10;

-- Which category gives the highest average discount?
SELECT p.category , AVG(oi.discount) AS avg_discount
from products p
INNER JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY avg_discount DESC;

-- How much revenue comes from delivered orders?
SELECT o.order_status , SUM(oi.quantity * oi.unit_price *(1-oi.discount)) AS delivered_revenue
FROM orders o
INNER JOIN order_items oi
ON o.order_id = oi.order_id 
GROUP BY o.order_status
HAVING o.order_status = 'Delivered'
ORDER BY delivered_revenue DESC;