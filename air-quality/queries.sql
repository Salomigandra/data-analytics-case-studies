-- =============================================================
-- India Air Quality & PM2.5 Health Burden — SQL Queries
-- Author  : Salomi Gandra | salomigandra.com
-- Tables  : city_pm25, health_burden, standards_comparison, monitoring_stations
-- =============================================================


-- ─────────────────────────────────────────────────────────────
-- QUERY 1: City ranking by annual PM2.5 with WHO multiple
-- Purpose : Identify most polluted cities and WHO exceedance factor
-- ─────────────────────────────────────────────────────────────
SELECT
    c.city,
    c.state,
    c.pm25_annual_ugm3,
    c.population_millions,
    ROUND(c.pm25_annual_ugm3 / 5.0, 1)                          AS who_guideline_multiple,
    ROUND(c.pm25_annual_ugm3 / 40.0, 2)                         AS india_naaqs_multiple,
    CASE
        WHEN c.pm25_annual_ugm3 > 40.0 THEN 'Exceeds NAAQS'
        WHEN c.pm25_annual_ugm3 > 5.0  THEN 'Exceeds WHO Only'
        ELSE 'WHO Compliant'
    END                                                          AS compliance_status,
    RANK() OVER (ORDER BY c.pm25_annual_ugm3 DESC)               AS pollution_rank
FROM city_pm25 c
WHERE c.year = 2023
ORDER BY c.pm25_annual_ugm3 DESC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 2: GEMM attributable deaths calculation per city
-- Purpose : Quantify health burden using WHO-endorsed GEMM model
-- AF = 1 - exp(-0.0096 × max(PM2.5 - 2.4, 0))
-- ─────────────────────────────────────────────────────────────
WITH gemm_calc AS (
    SELECT
        c.city,
        c.state,
        c.pm25_annual_ugm3,
        c.population_millions * 1000000                          AS population,
        7.2                                                      AS baseline_mortality_per1000,
        -- GEMM attributable fraction
        1 - EXP(-0.0096 * GREATEST(c.pm25_annual_ugm3 - 2.4, 0)) AS attributable_fraction
    FROM city_pm25 c
    WHERE c.year = 2023
),
burden_calc AS (
    SELECT
        city,
        state,
        pm25_annual_ugm3,
        population,
        attributable_fraction,
        -- Total deaths × attributable fraction = PM2.5 deaths
        ROUND(population * (baseline_mortality_per1000 / 1000) * attributable_fraction, 0)
                                                                 AS attributable_deaths,
        -- Life years lost vs WHO guideline (AQLI: 0.098 yrs per μg/m³)
        ROUND(GREATEST(pm25_annual_ugm3 - 5.0, 0) * 0.098, 1)   AS life_years_lost
    FROM gemm_calc
)
SELECT
    city,
    state,
    pm25_annual_ugm3,
    ROUND(attributable_fraction * 100, 2)                        AS attributable_pct,
    attributable_deaths,
    life_years_lost,
    SUM(attributable_deaths) OVER ()                             AS total_all_cities,
    ROUND(attributable_deaths::DECIMAL
        / SUM(attributable_deaths) OVER () * 100, 2)             AS pct_of_total
FROM burden_calc
ORDER BY attributable_deaths DESC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 3: Seasonal PM2.5 pattern analysis (Delhi 2023)
-- Purpose : Quantify winter vs monsoon pollution ratio
-- ─────────────────────────────────────────────────────────────
WITH monthly_data AS (
    SELECT
        m.city,
        m.month_num,
        m.month_name,
        m.pm25_monthly_ugm3,
        CASE
            WHEN m.month_num IN (12, 1, 2)  THEN 'Winter'
            WHEN m.month_num IN (3, 4, 5)   THEN 'Spring'
            WHEN m.month_num IN (6, 7, 8, 9) THEN 'Monsoon'
            WHEN m.month_num IN (10, 11)    THEN 'Post-Monsoon'
        END                                                      AS season
    FROM monitoring_stations m
    WHERE m.city = 'Delhi'
      AND m.year = 2023
),
seasonal_agg AS (
    SELECT
        season,
        ROUND(AVG(pm25_monthly_ugm3), 1)                         AS avg_pm25,
        ROUND(MAX(pm25_monthly_ugm3), 1)                         AS peak_pm25,
        ROUND(MIN(pm25_monthly_ugm3), 1)                         AS min_pm25,
        COUNT(*)                                                 AS months_in_season
    FROM monthly_data
    GROUP BY season
)
SELECT
    s.season,
    s.avg_pm25,
    s.peak_pm25,
    s.min_pm25,
    s.months_in_season,
    ROUND(s.avg_pm25 / (SELECT avg_pm25 FROM seasonal_agg
        WHERE season = 'Monsoon'), 2)                            AS ratio_vs_monsoon,
    ROUND(s.avg_pm25 / 5.0, 1)                                  AS who_multiple
