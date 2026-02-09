
--BUSINESS QUESTION
--Which customer segments are the most profitable?

SELECT
    segment,
    COUNT(order_id) AS total_orders,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit) / SUM(sales), 2) AS profit_ratio
FROM sample_superstore
GROUP BY segment
ORDER BY profit_ratio DESC;