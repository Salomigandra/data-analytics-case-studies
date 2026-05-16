-- =============================================================
-- India Startup Talent: Entry-Level Paradox — SQL Queries
-- Author  : Salomi Gandra | salomigandra.com
-- Tables  : job_postings, employee_profiles, salary_benchmarks, startup_cohort
-- =============================================================


-- ─────────────────────────────────────────────────────────────
-- QUERY 1: Entry-level paradox rate by sector
-- Purpose : Identify sectors where "entry-level" = misleading label
-- ─────────────────────────────────────────────────────────────
WITH posting_classification AS (
    SELECT
        jp.sector,
        jp.posting_id,
        jp.title,
        jp.seniority_label,
        jp.min_years_required,
        -- Flag: labelled entry-level but requires 3+ years
        CASE
            WHEN jp.seniority_label IN ('Entry Level', 'Junior', 'Associate', 'Fresher')
             AND jp.min_years_required >= 3
            THEN 1 ELSE 0
        END                                                     AS is_paradox,
        -- Flag: genuinely entry-level (0–1 yr experience)
        CASE
            WHEN jp.seniority_label IN ('Entry Level', 'Junior', 'Associate', 'Fresher')
             AND jp.min_years_required <= 1
            THEN 1 ELSE 0
        END                                                     AS is_genuine_entry
    FROM job_postings jp
    WHERE jp.posting_date >= '2023-01-01'
      AND jp.country = 'India'
      AND jp.company_stage IN ('Seed', 'Series A', 'Series B', 'Series C', 'Growth')
)
SELECT
    sector,
    COUNT(*)                                                    AS total_postings,
    SUM(CASE WHEN seniority_label IN ('Entry Level', 'Junior', 'Associate', 'Fresher')
             THEN 1 ELSE 0 END)                                 AS entry_level_labelled,
    SUM(is_paradox)                                             AS paradox_postings,
    SUM(is_genuine_entry)                                       AS genuine_entry_postings,
    ROUND(SUM(is_paradox)::DECIMAL /
        NULLIF(SUM(CASE WHEN seniority_label IN ('Entry Level', 'Junior', 'Associate', 'Fresher')
                       THEN 1 ELSE 0 END), 0) * 100, 1)        AS paradox_rate_pct,
    ROUND(AVG(min_years_required), 1)                          AS avg_min_exp_required,
    RANK() OVER (ORDER BY
        SUM(is_paradox)::DECIMAL /
        NULLIF(SUM(CASE WHEN seniority_label IN ('Entry Level', 'Junior', 'Associate', 'Fresher')
                       THEN 1 ELSE 0 END), 0) DESC)            AS paradox_rank
FROM posting_classification
GROUP BY sector
HAVING COUNT(*) >= 100   -- minimum sample size
ORDER BY paradox_rate_pct DESC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 2: Salary distribution and compression by city tier
-- Purpose : Quantify geographic salary disparity for junior roles
-- ─────────────────────────────────────────────────────────────
SELECT
    sb.city_tier,
    sb.sector,
    COUNT(*)                                                    AS data_points,
    ROUND(AVG(sb.salary_lpa), 2)                               AS mean_salary_lpa,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP
        (ORDER BY sb.salary_lpa), 2)                           AS median_salary_lpa,
    ROUND(PERCENTILE_CONT(0.10) WITHIN GROUP
        (ORDER BY sb.salary_lpa), 2)                           AS p10_salary_lpa,
    ROUND(PERCENTILE_CONT(0.90) WITHIN GROUP
        (ORDER BY sb.salary_lpa), 2)                           AS p90_salary_lpa,
    ROUND(
        PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY sb.salary_lpa) /
        PERCENTILE_CONT(0.10) WITHIN GROUP (ORDER BY sb.salary_lpa)
    , 2)                                                       AS compression_ratio,
    -- Tier-1 premium vs this tier
    ROUND(
        AVG(sb.salary_lpa) /
        AVG(AVG(sb.salary_lpa)) FILTER (WHERE sb.city_tier = 'Tier 1')
            OVER (PARTITION BY sb.sector)
    , 2)                                                       AS ratio_vs_tier1
FROM salary_benchmarks sb
WHERE sb.experience_band = 'junior'   -- 0–2 years experience
  AND sb.survey_year = 2023
GROUP BY sb.city_tier, sb.sector
ORDER BY sb.sector, sb.city_tier;


