-- ================================================
-- PROJECT: Sales Analysis using SQL
-- Author: Rushil
-- Date: May 2026
-- Tools: SQLite
-- ================================================

-- ---- TABLE CREATION ----
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

-- ---- 1. TOTAL REVENUE PER PRODUCT ----
SELECT 
    p.product_name,
    SUM(o.quantity * p.price) AS total_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC;

-- ---- 2. TOTAL ORDERS PER CUSTOMER ----
SELECT 
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_name
ORDER BY total_orders DESC;

-- ---- 3. BEST SELLING CATEGORY ----
SELECT 
    p.category,
    SUM(o.quantity) AS units_sold,
    SUM(o.quantity * p.price) AS revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- ---- 4. MONTHLY REVENUE TREND ----
SELECT 
    strftime('%Y-%m', order_date) AS month,
    SUM(o.quantity * p.price) AS monthly_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY month
ORDER BY month;

-- ---- 5. REVENUE BY COUNTRY ----
SELECT 
    c.country,
    SUM(o.quantity * p.price) AS total_revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id
GROUP BY c.country
ORDER BY total_revenue DESC;

-- ---- 6. HIGH VALUE CUSTOMERS (HAVING) ----
SELECT 
    c.customer_name,
    SUM(o.quantity * p.price) AS total_spent
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id
GROUP BY c.customer_name
HAVING total_spent > 500
ORDER BY total_spent DESC;

-- ---- 7. CUSTOMERS ABOVE AVERAGE SPENDING (CTE) ----
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

-- ---- 8. CUSTOMER SPENDING RANK (WINDOW FUNCTION) ----
SELECT 
    c.customer_name,
    SUM(o.quantity * p.price) AS total_spent,
    RANK() OVER (ORDER BY SUM(o.quantity * p.price) DESC) AS spending_rank
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id
GROUP BY c.customer_name;

-- ---- 9. RANK WITHIN CATEGORY (PARTITION BY) ----
SELECT 
    p.category,
    p.product_name,
    SUM(o.quantity * p.price) AS revenue,
    RANK() OVER (PARTITION BY p.category 
                 ORDER BY SUM(o.quantity * p.price) DESC) AS rank_in_category
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category, p.product_name;

-- ---- 10. RUNNING TOTAL BY MONTH ----
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

-- ---- 11. CUSTOMER SEGMENTATION (CASE WHEN) ----
SELECT 
    c.customer_name,
    SUM(o.quantity * p.price) AS total_spent,
    CASE 
        WHEN SUM(o.quantity * p.price) > 1500 THEN 'VIP'
        WHEN SUM(o.quantity * p.price) > 1000 THEN 'Regular'
        ELSE 'New Customer'
    END AS customer_segment
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id
GROUP BY c.customer_name
ORDER BY total_spent DESC;

-- ---- 12. PRODUCT PERFORMANCE LABEL ----
SELECT 
    p.product_name,
    SUM(o.quantity * p.price) AS revenue,
    CASE 
        WHEN SUM(o.quantity * p.price) >= 2000 THEN 'Top Seller'
        WHEN SUM(o.quantity * p.price) >= 800  THEN 'Good'
        ELSE 'Needs Attention'
    END AS performance
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC;
