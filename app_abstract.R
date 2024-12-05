library(shiny)
library(readxl)
library(writexl)
library(dplyr)
library(shinyjs)

# Load the abstracts from the Excel file using the correct path
abstracts <- read_excel("abstracts.xlsx")

# Check if abstracts are available
if (nrow(abstracts) == 0) {
  stop("No abstracts found in the provided file.")
}

# Function to load or create randomized order
load_or_create_randomized_order <- function(reviewer) {
  file_path <- paste0("randomized_order_", reviewer, ".txt")
  if (file.exists(file_path)) {
    randomized_order <- as.numeric(readLines(file_path))
  } else {
    set.seed(1981)  # Set a seed for reproducibility
    randomized_order <- sample(1:nrow(abstracts))
    writeLines(as.character(randomized_order), file_path)
  }
  return(randomized_order)
}

# Define the UI
ui <- fluidPage(
  useShinyjs(),  # Include shinyjs
  titlePanel("Abstract Review"),
  sidebarLayout(
    sidebarPanel(
      selectInput("reviewer", "Reviewer", choices = c("R1", "R2", "R3")),
      actionButton("prev_btn", "Previous Abstract"),
      actionButton("next_btn", "Next Abstract"),
      numericInput("jump_to_id", "Jump to Abstract ID:", value = 1, min = 1, max = nrow(abstracts)),
      actionButton("jump_btn", "Jump to Abstract")
    ),
    mainPanel(
      uiOutput("abstract_info"),
      textInput("relevance", "Relevance (0-10)", value = ""),
      textInput("method", "Methods (0-10)", value = ""),
      uiOutput("outcome"),  # Dynamic UI for outcome
      actionButton("submit", "Submit Score"),
      hidden(div(id = "feedback", "Score submitted successfully!")),  # Hidden feedback message
      textOutput("feedback_text")  # Add a feedback output
    )
  )
)

