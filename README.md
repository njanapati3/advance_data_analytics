# Sales Data Analysis - SQL Exploratory Scripts

A comprehensive SQL script collection for exploratory data analysis (EDA) on a sales database with dimensional modeling (star schema).

## 📊 Database Schema

This project works with a **gold layer** data warehouse following the star schema pattern:

### Fact Table
- `gold.fact_sales` - Contains transactional sales data

### Dimension Tables
- `gold.dim_customers` - Customer information
- `gold.dim_products` - Product catalog and hierarchy
- `gold.dim_dates` - Date dimensions (implied)

## 🎯 Analysis Categories

### 1. **Schema Exploration**
- Database structure analysis
- Table and column discovery
- Understanding data models

### 2. **Dimension Exploration**
- Unique value identification
- Data categorization and segmentation
- Product hierarchy analysis (Category → Subcategory → Product)

### 3. **Date Range Analysis**
- Temporal boundaries identification
- Data timespan calculation
- Customer age demographics

### 4. **Key Performance Indicators (KPIs)**
- Total Sales Amount
- Total Quantity Sold
- Average Selling Price
- Total Orders
- Total Products
- Total Customers
- Active Customers (who placed orders)

### 5. **Magnitude Analysis**
- Sales by Country
- Customers by Gender
- Products by Category
- Revenue by Category
- Revenue by Customer
- Sales Distribution across Countries

### 6. **Ranking Analysis**
- Top 5 Revenue-Generating Products
- Bottom 5 Performing Products
- Customer ranking by revenue

### 7. **Temporal Trends Analysis**
- Sales performance over time (Year, Month, Quarter)
- Time-based aggregations using DATETRUNC and FORMAT
- Seasonality identification

### 8. **Cumulative Analysis**
- Running totals and cumulative sums
- Moving averages
- Progressive growth tracking

### 9. **Performance Analysis**
- Year-over-year comparisons
- Month-over-month growth
- Variance from targets/averages
- Trend categorization

### 10. **Part-to-Whole Analysis**
- Category contribution to total sales
- Percentage breakdowns
- Pareto analysis (80/20 rule)

### 11. **Data Segmentation**
- Customer segmentation (VIP, Regular, New)
- Product cost range analysis
- Age-based demographics
- Order size categorization

### 12. **Reporting Views**
- Customer 360-degree view (RFM analysis)
- Product performance dashboard
- Automated reporting layer

## 📁 Project Structure

```
sql-sales-analysis/
│
├── README.md                          # Project documentation
├── scripts/
│   ├── 00_full_eda_script.sql         # Complete initial analysis
│   ├── 01_schema_exploration.sql      # Database structure queries
│   ├── 02_dimension_exploration.sql   # Dimension analysis
│   ├── 03_date_exploration.sql        # Date range analysis
│   ├── 04_measures_kpis.sql           # Key metrics calculation
│   ├── 05_magnitude_analysis.sql      # Aggregation queries
│   ├── 06_ranking_analysis.sql        # Top/Bottom performers
│   ├── 07_temporal_trends.sql         # Time-series analysis
│   ├── 08_cumulative_analysis.sql     # Running totals & moving averages
│   ├── 09_performance_analysis.sql    # YoY/MoM comparisons
│   ├── 10_part_to_whole_analysis.sql  # Contribution analysis
│   ├── 11_data_segmentation.sql       # Customer & product segmentation
│   └── 12_reporting_views.sql         # Gold layer reporting views
│
├── docs/
│   └── analysis_patterns.md           # SQL patterns and techniques
│
├── CONTRIBUTING.md                    # Contribution guidelines
├── LICENSE                            # MIT License
└── .gitignore                         # Git ignore rules
```

## 🚀 Getting Started

### Prerequisites
- SQL Server database
- Access to the `gold` schema with appropriate permissions
- SQL Server Management Studio (SSMS) or Azure Data Studio

### Running the Scripts

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/sql-sales-analysis.git
   cd sql-sales-analysis
   ```

2. **Execute scripts in order**
   - Start with `00_full_eda_script.sql` for complete analysis
   - Or run individual scripts from the `scripts/` folder

3. **Customize for your database**
   - Update schema names if different from `gold`
   - Modify table names to match your database structure

## 📈 Key Queries

### Executive Summary Report
Generates a consolidated view of all business KPIs in a single result set:
```sql
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value 
FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM gold.fact_sales
-- ... additional metrics
```

### Top Revenue Products
```sql
SELECT TOP 5 dp.product_name, SUM(fs.sales_amount) AS total_revenue
FROM gold.fact_sales fs
INNER JOIN gold.dim_products dp ON fs.product_key = dp.product_key
GROUP BY dp.product_name
ORDER BY total_revenue DESC
```

### Year-over-Year Growth Analysis
```sql
WITH yearly_sales AS (
    SELECT 
        YEAR(order_date) AS year,
        product_name,
        SUM(sales_amount) AS current_year_sales
    FROM gold.fact_sales f
    JOIN gold.dim_products p ON f.product_key = p.product_key
    GROUP BY YEAR(order_date), product_name
)
SELECT 
    year,
    product_name,
    current_year_sales,
    LAG(current_year_sales) OVER (PARTITION BY product_name ORDER BY year) AS prev_year_sales,
    current_year_sales - LAG(current_year_sales) OVER (PARTITION BY product_name ORDER BY year) AS yoy_change
FROM yearly_sales
```

### Customer Segmentation (RFM)
```sql
SELECT 
    customer_key,
    CASE 
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,
    total_orders,
    total_sales,
    avg_order_value
FROM gold.report_customers
```

## 🔍 Analysis Patterns

### Magnitude Analysis Pattern
```
[Aggregation] [Measure] BY [Dimension]
```
Examples:
- Total Sales BY Country
- Total Quantity BY Category
- Average Price BY Product

### Ranking Analysis Pattern
```
Rank [Dimension] BY [Aggregation] [Measure]
```
Examples:
- Rank Countries BY Total Sales
- TOP 5 Products BY Quantity
- Bottom 3 Customers BY Total Orders

## 📝 Notes

- **Distinct Count for Orders**: Always use `COUNT(DISTINCT order_number)` as orders may contain multiple line items
- **Customer Segmentation**: Distinguishes between total customers and customers who have placed orders
- **Date Calculations**: Uses `DATEDIFF` for temporal analysis and age calculations

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

Narendra Janapati

## 🙏 Acknowledgments

- Designed for SQL Server databases
- Follows dimensional modeling best practices
- Based on star schema data warehouse patterns

---

**Note**: Remember to update connection strings and schema names according to your specific database environment.
