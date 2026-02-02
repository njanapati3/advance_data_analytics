/*
================================================================================
CHANGE-OVER-TIME TRENDS ANALYSIS
================================================================================
Purpose: Analyze how measures evolve over time
Outcome: Track trends and identify seasonality in your data
Pattern: [Aggregation] [Measure] BY [Date Dimension]
Examples: Total Sales BY Year, Average Cost BY Month
================================================================================
*/

-- Analyze sales performance over time [Year]
SELECT 
    YEAR(order_date) AS OrderYear,
    SUM(sales_amount) AS TotalRevenue,
    COUNT(DISTINCT customer_key) AS TotalCustomers,
    SUM(quantity) AS TotalQuantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);

-- Analyze sales performance over time [Month]
SELECT 
    MONTH(order_date) AS OrderMonth,
    SUM(sales_amount) AS TotalRevenue,
    COUNT(DISTINCT customer_key) AS TotalCustomers,
    SUM(quantity) AS TotalQuantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date)
ORDER BY MONTH(order_date);

-- Analyze sales performance over time [Year, Month]
SELECT 
    YEAR(order_date) AS OrderYear,
    MONTH(order_date) AS OrderMonth,
    SUM(sales_amount) AS TotalRevenue,
    COUNT(DISTINCT customer_key) AS TotalCustomers,
    SUM(quantity) AS TotalQuantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);

-- Analyze sales performance over time [Year, Month] - Using DATETRUNC
SELECT 
    DATETRUNC(month, order_date) AS OrderDate,
    SUM(sales_amount) AS TotalRevenue,
    COUNT(DISTINCT customer_key) AS TotalCustomers,
    SUM(quantity) AS TotalQuantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date);

-- Analyze sales performance over time [Year] - Using DATETRUNC
SELECT 
    DATETRUNC(year, order_date) AS OrderDate,
    SUM(sales_amount) AS TotalRevenue,
    COUNT(DISTINCT customer_key) AS TotalCustomers,
    SUM(quantity) AS TotalQuantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(year, order_date)
ORDER BY DATETRUNC(year, order_date);

-- Analyze sales performance over time [Year-Month] - Using FORMAT
SELECT 
    FORMAT(order_date, 'yyyy-MMM') AS OrderDate,
    SUM(sales_amount) AS TotalRevenue,
    COUNT(DISTINCT customer_key) AS TotalCustomers,
    SUM(quantity) AS TotalQuantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY FORMAT(order_date, 'yyyy-MMM');
