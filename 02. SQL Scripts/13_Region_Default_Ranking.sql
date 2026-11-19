-- 13_Region_Default_Ranking.sql
-- Question : How do regions rank by default rate, and how far from the portfolio average?
-- Note     : RANK() window function; portfolio average computed in a CTE.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

WITH region_stats AS (
    SELECT c.Region,
           COUNT(*) AS loans,
           SUM(CASE WHEN l.Status = 'Defaulted' THEN 1 ELSE 0 END) AS defaults
    FROM Loans l
    JOIN Customers c ON c.CustomerID = l.CustomerID
    GROUP BY c.Region
),
overall AS (
    SELECT 100.0 * SUM(defaults) / SUM(loans) AS avg_default_rate FROM region_stats
)
SELECT
    RANK() OVER (ORDER BY 1.0 * r.defaults / r.loans DESC)        AS risk_rank,
    r.Region,
    r.loans,
    r.defaults,
    ROUND(100.0 * r.defaults / r.loans, 2)                        AS default_rate_pct,
    ROUND(100.0 * r.defaults / r.loans - o.avg_default_rate, 2)   AS vs_portfolio_pts
FROM region_stats r CROSS JOIN overall o
ORDER BY risk_rank;
