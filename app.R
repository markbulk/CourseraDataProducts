#' This shiny web app made by Mark Bulkeley on 2016-06-06
#' for the Coursera Data Products course in the Data Science specialization
#' 
#' This demonstrates the power of shiny to create interactive applications and quickly deploy on the web.

library(shiny)
library(UsingR)
library(data.table)

mtc <- data.table(mtcars)
regressorChoices <- setdiff(names(mtc), "mpg")

# Define UI for application that draws a histogram
ui <- shinyUI(pageWithSidebar(  
  headerPanel("Interactive Linear Regression"),  
  sidebarPanel(
    helpText(paste("This application uses the mtcars dataset in R to demonstrate the impact of changing the regressors on",
                    "Root Mean Square Error.  Use the check boxes below to use a regressor in the linear regression.",
                   "You will see the results to the right both graphically and in terms of the Root Mean Square Error.")),
    checkboxGroupInput('regressors', 'Choose regressors to predict MPG', regressorChoices, selected = regressorChoices, inline = FALSE, width = NULL)  
  ), 
  mainPanel(    
    plotOutput("myPlot"),
    #textOutput('myModel'),
    textOutput("text1"),
    textOutput("text2")
  )
))

# Define server logic required to draw a histogram
server <- shinyServer(  
  function(input, output) {    
    output$myModel <- renderText(modelFunction(mtc, input$regressors)[["sum"]])
    output$text1 <- renderText({
      if(length(input$regressors) < 1) {
        "You have chosen too few inputs.  The model doesn't make sense."
      } else {
        paste("The inputs used in this model are: ", paste(input$regressors, collapse = ", "))
      }
    })
    output$text2 <- renderText(paste("Additional Notes: The above graph shows the predicted value on the x-axis and the actual value on the y-axis.",
                                     "The dotted line is y = x.  The solid blue line is a fit of the predicted versus actual and the darker grey",
                                     "band around it is one standard error."))
    output$myPlot <- renderPlot({
      dt.plot <- modelFunction(mtc, input$regressors)[["predAct"]]
      ggplot(data = dt.plot,
             mapping = aes(x = predicted, y = actual)) +
        geom_abline(slope = 1, lty = "dashed", col = "blue") +
        geom_point(size = 6, col= "steelblue", alpha = 0.7) +
        scale_x_continuous(name = "Predicted MPG Values") +
        scale_y_continuous(name = "Actual MPG Values") +
        geom_smooth() +
        annotate("text", x = 20, y = 30, label = paste("Root Mean Square Error:",round(sqrt(sum((dt.plot$actual - dt.plot$predicted)^2)),4)))
    })
  }
)

modelFunction <- function(mtc = NULL, regressors = NULL) {
  newMtc <- mtc[, c("mpg", regressors), with = FALSE]
  if(ncol(newMtc) == 1) newMtc[, dummy := 1]
  myModel <- lm(mpg ~ ., data = newMtc)
  chrModelSummary <- summary(myModel)
  return(list(sum = paste(chrModelSummary, collapse = "\n"),
              predAct = data.table(actual = newMtc$mpg, predicted = myModel$fitted.values)))
}

# Run the application 
shinyApp(ui = ui, server = server)