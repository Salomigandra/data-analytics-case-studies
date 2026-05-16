# Data Dictionary — Geopolitical Shocks & CPI

## SQL Tables

### `cpi_monthly`
| Column | Type | Unit | Description | Source |
|--------|------|------|-------------|--------|
| month | DATE | — | First day of reference month | MoSPI |
| category | TEXT | — | `headline`, `food_beverages`, `housing`, `fuel_light`, `clothing_footwear`, `core_misc` | MoSPI CPI Press Release |
| cpi_value | FLOAT | % (YoY) | CPI inflation rate year-on-year | MoSPI / RBI DBIE Table 5 |

### `fd_rates`
| Column | Type | Unit | Description | Source |
|--------|------|------|-------------|--------|
| year | INT | — | Calendar year | — |
| sbi_1yr_rate_pct | FLOAT | % p.a. | SBI 1-year fixed deposit rate | SBI public rate card |
| hdfc_1yr_rate_pct | FLOAT | % p.a. | HDFC Bank 1-year FD rate | HDFC public rate card |

### `brent_monthly_avg`
| Column | Type | Unit | Description | Source |
|--------|------|------|-------------|--------|
| month | DATE | — | First day of month | EIA |
| brent_usd_avg | FLOAT | $/barrel | Monthly average Brent spot price | EIA DNAV |

### `rbi_policy`
| Column | Type | Unit | Description | Source |
|--------|------|------|-------------|--------|
| meeting_date | DATE | — | MPC meeting date | RBI press release |
| repo_rate_pct | FLOAT | % | Repo rate post-meeting | RBI Monetary Policy |
| change_bps | INT | basis points | Rate change (positive = hike) | RBI |

## CPI Basket Weights (Base Year 2012)
| Category | Weight |
|----------|--------|
| Food & Beverages | 45.86% |
| Housing | 10.07% |
| Fuel & Light | 6.84% |
| Clothing & Footwear | 6.53% |
| Core (Misc. incl. education, health, transport) | 28.32% |
| **Total** | **100%** |

## Key Formulas

**FD Real Return**
```
real_return = nominal_fd_rate - avg_annual_cpi
```

**Purchasing Power Index**
```
real_value_t = initial_value × ∏(1 + fd_rate_i - cpi_rate_i)
               for each year i from start to t
```
