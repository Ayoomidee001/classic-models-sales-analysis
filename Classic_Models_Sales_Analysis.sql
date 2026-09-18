-- ============================================================
-- CLASSIC MODELS SALES ANALYSIS
-- SQL PORTFOLIO PROJECT
-- Database: classicmodels
-- 25 Business-Focused SQL Queries
-- ============================================================

USE classicmodels;


-- ============================================================
-- 1. TOTAL REVENUE
-- ============================================================
SELECT
    ROUND(SUM(quantityOrdered * priceEach), 2) AS total_revenue
FROM orderdetails;


-- ============================================================
-- 2. TOTAL ORDERS
-- ============================================================
SELECT
    COUNT(DISTINCT orderNumber) AS total_orders
FROM orders;


-- ============================================================
-- 3. TOTAL UNITS SOLD
-- ============================================================
SELECT
    SUM(quantityOrdered) AS total_units_sold
FROM orderdetails;


-- ============================================================
-- 4. TOTAL CUSTOMERS
-- ============================================================
SELECT
    COUNT(*) AS total_customers
FROM customers;


-- ============================================================
-- 5. ACTIVE CUSTOMERS
-- ============================================================
-- An active customer is one who has placed at least one order.
SELECT
    COUNT(DISTINCT customerNumber) AS active_customers
FROM orders;


-- ============================================================
-- 6. AVERAGE ORDER VALUE (AOV)
-- ============================================================
-- Average revenue generated per order.
SELECT
    ROUND(
        SUM(quantityOrdered * priceEach)
        / COUNT(DISTINCT orderNumber),
        2
    ) AS average_order_value
FROM orderdetails;


-- ============================================================
-- 7. AVERAGE REVENUE PER CUSTOMER
-- ============================================================
SELECT
    ROUND(
        SUM(od.quantityOrdered * od.priceEach)
        / COUNT(DISTINCT o.customerNumber),
        2
    ) AS average_revenue_per_customer
FROM orders o
JOIN orderdetails od
    ON o.orderNumber = od.orderNumber;


-- ============================================================
-- 8. REVENUE BY PRODUCT LINE
-- ============================================================
SELECT
    p.productLine,
    ROUND(
        SUM(od.quantityOrdered * od.priceEach),
        2
    ) AS revenue
FROM products p
JOIN orderdetails od
    ON p.productCode = od.productCode
GROUP BY p.productLine
ORDER BY revenue DESC;


-- ============================================================
-- 9. TOP PRODUCT LINE
-- ============================================================
SELECT
    p.productLine,
    ROUND(
        SUM(od.quantityOrdered * od.priceEach),
        2
    ) AS revenue
FROM products p
JOIN orderdetails od
    ON p.productCode = od.productCode
GROUP BY p.productLine
ORDER BY revenue DESC
LIMIT 1;


-- ============================================================
-- 10. TOP 10 CUSTOMERS BY REVENUE
-- ============================================================
SELECT
    c.customerNumber,
    c.customerName,
    ROUND(
        SUM(od.quantityOrdered * od.priceEach),
        2
    ) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customerNumber = o.customerNumber
JOIN orderdetails od
    ON o.orderNumber = od.orderNumber
GROUP BY
    c.customerNumber,
    c.customerName
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- 11. TOP CUSTOMER
-- ============================================================
SELECT
    c.customerNumber,
    c.customerName,
    ROUND(
        SUM(od.quantityOrdered * od.priceEach),
        2
    ) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customerNumber = o.customerNumber
JOIN orderdetails od
    ON o.orderNumber = od.orderNumber
GROUP BY
    c.customerNumber,
    c.customerName
ORDER BY total_revenue DESC
LIMIT 1;


-- ============================================================
-- 12. REVENUE BY COUNTRY
-- ============================================================
SELECT
    c.country,
    ROUND(
        SUM(od.quantityOrdered * od.priceEach),
        2
    ) AS revenue
