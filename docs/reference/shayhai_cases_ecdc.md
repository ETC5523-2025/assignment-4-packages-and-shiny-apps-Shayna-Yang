# Simulated case-level HAI burden data (EU/EEA, ECDC PPS)

The dataset `shayhai_cases_ecdc` contains 5,000 simulated HAI cases for
a reference population in the EU/EEA. Each row represents one synthetic
case generated using the rates reported by the ECDC PPS (2011–2012).

## Usage

``` r
shayhai_cases_ecdc
```

## Format

A data frame (tibble) with 5,000 rows and 9 columns.

## Source

Calibrated to published ECDC PPS (EU/EEA) burden estimates per 100,000
population.

## Details

Case weights are calibrated so that, when summed, they match the
published ECDC PPS burden estimates per 100,000 population: HAIs,
deaths, and DALYs.

Conceptually, this dataset represents an illustrative population of
100,000 people in the EU/EEA.

Columns:

- case_id:

  Unique simulated case ID.

- infection_type:

  Type of HAI: `"HAP"`, `"SSI"`, `"BSI"`, `"UTI"`, `"CDI"`.

- age_group:

  Age band at infection.

- gender:

  Reported gender ("Female", "Male").

- died:

  Indicator (1/0) for attributable death.

- yll:

  Years of life lost (YLL) for this case.

- yld:

  Years lived with disability (YLD) for this case.

- daly:

  Total disability-adjusted life years (DALY = YLL + YLD).

- weight_pop:

  How many real-world cases (per 100,000 population) this simulated row
  represents. Summing `weight_pop` across cases of one infection type
  approximates the published “HAIs per 100,000” for that infection type.
  Similarly, summing `weight_pop * died` or `weight_pop * daly`
  approximates deaths per 100,000 and DALYs per 100,000, respectively.

Interpretation for comparison plots:

- This dataset lets you directly compare Germany vs EU/EEA in Shiny by
  switching between `shayhai_cases` and `shayhai_cases_ecdc`.
