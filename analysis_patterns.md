# SQL Analysis Patterns Guide

## Overview
This document outlines common SQL analysis patterns used in exploratory data analysis (EDA) for business intelligence.

---

## 1. Magnitude Analysis

### Pattern
```
[Aggregation Function] [Measure] BY [Dimension]
```

### Common Aggregations
- `SUM()` - Total values
- `AVG()` - Average values
- `COUNT()` - Count of records
- `MIN()` / `MAX()` - Extreme values

### Examples

**Total Sales BY Country**
```sql
SELECT 
    country,
    SUM(sales_amount) AS total_sales
FROM sales_data
GROUP BY country
ORDER BY total_sales DESC;
```

**Average Price BY Product Category**
```sql
SELECT 
    category,
    AVG(price) AS avg_price
FROM products
GROUP BY category;
```

**Total Quantity BY Region**
```sql
SELECT 
    region,
    SUM(quantity) AS total_quantity
FROM sales
GROUP BY region;
```

---

## 2. Ranking Analysis

### Pattern
```
Rank [Dimension] BY [Aggregation] [Measure]
```

### Types
- **Top N**: Best performers
- **Bottom N**: Worst performers
- **Full Ranking**: All values ordered

### Examples

**TOP 5 Products BY Revenue**
```sql
SELECT TOP 5 
    product_name,
    SUM(sales_amount) AS total_revenue
FROM sales
GROUP BY product_name
ORDER BY total_revenue DESC;
```

**BOTTOM 3 Customers BY Order Count**
```sql
SELECT TOP 3 
    customer_name,
    COUNT(order_id) AS order_count
FROM orders
GROUP BY customer_name
ORDER BY order_count ASC;
```

**Rank Countries BY Sales with RANK()**
```sql
SELECT 
    country,
    SUM(sales_amount) AS total_sales,
    RANK() OVER (ORDER BY SUM(sales_amount) DESC) AS sales_rank
FROM sales
GROUP BY country;
```

---

## 3. Temporal Analysis

### Pattern
```
[Aggregation] [Measure] BY [Time Period]
```

### Common Time Periods
- Year: `YEAR(date_column)`
- Quarter: `DATEPART(QUARTER, date_column)`
- Month: `MONTH(date_column)`
- Week: `DATEPART(WEEK, date_column)`
- Day of Week: `DATENAME(WEEKDAY, date_column)`

### Examples

**Sales BY Year**
```sql
SELECT 
    YEAR(order_date) AS year,
    SUM(sales_amount) AS total_sales
FROM sales
GROUP BY YEAR(order_date)
ORDER BY year;
```

**Monthly Trend**
```sql
SELECT 
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    SUM(sales_amount) AS monthly_sales
FROM sales
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month;
```

---

## 4. Comparative Analysis

### Pattern
```
Compare [Metric] BETWEEN [Dimension Values]
```

### Examples

**Year-over-Year Comparison**
```sql
SELECT 
    product_category,
    SUM(CASE WHEN YEAR(order_date) = 2024 THEN sales_amount ELSE 0 END) AS sales_2024,
    SUM(CASE WHEN YEAR(order_date) = 2025 THEN sales_amount ELSE 0 END) AS sales_2025,
    SUM(CASE WHEN YEAR(order_date) = 2025 THEN sales_amount ELSE 0 END) - 
    SUM(CASE WHEN YEAR(order_date) = 2024 THEN sales_amount ELSE 0 END) AS yoy_change
FROM sales
GROUP BY product_category;
```

---

## 5. Distribution Analysis

### Pattern
```
Distribution of [Measure] ACROSS [Dimension]
```

### Examples

**Customer Distribution BY Country**
```sql
SELECT 
    country,
    COUNT(customer_id) AS customer_count,
    COUNT(customer_id) * 100.0 / SUM(COUNT(customer_id)) OVER () AS percentage
FROM customers
GROUP BY country
ORDER BY customer_count DESC;
```

