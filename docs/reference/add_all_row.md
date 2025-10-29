# Add a total "All" row to a burden summary

Takes the output of
[`summarise_burden_totals()`](https://ETC5523-2025.github.io/assignment-4-packages-and-shiny-apps-Shayna-Yang/reference/summarise_burden_totals.md)
and appends a final row where all infection types are combined
(`"All"`).

## Usage

``` r
add_all_row(tbl)
```

## Arguments

- tbl:

  A tibble returned by
  [`summarise_burden_totals()`](https://ETC5523-2025.github.io/assignment-4-packages-and-shiny-apps-Shayna-Yang/reference/summarise_burden_totals.md).

## Value

The same tibble with an extra "All" row.

## Details

This mirrors the "All" line shown in the paper.

## Examples

``` r
# Start with per-infection-type totals
burden_tbl <- summarise_burden_totals(shayhai::shayhai_cases)

# Add an overall "All" row
add_all_row(burden_tbl)
#> # A tibble: 6 × 6
#>   infection_type n_hai_est deaths_est ylls_est ylds_est dalys_est
#>   <chr>              <dbl>      <dbl>    <dbl>    <dbl>     <dbl>
#> 1 BSI                26976      4169.   50756.    8778.    59534.
#> 2 CDI                36002      1930.   19986.     975.    20960.
#> 3 HAP               106586      4008.   40460.   27621.    68080.
#> 4 SSI                93228      2489.   30342.     451.    30793.
#> 5 UTI               214150      3592.   43822.   20487.    64309.
#> 6 All               476942     16188.  185365.   58311.   243676.
```
