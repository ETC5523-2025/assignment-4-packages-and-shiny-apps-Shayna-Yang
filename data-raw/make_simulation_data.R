# 1. numbers of parameters each infection
targets <- tibble::tribble(
  ~infection_type, ~n_hai_point, ~deaths_point, ~ylls_point, ~ylds_point,
  "HAP", 106586, 3968, 41306, 27539,
  "SSI", 93228, 2328, 28376, 452,
  "BSI", 26976, 3905, 49578, 8878,
  "UTI", 214150, 3664, 44871, 20423,
  "CDI", 36002, 1917, 19937, 977
) |>
  dplyr::mutate(
    p_death = deaths_point / n_hai_point,
    yll_per_death = ylls_point / deaths_point,
    yld_per_case = ylds_point / n_hai_point
  )

# 2. age-sex
age_groups <- c("0-1","2-4","5-9","10-14","15-19","20-24","25-34","35-44",
                "45-54","55-64","65-74","75-79","80-84","85+")

# Heavier weights in older ages, reflecting higher DALY bars in Figure 4.
age_weights <- c(1,1,1,1,1,2,3,4,6,8,10,12,12,12)

sex_levels <- c("Female","Male")
sex_weights <- c(1,1)  # you can nudge later if you want males slightly higher in some ages

# 3. Simulation
simulate_shayhai_cases <- function(n_cases = 5000, seed = 5523) {
  set.seed(seed)
  probs_type <- targets$n_hai_point / sum(targets$n_hai_point)

  infection_draw <- sample(
    targets$infection_type,
    size = n_cases,
    replace = TRUE,
    prob = probs_type)

  age_draw <- sample(age_groups, size = n_cases, replace = TRUE, prob = age_weights)
  sex_draw <- sample(sex_levels, size = n_cases, replace = TRUE, prob = sex_weights)

  df <- tibble::tibble(case_id = 1:n_cases, infection_type = infection_draw,
               age_group = age_draw, sex = sex_draw) |>
    dplyr::left_join(targets, by = "infection_type") |>
    dplyr::rowwise() |>
    dplyr::mutate(
      died = stats::rbinom(1, 1, p_death),
      yll = if (died == 1) yll_per_death * stats::runif(1, 0.8, 1.2) else 0,
      yld = yld_per_case * stats::runif(1, 0.8, 1.2),
      daly = yll + yld
    ) |>
    dplyr::ungroup()
  # weighted
  n_type <- df |> dplyr::count(infection_type, name = "n_sim")
  df <- df |>
    dplyr::left_join(n_type, by = "infection_type") |>
    dplyr::mutate(weight_pop = n_hai_point / n_sim)

  df |> dplyr::select(case_id, infection_type, age_group, sex, died, yll, yld, daly, weight_pop)
}

shayhai_cases <- simulate_shayhai_cases()

usethis::use_data(shayhai_cases, overwrite = TRUE)
