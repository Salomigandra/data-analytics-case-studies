# Data Dictionary — India Startup Talent: Entry-Level Paradox

**Author:** Salomi Gandra | salomigandra.com  
**Last updated:** 2024

---

## SQL Tables

### `job_postings`

Individual job posting records from LinkedIn Talent Insights / job board data.

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `posting_id` | VARCHAR(30) | Unique posting identifier | `LI_20230415_894521` |
| `company_id` | VARCHAR(20) | Employer identifier | `C_47821` |
| `company_name` | VARCHAR(200) | Employer name | `Razorpay` |
| `company_stage` | VARCHAR(20) | Startup funding stage: `Seed`, `Series A`, `Series B`, `Series C`, `Growth`, `Public` | `Series B` |
| `sector` | VARCHAR(50) | Industry sector: `Fintech`, `SaaS / Cloud`, `HealthTech`, `D2C / Ecommerce`, `Deep Tech / EV`, `EdTech` | `Fintech` |
| `title` | VARCHAR(200) | Job title as posted | `Junior Software Engineer` |
| `seniority_label` | VARCHAR(50) | Platform-assigned seniority: `Entry Level`, `Junior`, `Associate`, `Fresher`, `Mid-Senior`, `Senior` | `Entry Level` |
| `min_years_required` | INT | Minimum years of experience stated in JD | `3` |
| `max_years_required` | INT | Maximum years of experience stated (if any) | `5` |
| `required_skills` | TEXT[] | Array of required skills extracted from JD | `{Python, SQL, AWS}` |
| `city` | VARCHAR(100) | Job location | `Bengaluru` |
| `city_tier` | CHAR(6) | NASSCOM city classification: `Tier 1`, `Tier 2`, `Tier 3` | `Tier 1` |
| `country` | VARCHAR(50) | Country | `India` |
| `salary_min_lpa` | DECIMAL(6,2) | Minimum salary offered (₹ LPA); NULL if not disclosed | `6.00` |
| `salary_max_lpa` | DECIMAL(6,2) | Maximum salary offered (₹ LPA) | `9.00` |
| `posting_date` | DATE | Date posting went live | `2023-07-15` |
| `close_date` | DATE | Date posting closed (filled or expired) | `2023-09-28` |
| `days_to_fill` | INT | Days between posting and close (NULL if still open) | `75` |
| `applicant_count` | INT | Total applications received | `487` |

**Source:** LinkedIn Talent Insights; Naukri.com job analytics; AmbitionBox data  
**Period:** 2023–2024  
**Filter applied:** India-based roles only; startup companies (not MNCs or PSUs)

---

### `employee_profiles`

Employee records including tenure, skills, and exit data (anonymized).

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `employee_id` | VARCHAR(20) | Anonymized employee ID | `EMP_082941` |
| `company_id` | VARCHAR(20) | Employer (FK → job_postings) | `C_47821` |
| `sector` | VARCHAR(50) | Industry sector | `Fintech` |
| `hire_type` | VARCHAR(20) | `traditional` or `apprenticeship` | `apprenticeship` |
| `seniority_at_hire` | VARCHAR(20) | Seniority when hired: `junior`, `mid`, `senior` | `junior` |
| `years_experience` | DECIMAL(4,1) | Years of experience at time of hire | `0.5` |
| `listed_skills` | TEXT[] | Skills on LinkedIn/CV at time of application | `{Python, Git, SQL}` |
| `education_type` | VARCHAR(50) | `degree`, `bootcamp`, `self_taught`, `diploma` | `degree` |
| `city_tier` | CHAR(6) | City tier of job | `Tier 1` |
| `country` | VARCHAR(50) | Country | `India` |
| `gender` | CHAR(1) | `M`, `F`, `O` (other/not disclosed) | `F` |
| `hire_date` | DATE | Date employment started | `2022-03-01` |
| `exit_date` | DATE | Date of departure; NULL if still employed | `2023-07-15` |
| `exit_reason` | VARCHAR(100) | Exit reason: `better_offer`, `culture_fit`, `role_mismatch`, `burnout`, `relocation`, `layoff` | `better_offer` |
| `salary_at_hire_lpa` | DECIMAL(6,2) | Annual salary at hire (₹ LPA) | `7.20` |
| `salary_at_exit_lpa` | DECIMAL(6,2) | Annual salary at exit/last review | `8.50` |
| `stipend_lpa` | DECIMAL(6,2) | Monthly stipend annualized during apprenticeship; NULL for traditional | `3.00` |
| `training_duration_months` | INT | Length of apprenticeship/training period | `6` |
| `promoted_within_18m` | BOOLEAN | Received promotion within 18 months | `FALSE` |
| `performance_band` | VARCHAR(10) | Last performance review: `top`, `meets`, `below` | `meets` |

**Source:** Teamlease Services India Startup Report 2023; anonymized HR data via 91Springboard

---

### `salary_benchmarks`

Aggregated salary data by city tier, sector, and experience band.

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `benchmark_id` | INT | Unique record ID | `1` |
| `sector` | VARCHAR(50) | Industry sector | `SaaS / Cloud` |
| `city_tier` | CHAR(6) | City tier | `Tier 1` |
| `city_sample` | VARCHAR(200) | Representative cities in sample | `Bengaluru, Hyderabad, Pune` |
| `experience_band` | VARCHAR(20) | `junior` (0–2yr), `mid` (2–5yr), `senior` (5+yr) | `junior` |
| `salary_lpa` | DECIMAL(6,2) | Individual salary data point (₹ LPA) | `8.50` |
| `survey_year` | INT | Survey year | `2023` |
| `data_source` | VARCHAR(50) | `nasscom_hr_survey`, `glassdoor`, `ambitionbox`, `linkedin_salary` | `nasscom_hr_survey` |

