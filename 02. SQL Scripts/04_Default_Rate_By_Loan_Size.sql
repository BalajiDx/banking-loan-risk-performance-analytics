-- 04_Default_Rate_By_Loan_Size.sql
-- Question : Are bigger loans riskier?
-- Note     : Default rate = defaulted loans / all loans in the group. Recent loans have had less time to default (data cut-off 2024-12-31).
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT
    CASE WHEN l.LoanAmount < 500000 THEN '1. Under 5 L'
         WHEN l.LoanAmount < 1000000 THEN '2. 5-10 L'
         WHEN l.LoanAmount < 2500000 THEN '3. 10-25 L'
         WHEN l.LoanAmount < 5000000 THEN '4. 25-50 L'
         ELSE '5. 50 L and above' END AS loan_size_band,
    COUNT(*)                                                      AS loans,
    SUM(CASE WHEN l.Status = 'Defaulted' THEN 1 ELSE 0 END)       AS defaults,
    ROUND(100.0 * SUM(CASE WHEN l.Status = 'Defaulted' THEN 1 ELSE 0 END) / COUNT(*), 2) AS default_rate_pct,
    ROUND(AVG(l.InterestRate), 2)                                 AS avg_rate_pct
FROM Loans l
JOIN Customers c ON c.CustomerID = l.CustomerID
GROUP BY 1
ORDER BY 1;
