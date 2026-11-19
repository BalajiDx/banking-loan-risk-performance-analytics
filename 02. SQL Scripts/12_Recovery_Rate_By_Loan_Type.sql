-- 12_Recovery_Rate_By_Loan_Type.sql
-- Question : How much of the defaulted balance do we recover, by product?
-- Note     : Loss given default (LGD) = 1 - recovery rate.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT
    l.LoanType,
    COUNT(*)                                                      AS defaulted_loans,
    ROUND(SUM(d.OutstandingAtDefault) / 1e6, 2)                   AS outstanding_inr_m,
    ROUND(SUM(d.RecoveryAmount) / 1e6, 2)                         AS recovered_inr_m,
    ROUND(100.0 * SUM(d.RecoveryAmount) / SUM(d.OutstandingAtDefault), 1) AS recovery_rate_pct,
    ROUND(100.0 * (1 - SUM(d.RecoveryAmount) / SUM(d.OutstandingAtDefault)), 1) AS loss_given_default_pct
FROM Defaults d
JOIN Loans l ON l.LoanID = d.LoanID
GROUP BY l.LoanType
ORDER BY loss_given_default_pct DESC;
