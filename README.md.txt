# 🛒 SQL E-Commerce Analysis

## 📌 Project Overview

This project performs an end-to-end **E-Commerce Data Analysis using MySQL**.

The objective is to analyze customers, products, orders, revenue, discounts, profitability, customer behavior, and sales trends using SQL.

The project demonstrates how SQL can be used to transform raw transactional data into meaningful business insights.

---

## 🎯 Business Objectives

The analysis focuses on answering important business questions such as:

- How much total revenue was generated?
- How much revenue came from delivered orders?
- Which customers generate the highest revenue?
- Which customers place the most orders?
- Which product categories generate the most revenue?
- Which products generate the highest revenue and profit?
- Which month generated the highest revenue?
- What is the monthly revenue trend?
- How much did revenue increase or decrease compared with the previous month?
- Which customers contribute the highest percentage of total revenue?
- How can customers be segmented based on revenue?
- Which products have never been ordered?
- Which category has the highest average discount?
- Which category generates the highest total profit?

---

# 🗂️ Database Schema

The project contains four main tables:

### 1. Customers

Stores customer demographic and registration information.

| Column | Description |
|---|---|
| customer_id | Unique customer identifier |
| customer_name | Customer name |
| gender | Customer gender |
| age | Customer age |
| city | Customer city |
| state | Customer state |
| country | Customer country |
| signup_date | Customer registration date |

### 2. Products

Stores product information and pricing.

| Column | Description |
|---|---|
| product_id | Unique product identifier |
| product_name | Product name |
| category | Product category |
| subcategory | Product subcategory |
| unit_price | Selling price |
| cost_price | Product cost |

### 3. Orders

Stores order-level information.

| Column | Description |
|---|---|
| order_id | Unique order identifier |
| customer_id | Customer who placed the order |
| order_date | Date of order |
| order_status | Order status |
| payment_method | Payment method |

### 4. Order Items

Stores products included in each order.

| Column | Description |
|---|---|
| order_item_id | Unique order-item identifier |
| order_id | Associated order |
| product_id | Associated product |
| quantity | Number of units purchased |
| unit_price | Selling price per unit |
| discount | Discount applied |

---

# 🔗 Table Relationships

```text
Customers
    │
    │ customer_id
    ▼
Orders
    │
    │ order_id
    ▼
Order_Items
    │
    │ product_id
    ▼
Products  
                    
🛠️ Technologies Used
MySQL
SQL
MySQL Workbench

📚 SQL Concepts Demonstrated
This project covers a wide range of SQL concepts:

Basic SQL
SELECT
WHERE
ORDER BY
GROUP BY
HAVING
LIMIT
DISTINCT

Aggregate Functions
COUNT()
SUM()
AVG()

Joins
INNER JOIN
LEFT JOIN

Advanced SQL
Subqueries
Derived tables
Window Functions
OVER()
PARTITION BY
LAG()
RANK()
DENSE_RANK()
ROW_NUMBER()

Conditional Logic
CASE WHEN

Date Functions
YEAR()
MONTH()
DATE_FORMAT()

Data Quality Checks
Duplicate detection
Missing value checks
Record counts
Table inspection