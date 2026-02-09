
--BUSINESS QUESTION :
--Which states contribute the most to financial losses?

SELECT
    region,
    state,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit) / SUM(sales), 2) AS profit_ratio
FROM sample_superstore
GROUP BY region, state
HAVING SUM(profit) < 0
ORDER BY profit_ratio ASC;





