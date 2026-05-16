-- =============================================================
-- Iran Shock — SQL Queries
-- Author  : Salomi Gandra | salomigandra.com
-- Dataset : Tables represent data imported from EIA, RBI DBIE,
--           PPAC, and HCES 2022-23 (see data_dictionary.md)
-- =============================================================


-- ─────────────────────────────────────────────────────────────
-- QUERY 1: Daily Brent crude % change with 7-day rolling average
-- Purpose : Identify shock date and magnitude
-- ─────────────────────────────────────────────────────────────
WITH daily_changes AS (
    SELECT
        price_date,
        brent_usd,
        LAG(brent_usd) OVER (ORDER BY price_date)              AS prev_day_price,
        ROUND(
            (brent_usd - LAG(brent_usd) OVER (ORDER BY price_date))
            / LAG(brent_usd) OVER (ORDER BY price_date) * 100, 3
        )                                                       AS daily_pct_change
    FROM brent_crude_prices
    WHERE price_date BETWEEN '2022-01-01' AND '2024-06-30'
),
rolling_avg AS (
    SELECT
        price_date,
        brent_usd,
        daily_pct_change,
        AVG(brent_usd) OVER (
            ORDER BY price_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        )                                                       AS rolling_7d_avg
    FROM daily_changes
)
SELECT
    price_date,
    ROUND(brent_usd, 2)         AS brent_usd,
    ROUND(rolling_7d_avg, 2)    AS rolling_7d_avg,
    daily_pct_change
FROM rolling_avg
WHERE ABS(daily_pct_change) > 2.0   -- flag days with >2% single-day moves
ORDER BY price_date;


-- ─────────────────────────────────────────────────────────────
-- QUERY 2: INR/USD monthly average + cumulative depreciation
-- Purpose : Show steady rupee weakening trajectory
-- ─────────────────────────────────────────────────────────────
WITH monthly_avg AS (
    SELECT
        DATE_TRUNC('month', rate_date)                          AS month,
        ROUND(AVG(inr_per_usd), 2)                             AS avg_inr_usd
    FROM inr_usd_rates
    WHERE rate_date BETWEEN '2022-01-01' AND '2024-06-30'
    GROUP BY DATE_TRUNC('month', rate_date)
),
base_rate AS (
    SELECT avg_inr_usd AS jan_2022_rate
    FROM monthly_avg
    ORDER BY month
    LIMIT 1
)
SELECT
    m.month,
    m.avg_inr_usd,
    ROUND(
        (m.avg_inr_usd - b.jan_2022_rate) / b.jan_2022_rate * 100, 2
    )                                                           AS cumulative_depreciation_pct
FROM monthly_avg m
CROSS JOIN base_rate b
ORDER BY m.month;


-- ─────────────────────────────────────────────────────────────
-- QUERY 3: Effective pump price model vs actual pump price
-- Purpose : Validate theoretical model against real PPAC data
-- ─────────────────────────────────────────────────────────────
SELECT
    p.month,
    p.brent_monthly_avg_usd,
    r.avg_inr_usd,
    -- Theoretical pump price formula
    ROUND(
        (p.brent_monthly_avg_usd * r.avg_inr_usd)
        / 158.987                                               -- barrel to litres
        / 0.65                                                  -- crude yield
        * 1.45,                                                 -- duty + margin
        2
    )                                                           AS model_pump_price_inr,
    pp.actual_pump_price_delhi_inr,
    ROUND(
        pp.actual_pump_price_delhi_inr -
        (p.brent_monthly_avg_usd * r.avg_inr_usd / 158.987 / 0.65 * 1.45),
        2
    )                                                           AS model_vs_actual_diff
FROM brent_monthly_avg p
JOIN inr_monthly_avg   r  ON p.month = r.month
JOIN pump_prices_ppac  pp ON p.month = pp.month
ORDER BY p.month;


-- ─────────────────────────────────────────────────────────────
-- QUERY 4: Household quintile fuel burden before vs after shock
-- Purpose : Show regressive impact across income groups
-- ─────────────────────────────────────────────────────────────
WITH shock_params AS (
    SELECT
        96.5  AS price_baseline,    -- ₹/litre Jan 2022
        180.6 AS price_shock,       -- ₹/litre Jun 2024
        0.871 AS shock_pct          -- 87.1% increase
),
quintile_impacts AS (
    SELECT
        h.quintile_label,
        h.avg_monthly_income_inr,
        h.fuel_expenditure_share_pct,
        ROUND(h.avg_monthly_income_inr * h.fuel_expenditure_share_pct / 100, 0)
                                                                AS baseline_fuel_spend,
        ROUND(h.avg_monthly_income_inr * h.fuel_expenditure_share_pct / 100 * (1 + s.shock_pct), 0)
                                                                AS shocked_fuel_spend,
        ROUND(h.avg_monthly_income_inr * h.fuel_expenditure_share_pct / 100 * s.shock_pct, 0)
                                                                AS monthly_increase_inr
    FROM household_quintiles h
    CROSS JOIN shock_params s
)
SELECT
    quintile_label,
    avg_monthly_income_inr,
    fuel_expenditure_share_pct,
    baseline_fuel_spend,
    shocked_fuel_spend,
    monthly_increase_inr,
    ROUND(monthly_increase_inr::DECIMAL / avg_monthly_income_inr * 100, 2)
                                                                AS income_impact_pct
FROM quintile_impacts
ORDER BY avg_monthly_income_inr;


-- ─────────────────────────────────────────────────────────────
-- QUERY 5: Oil import origin — Hormuz dependency check
-- Purpose : Quantify % of India's crude that transits Hormuz
-- ─────────────────────────────────────────────────────────────
SELECT
    origin_country,
    import_volume_mbpd,
    ROUND(
        import_volume_mbpd / SUM(import_volume_mbpd) OVER () * 100, 1
    )                                                           AS share_pct,
    transits_hormuz,                                            -- boolean flag
    CASE
        WHEN transits_hormuz THEN ROUND(
            import_volume_mbpd / SUM(import_volume_mbpd) OVER () * 100, 1
        )
        ELSE 0
    END                                                         AS hormuz_exposure_pct
FROM india_crude_imports
WHERE fiscal_year = '2023-24'
ORDER BY import_volume_mbpd DESC;
