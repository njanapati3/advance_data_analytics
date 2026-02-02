/*
================================================================================
SALES DATA ANALYSIS - COMPLETE EXPLORATORY DATA ANALYSIS (EDA)
================================================================================
Purpose: Comprehensive exploration of sales database with dimensional modeling
Database: SQL Server
Schema: gold (star schema - fact_sales, dim_customers, dim_products)
Author: Your Name
Date: 2026-02-01
================================================================================
*/

-- ============================================================================
-- SECTION 1: SCHEMA EXPLORATION
-- ============================================================================
-- Purpose: Understand database structure and available objects

-- Explore All Objects in the database
SELECT * FROM INFORMATION_SCHEMA.TABLES;

-- Explore All Columns in the database
SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'dim_customers';


-- ============================================================================
-- SECTION 2: DIMENSIONS EXPLORATION
-- ============================================================================
-- Purpose: Identifying unique values (or categories) in each dimension
-- Outcome: Recognizing how data might be grouped or segmented

-- Explore All Countries our customers come from
SELECT DISTINCT country 
FROM gold.dim_customers;

-- Explore all product categories (the major divisions)
SELECT DISTINCT category 
FROM gold.dim_products;

-- Explore all product categories, sub-category (the major divisions)
SELECT DISTINCT 
    category,
    subcategory,
    product_name 
FROM gold.dim_products
ORDER BY 1, 2, 3;


-- ============================================================================
-- SECTION 3: DATE EXPLORATION
-- ============================================================================
-- Purpose: Identify the earliest and latest dates (boundaries)
-- Outcome: Understand the scope of data and the timespan

-- Find the date of the first and last order
SELECT 
    MIN(order_date) AS MinDate, 
    MAX(order_date) AS MaxDate, 
    DATEDIFF(year, MIN(order_date), MAX(order_date)) AS DateDiffYears
FROM gold.fact_sales;

-- Find the youngest and oldest customer
SELECT 
    MIN(birth_date) AS OldCustBdate, 
    DATEDIFF(year, MIN(birth_date), GETDATE()) AS OldCustAge, 
    MAX(birth_date) AS YoungCustBdate, 
    DATEDIFF(year, MAX(birth_date), GETDATE()) AS YoungCustAge
FROM gold.dim_customers;


-- ============================================================================
-- SECTION 4: MEASURES EXPLORATION - KEY PERFORMANCE INDICATORS (KPIs)
-- ============================================================================
-- Purpose: Calculate the key metrics of the business (Big Numbers)
-- Level: Highest Level of Aggregation | Lowest level of details

-- Find the total sales
SELECT SUM(sales_amount) AS TotalSalesAmount 
FROM gold.fact_sales;

-- Find how many items are sold
SELECT SUM(quantity) AS TotalItems 
FROM gold.fact_sales;

-- Find the average selling price
SELECT AVG(price) AS AvgSellingPrice 
FROM gold.fact_sales;

-- Find the total number of orders
-- Note: Same order can have multiple products, so entries would be repeated
SELECT COUNT(order_number) AS TotalOrders 
FROM gold.fact_sales;

-- Correct way - using DISTINCT
SELECT COUNT(DISTINCT order_number) AS TotalOrders 
FROM gold.fact_sales;

-- Find the total number of products
SELECT COUNT(product_key) AS TotalProducts 
FROM gold.dim_products;

-- Correct way - using DISTINCT
SELECT COUNT(DISTINCT product_key) AS TotalProducts 
FROM gold.dim_products;

-- Find the total number of customers
SELECT COUNT(customer_key) AS TotalCustomers 
FROM gold.dim_customers;

-- Find the total number of customers that have placed an order
SELECT COUNT(DISTINCT fs.customer_key) AS TotalCustomersPlacedOrder
FROM gold.dim_customers dc 
INNER JOIN gold.fact_sales fs ON dc.customer_key = fs.customer_key;

