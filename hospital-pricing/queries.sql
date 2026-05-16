-- =============================================================
-- U.S. Hospital Price Audit — SQL Queries
-- Author  : Salomi Gandra | salomigandra.com
-- Tables  : hospital_prices, compliance_audit, oecd_spending
-- =============================================================


-- ─────────────────────────────────────────────────────────────
-- QUERY 1: Price ratio per hospital ranked highest to lowest
-- Purpose : Identify most aggressive price markups
-- ─────────────────────────────────────────────────────────────
SELECT
    h.hospital_name,
    h.state,
    h.hospital_type,
    ROUND(AVG(h.private_rate_usd / h.medicare_rate_usd), 2)    AS avg_price_ratio,
    COUNT(DISTINCT h.procedure_code)                            AS procedures_analyzed,
    ROUND(AVG(h.private_rate_usd), 0)                          AS avg_private_rate,
    ROUND(AVG(h.medicare_rate_usd), 0)                         AS avg_medicare_rate,
    ROUND(AVG(h.private_rate_usd - h.medicare_rate_usd), 0)    AS avg_markup_usd
FROM hospital_prices h
WHERE h.medicare_rate_usd > 0      -- exclude $0 Medicare (non-covered)
  AND h.year = 2022
GROUP BY h.hospital_name, h.state, h.hospital_type
HAVING COUNT(DISTINCT h.procedure_code) >= 10   -- enough data points
ORDER BY avg_price_ratio DESC
LIMIT 50;


-- ─────────────────────────────────────────────────────────────
-- QUERY 2: Price ratio by procedure category
-- Purpose : Which categories have worst markup?
-- ─────────────────────────────────────────────────────────────
SELECT
    p.category,
    COUNT(*)                                                    AS procedure_count,
    ROUND(AVG(p.private_rate_usd / p.medicare_rate_usd), 2)    AS avg_ratio,
    ROUND(MIN(p.private_rate_usd / p.medicare_rate_usd), 2)    AS min_ratio,
    ROUND(MAX(p.private_rate_usd / p.medicare_rate_usd), 2)    AS max_ratio,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP
        (ORDER BY p.private_rate_usd / p.medicare_rate_usd), 2) AS median_ratio,
    ROUND(AVG(p.medicare_rate_usd), 0)                         AS avg_medicare_usd,
    ROUND(AVG(p.private_rate_usd), 0)                          AS avg_private_usd
FROM hospital_prices p
WHERE p.medicare_rate_usd > 0
  AND p.year = 2022
GROUP BY p.category
ORDER BY avg_ratio DESC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 3: State-level compliance rate
-- Purpose : Show which states have worst transparency compliance
-- ─────────────────────────────────────────────────────────────
WITH compliance_scores AS (
    SELECT
        c.state,
        COUNT(*)                                                AS total_hospitals,
        SUM(CASE WHEN c.file_present = TRUE        THEN 1 ELSE 0 END) AS has_file,
        SUM(CASE WHEN c.publicly_accessible = TRUE THEN 1 ELSE 0 END) AS accessible,
        SUM(CASE WHEN c.all_fields_present = TRUE  THEN 1 ELSE 0 END) AS complete,
        SUM(CASE WHEN c.updated_within_12m = TRUE  THEN 1 ELSE 0 END) AS current,
        SUM(CASE WHEN c.fully_compliant = TRUE     THEN 1 ELSE 0 END) AS fully_compliant
    FROM compliance_audit c
    WHERE c.audit_year = 2023
    GROUP BY c.state
)
SELECT
    state,
    total_hospitals,
    ROUND(fully_compliant::DECIMAL / total_hospitals * 100, 1)  AS compliant_pct,
    total_hospitals - fully_compliant                           AS non_compliant_count,
    ROUND((total_hospitals - fully_compliant)::DECIMAL
        / total_hospitals * 100, 1)                             AS non_compliant_pct
FROM compliance_scores
ORDER BY non_compliant_pct DESC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 4: OECD spending vs life expectancy
-- Purpose : Does higher spending = better outcomes?
-- ─────────────────────────────────────────────────────────────
SELECT
    country,
    per_capita_spend_usd,
    life_expectancy_years,
    infant_mortality_per_1000,
    ROUND(
        per_capita_spend_usd /
        (SELECT per_capita_spend_usd FROM oecd_spending WHERE country = 'Germany'),
        2
    )                                                           AS ratio_vs_germany,
    RANK() OVER (ORDER BY per_capita_spend_usd DESC)            AS spend_rank,
    RANK() OVER (ORDER BY life_expectancy_years DESC)           AS life_exp_rank
FROM oecd_spending
WHERE year = 2022
ORDER BY per_capita_spend_usd DESC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 5: Reference pricing savings model
-- Purpose : Estimate savings if private rates capped at 160% Medicare
-- ─────────────────────────────────────────────────────────────
WITH current_spend AS (
    SELECT
        procedure_code,
        category,
        SUM(private_rate_usd * claim_volume)                    AS total_current_spend,
        SUM(medicare_rate_usd * 1.60 * claim_volume)            AS total_capped_spend
    FROM hospital_prices
    WHERE year = 2022
      AND medicare_rate_usd > 0
    GROUP BY procedure_code, category
)
SELECT
    category,
    ROUND(SUM(total_current_spend) / 1e9, 2)                   AS current_spend_bn,
    ROUND(SUM(total_capped_spend)  / 1e9, 2)                   AS capped_spend_bn,
    ROUND((SUM(total_current_spend) - SUM(total_capped_spend))
        / 1e9, 2)                                               AS savings_bn,
    ROUND(
        (SUM(total_current_spend) - SUM(total_capped_spend))
        / SUM(total_current_spend) * 100, 1
    )                                                           AS savings_pct
FROM current_spend
GROUP BY category
ORDER BY savings_bn DESC;
