#' @export
run_app <- function() {
  app_dir <- system.file("shiny-app", package = "BHAIExplore")
  shiny::runApp(app_dir, display.mode = "normal")
}
