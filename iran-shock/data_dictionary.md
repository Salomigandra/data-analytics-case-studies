# Data Dictionary — Iran Shock

## Tables (SQL)

### `brent_crude_prices`
| Column | Type | Unit | Description | Source |
|--------|------|------|-------------|--------|
| price_date | DATE | — | Trading day | EIA |
| brent_usd | FLOAT | $/barrel | Brent crude spot price | EIA DNAV |

### `inr_usd_rates`
| Column | Type | Unit | Description | Source |
|--------|------|------|-------------|--------|
| rate_date | DATE | — | Date of rate | RBI DBIE |
| inr_per_usd | FLOAT | ₹/$ | Mid-market INR/USD rate | RBI Reference Rate |

### `pump_prices_ppac`
| Column | Type | Unit | Description | Source |
|--------|------|------|-------------|--------|
| month | DATE | — | First day of month | PPAC |
| actual_pump_price_delhi_inr | FLOAT | ₹/litre | Petrol retail price, Delhi | PPAC daily price notification |

### `household_quintiles`
| Column | Type | Unit | Description | Source |
|--------|------|------|-------------|--------|
| quintile_label | TEXT | — | Q1 (bottom) to Q5 (top) | HCES 2022-23 |
| avg_monthly_income_inr | INT | ₹ | Average monthly household income | HCES 2022-23 Table 3R |
| fuel_expenditure_share_pct | FLOAT | % | % of income spent on fuel | HCES 2022-23 Table 5R |

### `india_crude_imports`
| Column | Type | Unit | Description | Source |
|--------|------|------|-------------|--------|
| origin_country | TEXT | — | Country of crude origin | PPAC Import Data |
| import_volume_mbpd | FLOAT | Million barrels/day | Volume imported | PPAC FY2023-24 |
| transits_hormuz | BOOLEAN | — | Whether route passes Strait of Hormuz | Geographic assessment |
| fiscal_year | TEXT | — | Indian fiscal year (Apr–Mar) | PPAC |

## Python Constants

| Variable | Value | Unit | Rationale |
|----------|-------|------|-----------|
| `BARREL_TO_LITRES` | 158.987 | litres/barrel | Standard international conversion |
| `CRUDE_YIELD_RATIO` | 0.65 | ratio | ~65% of crude barrel yields petrol (industry avg) |
| `DUTY_MARGIN_FACTOR` | 1.45 | multiplier | Central excise + state VAT + dealer commission (India FY2024) |
| `DAILY_CONSUMPTION_ML` | 9,200 | million litres/day | PPAC FY2024 daily demand |
| `UNDER_RECOVERY_PER_LITRE` | ₹18.5 | ₹/litre | Gap between cost price and selling price at peak shock |
| `HORMUZ_SHARE_PCT` | 20% | % | Estimated share of India crude imports via Strait of Hormuz |
