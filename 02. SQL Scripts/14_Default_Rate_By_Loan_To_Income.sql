-- 14_Default_Rate_By_Loan_To_Income.sql
-- Question : Does borrowing a larger multiple of income raise default risk?
-- Note     : Loan-to-income = loan amount / annual income. Imputed incomes are included (see Cleaning Log).
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT
    CASE WHEN 1.0 * l.LoanAmount / c.AnnualIncome < 0.5 THEN '1. Under 0.5x'
         WHEN 1.0 * l.LoanAmount / c.AnnualIncome < 1.0 THEN '2. 0.5-1.0x'
         WHEN 1.0 * l.LoanAmount / c.AnnualIncome < 2.0 THEN '3. 1.0-2.0x'
         WHEN 1.0 * l.LoanAmount / c.AnnualIncome < 4.0 THEN '4. 2.0-4.0x'
         ELSE '5. 4.0x and above' END                              AS loan_to_income_band,
    COUNT(*)                                                       AS loans,
    SUM(CASE WHEN l.Status = 'Defaulted' THEN 1 ELSE 0 END)        AS defaults,
    ROUND(100.0 * SUM(CASE WHEN l.Status = 'Defaulted' THEN 1 ELSE 0 END) / COUNT(*), 2) AS default_rate_pct
FROM Loans l
JOIN Customers c ON c.CustomerID = l.CustomerID
GROUP BY 1
ORDER BY 1;
