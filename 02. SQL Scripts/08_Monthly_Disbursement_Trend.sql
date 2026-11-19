-- 08_Monthly_Disbursement_Trend.sql
-- Question : How much was disbursed each month, and how is it trending?
-- Note     : Uses window functions: running total (SUM OVER) and month-on-month change (LAG).
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

WITH monthly AS (
    SELECT strftime('%Y-%m', OriginationDate) AS month,
           COUNT(*)                           AS loans,
           SUM(LoanAmount)                    AS disbursed
    FROM Loans
    GROUP BY 1
)
SELECT
    month,
    loans,
    ROUND(disbursed / 1e6, 2)                                           AS disbursed_inr_m,
    ROUND(SUM(disbursed) OVER (ORDER BY month) / 1e6, 2)                AS cumulative_inr_m,
    ROUND(100.0 * (disbursed - LAG(disbursed) OVER (ORDER BY month))
          / LAG(disbursed) OVER (ORDER BY month), 1)                    AS mom_change_pct
FROM monthly
ORDER BY month;
