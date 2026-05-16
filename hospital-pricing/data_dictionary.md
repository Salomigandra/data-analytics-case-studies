# Data Dictionary — U.S. Hospital Price Audit

**Author:** Salomi Gandra | salomigandra.com  
**Last updated:** 2024

---

## SQL Tables

### `hospital_prices`

Primary table of negotiated rates from RAND Hospital Price Transparency Study.

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `hospital_id` | VARCHAR(20) | Unique CMS Certification Number (CCN) | `140010` |
| `hospital_name` | VARCHAR(200) | Hospital facility name | `Northwestern Memorial Hospital` |
| `state` | CHAR(2) | U.S. state abbreviation | `IL` |
| `hospital_type` | VARCHAR(50) | Facility type: `Non-profit`, `For-profit`, `Government` | `Non-profit` |
| `procedure_code` | VARCHAR(10) | MS-DRG code (inpatient) or CPT/HCPCS (outpatient) | `470` |
| `procedure_name` | VARCHAR(200) | Procedure description | `Major Joint Replacement` |
| `category` | VARCHAR(100) | Procedure category grouping | `Inpatient Surgery` |
| `medicare_rate_usd` | DECIMAL(10,2) | CMS Medicare allowable payment for this DRG/CPT at this hospital | `18400.00` |
| `private_rate_usd` | DECIMAL(10,2) | Negotiated rate with largest private insurer at this hospital | `51520.00` |
| `cash_rate_usd` | DECIMAL(10,2) | Self-pay / uninsured rate (chargemaster) | `95000.00` |
| `claim_volume` | INT | Estimated annual claim volume for this procedure at this hospital | `847` |
| `year` | INT | Rate year | `2022` |
| `price_source` | VARCHAR(50) | Source: `machine_readable_file`, `rand_estimate`, `cms_extract` | `machine_readable_file` |

**Source:** RAND Corporation RRA1168-2; CMS Hospital Price Transparency machine-readable files  
**Row count:** ~4,000 hospitals × avg 25 procedures = ~100,000 rows

---

### `compliance_audit`

Hospital-level compliance with CMS Price Transparency Rule (effective Jan 1, 2021).

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `hospital_id` | VARCHAR(20) | CMS Certification Number (FK → hospital_prices) | `140010` |
| `hospital_name` | VARCHAR(200) | Facility name | `Northwestern Memorial Hospital` |
| `state` | CHAR(2) | State abbreviation | `IL` |
| `audit_year` | INT | Year of compliance audit | `2023` |
| `file_present` | BOOLEAN | Machine-readable file exists and is reachable | `TRUE` |
| `publicly_accessible` | BOOLEAN | No login, registration, or CAPTCHA required to access file | `TRUE` |
| `all_fields_present` | BOOLEAN | All 5 CMS required data elements present in file | `FALSE` |
| `updated_within_12m` | BOOLEAN | File last-modified date within 12 months of audit date | `TRUE` |
| `follows_cms_schema` | BOOLEAN | JSON/CSV follows CMS field naming and format specification | `FALSE` |
| `fully_compliant` | BOOLEAN | TRUE only if all 5 criteria above are TRUE | `FALSE` |
| `cms_warning_issued` | BOOLEAN | Hospital received CMS non-compliance notice | `TRUE` |
| `fine_amount_usd` | DECIMAL(10,2) | CMS fine levied ($300/day); NULL if no fine | `109500.00` |
| `auditor_notes` | TEXT | Qualitative notes from audit review | `File present but schema non-conforming` |

**Source:** CMS Hospital Price Transparency enforcement data; RAND HPTP audit cross-reference  
**CMS compliance standard:** 42 CFR § 180.40–180.60

---

### `oecd_spending`

International health expenditure and outcome benchmarks from OECD SHA database.

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `country` | VARCHAR(50) | Country name | `United States` |
| `country_code` | CHAR(3) | ISO 3166-1 alpha-3 | `USA` |
| `year` | INT | Reference year | `2022` |
| `per_capita_spend_usd` | INT | Total health expenditure per capita, USD PPP-adjusted | `12555` |
| `pct_gdp` | DECIMAL(5,2) | Health spend as % of GDP | `16.90` |
| `life_expectancy_years` | DECIMAL(4,1) | Period life expectancy at birth (both sexes) | `76.4` |
| `infant_mortality_per_1000` | DECIMAL(5,2) | Infant deaths per 1,000 live births | `5.4` |
| `physician_density` | DECIMAL(4,2) | Practicing physicians per 1,000 population | `2.6` |
| `hospital_beds_per_1000` | DECIMAL(4,2) | Inpatient care beds per 1,000 population | `2.5` |
| `public_spend_pct` | DECIMAL(5,2) | Government / compulsory share of total health spend (%) | `48.2` |

