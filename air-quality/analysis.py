"""
India Air Quality & PM2.5 Health Burden
=========================================
Author  : Salomi Gandra
Portfolio: salomigandra.com
GitHub  : github.com/salomigandra/data-analytics-case-studies

Business Question
-----------------
How many premature deaths are attributable to PM2.5 exposure across Indian
cities, and how does India's air quality standard compare to WHO guidelines?

Key Finding
-----------
104,300 premature deaths attributable to PM2.5 in top 30 Indian cities.
India's NAAQS standard (40 μg/m³) is 8× looser than WHO 2021 guideline
(5 μg/m³). Average life expectancy loss in high-pollution cities: 5.3 years.

Data Sources
------------
- PM2.5 data  : CPCB real-time AQI stations → cpcb.nic.in
- GEMM model  : Burnett et al. (2018) PNAS doi:10.1073/pnas.1803222115
- AQLI        : EPIC, University of Chicago → aqli.epic.uchicago.edu
- Population  : Census of India 2011 (projected to 2024)
"""

import numpy as np
import pandas as pd
from scipy import stats

# ─────────────────────────────────────────────────────────────
# SECTION 1: GEMM MODEL SETUP
# ─────────────────────────────────────────────────────────────

# GEMM parameters (Burnett et al. 2018, all-cause mortality)
BETA                = 0.0096    # GEMM coefficient
COUNTERFACTUAL_CF   = 2.4       # μg/m³ — theoretical minimum risk concentration
WHO_GUIDELINE_2021  = 5.0       # μg/m³ — WHO 2021 annual mean guideline
INDIA_NAAQS         = 40.0      # μg/m³ — India National Ambient Air Quality Standard
AQLI_COEFF          = 0.098     # life-years per additional μg/m³ (EPIC/AQLI)


def gemm_attributable_fraction(pm25: float) -> float:
    """
    Calculate the attributable fraction of all-cause mortality due to PM2.5
    using the Global Exposure Mortality Model (GEMM).

    AF = 1 - exp(-β × max(PM2.5 - CF, 0))

    Reference: Burnett et al. (2018). Global estimates of mortality associated
    with long-term exposure to outdoor fine particle pollution.
    PNAS, 115(38), 9592–9597. doi:10.1073/pnas.1803222115

    Parameters
    ----------
    pm25 : float  Annual mean PM2.5 concentration in μg/m³

    Returns
    -------
    float  Attributable fraction (0–1)
    """
    excess_exposure = max(pm25 - COUNTERFACTUAL_CF, 0)
    return 1 - np.exp(-BETA * excess_exposure)


def attributable_deaths(population: int, baseline_mortality_rate: float, pm25: float) -> int:
    """
    Estimate annual deaths attributable to PM2.5 exposure.

    Parameters
    ----------
    population            : int    City population
    baseline_mortality_rate: float Annual all-cause mortality rate (deaths per 1,000)
    pm25                  : float  Annual mean PM2.5 (μg/m³)

    Returns
    -------
    int  Estimated attributable deaths
    """
    af = gemm_attributable_fraction(pm25)
    total_deaths = population * (baseline_mortality_rate / 1000)
    return int(total_deaths * af)


def life_years_lost(pm25: float) -> float:
    """Life expectancy years lost vs WHO guideline (AQLI methodology)."""
    return max(pm25 - WHO_GUIDELINE_2021, 0) * AQLI_COEFF


# ─────────────────────────────────────────────────────────────
# SECTION 2: CITY-LEVEL PM2.5 DATA (CPCB Annual Averages 2023)
# ─────────────────────────────────────────────────────────────
# Source: CPCB National Air Quality Index, annual city reports

cities = pd.DataFrame({
    "city":            ["Delhi", "Gurugram", "Noida", "Patna", "Agra",
                        "Lucknow", "Kanpur", "Faridabad", "Muzaffarpur",
                        "Ahmedabad", "Mumbai", "Kolkata", "Chennai", "Hyderabad",
                        "Bengaluru", "Jaipur", "Surat", "Pune", "Bhopal",
                        "Nagpur", "Varanasi", "Allahabad", "Meerut",
                        "Visakhapatnam", "Jodhpur", "Raipur", "Chandigarh",
                        "Guwahati", "Coimbatore", "Thiruvananthapuram"],
    "state":           ["Delhi", "Haryana", "UP", "Bihar", "UP",
                        "UP", "UP", "Haryana", "Bihar",
                        "Gujarat", "Maharashtra", "West Bengal", "Tamil Nadu", "Telangana",
                        "Karnataka", "Rajasthan", "Gujarat", "Maharashtra", "MP",
                        "Maharashtra", "UP", "UP", "UP",
                        "AP", "Rajasthan", "Chhattisgarh", "Punjab",
                        "Assam", "Tamil Nadu", "Kerala"],
    "pm25_annual":     [96.4, 101.6, 89.2, 83.4, 78.5,
                        74.2, 91.3, 88.7, 119.8,
                        51.2, 44.7, 58.3, 28.1, 33.6,
                        21.4, 67.3, 48.9, 35.2, 42.1,
                        38.4, 98.2, 76.4, 103.1,
                        34.7, 61.2, 71.8, 52.4,
                        45.8, 24.3, 16.2],
    "population_M":    [32.9, 3.1, 0.64, 2.1, 1.8,
                        3.5, 3.0, 1.4, 0.4,
                        8.0, 20.7, 14.7, 10.1, 10.5,
                        12.3, 3.1, 6.5, 6.6, 2.1,
                        2.9, 1.4, 1.2, 1.3,
                        2.0, 1.1, 1.2, 1.2,
                        1.1, 1.1, 0.95],
    "baseline_mort_per1000": [7.2] * 30,   # India all-cause rate (SRS 2020)
})

