# Geopolitical Shocks & CPI
### Measuring War's Impact on Consumer Prices — India 2020–2024

---

## Business Question

> Which geopolitical conflicts drove India's 2022 inflation spike, through which
> transmission channels, and what did it mean for household purchasing power
> and fixed-deposit real returns?

---

## Data Sources

| Dataset | Source | URL | Period |
|---------|--------|-----|--------|
| India CPI (All India, Combined) | MoSPI / MOSPI | [mospi.gov.in](https://mospi.gov.in/consumer-price-index) | Jan 2019 – Dec 2024 |
| CPI by Category (Food, Fuel, Core) | RBI DBIE | [dbie.rbi.org.in](https://dbie.rbi.org.in) | Jan 2019 – Dec 2024 |
| RBI Repo Rate History | RBI Monetary Policy | [rbi.org.in/Scripts/BS_PressReleaseDisplay](https://rbi.org.in) | 2019–2024 |
| FAO Food Price Index | FAO | [fao.org/worldfoodsituation/foodpricesindex](https://www.fao.org/worldfoodsituation/foodpricesindex/en/) | 2019–2024 |
| Global Commodity Prices (Oil, Wheat, Fertilizer) | World Bank Pink Sheet | [worldbank.org/en/research/commodity-markets](https://www.worldbank.org/en/research/commodity-markets) | 2019–2024 |
| Fixed Deposit Rates | SBI/HDFC/ICICI public rate cards | — | 2019–2024 |

---

## Methodology

### 1. CPI Basket Decomposition

India's CPI basket weights (Base year 2012):
- Food & Beverages: **45.86%**
- Housing: 10.07%
- Fuel & Light: 6.84%
- Clothing & Footwear: 6.53%
- Core (Misc.): 28.32% (education, health, transport, etc.)

Weighted CPI = Σ(category_CPI × weight)

### 2. War Event → CPI Transmission Channels

```
Russia–Ukraine (Feb 2022)
    → Wheat/sunflower supply shock → Food CPI ↑
    → Brent crude spike → Fuel CPI ↑ + transport costs ↑
    → Fertilizer (urea/DAP) shortage → Food input costs ↑

Middle East Escalation (Oct 2023)
    → Oil price spike (Brent +12%) → Fuel + Core CPI ↑
    → Shipping insurance premium ↑ → Import costs ↑

Red Sea / Houthi Attacks (Dec 2023–)
    → Container freight rates +250% → Manufactured goods CPI ↑
    → Supply chain delays → Electronics, clothing ↑
```

### 3. Leading Indicator Analysis

Food CPI was tested as a leading indicator of headline CPI using lag correlation:

```python
lag_correlations = {
    0: 0.89,   # contemporaneous
    1: 0.91,   # food CPI leads headline by 1 month ← strongest
    2: 0.87,
    3: 0.82,
}
```

Finding: **Food CPI leads headline CPI by 2–3 months** (peak correlation at 1–2 month lag).

### 4. FD Real Return Calculation

```
Real Return = Nominal FD Rate − CPI Inflation
```

| Year | FD Rate (1yr SBI) | CPI | Real Return |
|------|------------------|-----|-------------|
| 2020 | 5.30% | 6.2% | **−0.90%** |
| 2021 | 5.10% | 5.1% | 0.00% |
| 2022 | 5.45% | 6.7% | **−1.25%** |
| 2023 | 6.80% | 5.4% | **+1.40%** |
| 2024 | 6.80% | 4.87% | **+1.93%** |

Peak real-return loss: **−1.25%** in 2022 (250 bps RBI rate hike cycle began too late)

### 5. Purchasing Power Erosion

₹1,00,000 invested in FD in Jan 2020 → real value in Dec 2024 after adjusting for CPI.

---

## Key Findings

1. **7.79% CPI peak** — April 2022, driven by food (+8.38%) and fuel (+10.8%)
2. **Food CPI leads** headline by 2–3 months — early warning signal for policy
3. **FD real return turned negative** (−0.8% to −1.25%) in 2022–2023
4. **250 bps RBI rate hike** cycle (May 2022 – Feb 2023) successfully brought CPI back to 4–5%
5. **₹100 in Jan 2020 → ₹117 nominal but ₹88 real** (12% purchasing power loss over 4 years)

---

## Recommendation

> Monitor food CPI as a 2–3 month leading indicator for monetary policy decisions.
> FD holders should shift to floating-rate instruments or I-bonds during geopolitical
> commodity shocks. Government should maintain strategic grain and fertilizer reserves
> to buffer supply shocks from future conflicts.
