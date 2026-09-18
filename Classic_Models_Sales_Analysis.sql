use classicmodels;
SELECT 
    ROUND(SUM(quantityOrdered * priceEach), 
    2) AS total_revenue
FROM orderdetails;

SELECT 
    COUNT(DISTINCT orderNumber) AS total_orders
FROM orders;

SELECT 
    SUM(quantityOrdered) AS total_units_sold
FROM orderdetails;

SELECT 
    COUNT(*) AS total_customers
FROM customers;

SELECT 
    COUNT(DISTINCT customerNumber) AS active_customers
FROM orders;

SELECT 
    ROUND(
        SUM(quantityOrdered * priceEach) 
        / COUNT(DISTINCT orderNumber), 
        2
    ) AS average_order_value
FROM orderdetails;

SELECT 
    ROUND(
        SUM(od.quantityOrdered * od.priceEach) 
        / COUNT(DISTINCT o.customerNumber), 
        2
    ) AS average_revenue_per_customer
FROM orders o
JOIN orderdetails od
    ON o.orderNumber = od.orderNumber;
    
    SELECT 
    p.productLine,
    ROUND(SUM(od.quantityOrdered * od.priceEach), 2) AS revenue
FROM products p
JOIN orderdetails od
    ON p.productCode = od.productCode
GROUP BY p.productLine
ORDER BY revenue DESC;

SELECT 
    p.productLine,
    ROUND(SUM(od.quantityOrdered * od.priceEach), 2) AS revenue
FROM products p
JOIN orderdetails od
    ON p.productCode = od.productCode
GROUP BY p.productLine
ORDER BY revenue DESC
LIMIT 1;

SELECT 
    c.customerNumber,
    c.customerName,
    ROUND(SUM(od.quantityOrdered * od.priceEach), 2) AS total_revenue
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

SELECT 
    c.customerNumber,
    c.customerName,
    ROUND(SUM(od.quantityOrdered * od.priceEach), 2) AS total_revenue
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

SELECT 
    c.country,
    ROUND(SUM(od.quantityOrdered * od.priceEach), 2) AS revenue
FROM customers c
JOIN orders o
    ON c.customerNumber = o.customerNumber
JOIN orderdetails od
    ON o.orderNumber = od.orderNumber
GROUP BY c.country
ORDER BY revenue DESC;

SELECT 
    c.country,
    COUNT(DISTINCT c.customerNumber) AS customers,
    ROUND(SUM(od.quantityOrdered * od.priceEach), 2) AS revenue,
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

SELECT 
    DATE_FORMAT(orderDate, '%Y-%m') AS month,
    COUNT(*) AS total_orders
FROM orders
GROUP BY DATE_FORMAT(orderDate, '%Y-%m')
ORDER BY month;

SELECT 
    DATE_FORMAT(o.orderDate, '%Y-%m') AS month,
    ROUND(SUM(od.quantityOrdered * od.priceEach), 2) AS revenue
FROM orders o
JOIN orderdetails od
    ON o.orderNumber = od.orderNumber
GROUP BY DATE_FORMAT(o.orderDate, '%Y-%m')
ORDER BY month;

SELECT 
    YEAR(o.orderDate) AS year,
    ROUND(SUM(od.quantityOrdered * od.priceEach), 2) AS revenue
FROM orders o
JOIN orderdetails od
    ON o.orderNumber = od.orderNumber
GROUP BY YEAR(o.orderDate)
ORDER BY year;

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
        LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue
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

SELECT 
    e.employeeNumber,
    CONCAT(e.firstName, ' ', e.lastName) AS sales_rep,
    COUNT(DISTINCT c.customerNumber) AS customers_managed,
    ROUND(SUM(od.quantityOrdered * od.priceEach), 2) AS total_revenue
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

SELECT 
    p.productCode,
    p.productName,
    p.productLine,
    SUM(od.quantityOrdered) AS units_sold,
    ROUND(SUM(od.quantityOrdered * od.priceEach), 2) AS revenue
FROM products p
JOIN orderdetails od
    ON p.productCode = od.productCode
GROUP BY 
    p.productCode,
    p.productName,
    p.productLine
ORDER BY revenue DESC
LIMIT 10;

SELECT 
    p.productCode,
    p.productName,
    p.productLine,
    SUM(od.quantityOrdered) AS units_sold,
    ROUND(SUM(od.quantityOrdered * od.priceEach), 2) AS revenue
FROM products p
JOIN orderdetails od
    ON p.productCode = od.productCode
GROUP BY 
    p.productCode,
    p.productName,
    p.productLine
ORDER BY revenue DESC
LIMIT 10;

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

SELECT 
    status,
    COUNT(*) AS number_of_orders,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders),
        2
    ) AS percentage_of_orders
FROM orders
GROUP BY status
ORDER BY number_of_orders DESC;

SELECT 
    ROUND(AVG(DATEDIFF(shippedDate, orderDate)), 2) 
        AS average_fulfillment_days
FROM orders
WHERE shippedDate IS NOT NULL;

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

SELECT 
    c.customerNumber,
    c.customerName,
    c.creditLimit,
    COALESCE(SUM(p.amount), 0) AS total_payments,
    ROUND(
        c.creditLimit - COALESCE(SUM(p.amount), 0),
        2
    ) AS remaining_credit
FROM customers c
LEFT JOIN payments p
    ON c.customerNumber = p.customerNumber
GROUP BY 
    c.customerNumber,
    c.customerName,
    c.creditLimit
ORDER BY remaining_credit DESC;

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
        RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
    FROM customer_revenue
)

SELECT 
    ROUND(
        SUM(revenue) /
        (SELECT SUM(revenue) FROM customer_revenue) * 100,
        2
    ) AS top_10_customer_revenue_percentage
FROM ranked_customers
WHERE revenue_rank <= 10;