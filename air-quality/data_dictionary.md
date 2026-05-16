# Data Dictionary — India Air Quality & PM2.5 Health Burden

**Author:** Salomi Gandra | salomigandra.com  
**Last updated:** 2024

---

## SQL Tables

### `city_pm25`

Annual PM2.5 concentrations by city from CPCB monitoring network.

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `city_id` | INT | Unique city identifier | `1` |
| `city` | VARCHAR(100) | City name | `Delhi` |
| `state` | VARCHAR(50) | Indian state | `Delhi` |
| `pm25_annual_ugm3` | DECIMAL(6,2) | Annual mean PM2.5 concentration (μg/m³) | `96.40` |
| `aqi_annual` | INT | Annual mean Air Quality Index (CPCB scale) | `287` |
| `population_millions` | DECIMAL(6,2) | City population (Census 2011 projected to 2024) | `32.90` |
| `n_monitoring_stations` | INT | Number of CPCB CAAQMS stations in city | `40` |
| `year` | INT | Measurement year | `2023` |
| `data_completeness_pct` | DECIMAL(5,2) | % of hours with valid PM2.5 readings (min 75% required) | `91.30` |

**Source:** CPCB National Air Quality Index — [cpcb.nic.in/air-quality-index](https://cpcb.nic.in/air-quality-index/)  
**Row count:** 30 cities × annual records

---

### `monitoring_stations`

Monthly PM2.5 readings aggregated from CAAQMS (Continuous Ambient Air Quality Monitoring Stations).

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `station_id` | VARCHAR(20) | CPCB station code | `DPCB001` |
| `station_name` | VARCHAR(100) | Monitoring location | `Anand Vihar, Delhi` |
| `city` | VARCHAR(100) | Parent city | `Delhi` |
| `state` | VARCHAR(50) | State | `Delhi` |
| `month_num` | INT | Month number (1=Jan, 12=Dec) | `1` |
| `month_name` | CHAR(3) | Month abbreviation | `Jan` |
| `year` | INT | Year | `2023` |
| `pm25_monthly_ugm3` | DECIMAL(6,2) | Monthly mean PM2.5 (μg/m³) | `160.00` |
| `pm10_monthly_ugm3` | DECIMAL(6,2) | Monthly mean PM10 (μg/m³) | `290.00` |
| `no2_monthly_ugm3` | DECIMAL(6,2) | Monthly mean NO₂ (μg/m³) | `68.40` |
| `valid_hours` | INT | Hours with valid PM2.5 data in month | `695` |
| `latitude` | DECIMAL(8,6) | Station latitude | `28.647831` |
| `longitude` | DECIMAL(9,6) | Station longitude | `77.315808` |

**Source:** CPCB CAAQMS real-time data portal; IQAir Annual World Air Quality Report 2023

---

### `health_burden`

Pre-computed health burden metrics at city level (for validation against Python analysis).

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `city` | VARCHAR(100) | City name | `Delhi` |
| `year` | INT | Reference year | `2023` |
| `pm25_annual_ugm3` | DECIMAL(6,2) | Annual mean PM2.5 | `96.40` |
| `population` | BIGINT | City population | `32900000` |
| `baseline_mortality_per1000` | DECIMAL(5,3) | India all-cause mortality rate (SRS 2020) | `7.200` |
| `gemm_af` | DECIMAL(8,6) | GEMM attributable fraction | `0.442318` |
| `attributable_deaths` | INT | Annual deaths attributable to PM2.5 | `10451` |
| `life_years_lost` | DECIMAL(5,2) | Avg life years lost vs WHO guideline (AQLI) | `8.97` |
| `aqli_coefficient` | DECIMAL(6,4) | Life-years per μg/m³ additional exposure | `0.0980` |

**Source:** Burnett et al. (2018) PNAS; EPIC/AQLI (aqli.epic.uchicago.edu); SRS 2020

---

### `standards_comparison`

Air quality standards reference table for gap analysis.

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `standard_id` | INT | Unique identifier | `1` |
| `standard_name` | VARCHAR(100) | Standard name | `WHO 2021 Guideline` |
| `issuing_body` | VARCHAR(50) | Organization | `WHO` |
| `annual_limit_ugm3` | DECIMAL(6,1) | Annual mean PM2.5 limit (μg/m³) | `5.0` |
| `limit_24hr_ugm3` | DECIMAL(6,1) | 24-hour mean PM2.5 limit (μg/m³) | `15.0` |
| `year_issued` | INT | Year standard was published | `2021` |
| `url` | VARCHAR(300) | Source URL | `https://www.who.int/...` |

---

## Python Analysis Constants

### GEMM Model Parameters (Burnett et al. 2018)

| Constant | Value | Description | Source |
|----------|-------|-------------|--------|
| `BETA` | 0.0096 | GEMM coefficient for all-cause mortality | Burnett et al. (2018) PNAS 115(38) |
| `COUNTERFACTUAL_CF` | 2.4 μg/m³ | Theoretical minimum risk concentration (no excess risk below this) | Burnett et al. (2018) |
| `WHO_GUIDELINE_2021` | 5.0 μg/m³ | WHO 2021 annual mean PM2.5 guideline | WHO Air Quality Guidelines 2021 |
| `INDIA_NAAQS` | 40.0 μg/m³ | India National Ambient Air Quality Standard | CPCB NAAQS (revised 2009) |
| `AQLI_COEFF` | 0.098 | Life-years lost per additional μg/m³ vs WHO guideline | EPIC/AQLI (Greenstone et al.) |
| `BASELINE_MORTALITY_PER1000` | 7.2 | India all-cause mortality rate, deaths per 1,000 | SRS Statistical Report 2020, RGI India |

### GEMM Formula Reference

```
Attributable Fraction (AF) = 1 − exp(−β × max(PM2.5 − CF, 0))

Attributable Deaths = Population × (Mortality_Rate / 1000) × AF

Life Years Lost = max(PM2.5 − WHO_Guideline, 0) × AQLI_Coefficient
```

Where:
- `β = 0.0096` (all-cause mortality GEMM coefficient)
- `CF = 2.4 μg/m³` (counterfactual minimum risk concentration)
- `WHO_Guideline = 5.0 μg/m³` (WHO 2021 annual guideline)
- `AQLI_Coefficient = 0.098` years per μg/m³

### Policy Scenario Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `IT1_STANDARD` | 35.0 μg/m³ | WHO Interim Target 1 (transitional standard toward WHO guideline) |
| `IT2_STANDARD` | 25.0 μg/m³ | WHO Interim Target 2 |
| `CITY_COUNT` | 30 | Number of cities in analysis (top 30 Indian cities by population/data availability) |

---

## WHO PM2.5 Standards Reference

| Standard | Annual Limit | 24-hr Limit | Rationale |
|----------|-------------|-------------|-----------|
| WHO 2021 Guideline | 5 μg/m³ | 15 μg/m³ | Lowest level with measurable health effects |
| WHO Interim Target 1 | 35 μg/m³ | 75 μg/m³ | ~15% reduction in mortality vs. 70 μg/m³ |
| WHO Interim Target 2 | 25 μg/m³ | 50 μg/m³ | ~6% reduction in mortality vs. IT-1 |
| WHO Interim Target 3 | 15 μg/m³ | 37.5 μg/m³ | Approaching WHO guideline levels |
| India NAAQS | 40 μg/m³ | 60 μg/m³ | India national standard (revised 2009) |

**Source:** WHO Global Air Quality Guidelines, 2021 — [who.int/publications/i/item/9789240034228](https://www.who.int/publications/i/item/9789240034228)

---

## Seasonal Driver Reference (Delhi)

| Season | Months | Avg PM2.5 | Key Drivers |
|--------|--------|-----------|-------------|
| Winter | Dec–Feb | ~158 μg/m³ | Stubble burning residue, temperature inversion, heating biomass, low wind |
| Post-Monsoon | Oct–Nov | ~131 μg/m³ | Active stubble burning (Punjab/Haryana), crop residue fires |
| Spring | Mar–May | ~88 μg/m³ | Dust storms, vehicle/industrial emissions, declining inversion |
| Monsoon | Jun–Sep | ~53 μg/m³ | Wet deposition removes PM2.5, strong convection, minimal biomass burning |

---

## Key References

| Citation | URL |
|----------|-----|
| Burnett et al. (2018) — GEMM Model | [doi.org/10.1073/pnas.1803222115](https://doi.org/10.1073/pnas.1803222115) |
| CPCB — National AQI & City Data | [cpcb.nic.in/air-quality-index](https://cpcb.nic.in/air-quality-index/) |
| EPIC/AQLI — Air Quality Life Index | [aqli.epic.uchicago.edu](https://aqli.epic.uchicago.edu/the-index/) |
| WHO Air Quality Guidelines (2021) | [who.int/publications/i/item/9789240034228](https://www.who.int/publications/i/item/9789240034228) |
| India NAAQS (CPCB) | [cpcb.nic.in/naaqs](https://cpcb.nic.in/naaqs/) |
| IQAir World Air Quality Report 2023 | [iqair.com/world-air-quality-report](https://www.iqair.com/world-air-quality-report) |
| Census of India / Population Projections | [censusindia.gov.in](https://censusindia.gov.in) |
| SRS Statistical Report 2020 | [rgiindia.gov.in](https://rgiindia.gov.in) |
