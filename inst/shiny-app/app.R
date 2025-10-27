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
ui <- navbarPage(
  title = "shayhai: HAI Explorer",
  theme = bslib::bs_theme(version = 5, bootswatch = "flatly"),
  header = tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "app.css")
  ),
  tabPanel(
    "Explore",
    sidebarLayout(
      sidebarPanel(
        width = 3,
        div(class = "card-box",
            h4("Filters"),
            selectInput("infection_type", "Infection type(s)",
                        choices  = infection_choices,
                        selected = infection_choices,
                        multiple = TRUE
            ),
            selectInput("module", "Survey module(s)",
                        choices  = module_choices,
                        selected = module_choices,
                        multiple = TRUE
            ),
            selectInput("sex", "Sex",
                        choices  = sex_choices,
                        selected = sex_choices,
                        multiple = TRUE
            ),
            selectInput("age_group", "Age group(s)",
                        choices  = age_choices,
                        selected = age_choices,
                        multiple = TRUE
            ),
            tags$hr(),
            div(class = "plot-card-title", "Field glossary"),
            tags$small(
              tags$ul(
                tags$li(tags$b("HAP"), " = healthcare-associated pneumonia"),
                tags$li(tags$b("UTI"), " = urinary tract infection"),
                tags$li(tags$b("BSI"), " = primary bloodstream infection"),
                tags$li(tags$b("SSI"), " = surgical-site infection"),
                tags$li(tags$b("CDI"), " = ",
                        tags$i("Clostridioides difficile"), " infection")
              ),
              tags$br(),
              tags$b("DALY"), " = YLL (years of life lost) + YLD (years lived with disability).",
              tags$br(),
              tags$b("weight_pop"), ": Weights to evalute the population.", tags$br(),
              tags$b("died"), ": 1 means attributing complications and death to a HAI"
            )
        )
      ),

      mainPanel(
        width = 9,
        h4("Interactive HAI burden views"),

        fluidRow(
          column(
            width = 6,
            div(class = "card-box",
                div(class = "plot-card-title", "Bubble plot"),
                plotOutput("bubble_plot", height = "300px"),
                tags$small(
                  "Each bubble = A type of HAI; ",
                  "X = Number of HAIs, Y = Number of attributable deaths; ",
                  "The diameter of the bubbles is proportional to the annual numbers of DALYs,
                  colour = Survey Module (German PPS / ECDC PPS)."
                )
            )
          ),
          column(
            width = 6,
            div(class = "card-box",
                div(class = "plot-card-title", "Bar Plot with 95% UI"),
                plotOutput("bar_plot", height = "300px"),
                tags$small(
                  "Y = Attributable deaths，The error bars indicate ",
                  tags$b("95% uncertainty interval (UI)")
                )
            )
          )
        ),

        fluidRow(
          column(
            width = 12,
            div(class = "card-box",
                div(class = "plot-card-title", "Age pyramid"),
                plotOutput("pyramid_plot", height = "400px"),
                tags$small(
                  "Left = Female, Right = MALE; ",
                  "Width = Number of DALYs (all infections)",
                  "Use filters to focus on a specific infection or module."
                )
            )
          )
        ),

        tags$hr(),
        h5(tags$b("How to interpret the dashboard")),
        tags$ul(
          tags$li(tags$b("Filters:"),
                  "Select infection type(s), survey module(s), sex, and age group(s)."),
          tags$li(tags$b("Bubble plot:"),
                  "Shows which infections cause the most cases, deaths, and DALYs."),
          tags$li(tags$b("Bar plot:"), "Compares infections with",
                  tags$b("95% uncertainty intervals (UI)"), "."),
          tags$li(tags$b("Age pyramid:"),
                  "Shows which age/sex groups bear the largest health burden.")
        )
      )
    )
  ),

  # ---- TAB: About ----
  tabPanel(
    "About",
    div(class = "card-box",
        h4("About the data"),
        p("This app uses the German and ECDC PPS datasets included in the ",
          tags$code("shayhai"), " package. Each row represents a simulated case, ",
          "weighted to represent its contribution to the total population burden."),
        h4("Computed metrics"),
        tags$ul(
          tags$li(tags$b("Cases"), " = sum(weight_pop)"),
          tags$li(tags$b("Deaths"), " = sum(weight_pop * died)"),
          tags$li(tags$b("DALYs"), " = sum(weight_pop * daly)")
        ),
        h4("Uncertainty intervals"),
        p("Bar plots illustrate ",
          tags$b("95% uncertainty intervals (UIs)"),
          " conceptually (currently ±10% of the estimate).")
    )
  )
)


