Find customers generating the most revenue.
SELECT
    c.customer_unique_id,
    ROUND(SUM(p.payment_value),2) AS total_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN payments p
    ON o.order_id = p.order_id
GROUP BY c.customer_unique_id
ORDER BY total_spent DESC
LIMIT 10;
RANK()
WITH customer_spending AS (
    SELECT
        c.customer_unique_id,
        ROUND(SUM(p.payment_value),2) AS total_spent
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN payments p
        ON o.order_id = p.order_id
    GROUP BY c.customer_unique_id
)

SELECT
    customer_unique_id,
    total_spent,
    RANK() OVER (
        ORDER BY total_spent DESC
    ) AS customer_rank
FROM customer_spending;
High Value, Medium Value, Low Value
WITH customer_spending AS (
    SELECT
        c.customer_unique_id,
        SUM(p.payment_value) AS total_spent
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN payments p
        ON o.order_id = p.order_id
    GROUP BY c.customer_unique_id
)

SELECT
    CASE
        WHEN total_spent >= 1000 THEN 'High Value'
        WHEN total_spent >= 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment,
    COUNT(*) AS customers
FROM customer_spending
GROUP BY customer_segment;
How many customers purchased more than once?
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*) AS repeat_customers
FROM customer_orders
WHERE total_orders > 1;

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
ROUND(
100.0 *
SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)
/
COUNT(*),
2
) AS repeat_customer_rate
FROM customer_orders;

SELECT
ROUND(
SUM(payment_value) /
COUNT(DISTINCT customer_id),
2
) AS avg_customer_revenue
FROM orders o
JOIN payments p
ON o.order_id = p.order_id;
Customer growth over time.
WITH first_purchase AS (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_order
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    DATE_FORMAT(first_order,'%Y-%m') AS month,
    COUNT(*) AS new_customers
FROM first_purchase
GROUP BY month
ORDER BY month;
SUM() OVER()
WITH first_purchase AS (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_order
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
),
monthly_customers AS (
    SELECT
        DATE_FORMAT(first_order,'%Y-%m') AS month,
        COUNT(*) AS new_customers
    FROM first_purchase
    GROUP BY month
)
SELECT
    month,
    new_customers,
    SUM(new_customers)
    OVER(ORDER BY month) AS cumulative_customers
FROM monthly_customers;
ROW_NUMBER()
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,
        ROW_NUMBER() OVER(
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp
        ) AS rn
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
)
SELECT *
FROM customer_orders
WHERE rn = 1;

SELECT
    c.customer_unique_id,
    ROUND(SUM(p.payment_value),2) AS customer_lifetime_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN payments p
    ON o.order_id = p.order_id
GROUP BY c.customer_unique_id
ORDER BY customer_lifetime_value DESC;