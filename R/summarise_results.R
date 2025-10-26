#' Summarise simulated cases to reproduce Table 1
#'
#' Using the simulated dataset \code{shayhai_cases}, this function aggregates
#' case-level values by infection type to estimate the total number of
#' healthcare-associated infections (HAIs), attributable deaths,
#' years of life lost (YLLs), years lived with disability (YLDs),
#' and total disability-adjusted life years (DALYs).
#'
#' This reproduces the style of Table 1 in the published study
#' (German PPS sample, 2011).
#'
#' @param cases A data frame, typically \code{shayhai::shayhai_cases}.
#'
#' @return A tibble where each row corresponds to one infection type,
#' including the following columns:
#' \code{n_hai_est}, \code{deaths_est}, \code{ylls_est},
#' \code{ylds_est}, and \code{dalys_est}.
#'
#' @export
summarise_table <- function(cases) {
  cases |>
    dplyr::group_by(infection_type) |>
    dplyr::summarise(
      n_hai_est   = sum(weight_pop),
      deaths_est  = sum(weight_pop * died),
      ylls_est    = sum(weight_pop * yll),
      ylds_est    = sum(weight_pop * yld),
      dalys_est   = sum(weight_pop * daly),
      .groups = "drop"
    ) |>
    dplyr::arrange(infection_type)
}

#' Add a total "All" row
#'
#' Appends a summary row where all infection types are combined
#' into a single total, with \code{infection_type = "All"}.
#'
#' @param tbl The output of \code{summarise_table1()}.
#'
#' @return A tibble identical to the input but with one additional
#' row summarising all infection types.
#'
#' @export
add_all_row <- function(tbl) {
  all_row <- tbl |>
    dplyr::summarise(
      infection_type = "All",
      n_hai_est   = sum(n_hai_est),
      deaths_est  = sum(deaths_est),
      ylls_est    = sum(ylls_est),
      ylds_est    = sum(ylds_est),
      dalys_est   = sum(dalys_est)
    )
  dplyr::bind_rows(tbl, all_row)
}

#' Prepare bubble plot data (corresponding to Figure 2)
#'
#' Generates a tidy data frame containing, for each infection type,
#' the estimated annual number of infections, attributable deaths,
#' and total DALYs. This dataset can be directly used to create
#' a bubble plot similar to Figure 2 of the published study.
#'
#' @param cases A data frame, typically \code{shayhai::shayhai_cases}.
#'
#' @return A tibble with columns:
#' \code{infection_type}, \code{n_hai_est}, \code{deaths_est},
#' and \code{dalys_est}.
#'
#' @export
prep_bubble_data <- function(cases) {
  summarise_table(cases) |>
    dplyr::select(
      infection_type,
      n_hai_est,
      deaths_est,
      dalys_est
    )
}
