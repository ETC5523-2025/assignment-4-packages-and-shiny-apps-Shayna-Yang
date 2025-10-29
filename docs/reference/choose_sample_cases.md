# Choose which dataset to analyse (Germany vs EU/EEA)

Convenience helper for the Shiny app. Returns either the German
simulated dataset (`shayhai_cases`) or the EU/EEA simulated dataset
(`shayhai_cases_ecdc`), depending on user input.

## Usage

``` r
choose_sample_cases(sample = c("Germany", "EU/EEA"))
```

## Arguments

- sample:

  Either `"Germany"` or `"EU/EEA"`.

## Value

A data frame of simulated cases.

## Examples

``` r
# Get the German PPS-like dataset
choose_sample_cases("Germany")
#> # A tibble: 5,000 × 9
#>    case_id infection_type age_group gender  died   yll    yld    daly weight_pop
#>      <int> <chr>          <chr>     <chr>  <int> <dbl>  <dbl>   <dbl>      <dbl>
#>  1       1 UTI            80-84     Male       0   0   0.100   0.100        97.1
#>  2       2 UTI            85+       Male       0   0   0.0832  0.0832       97.1
#>  3       3 CDI            80-84     Female     0   0   0.0232  0.0232       96.5
#>  4       4 HAP            75-79     Male       0   0   0.231   0.231        95.4
#>  5       5 BSI            85+       Female     0   0   0.330   0.330        81.7
#>  6       6 HAP            75-79     Female     1  12.1 0.244  12.3          95.4
#>  7       7 UTI            55-64     Female     0   0   0.103   0.103        97.1
#>  8       8 CDI            55-64     Male       0   0   0.0248  0.0248       96.5
#>  9       9 UTI            2-4       Female     0   0   0.0964  0.0964       97.1
#> 10      10 UTI            85+       Male       0   0   0.105   0.105        97.1
#> # ℹ 4,990 more rows

# Get the EU/EEA PPS-like dataset
choose_sample_cases("EU/EEA")
#> # A tibble: 5,000 × 9
#>    case_id infection_type age_group gender  died   yll     yld    daly
#>      <int> <chr>          <chr>     <chr>  <int> <dbl>   <dbl>   <dbl>
#>  1       1 SSI            65-74     Male       0     0 0.00399 0.00399
#>  2       2 UTI            75-79     Female     0     0 0.0996  0.0996 
#>  3       3 UTI            85+       Female     0     0 0.103   0.103  
#>  4       4 HAP            85+       Female     0     0 0.275   0.275  
#>  5       5 HAP            85+       Female     0     0 0.318   0.318  
#>  6       6 UTI            75-79     Male       0     0 0.0963  0.0963 
#>  7       7 HAP            75-79     Female     0     0 0.245   0.245  
#>  8       8 HAP            65-74     Female     0     0 0.318   0.318  
#>  9       9 HAP            65-74     Male       0     0 0.285   0.285  
#> 10      10 UTI            80-84     Female     0     0 0.0884  0.0884 
#> # ℹ 4,990 more rows
#> # ℹ 1 more variable: weight_pop <dbl>

# If you don't supply an argument, it will default to "Germany":
choose_sample_cases()
#> # A tibble: 5,000 × 9
#>    case_id infection_type age_group gender  died   yll    yld    daly weight_pop
#>      <int> <chr>          <chr>     <chr>  <int> <dbl>  <dbl>   <dbl>      <dbl>
#>  1       1 UTI            80-84     Male       0   0   0.100   0.100        97.1
#>  2       2 UTI            85+       Male       0   0   0.0832  0.0832       97.1
#>  3       3 CDI            80-84     Female     0   0   0.0232  0.0232       96.5
#>  4       4 HAP            75-79     Male       0   0   0.231   0.231        95.4
#>  5       5 BSI            85+       Female     0   0   0.330   0.330        81.7
#>  6       6 HAP            75-79     Female     1  12.1 0.244  12.3          95.4
#>  7       7 UTI            55-64     Female     0   0   0.103   0.103        97.1
#>  8       8 CDI            55-64     Male       0   0   0.0248  0.0248       96.5
#>  9       9 UTI            2-4       Female     0   0   0.0964  0.0964       97.1
#> 10      10 UTI            85+       Male       0   0   0.105   0.105        97.1
#> # ℹ 4,990 more rows
```
