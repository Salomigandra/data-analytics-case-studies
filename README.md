# Data Analytics Case Studies — Salomi Gandra

> **Portfolio:** [salomigandra.com](https://salomigandra.me) · [LinkedIn](https://www.linkedin.com/in/salomisabastian) · [Email](mailto:salomigandra234@gmail.com)

data analytics case studies covering macroeconomics, public health, environmental policy, and healthcare. Each study includes a clear business question, real sourced data, documented methodology, reproducible code, and a decision-ready recommendation.

---

## Case Studies

| # | Study | Domain | Key Finding | Tools |
|---|-------|--------|-------------|-------|
| 1 | [Iran Shock — Energy Cost Model](./iran-shock/) | Macroeconomics | 87.1% effective cost shock on India's energy import bill | Python · SQL · Excel |
| 2 | [Geopolitical Shocks & CPI](./inflation/) | Inflation / Macro | Food CPI leads core by 2–3 months; FD real return turned negative | Python · SQL · Excel |
| 3 | [U.S. Hospital Price Audit](./hospital-pricing/) | Healthcare Policy | Private insurers pay 2.35× Medicare; 44.1% hospitals non-compliant | Python · SQL · Excel |
| 4 | [India Air Quality & PM2.5](./air-quality/) | Public Health | 104,300 attributable deaths; India's standard is 8× looser than WHO | Python · Excel |
| 5 | [National Warming Trajectories](./climate/) | Climate Science | 23.5 Gt CO₂ NDC gap by 2030; Arctic warming 3.8× global average | Python · Excel |
| 6 | [India's $340B Productivity Gap](./ist/) | Behavioral Economics | PDI–lateness correlation r = +0.94; ₹73,000 Cr annual cost model | Python · SQL · Excel |

---

## Tech Stack

```
Python 3.11+      pandas · numpy · scipy · matplotlib · seaborn
SQL               PostgreSQL-compatible syntax (window functions, CTEs, aggregations)
Excel             Pivot tables · scenario models · conditional formatting · charts
```

---

## Repository Structure

```
data-analytics-case-studies/
├── README.md                  ← You are here
├── requirements.txt           ← Python dependencies
│
├── iran-shock/
│   ├── README.md              ← Business question, methodology, findings
│   ├── analysis.py            ← Full Python analysis script
│   ├── queries.sql            ← SQL queries used in the analysis
│   └── data_dictionary.md     ← Variable definitions and data sources
│
├── inflation/
│   ├── README.md
│   ├── analysis.py
│   ├── queries.sql
│   └── data_dictionary.md
│
├── hospital-pricing/
│   ├── README.md
│   ├── analysis.py
│   ├── queries.sql
│   └── data_dictionary.md
│
├── air-quality/
│   ├── README.md
│   ├── analysis.py
│   └── data_dictionary.md
│
├── climate/
│   ├── README.md
│   ├── analysis.py
│   └── data_dictionary.md
│
└── ist/
    ├── README.md
    ├── analysis.py
    ├── queries.sql
    └── data_dictionary.md
```

---

## How to Run

```bash
# Clone the repo
git clone https://github.com/salomigandra/data-analytics-case-studies.git
cd data-analytics-case-studies

# Install dependencies
pip install -r requirements.txt

# Run any case study
python iran-shock/analysis.py
python inflation/analysis.py
# ... etc
```

---

## Methodology Principles

Each case study follows the same analytical process:

1. **Define the question** — What decision does this analysis need to support?
2. **Source and validate data** — Public datasets only; every source cited with URL and access date
3. **Clean and document** — Null handling, outlier treatment, and all assumptions documented
4. **Build the model** — Formulas are transparent, reproducible, and mathematically sound
5. **Validate findings** — Cross-check key numbers against at least two independent sources
6. **Recommend** — Every study ends with a concrete, data-backed recommendation

---


*All data used is publicly available. Sources are cited in each case study's README and data dictionary.*
