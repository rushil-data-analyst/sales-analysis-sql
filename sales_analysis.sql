Create Database

-- Create tables
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    city VARCHAR(50),
    country VARCHAR(50)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    quantity INT,
    order_date DATE
); 

2. Insert Sample Data

-- Customers
INSERT INTO customers VALUES (1, 'Alice', 'London', 'UK');
INSERT INTO customers VALUES (2, 'Bob', 'New York', 'USA');
INSERT INTO customers VALUES (3, 'Clara', 'Mumbai', 'India');
INSERT INTO customers VALUES (4, 'David', 'Paris', 'France');
INSERT INTO customers VALUES (5, 'Eva', 'London', 'UK');

-- Products
INSERT INTO products VALUES (1, 'Laptop', 'Electronics', 800.00);
INSERT INTO products VALUES (2, 'Phone', 'Electronics', 500.00);
INSERT INTO products VALUES (3, 'Desk', 'Furniture', 200.00);
INSERT INTO products VALUES (4, 'Chair', 'Furniture', 150.00);
INSERT INTO products VALUES (5, 'Headphones', 'Electronics', 100.00);

-- Orders
INSERT INTO orders VALUES (1, 1, 1, 2, '2024-01-15');
INSERT INTO orders VALUES (2, 2, 2, 1, '2024-01-20');
INSERT INTO orders VALUES (3, 3, 3, 4, '2024-02-10');
INSERT INTO orders VALUES (4, 1, 5, 3, '2024-02-14');
INSERT INTO orders VALUES (5, 4, 2, 2, '2024-03-05');
INSERT INTO orders VALUES (6, 5, 4, 5, '2024-03-18');
INSERT INTO orders VALUES (7, 2, 1, 1, '2024-03-22');
INSERT INTO orders VALUES (8, 3, 5, 2, '2024-04-01');
INSERT INTO orders VALUES (9, 4, 3, 1, '2024-04-15');
INSERT INTO orders VALUES (10, 5, 1, 1, '2024-04-28');

3. First Analysis Queries

3.1 Total revenue per product:

SELECT 
    p.product_name,
    SUM(o.quantity * p.price) AS total_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC;

3.2 Total orders per customer:

SELECT 
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_name
ORDER BY total_orders DESC;

3.3 Best selling category:

SELECT 
    p.category,
    SUM(o.quantity) AS units_sold,
    SUM(o.quantity * p.price) AS revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;

3.4 Monthly Revenue Trend:

SELECT 
    strftime('%Y-%m', order_date) AS month,
    SUM(o.quantity * p.price) AS monthly_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY month
ORDER BY month;

3.5 Which country generates most revenue?

SELECT 
    c.country,
    SUM(o.quantity * p.price) AS total_revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id
GROUP BY c.country
ORDER BY total_revenue DESC;

3.6 Customers who spent more than $500 (HAVING clause):

SELECT 
    c.customer_name,
    SUM(o.quantity * p.price) AS total_spent
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id
GROUP BY c.customer_name
HAVING total_spent > 500
ORDER BY total_spent DESC;

3.7 Customers who spent MORE than the average customer spending

-- Same query using CTE (much cleaner!)
WITH customer_spending AS (
    SELECT 
        c.customer_name,
        SUM(o.quantity * p.price) AS total_spent
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN products p ON o.product_id = p.product_id
    GROUP BY c.customer_name
),
avg_spending AS (
    SELECT AVG(total_spent) AS avg_spent 
    FROM customer_spending
)
SELECT 
    customer_name,
    total_spent
FROM customer_spending, avg_spending
WHERE total_spent > avg_spent
ORDER BY total_spent DESC;

3.8 Rank customers by spending:

SELECT 
    c.customer_name,
    SUM(o.quantity * p.price) AS total_spent,
    RANK() OVER (ORDER BY SUM(o.quantity * p.price) DESC) AS spending_rank
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id
GROUP BY c.customer_name;

3.9 Rank products within each category:

SELECT 
    p.category,
    p.product_name,
    SUM(o.quantity * p.price) AS revenue,
    RANK() OVER (PARTITION BY p.category ORDER BY SUM(o.quantity * p.price) DESC) AS rank_in_category
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category, p.product_name;

3.10 Running total of revenue by month:

WITH monthly AS (
    SELECT 
        strftime('%Y-%m', order_date) AS month,
        SUM(o.quantity * p.price) AS monthly_revenue
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY month
)
SELECT 
    month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (ORDER BY month) AS running_total
FROM monthly;

3.11 Customer Segmentation using CASE WHEN:

SELECT 
    c.customer_name,
    SUM(o.quantity * p.price) AS total_spent,
    CASE 
        WHEN SUM(o.quantity * p.price) > 1500 THEN '🥇 VIP'
        WHEN SUM(o.quantity * p.price) > 1000 THEN '🥈 Regular'
        ELSE '🥉 New Customer'
    END AS customer_segment
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id
GROUP BY c.customer_name
ORDER BY total_spent DESC;

3.12  Product Performance Label:

SELECT 
    p.product_name,
    SUM(o.quantity * p.price) AS revenue,
    CASE 
        WHEN SUM(o.quantity * p.price) >= 2000 THEN '🔥 Top Seller'
        WHEN SUM(o.quantity * p.price) >= 800 THEN '✅ Good'
        ELSE '⚠️ Needs Attention'
    END AS performance
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC;