**Source:** OECD Health Statistics — System of Health Accounts (SHA) 2023 edition  
**URL:** [stats.oecd.org/Index.aspx?DataSetCode=SHA](https://stats.oecd.org/Index.aspx?DataSetCode=SHA)

---

## Python Analysis Constants

| Constant | Value | Description | Source |
|----------|-------|-------------|--------|
| `N_HOSPITALS` | 4,000 | RAND study sample size | RAND RRA1168-2 (2023) |
| `RAND_MEAN_RATIO` | 2.35 | Mean private/Medicare price ratio across all procedures | RAND RRA1168-2 |
| `RAND_STD_RATIO` | 0.55 | Standard deviation of price ratios | RAND RRA1168-2 |
| `NON_COMPLIANT_PCT` | 44.1 | % hospitals non-compliant with CMS transparency rule | RAND/CMS audit cross-reference, 2023 |
| `US_PER_CAPITA_SPEND` | $12,555 | U.S. health spend per capita (2022, USD PPP) | OECD Health Statistics 2023 |
| `GERMANY_PER_CAPITA` | $7,383 | Germany (2nd highest OECD) health spend per capita | OECD Health Statistics 2023 |
| `TOTAL_US_HEALTH_SPEND_BN` | $4,500B | Total U.S. health expenditure, 2022 | CMS National Health Expenditures (NHE) |
| `PRIVATE_INSURER_SHARE` | 0.31 | Private health insurance share of total NHE | CMS NHE 2022 |
| `AVG_PROPOSED_RATIO` | 1.60 | Proposed reference price cap: 160% of Medicare | RAND recommendation (RRA1168-2) |
| `AMERICANS_WITH_DEBT` | 100,000,000 | Americans carrying medical debt | CFPB 2023 |
| `MEDIAN_DEBT_USD` | $2,500 | Median medical debt per debtor | CFPB Consumer Credit Panel 2023 |
| `CMS_DAILY_FINE` | $300 | Current CMS daily fine for transparency non-compliance | 42 CFR § 180.95 |
| `PROPOSED_DAILY_FINE` | $10,000 | Proposed effective deterrent fine level | Health Affairs (2023) |

---

## Procedure Categories

| Category | MS-DRG / CPT Range | Examples |
|----------|-------------------|---------|
| Inpatient Surgery | MS-DRG 001–999 | Joint replacement (DRG 470), Cardiac surgery (DRG 216–221) |
| Specialty Drugs (Infusion) | HCPCS J-codes | Biologics, chemotherapy, IVIG |
| Outpatient Imaging (MRI) | CPT 70553, 71552, 73223 | Brain MRI, spine MRI, knee MRI |
| Emergency Room (Moderate) | CPT 99283–99284 | Level 3–4 ED visit |
| Lab & Diagnostics | CPT 80000–89999 | Metabolic panel, CBC, lipid panel |

---

## CMS Price Transparency Rule Reference

| Requirement | Regulation | Effective |
|-------------|------------|---------|
| Machine-readable file (MRF) | 45 CFR § 180.50 | Jan 1, 2021 |
| Standard charges: gross, discounted cash, min/max negotiated | 45 CFR § 180.50(b) | Jan 1, 2021 |
| Shoppable services consumer display | 45 CFR § 180.60 | Jan 1, 2021 |
| CMS JSON/CSV schema v2.0 compliance | CMS Technical Implementation Guide | Jul 1, 2024 |
| Daily civil monetary penalty | 42 CFR § 180.95 | $300/day (small) / $5,500/day (large) |

---

## Key References

| Citation | URL |
|----------|-----|
| RAND Hospital Price Transparency Study (RRA1168-2) | [rand.org/pubs/research_reports/RRA1168-2](https://www.rand.org/pubs/research_reports/RRA1168-2.html) |
| KFF Health System Tracker | [healthsystemtracker.org](https://www.healthsystemtracker.org) |
| OECD Health Statistics | [stats.oecd.org](https://stats.oecd.org) |
| CMS Price Transparency | [cms.gov/hospital-price-transparency](https://www.cms.gov/hospital-price-transparency) |
| CFPB Medical Debt Report | [consumerfinance.gov](https://www.consumerfinance.gov/about-us/newsroom/cfpb-finds-that-medical-debt-is-inaccurate-and-unfair/) |
| CMS National Health Expenditures | [cms.gov/research-statistics-data-and-systems/statistics-trends-and-reports/nationalhealthexpenddata](https://www.cms.gov/research-statistics-data-and-systems/statistics-trends-and-reports/nationalhealthexpenddata) |
