-- 16_Active_Loans_Watchlist.sql
-- Question : Which active loans should the collections team look at first?
-- Note     : Uses a CTE + ROW_NUMBER to take each loan's last 6 instalments. Exposure is approximate: LoanAmount x share of tenure remaining.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

WITH recent AS (
    SELECT p.*,
           ROW_NUMBER() OVER (PARTITION BY p.LoanID ORDER BY p.InstallmentNo DESC) AS rn
    FROM Payments p
),
signals AS (
    SELECT LoanID,
           MAX(InstallmentNo)                                          AS instalments_paid,
           SUM(CASE WHEN DaysLate >= 10 THEN 1 ELSE 0 END)             AS late_10_plus,
           SUM(CASE WHEN AmountPaid < AmountDue * 0.99 THEN 1 ELSE 0 END) AS part_paid
    FROM recent
    WHERE rn <= 6
    GROUP BY LoanID
)
SELECT
    l.LoanID,
    l.LoanType,
    c.CreditScore,
    l.InterestRate,
    s.late_10_plus,
    s.part_paid,
    ROUND(l.LoanAmount * (1.0 - s.instalments_paid / l.TenureMonths) / 1e3, 0) AS approx_exposure_inr_k
FROM Loans l
JOIN Customers c ON c.CustomerID = l.CustomerID
JOIN signals s   ON s.LoanID = l.LoanID
WHERE l.Status = 'Active'
  AND (s.late_10_plus >= 2 OR s.part_paid >= 1)
ORDER BY s.late_10_plus DESC, s.part_paid DESC, approx_exposure_inr_k DESC
LIMIT 10;
