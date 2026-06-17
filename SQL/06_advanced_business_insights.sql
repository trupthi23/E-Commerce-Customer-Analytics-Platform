Which Payment Methods Generate the Most Revenue?
SELECT
    payment_type,
    COUNT(*) AS transactions,
    ROUND(SUM(payment_value),2) AS revenue
FROM payments
GROUP BY payment_type
ORDER BY revenue DESC;
Which Payment Method Has Highest Average Order Value?
SELECT
    payment_type,
    ROUND(AVG(payment_value),2) AS avg_order_value
FROM payments
GROUP BY payment_type
ORDER BY avg_order_value DESC;
Which States Generate Highest Revenue?
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
Which States Have Highest Average Review Scores?
SELECT
    c.customer_state,
    ROUND(AVG(r.review_score),2) AS avg_review_score
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN reviews r
    ON o.order_id = r.order_id
GROUP BY c.customer_state
ORDER BY avg_review_score DESC;
Does Delivery Speed Affect Customer Satisfaction?
SELECT
    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_purchase_timestamp
            )
        ),
        2
    ) AS avg_delivery_days,
    ROUND(
        AVG(review_score),
        2
    ) AS avg_review_score
FROM orders o
JOIN reviews r
    ON o.order_id = r.order_id
WHERE order_delivered_customer_date IS NOT NULL;
Review Score by Delivery Time Bucket
SELECT
CASE
    WHEN DATEDIFF(order_delivered_customer_date,
                  order_purchase_timestamp) <= 5
         THEN '0-5 Days'
    WHEN DATEDIFF(order_delivered_customer_date,
                  order_purchase_timestamp) <= 10
         THEN '6-10 Days'
    WHEN DATEDIFF(order_delivered_customer_date,
                  order_purchase_timestamp) <= 20
         THEN '11-20 Days'
    ELSE '20+ Days'
END AS delivery_bucket,
ROUND(AVG(review_score),2) AS avg_review_score
FROM orders o
JOIN reviews r
    ON o.order_id = r.order_id
GROUP BY delivery_bucket
ORDER BY avg_review_score DESC;
Best Categories by Review Score
SELECT
    p.product_category_name,
    ROUND(AVG(r.review_score),2) AS avg_review_score
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN reviews r
    ON oi.order_id = r.order_id
GROUP BY p.product_category_name
ORDER BY avg_review_score DESC
LIMIT 15;
Worst Categories by Review Score
SELECT
    p.product_category_name,
    ROUND(AVG(r.review_score),2) AS avg_review_score
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN reviews r
    ON oi.order_id = r.order_id
GROUP BY p.product_category_name
ORDER BY avg_review_score ASC
LIMIT 15;
Revenue vs Review Score by Seller
SELECT
    oi.seller_id,
    ROUND(SUM(oi.price),2) AS revenue,
    ROUND(AVG(r.review_score),2) AS review_score
FROM order_items oi
JOIN reviews r
    ON oi.order_id = r.order_id
GROUP BY oi.seller_id
ORDER BY revenue DESC;
Top Revenue Months
SELECT
    DATE_FORMAT(order_purchase_timestamp,'%Y-%m') AS month,
    ROUND(SUM(payment_value),2) AS revenue
FROM orders o
JOIN payments p
    ON o.order_id = p.order_id
GROUP BY month
ORDER BY revenue DESC;
Revenue Contribution by Top 10 Categories
WITH category_revenue AS (
    SELECT
        p.product_category_name,
        SUM(oi.price) AS revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY p.product_category_name
)
SELECT
    product_category_name,
    ROUND(revenue,2) AS revenue,
    ROUND(
        revenue /
        SUM(revenue) OVER() * 100,
        2
    ) AS revenue_percentage
FROM category_revenue
ORDER BY revenue DESC
LIMIT 10;
Customer Retention by State
WITH customer_orders AS (
    SELECT
        c.customer_state,
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY
        c.customer_state,
        c.customer_unique_id
)
SELECT
    customer_state,
    ROUND(
        100.0 *
        SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)
        /
        COUNT(*),
        2
    ) AS retention_rate
FROM customer_orders
GROUP BY customer_state
ORDER BY retention_rate DESC;