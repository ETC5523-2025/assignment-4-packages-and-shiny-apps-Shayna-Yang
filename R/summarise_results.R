#' Summarise total burden by infection type
#'
#' Aggregates a simulated case dataset (e.g. \code{shayhai_cases} or
#' \code{shayhai_cases_ecdc}) to estimate total annual burden per
#' infection type.
#'
#' The output includes:
#' \itemize{
#'   \item total HAIs
#'   \item attributable deaths
#'   \item YLL (years of life lost)
#'   \item YLD (years lived with disability)
#'   \item DALYs (YLL + YLD)
#' }
#'
#'
#' @param cases A simulated dataset such as \code{shayhai_cases}
#'   (Germany) or \code{shayhai_cases_ecdc} (EU/EEA).
#'
#' @return A tibble: one row per infection type.
#' @export
summarise_burden_totals <- function(cases) {
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

#' Add a total "All" row to a burden summary
#'
#' Takes the output of \code{summarise_burden_totals()} and appends a
#' final row where all infection types are combined (\code{"All"}).
#'
#' This mirrors the "All" line shown in the paper.
#'
#' @param tbl A tibble returned by \code{summarise_burden_totals()}.
#'
#' @return The same tibble with an extra "All" row.
#'
#' @examples
#' # Start with per-infection-type totals
#' burden_tbl <- summarise_burden_totals(shayhai::shayhai_cases)
#'
#' # Add an overall "All" row
#' add_all_row(burden_tbl)
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

#' Prepare data for the bubble plot (Figure 2)
#'
#' Returns infections, deaths, and DALYs by infection type in a tidy
#' format ready for plotting a bubble chart like Figure 2 of the paper:
#' \itemize{
#'   \item x-axis: HAIs
#'   \item y-axis: attributable deaths
#'   \item bubble size: DALYs
#' }
#'
#' @param cases A simulated dataset such as \code{shayhai_cases}.
#' @return A tibble with columns \code{infection_type},
#'   \code{n_hai_est}, \code{deaths_est}, \code{dalys_est}.
#' @examples
#' # Prepare German PPS-style data for a bubble plot
#' bubble_df <- prep_bubble_data(shayhai::shayhai_cases)
#' bubble_df
#'
#' # You could then pass this to ggplot2, e.g.:
#' # (not run during checks)
#' \dontrun{
#'   library(ggplot2)
#'   ggplot(
#'     bubble_df,
#'     aes(x = n_hai_est,
#'         y = deaths_est,
#'         size = dalys_est,
#'         label = infection_type)
#'   ) +
#'     geom_point(alpha = 0.6) +
#'     geom_text(vjust = -0.7)
#' }
#'
#' @export
prep_bubble_data <- function(cases) {
  summarise_burden_totals(cases) |>
    dplyr::select(
      infection_type,
      n_hai_est,
      deaths_est,
      dalys_est
    )
}

#' Choose which dataset to analyse (Germany vs EU/EEA)
#'
#' Convenience helper for the Shiny app. Returns either the German
#' simulated dataset (\code{shayhai_cases}) or the EU/EEA simulated
#' dataset (\code{shayhai_cases_ecdc}), depending on user input.
#'
#' @param sample Either \code{"Germany"} or \code{"EU/EEA"}.
#'
#' @return A data frame of simulated cases.
#'
#' @examples
#' # Get the German PPS-like dataset
#' choose_sample_cases("Germany")
#'
#' # Get the EU/EEA PPS-like dataset
#' choose_sample_cases("EU/EEA")
#'
#' # If you don't supply an argument, it will default to "Germany":
#' choose_sample_cases()
#'
#' @export
choose_sample_cases <- function(sample = c("Germany", "EU/EEA")) {
  sample <- match.arg(sample)
  if (sample == "Germany") {
    return(shayhai::shayhai_cases)
  } else {
    return(shayhai::shayhai_cases_ecdc)
  }
}