FROM seasonal_agg s
ORDER BY s.avg_pm25 DESC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 4: Air quality standard gap analysis
-- Purpose : Show regulatory gap between India NAAQS and WHO guidelines
-- ─────────────────────────────────────────────────────────────
SELECT
    st.standard_name,
    st.issuing_body,
    st.annual_limit_ugm3,
    st.limit_24hr_ugm3,
    st.year_issued,
    ROUND(st.annual_limit_ugm3 / 5.0, 1)                        AS multiple_of_who_2021,
    -- Cities in compliance with this standard
    (SELECT COUNT(*)
     FROM city_pm25 c
     WHERE c.year = 2023
       AND c.pm25_annual_ugm3 <= st.annual_limit_ugm3)           AS cities_compliant,
    (SELECT COUNT(*)
     FROM city_pm25 c
     WHERE c.year = 2023)                                        AS total_cities,
    -- % of 30-city population below this standard
    ROUND(
        (SELECT SUM(c.population_millions)
         FROM city_pm25 c
         WHERE c.year = 2023
           AND c.pm25_annual_ugm3 <= st.annual_limit_ugm3) /
        (SELECT SUM(c.population_millions)
         FROM city_pm25 c
         WHERE c.year = 2023) * 100, 1
    )                                                            AS pct_population_compliant
FROM standards_comparison st
ORDER BY st.annual_limit_ugm3 ASC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 5: Policy scenario — lives saved at WHO Interim Target 1 (35 μg/m³)
-- Purpose : Quantify annual lives saved if India adopted IT-1 as NAAQS
-- ─────────────────────────────────────────────────────────────
WITH current_burden AS (
    SELECT
        c.city,
        c.population_millions * 1000000                          AS population,
        c.pm25_annual_ugm3                                       AS pm25_current,
        LEAST(c.pm25_annual_ugm3, 35.0)                         AS pm25_at_it1,
        -- Deaths at current PM2.5
        ROUND((c.population_millions * 1000000) * 0.0072 *
            (1 - EXP(-0.0096 * GREATEST(c.pm25_annual_ugm3 - 2.4, 0))), 0)
                                                                 AS deaths_current,
        -- Deaths if city achieved IT-1 (35 μg/m³)
        ROUND((c.population_millions * 1000000) * 0.0072 *
            (1 - EXP(-0.0096 * GREATEST(LEAST(c.pm25_annual_ugm3, 35.0) - 2.4, 0))), 0)
                                                                 AS deaths_at_it1
    FROM city_pm25 c
    WHERE c.year = 2023
),
savings AS (
    SELECT
        city,
        deaths_current,
        deaths_at_it1,
        deaths_current - deaths_at_it1                          AS lives_saved,
        CASE WHEN pm25_current > 35.0
             THEN 'Reduction required'
             ELSE 'Already compliant'
        END                                                      AS it1_status
    FROM current_burden
)
SELECT
    city,
    deaths_current,
    deaths_at_it1,
    lives_saved,
    it1_status,
    -- Running total of lives saved
    SUM(lives_saved) OVER (ORDER BY lives_saved DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)       AS cumulative_lives_saved,
    SUM(lives_saved) OVER ()                                    AS total_lives_saved_it1
FROM savings
ORDER BY lives_saved DESC;
