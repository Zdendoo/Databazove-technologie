CREATE View high_value_customers AS
SELECT c.customer_id, c.customer_name, SUM(o.sales) AS total_sales FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name HAVING SUM(o.sales) > 2000;

SELECT * from high_value_customers

SELECT COUNT(*) from high_value_customers

--------------------------------------------------------------------------------

CREATE view regional_monthly_sales AS
SELECT c.region, date_trunc('month',o.order_date) AS month, SUM(o.sales) as monthly_sales FROM customers c 
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.region, date_trunc('month', o.order_date);

SELECT * FROM regional_monthly_sales
WHERE region = 'West' ORDER BY month;

--------------------------------------------------------------------------------

CREATE View analyst_orders AS
SELECT order_id, customer_id, product_id, sales, quantity, discount FROM orders;

--------------------------------------------------------------------------------

CREATE INDEX idx_orders_customer_id
ON orders (customer_id);

SELECT * FROM orders WHERE customer_id = 'C001';

--------------------------------------------------------------------------------

CREATE INDEX idx_orders_customer_id
ON orders (order_date);

SELECT date_trunc('month', order_date) AS month, SUM(sales) AS sum FROM orders
GROUP BY date_trunc('month', order_date) ORDER BY month ASC;

--------------------------------------------------------------------------------

CREATE INDEX idx_orders_customer_id
ON orders (customer_id, order_date);

SELECT o.customer_id, o.profit FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE c.region = 'West' AND o.order_date >= '2024-01-01';