-- 15_Months_To_Default.sql
-- Question : How long after origination do loans default?
-- Note     : Months between OriginationDate and DefaultDate, bucketed.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT
    CASE WHEN m < 6  THEN '1. 0-5 months'
         WHEN m < 12 THEN '2. 6-11 months'
         WHEN m < 18 THEN '3. 12-17 months'
         WHEN m < 24 THEN '4. 18-23 months'
         ELSE '5. 24+ months' END                                  AS months_to_default,
    COUNT(*)                                                       AS defaults,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)             AS pct_of_defaults
FROM (
    SELECT CAST((julianday(d.DefaultDate) - julianday(l.OriginationDate)) / 30.4375 AS INTEGER) AS m
    FROM Defaults d
    JOIN Loans l ON l.LoanID = d.LoanID
)
GROUP BY 1
ORDER BY 1;
