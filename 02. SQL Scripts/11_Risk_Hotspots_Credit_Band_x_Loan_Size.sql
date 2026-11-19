-- 11_Risk_Hotspots_Credit_Band_x_Loan_Size.sql
-- Question : Which combinations of credit band and loan size have the highest default rate?
-- Note     : Groups with fewer than 20 loans are hidden so a handful of cases does not look like a trend.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT
    CASE WHEN c.CreditScore < 580 THEN '1. Poor (300-579)'
         WHEN c.CreditScore < 670 THEN '2. Fair (580-669)'
         WHEN c.CreditScore < 740 THEN '3. Good (670-739)'
         WHEN c.CreditScore < 800 THEN '4. Very Good (740-799)'
         ELSE '5. Exceptional (800-850)' END AS credit_band,
    CASE WHEN l.LoanAmount < 500000 THEN '1. Under 5 L'
         WHEN l.LoanAmount < 1000000 THEN '2. 5-10 L'
         WHEN l.LoanAmount < 2500000 THEN '3. 10-25 L'
         WHEN l.LoanAmount < 5000000 THEN '4. 25-50 L'
         ELSE '5. 50 L and above' END AS loan_size_band,
    COUNT(*)                                                      AS loans,
    SUM(CASE WHEN l.Status = 'Defaulted' THEN 1 ELSE 0 END)       AS defaults,
    ROUND(100.0 * SUM(CASE WHEN l.Status = 'Defaulted' THEN 1 ELSE 0 END) / COUNT(*), 2) AS default_rate_pct
FROM Loans l
JOIN Customers c ON c.CustomerID = l.CustomerID
GROUP BY 1, 2
HAVING COUNT(*) >= 20
ORDER BY default_rate_pct DESC;
