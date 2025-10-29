# Prepare data for the bubble plot (Figure 2)

Returns infections, deaths, and DALYs by infection type in a tidy format
ready for plotting a bubble chart like Figure 2 of the paper:

- x-axis: HAIs

- y-axis: attributable deaths

- bubble size: DALYs

## Usage

``` r
prep_bubble_data(cases)
```

## Arguments

- cases:

  A simulated dataset such as `shayhai_cases`.

## Value

A tibble with columns `infection_type`, `n_hai_est`, `deaths_est`,
`dalys_est`.

## Examples

``` r
# Prepare German PPS-style data for a bubble plot
bubble_df <- prep_bubble_data(shayhai::shayhai_cases)
bubble_df
#> # A tibble: 5 × 4
#>   infection_type n_hai_est deaths_est dalys_est
#>   <chr>              <dbl>      <dbl>     <dbl>
#> 1 BSI                26976      4169.    59534.
#> 2 CDI                36002      1930.    20960.
#> 3 HAP               106586      4008.    68080.
#> 4 SSI                93228      2489.    30793.
#> 5 UTI               214150      3592.    64309.

# You could then pass this to ggplot2, e.g.:
# (not run during checks)
if (FALSE) { # \dontrun{
  library(ggplot2)
  ggplot(
    bubble_df,
    aes(x = n_hai_est,
        y = deaths_est,
        size = dalys_est,
        label = infection_type)
  ) +
    geom_point(alpha = 0.6) +
    geom_text(vjust = -0.7)
} # }
```
