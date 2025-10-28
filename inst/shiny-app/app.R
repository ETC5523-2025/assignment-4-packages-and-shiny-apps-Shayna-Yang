# inst/shiny/app.R

library(shiny)
library(dplyr)
library(ggplot2)
library(tidyr)
library(bslib)
library(plotly)

# 1. Data from package

data("shayhai_cases", package = "shayhai")       # German PPS
data("shayhai_cases_ecdc", package = "shayhai")  # ECDC PPS

shayhai_cases <- shayhai_cases |>
  mutate(module = "German PPS")

shayhai_cases_ecdc <- shayhai_cases_ecdc |>
  mutate(module = "ECDC PPS")

all_cases <- bind_rows(shayhai_cases, shayhai_cases_ecdc)

infection_choices <- c("HAP", "SSI", "BSI", "UTI", "CDI")
module_choices <- c("German PPS", "ECDC PPS")
sex_choices <- c("Female", "Male")
age_choices <- c(
  "0-1","2-4","5-9","10-14","15-19","20-24",
  "25-34","35-44","45-54","55-64",
  "65-74","75-79","80-84","85+"
)

# UI
ui <- navbarPage(
  title = "shayhai: HAI Explorer",
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly"
  ),
  header = tags$head(
    tags$link(
      rel = "stylesheet",
      href = "https://fonts.googleapis.com/css2?family=PT+Sans:wght@400;700&display=swap"
    ),

    tags$link(
      rel = "stylesheet",
      type = "text/css",
      href = "app.css"
    )
  ),

  # panel 1: bubble
  tabPanel(
    "Bubble plot",
    sidebarLayout(
      sidebarPanel(
        width = 3,
        h4("Filters"),
        checkboxGroupInput("infection_type", "Infection type(s)",
                           choices  = infection_choices,
                           selected = infection_choices
        )
      ),
      mainPanel(
        width = 9,
        div(class = "card-box",
            h4("Bubble plot: DALYs vs deaths vs cases"),
            plotlyOutput("bubble_plot", height = "500px"),
            tags$small(
              "Each bubble = infection type; ",
              "X = Number of HAIs, Y = Attributable deaths; ",
              "Bubble size = DALYs; Color = Survey module (German PPS / ECDC PPS)."
            )
        )
      )
    )
  ),

  # panel: bar
  tabPanel(
    "Bar plot with 95% UI",
    sidebarLayout(
      sidebarPanel(
        width = 3,
        h4("Filters"),

        checkboxGroupInput(
          "infection_type_bar", "Infection type(s)",
          choices  = infection_choices,
          selected = infection_choices
        ),

        checkboxGroupInput(
          "module_bar", "Survey module(s)",
          choices  = module_choices,
          selected = module_choices
        ),

        tags$hr(),
        radioButtons(
          "metric_bar",
          "Choose metric:",
          choices = c(
            "Attributable deaths per 100,000" = "deaths",
            "DALYs per 100,000"               = "dalys"
          ),
          selected = "deaths"
        )
      ),

      mainPanel(
        width = 9,
        div(class = "card-box",
            h4("Annual burden by infection type"),
            plotlyOutput("bar_plot", height = "520px")
        )
      )
    )
  ),

  # panel: Age pyramid
  tabPanel(
    "Age pyramid",
    sidebarLayout(
      sidebarPanel(
        width = 3,
        h4("Filters"),

        checkboxGroupInput("infection_type_pyr", "Infection type(s)",
                           choices  = infection_choices,
                           selected = infection_choices
        ),


        checkboxGroupInput("sex_pyr", "Sex",
                           choices  = sex_choices,
                           selected = sex_choices
        ),

        checkboxGroupInput("age_group_pyr", "Age group(s)",
                           choices  = age_choices,
                           selected = age_choices
        )
      ),
      mainPanel(
        width = 9,
        div(class = "card-box",
            h4("Age pyramid: Weighted DALYs by sex and age group"),
            plotlyOutput("pyramid_plot", height = "500px"),
            tags$small(
              "Left = Female, Right = Male; Width = total DALYs. ",
              "Use filters to focus on a specific infection or demographic group."
            )
        )
      )
    )
  ),

  # panel: summary table
  tabPanel(
    "Summary table",
    fluidPage(
      div(class = "card-box",
          h4("Annual burden per 100,000 population"),
          tags$small(
            "Structure inspired by Table 2 of the report. ",
            "Cells show point estimate per 100,000 (95% UI). ",
            "95% UI here is an illustrative ±10% interval."
          ),
          DT::dataTableOutput("summary_table")
      )
    )
  ),

  # panel: About
  tabPanel(
    "About",
    div(class = "card-box",
        h3("About this app"),
        p("This Shiny app is part of the ", tags$code("shayhai"), " package."),
        p("It visualises simulated estimates of the burden of ",
          tags$b("healthcare-associated infections (HAIs)"),
          " based on two sources: the German PPS (2011) and the ECDC PPS (EU/EEA, 2011–2012)."),
        tags$hr(),

        h4("Purpose"),
        p("The goal is to help users explore differences in HAI burden across infection types, ",
          "survey modules (German vs EU/EEA), and demographic subgroups (age, sex)."),
        tags$hr(),

        h4("Field glossary"),
        tags$ul(
          tags$li(tags$b("HAP"), " = healthcare-associated pneumonia"),
          tags$li(tags$b("UTI"), " = urinary tract infection"),
          tags$li(tags$b("BSI"), " = primary bloodstream infection"),
          tags$li(tags$b("SSI"), " = surgical-site infection"),
          tags$li(tags$b("CDI"), " = ", tags$i("Clostridioides difficile"), " infection")
        ),
        tags$br(),
        tags$b("DALY"), " = YLL (years of life lost) + YLD (years lived with disability).",
        tags$hr(),

        h4("Data description"),
        p("Each record in the dataset represents a simulated HAI case, ",
          "weighted by ", tags$code("weight_pop"), " to represent its contribution to the population-level burden."),
        tags$ul(
          tags$li(tags$code("infection_type"), " – infection category (HAP, SSI, BSI, UTI, CDI)"),
          tags$li(tags$code("module"), " – data source (German PPS, ECDC PPS)"),
          tags$li(tags$code("sex"), " – Male or Female"),
          tags$li(tags$code("age_group"), " – 14 age bands from 0–1 up to 85+"),
          tags$li(tags$code("died"), " – 1 if the simulated case resulted in death, else 0"),
          tags$li(tags$code("yll"), " – years of life lost for that case"),
          tags$li(tags$code("yld"), " – years lived with disability for that case"),
          tags$li(tags$code("daly"), " – sum of YLL and YLD"),
          tags$li(tags$code("weight_pop"), " – scaling weight to extrapolate the case to population totals")
        ),
        tags$hr(),

        h4("How to interpret the plots"),
        p("Each plot provides a complementary perspective on the burden of healthcare-associated infections (HAIs). ",
          "Together, they allow users to explore both the magnitude and the distribution of burden across infection types,
          demographics, and survey modules. "),
        tags$ul(
          tags$li(tags$b("Bubble plot:"),
                  "Each bubble represents one infection type (HAP, SSI, BSI, UTI, or CDI). ",
                  "X = number of HAIs (weighted), Y = attributable deaths (weighted). ",
                  "The diameter of the bubbles is proportional to the annual numbers of DALYs.
                  Bubble colour identifies the survey module (German PPS or ECDC PPS)."),

          tags$li(tags$b("Bar plot:"),
                  "Shows the burden by infection type, with separate bars for German PPS and ECDC PPS. ",
                  "Error bars indicate the ", tags$b("95% uncertainty interval (UI)"),
                  " shown here as a placeholder ±10% around the estimate. ",
                  "Colours are fixed: German PPS = steelblue, ECDC PPS = coral."),

          tags$li(tags$b("Age pyramid:"),
                  "Visualises the distribution of total DALYs across age and sex groups.",
                  "Left = Female, Right = Male; bar represents total DALYs (weighted).",
                  "This plot highlights demographic patterns—for example,
                  whether burden is concentrated among older adults,
                  or differs between sexes within infection types.")
        ),
        tags$hr(),

        h4("Uncertainty intervals"),
        p("Bars display ", tags$b("95% uncertainty intervals (UIs)"),
          " as placeholders (±10% of the estimate). ",
          "In the real BHAI workflow, these would be derived from modelled posterior distributions (2.5th–97.5th quantiles)."),
        tags$hr(),

        h4("References"),
        tags$ul(
          tags$li("Zacher B. et al. (2019). ",
                  tags$i("Burden of healthcare-associated infections in Germany: results of the burden of communicable diseases in Europe study (BCoDE)."),
                  " Eurosurveillance 24(46): 1900135. ",
                  tags$a(href="https://www.eurosurveillance.org/content/10.2807/1560-7917.ES.2019.24.46.1900135",
                         "View article", target="_blank")),
          tags$li("Cassini A. et al. (2016). ",
                  tags$i("Burden of Six Healthcare-Associated Infections on European Population Health: Estimating Incidence-Based Disability-Adjusted Life Years through a Population Prevalence-Based Modelling Study."),
                  " PLoS Med 13(10): e1002150.")
        )
    )
  )
)

# Server
server <- function(input, output, session) {

  filter_cases <- function(
    infection = infection_choices,
    module    = module_choices,
    sex       = sex_choices,
    age       = age_choices
  ) {
    all_cases |>
      filter(
        infection_type %in% infection,
        module         %in% module,
        sex            %in% sex,
        age_group      %in% age
      )
  }

  # Bubble
  output$bubble_plot <- renderPlotly({
    df <- filter_cases(
      infection = input$infection_type,
      module    = module_choices,
      sex       = sex_choices,
      age       = age_choices
    ) |>
      group_by(infection_type, module) |>
      summarise(
        cases_est  = sum(weight_pop, na.rm = TRUE),
        deaths_est = sum(weight_pop * died, na.rm = TRUE),
        dalys_est  = sum(weight_pop * daly, na.rm = TRUE),
        .groups = "drop"
      )

    validate(need(nrow(df) > 0, "No data for current filter."))

    p <- ggplot(
      df,
      aes(
        x = cases_est,
        y = deaths_est,
        size  = dalys_est,
        color = module,
        text = paste(
          "Infection:", infection_type,
          "<br>Module:", module,
          "<br>Cases:", round(cases_est),
          "<br>Deaths:", round(deaths_est),
          "<br>DALYs:", round(dalys_est)
        )
      )
    ) +
      geom_point(alpha = 0.6) +
      geom_text(aes(label = infection_type), vjust = -0.7, size = 3) +
      scale_size_area(max_size = 20) +
      scale_color_manual(
        values = c("German PPS" = "steelblue", "ECDC PPS" = "coral")
      ) +
      labs(
        x = "Number of HAIs (weighted)",
        y = "Attributable deaths (weighted)",
        size  = "DALYs (weighted)",
        color = "Survey module"
      ) +
      theme_minimal()

    ggplotly(p, tooltip = "text")
  })

  # Bar plot
  output$bar_plot <- renderPlotly({
    df <- all_cases |>
      filter(
        infection_type %in% input$infection_type_bar,
        module         %in% input$module_bar
      ) |>
      group_by(infection_type, module) |>
      summarise(
        deaths_est = sum(weight_pop * died, na.rm = TRUE),
        dalys_est  = sum(weight_pop * daly, na.rm = TRUE),
        .groups = "drop"
      ) |>
      mutate(
        ui_low_death  = deaths_est * 0.9,
        ui_high_death = deaths_est * 1.1,
        ui_low_daly   = dalys_est * 0.9,
        ui_high_daly  = dalys_est * 1.1,
        infection_type = factor(infection_type, levels = infection_choices),
        module         = factor(module,         levels = module_choices)
      )

    validate(need(nrow(df) > 0, "No data for current filter."))

    metric <- input$metric_bar

    if (metric == "deaths") {
      p <- ggplot(
        df,
        aes(
          x = infection_type,
          y = deaths_est,
          fill = module,
          text = paste(
            "Infection:", infection_type,
            "<br>Module:", module,
            "<br>Attributable deaths:", round(deaths_est, 1),
            "<br>95% UI:",
            paste0(round(ui_low_death, 1), " – ", round(ui_high_death, 1))
          )
        )
      ) +
        geom_col(
          position = position_dodge(width = 0.7),
          width = 0.6
        ) +
        geom_errorbar(
          aes(ymin = ui_low_death, ymax = ui_high_death),
          position = position_dodge(width = 0.7),
          width = 0.2
        ) +
        scale_fill_manual(
          values = c("German PPS" = "steelblue", "ECDC PPS" = "coral"),
          name = "Survey module"
        ) +
        labs(
          x = "Infection type",
          y = "Attributable deaths (weighted)"
        ) +
        theme_minimal() +
        theme(
          panel.grid.minor   = element_blank(),
          panel.grid.major.y = element_line(color = "grey90")
        )

    } else { # DALYs
      p <- ggplot(
        df,
        aes(
          x = infection_type,
          y = dalys_est,
          fill = module,
          text = paste(
            "Infection:", infection_type,
            "<br>Module:", module,
            "<br>DALYs:", round(dalys_est, 1),
            "<br>95% UI:",
            paste0(round(ui_low_daly, 1), " – ", round(ui_high_daly, 1))
          )
        )
      ) +
        geom_col(
          position = position_dodge(width = 0.7),
          width = 0.6
        ) +
        geom_errorbar(
          aes(ymin = ui_low_daly, ymax = ui_high_daly),
          position = position_dodge(width = 0.7),
          width = 0.2
        ) +
        scale_fill_manual(
          values = c("German PPS" = "steelblue", "ECDC PPS" = "coral"),
          name = "Survey module"
        ) +
        labs(
          x = "Infection type",
          y = "DALYs (weighted)"
        ) +
        theme_minimal() +
        theme(
          panel.grid.minor   = element_blank(),
          panel.grid.major.y = element_line(color = "grey90")
        )
    }

    ggplotly(p, tooltip = "text")
  })

  # Age Pyramid
  output$pyramid_plot <- renderPlotly({
    # empty sex filter empty plot
    validate(
      need(length(input$sex_pyr) > 0, "No data for current filter.")
    )
    # age level
    age_levels_desc <- rev(age_choices)  # "85+" ... "0-1"
    age_levels_desc_filtered <- age_levels_desc[age_levels_desc %in% input$age_group_pyr]

    df_raw <- all_cases |>
      filter(
        infection_type %in% input$infection_type_pyr,
        sex            %in% input$sex_pyr,
        age_group      %in% input$age_group_pyr
      )

    validate(
      need(nrow(df_raw) > 0, "No data for current filter.")
    )

    df <- df_raw |>
      group_by(age_group, sex) |>
      summarise(
        daly_weighted = sum(weight_pop * daly, na.rm = TRUE),
        .groups = "drop"
      ) |>
      mutate(
        sex = tolower(sex),
        age_group = factor(age_group, levels = age_levels_desc_filtered)
      ) |>
      tidyr::pivot_wider(
        names_from  = sex,              # "female", "male"
        values_from = daly_weighted,
        values_fill = 0
      )

    # make sure the coulumn exist if user choose only one
    if (!"female" %in% names(df)) df$female <- 0
    if (!"male"   %in% names(df)) df$male   <- 0

    df <- df |>
      arrange(age_group)

    # if all 0 then stop
    validate(
      need(sum(df$female) + sum(df$male) > 0, "No data for current filter.")
    )

    p <- ggplot() +
      geom_col(
        data = df,
        aes(
          x = age_group,
          y = -female,
          text = paste(
            "Age:", age_group,
            "<br>Sex: Female",
            "<br>DALYs:", round(female)
          )
        ),
        alpha = 1,
        fill = "coral"
      ) +
      geom_col(
        data = df,
        aes(
          x = age_group,
          y = male,
          text = paste(
            "Age:", age_group,
            "<br>Sex: Male",
            "<br>DALYs:", round(male)
          )
        ),
        alpha = 1,
        fill = "steelblue"
      ) +
      coord_flip() +
      labs(
        x = "Age group",
        y = "DALYs (weighted)"
      ) +
      theme_minimal()

    ggplotly(p, tooltip = "text")
  })

  # --- helper to format "point (low–high)" -----------------
  fmt_ui <- function(est) {
    low  <- est * 0.9
    high <- est * 1.1
    paste0(
      round(est, 1), " (",
      round(low, 1), "–",
      round(high, 1), ")"
    )
  }

  # table
  output$summary_table <- DT::renderDataTable({
    df_filt <- filter_cases(
      infection = infection_choices,
      module    = module_choices,
      sex       = sex_choices,
      age       = age_choices
    )
    validate(need(nrow(df_filt) > 0, "No data for current filter."))

    # compute denominator per module
    denom_by_module <- df_filt |>
      group_by(module) |>
      summarise(
        pop_equiv = sum(weight_pop, na.rm = TRUE),
        .groups = "drop"
      )
    # compute totals by module x infection_type
    by_inf <- df_filt |>
      group_by(module, infection_type) |>
      summarise(
        cases_est  = sum(weight_pop, na.rm = TRUE),
        deaths_est = sum(weight_pop * died, na.rm = TRUE),
        dalys_est  = sum(weight_pop * daly, na.rm = TRUE),
        .groups = "drop"
      ) |>
      left_join(denom_by_module, by = "module") |>
      mutate(
        rate_cases_per100k  = (cases_est  / pop_equiv) * 100000,
        rate_deaths_per100k = (deaths_est / pop_equiv) * 100000,
        rate_dalys_per100k  = (dalys_est  / pop_equiv) * 100000
      )
    # compute across infection types per module
    by_all <- df_filt |>
      group_by(module) |>
      summarise(
        cases_est  = sum(weight_pop, na.rm = TRUE),
        deaths_est = sum(weight_pop * died, na.rm = TRUE),
        dalys_est  = sum(weight_pop * daly, na.rm = TRUE),
        .groups = "drop"
      ) |>
      left_join(denom_by_module, by = "module") |>
      mutate(
        infection_type = "All",
        rate_cases_per100k  = (cases_est  / pop_equiv) * 100000,
        rate_deaths_per100k = (deaths_est / pop_equiv) * 100000,
        rate_dalys_per100k  = (dalys_est  / pop_equiv) * 100000
      )

    # combine infection-specific rows + All
    rate_long <- bind_rows(by_inf, by_all)

    # helper to build one block (e.g. "HAIs per 100,000")
    block_cases <- rate_long |>
      select(module, infection_type, value = rate_cases_per100k) |>
      mutate(measure = "HAIs per 100,000")

    block_deaths <- rate_long |>
      select(module, infection_type, value = rate_deaths_per100k) |>
      mutate(measure = "Attributable deaths per 100,000")

    block_dalys <- rate_long |>
      select(module, infection_type, value = rate_dalys_per100k) |>
      mutate(measure = "DALYs per 100,000")

    blocks <- bind_rows(block_cases, block_deaths, block_dalys)

    # turn each numeric into "point (low–high)" string
    blocks <- blocks |>
      mutate(formatted = fmt_ui(value))

    # spread infection types to columns
    inf_order <- c("HAP","UTI","BSI","SSI","CDI","All")
    blocks$infection_type <- factor(blocks$infection_type, levels = inf_order)

    table_wide <- blocks |>
      select(measure, module, infection_type, formatted) |>
      tidyr::pivot_wider(
        names_from  = infection_type,
        values_from = formatted
      ) |>
      arrange(
        factor(measure,
               levels = c("HAIs per 100,000",
                          "Attributable deaths per 100,000",
                          "DALYs per 100,000")),
        module
      )
    # final table
    table_wide <- table_wide |>
      rename(
        `Annual burden measure` = measure,
        Sample = module
      )

    DT::datatable(
      table_wide,
      rownames = FALSE,
      options = list(
        paging = FALSE,
        searching = FALSE,
        ordering = FALSE,
        info = FALSE,
        scrollX = TRUE
      )
    )
  })
}

shinyApp(ui, server)