-- ─────────────────────────────────────────────────────────────
-- QUERY 3: Attrition tracking with tenure cohort analysis
-- Purpose : Show when junior employees leave and why (first 24 months)
-- ─────────────────────────────────────────────────────────────
WITH tenure_cohort AS (
    SELECT
        ep.employee_id,
        ep.sector,
        ep.city_tier,
        ep.hire_date,
        ep.exit_date,
        ep.exit_reason,
        ep.salary_at_hire_lpa,
        -- Tenure in months
        EXTRACT(MONTH FROM AGE(
            COALESCE(ep.exit_date, CURRENT_DATE), ep.hire_date
        ))                                                      AS tenure_months,
        -- Still active flag
        CASE WHEN ep.exit_date IS NULL THEN 1 ELSE 0 END       AS still_active
    FROM employee_profiles ep
    WHERE ep.seniority_at_hire = 'junior'
      AND ep.hire_date BETWEEN '2021-01-01' AND '2022-12-31'
)
SELECT
    sector,
    COUNT(*)                                                    AS cohort_size,
    -- Survival at key milestones
    ROUND(SUM(CASE WHEN tenure_months >= 6  OR still_active = 1
                   THEN 1 ELSE 0 END)::DECIMAL / COUNT(*) * 100, 1) AS survived_6m_pct,
    ROUND(SUM(CASE WHEN tenure_months >= 12 OR still_active = 1
                   THEN 1 ELSE 0 END)::DECIMAL / COUNT(*) * 100, 1) AS survived_12m_pct,
    ROUND(SUM(CASE WHEN tenure_months >= 18 OR still_active = 1
                   THEN 1 ELSE 0 END)::DECIMAL / COUNT(*) * 100, 1) AS survived_18m_pct,
    -- Most common exit reason
    MODE() WITHIN GROUP (ORDER BY exit_reason)                 AS top_exit_reason,
    ROUND(AVG(salary_at_hire_lpa), 2)                         AS avg_hire_salary_lpa,
    ROUND(AVG(tenure_months) FILTER (WHERE still_active = 0), 1) AS avg_tenure_months_exiters
FROM tenure_cohort
GROUP BY sector
ORDER BY survived_18m_pct ASC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 4: Skills gap — most demanded vs. fresher CV frequency
-- Purpose : Identify curriculum-market skills mismatch
-- ─────────────────────────────────────────────────────────────
WITH skill_demand AS (
    SELECT
        unnest(jp.required_skills)                              AS skill,
        COUNT(*)                                                AS posting_count,
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()               AS pct_of_postings
    FROM job_postings jp
    WHERE jp.posting_date >= '2023-01-01'
      AND jp.seniority_label IN ('Entry Level', 'Junior', 'Fresher', 'Associate')
      AND jp.country = 'India'
    GROUP BY unnest(jp.required_skills)
),
skill_supply AS (
    SELECT
        unnest(ep.listed_skills)                                AS skill,
        COUNT(*)                                                AS profile_count,
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()               AS pct_of_profiles
    FROM employee_profiles ep
    WHERE ep.years_experience <= 1   -- genuine freshers
      AND ep.country = 'India'
    GROUP BY unnest(ep.listed_skills)
)
SELECT
    d.skill,
    ROUND(d.pct_of_postings, 1)                                AS required_in_pct_postings,
    ROUND(COALESCE(s.pct_of_profiles, 0), 1)                   AS present_in_pct_profiles,
    ROUND(d.pct_of_postings - COALESCE(s.pct_of_profiles, 0), 1) AS gap_pp,
    CASE
        WHEN d.pct_of_postings - COALESCE(s.pct_of_profiles, 0) > 30
        THEN 'Critical gap'
        WHEN d.pct_of_postings - COALESCE(s.pct_of_profiles, 0) > 15
        THEN 'Significant gap'
        ELSE 'Manageable gap'
    END                                                         AS gap_severity
FROM skill_demand d
LEFT JOIN skill_supply s ON d.skill = s.skill
WHERE d.pct_of_postings >= 10   -- only skills required in 10%+ of postings
ORDER BY gap_pp DESC
LIMIT 20;


-- ─────────────────────────────────────────────────────────────
-- QUERY 5: Apprenticeship vs. traditional hire cohort comparison
-- Purpose : ROI of structured apprenticeship on retention and cost
-- ─────────────────────────────────────────────────────────────
WITH hire_cohorts AS (
    SELECT
        ep.employee_id,
        ep.hire_type,    -- 'apprenticeship' or 'traditional'
        ep.sector,
        ep.salary_at_hire_lpa,
        ep.stipend_lpa,                -- for apprentices during training period
        ep.training_duration_months,
        EXTRACT(MONTH FROM AGE(
            COALESCE(ep.exit_date, ep.hire_date + INTERVAL '18 months'),
            ep.hire_date
        ))                                                      AS tenure_months,
        CASE WHEN ep.exit_date IS NULL
              OR ep.exit_date > ep.hire_date + INTERVAL '18 months'
             THEN 1 ELSE 0 END                                  AS retained_18m,
        -- Total cost employer paid in 18 months
        CASE
            WHEN ep.hire_type = 'apprenticeship'
            THEN ep.stipend_lpa * (ep.training_duration_months / 12.0)
               + ep.salary_at_hire_lpa * ((18.0 - ep.training_duration_months) / 12.0)
            ELSE ep.salary_at_hire_lpa * 1.5  -- 18 months of salary
        END                                                     AS employer_cost_18m_lpa
    FROM employee_profiles ep
    WHERE ep.hire_date BETWEEN '2022-01-01' AND '2023-06-30'
      AND ep.seniority_at_hire = 'junior'
)
SELECT
    sector,
    hire_type,
    COUNT(*)                                                    AS cohort_n,
    ROUND(AVG(retained_18m) * 100, 1)                          AS retention_18m_pct,
    ROUND(AVG(employer_cost_18m_lpa), 2)                       AS avg_employer_cost_18m_lpa,
    -- Statistical test: retention difference
    ROUND(STDDEV(retained_18m::DECIMAL) /
        SQRT(COUNT(*)) * 1.96 * 100, 1)                        AS retention_95ci_pp,
    COUNT(*) FILTER (WHERE retained_18m = 1)                   AS retained_count,
    COUNT(*) FILTER (WHERE retained_18m = 0)                   AS departed_count
FROM hire_cohorts
GROUP BY sector, hire_type
ORDER BY sector, hire_type;