# Define the server logic
server <- function(input, output, session) {
  # Reactive value to track the current abstract
  values <- reactiveValues(current = 1)
  
  # Load the current abstract index from a file if it exists
  observe({
    reviewer <- input$reviewer
    values$randomized_order <- load_or_create_randomized_order(reviewer)
    if (file.exists(paste0("current_abstract_index_", reviewer, ".txt"))) {
      values$current <- as.numeric(readLines(paste0("current_abstract_index_", reviewer, ".txt")))
    }
  })
  
  # Save the current abstract index to a file when the session ends
  observe({
    reviewer <- input$reviewer
    session$onSessionEnded(function() {
      writeLines(as.character(isolate(values$current)), paste0("current_abstract_index_", reviewer, ".txt"))
    })
  })
  
  # Navigate to the next abstract
  observeEvent(input$next_btn, {
    reviewer <- input$reviewer
    if (nrow(abstracts) > 0) {
      values$current <- (values$current %% nrow(abstracts)) + 1
      updateTextInput(session, "relevance", value = "")
      updateTextInput(session, "method", value = "")
      updateSelectInput(session, "outcome", selected = character(0))
    }
  })
  
  # Navigate to the previous abstract
  observeEvent(input$prev_btn, {
    reviewer <- input$reviewer
    if (nrow(abstracts) > 0) {
      values$current <- ifelse(values$current == 1, nrow(abstracts), values$current - 1)
    }
  })
  
  # Jump to a specific abstract by ID
  observeEvent(input$jump_btn, {
    reviewer <- input$reviewer
    if (nrow(abstracts) > 0) {
      values$current <- input$jump_to_id
      updateTextInput(session, "relevance", value = "")
      updateTextInput(session, "method", value = "")
      updateSelectInput(session, "outcome", selected = character(0))
    }
  })
  
  # Load existing scores when navigating to an abstract
  observeEvent(values$current, {
    reviewer <- input$reviewer
    if (file.exists("scores.xlsx")) {
      existing_data <- read_excel("scores.xlsx")
      row_index <- which(existing_data$ID == abstracts$ID[values$randomized_order[values$current]])
      if (length(row_index) > 0) {
        updateTextInput(session, "relevance", value = existing_data[[paste0("Relevance_", reviewer)]][row_index])
        updateTextInput(session, "method", value = existing_data[[paste0("Method_", reviewer)]][row_index])
        updateSelectInput(session, "outcome", selected = existing_data[[paste0("Outcome_", reviewer)]][row_index])
      }
    }
  })
  
  # Render title, abstract, keywords, symposium, and request with pretty headers
  output$abstract_info <- renderUI({
    reviewer <- input$reviewer
    if (!is.na(values$current) && nrow(abstracts) > 0) {
      current_index <- values$randomized_order[values$current]
      tagList(
        tags$h3(paste("ID", values$current, "out of", nrow(abstracts), " (Original ID:", abstracts$ID[current_index], ")")),
        tags$h3("Title:"),
        tags$strong(abstracts$Title[current_index]),
        tags$h3("Abstract:"),
        tags$p(abstracts$Abstract[current_index]),
        tags$h3("Keywords:"),
        tags$p(paste(abstracts$Keywords[current_index], collapse = ", ")),
        tags$h3("Symposium:"),
        tags$p(abstracts$Symposium[current_index]),
        tags$h3("Request:"),
        tags$p(abstracts$Request[current_index])
      )
    } else {
      tags$p("No abstracts available")
    }
  })
  
  # Render outcome options in the specified order
  output$outcome <- renderUI({
    request_options <- c("Poster", "Short Talk", "Talk")
    selectInput("outcome", "Outcome", choices = request_options)
  })
  
  # Handle score submission
  observeEvent(input$submit, {
    reviewer <- input$reviewer
    if (!is.na(values$current) && nrow(abstracts) > 0) {
      relevance <- as.numeric(input$relevance)
      method <- as.numeric(input$method)
      
      if (is.na(relevance) || is.na(method) || relevance < 0 || relevance > 10 || method < 0 || method > 10 || relevance != floor(relevance) || method != floor(method)) {
        output$feedback_text <- renderText({ "Please enter a whole number between 0 and 10." })
      } else {
        current_index <- values$randomized_order[values$current]
        new_row <- data.frame(
          ID = abstracts$ID[current_index],
          stringsAsFactors = FALSE
        )
        new_row[[paste0("Relevance_", reviewer)]] <- relevance
        new_row[[paste0("Method_", reviewer)]] <- method
        new_row[[paste0("Outcome_", reviewer)]] <- input$outcome
        
        if (file.exists("scores.xlsx")) {
          existing_data <- read_excel("scores.xlsx")
          # Ensure the columns exist in the existing data
          cols_to_add <- setdiff(names(new_row), names(existing_data))
          for (col in cols_to_add) {
            existing_data[[col]] <- NA
          }
          # Match the columns of existing_data and new_row
          existing_data <- existing_data[, names(new_row)]
          
          # Update the existing row if it exists, otherwise add a new row
          row_index <- which(existing_data$ID == abstracts$ID[current_index])
          if (length(row_index) > 0) {
            existing_data[row_index, names(new_row)] <- new_row
          } else {
            existing_data <- bind_rows(existing_data, new_row)
          }
          
          write_xlsx(existing_data, "scores.xlsx")
        } else {
          write_xlsx(new_row, "scores.xlsx")
        }
        
        # Show the feedback message as a pop-up
        shinyjs::show("feedback")
        delay(2000, shinyjs::hide("feedback"))
        
        # Move to the next abstract and clear input boxes
        values$current <- (values$current %% nrow(abstracts)) + 1
        updateTextInput(session, "relevance", value = "")
        updateTextInput(session, "method", value = "")
        updateSelectInput(session, "outcome", selected = character(0))
      }
    } else {
      output$feedback_text <- renderText({ "No abstracts available to submit." })
    }
  })
}

# Run the application
shinyApp(ui = ui, server = server)
