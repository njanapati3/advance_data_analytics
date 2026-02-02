/*
================================================================================
PART-TO-WHOLE ANALYSIS
================================================================================
Purpose: Analyze individual part performance compared to overall
Outcome: Understand which category has greatest impact on business
Pattern: ([Measure]/Total[Measure])*100 BY [Dimension]
Examples: 
  - (Sales/Total Sales)*100 BY Category
  - (Quantity/Total Quantity)*100 BY Country
================================================================================
*/

-- Which Category contributes the most to overall sales?
WITH category_totals AS (
    SELECT 
        d.category,
        SUM(f.sales_amount) AS total_sales,
        SUM(f.quantity) AS total_quantity
    FROM gold.fact_sales f
    INNER JOIN gold.dim_products d
        ON f.product_key = d.product_key
    GROUP BY d.category
)
SELECT 
    category,
    total_sales,
    total_quantity,
    
    -- Overall total sales
    SUM(total_sales) OVER () AS overall_total_sales,
    
    -- Sales contribution percentage
    ROUND(
        (total_sales * 100.0 / SUM(total_sales) OVER ()), 
        2
    ) AS percentage_contribution,
    
    -- Performance tier based on contribution
    CASE 
        WHEN ROUND((total_sales * 100.0 / SUM(total_sales) OVER ()), 2) >= 30 
            THEN 'Tier 1 - Major Contributor'
        WHEN ROUND((total_sales * 100.0 / SUM(total_sales) OVER ()), 2) >= 15 
            THEN 'Tier 2 - Significant Contributor'
        WHEN ROUND((total_sales * 100.0 / SUM(total_sales) OVER ()), 2) >= 5 
            THEN 'Tier 3 - Moderate Contributor'
        ELSE 'Tier 4 - Minor Contributor'
    END AS contribution_tier,
    
    -- Ranking by sales
    RANK() OVER (ORDER BY total_sales DESC) AS sales_rank

FROM category_totals
ORDER BY percentage_contribution DESC;

-- Country contribution to sales
WITH country_totals AS (
    SELECT 
        c.country,
        SUM(f.sales_amount) AS total_sales,
        SUM(f.quantity) AS total_quantity,
        COUNT(DISTINCT f.customer_key) AS unique_customers
    FROM gold.fact_sales f
    INNER JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.country
)
SELECT 
    country,
    total_sales,
    total_quantity,
    unique_customers,
    SUM(total_sales) OVER () AS overall_sales,
    ROUND((total_sales * 100.0 / SUM(total_sales) OVER ()), 2) AS sales_percentage,
    ROUND((total_quantity * 100.0 / SUM(total_quantity) OVER ()), 2) AS quantity_percentage,
    ROUND((unique_customers * 100.0 / SUM(unique_customers) OVER ()), 2) AS customer_percentage
FROM country_totals
ORDER BY sales_percentage DESC;

-- Product subcategory contribution within categories
WITH subcategory_sales AS (
    SELECT 
        d.category,
        d.subcategory,
        SUM(f.sales_amount) AS subcategory_sales
    FROM gold.fact_sales f
    INNER JOIN gold.dim_products d ON f.product_key = d.product_key
    GROUP BY d.category, d.subcategory
)
SELECT 
    category,
    subcategory,
    subcategory_sales,
    SUM(subcategory_sales) OVER (PARTITION BY category) AS category_total_sales,
    ROUND(
        (subcategory_sales * 100.0 / SUM(subcategory_sales) OVER (PARTITION BY category)), 
        2
    ) AS contribution_within_category,
    ROUND(
        (subcategory_sales * 100.0 / SUM(subcategory_sales) OVER ()), 
        2
    ) AS contribution_to_overall
FROM subcategory_sales
ORDER BY category, contribution_within_category DESC;
