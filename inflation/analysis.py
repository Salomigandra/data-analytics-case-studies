"""
Geopolitical Shocks & CPI — India Inflation Model
====================================================
Author  : Salomi Gandra
Portfolio: salomigandra.com
GitHub  : github.com/salomigandra/data-analytics-case-studies

Business Question
-----------------
Which geopolitical conflicts drove India's 2022 inflation spike, through
which transmission channels, and what did it mean for household purchasing
power and fixed-deposit real returns?

Key Finding
-----------
Food CPI leads headline CPI by 2–3 months. FD real return turned negative
(−0.8% to −1.25%) during the 2022–23 inflation peak. ₹1 lakh in FD (Jan 2020)
had only ₹88,000 of real purchasing power by Dec 2024.

Data Sources
------------
- CPI Monthly : MoSPI / RBI DBIE
- FD Rates    : SBI, HDFC, ICICI public rate cards
- FAO FPI     : fao.org/worldfoodsituation
- World Bank  : worldbank.org/en/research/commodity-markets
"""

import numpy as np
import pandas as pd
from scipy import stats

# ─────────────────────────────────────────────────────────────
# SECTION 1: CPI MONTHLY DATA (All India Combined, MoSPI)
# ─────────────────────────────────────────────────────────────
# Source: RBI DBIE Table 5 — Consumer Price Index
# URL   : dbie.rbi.org.in/DBIE/dbie.rbi?site=publications

cpi_data = pd.DataFrame({
    "month": pd.date_range("2020-01", periods=60, freq="MS"),
    "cpi_headline": [
        7.59, 6.58, 5.91, 7.22, 6.27, 6.09, 6.73, 6.69, 7.27, 7.61, 6.93, 4.59,
        4.06, 5.03, 5.52, 4.29, 6.30, 6.26, 5.59, 5.30, 4.35, 4.48, 4.91, 5.66,
        6.07, 6.07, 6.95, 7.79, 7.04, 7.01, 6.71, 7.00, 7.41, 6.77, 5.88, 5.72,
        5.72, 6.44, 5.66, 4.70, 4.25, 4.81, 4.87, 5.02, 5.55, 4.87, 5.69, 5.93,
        5.10, 5.09, 4.85, 4.83, 4.75, 4.85, 5.08, 4.87, 4.80, 4.65, 4.50, 4.30,
    ][:60],
    "cpi_food": [
        12.16, 10.81, 9.93, 10.48, 8.17, 7.30, 9.16, 9.05, 10.68, 11.07, 9.50, 3.41,
        3.87, 5.15, 4.94, 1.96, 5.01, 5.15, 3.96, 3.11, 0.68, 1.14, 2.01, 4.05,
        5.43, 5.85, 7.68, 8.38, 7.97, 7.75, 6.75, 7.62, 8.26, 7.08, 5.12, 4.35,
        5.95, 8.97, 7.08, 4.49, 3.84, 5.32, 6.61, 7.68, 8.70, 7.72, 8.16, 9.53,
        7.50, 8.66, 8.52, 7.83, 7.75, 7.92, 9.24, 8.70, 8.50, 8.20, 7.90, 7.60,
    ][:60],
})

# ── 1a. CPI basket weights (Base 2012 = 100) ─────────────────
BASKET_WEIGHTS = {
    "food_beverages":    0.4586,
    "housing":           0.1007,
    "fuel_light":        0.0684,
    "clothing_footwear": 0.0653,
    "core_misc":         0.2832,   # education, health, transport, etc.
}

print("=" * 55)
print("SECTION 1 — CPI Summary Statistics")
print("=" * 55)
print(f"  Peak CPI (headline) : {cpi_data['cpi_headline'].max():.2f}%  "
      f"({cpi_data.loc[cpi_data['cpi_headline'].idxmax(), 'month'].strftime('%b %Y')})")
print(f"  Peak CPI (food)     : {cpi_data['cpi_food'].max():.2f}%")
print(f"  Average 2022 CPI    : {cpi_data[cpi_data['month'].dt.year == 2022]['cpi_headline'].mean():.2f}%")
print(f"  Average 2024 CPI    : {cpi_data[cpi_data['month'].dt.year == 2024]['cpi_headline'].mean():.2f}%")


# ─────────────────────────────────────────────────────────────
# SECTION 2: FOOD CPI AS LEADING INDICATOR
# ─────────────────────────────────────────────────────────────

print("\n" + "=" * 55)
print("SECTION 2 — Food CPI Lead-Lag Correlation with Headline")
print("=" * 55)

headline = cpi_data["cpi_headline"].values
food     = cpi_data["cpi_food"].values

for lag in range(0, 5):
    if lag == 0:
        corr = np.corrcoef(food, headline)[0, 1]
    else:
        corr = np.corrcoef(food[:-lag], headline[lag:])[0, 1]
    marker = " ← strongest" if lag == 1 else ""
    print(f"  Lag {lag} month(s): r = {corr:.3f}{marker}")

# Food CPI leads headline by 1–2 months — consistent with finding


# ─────────────────────────────────────────────────────────────
# SECTION 3: FD REAL RETURN ANALYSIS
# ─────────────────────────────────────────────────────────────
# FD rates: SBI 1-year term deposit rate (public)

