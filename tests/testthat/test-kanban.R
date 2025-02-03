test_that("kanban errors if data is not provided", {
  expect_error(kanban(), "`data` must be provided.")
})

test_that("kanban creates a widget with proper attributes", {
  sample_data <- list(
    lists = list(
      list(id = 1, title = "Test List", cards = list())
    )
  )

  widget <- kanban(
    data = sample_data,
    width = "600px",
    height = "400px",
    elementId = "test-kanban"
  )

  expect_s3_class(widget, "htmlwidget")

  widgetName <- attr(widget, "htmlwidgets.widgetName")
  widgetPackage <- attr(widget, "htmlwidgets.package")


  expect_equal(widget$width, "600px")
  expect_equal(widget$height, "400px")
  expect_equal(widget$elementId, "test-kanban")


})

#######################################################################

tag1 <- list(content = "Tag 1")
class(tag1) <- "shiny.tag"

tag2 <- list(content = "Tag 2")
class(tag2) <- "shiny.tag"

tag_list <- list(tag1, tag2)

tag_list_with_class <- list(tag1, tag2)
class(tag_list_with_class) <- "shiny.tag.list"

non_tag <- list(content = "Non-tag")

non_tag_vector <- 1:5

test_that("is.tag returns TRUE for objects with class shiny.tag", {
  expect_true(is.tag(tag1))
  expect_true(is.tag(tag2))

  expect_false(is.tag(non_tag))
  expect_false(is.tag(non_tag_vector))

  non_list_tag <- "example"
  class(non_list_tag) <- "shiny.tag"
  expect_true(is.tag(non_list_tag))
})
test_that("isTagList returns TRUE when object has shiny.tag.list class", {
  expect_true(isTagList(tag_list_with_class))
})

test_that("isTagList returns TRUE for a list of shiny.tag objects", {
  expect_true(isTagList(tag_list))
})

test_that("isTagList returns TRUE for an empty list", {
  expect_true(isTagList(list()))
})

test_that("isTagList returns FALSE for lists with non-tag elements", {
  mixed_list <- list(tag1, non_tag)
  expect_false(isTagList(mixed_list))
})

test_that("isTagList returns FALSE for non-list objects", {
  expect_false(isTagList(tag1))
  expect_false(isTagList("not a list"))
  expect_false(isTagList(123))
})

#######################################################################
test_that("widget_html.kanban returns a shiny.tag.list object", {
  widget <- widget_html.kanban("test-id", "color: red;", "test-class")
  expect_true(inherits(widget, "shiny.tag.list"))
})

test_that("widget_html.kanban contains a div with correct attributes", {
  test_id <- "div-id"
  test_style <- "background-color: blue;"
  test_class <- "div-class"

  widget <- widget_html.kanban(test_id, test_style, test_class)

  div_tag <- widget[[length(widget)]]
  expect_equal(div_tag$name, "div")
  expect_equal(div_tag$attribs$id, test_id)
  expect_equal(div_tag$attribs$style, test_style)
  expect_equal(div_tag$attribs$class, test_class)
})

#######################################################################

test_that("kanbanOutput returns valid HTML output with correct attributes", {
  outputId <- "test-output"
  width <- "250px"
  height <- "350px"

  out <- suppressWarnings(kanbanOutput(outputId, width = width, height = height))

  findDataAttr <- function(x) {
    if (inherits(x, "shiny.tag")) {
      return(x$attribs[["data-kanban-output"]])
    } else if (is.list(x)) {
      return(unlist(lapply(x, findDataAttr)))
    } else {
      return(NULL)
    }
  }

  data_attrs <- findDataAttr(out)
  expect_true(outputId %in% data_attrs)

  if (inherits(out, "shiny.tag") && !is.null(out$attribs$style)) {
    expect_true(grepl(width, out$attribs$style))
    expect_true(grepl(height, out$attribs$style))
  }
})
#######################################################################

test_that("updateKanban sends a custom message with correct inputId and data", {
  dummy_session <- new.env(parent = emptyenv())
  dummy_session$last_message <- NULL

  dummy_session$sendCustomMessage <- function(type, message) {
    dummy_session$last_message <- list(type = type, message = message)
  }

  inputId <- "test-kanban"
  data <- list(a = 1, b = 2, c = "test")

  updateKanban(dummy_session, inputId, data)

  expect_equal(dummy_session$last_message$type, inputId)
  expect_equal(dummy_session$last_message$message, list(data = data))
})

#######################################################################

test_that("getSelectedCard errors when outputId is not a character", {
  dummy_session <- list(input = list(dummy__kanban__card = "some_value"))

  expect_error(getSelectedCard(123, dummy_session),
               "`outputId` must be a character string")
})

test_that("getSelectedCard returns the correct state from session input", {
  dummy_session <- list(input = list())
  outputId <- "kanban1"
  key <- sprintf("%s__kanban__card", outputId)

  dummy_session$input[[key]] <- "selected_card_value"

  result <- getSelectedCard(outputId, dummy_session)
  expect_equal(result, "selected_card_value")
})


