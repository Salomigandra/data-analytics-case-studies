-- =============================================================
-- Global Climate Risk & Extreme Weather Costs — SQL Queries
-- Author  : Salomi Gandra | salomigandra.com
-- Tables  : natcat_events, insured_losses, temperature_anomaly, co2_levels
-- =============================================================


-- ─────────────────────────────────────────────────────────────
-- QUERY 1: Decade-level event frequency trend
-- Purpose : Quantify how often climate disasters have increased
-- ─────────────────────────────────────────────────────────────
WITH decade_events AS (
    SELECT
        FLOOR(n.event_year / 10) * 10                           AS decade_start,
        COUNT(*)                                                AS total_events,
        COUNT(CASE WHEN n.event_type = 'Meteorological' THEN 1 END) AS storm_events,
        COUNT(CASE WHEN n.event_type = 'Hydrological'   THEN 1 END) AS flood_events,
        COUNT(CASE WHEN n.event_type = 'Climatological'  THEN 1 END) AS heat_drought_events,
        COUNT(DISTINCT n.event_year)                           AS years_in_period,
        ROUND(COUNT(*) / COUNT(DISTINCT n.event_year), 1)      AS avg_events_per_year
    FROM natcat_events n
    WHERE n.event_type IN ('Meteorological', 'Hydrological', 'Climatological')
      AND n.event_year BETWEEN 1980 AND 2023
    GROUP BY FLOOR(n.event_year / 10) * 10
),
baseline AS (
    SELECT avg_events_per_year AS baseline_avg
    FROM decade_events
    WHERE decade_start = 1980
)
SELECT
    d.decade_start,
    d.decade_start + 9                                         AS decade_end,
    d.total_events,
    d.avg_events_per_year,
    d.storm_events,
    d.flood_events,
    d.heat_drought_events,
    ROUND(d.avg_events_per_year / b.baseline_avg, 2)           AS ratio_vs_1980s
FROM decade_events d
CROSS JOIN baseline b
ORDER BY d.decade_start;


-- ─────────────────────────────────────────────────────────────
-- QUERY 2: Regional protection gap analysis
-- Purpose : Show insured vs. total losses and gap by region
-- ─────────────────────────────────────────────────────────────
SELECT
    il.region,
    ROUND(SUM(il.total_economic_loss_bn), 1)                   AS total_losses_bn,
    ROUND(SUM(il.insured_loss_bn), 1)                          AS insured_losses_bn,
    ROUND(SUM(il.total_economic_loss_bn) - SUM(il.insured_loss_bn), 1)
                                                               AS protection_gap_bn,
    ROUND(
        (SUM(il.total_economic_loss_bn) - SUM(il.insured_loss_bn))
        / SUM(il.total_economic_loss_bn) * 100, 1
    )                                                          AS gap_pct,
    ROUND(SUM(il.insured_loss_bn)
        / SUM(il.total_economic_loss_bn) * 100, 1)             AS insurance_penetration_pct,
    RANK() OVER (ORDER BY SUM(il.total_economic_loss_bn) DESC) AS loss_rank,
    RANK() OVER (
        ORDER BY (SUM(il.total_economic_loss_bn) - SUM(il.insured_loss_bn)) DESC
    )                                                          AS gap_rank
FROM insured_losses il
WHERE il.loss_year BETWEEN 2000 AND 2023
GROUP BY il.region
ORDER BY total_losses_bn DESC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 3: Year-over-year insured loss trend with rolling average
-- Purpose : Smooth annual volatility to show underlying trend
-- ─────────────────────────────────────────────────────────────
SELECT
    il.loss_year,
    ROUND(SUM(il.insured_loss_bn), 1)                          AS insured_losses_bn,
    ROUND(SUM(il.total_economic_loss_bn), 1)                   AS total_losses_bn,
    ta.temp_anomaly_c,
    -- 5-year rolling average to smooth catastrophe year spikes
    ROUND(AVG(SUM(il.insured_loss_bn)) OVER (
        ORDER BY il.loss_year
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ), 1)                                                      AS rolling_5yr_avg_bn,
    -- Year-over-year growth in insured losses
    ROUND(
        (SUM(il.insured_loss_bn) -
         LAG(SUM(il.insured_loss_bn)) OVER (ORDER BY il.loss_year)) /
         LAG(SUM(il.insured_loss_bn)) OVER (ORDER BY il.loss_year) * 100
    , 1)                                                       AS yoy_growth_pct,
    -- Rank by insured losses (identify worst years)
    RANK() OVER (ORDER BY SUM(il.insured_loss_bn) DESC)        AS loss_rank
