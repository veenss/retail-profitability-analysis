# Retail Profitability Analysis Dashboard

## 📌 Project Overview
This project analyzes retail sales data to identify key drivers of profitability and uncover areas contributing to financial losses. The dashboard is designed to support business decision-making by highlighting trends, regional performance, discount impact, and loss-making products.

The analysis follows an end-to-end data analytics workflow, from data exploration using SQL to interactive visualization using Power BI.

🔍SQL Queries? Find out here : [project-sql](/project-sql/)

## ❓ Business Problem
Despite strong sales performance, the business experiences inconsistent profitability across regions, products, and discount strategies. Management needs a clear understanding of:
- Where losses are concentrated
- Which products generate high sales but negative profit
- How discounts impact overall profitability
- Which customer segments are most profitable

## 📊 Dataset
- **Source:** [Sample Superstore dataset](/assets/sample-superstore.csv)
- **Time Period:** 2014 – 2017
- **Key Fields:**  
  - Sales  
  - Profit  
  - Order Date  
  - Region & State  
  - Product & Category  
  - Discount  
  - Customer Segment

## 🛠 Tools & Technologies
- **PostgreSQL** – Data aggregation and business logic analysis  
- **Power BI** – Data modeling, DAX measures, and dashboard visualization  
- **DAX** – Explicit measures for consistent KPI calculations  

## 🔍 Analytical Approach
The analysis is structured around key business questions:

1. What is the overall sales and profitability performance?
2. How do sales and profit trends change over time?
3. Which states contribute the most to financial losses?
4. How do different discount levels impact profit margins?
5. Which products generate high sales but negative profit?
6. Which customer segments are the most profitable?

Each query focuses on a specific analytical question:

### 1. Overall Performance
This query identifies the total sales, total profit, profit ratio, and total orders.

```sql
SELECT
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(profit) / SUM(sales), 2) AS profit_ratio
FROM
    sample_superstore
```
Here's the breakdown of overall performance :
- The business generates over 2.29M in sales with a 12% profit margin across nearly 10,000 orders, indicating strong demand and overall profitability, though margin optimization remains a key opportunity.

| Total Sales | Total Profit | Total Orders | Profit Ratio |
|-------------|--------------|--------------|--------------|
|2297201.07   |286397.79     |9994          |0.12          |

### 2. Profit vs Sales Trends
This query analyzes monthly profit vs sales trends.

```sql
SELECT
    TO_CHAR(order_date, 'YYYY-MM') AS month,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_ratio 
FROM
    sample_superstore
GROUP BY
    TO_CHAR(order_date, 'YYYY-MM')
ORDER BY
    TO_CHAR(order_date, 'YYYY-MM')
```
Here's the breakdown of profit vs sales trends :
- **Profit doesn't always follow sales growth** : Several months show high sales but weak or negative profit. On March 2014, it was high sales (~54.8K) but almost zero profit. On July 2014, negative profit despite solid sales.
- Monthly trend analysis shows strong sales growth over time, but profit remains volatile, indicating that increasing sales does not always translate into improved profitability.

![Profit vs Sales Trend](/assets/profit-vs-sales-trend.png)

### 3. Financial Losses by State
This query identifies states with negative profit.

```sql
SELECT
    TO_CHAR(order_date, 'YYYY-MM') AS month,
    region,
    state,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit) / SUM(sales), 2) AS profit_ratio
FROM 
    sample_superstore
GROUP BY 
    TO_CHAR(order_date, 'YYYY-MM'), region, state
HAVING 
    SUM(profit) < 0
ORDER BY 
    TO_CHAR(order_date, 'YYYY-MM') ASC;
```

Here's the breakdown of financial losses by state :
- Business losses are geographically concentrated, with Central and East regions contributing the largest losses. High-sales states such as Texas, Pennsylvania, and Illinois consistently generate negative profit margins, indicating structural profitability issues rather than weak demand.

![Loss Profit States](/assets/loss-profit-states.png)

### 4. Discount Impact
This query evaluates the impact of different discount levels on profitability.

```sql
SELECT
    sub_category,
    CASE
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount > 0 AND discount <= 0.2 THEN 'Low Discount (0-20%)'
        WHEN discount > 0.2 AND discount <= 0.3 THEN 'Medium Discount (21-30%)'
        ELSE 'High Discount (>30%)'
    END AS discount_group,
    COUNT(*) AS total_transactions,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit) / SUM(sales), 2) AS profit_ratio
FROM sample_superstore
GROUP BY
    sub_category,
    CASE
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount > 0 AND discount <= 0.2 THEN 'Low Discount (0-20%)'
        WHEN discount > 0.2 AND discount <= 0.3 THEN 'Medium Discount (21-30%)'
        ELSE 'High Discount (>30%)'
    END
ORDER BY
    sub_category,
    profit_ratio DESC;
```
Here's the breakdown of discount impact :
- Profitability declines sharply as discount levels increase. While low discounts may be sustainable for selected sub-categories, medium and high discounts consistently result in losses indicating the need for category specific discount strategies.

