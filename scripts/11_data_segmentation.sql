/*
================================================================================
DATA SEGMENTATION
================================================================================
Purpose: Group data based on specific ranges
Outcome: Understand correlation between two measures
Pattern: [Measure] BY [Measure]
Examples: Total Products BY Sales Range, Total Customers BY Age
================================================================================
*/

-- Segment products into cost ranges and count products in each segment
WITH ProductSegments AS (
    SELECT 
        product_key,
        product_name,
        cost,
        CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS CostRange
    FROM gold.dim_products
)
SELECT 
    CostRange,
    COUNT(*) AS ProductsTotal,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM ProductSegments
GROUP BY CostRange
ORDER BY ProductsTotal DESC;

/*
Group customers into three segments based on spending behavior:
    - VIP: Customers with at least 12 months of history and spending more than €5,000
    - Regular: Customers with at least 12 months of history but spending €5,000 or less
    - New: Customers with lifespan less than 12 months
Find total number of customers by each group
*/
WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT 
    customer_segment,
    COUNT(customer_key) AS total_customers,
    ROUND(COUNT(customer_key) * 100.0 / SUM(COUNT(customer_key)) OVER (), 2) AS percentage,
    SUM(total_spending) AS segment_revenue,
    AVG(total_spending) AS avg_customer_value
FROM (
    SELECT 
        customer_key,
        total_spending,
        CASE 
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) AS segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;

-- Age-based customer segmentation
WITH customer_ages AS (
    SELECT
        customer_key,
        FLOOR(DATEDIFF(DAY, birth_date, GETDATE()) / 365.25) AS age
    FROM gold.dim_customers
)
SELECT 
    CASE 
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        WHEN age BETWEEN 50 AND 59 THEN '50-59'
        ELSE '60 and above'
    END AS age_group,
    COUNT(customer_key) AS total_customers,
    ROUND(COUNT(customer_key) * 100.0 / SUM(COUNT(customer_key)) OVER (), 2) AS percentage
FROM customer_ages
GROUP BY 
    CASE 
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        WHEN age BETWEEN 50 AND 59 THEN '50-59'
        ELSE '60 and above'
    END
ORDER BY age_group;

-- Sales amount segmentation
WITH order_segments AS (
    SELECT 
        order_number,
        SUM(sales_amount) AS order_total,
        CASE 
            WHEN SUM(sales_amount) < 100 THEN 'Small Order (<100)'
            WHEN SUM(sales_amount) BETWEEN 100 AND 500 THEN 'Medium Order (100-500)'
            WHEN SUM(sales_amount) BETWEEN 500 AND 1000 THEN 'Large Order (500-1000)'
            ELSE 'Very Large Order (>1000)'
        END AS order_size_category
    FROM gold.fact_sales
    GROUP BY order_number
)
SELECT 
    order_size_category,
    COUNT(*) AS order_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage,
    SUM(order_total) AS total_revenue,
    AVG(order_total) AS avg_order_value
FROM order_segments
GROUP BY order_size_category
ORDER BY avg_order_value DESC;