FROM customers c
JOIN orders o
    ON c.customerNumber = o.customerNumber
JOIN orderdetails od
    ON o.orderNumber = od.orderNumber
GROUP BY c.country
ORDER BY revenue DESC;


-- ============================================================
-- 13. REVENUE PER CUSTOMER BY COUNTRY
-- ============================================================
SELECT
    c.country,
    COUNT(DISTINCT c.customerNumber) AS customers,
    ROUND(
        SUM(od.quantityOrdered * od.priceEach),
        2
    ) AS revenue,
    ROUND(
        SUM(od.quantityOrdered * od.priceEach)
        / COUNT(DISTINCT c.customerNumber),
        2
    ) AS revenue_per_customer
FROM customers c
JOIN orders o
    ON c.customerNumber = o.customerNumber
JOIN orderdetails od
    ON o.orderNumber = od.orderNumber
GROUP BY c.country
ORDER BY revenue_per_customer DESC;


-- ============================================================
-- 14. ORDERS BY MONTH
-- ============================================================
SELECT
    DATE_FORMAT(orderDate, '%Y-%m') AS month,
    COUNT(*) AS total_orders
FROM orders
GROUP BY DATE_FORMAT(orderDate, '%Y-%m')
ORDER BY month;


-- ============================================================
-- 15. REVENUE BY MONTH
-- ============================================================
SELECT
    DATE_FORMAT(o.orderDate, '%Y-%m') AS month,
    ROUND(
        SUM(od.quantityOrdered * od.priceEach),
        2
    ) AS revenue
FROM orders o
JOIN orderdetails od
    ON o.orderNumber = od.orderNumber
GROUP BY DATE_FORMAT(o.orderDate, '%Y-%m')
ORDER BY month;


-- ============================================================
-- 16. REVENUE BY YEAR
-- ============================================================
SELECT
    YEAR(o.orderDate) AS year,
    ROUND(
        SUM(od.quantityOrdered * od.priceEach),
        2
    ) AS revenue
FROM orders o
JOIN orderdetails od
    ON o.orderNumber = od.orderNumber
GROUP BY YEAR(o.orderDate)
ORDER BY year;


-- ============================================================
-- 17. MONTH-OVER-MONTH REVENUE GROWTH
-- ============================================================
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.orderDate, '%Y-%m') AS month,
        SUM(od.quantityOrdered * od.priceEach) AS revenue
    FROM orders o
    JOIN orderdetails od
        ON o.orderNumber = od.orderNumber
    GROUP BY DATE_FORMAT(o.orderDate, '%Y-%m')
),
revenue_with_previous AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY month
        ) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,
    ROUND(
        (revenue - previous_month_revenue)
        / previous_month_revenue * 100,
        2
    ) AS mom_growth_percentage
FROM revenue_with_previous
ORDER BY month;


-- ============================================================
-- 18. REVENUE BY SALES REPRESENTATIVE
-- ============================================================
SELECT
    e.employeeNumber,
    CONCAT(e.firstName, ' ', e.lastName) AS sales_rep,
    COUNT(DISTINCT c.customerNumber) AS customers_managed,
    ROUND(
        SUM(od.quantityOrdered * od.priceEach),
        2
    ) AS total_revenue
FROM employees e
JOIN customers c
    ON e.employeeNumber = c.salesRepEmployeeNumber
JOIN orders o
    ON c.customerNumber = o.customerNumber
JOIN orderdetails od
    ON o.orderNumber = od.orderNumber
GROUP BY
    e.employeeNumber,
    e.firstName,
    e.lastName
ORDER BY total_revenue DESC;


-- ============================================================
-- 19. TOP 10 PRODUCTS BY REVENUE
-- ============================================================
SELECT
    p.productCode,
    p.productName,
    p.productLine,
    ROUND(
        SUM(od.quantityOrdered * od.priceEach),
        2
    ) AS revenue