-- Alternative approach
SELECT COUNT(DISTINCT fs.customer_key) AS TotalCustomersPlacedOrder
FROM gold.fact_sales fs;


-- ============================================================================
-- EXECUTIVE SUMMARY REPORT
-- ============================================================================
-- Purpose: Aggregates all high-level business KPIs into a single key-value result set

SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value 
FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) 
FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) 
FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) 
FROM gold.fact_sales
UNION ALL
SELECT 'Total Products', COUNT(DISTINCT product_key) 
FROM gold.dim_products
UNION ALL
SELECT 'Total Customers', COUNT(DISTINCT customer_key) 
FROM gold.dim_customers
UNION ALL
SELECT 'Customers Who Ordered', COUNT(DISTINCT customer_key) 
FROM gold.fact_sales;


-- ============================================================================
-- SECTION 5: MAGNITUDE ANALYSIS
-- ============================================================================
-- Pattern: [Aggregation] [Measure] BY [Dimension]
-- Examples: Total Sales BY Country; Total Quantity BY Category; Average Price BY Product

-- Find the total customers by countries
SELECT 
    country,
    COUNT(customer_key) AS TotalCustomers 
FROM gold.dim_customers
GROUP BY country;

-- Find the total customers by gender
SELECT 
    gender,
    COUNT(gender) AS TotalCustomers 
FROM gold.dim_customers
GROUP BY gender;

-- Find total products by category
SELECT 
    category,
    COUNT(category) AS TotalProducts 
FROM gold.dim_products
GROUP BY category;

-- What is the average cost in each category?
SELECT 
    category, 
    AVG(cost) AS AvgCost 
FROM gold.dim_products
GROUP BY category;

-- What is the total revenue generated for each category?
SELECT 
    dp.category, 
    SUM(fs.sales_amount) AS TotalRevenue
FROM gold.fact_sales fs
INNER JOIN gold.dim_products dp ON fs.product_key = dp.product_key
GROUP BY dp.category
ORDER BY TotalRevenue DESC;

-- What is the total revenue generated for each customer?
SELECT 
    dc.customer_key, 
    dc.first_name, 
    dc.last_name, 
    SUM(fs.sales_amount) AS TotalRevenue
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc ON fs.customer_key = dc.customer_key
GROUP BY dc.customer_key, dc.first_name, dc.last_name
ORDER BY TotalRevenue DESC;

-- What is the distribution of sold items across countries?
SELECT 
    dc.country, 
    SUM(quantity) AS TotalItemsSold
FROM gold.dim_customers dc
INNER JOIN gold.fact_sales fs ON dc.customer_key = fs.customer_key
GROUP BY dc.country
ORDER BY TotalItemsSold DESC;


-- ============================================================================
-- SECTION 6: RANKING ANALYSIS
-- ============================================================================
-- Purpose: Order the values of dimensions by measure
-- Pattern: Rank [Dimension] BY [Aggregation] [Measure]
-- Examples: 
--   - Rank Countries BY Total Sales
--   - TOP 5 Products BY Quantity
--   - Bottom 3 Customers BY Total Orders

-- Which 5 Products generate the highest revenue?
SELECT TOP 5 
    dp.product_name, 
    SUM(fs.sales_amount) AS total_revenue
FROM gold.fact_sales fs
INNER JOIN gold.dim_products dp ON fs.product_key = dp.product_key
GROUP BY dp.product_name
ORDER BY total_revenue DESC;

-- What are the 5 worst-performing products in terms of sales quantity?
SELECT TOP 5 
    dp.product_name, 
    SUM(quantity) AS total_sales
FROM gold.fact_sales fs
INNER JOIN gold.dim_products dp ON fs.product_key = dp.product_key
GROUP BY dp.product_name
ORDER BY total_sales ASC;

-- ============================================================================
-- END OF SCRIPT
-- ============================================================================
