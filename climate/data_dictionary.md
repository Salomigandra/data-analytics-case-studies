# Data Dictionary — Global Climate Risk & Extreme Weather Costs

**Author:** Salomi Gandra | salomigandra.com  
**Last updated:** 2024

---

## SQL Tables

### `natcat_events`

Individual natural catastrophe event records from Munich Re NatCatSERVICE.

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `event_id` | INT | Unique event identifier | `20230001` |
| `event_year` | INT | Year of event occurrence | `2023` |
| `event_date` | DATE | Date of event (or start date for multi-day) | `2023-09-08` |
| `country` | VARCHAR(100) | Primary country affected | `Libya` |
| `region` | VARCHAR(50) | World region: `North America`, `Asia`, `Europe`, `Australia / Pacific`, `Latin America`, `Africa`, `Middle East` | `Africa` |
| `event_name` | VARCHAR(200) | Event name/identifier | `Storm Daniel - Mediterranean` |
| `event_type` | VARCHAR(50) | Primary classification: `Meteorological`, `Hydrological`, `Climatological`, `Geophysical` | `Meteorological` |
| `event_subtype` | VARCHAR(100) | Detailed type | `Tropical storm`, `Flash flood`, `Heat wave`, `Wildfire` |
| `total_loss_bn` | DECIMAL(8,3) | Total economic losses ($B, 2023 USD PPP-adjusted) | `2.500` |
| `insured_loss_bn` | DECIMAL(8,3) | Insured losses ($B, 2023 USD) | `0.500` |
| `fatalities` | INT | Confirmed deaths | `4000` |
| `affected_millions` | DECIMAL(8,2) | People affected (displaced/injured/impacted) | `1.50` |
| `data_source` | VARCHAR(50) | Primary source: `munich_re`, `swiss_re`, `em_dat` | `munich_re` |