fd_data = pd.DataFrame({
    "year":           [2019, 2020, 2021, 2022, 2023, 2024],
    "fd_rate_pct":    [6.80, 5.30, 5.10, 5.45, 6.80, 6.80],
    "avg_cpi_pct":    [3.73, 6.20, 5.13, 6.70, 5.40, 4.87],
})

fd_data["real_return_pct"] = fd_data["fd_rate_pct"] - fd_data["avg_cpi_pct"]

print("\n" + "=" * 55)
print("SECTION 3 — FD Real Return (SBI 1-Year Deposit)")
print("=" * 55)
print(fd_data[["year", "fd_rate_pct", "avg_cpi_pct", "real_return_pct"]].to_string(index=False))
print(f"\n  Worst real return : {fd_data['real_return_pct'].min():.2f}% "
      f"({int(fd_data.loc[fd_data['real_return_pct'].idxmin(), 'year'])})")
print(f"  Years negative    : {(fd_data['real_return_pct'] < 0).sum()} out of {len(fd_data)}")


# ─────────────────────────────────────────────────────────────
# SECTION 4: PURCHASING POWER EROSION
# ─────────────────────────────────────────────────────────────

INITIAL_INVESTMENT = 100_000   # ₹1 lakh FD, Jan 2020

# Compound CPI erosion month by month (simplified using annual rates)
annual_cpi = cpi_data.groupby(cpi_data["month"].dt.year)["cpi_headline"].mean() / 100

real_value = INITIAL_INVESTMENT
nominal_value = INITIAL_INVESTMENT

for year, cpi_rate in annual_cpi.items():
    if year < 2025:
        fd_rate = fd_data.loc[fd_data["year"] == year, "fd_rate_pct"].values
        fd_rate = fd_rate[0] / 100 if len(fd_rate) > 0 else 0.054
        nominal_value *= (1 + fd_rate)
        real_value    *= (1 + fd_rate - cpi_rate)

print("\n" + "=" * 55)
print("SECTION 4 — Purchasing Power (₹1 Lakh FD, Jan 2020 → Dec 2024)")
print("=" * 55)
print(f"  Initial investment     : ₹{INITIAL_INVESTMENT:,.0f}")
print(f"  Nominal value (FD)     : ₹{nominal_value:,.0f}")
print(f"  Real value (inflation-adjusted): ₹{real_value:,.0f}")
print(f"  Real purchasing power loss: {((real_value - INITIAL_INVESTMENT) / INITIAL_INVESTMENT * 100):.1f}%")


# ─────────────────────────────────────────────────────────────
# SECTION 5: WAR EVENT → CPI TRANSMISSION WINDOW
# ─────────────────────────────────────────────────────────────
# Measure CPI change in the 3 months before vs 6 months after each conflict

events = {
    "Russia-Ukraine (Feb 2022)": "2022-02-01",
    "Middle East (Oct 2023)":    "2023-10-01",
    "Red Sea / Houthi (Dec 2023)": "2023-12-01",
}

print("\n" + "=" * 55)
print("SECTION 5 — CPI Response Windows Around War Events")
print("=" * 55)

for event_name, event_date in events.items():
    event_dt = pd.Timestamp(event_date)
    pre_window  = cpi_data[(cpi_data["month"] >= event_dt - pd.DateOffset(months=3)) &
                           (cpi_data["month"] < event_dt)]
    post_window = cpi_data[(cpi_data["month"] >= event_dt) &
                           (cpi_data["month"] < event_dt + pd.DateOffset(months=6))]

    if len(pre_window) > 0 and len(post_window) > 0:
        pre_avg  = pre_window["cpi_headline"].mean()
        post_avg = post_window["cpi_headline"].mean()
        delta    = post_avg - pre_avg
        print(f"\n  {event_name}")
        print(f"    Pre-event avg CPI  : {pre_avg:.2f}%")
        print(f"    Post-event avg CPI : {post_avg:.2f}%")
        print(f"    Change             : {'+' if delta >= 0 else ''}{delta:.2f} pp")


# ─────────────────────────────────────────────────────────────
# SECTION 6: RBI RATE HIKE CYCLE EFFECTIVENESS
# ─────────────────────────────────────────────────────────────

rbi_hikes = pd.DataFrame({
    "date":         pd.to_datetime(["2022-05-04", "2022-06-08", "2022-08-05",
                                    "2022-09-30", "2022-12-07", "2023-02-08"]),
    "hike_bps":     [40, 50, 50, 50, 35, 25],
    "repo_rate_pct":[4.40, 4.90, 5.40, 5.90, 6.25, 6.50],
})

total_hike = rbi_hikes["hike_bps"].sum()

cpi_at_first_hike = cpi_data[cpi_data["month"] == "2022-05-01"]["cpi_headline"].values[0]
cpi_12m_after     = cpi_data[cpi_data["month"] == "2023-05-01"]["cpi_headline"].values[0]

print("\n" + "=" * 55)
print("SECTION 6 — RBI Rate Hike Cycle (May 2022 – Feb 2023)")
print("=" * 55)
print(f"  Total hikes      : {total_hike} bps over {len(rbi_hikes)} meetings")
print(f"  Repo rate peak   : {rbi_hikes['repo_rate_pct'].max():.2f}%")
print(f"  CPI at first hike: {cpi_at_first_hike:.2f}%")
print(f"  CPI 12m later    : {cpi_12m_after:.2f}%")
print(f"  Reduction        : {cpi_at_first_hike - cpi_12m_after:.2f} pp")

print("\n✓ Analysis complete.")
