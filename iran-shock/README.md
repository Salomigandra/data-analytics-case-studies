# The Iran Shock: Modeling How an Oil Crisis Impacts Indian Households
### Hormuz Closure Risk — Quantifying India's Compound Energy, Aviation & Food Supply Shock

---

## Project Summary

**One-line description:** Built an interactive economic impact simulator that models how crude oil shocks, rupee depreciation, and fuel-price pass-through affect Indian household budgets and national import pressure.

**Problem statement:** When the US-Israel military operations against Iran triggered a Strait of Hormuz closure in early 2026, India — which imports ~85% of its crude oil — faced a compounding shock across fuel, LPG, aviation, food, and currency. The question this project answers: *How does a geopolitical oil price shock transmit into a household-level economic impact across India's income groups, and what behavioral responses can measurably reduce the pressure?*

**Live interactive version:** [salomigandra.me/work/iran-shock](https://www.salomigandra.me/work/iran-shock)

---

## My Role

- Built a React-based interactive household impact simulator (fuel, LPG, food pass-through)
- Modeled the oil-to-pump-price transmission formula from first principles using PPAC and EIA data
- Structured macroeconomic data from 8 public sources (RBI, PPAC, EIA, MOSPI, IOCL, DGCA, HCES, Fed H.10)
- Built quintile-level household impact model using HCES 2022-23 expenditure data
- Designed 4-measure "Modi's Playbook" calculator with national aggregate impact estimates
- Translated technical economic analysis into a public-facing decision tool for a general audience

---

## Conflict & Economic Timeline

| Date | Event |
|------|-------|
| Feb 2026 | US and Israel launch military operations against Iran's nuclear programme |
| Mar 4, 2026 | Iran declares Strait of Hormuz closed; Brent crude surges |
| Mar 4–27 | Brent rises from $72.5 → $112.6 — a 55% spike in under 4 weeks |
| Mar 27 | India cuts excise duty on petrol and diesel by ₹10/L |
| Apr 1, 2026 | ATF price doubles to ₹2,07,341/kl (+114.5%) |
| Apr–May 2026 | Brent above $115; OMC cumulative losses ~₹1 lakh Cr; rupee hits ₹95.7/$ intraday |
| May 10–11 | PM Modi makes public appeal on WFH, gold imports, travel, and fuel use |

---

## Assumptions & Data Notes

- **Exchange rates:** ₹95.7/$ = intraday low (May 2026, Federal Reserve H.10 / RBI DBIE); ₹94.5/$ = May 2026 closing average used in household calculations; ₹85.5/$ = May 2025 baseline
- **Crude prices:** $72.5/barrel = pre-crisis baseline (Feb 2026 start); $114/barrel = peak reported by CNBC/EIA
- **OMC under-recovery:** ₹14/L petrol, ₹42/L diesel — derived from IOCL/BPCL quarterly disclosures and Business Standard reporting
- **Household impact:** Scenario-based; uses simplified linear pass-through. Actual impact depends on government pricing decisions. Not a forecast.
- **Quintile data:** HCES 2022-23 (MoSPI) — expenditure shares may differ from current household reality
- **ATF figure:** ₹2,07,341/kl = IOCL fuel price notification, April 1, 2026
- **Aviation flights:** −1,034 weekly international flights in May 2026 vs year-ago — DGCA/CAPA India

---

## Data Sources

| Dataset | Source | URL | Period |
|---------|--------|-----|--------|
| Brent Crude Spot Price | U.S. EIA | [eia.gov/dnav/pet](https://www.eia.gov/dnav/pet/pet_pri_spt_s1_d.htm) | Jan 2022 – May 2026 |
| INR/USD Exchange Rate | Federal Reserve H.10 / RBI DBIE | [federalreserve.gov/releases/H10](https://www.federalreserve.gov/releases/H10/) | Jan 2022 – May 2026 |
| India Pump Prices (Petrol/Diesel) | PPAC | [ppac.gov.in](https://ppac.gov.in/content/price-petrol-diesel) | Jan 2022 – May 2026 |
| ATF Price Data | IOCL Fuel Price Notifications | [iocl.com/fuelprice](https://www.iocl.com/fuelprice) | Apr 2026 |
| Airline Route Data | DGCA / CAPA India | [dgca.gov.in](https://dgca.gov.in) | May 2026 |
| OMC Under-Recovery Data | IOCL Annual Report + Business Standard | [iocl.com/investor-relations](https://www.iocl.com/investor-relations) | FY 2025–26 |
| Household Expenditure Survey | HCES 2022-23, MoSPI | [mospi.gov.in](https://mospi.gov.in) | 2022–23 |
| India Crude Import Mix | PPAC Oil Import Data | [ppac.gov.in](https://ppac.gov.in/content/consumption) | 2023–24 |

---

## Methodology

### 1. Pump Price Transmission Model

```
Pump Price = (Brent_USD × INR_USD) / 158.987 / 0.65 × Duty_Margin_Factor
```

Where:
- `158.987` = litres per barrel (standard conversion)
- `0.65` = crude-to-petrol yield ratio (~65% refinery recovery, industry standard)
- `Duty_Margin_Factor = 1.45` = excise duty + dealer margin multiplier

**Baseline** (Feb 2026): Brent $72.5, ₹85.5/$ → model pump price ≈ ₹88.5/litre  
**Shock** (May 2026): Brent $114, ₹94.5/$ → model pump price ≈ ₹146.2/litre  
**Theoretical shock = +65%** (actual pump prices frozen by government policy)

### 2. OMC Daily Under-Recovery

```
OMC_Loss_per_day = (Under_recovery_per_litre × Daily_fuel_consumption_litres) / 10,000,000
```

Under-recovery ≈ ₹18.5/litre blended (petrol + diesel); daily consumption ≈ 9,200 million litres (PPAC) → **₹1,702 Cr/day**

### 3. Quintile Impact Model

Household fuel expenditure share from HCES 2022-23:

| Quintile | Monthly Income | Fuel Spend Share | Absolute Fuel Cost |
|----------|---------------|------------------|--------------------|
| Q1 (Bottom 20%) | ≤ ₹10,000 | 8.2% | ₹820 |
| Q2 | ₹10,001–20,000 | 6.4% | ₹960 |
| Q3 | ₹20,001–35,000 | 5.1% | ₹1,071 |
| Q4 | ₹35,001–60,000 | 4.2% | ₹1,680 |
| Q5 (Top 20%) | > ₹60,000 | 3.1% | ₹3,100 |

Shock applied proportionally: bottom quintile faces 2.6× greater **relative** burden vs top quintile.

---

## Key Findings

1. **~65% theoretical pump price shock** — compound effect of crude spike ($72.5→$114) + rupee depreciation (₹85.5→₹94.5); actual pump prices frozen by government policy
2. **₹1,700 Cr/day OMC under-recoveries** — cumulative ~₹1 lakh Cr over 10 weeks
3. **Regressive impact** — lowest quintile spends 8.2% of income on fuel vs 3.1% for top quintile
4. **ATF crisis** — Aviation Turbine Fuel doubled to ₹2,07,341/kl (+114.5%) as of April 1, 2026; airline cost share rose from 30–40% to 55–60%
5. **Aviation disruption** — Indian carriers cut 1,034 international weekly flights in May 2026; Air India Express slashed 53% of its international schedule
6. **Food supply chain** — India sources ~35% of fertilizers from the Gulf; Hormuz disruption threatens Kharif 2026 inputs and food inflation (4.2% in April 2026)
7. **Strait risk premium** — 50% of India's crude transits Hormuz; a 30-day closure adds ~$8–12/barrel freight surcharge

---

## Files

| File | Description |
|------|-------------|
| `README.md` | Project overview, methodology, assumptions, data sources (this file) |
| `analysis.py` | Python script — pump price model, OMC under-recovery calculations, quintile impact model, household savings estimates |
| `queries.sql` | SQL queries — crude price correlation, import origin mix, quintile cost impact joins |
| `data_dictionary.md` | All variable definitions, units, source URLs, and field-level notes |

---

## Screenshots

> Interactive version at [salomigandra.me/work/iran-shock](https://www.salomigandra.me/work/iran-shock)

The live case study includes:
- Animated rupee depreciation chart (Mar 2025 → May 2026)
- Brent crude price timeline with annotated events
- Sector impact tabs (fuel, LPG, food, aviation, EMIs)
- Household impact calculator (sliders for commute, gold, travel)
- National aggregate impact calculator

---

## Recommendation

Diversify crude import routes (accelerate long-term contracts with Russia/Central Asia); build 90-day strategic petroleum reserves; introduce a fuel-price stabilisation fund to buffer Q1–Q2 households during oil price shocks.