**Sales Concentration**
```sql
SELECT 
    product_name,
    SUM(sales_amount) AS product_sales,
    SUM(SUM(sales_amount)) OVER () AS total_sales,
    SUM(sales_amount) * 100.0 / SUM(SUM(sales_amount)) OVER () AS sales_percentage,
    SUM(SUM(sales_amount) * 100.0 / SUM(SUM(sales_amount)) OVER ()) 
        OVER (ORDER BY SUM(sales_amount) DESC) AS cumulative_percentage
FROM sales
GROUP BY product_name
ORDER BY product_sales DESC;
```

---

## 6. Cohort Analysis

### Pattern
```
Analyze [Measure] BY [Cohort Definition]
```

### Example

**Customer Cohort BY First Purchase Year**
```sql
WITH customer_cohorts AS (
    SELECT 
        customer_id,
        YEAR(MIN(order_date)) AS cohort_year
    FROM orders
    GROUP BY customer_id
)
SELECT 
    cc.cohort_year,
    COUNT(DISTINCT cc.customer_id) AS cohort_size,
    SUM(o.sales_amount) AS total_revenue
FROM customer_cohorts cc
JOIN orders o ON cc.customer_id = o.customer_id
GROUP BY cc.cohort_year
ORDER BY cc.cohort_year;
```

---

## 7. Dimensional Drill-Down

### Pattern
```
High-level [Dimension 1] → Detailed [Dimension 2] → Granular [Dimension 3]
```

### Example

**Category → Subcategory → Product**
```sql
-- Level 1: Category
SELECT category, SUM(sales_amount) AS total_sales
FROM products p JOIN sales s ON p.product_id = s.product_id
GROUP BY category;

-- Level 2: Subcategory
SELECT category, subcategory, SUM(sales_amount) AS total_sales
FROM products p JOIN sales s ON p.product_id = s.product_id
GROUP BY category, subcategory;

-- Level 3: Product
SELECT category, subcategory, product_name, SUM(sales_amount) AS total_sales
FROM products p JOIN sales s ON p.product_id = s.product_id
GROUP BY category, subcategory, product_name;
```

---

## Best Practices

### 1. **Use DISTINCT for Counting Unique Values**
```sql
-- WRONG
SELECT COUNT(order_id) FROM orders;

-- CORRECT (when orders can have multiple lines)
SELECT COUNT(DISTINCT order_number) FROM orders;
```

### 2. **Handle NULL Values**
```sql
SELECT 
    COALESCE(country, 'Unknown') AS country,
    COUNT(*) AS customer_count
FROM customers
GROUP BY country;
```

### 3. **Use Window Functions for Advanced Analytics**
```sql
SELECT 
    product_name,
    sales_amount,
    RANK() OVER (ORDER BY sales_amount DESC) AS sales_rank,
    SUM(sales_amount) OVER () AS total_sales,
    sales_amount * 100.0 / SUM(sales_amount) OVER () AS percentage_of_total
FROM product_sales;
```

### 4. **Optimize with CTEs for Readability**
```sql
WITH monthly_sales AS (
    SELECT 
        YEAR(order_date) AS year,
        MONTH(order_date) AS month,
        SUM(sales_amount) AS total_sales
    FROM sales
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT 
    year,
    month,
    total_sales,
    AVG(total_sales) OVER (PARTITION BY year ORDER BY month ROWS 2 PRECEDING) AS rolling_3mo_avg
FROM monthly_sales;
```

---

## Common Gotchas

1. **Integer Division**: Use `* 1.0` or `CAST` to avoid integer division
2. **NULL in Aggregations**: `SUM()`, `AVG()` ignore NULLs, but `COUNT(*)` includes them
3. **Date Comparisons**: Be careful with time zones and time portions
4. **String Comparisons**: Remember case sensitivity settings
5. **Join Performance**: Always check execution plans for large datasets

---

## Additional Resources

- SQL Server Documentation: https://docs.microsoft.com/sql/
- Window Functions Guide: https://docs.microsoft.com/sql/t-sql/queries/select-over-clause-transact-sql
- Query Optimization: https://docs.microsoft.com/sql/relational-databases/performance/
