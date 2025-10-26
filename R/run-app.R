#' Launch the shayhai Shiny app
#'
#' Opens the interactive dashboard for exploring simulated
#' healthcare-associated infection (HAI) burden, including
#' estimated infections, deaths, and DALYs by infection type.
#'
#' @return No return value; this function launches a Shiny app.
#' @export
run_app <- function() {
  app_dir <- system.file("shiny-app", package = "shayhai")
  shiny::runApp(app_dir, display.mode = "normal")
}