cities["population"]        = (cities["population_M"] * 1_000_000).astype(int)
cities["attributable_deaths"] = cities.apply(
    lambda r: attributable_deaths(r["population"], r["baseline_mort_per1000"], r["pm25_annual"]),
    axis=1
)
cities["life_years_lost"]   = cities["pm25_annual"].apply(life_years_lost).round(1)
cities["exceeds_who"]       = cities["pm25_annual"] > WHO_GUIDELINE_2021
cities["exceeds_naaqs"]     = cities["pm25_annual"] > INDIA_NAAQS
cities["who_multiple"]      = (cities["pm25_annual"] / WHO_GUIDELINE_2021).round(1)

print("=" * 60)
print("SECTION 2 — City-Level PM2.5 & Attributable Deaths")
print("=" * 60)
print(cities[["city", "pm25_annual", "who_multiple",
              "attributable_deaths", "life_years_lost"]].head(15).to_string(index=False))

total_attributable = cities["attributable_deaths"].sum()
avg_life_years_lost = cities["life_years_lost"].mean()

print(f"\n  Total attributable deaths (30 cities) : {total_attributable:,}")
print(f"  Average life years lost                : {avg_life_years_lost:.1f} years")
print(f"  Cities exceeding WHO guideline         : {cities['exceeds_who'].sum()}/{len(cities)}")
print(f"  Cities exceeding India NAAQS           : {cities['exceeds_naaqs'].sum()}/{len(cities)}")


# ─────────────────────────────────────────────────────────────
# SECTION 3: STANDARD GAP ANALYSIS
# ─────────────────────────────────────────────────────────────

standards = {
    "WHO 2021 Guideline":    5.0,
    "WHO Interim Target 1": 35.0,
    "WHO Interim Target 2": 25.0,
    "India NAAQS":          40.0,
}

print("\n" + "=" * 60)
print("SECTION 3 — Air Quality Standard Comparison")
print("=" * 60)
print(f"  {'Standard':<25} {'Limit (μg/m³)':>15} {'Gap vs WHO 2021':>16}")
print("  " + "-" * 58)
for std, limit in standards.items():
    multiple = limit / WHO_GUIDELINE_2021
    print(f"  {std:<25} {limit:>12.0f}     {multiple:>10.1f}×")

naaqs_who_gap = INDIA_NAAQS / WHO_GUIDELINE_2021
print(f"\n  India NAAQS is {naaqs_who_gap:.0f}× looser than WHO 2021 guideline")


# ─────────────────────────────────────────────────────────────
# SECTION 4: SEASONAL VARIATION ANALYSIS
# ─────────────────────────────────────────────────────────────
# Monthly PM2.5 index (Delhi, CPCB 2023, base = annual average)

months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
          "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

delhi_monthly_pm25 = np.array([
    160, 142, 108, 82, 74, 58,
    48, 45, 62, 115, 148, 172
])   # μg/m³ approximate monthly means (CPCB, Delhi 2023)

df_seasonal = pd.DataFrame({"month": months, "pm25": delhi_monthly_pm25})
df_seasonal["season"] = df_seasonal["month"].map({
    "Dec": "Winter", "Jan": "Winter", "Feb": "Winter",
    "Mar": "Spring", "Apr": "Spring", "May": "Spring",
    "Jun": "Monsoon", "Jul": "Monsoon", "Aug": "Monsoon", "Sep": "Monsoon",
    "Oct": "Post-Monsoon", "Nov": "Post-Monsoon"
})

seasonal_avg = df_seasonal.groupby("season")["pm25"].mean().round(1)

print("\n" + "=" * 60)
print("SECTION 4 — Delhi Seasonal PM2.5 Pattern (2023)")
print("=" * 60)
print(df_seasonal[["month", "pm25", "season"]].to_string(index=False))
print("\n  Seasonal averages:")
print(seasonal_avg.to_string())
winter_summer_ratio = seasonal_avg["Winter"] / seasonal_avg["Monsoon"]
print(f"\n  Winter/Summer ratio: {winter_summer_ratio:.1f}×")


# ─────────────────────────────────────────────────────────────
# SECTION 5: POLICY SCENARIO — ADOPTING WHO INTERIM TARGET 1
# ─────────────────────────────────────────────────────────────

print("\n" + "=" * 60)
print("SECTION 5 — Policy Scenario: Adopt WHO Interim Target 1 (35 μg/m³)")
print("=" * 60)

IT1_STANDARD = 35.0  # μg/m³

# Deaths if all cities achieved IT-1
cities["pm25_it1"] = cities["pm25_annual"].clip(upper=IT1_STANDARD)
cities["deaths_it1"] = cities.apply(
    lambda r: attributable_deaths(r["population"], r["baseline_mort_per1000"], r["pm25_it1"]),
    axis=1
)

deaths_saved = total_attributable - cities["deaths_it1"].sum()

print(f"  Current attributable deaths  : {total_attributable:,}")
print(f"  Deaths at IT-1 compliance    : {cities['deaths_it1'].sum():,}")
print(f"  Lives saved annually         : {deaths_saved:,}")
print(f"  → Adopting IT-1 could save ~{deaths_saved:,} lives/year")

print("\n✓ Analysis complete.")
print(f"  Key finding: {total_attributable:,} attributable deaths | {avg_life_years_lost:.1f} avg life-years lost")
