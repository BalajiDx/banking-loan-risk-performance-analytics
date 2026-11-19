-- 07_Interest_Rate_By_Band_And_Tenure.sql
-- Question : How does the average interest rate move with credit band and tenure?
-- Note     : Pivot built with conditional AVG; empty cells mean no loans in that combination.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT
    CASE WHEN c.CreditScore < 580 THEN '1. Poor (300-579)'
         WHEN c.CreditScore < 670 THEN '2. Fair (580-669)'
         WHEN c.CreditScore < 740 THEN '3. Good (670-739)'
         WHEN c.CreditScore < 800 THEN '4. Very Good (740-799)'
         ELSE '5. Exceptional (800-850)' END AS credit_band,
    ROUND(AVG(CASE WHEN l.TenureMonths <= 12 THEN l.InterestRate END), 2) AS "Up to 1 yr",
    ROUND(AVG(CASE WHEN l.TenureMonths BETWEEN 13 AND 36 THEN l.InterestRate END), 2) AS "1-3 yrs",
    ROUND(AVG(CASE WHEN l.TenureMonths BETWEEN 37 AND 60 THEN l.InterestRate END), 2) AS "3-5 yrs",
    ROUND(AVG(CASE WHEN l.TenureMonths BETWEEN 61 AND 120 THEN l.InterestRate END), 2) AS "5-10 yrs",
    ROUND(AVG(CASE WHEN l.TenureMonths > 120 THEN l.InterestRate END), 2) AS "Over 10 yrs"
FROM Loans l
JOIN Customers c ON c.CustomerID = l.CustomerID
GROUP BY 1
ORDER BY 1;
