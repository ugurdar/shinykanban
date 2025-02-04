<img src="https://drive.google.com/uc?export=download&id=12CIiaTKPJh4D1IegS5jzM30E4MEm-oQ_" align="right" alt="Rhino logo" style="height: 140px;">

# shinykanban

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/shinykanban)](https://cran.r-project.org/package=shinykanban)
[![](https://cranlogs.r-pkg.org/badges/shinykanban)](https://cran.rstudio.com/web/packages/shinykanban/index.html)
[![](http://cranlogs.r-pkg.org/badges/last-week/shinykanban?color=green)](https://cran.r-project.org/package=shinykanban)
<!-- badges: end -->


## Installation

``` r
install.packages("shinykanban")
```

## Example

``` r
remotes::install_github("ugurdar/shinykanban@main")
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

<img width="620" height="340" src="https://drive.google.com/uc?export=download&id=1fQKFVrmcNnlNzMir4cDGjXGW42utPZhU">
