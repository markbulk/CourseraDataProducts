#' This is the companion ui.R file that goes with the server.R for Interactive Linear Regression
#' by Mark Bulkeley built on 2016-06-06
#' for the Coursera Data Products class in the Data Science Specialization Course
library(shiny)
library(UsingR)
library(data.table)

shinyUI(pageWithSidebar(  
  headerPanel("Interactive Linear Regression"),  
  sidebarPanel(
    helpText(paste("This application uses the mtcars dataset in R to demonstrate the impact of changing the regressors on",
                   "Root Mean Square Error.  Use the check boxes below to use a regressor in the linear regression.",
                   "You will see the results to the right both graphically and in terms of the Root Mean Square Error.")),
    checkboxGroupInput('regressors', 'Choose regressors to predict MPG', regressorChoices, selected = regressorChoices, inline = FALSE, width = NULL)  
  ), 
  mainPanel(    
    plotOutput("myPlot"),
    textOutput("text1"),
    textOutput("text2")
  )
))