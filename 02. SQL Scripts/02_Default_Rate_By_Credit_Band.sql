-- 02_Default_Rate_By_Credit_Band.sql
-- Question : Do lower credit-score bands default more?
-- Note     : Default rate = defaulted loans / all loans in the group. Recent loans have had less time to default (data cut-off 2024-12-31).
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT
    CASE WHEN c.CreditScore < 580 THEN '1. Poor (300-579)'
         WHEN c.CreditScore < 670 THEN '2. Fair (580-669)'
         WHEN c.CreditScore < 740 THEN '3. Good (670-739)'
         WHEN c.CreditScore < 800 THEN '4. Very Good (740-799)'
         ELSE '5. Exceptional (800-850)' END AS credit_band,
    COUNT(*)                                                      AS loans,
    SUM(CASE WHEN l.Status = 'Defaulted' THEN 1 ELSE 0 END)       AS defaults,
    ROUND(100.0 * SUM(CASE WHEN l.Status = 'Defaulted' THEN 1 ELSE 0 END) / COUNT(*), 2) AS default_rate_pct,
    ROUND(AVG(l.InterestRate), 2)                                 AS avg_rate_pct
FROM Loans l
JOIN Customers c ON c.CustomerID = l.CustomerID
GROUP BY 1
ORDER BY 1;
