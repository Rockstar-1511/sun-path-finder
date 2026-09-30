# Sun Path Finder (MATLAB)

A MATLAB simulation model that calculates the sun's position (altitude and azimuth) for any location over a full year at 1-hour intervals. It analyses seasonal trends with curve fitting and estimates the best fixed tilt for photovoltaic (PV) panel placement.

![Sun path diagram](results/sun_path_diagram.png)

## Specifications

| Parameter | Value |
|---|---|
| Time range | 365 days |
| Time step | 1 hour (8,760 solar positions per year) |
| Solar position model | NOAA general solar position equations |
| Outputs per point | Altitude, azimuth, declination |
| Trend analysis | 2-term Fourier fit (Curve Fitting Toolbox, with base-MATLAB fallback) |
| PV analysis | Fixed-tilt optimisation, equator-facing panel |
| Example site | New York, NY (40.71°N, 74.01°W, UTC−5) |

## Results (New York, NY)

| Metric | Result |
|---|---|
| Maximum noon altitude | 72.7° (June solstice) |
| Minimum noon altitude | 25.9° (December solstice) |
| Longest day | 15.1 h |
| Shortest day | 9.3 h |
| Trend fit, noon altitude | R² = 0.99994 |
| Trend fit, day length | R² = 0.9992 |
| Optimal fixed tilt | 34° south-facing (clear-sky beam model) |

### Key dates

| Date | Noon altitude | Sunrise | Sunset | Day length |
|---|---|---|---|---|
| Mar 21 (equinox) | 49.2° | 06:00 | 18:08 | 12.1 h |
| Jun 21 (solstice) | 72.7° | 04:24 | 19:30 | 15.1 h |
| Sep 23 (equinox) | 49.5° | 05:43 | 17:54 | 12.2 h |
| Dec 21 (solstice) | 25.9° | 07:16 | 16:31 | 9.3 h |

Times are local standard time (EST). Add one hour during daylight saving time.

## Workflow

![Workflow](results/workflow.png)

## Method

**Solar position.** The model uses the NOAA general solar position equations:

1. Fractional year: γ = 2π/365 · (day − 1 + (hour − 12)/24)
2. Equation of time and solar declination from Spencer's Fourier series
3. True solar time, corrected for longitude and time zone, gives the hour angle h
4. Zenith angle: cos θz = sin φ sin δ + cos φ cos δ cos h, and altitude = 90° − θz
5. Azimuth is measured clockwise from true north

**Sunrise and sunset.** The NOAA sunrise equation uses a zenith of 90.833°. This accounts for atmospheric refraction and the size of the solar disc.

**Trend analysis.** Noon altitude and day length follow a yearly cycle. Each is fitted with a two-term Fourier series. R² and RMSE confirm the fit quality.

**PV tilt optimisation.** Direct normal irradiance is estimated using the Meinel clear-sky model and Kasten-Young air mass. Annual beam energy on an equator-facing panel is compared for tilts from 0° to 90°. The optimum of 34° is a few degrees below the site latitude, which matches the common rule of thumb for fixed arrays.

## Figures

| Polar sun path | Altitude heatmap |
|---|---|
| ![Polar](results/sun_path_polar.png) | ![Heatmap](results/altitude_heatmap.png) |

| Seasonal trends with curve fit | Sunrise and sunset |
|---|---|
| ![Trends](results/seasonal_trends.png) | ![Sunrise and sunset](results/sunrise_sunset.png) |

![Tilt optimisation](results/tilt_optimisation.png)

## Data

| File | Description |
|---|---|
| `data/sun_positions.csv` | 8,760 rows of hourly altitude and azimuth |
| `data/daily_summary.csv` | Daily declination, noon altitude, sunrise, solar noon, sunset, day length |

## Project Structure

```
sun-path-finder/
├── main.m                  # Runs the full analysis, saves figures and data
├── src/
│   ├── sunPosition.m       # NOAA solar position equations
│   ├── sunriseSunset.m     # Sunrise, sunset, solar noon, day length
│   ├── fitSeasonalTrend.m  # Fourier curve fitting (toolbox or fallback)
│   ├── optimalTilt.m       # Fixed-tilt PV optimisation
│   └── plotSunPath.m       # Sun path, polar chart and heatmap
├── results/                # Figures
├── data/                   # CSV exports
├── LICENSE
└── README.md
```

## Getting Started

**Requirements:** MATLAB R2019b or later. The Curve Fitting Toolbox is optional.

1. Clone the repo and open it in MATLAB:
   ```bash
   git clone https://github.com/Rockstar-1511/sun-path-finder.git
   ```
2. Set your site in `main.m`:
   ```matlab
   site.name      = 'New York, NY';
   site.latitude  = 40.7128;
   site.longitude = -74.0060;
   site.utcOffset = -5;
   ```
3. Run `main.m`. Figures are saved to `results/` and data to `data/`.

## Limitations

- Uses local standard time and does not apply daylight saving time.
- Tilt optimisation considers clear-sky beam irradiance only. It ignores diffuse light, weather, shading, and temperature. Use NREL PVWatts or SAM for design-grade energy estimates.
- Solar position accuracy is typically within a fraction of a degree. Validate against the [NOAA Solar Calculator](https://gml.noaa.gov/grad/solcalc/) for your site.

## References

- NOAA Global Monitoring Laboratory, *General Solar Position Calculations*
- Spencer, J. W. (1971). Fourier series representation of the position of the sun
- Kasten, F. & Young, A. T. (1989). Revised optical air mass tables and approximation formula
- Meinel, A. B. & Meinel, M. P. (1976). *Applied Solar Energy*

## License

MIT. See [LICENSE](LICENSE).
