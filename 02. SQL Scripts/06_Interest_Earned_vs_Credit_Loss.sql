-- 06_Interest_Earned_vs_Credit_Loss.sql
-- Question : Is the interest charged on riskier bands enough to cover the losses?
-- Note     : Interest earned = share of each instalment paid that was interest. Credit loss = outstanding at default minus recovery. Net = earned - loss.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

WITH interest AS (
    SELECT p.LoanID,
           SUM(p.AmountPaid * p.InterestDue / p.AmountDue) AS interest_earned
    FROM Payments p
    GROUP BY p.LoanID
),
loss AS (
    SELECT LoanID, OutstandingAtDefault - RecoveryAmount AS credit_loss
    FROM Defaults
)
SELECT
    CASE WHEN c.CreditScore < 580 THEN '1. Poor (300-579)'
         WHEN c.CreditScore < 670 THEN '2. Fair (580-669)'
         WHEN c.CreditScore < 740 THEN '3. Good (670-739)'
         WHEN c.CreditScore < 800 THEN '4. Very Good (740-799)'
         ELSE '5. Exceptional (800-850)' END AS credit_band,
    COUNT(*)                                          AS loans,
    ROUND(AVG(l.InterestRate), 2)                     AS avg_rate_pct,
    ROUND(SUM(i.interest_earned) / 1e6, 2)            AS interest_earned_inr_m,
    ROUND(SUM(COALESCE(x.credit_loss, 0)) / 1e6, 2)   AS credit_loss_inr_m,
    ROUND((SUM(i.interest_earned) - SUM(COALESCE(x.credit_loss, 0))) / 1e6, 2) AS net_inr_m,
    ROUND(100.0 * (SUM(i.interest_earned) - SUM(COALESCE(x.credit_loss, 0))) / SUM(l.LoanAmount), 2) AS net_pct_of_disbursed
FROM Loans l
JOIN Customers c ON c.CustomerID = l.CustomerID
LEFT JOIN interest i ON i.LoanID = l.LoanID
LEFT JOIN loss x     ON x.LoanID = l.LoanID
GROUP BY 1
ORDER BY 1;
