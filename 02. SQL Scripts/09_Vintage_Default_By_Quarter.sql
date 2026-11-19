-- 09_Vintage_Default_By_Quarter.sql
-- Question : Are newer loan vintages performing better or worse?
-- Note     : Cohort view by origination quarter. Later quarters are lower partly because they are younger (less time to default).
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT
    strftime('%Y', OriginationDate) || '-Q' || ((CAST(strftime('%m', OriginationDate) AS INTEGER) + 2) / 3) AS origination_quarter,
    COUNT(*)                                                      AS loans,
    SUM(CASE WHEN Status = 'Defaulted' THEN 1 ELSE 0 END)         AS defaults,
    ROUND(100.0 * SUM(CASE WHEN Status = 'Defaulted' THEN 1 ELSE 0 END) / COUNT(*), 2) AS default_rate_pct,
    ROUND(AVG(InterestRate), 2)                                   AS avg_rate_pct
FROM Loans
GROUP BY 1
ORDER BY 1;
