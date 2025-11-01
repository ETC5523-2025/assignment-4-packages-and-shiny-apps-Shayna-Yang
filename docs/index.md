# shayhai

## Introduction

shayhai is a teaching-focused R package for exploring the burden of
healthcare-associated infections (HAIs) using simulated datasets. It
provides tidy data, helper functions, and an interactive Shiny app to
summarise and visualise HAI burden — including infection counts,
attributable deaths, and disability-adjusted life years (DALYs).

This package is designed for coursework, demos, and data communication
exercises.

## Usage

You can install the development version of shayhai from
[GitHub](https://github.com/ETC5523-2025/assignment-4-packages-and-shiny-apps-Shayna-Yang)
with:

``` r
# install.packages("pak")
pak::pak("ETC5523-2025/assignment-4-packages-and-shiny-apps-Shayna-Yang")
```

Load the package:

``` r
library(shayhai)
```

### Data Included

The package ships with two simulated datasets:

- `shayhai_cases` — German PPS sample (2011)

- `shayhai_cases_ecdc` — EU/EEA PPS sample (2011–2012)

Each row represents a simulated “case” weighted to reflect the national
burden. Key variables include:

- infection_type: infection category (`HAP`, `SSI`, `BSI`, `UTI`, `CDI`)

- `weight_pop`: population weight for national scaling

- Demographic and infection descriptors (used in filtering and plotting)

Example preview:

``` r
head(shayhai_cases)
#>   case_id infection_type age_group gender died      yll        yld        daly
#> 1       1            UTI     80-84   Male    0  0.00000 0.10036240  0.10036240
#> 2       2            UTI       85+   Male    0  0.00000 0.08324335  0.08324335
#> 3       3            CDI     80-84 Female    0  0.00000 0.02322845  0.02322845
#> 4       4            HAP     75-79   Male    0  0.00000 0.23113244  0.23113244
#> 5       5            BSI       85+ Female    0  0.00000 0.32974989  0.32974989
#> 6       6            HAP     75-79 Female    1 12.09578 0.24421109 12.33998793
#>   weight_pop
#> 1   97.07616
#> 2   97.07616
#> 3   96.52011
#> 4   95.42167
#> 5   81.74545
#> 6   95.42167
```

### Shiny App

The package includes an interactive dashboard to explore infection
burden by type, survey module, and demographic group.

App features:

- Bubble plot: HAIs vs deaths, bubble size = DALYs

- Bar plot: Compare German PPS vs ECDC PPS (with 95% uncertainty
  intervals)

- Age pyramid: DALYs by sex and age group

You can explore the interactive [Shiny
app](https://etc5523-2025.github.io/assignment-4-packages-and-shiny-apps-Shayna-Yang/articles/shayhai.html#using-the-shiny-app)
included in the package.

[![](https://raw.githubusercontent.com/ETC5523-2025/assignment-4-packages-and-shiny-apps-Shayna-Yang/main/man/figures/bubble_example.png)](https://etc5523-2025.github.io/assignment-4-packages-and-shiny-apps-Shayna-Yang/articles/shayhai.html#bubble-plot-dalys-vs-deaths-vs-cases)
[![](https://raw.githubusercontent.com/ETC5523-2025/assignment-4-packages-and-shiny-apps-Shayna-Yang/main/man/figures/bar_example.png)](https://etc5523-2025.github.io/assignment-4-packages-and-shiny-apps-Shayna-Yang/articles/shayhai.html#bar-plot-with-95-ui)
[![](https://raw.githubusercontent.com/ETC5523-2025/assignment-4-packages-and-shiny-apps-Shayna-Yang/main/man/figures/agepyramid_example.png)](https://etc5523-2025.github.io/assignment-4-packages-and-shiny-apps-Shayna-Yang/articles/shayhai.html#age-pyramid-weighted-dalys-by-gender-and-age-group)

## Data Sources

The simulated datasets mirror the structure of two major PPS surveys:

- German PPS (2011): 46 hospitals, 9,626 patients

- EU/EEA PPS (2011–2012): 273,753 patients across 29 countries

Metrics (HAIs, deaths, DALYs, YLL, YLD) follow the methodology of the
Burden of Healthcare-Associated Infections (BHAI) framework as described
in:

Zacher B, Haller S, Willrich N, et al. Application of a new methodology
and R package reveals a high burden of healthcare-associated infections
(HAI) in Germany compared to the average in the European Union/European
Economic Area, 2011 to 2012. Euro Surveill. 2019;24(46):1900135.
<https://doi.org/10.2807/1560-7917.ES.2019.24.46.1900135>

These data are simplified for educational use in ETC5523: Communicating
with Data.

## Documentation

Full documentation and examples:

**Site home:**
<https://ETC5523-2025.github.io/assignment-4-packages-and-shiny-apps-Shayna-Yang>

Blog Post for BHAI analysis:

**Blog site:** [Germany’s Hidden Hospital Infection Burden: What the
BHAI R Package
Revealed](https://etc5523-2025.github.io/assignment-3-creating-a-blog-Shayna-Yang/posts/HAIs%20Burden%20in%20Germany/)

## License

This package is released under the MIT License. See the included LICENSE
file for details.

## Author

Tzu-Hsuan, Yang (Author & Maintainer)

## Acknowledgements

- Package infrastructure: `usethis`, `devtools`, `roxygen2`

- Data wrangling: `dplyr`, `tidyr`, `scales`

- Visualisation: `ggplot2`, `plotly`, `shiny`

- Concept inspired by the BHAI methodology [(Zacher et al.,
  2019)](https://doi.org/10.2807/1560-7917.ES.2019.24.46.1900135)

Simulated datasets were produced with partial AI assistance for
illustrative purposes only.
