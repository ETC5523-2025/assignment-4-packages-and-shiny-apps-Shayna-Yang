## Purpose: generate two simulated case-level datasets:
## 1. shayhai_cases        -> Germany (German PPS 2011)
## 2. shayhai_cases_ecdc   -> EU/EEA (ECDC PPS 2011-2012, per 100k population)
##
## Both are ~5000-row synthetic microdata tables. Each row is a simulated
## healthcare-associated infection (HAI) case, with weights that scale
## back up to population-level burden.


# 1. Parameters for Germany

targets_ger <- tibble::tribble(
  ~infection_type, ~n_hai_point, ~deaths_point, ~ylls_point, ~ylds_point,
  "HAP", 106586, 3968, 41306, 27539,
  "SSI",  93228, 2328, 28376,   452,
  "BSI",  26976, 3905, 49578,  8878,
  "UTI", 214150, 3664, 44871, 20423,
  "CDI",  36002, 1917, 19937,   977
) |>
  dplyr::mutate(
    dalys_point    = ylls_point + ylds_point,
    p_death        = deaths_point / n_hai_point,
    yll_per_death  = dplyr::if_else(deaths_point > 0,
                                    ylls_point / deaths_point, 0),
    yld_per_case   = ylds_point / n_hai_point
  )

# We'll reuse Germany's YLL/DALY split to estimate YLL and YLD for EU/EEA.
yll_prop_ger <- targets_ger |>
  dplyr::mutate(prop_yll = ifelse(dalys_point > 0, ylls_point / dalys_point, 0)) |>
  dplyr::select(infection_type, prop_yll)


# 2. Parameters for EU/EEA (ECDC PPS)
#
# Idea:
# - Treat "per 100,000 population" as if it's the total burden in
#   a reference population of exactly 100,000 people.
# - So HAIs_per_100k  -> n_hai_point
#   deaths_per_100k   -> deaths_point
#   DALYs_per_100k    -> dalys_point
# - Then split DALYs into YLL and YLD using Germany's YLL proportion.

targets_ecdc_rates <- tibble::tribble(
  ~infection_type, ~hais_per_100k, ~deaths_per_100k, ~dalys_per_100k,
  "HAP", 143.7, 5.3, 109.8,
  "UTI", 174.7, 3.0,  57.1,
  "BSI",  22.2, 3.3,  76.2,
  "SSI", 111.3, 2.6,  35.1,
  "CDI",  16.0, 0.9,  10.0
  # "All" row not simulated as a type; we'll always compute "All" later by summing.
)

# join the YLL proportion from Germany to split EU/EEA DALYs into YLL vs YLD
targets_ecdc <- targets_ecdc_rates |>
  dplyr::left_join(yll_prop_ger, by = "infection_type") |>
  dplyr::mutate(
    n_hai_point   = hais_per_100k,      # interpret per-100k as "this many cases in our ref pop"
    deaths_point  = deaths_per_100k,
    dalys_point   = dalys_per_100k,
    ylls_point    = dalys_per_100k * prop_yll,
    ylds_point    = dalys_per_100k * (1 - prop_yll),
    p_death       = dplyr::if_else(n_hai_point > 0,
                                   deaths_point / n_hai_point, 0),
    yll_per_death = dplyr::if_else(deaths_point > 0,
                                   ylls_point / deaths_point, 0),
    yld_per_case  = dplyr::if_else(n_hai_point > 0,
                                   ylds_point / n_hai_point, 0)
  ) |>
  dplyr::select(
    infection_type,
    n_hai_point,
    deaths_point,
    ylls_point,
    ylds_point,
    p_death,
    yll_per_death,
    yld_per_case
  )


# 3. Shared demographic sampling assumptions
#    (age/sex distributions, same for both populations for now)

age_groups_ref <- c(
  "0-1","2-4","5-9","10-14","15-19","20-24","25-34","35-44",
  "45-54","55-64","65-74","75-79","80-84","85+"
)

# Heavier weights in older ages, reflecting higher DALY burden in the figures
age_weights_ref <- c(1,1,1,1,1,2,3,4,6,8,10,12,12,12)

sex_levels_ref <- c("Female","Male")
sex_weights_ref <- c(1,1)


# 4. Generic simulator

simulate_cases_generic <- function(
    targets_tbl,
    n_cases = 5000,
    seed = 5523,
    age_groups = age_groups_ref,
    age_weights = age_weights_ref,
    sex_levels = sex_levels_ref,
    sex_weights = sex_weights_ref
) {
  set.seed(seed)

  probs_type <- targets_tbl$n_hai_point / sum(targets_tbl$n_hai_point)

  infection_draw <- base::sample(
    targets_tbl$infection_type,
    size = n_cases,
    replace = TRUE,
    prob = probs_type
  )

  age_draw <- base::sample(
    age_groups, size = n_cases, replace = TRUE, prob = age_weights
  )

  sex_draw <- base::sample(
    sex_levels, size = n_cases, replace = TRUE, prob = sex_weights
  )

  df <- tibble::tibble(
    case_id = seq_len(n_cases),
    infection_type = infection_draw,
    age_group = age_draw,
    sex = sex_draw
  ) |>
    dplyr::left_join(targets_tbl, by = "infection_type") |>
    dplyr::rowwise() |>
    dplyr::mutate(
      died = stats::rbinom(1, 1, p_death),
      # add light random noise so cases aren't perfectly identical
      yll  = if (died == 1) yll_per_death * stats::runif(1, 0.8, 1.2) else 0,
      yld  = yld_per_case  * stats::runif(1, 0.8, 1.2),
      daly = yll + yld
    ) |>
    dplyr::ungroup()

  # weight_pop scales our ~5000 simulated rows back to the "population total"
  n_type <- df |>
    dplyr::count(infection_type, name = "n_sim")

  df |>
    dplyr::left_join(n_type, by = "infection_type") |>
    dplyr::mutate(
      weight_pop = n_hai_point / n_sim
    ) |>
    dplyr::select(
      case_id,
      infection_type,
      age_group,
      sex,
      died,
      yll,
      yld,
      daly,
      weight_pop
    )
}


# 5. Generate both datasets

shayhai_cases <- simulate_cases_generic(
  targets_tbl = targets_ger,
  n_cases = 5000,
  seed = 5523
)

shayhai_cases_ecdc <- simulate_cases_generic(
  targets_tbl = targets_ecdc,
  n_cases = 5000,
  seed = 9876  # different seed so it's not identical structure
)

# 6. Save to data/ for the package

usethis::use_data(
  shayhai_cases,
  shayhai_cases_ecdc,
  overwrite = TRUE
)
