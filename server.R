#' This is the companion server.R file that goes with the ui.R for Interactive Linear Regression Shiny tool
#' by Mark Bulkeley built on 2016-06-06
#' for the Coursera Data Products class in the Data Science Specialization Course

library(shiny)
library(UsingR)
library(data.table)

mtc <- data.table(mtcars)
regressorChoices <- setdiff(names(mtc), "mpg")

shinyServer(  
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