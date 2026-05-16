-- =============================================================
-- Geopolitical Shocks & CPI — SQL Queries
-- Author  : Salomi Gandra | salomigandra.com
-- Tables  : cpi_monthly, fd_rates, commodity_prices, rbi_policy
-- =============================================================


-- ─────────────────────────────────────────────────────────────
-- QUERY 1: Year-over-year CPI change by category using LAG()
-- Purpose : Show which categories drove each year's inflation
-- ─────────────────────────────────────────────────────────────
WITH yoy AS (
    SELECT
        month,
        category,
        cpi_value,
        LAG(cpi_value, 12) OVER (
            PARTITION BY category
            ORDER BY month
        )                                           AS cpi_same_month_last_year
    FROM cpi_monthly
    WHERE month BETWEEN '2020-01-01' AND '2024-12-01'
)
SELECT
    month,
    category,
    ROUND(cpi_value, 2)                             AS cpi_value,
    ROUND(cpi_same_month_last_year, 2)              AS prev_year,
    ROUND(
        (cpi_value - cpi_same_month_last_year)
        / cpi_same_month_last_year * 100, 2
    )                                               AS yoy_change_pct
FROM yoy
WHERE cpi_same_month_last_year IS NOT NULL
ORDER BY month, category;


-- ─────────────────────────────────────────────────────────────
-- QUERY 2: Monthly food CPI vs headline CPI — lead-lag check
-- Purpose : Confirm food CPI leads headline by 1–2 months
-- ─────────────────────────────────────────────────────────────
SELECT
    h.month,
    h.cpi_value                                     AS headline_cpi,
    f.cpi_value                                     AS food_cpi,
    LAG(f.cpi_value, 1) OVER (ORDER BY h.month)    AS food_cpi_lag1,
    LAG(f.cpi_value, 2) OVER (ORDER BY h.month)    AS food_cpi_lag2,
    LAG(f.cpi_value, 3) OVER (ORDER BY h.month)    AS food_cpi_lag3
FROM cpi_monthly h
JOIN cpi_monthly f
    ON h.month = f.month
    AND f.category = 'food_beverages'
WHERE h.category = 'headline'
  AND h.month BETWEEN '2020-01-01' AND '2024-12-01'
ORDER BY h.month;


-- ─────────────────────────────────────────────────────────────
-- QUERY 3: 5-year cumulative inflation by category
-- Purpose : Show which basket items eroded purchasing power most
-- ─────────────────────────────────────────────────────────────
WITH base AS (
    SELECT category, cpi_value AS base_value
    FROM cpi_monthly
    WHERE month = '2020-01-01'
),
latest AS (
    SELECT category, cpi_value AS latest_value
    FROM cpi_monthly
    WHERE month = '2024-12-01'
)
SELECT
    b.category,
    ROUND(b.base_value, 2)          AS cpi_jan_2020,
    ROUND(l.latest_value, 2)        AS cpi_dec_2024,
    ROUND(
        (l.latest_value - b.base_value) / b.base_value * 100, 1
    )                               AS cumulative_inflation_pct
FROM base b
JOIN latest l ON b.category = l.category
ORDER BY cumulative_inflation_pct DESC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 4: FD real return by year
-- Purpose : Show when savings instruments failed to beat inflation
-- ─────────────────────────────────────────────────────────────
WITH annual_cpi AS (
    SELECT
        EXTRACT(YEAR FROM month)            AS year,
        ROUND(AVG(cpi_value), 2)           AS avg_cpi_pct
    FROM cpi_monthly
    WHERE category = 'headline'
    GROUP BY EXTRACT(YEAR FROM month)
)
SELECT
    ac.year,
    ac.avg_cpi_pct,
    fd.sbi_1yr_rate_pct,
    ROUND(fd.sbi_1yr_rate_pct - ac.avg_cpi_pct, 2)     AS real_return_pct,
    CASE
        WHEN fd.sbi_1yr_rate_pct - ac.avg_cpi_pct < 0
        THEN 'NEGATIVE — savings losing value'
        ELSE 'Positive'
    END                                                  AS real_return_status
FROM annual_cpi ac
JOIN fd_rates fd ON ac.year = fd.year
ORDER BY ac.year;


-- ─────────────────────────────────────────────────────────────
-- QUERY 5: Brent crude to food CPI lagged correlation
-- Purpose : Quantify oil → food transmission (via transport + fertiliser)
-- ─────────────────────────────────────────────────────────────
WITH monthly_data AS (
    SELECT
        c.month,
        c.cpi_value                                     AS food_cpi,
        b.brent_usd_avg,
        LAG(b.brent_usd_avg, 2) OVER (ORDER BY c.month) AS brent_lag2m,
        LAG(b.brent_usd_avg, 3) OVER (ORDER BY c.month) AS brent_lag3m
    FROM cpi_monthly c
    JOIN brent_monthly_avg b ON c.month = b.month
    WHERE c.category = 'food_beverages'
      AND c.month BETWEEN '2021-01-01' AND '2024-12-01'
)
SELECT
    month,
    ROUND(food_cpi, 2)          AS food_cpi_pct,
    ROUND(brent_usd_avg, 2)     AS brent_current,
    ROUND(brent_lag2m, 2)       AS brent_2m_prior,
    ROUND(brent_lag3m, 2)       AS brent_3m_prior
FROM monthly_data
WHERE brent_lag3m IS NOT NULL
ORDER BY month;