# Server
server <- function(input, output, session) {

  filtered_data <- reactive({
    all_cases %>%
      filter(
        infection_type %in% input$infection_type,
        module         %in% input$module,
        sex            %in% input$sex,
        age_group      %in% input$age_group
      )
  })

  # Bubble
  bubble_data <- reactive({
    filtered_data() %>%
      group_by(infection_type, module) %>%
      summarise(
        cases_est  = sum(weight_pop, na.rm = TRUE),
        deaths_est = sum(weight_pop * died, na.rm = TRUE),
        dalys_est  = sum(weight_pop * daly, na.rm = TRUE),
        .groups = "drop"
      )
  })

  output$bubble_plot <- renderPlot({
    df <- bubble_data()
    validate(need(nrow(df) > 0, "No data for current filter (bubble plot)."))

    xmax <- max(df$cases_est,  na.rm = TRUE) * 1.1
    ymax <- max(df$deaths_est, na.rm = TRUE) * 1.1
    dmax <- max(df$dalys_est,  na.rm = TRUE)

    ggplot(df, aes(x = cases_est, y = deaths_est)) +
      # bubble
      geom_point(
        aes(size = dalys_est, color = module),
        alpha = 0.6
      ) +
      # label with infection type
      geom_text(
        aes(label = infection_type),
        vjust = -0.7,
        size = 3
      ) +
      scale_size_area(limits = c(0, dmax), max_size = 18) +
      scale_x_continuous(limits = c(0, xmax)) +
      scale_y_continuous(limits = c(0, ymax)) +
      labs(
        x = "Number of HAIs (weighted)",
        y = "Attributable deaths (weighted)",
        size = "DALYs (weighted)",
        color = "Survey module"
      ) +
      theme_minimal()
  })

  # Bar plot
  bar_data <- reactive({
    filtered_data() %>%
      group_by(infection_type, module) %>%
      summarise(
        deaths_est = sum(weight_pop * died, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      mutate(
        ui_low  = deaths_est * 0.9,
        ui_high = deaths_est * 1.1
      )
  })

  output$bar_plot <- renderPlot({
    df <- bar_data()
    validate(need(nrow(df) > 0, "No data for current filter (bar plot)."))

    df <- df %>%
      mutate(infection_type = factor(infection_type, levels = infection_choices))

    ymax <- max(df$ui_high, na.rm = TRUE) * 1.1

    ggplot(df, aes(x = infection_type, y = deaths_est, fill = module)) +
      geom_col(
        position = position_dodge(width = 0.6),
        width    = 0.6,
        alpha    = 0.8
      ) +
      geom_errorbar(
        aes(ymin = ui_low, ymax = ui_high),
        position = position_dodge(width = 0.6),
        width    = 0.2,
        linewidth = 0.4
      ) +
      scale_y_continuous(limits = c(0, ymax)) +
      coord_flip() +
      labs(
        x   = "Infection type",
        y   = "Attributable deaths (weighted)",
        fill = "Survey module"
      ) +
      theme_minimal() +
      theme(panel.grid.minor = element_blank())
  })

  # Age Pyramid
  pyramid_data <- reactive({
    filtered_data() %>%
      group_by(age_group, sex) %>%
      summarise(
        daly_weighted = sum(weight_pop * daly, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      # standardise to lower for pivot
      mutate(sex = tolower(sex)) %>%
      tidyr::pivot_wider(
        names_from  = sex,
        values_from = daly_weighted,
        values_fill = 0
      ) %>%
      # make sure both columns exist even if filtered to only one sex
      mutate(
        female = ifelse(is.na(female), 0, female),
        male   = ifelse(is.na(male),   0, male)
      ) %>%
      arrange(age_group)
  })

  output$pyramid_plot <- renderPlot({
    df <- pyramid_data()
    validate(need(nrow(df) > 0, "No data for current filter (age pyramid)."))

    ggplot() +
      # Female to the left (negative)
      geom_col(
        data = df,
        aes(x = age_group, y = -female),
        alpha = 0.7
      ) +
      # Male to the right (positive)
      geom_col(
        data = df,
        aes(x = age_group, y = male),
        alpha = 0.7
      ) +
      coord_flip() +
      labs(
        x = "Age group",
        y = "DALYs (weighted)"
      ) +
      theme_minimal()
  })
}

shinyApp(ui, server)
