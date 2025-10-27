# inst/shiny/app.R

library(shiny)
library(dplyr)
library(ggplot2)
library(tidyr)
library(bslib)

# 1. Data from package

data("shayhai_cases", package = "shayhai") # German PPS
data("shayhai_cases_ecdc", package = "shayhai") # ECDC PPS

shayhai_cases <- shayhai_cases |>
  mutate(module = "German PPS")

shayhai_cases_ecdc <- shayhai_cases_ecdc |>
  mutate(module = "ECDC PPS")

all_cases <- bind_rows(shayhai_cases, shayhai_cases_ecdc)

infection_choices <- sort(unique(all_cases$infection_type))
module_choices    <- sort(unique(all_cases$module))
sex_choices       <- sort(unique(all_cases$sex))
age_choices       <- sort(unique(all_cases$age_group))

# UI
ui <- fluidPage(
  br(),
  sidebarLayout(
    sidebarPanel(
      selectizeInput("entity",
                     "Select a country or region:",
                     choices = sort(unique(key_crop_yields$entity)),
                     selected = "Australia")
    ),
    mainPanel(
      plotOutput("tsplot")
    )
  )
)

# Server
server <- function(input, output, session) {

  output$tsplot <- renderPlot({
    key_crop_yields %>%
      filter(entity == input$entity) %>%
      ggplot(aes(year, yield)) +
      geom_line() +
      geom_point() +
      facet_wrap(~crop, scale = "free_y")
  })

}

shinyApp(ui, server)
