-- 01_Portfolio_KPIs.sql
-- Question : What are the headline numbers for the loan book?
-- Note     : Default rate = defaulted loans / all loans in the group. Recent loans have had less time to default (data cut-off 2024-12-31).
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT
    COUNT(*)                                                     AS total_loans,
    ROUND(SUM(LoanAmount) / 1e6, 1)                              AS disbursed_inr_m,
    ROUND(AVG(InterestRate), 2)                                  AS avg_interest_rate_pct,
    SUM(CASE WHEN Status = 'Defaulted' THEN 1 ELSE 0 END)        AS defaulted_loans,
    ROUND(100.0 * SUM(CASE WHEN Status = 'Defaulted' THEN 1 ELSE 0 END) / COUNT(*), 2) AS default_rate_pct,
    SUM(CASE WHEN Status = 'Active'   THEN 1 ELSE 0 END)         AS active_loans,
    SUM(CASE WHEN Status = 'Closed'   THEN 1 ELSE 0 END)         AS closed_loans,
    (SELECT ROUND(SUM(OutstandingAtDefault) / 1e6, 1) FROM Defaults) AS outstanding_at_default_inr_m,
    (SELECT ROUND(SUM(RecoveryAmount) / 1e6, 1)       FROM Defaults) AS recovered_inr_m
FROM Loans;