**Source:** NASSCOM HR Survey 2023; Glassdoor India; AmbitionBox; LinkedIn Salary Insights

---

### `startup_cohort`

Startup-level funding and hiring data from Tracxn / Crunchbase.

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `company_id` | VARCHAR(20) | Company identifier | `C_47821` |
| `company_name` | VARCHAR(200) | Company name | `Razorpay` |
| `sector` | VARCHAR(50) | Sector | `Fintech` |
| `funding_stage` | VARCHAR(20) | Latest funding stage | `Series C` |
| `total_funding_usd_mn` | DECIMAL(10,2) | Total funding raised (USD millions) | `741.50` |
| `latest_round_year` | INT | Year of latest funding round | `2023` |
| `employee_count_total` | INT | Total headcount | `3200` |
| `employee_count_junior` | INT | Headcount at junior level (0–2yr) | `820` |
| `annual_hiring_plan` | INT | Planned junior hires this year | `180` |
| `city_hq` | VARCHAR(100) | Headquarters city | `Bengaluru` |
| `founded_year` | INT | Year founded | `2014` |
| `has_apprenticeship_program` | BOOLEAN | Formal apprenticeship/traineeship program in place | `FALSE` |

**Source:** Tracxn India Startup Ecosystem Report 2024; Crunchbase Pro; LinkedIn Company Pages

---

## Python Analysis Constants

| Constant | Value | Description | Source |
|----------|-------|-------------|--------|
| `OVERALL_PARADOX_RATE` | 73.0% | % of entry-level postings requiring 3+ years experience | LinkedIn Talent Insights 2023–24 |
| `ENGINEERING_GRADS_2023` | 1,500,000 | India engineering/tech graduates in 2022–23 | AICTE Annual Report 2022–23 |
| `FUNDED_STARTUP_JOBS` | 200,000 | Jobs at Series-A+ startups | Nasscom Strategic Review 2024; Tracxn |
| `FRESHER_ELIGIBLE_JOBS` | 95,000 | Jobs genuinely open to 0–1 year experience | Derived: funded jobs × (1 − paradox rate) |
| `TRADITIONAL_ATTRITION_18M` | 45% | Junior hire attrition within 18 months (traditional) | Teamlease India Startup Report 2023 |
| `APPRENTICE_ATTRITION_18M` | 18% | Junior hire attrition within 18 months (apprenticeship) | Teamlease apprenticeship benchmark |
| `REPLACEMENT_MULTIPLIER` | 1.5–2.0× | Cost to replace a junior employee as multiple of salary | SHRM India; Teamlease 2023 |
| `AVG_REPLACEMENT_COST_LPA` | ₹12.7L | Average replacement cost per junior hire | Derived from sector data |
| `APPRENTICE_CONVERSION_RATE` | 75% | % of apprentices who convert to full-time | Teamlease apprenticeship data 2023 |

---

## City Tier Classification (NASSCOM)

| Tier | Cities | Characteristics |
|------|--------|----------------|
| Tier 1 | Bengaluru, Mumbai, Delhi-NCR, Hyderabad, Chennai, Pune | Large IT/startup hubs; highest salaries; 60%+ of funded startup headcount |
| Tier 2 | Ahmedabad, Kolkata, Jaipur, Kochi, Coimbatore, Indore | Emerging tech ecosystems; growing startup activity; 25–50% lower salaries |
| Tier 3 | Bhopal, Nagpur, Lucknow, Chandigarh, Vizag | Early-stage ecosystems; talent export cities; 55–65% lower salaries than Tier 1 |

---

## Sector Definitions

| Sector | Description | Representative Companies |
|--------|-------------|--------------------------|
| Fintech | Payments, lending, insurtech, wealthtech | Razorpay, Zepto Pay, CRED, Groww, PolicyBazaar |
| SaaS / Cloud | B2B software, cloud infrastructure, cybersecurity | Freshworks, Zoho, Druva, Chargebee |
| HealthTech | Digital health, telemedicine, EHR, diagnostics | Practo, Mfine, 1mg, PharmEasy |
| D2C / Ecommerce | Direct-to-consumer brands, quick commerce, logistics | Blinkit, Nykaa, Meesho, Mamaearth |
| Deep Tech / EV | Hardware, semiconductors, clean energy, EVs | Ather Energy, Ola Electric, SigTuple |
| EdTech | Online learning, test prep, upskilling | BYJU'S, Unacademy, upGrad, Vedantu |

---

## Key References

| Citation | URL |
|----------|-----|
| LinkedIn Talent Insights | [linkedin.com/talent/insights](https://www.linkedin.com/talent/insights) |
| NASSCOM HR Survey 2023 | [nasscom.in/knowledge-center/publications](https://nasscom.in/knowledge-center/publications) |
| Teamlease India Startup Report 2023 | [teamlease.com/research](https://teamlease.com/research) |
| AICTE Annual Report 2022–23 | [aicte-india.org/reports/annual](https://www.aicte-india.org/reports/annual) |
| Tracxn India Ecosystem Report | [tracxn.com/d/hubs/india](https://tracxn.com/d/hubs/india__startup-ecosystem) |
| Nasscom Strategic Review 2024 | [nasscom.in/strategic-review](https://nasscom.in/strategic-review) |
| Ministry of Education Statistics | [education.gov.in/en](https://www.education.gov.in/en) |