FROM insured_losses il
LEFT JOIN temperature_anomaly ta
    ON il.loss_year = ta.anomaly_year
WHERE il.loss_year BETWEEN 2000 AND 2023
GROUP BY il.loss_year, ta.temp_anomaly_c
ORDER BY il.loss_year;


-- ─────────────────────────────────────────────────────────────
-- QUERY 4: Catastrophic event type breakdown by decade
-- Purpose : Show which disaster types are growing fastest
-- ─────────────────────────────────────────────────────────────
WITH event_decade AS (
    SELECT
        CASE
            WHEN n.event_year BETWEEN 1980 AND 1999 THEN '1980–1999'
            WHEN n.event_year BETWEEN 2000 AND 2023 THEN '2000–2023'
        END                                                     AS era,
        n.event_type,
        n.event_subtype,
        COUNT(*)                                                AS event_count,
        ROUND(AVG(n.total_loss_bn), 2)                         AS avg_loss_bn,
        ROUND(SUM(n.total_loss_bn), 1)                         AS total_loss_bn,
        SUM(n.fatalities)                                      AS total_deaths
    FROM natcat_events n
    WHERE n.event_year BETWEEN 1980 AND 2023
      AND n.event_type IN ('Meteorological', 'Hydrological', 'Climatological')
    GROUP BY era, n.event_type, n.event_subtype
),
era_totals AS (
    SELECT era, SUM(event_count) AS era_total_events
    FROM event_decade
    GROUP BY era
)
SELECT
    ed.era,
    ed.event_type,
    ed.event_subtype,
    ed.event_count,
    ROUND(ed.event_count::DECIMAL / et.era_total_events * 100, 1) AS pct_of_era_events,
    ed.total_loss_bn,
    ed.total_deaths
FROM event_decade ed
JOIN era_totals et ON ed.era = et.era
ORDER BY ed.era, ed.event_count DESC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 5: CO₂ concentration milestones and warming correlation
-- Purpose : Document Keeling Curve milestones and loss correlation
-- ─────────────────────────────────────────────────────────────
WITH co2_milestones AS (
    SELECT
        c.measurement_year,
        c.co2_ppm,
        c.co2_ppm - LAG(c.co2_ppm, 1)  OVER (ORDER BY c.measurement_year) AS annual_increase,
        c.co2_ppm - LAG(c.co2_ppm, 10) OVER (ORDER BY c.measurement_year) AS decade_increase,
        CASE
            WHEN c.co2_ppm >= 420 THEN '420+ ppm era'
            WHEN c.co2_ppm >= 400 THEN '400–420 ppm era'
            WHEN c.co2_ppm >= 380 THEN '380–400 ppm era'
            WHEN c.co2_ppm >= 360 THEN '360–380 ppm era'
            ELSE 'Pre-360 ppm era'
        END                                                     AS co2_era
    FROM co2_levels c
    WHERE c.measurement_year BETWEEN 1980 AND 2023
),
era_losses AS (
    SELECT
        CASE
            WHEN co2_ppm >= 420 THEN '420+ ppm era'
            WHEN co2_ppm >= 400 THEN '400–420 ppm era'
            WHEN co2_ppm >= 380 THEN '380–400 ppm era'
            WHEN co2_ppm >= 360 THEN '360–380 ppm era'
            ELSE 'Pre-360 ppm era'
        END                                                     AS co2_era,
        ROUND(AVG(il.insured_loss_bn), 1)                      AS avg_annual_insured_loss_bn
    FROM co2_levels cl
    JOIN insured_losses il ON cl.measurement_year = il.loss_year
    GROUP BY co2_era
)
SELECT
    cm.co2_era,
    ROUND(AVG(cm.co2_ppm), 1)                                  AS avg_co2_ppm,
    ROUND(AVG(cm.annual_increase), 2)                          AS avg_annual_increase_ppm,
    el.avg_annual_insured_loss_bn,
    ROUND(el.avg_annual_insured_loss_bn /
        FIRST_VALUE(el.avg_annual_insured_loss_bn) OVER (
            ORDER BY AVG(cm.co2_ppm)
        ), 2)                                                   AS loss_ratio_vs_lowest_era
FROM co2_milestones cm
JOIN era_losses el ON cm.co2_era = el.co2_era
GROUP BY cm.co2_era, el.avg_annual_insured_loss_bn
ORDER BY AVG(cm.co2_ppm);