**Source:** Munich Re NatCatSERVICE — [munichre.com/natcatservice](https://www.munichre.com/en/solutions/for-industry-clients/natcatservice.html)  
**Note:** Geophysical events (earthquakes, volcanoes) excluded from climate analysis

---

### `insured_losses`

Annual insured and total economic losses by region (Swiss Re sigma + Munich Re).

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `region` | VARCHAR(50) | World region | `North America` |
| `loss_year` | INT | Year | `2022` |
| `insured_loss_bn` | DECIMAL(8,2) | Insured losses ($B, 2023 USD, inflation-adjusted) | `125.00` |
| `total_economic_loss_bn` | DECIMAL(8,2) | Total economic losses ($B, 2023 USD) | `275.00` |
| `protection_gap_bn` | DECIMAL(8,2) | Uninsured losses = Total − Insured | `150.00` |
| `dominant_peril` | VARCHAR(100) | Largest loss contributor in this year/region | `Atlantic hurricanes` |
| `catastrophe_count` | INT | Number of billion-dollar events in year | `18` |

**Source:** Swiss Re sigma No. 1/2024; Munich Re NatCatSERVICE annual reports  
**Inflation adjustment:** U.S. CPI, base year 2023

---

### `temperature_anomaly`

Annual global surface temperature anomalies from NOAA NOAAGlobalTemp v5.1.

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `anomaly_year` | INT | Calendar year | `2023` |
| `temp_anomaly_c` | DECIMAL(5,3) | Annual mean global surface temperature departure from 1951–1980 baseline (°C) | `1.170` |
| `uncertainty_c` | DECIMAL(5,3) | 95% confidence interval (±°C) | `0.050` |
| `land_anomaly_c` | DECIMAL(5,3) | Land-only temperature anomaly | `1.540` |
| `ocean_anomaly_c` | DECIMAL(5,3) | Ocean-only temperature anomaly | `0.920` |
| `rank_warmest` | INT | Rank among all years in record (1 = warmest) | `1` |

**Source:** NOAA Global Surface Temperature (NOAAGlobalTemp v5.1)  
**URL:** [ncei.noaa.gov/products/land-based-station/noaa-global-surface-temperature](https://www.ncei.noaa.gov/products/land-based-station/noaa-global-surface-temperature)  
**Baseline:** 1951–1980 mean (same as NASA GISS)

---

### `co2_levels`

Annual atmospheric CO₂ concentrations from NOAA Mauna Loa Observatory.

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `measurement_year` | INT | Calendar year (annual mean) | `2023` |
| `co2_ppm` | DECIMAL(6,2) | Annual mean CO₂ concentration (parts per million by volume, dry air) | `421.08` |
| `co2_growth_rate` | DECIMAL(5,2) | Annual increase (ppm/year) | `2.80` |
| `data_station` | VARCHAR(50) | Monitoring station | `Mauna Loa, Hawaii` |
| `station_elevation_m` | INT | Station elevation above sea level | `3397` |

**Source:** NOAA Global Monitoring Laboratory — Keeling Curve  
**URL:** [gml.noaa.gov/ccgg/trends](https://gml.noaa.gov/ccgg/trends/)  
**Note:** Pre-industrial baseline ≈ 280 ppm (ice core records, year ~1750)

---

## Python Analysis Constants

| Constant | Value | Description | Source |
|----------|-------|-------------|--------|
| `BASELINE_INSURED_BN` | $91B/year | 2020 average annual global insured losses | Swiss Re sigma 2021 |
| `LOSS_MULTIPLIER_PER_C` | 2.0× | Loss scaling factor per 1°C additional warming | Swiss Re Institute / Munich Re cat model |
| `FREQUENCY_RATIO` | 3.4× | Climate disaster frequency 2010–2023 vs 1980–1989 | Munich Re NatCatSERVICE |
| `TOTAL_INSURED_2000_2023` | $2.8T | Total insured losses 2000–2023 (2023 USD) | Swiss Re sigma No. 1/2024 |
| `TOTAL_ECONOMIC_2000_2023` | $6.1T | Total economic losses 2000–2023 (2023 USD) | Munich Re NatCatSERVICE |
| `WARMING_TREND_PER_DECADE` | +0.18°C | Observed warming rate 1980–2023 | NOAA NOAAGlobalTemp |
| `CO2_2023` | 421.1 ppm | 2023 annual mean CO₂ | NOAA MLO |
| `CO2_PREINDUSTRIAL` | 280 ppm | Pre-industrial CO₂ baseline (~1750) | IPCC AR6 |
| `AQLI_COEFF` | 0.098 | (Not used in this study; see air-quality case study) | — |

---

## IPCC SSP Scenario Reference

| Scenario | Short Name | 2050 Warming | 2100 Warming | Description |
|----------|-----------|-------------|-------------|-------------|
| SSP1-1.9 | Very Low | +1.0°C | +1.4°C | Aggressive mitigation; net-zero ~2050 |
| SSP1-2.6 | Low | +1.2°C | +1.8°C | Strong mitigation |
| SSP2-4.5 | Medium | +1.6°C | +2.7°C | Current stated policies |
| SSP3-7.0 | High | +2.0°C | +3.6°C | Regional rivalry |
| SSP5-8.5 | Very High | +2.1°C | +4.4°C | Business as usual; high fossil fuel use |

All warming figures = °C above 1990 baseline (IPCC AR6 WGI Table SPM.1, 2021).  
**Source:** IPCC AR6 — [ipcc.ch/report/ar6/wg1](https://www.ipcc.ch/report/ar6/wg1/)

---

## Key References

| Citation | URL |
|----------|-----|
| Munich Re NatCatSERVICE | [munichre.com/natcatservice](https://www.munichre.com/en/solutions/for-industry-clients/natcatservice.html) |
| Swiss Re sigma No. 1/2024 | [swissre.com/sigma](https://www.swissre.com/institute/research/sigma-research.html) |
| NOAA Global Surface Temperature | [ncei.noaa.gov](https://www.ncei.noaa.gov/products/land-based-station/noaa-global-surface-temperature) |
| NOAA Mauna Loa CO₂ (Keeling Curve) | [gml.noaa.gov/ccgg/trends](https://gml.noaa.gov/ccgg/trends/) |
| IPCC AR6 WGI (2021) | [ipcc.ch/report/ar6/wg1](https://www.ipcc.ch/report/ar6/wg1/) |
| ND-GAIN Country Index | [gain.nd.edu/our-work/country-index](https://gain.nd.edu/our-work/country-index/) |
| UNDRR Global Assessment Report | [undrr.org/gar](https://www.undrr.org/gar) |
