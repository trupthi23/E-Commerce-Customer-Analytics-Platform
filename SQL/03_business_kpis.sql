How much money has the company generated?
SELECT
    ROUND(SUM(payment_value),2) AS total_revenue
FROM payments;
How many orders were placed?
SELECT
    COUNT(DISTINCT order_id) AS total_orders
FROM orders;
How many unique customers purchased?
SELECT
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM customers;
How much does an average customer spend per order?
SELECT
    ROUND(
        SUM(payment_value) /
        COUNT(DISTINCT order_id),
        2
    ) AS average_order_value
FROM payments;
SELECT
    COUNT(DISTINCT seller_id) AS total_sellers
FROM sellers;
How many orders were delivered, canceled, shipped, processing?
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;
Is revenue growing?
Are there seasonal spikes?
SELECT
    DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m') AS month,
    ROUND(SUM(p.payment_value),2) AS revenue
FROM orders o
JOIN payments p
    ON o.order_id = p.order_id
GROUP BY month
ORDER BY month;
SELECT
    DATE_FORMAT(order_purchase_timestamp,'%Y-%m') AS month,
    COUNT(*) AS orders
FROM orders
GROUP BY month
ORDER BY month;
SELECT
    c.customer_state,
    ROUND(SUM(p.payment_value),2) AS revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN payments p
    ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;
SELECT
    pr.product_category_name,
    ROUND(SUM(oi.price),2) AS revenue
FROM products pr
JOIN order_items oi
    ON pr.product_id = oi.product_id
GROUP BY pr.product_category_name
ORDER BY revenue DESC
LIMIT 10;
SELECT
    c.customer_city,
    ROUND(SUM(p.payment_value),2) AS revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN payments p
    ON o.order_id = p.order_id
GROUP BY c.customer_city
ORDER BY revenue DESC
LIMIT 10;