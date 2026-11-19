-- 05_Default_Rate_By_Loan_Type.sql
-- Question : Which products carry the most default risk?
-- Note     : Default rate = defaulted loans / all loans in the group. Recent loans have had less time to default (data cut-off 2024-12-31).
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT
    l.LoanType AS loan_type,
    COUNT(*)                                                      AS loans,
    SUM(CASE WHEN l.Status = 'Defaulted' THEN 1 ELSE 0 END)       AS defaults,
    ROUND(100.0 * SUM(CASE WHEN l.Status = 'Defaulted' THEN 1 ELSE 0 END) / COUNT(*), 2) AS default_rate_pct,
    ROUND(AVG(l.InterestRate), 2)                                 AS avg_rate_pct,
    ROUND(SUM(l.LoanAmount) / 1e6, 1)                             AS disbursed_inr_m
FROM Loans l
JOIN Customers c ON c.CustomerID = l.CustomerID
GROUP BY 1
ORDER BY 1;
