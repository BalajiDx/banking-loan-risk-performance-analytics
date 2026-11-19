-- 10_Payment_Behaviour_Before_Default.sql
-- Question : Do late payments warn us before a loan defaults?
-- Note     : Compares repayment behaviour of defaulted loans with all other loans.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT
    CASE WHEN l.Status = 'Defaulted' THEN 'Defaulted' ELSE 'Not defaulted' END AS loan_group,
    COUNT(DISTINCT l.LoanID)                                       AS loans,
    COUNT(*)                                                       AS instalments,
    ROUND(100.0 * SUM(CASE WHEN p.DaysLate > 0  THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_paid_late,
    ROUND(100.0 * SUM(CASE WHEN p.DaysLate >= 15 THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_paid_15_plus_days_late,
    ROUND(AVG(p.DaysLate), 2)                                      AS avg_days_late,
    ROUND(100.0 * SUM(CASE WHEN p.AmountPaid < p.AmountDue * 0.99 THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_part_paid
FROM Payments p
JOIN Loans l ON l.LoanID = p.LoanID
GROUP BY 1
ORDER BY 1 DESC;
