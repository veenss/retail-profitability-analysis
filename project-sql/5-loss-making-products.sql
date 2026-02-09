
--BUSINESS QUESTION :
--Which products generate high sales but negative profit?
--(high sales threshold using Q3 in this case)

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