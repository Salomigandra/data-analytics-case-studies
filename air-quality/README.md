# India Air Quality & PM2.5 Burden
### 104,300 Premature Deaths Attributable to Particulate Pollution

---

## Business Question

> How many premature deaths are attributable to PM2.5 exposure across Indian cities,
> and how does India's national air quality standard compare to WHO guidelines?

---

## Data Sources

| Dataset | Source | URL | Period |
|---------|--------|-----|--------|
| Real-time PM2.5 by City | CPCB (Central Pollution Control Board) | [cpcb.nic.in/air-quality-index](https://cpcb.nic.in/air-quality-index/) | 2022–2024 |
| Air Quality Life Index (AQLI) | EPIC, Univ. of Chicago | [aqli.epic.uchicago.edu](https://aqli.epic.uchicago.edu/the-index/) | 2022 |
| WHO Air Quality Guidelines | World Health Organization | [who.int/news-room/fact-sheets/detail/ambient](https://www.who.int/news-room/fact-sheets/detail/ambient-(outdoor)-air-quality-and-health) | 2021 |
| India NAAQS Standard | MoEFCC / CPCB | [cpcb.nic.in/naaqs](https://cpcb.nic.in/naaqs/) | Revised 2009 |
| Global Burden of Disease | IHME | [healthdata.org/gbd](https://www.healthdata.org/gbd) | 2019 |
| India Census / City Population | Census of India | [censusindia.gov.in](https://censusindia.gov.in) | 2011 (projected 2024) |

---

## Methodology

### 1. GEMM Health-Impact Model

The **Global Exposure Mortality Model (GEMM)** is the WHO-endorsed standard for estimating PM2.5-attributable deaths:

```
AF = 1 - exp(−β × max(PM2.5_annual - CF, 0))

where:
  AF     = attributable fraction (of deaths caused by PM2.5)
  β      = 0.0096   (GEMM coefficient for all-cause mortality)
  CF     = 2.4 μg/m³  (counterfactual — minimum exposure with no excess risk)
  PM2.5  = annual mean PM2.5 concentration (μg/m³)
```

```
Attributable_Deaths = Population × Baseline_Mortality_Rate × AF
```

### 2. Life Expectancy Loss

Using AQLI methodology:
```
Life_Years_Lost = (PM2.5_actual - PM2.5_WHO_guideline) × AQLI_coefficient
AQLI_coefficient ≈ 0.098 years per μg/m³ additional exposure
```

For Delhi (PM2.5 = 96 μg/m³, WHO guideline = 5 μg/m³):
Life years lost = (96 − 5) × 0.098 = **8.9 years**

### 3. Standard Gap Analysis

| Standard | Annual PM2.5 Limit | 24-hr Limit |
|----------|-------------------|-------------|
| WHO 2021 | **5 μg/m³** | 15 μg/m³ |
| WHO Interim 1 | 35 μg/m³ | 75 μg/m³ |
| India NAAQS | **40 μg/m³** | 60 μg/m³ |
| Delhi actual | ~96 μg/m³ | varies |

India's standard is **8× looser** than WHO 2021 guidelines.

### 4. Seasonal Analysis

PM2.5 spikes in winter (Oct–Feb) due to:
- Stubble burning in Punjab/Haryana (Oct–Nov)
- Low wind speeds and temperature inversion trapping pollutants
- Increased biomass burning for heating

Summer levels (Mar–Jun) typically 40–60% lower than winter peak.

---

## Key Findings

1. **104,300 attributable deaths** from PM2.5 in top 30 Indian cities (GEMM model)
2. **9 of 10 most polluted cities globally** are in India (IQAir 2023 World Air Quality Report)
3. **5.3 years of life expectancy lost** on average for residents of high-pollution cities
4. **8× standard gap** — India NAAQS (40 μg/m³) vs WHO guideline (5 μg/m³)
5. **Seasonal pattern**: Winter PM2.5 is 2.3× higher than summer due to stubble burning + inversion

---

## Recommendation

> Adopt WHO Interim Target 1 (35 μg/m³) as a transitional NAAQS by 2027.
> Implement satellite-based stubble burning bans with direct cash incentives
> for farmers to adopt in-situ crop residue management. Prioritize BS-VI
> vehicle transition in top-10 polluted cities. Projected benefit: 27,000
> additional lives saved annually at IT-1 compliance.
