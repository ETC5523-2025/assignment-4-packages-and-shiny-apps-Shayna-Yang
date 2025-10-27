#' Simulated case-level HAI burden data (EU/EEA, ECDC PPS)
#'
#' The dataset \code{shayhai_cases_ecdc} contains 5,000 simulated
#' HAI cases for a reference population in the EU/EEA.
#' Each row represents one synthetic case generated using the
#' rates reported by the ECDC PPS (2011–2012).
#'
#' Case weights are calibrated so that, when summed, they match
#' the published ECDC PPS burden estimates per 100,000 population:
#' HAIs, deaths, and DALYs.
#'
#' Conceptually, this dataset represents an illustrative population
#' of 100,000 people in the EU/EEA.
#'
#' Columns:
#' \describe{
#'   \item{case_id}{Unique simulated case ID.}
#'   \item{infection_type}{Type of HAI:
#'   \code{"HAP"}, \code{"SSI"}, \code{"BSI"}, \code{"UTI"}, \code{"CDI"}.}
#'   \item{age_group}{Age band at infection.}
#'   \item{sex}{Reported sex ("Female", "Male").}
#'   \item{died}{Indicator (1/0) for attributable death.}
#'   \item{yll}{Years of life lost (YLL) for this case.}
#'   \item{yld}{Years lived with disability (YLD) for this case.}
#'   \item{daly}{Total disability-adjusted life years (DALY = YLL + YLD).}
#'   \item{weight_pop}{How many real-world cases (per 100,000 population)
#'   this simulated row represents. Summing \code{weight_pop} across cases
#'   of one infection type approximates the published “HAIs per 100,000”
#'   for that infection type. Similarly, summing \code{weight_pop * died}
#'   or \code{weight_pop * daly} approximates deaths per 100,000 and
#'   DALYs per 100,000, respectively.}
#' }
#'
#' Interpretation for comparison plots:
#' \itemize{
#'   \item This dataset lets you directly compare Germany vs EU/EEA
#'   in Shiny by switching between \code{shayhai_cases} and
#'   \code{shayhai_cases_ecdc}.
#' }
#'
#' @format A data frame (tibble) with 5,000 rows and 9 columns.
#' @source Calibrated to published ECDC PPS (EU/EEA) burden estimates per 100,000 population.
"shayhai_cases_ecdc"
