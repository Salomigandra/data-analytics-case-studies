# Global Climate Risk & Extreme Weather Costs
### $2.8 Trillion in Insured Losses Since 2000 — Frequency Up 3.4× in 40 Years

---

## Business Question

> How has the frequency and economic cost of climate-related extreme weather events
> changed since 1980, which regions bear the highest uninsured loss burden, and
> what do IPCC SSP scenarios imply for insured losses by 2050?

---

## Data Sources

| Dataset | Source | URL | Period |
|---------|--------|-----|--------|
| Natural Catastrophe Losses | Munich Re NatCatSERVICE | [munichre.com/natcatservice](https://www.munichre.com/en/solutions/for-industry-clients/natcatservice.html) | 1980–2023 |
| Global Temperature Anomalies | NOAA Global Surface Temperature (NOAAGlobalTemp) | [ncei.noaa.gov](https://www.ncei.noaa.gov/products/land-based-station/noaa-global-surface-temperature) | 1880–2023 |
| CO₂ Concentrations | NOAA Global Monitoring Laboratory (Mauna Loa) | [gml.noaa.gov/ccgg/trends](https://gml.noaa.gov/ccgg/trends/) | 1958–2024 |
| SSP Emissions Scenarios | IPCC AR6 (2021) — Scenario Explorer | [scenarios.iiasa.ac.at](https://scenarios.iiasa.ac.at) | 2021–2100 |
| Insured Loss Database | Swiss Re sigma | [swissre.com/sigma](https://www.swissre.com/institute/research/sigma-research.html) | 2000–2023 |
| Country Vulnerability Index | Notre Dame Global Adaptation Initiative (ND-GAIN) | [gain.nd.edu](https://gain.nd.edu/our-work/country-index/) | 2022 |

---

## Methodology

### 1. Event Frequency Trend Analysis

Extreme weather event frequency sourced from Munich Re NatCatSERVICE:

```
Event types included:
  - Meteorological: tropical storms, extratropical storms, local wind
  - Hydrological: river floods, flash floods, storm surge
  - Climatological: heat waves, droughts, wildfires
  - Geophysical excluded (not climate-related)

Trend calculation:
  CAGR = (Events_final / Events_base) ^ (1 / n_years) - 1
  Ratio = mean(2010-2023) / mean(1980-1990)
```

### 2. Insured vs. Uninsured Loss Gap

```
Protection Gap = Total Economic Losses − Insured Losses
Protection Gap % = (Total − Insured) / Total × 100

Region-level gaps sourced from Munich Re / Swiss Re sigma annual reports.
High-income nations: ~40–50% insured
Low-income nations: <5% insured
```

### 3. Temperature Anomaly Correlation

Linear regression of annual losses against NOAA global temperature anomaly:

```
Model: Log(Insured_Losses) = α + β × Temperature_Anomaly + ε

Where:
  Temperature_Anomaly = annual mean departure from 1951–1980 baseline
  Losses inflation-adjusted to 2023 USD using U.S. CPI

Pearson r and p-value reported; non-climate factors (exposure growth, GDP,
urbanization) acknowledged as confounders.
```

### 4. IPCC Scenario Projections

SSP (Shared Socioeconomic Pathway) scenarios used:

| Scenario | Warming by 2100 | Description |
|----------|----------------|-------------|
| SSP1-1.9 | ~1.5°C | Aggressive mitigation — net-zero by 2050 |
| SSP2-4.5 | ~2.7°C | Middle of the road — current policies |
| SSP5-8.5 | ~4.4°C | Business as usual — no additional action |

Loss scaling methodology follows UNDRR (2022) risk assessment framework: catastrophe model sensitivity ~1.5–2.5× loss per 1°C warming for flood/storm perils.

---

## Key Findings

1. **3.4× frequency increase** — climate-related natural disasters increased 3.4× between 1980–1990 and 2010–2023
2. **$2.8 trillion in insured losses** since 2000 (Swiss Re sigma, 2023, inflation-adjusted)
3. **$6.1 trillion total economic losses** — 54% uninsured (Munich Re NatCatSERVICE 2023)
4. **1.5°C warming (SSP1-1.9)** limits additional loss increase to ~40% above 2020 baseline
5. **3°C warming (SSP5-8.5)** implies 3.5–4× current insured losses by 2080 — $300B+/year
6. **Asia bears 45% of losses** but only 8% are insured — largest protection gap globally
7. **+0.18°C per decade** — NOAA observed warming trend 1980–2023; statistically significant (p<0.001)

---

## Recommendation

> Mandatory climate risk disclosure (TCFD/ISSB) for all listed companies and
> institutional lenders by 2026. Parametric insurance mechanisms for agricultural
> smallholders in South and Southeast Asia (currently <2% insured). Price
> sovereign catastrophe bonds at SSP2-4.5 expected loss to close the $3.3T
> annual protection gap. Invest in nature-based solutions (coastal mangroves,
> wetland restoration) with BCR of 5:1 vs. hard infrastructure for flood risk reduction.
