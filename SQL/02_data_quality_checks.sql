SELECT COUNT(*) AS customers_count FROM customers;
SELECT COUNT(*) AS orders_count FROM orders;
SELECT COUNT(*) AS order_items_count FROM order_items;
SELECT COUNT(*) AS products_count FROM products;
SELECT COUNT(*) AS sellers_count FROM sellers;
SELECT COUNT(*) AS reviews_count FROM reviews;

SELECT customer_id,
       COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;
SELECT order_id,
       COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;
SELECT seller_id,
       COUNT(*) AS duplicate_count
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

SELECT
SUM(order_id IS NULL) AS order_id_nulls,
SUM(customer_id IS NULL) AS customer_id_nulls
FROM orders;
SELECT
SUM(product_category_name IS NULL) AS category_nulls
FROM products;

ALTER TABLE customers
ADD PRIMARY KEY (customer_id);
ALTER TABLE orders
ADD PRIMARY KEY (order_id);
ALTER TABLE products
ADD PRIMARY KEY (product_id);
ALTER TABLE sellers
ADD PRIMARY KEY (seller_id);
ALTER TABLE reviews
ADD PRIMARY KEY (review_id);

ALTER TABLE orders
ADD CONSTRAINT fk_orders_customers
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);
SELECT COUNT(*)
FROM order_items oi
LEFT JOIN orders o
ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*)
FROM orders
WHERE order_purchase_timestamp IS NULL;
SELECT *
FROM orders
LIMIT 10;
SELECT COUNT(*)
FROM customers;
SELECT COUNT(*)
FROM orders
WHERE customer_id IS NULL;

DROP TABLE orders;
CREATE TABLE orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);
SELECT COUNT(*) FROM orders;