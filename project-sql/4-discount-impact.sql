
--BUSINESS QUESTION :
--How do different discount levels impact profit margins?

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
