-- 03_Default_Rate_By_Tenure.sql
-- Question : How does loan tenure relate to default?
-- Note     : Default rate = defaulted loans / all loans in the group. Recent loans have had less time to default (data cut-off 2024-12-31).
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT
    CASE WHEN l.TenureMonths <= 12 THEN '1. Up to 1 yr'
         WHEN l.TenureMonths <= 36 THEN '2. 1-3 yrs'
         WHEN l.TenureMonths <= 60 THEN '3. 3-5 yrs'
         WHEN l.TenureMonths <= 120 THEN '4. 5-10 yrs'
         ELSE '5. Over 10 yrs' END AS tenure_band,
    COUNT(*)                                                      AS loans,
    SUM(CASE WHEN l.Status = 'Defaulted' THEN 1 ELSE 0 END)       AS defaults,
    ROUND(100.0 * SUM(CASE WHEN l.Status = 'Defaulted' THEN 1 ELSE 0 END) / COUNT(*), 2) AS default_rate_pct,
    ROUND(AVG(l.InterestRate), 2)                                 AS avg_rate_pct
FROM Loans l
JOIN Customers c ON c.CustomerID = l.CustomerID
GROUP BY 1
ORDER BY 1;
