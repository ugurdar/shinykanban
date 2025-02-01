#' Create a Kanban Board Widget
#'
#' This function creates an interactive Kanban board as an HTML widget.
#'
#' @param data A named list representing the board data.
#' @param styleOptions A named list of style options.
#' @param width,height Optional widget dimensions.
#' @param elementId DOM element ID.
#'
#' @import bsicons
#' @import htmlwidgets
#' @export
kanban <- function(
    data,
    styleOptions = list(
      headerBg = "#fff",
      headerBgHover = "#fff",
      headerColor = "#353535",
      headerFontSize = "1rem",
      listNameFontSize = "1rem",
      cardTitleFontSize = "1rem",
      cardTitleFontWeight = 600,
      cardSubTitleFontSize = "0.8rem",
      cardSubTitleFontWeight  = 300,
      addCardBgColor = "#999",
      deleteList = list(
        backgroundColor = "#fff",
        color = "#353535",
        icon = bsicons::bs_icon("x"),
        size = "1rem"
      ),
      deleteCard = list(
        backgroundColor = "#fff",
        color = "#353535",
        icon = bsicons::bs_icon("trash"),
        size = "1rem"
      ),
      addButtonText = "Add",
      cancelButtonText = "Cancel",
      addCardButtonText = "Add Card",
      cancelCardButtonText = "Cancel"
    ),
    width = NULL,
    height = NULL,
    elementId = NULL
) {
  if (missing(data)) {
    stop("`data` must be provided.")
  }
  defaults <- list(
    headerBg = "#fff",
    headerBgHover = "#fff",
    headerColor = "#353535",
    headerFontSize = "1rem",
    listNameFontSize = "1rem",
    cardTitleFontSize = "1rem",
    cardTitleFontWeight = 600,
    cardSubTitleFontSize = "0.8rem",
    cardSubTitleFontWeight  = 300,
    addCardBgColor = "#999",
    deleteList = list(
      backgroundColor = "#fff",
      color = "#353535",
      icon = bsicons::bs_icon("x"),
      size = "1rem"
    ),
    deleteCard = list(
      backgroundColor = "#fff",
      color = "#353535",
      icon = bsicons::bs_icon("trash"),
      size = "1rem"
    ),
    addButtonText = "Add",
    cancelButtonText = "Cancel",
    addCardButtonText = "Add Card",
    cancelCardButtonText = "Cancel"
  )


  finalStyle <- modifyList(defaults, styleOptions)

  component <- reactR::reactMarkup(
    htmltools::tag("KanbanBoard", list(
      data = data,
      elementId = elementId,
      styleOptions = finalStyle
    ))
  )

  htmlwidgets::createWidget(
    name = "kanban",
    component,
    width = width,
    height = height,
    package = "shinykanban",
    elementId = elementId
  )
}


#' Called by HTMLWidgets to produce the widget's root element.
#' @import reactR
#' @noRd
widget_html.kanban <- function(id, style, class, ...) {
  htmltools::tagList(
    reactR::html_dependency_corejs(),
    reactR::html_dependency_react(),
    reactR::html_dependency_reacttools(),
    htmltools::tags$div(id = id, class = class, style = style)
  )
}


is.tag <- function(x) {
  inherits(x, "shiny.tag")
}

isTagList <- function(x) {
  inherits(x, "shiny.tag.list") || (is.list(x) && all(sapply(x, is.tag)))
}


#' Shiny bindings for Kanban Board
#'
#' Output and render functions for using Kanban Board within Shiny.
#' @param outputId Output variable to read the value from
#' @param width,height A valid CSS unit (like `"100%"`, `"400px"`, `"auto"`)
#' or a number, which will be coerced to a string and have `"px"` appended.
#' @name kanban-shiny
#' @import htmlwidgets
#' @export
kanbanOutput <- function(outputId, width = "100%", height = "400px") {
  output <- htmlwidgets::shinyWidgetOutput(outputId, "kanban", width, height, package = "shinykanban")
  # Add attribute to Shiny output containers to differentiate them from static widgets
  addOutputId <- function(x) {
    if (isTagList(x)) {
      x[] <- lapply(x, addOutputId)
    } else if (is.tag(x)) {
      x <- htmltools::tagAppendAttributes(x, "data-kanban-output" = outputId)
    }
    x
  }
  output <- addOutputId(output)
  output
}

#' Renders a kanban that is suitable for assigning to an output slot.
#' @examples
#' if(interactive()){
#'library(shiny)
#'library(shinykanban)
#'library(bslib)
#'library(bsicons)
#'
#'ui <- page_fluid(
#' title = "My App",
#' nav_panel(title = "One",
#'            kanbanOutput("kanban_board")
#'  )
#')
#'
#'server <- function(input, output, session) {
#'
#' kanban_data <- reactiveVal(
#'  list(
#'  "To Do" = list(
#'    name = "To Do",
#'    items = list(
#'     list(
#'       id = "task1",
#'       title = "Task 1",
#'       subtitle = "abc"
#'     ),
#'      list(
#'       id = "task2",
#'       title = "Task 2"
#'     )
#'    ),
#'    listPosition = 1
#'   ),
#'  "In Progress" = list(
#'   name = "In Progress",
#'   items = list(
#'     list(
#'      id = "task3",
#'      title = "Task 3"
#'    )
#'   ),
#'     listPosition = 2
#'    )
#'   ))
#'
#' output$kanban_board <- renderKanban({
#'  message("rerendering")
#'  kanban(
#'   data = kanban_data()
#'   )
#' })
#'
#'  # Get any change from kanban and update the data
#' observeEvent(input$kanban_board, {
#' new_list <- input$kanban_board
#' new_list$`_timestamp` <- NULL
#'    kanban_data(new_list)
#'  })
#'}
#'
#'shinyApp(ui, server)
#'
#'}
#' @param expr An expression that generates kanban board with shinykanban::kanban()
#' @rdname kanban-shiny
#' @import htmlwidgets
#' @export
renderKanban <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # Force quoted expression
  htmlwidgets::shinyRenderWidget(expr, kanbanOutput, env, quoted = TRUE)
}

#' Update the data for a Kanban input on the client.
#'
#' @param session The Shiny session object.
#' @param inputId The ID of the input object.
#' @param data The data to set.
#' @export
updateKanban <- function(session, inputId, data) {
  session$sendCustomMessage(inputId, list(data = data))
}

#' Get the Selected Card Data
#'
#' Retrieves the details of a card that was clicked on the Kanban board.
#' @param outputId A character string specifying the ID of the Kanban output.
#' @return A list with the selected card's details as a list (listName, title, id, position, clickCount)
#' @import shiny
#' @export
getSelectedCard <- function(outputId, session = NULL) {
  if (is.null(session)) {
    if (requireNamespace("shiny", quietly = TRUE)) {
      session <- shiny::getDefaultReactiveDomain()
    }
    if (is.null(session)) {
      # Not in an active Shiny session
      return(NULL)
    }
  }
  if (!is.character(outputId)) {
    stop("`outputId` must be a character string")
  }

  state <- session$input[[sprintf("%s__kanban__card", outputId)]]

  state
}


