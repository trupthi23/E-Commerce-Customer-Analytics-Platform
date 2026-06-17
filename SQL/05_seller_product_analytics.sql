Which sellers generate the most revenue?
SELECT
    seller_id,
    ROUND(SUM(price),2) AS revenue
FROM order_items
GROUP BY seller_id
ORDER BY revenue DESC
LIMIT 10;
DENSE_RANK()
WITH seller_revenue AS (
    SELECT
        seller_id,
        SUM(price) AS revenue
    FROM order_items
    GROUP BY seller_id
)
SELECT
    seller_id,
    ROUND(revenue,2) AS revenue,
    DENSE_RANK() OVER(
        ORDER BY revenue DESC
    ) AS seller_rank
FROM seller_revenue;

SELECT
    seller_id,
    COUNT(DISTINCT order_id) AS total_orders
FROM order_items
GROUP BY seller_id
ORDER BY total_orders DESC
LIMIT 10;

SELECT
    seller_id,
    ROUND(
        SUM(price) /
        COUNT(DISTINCT order_id),
        2
    ) AS avg_order_value
FROM order_items
GROUP BY seller_id
ORDER BY avg_order_value DESC;
Which sellers generate revenue and maintain good ratings?
SELECT
    oi.seller_id,
    ROUND(SUM(oi.price),2) AS revenue,
    ROUND(AVG(r.review_score),2) AS avg_review_score
FROM order_items oi
JOIN reviews r
    ON oi.order_id = r.order_id
GROUP BY oi.seller_id
ORDER BY revenue DESC;

SELECT
    p.product_category_name,
    ROUND(SUM(oi.price),2) AS revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY revenue DESC
LIMIT 10;
ROW_NUMBER()
WITH product_revenue AS (
    SELECT
        p.product_category_name,
        oi.product_id,
        SUM(oi.price) AS revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY
        p.product_category_name,
        oi.product_id
)
SELECT *
FROM (
    SELECT
        product_category_name,
        product_id,
        revenue,
        ROW_NUMBER() OVER(
            PARTITION BY product_category_name
            ORDER BY revenue DESC
        ) AS rn
    FROM product_revenue
) ranked
WHERE rn = 1;

SELECT
    DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m') AS month,
    ROUND(SUM(oi.price),2) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;
LAG()
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m') AS month,
        SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY month
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER(
        ORDER BY month
    ) AS previous_month_revenue
FROM monthly_revenue;

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m') AS month,
        SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY month
)
SELECT
    month,
    revenue,
    ROUND(
        (
            revenue -
            LAG(revenue) OVER(ORDER BY month)
        )
        /
        LAG(revenue) OVER(ORDER BY month)
        * 100,
        2
    ) AS growth_percentage
FROM monthly_revenue;
SUM() OVER()
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m') AS month,
        SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY month
)
SELECT
    month,
    revenue,
    SUM(revenue)
    OVER(
        ORDER BY month
    ) AS cumulative_revenue
FROM monthly_revenue;