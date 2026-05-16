# U.S. Hospital Price Audit
### Private Insurers Pay 2.35× Medicare — And 44% of Hospitals Hid It

---

## Business Question

> By how much do U.S. hospitals charge private insurers above Medicare rates,
> which procedure categories show the highest markups, and how compliant are
> hospitals with the federal price transparency rule?

---

## Data Sources

| Dataset | Source | URL | Year |
|---------|--------|-----|------|
| Hospital Price Transparency Study | RAND Corporation | [rand.org/pubs/research_reports/RRA1168-2](https://www.rand.org/pubs/research_reports/RRA1168-2.html) | 2020–2022 |
| Health System Tracker (spending benchmarks) | KFF | [healthsystemtracker.org](https://www.healthsystemtracker.org) | 2023 |
| OECD Health Statistics | OECD | [stats.oecd.org/Index.aspx?DataSetCode=SHA](https://stats.oecd.org) | 2022 |
| CMS Price Transparency Compliance | CMS Hospital Price Transparency | [cms.gov/hospital-price-transparency](https://www.cms.gov/hospital-price-transparency) | 2023–24 |
| Medical Debt Statistics | Consumer Financial Protection Bureau | [consumerfinance.gov/about-us/newsroom](https://www.consumerfinance.gov) | 2023 |

---

## Methodology

### 1. Price Ratio Calculation

```
price_ratio = private_insurer_rate / medicare_allowable_rate
```

Data from RAND's Hospital Price Transparency Study covers 4,000+ hospitals.  
Average ratio across all procedures and hospitals: **2.35×**  
Range: 1.8× (in-network routine) to 4.2× (out-of-network specialty)

### 2. Procedure Category Analysis

| Category | Avg Price Ratio | Medicare Rate (avg) | Private Rate (avg) |
|----------|----------------|--------------------|--------------------|
| Inpatient Surgery | 2.8× | $18,400 | $51,520 |
| Outpatient Imaging (MRI) | 2.4× | $980 | $2,352 |
| Emergency Room (Moderate) | 2.1× | $590 | $1,239 |
| Lab & Diagnostics | 1.9× | $85 | $161 |
| Specialty Drugs (Infusion) | 4.2× | $2,800 | $11,760 |

### 3. Compliance Audit Methodology

CMS required all hospitals to post machine-readable price files from Jan 2021. Audit criteria:
- ✅ Machine-readable file present and accessible
- ✅ File contains standard charge, negotiated rates, and cash-pay rate
- ✅ File updated within 12 months
- ✅ File follows CMS schema (JSON or CSV with required fields)

Hospitals failing **any** criterion flagged as non-compliant.  
Result: **44.1% non-compliant** (RAND/CMS audit cross-reference, 2023)

### 4. OECD International Benchmark

Per-capita health expenditure (USD, 2022):
- 🇺🇸 United States: **$12,555**
- 🇩🇪 Germany: $7,383
- 🇨🇦 Canada: $7,179
- 🇦🇺 Australia: $5,468
- 🇫🇷 France: $5,218
- 🇮🇳 India: $267

The U.S. spends **1.7× more than Germany** (next highest) yet achieves lower life expectancy (76.4 vs 80.6 years).

### 5. Medical Debt Scope

- 100M+ Americans carry medical debt (CFPB, 2023)
- Median debt: $2,500
- Medical debt is the **#1 cause of personal bankruptcy** in the U.S.

---

## Key Findings

1. **2.35× price ratio** — private insurers pay 2.35× what Medicare pays for the same procedure
2. **44.1% non-compliant** — hospitals required to post prices, nearly half still hiding them
3. **$12,555 per capita** — U.S. spends 70% more than Germany, the next highest OECD nation
4. **Specialty drugs worst** — up to 4.2× Medicare rate for infusion therapy
5. **100M+ in debt** — price opacity directly linked to unpayable surprise bills

---

## Recommendation

> Federal reference pricing: cap private insurer rates at 150–175% of Medicare
> for in-network care. Mandate enforcement of price transparency rule with
> per-day fines for non-compliance ($300/day is currently too low — proposed
> $10,000/day would drive compliance). Estimated system savings: $180B/year.
