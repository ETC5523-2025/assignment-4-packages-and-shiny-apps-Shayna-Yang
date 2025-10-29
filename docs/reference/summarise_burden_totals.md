# Summarise total burden by infection type

Aggregates a simulated case dataset (e.g. `shayhai_cases` or
`shayhai_cases_ecdc`) to estimate total annual burden per infection
type.

## Usage

``` r
summarise_burden_totals(cases)
```

## Arguments

- cases:

  A simulated dataset such as `shayhai_cases` (Germany) or
  `shayhai_cases_ecdc` (EU/EEA).

## Value

A tibble: one row per infection type.

## Details

The output includes:

- total HAIs

- attributable deaths

- YLL (years of life lost)

- YLD (years lived with disability)

- DALYs (YLL + YLD)
