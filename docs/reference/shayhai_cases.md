# Simulated case-level HAI burden data (Germany)

The dataset `shayhai_cases` contains 5,000 simulated
healthcare-associated infection (HAI) cases for Germany. Each row
represents one synthetic patient record.

## Usage

``` r
shayhai_cases
```

## Format

A data frame (tibble) with 5,000 rows and 9 columns.

## Source

Calibrated to published German PPS estimates.

## Details

Case weights are calibrated so that, when summed, they reproduce the
published national estimates from the German PPS study (2011): total
HAIs, attributable deaths, and DALYs.

Columns:

- case_id:

  Unique simulated case ID.

- infection_type:

  Type of HAI: `"HAP"` (healthcare-associated pneumonia), `"SSI"`
  (surgical site infection), `"BSI"` (primary bloodstream infection),
  `"UTI"` (urinary tract infection), `"CDI"` (*Clostridioides difficile*
  infection).

- age_group:

  Age band at infection, e.g. "65-74", "75-79", "80-84", "85+").

- gender:

  Reported gender ("Female", "Male").

- died:

  Indicator (1/0) for whether the infection was estimated to result in
  an attributable death.

- yll:

  Years of life lost (YLL) assigned to this case.

- yld:

  Years lived with disability (YLD) assigned to this case.

- daly:

  Total disability-adjusted life years for this case
  (`daly = yll + yld`).

- weight_pop:

  How many real-world cases this simulated row represents. Summing
  `weight_pop` across cases of a given `infection_type` yields the
  estimated annual number of HAIs of that type in Germany.

Interpretation:

- `sum(weight_pop * died)` approximates the annual number of
  attributable deaths for each infection type in Germany.

- `sum(weight_pop * daly)` approximates the total DALYs for that
  infection type.

These weighted totals reflect the German PPS study (2011).
