Uloha 1

WITH ranked_orders AS (
    SELECT 
        c.customer_name,
        o.order_id,
        o.order_date,
        ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.order_date DESC) AS row_num
    FROM 
        orders o
    JOIN 
        customers c ON o.customer_id = c.customer_id
)
SELECT 
    customer_name,
    order_id,
    order_date
FROM 
    ranked_orders
WHERE 
    row_num <= 2
ORDER BY 
    customer_name ASC, 
    row_num ASC;

----------------------------------------------------------------------------

Uloha 2

SELECT 
    c.region,
    c.customer_name,
    SUM(o.profit) AS total_profit,
    RANK() OVER (PARTITION BY c.region ORDER BY SUM(o.profit) DESC) AS profit_rank,
    DENSE_RANK() OVER (PARTITION BY c.region ORDER BY SUM(o.profit) DESC) AS profit_dense_rank
FROM 
    orders o
JOIN 
    customers c ON o.customer_id = c.customer_id
GROUP BY 
    c.region, 
    c.customer_name, 
    c.customer_id
ORDER BY 
    c.region ASC, 
    total_profit DESC;

--------------------------------------------------------------------------

Uloha 3

WITH customer_sales AS (
    SELECT 
        c.customer_name,
        SUM(o.sales) AS total_sales,
        NTILE(4) OVER (ORDER BY SUM(o.sales) DESC) AS quartile
    FROM 
        orders o
    JOIN 
        customers c ON o.customer_id = c.customer_id
    GROUP BY 
        c.customer_id,
        c.customer_name
)
SELECT 
    customer_name,
    total_sales,
    quartile
FROM 
    customer_sales
ORDER BY 
    total_sales DESC;

--------------------------------------------------------------------------------------

Uloha 4

WITH monthly_summary AS (
    SELECT 
        DATE_TRUNC('month', order_date)::date AS month,
        SUM(sales) AS monthly_sales
    FROM 
        orders
    GROUP BY 
        DATE_TRUNC('month', order_date)
)
SELECT 
    month,
    monthly_sales,
    LAG(monthly_sales, 1) OVER (ORDER BY month ASC) AS prev_month_sales,
    LEAD(monthly_sales, 1) OVER (ORDER BY month ASC) AS next_month_sales
FROM 
    monthly_summary
ORDER BY 
    month ASC;

--------------------------------------------------------------------------------

Uloha 5

WITH product_sales_cte AS (
    SELECT 
        p.category,
        p.product_name,
        SUM(o.sales) AS product_sales
    FROM 
        orders o
    JOIN 
        products p ON o.product_id = p.product_id
    GROUP BY 
        p.category, 
        p.product_name
)
SELECT 
    category,
    product_name,
    product_sales,
    SUM(product_sales) OVER (PARTITION BY category) AS category_total,
    ROUND(
        (product_sales * 100.0) / SUM(product_sales) OVER (PARTITION BY category),
        2
    ) AS pct_of_category
FROM 
    product_sales_cte
ORDER BY 
    category ASC, 
    pct_of_category DESC;

---------------------------------------------------------------------------------

Uloha 6

WITH customer_orders_summary AS (
    SELECT DISTINCT
        c.customer_id,
        c.customer_name,
        MAX(o.order_date) OVER (PARTITION BY c.customer_id) AS last_order_date,
        MAX(o.order_date) OVER () AS latest_order_date
    FROM 
        customers c
    JOIN 
        orders o ON c.customer_id = o.customer_id
)
SELECT 
    customer_id,
    customer_name,
    last_order_date
FROM 
    customer_orders_summary
WHERE 
    last_order_date < latest_order_date - INTERVAL '90 days'
ORDER BY 
    last_order_date ASC;

--------------------------------------------------------------------------

Uloha 7

WITH monthly_sales_cte AS (
    SELECT 
        DATE_TRUNC('month', order_date)::date AS month,
        SUM(sales) AS monthly_sales
    FROM 
        orders
    GROUP BY 
        DATE_TRUNC('month', order_date)
),
prev_monthly_sales_cte AS (
    SELECT 
        month,
        monthly_sales,
        LAG(monthly_sales) OVER (ORDER BY month ASC) AS prev_month_sales
    FROM 
        monthly_sales_cte
)
SELECT 
    month,
    monthly_sales,
    prev_month_sales,
    (monthly_sales - prev_month_sales) AS sales_change,
    ROUND(
        ((monthly_sales - prev_month_sales) / prev_month_sales) * 100.0,
        2
    ) AS growth_percentage
FROM 
    prev_monthly_sales_cte
ORDER BY 
    month ASC;

------------------------------------------------------------------------------

Uloha 8

WITH first_purchases AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', MIN(order_date))::date AS first_month
    FROM 
        orders
    GROUP BY 
        customer_id
)
SELECT 
    COUNT(DISTINCT fp.customer_id) AS returned_customers_count
FROM 
    first_purchases fp
WHERE 
    fp.first_month = '2024-06-01'
    AND EXISTS (
        SELECT 1 
        FROM orders o 
        WHERE o.customer_id = fp.customer_id 
          AND DATE_TRUNC('month', o.order_date)::date > '2024-06-01'
    );