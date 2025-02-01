library(shiny)
library(shinykanban)
library(bslib)
library(bsicons)

ui <- page_fluid(
  title = "My App",
  nav_panel(title = "One",
            # textInput("new_list_name", "New List Name:", ""),
            # actionButton("add_list", "Add List"),
            # textInput("new_task_name", "New Task Name:", ""),
            selectInput("select_list", "Select List:", choices = NULL),
            # actionButton("add_task", "Add Task"),
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
    message("rerendering")
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


  # Adding a list with a button

  # observeEvent(input$add_list, {
  #   new_list_name <- input$new_list_name
  #   if (new_list_name != "") {
  #     current_data <- kanban_data()
  #
  #     current_data[[new_list_name]] <- list(name = new_list_name,
  #                                           items = list())
  #
  #     kanban_data(current_data)
  #     updateKanban(session, "kanban_board", data = current_data)
  #   }
  # })


  # Add a task with a button

  # observeEvent(input$add_task, {
  #   new_task_name <- input$new_task_name
  #   selected_list <- input$select_list
  #
  #   if (new_task_name != "" &&
  #       selected_list %in% names(kanban_data())) {
  #     current_data <- kanban_data()
  #     new_task_id <- paste0("task_", Sys.time())
  #     current_data[[selected_list]]$items <- append(current_data[[selected_list]]$items,
  #                                                   list(list(id = new_task_id, content = new_task_name)))
  #     kanban_data(current_data)
  #     updateKanban(session, "kanban_board", data = current_data)
  #   }
  # })

  # Getting card information

  # selectedCard <- reactive({
  #   getSelectedCard("kanban_board")
  # })
  #
  # observe({
  #   print(selectedCard())
  # })
}

shinyApp(ui, server)
