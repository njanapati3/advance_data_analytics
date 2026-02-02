/*
================================================================================
CUMULATIVE ANALYSIS
================================================================================
Purpose: Aggregate data progressively over time
Outcome: Understand whether business is growing or declining
Pattern: [Aggregation] [Cumulative Measure] BY [Date Dimension]
Examples: Running Total Sales BY Year, Moving Average of Sales BY Month
================================================================================
*/

-- Calculate total sales per month and running total over time
SELECT *,
    SUM(TotalSales) OVER (PARTITION BY OrderMonth ORDER BY OrderMonth) AS YearSpecificCumulativeSum
FROM 
(
    SELECT 
        DATETRUNC(month, order_date) AS OrderMonth,
        SUM(sales_amount) AS TotalSales,
        SUM(SUM(sales_amount)) OVER (ORDER BY DATETRUNC(month, order_date)) AS AllCumulativeSum,
        AVG(AVG(price)) OVER (ORDER BY DATETRUNC(month, order_date)) AS AveragePrice
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(month, order_date)
) t;

-- Year-by-year cumulative sales
SELECT 
    YEAR(order_date) AS OrderYear,
    SUM(sales_amount) AS YearlySales,
    SUM(SUM(sales_amount)) OVER (ORDER BY YEAR(order_date)) AS CumulativeSales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY OrderYear;

-- Monthly running totals with moving averages
SELECT 
    DATETRUNC(month, order_date) AS OrderMonth,
    SUM(sales_amount) AS MonthlySales,
    SUM(SUM(sales_amount)) OVER (ORDER BY DATETRUNC(month, order_date)) AS RunningTotal,
    AVG(SUM(sales_amount)) OVER (
        ORDER BY DATETRUNC(month, order_date) 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS Moving3MonthAvg
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY OrderMonth;
