
--Business Question :
--How do sales and profit trends change over time?

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