![Discount Impact](/assets/discount-impact.png)

### 5. Loss-Making Products
This query identifies high-sales products with negative profit. High-sales products are filtered using the Q3 total sales volume threshold.

```sql
WITH product_performance AS (
    SELECT
        EXTRACT(YEAR FROM order_date) AS year,
        region,
        sub_category,
        product_name,
        SUM(sales) AS total_sales,
        SUM(profit) AS total_profit
    FROM 
        sample_superstore
    GROUP BY 
        product_name,  
        EXTRACT(YEAR FROM order_date),
        region,
        sub_category
),
sales_threshold AS (
    SELECT
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_sales) AS high_sales_threshold
    FROM product_performance
)

SELECT
    p.year,
    p.region,
    p.sub_category,
    p.product_name,
    p.total_sales,
    p.total_profit,
    ROUND(p.total_profit / p.total_sales, 2) AS profit_ratio
FROM 
    product_performance p
CROSS JOIN sales_threshold s
WHERE p.total_sales >= s.high_sales_threshold
  AND p.total_profit < 0
ORDER BY p.total_sales DESC;
```
Here's the breakdown of loss-making products :
- Several high-sales products, particularly within the Machines and Furniture sub-categories, generate negative profits across multiple regions and years. These products exhibit structural margin issues, indicating that strong demand does not necessarily translate into business value.

|Product Name|Total Sales|Total Profit|
|------------|-----------|------------|
|Cisco TelePresence System EX90 Videoconferencing Unit|22638.48|-1811.08|
|Riverside Palais Royal Lawyers Bookcase, Royale Cherry Finish|11717.03|-493.34|
|Lexmark MX611dhe Monochrome Laser Printer|11219.93|-1869.99|
|Cubify CubeX 3D Printer Triple Head Print|7999.98|-3839.99|
|DMI Eclipse Executive Suite Bookcases|4809.41|-60.12|

### 6. Customer Segment Profitability
This query analyzes profitability by customer segment.

```sql
SELECT
    segment,
    COUNT(order_id) AS total_orders,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit) / SUM(sales), 2) AS profit_ratio
FROM sample_superstore
GROUP BY segment
ORDER BY profit_ratio DESC;
```
Here's the breakdown of customer segment profitability :
- While the Consumer segment drives the majority of sales and profit through high order volume, the Home Office segment achieves the highest profit margin. Corporate customers provide a balance between scale and efficiency highlighting the need for differentiated segment strategies.

|Segment|Total Orders|Total Sales|Total Profit|Profit Ratio|
|--------|------------|-----------|------------|------------|
|Home Office|1783|429653.29|60299.01|0.14|
|Corporate|3020|706146.44|91979.45|0.13|
|Consumer|5191|1161401.34|134119.33|0.12

## 💡 Key Insights
- The overall profit ratio is **12.47%**, indicating moderate profitability.
- Losses are concentrated in a small number of states, suggesting regional operational inefficiencies.
- High discount levels (>30%) consistently result in negative profit margins.
- Several products generate high sales volume but contribute to net losses, highlighting pricing and cost issues.
- The **Home Office** customer segment delivers the highest profit ratio among all segments.

## 🎯 Business Recommendations
- Shift business focus from sales growth to **profit-driven KPIs**, emphasizing margin improvement alongside revenue.
- Apply **region-specific pricing and operational strategies** to address persistent losses in underperforming states.
- Enforce **discount controls**, especially limiting high-discount promotions that consistently erode profitability.
- Review and optimize **high-sales but loss-making products** through pricing adjustments, cost renegotiation, or product rationalization.
- Protect and expand high-margin customer segments such as **Home Office** customers using targeted, low-discount strategies.

## 📈 Dashboard Preview
![Retail Profitability Dashboard](/assets/dashboard.png)

## 🚀 Outcome
This dashboard enables stakeholders to:
- Identify loss-driving regions and products
- Evaluate discount strategies
- Prioritize actions to improve profitability

The project demonstrates practical business analytics skills, combining SQL, Power BI, and data-driven storytelling.
