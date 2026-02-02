/*
================================================================================
PERFORMANCE ANALYSIS
================================================================================
Purpose: Compare current values to target values
Outcome: Measure success and compare performance
Pattern: Current[Measure] - Target[Measure]
Examples: 
  - Current Sales - Average Sales
  - Current Year Sales - Previous Year Sales
  - Current Sales - Lowest Sales
================================================================================
*/

-- Analyze yearly performance of products by comparing to average and previous year
WITH yearly_sales AS (
    SELECT 
        DATETRUNC(year, f.order_date) AS order_year,
        d.product_name,
        SUM(f.sales_amount) AS current_year_sales
    FROM gold.fact_sales f
    INNER JOIN gold.dim_products d
        ON f.product_key = d.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY 
        DATETRUNC(year, f.order_date),
        d.product_name
)
SELECT 
    order_year,
    product_name,
    current_year_sales,
    
    -- Average sales per product
    AVG(current_year_sales) OVER (
        PARTITION BY product_name
    ) AS avg_sales_per_product,
    
    -- Previous year sales
    COALESCE(
        LAG(current_year_sales) OVER (
            PARTITION BY product_name 
            ORDER BY order_year
        ), 
        0
    ) AS prev_year_sales,
    
    -- Year-over-year sales change
    current_year_sales - COALESCE(
        LAG(current_year_sales) OVER (
            PARTITION BY product_name 
            ORDER BY order_year
        ), 
        0
    ) AS yoy_sales_change,
    
    -- Year-over-year growth percentage
    CASE 
        WHEN LAG(current_year_sales) OVER (PARTITION BY product_name ORDER BY order_year) IS NULL 
            THEN 'First Year'
        WHEN LAG(current_year_sales) OVER (PARTITION BY product_name ORDER BY order_year) = 0 
            THEN 'No Prior Sales'
        ELSE CONCAT(
            ROUND(
                ((current_year_sales - LAG(current_year_sales) OVER (PARTITION BY product_name ORDER BY order_year)) 
                / LAG(current_year_sales) OVER (PARTITION BY product_name ORDER BY order_year) * 100), 
                2
            ), 
            '%'
        )
    END AS yoy_growth_pct,
    
    -- Sales performance category
    CASE 
        WHEN current_year_sales >= AVG(current_year_sales) OVER (PARTITION BY product_name) * 1.2 
            THEN 'Above Average'
        WHEN current_year_sales >= AVG(current_year_sales) OVER (PARTITION BY product_name) * 0.8 
            THEN 'Average'
        ELSE 'Below Average'
    END AS performance_category,
    
    -- Trend indicator
    CASE 
        WHEN LAG(current_year_sales) OVER (PARTITION BY product_name ORDER BY order_year) IS NULL 
            THEN 'N/A'
        WHEN current_year_sales > LAG(current_year_sales) OVER (PARTITION BY product_name ORDER BY order_year) 
            THEN 'Growing'
        WHEN current_year_sales < LAG(current_year_sales) OVER (PARTITION BY product_name ORDER BY order_year) 
            THEN 'Declining'
        ELSE 'Flat'
    END AS sales_trend,
    
    -- Sales tier
    CASE 
        WHEN current_year_sales >= 1000000 THEN 'Tier 1 - High'
        WHEN current_year_sales >= 500000 THEN 'Tier 2 - Medium'
        WHEN current_year_sales >= 100000 THEN 'Tier 3 - Low'
        ELSE 'Tier 4 - Very Low'
    END AS sales_tier

FROM yearly_sales
ORDER BY product_name, order_year;

-- Monthly performance comparison
WITH monthly_sales AS (
    SELECT 
        DATETRUNC(month, order_date) AS order_month,
        SUM(sales_amount) AS monthly_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(month, order_date)
)
SELECT 
    order_month,
    monthly_sales,
    AVG(monthly_sales) OVER () AS overall_avg_sales,
    monthly_sales - AVG(monthly_sales) OVER () AS variance_from_avg,
    LAG(monthly_sales) OVER (ORDER BY order_month) AS prev_month_sales,
    monthly_sales - LAG(monthly_sales) OVER (ORDER BY order_month) AS mom_change
FROM monthly_sales
ORDER BY order_month;