FROM products p
JOIN orderdetails od
    ON p.productCode = od.productCode
GROUP BY
    p.productCode,
    p.productName,
    p.productLine
ORDER BY revenue DESC
LIMIT 10;


-- ============================================================
-- 20. TOP 10 PRODUCTS BY UNITS SOLD
-- ============================================================
SELECT
    p.productCode,
    p.productName,
    p.productLine,
    SUM(od.quantityOrdered) AS units_sold
FROM products p
JOIN orderdetails od
    ON p.productCode = od.productCode
GROUP BY
    p.productCode,
    p.productName,
    p.productLine
ORDER BY units_sold DESC
LIMIT 10;


-- ============================================================
-- 21. ORDER STATUS DISTRIBUTION
-- ============================================================
SELECT
    status,
    COUNT(*) AS number_of_orders,
    ROUND(
        COUNT(*) * 100.0
        / (SELECT COUNT(*) FROM orders),
        2
    ) AS percentage_of_orders
FROM orders
GROUP BY status
ORDER BY number_of_orders DESC;


-- ============================================================
-- 22. AVERAGE FULFILLMENT TIME
-- ============================================================
SELECT
    ROUND(
        AVG(DATEDIFF(shippedDate, orderDate)),
        2
    ) AS average_fulfillment_days
FROM orders
WHERE shippedDate IS NOT NULL;


-- ============================================================
-- 23. FULFILLMENT TIME BY PRODUCT LINE
-- ============================================================
SELECT
    p.productLine,
    ROUND(
        AVG(DATEDIFF(o.shippedDate, o.orderDate)),
        2
    ) AS average_fulfillment_days
FROM orders o
JOIN orderdetails od
    ON o.orderNumber = od.orderNumber
JOIN products p
    ON od.productCode = p.productCode
WHERE o.shippedDate IS NOT NULL
GROUP BY p.productLine
ORDER BY average_fulfillment_days DESC;


-- ============================================================
-- 24. CUSTOMERS WITH OUTSTANDING CREDIT EXPOSURE
-- ============================================================
-- Uses credit limit less recorded customer payments as a
-- portfolio-level exposure indicator.
SELECT
    c.customerNumber,
    c.customerName,
    c.creditLimit,
    COALESCE(SUM(p.amount), 0) AS total_payments,
    ROUND(
        c.creditLimit - COALESCE(SUM(p.amount), 0),
        2
    ) AS outstanding_credit_exposure
FROM customers c
LEFT JOIN payments p
    ON c.customerNumber = p.customerNumber
GROUP BY
    c.customerNumber,
    c.customerName,
    c.creditLimit
ORDER BY outstanding_credit_exposure DESC;


-- ============================================================
-- 25. CUSTOMER CONCENTRATION — TOP 10 CUSTOMERS' REVENUE %
-- ============================================================
-- Measures how much of total revenue comes from the top 10
-- revenue-generating customers.
WITH customer_revenue AS (
    SELECT
        c.customerNumber,
        c.customerName,
        SUM(od.quantityOrdered * od.priceEach) AS revenue
    FROM customers c
    JOIN orders o
        ON c.customerNumber = o.customerNumber
    JOIN orderdetails od
        ON o.orderNumber = od.orderNumber
    GROUP BY
        c.customerNumber,
        c.customerName
),
ranked_customers AS (
    SELECT
        customerNumber,
        customerName,
        revenue,
        RANK() OVER (
            ORDER BY revenue DESC
        ) AS revenue_rank
    FROM customer_revenue
)
SELECT
    ROUND(
        SUM(revenue)
        / (SELECT SUM(revenue) FROM customer_revenue)
        * 100,
        2
    ) AS top_10_customer_revenue_percentage
FROM ranked_customers
WHERE revenue_rank <= 10;


-- ============================================================
-- END OF CLASSIC MODELS SALES ANALYSIS
-- ============================================================
