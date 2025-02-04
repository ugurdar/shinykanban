<img align="right" width="220" height="240" src="https://drive.google.com/file/d/12CIiaTKPJh4D1IegS5jzM30E4MEm-oQ_">

# datadriftR

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/datadriftR)](https://cran.r-project.org/package=datadriftR)
[![](https://cranlogs.r-pkg.org/badges/datadriftR)](https://cran.rstudio.com/web/packages/datadriftR/index.html)
[![](http://cranlogs.r-pkg.org/badges/last-week/datadriftR?color=green)](https://cran.r-project.org/package=datadriftR)
<!-- badges: end -->


## Installation

``` r
install.packages("datadriftR")
```

## Example

``` r
remotes::install_github("ugurdar/datadriftR@main")
```

```
library(shiny)
library(shinykanban)
library(bslib)
library(bsicons)

ui <- page_fluid(
  title = "My App",
  nav_panel(title = "One",
            kanbanOutput("kanban_board")
  )
)

server <- function(input, output, session) {

  kanban_data <- reactiveVal(
    list(
      "To Do" = list(
        name = "To Do",
        items = list(
          list(
            id = "task1",
            title = "Task 1",
            subtitle = "abc"
          ),
          list(
            id = "task2",
            title = "Task 2"
          )
        ),
        listPosition = 1
      ),
      "In Progress" = list(
        name = "In Progress",
        items = list(
          list(
            id = "task3",
            title = "Task 3"
          )
        ),
        listPosition = 2
      )
    ))

  output$kanban_board <- renderKanban({
    kanban(
      data = kanban_data()
    )
  })

  # Get any change from kanban and update the data
  observeEvent(input$kanban_board, {
    new_list <- input$kanban_board
    new_list$`_timestamp` <- NULL
    kanban_data(new_list)
  })

}

shinyApp(ui, server)

```

<img width="420" height="440" src="https://drive.google.com/file/d/1fQKFVrmcNnlNzMir4cDGjXGW42utPZhU/view?usp=drive_link">
