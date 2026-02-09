
--BUSINESS QUESTION :
--What is the overall sales and profitability performance?

SELECT
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(profit) / SUM(sales), 2) AS profit_ratio
FROM
    sample_superstore