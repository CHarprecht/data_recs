library(shiny)

load("weinfreunde_data_1.RData")

shinyUI(fluidPage(
  navbarPage("The Data Recs Project"),
  tabsetPanel(
    tabPanel("Wine", 
               sidebarLayout(
                 sidebarPanel(
                  selectInput(
                   "WineInput", 
                   "Which Wine do you like?", 
                   c("type and select here",as.character(data$Name)), multiple=FALSE, selectize=TRUE)
                 ),
                 mainPanel(textOutput("wine_selection"),
                   tableOutput("wine_table")
                 )
               )
           ),
   tabPanel("Courses",
    sidebarLayout(
      sidebarPanel("our inputs will go here"),
      mainPanel("our results will go here")
    )
  ),
  tabPanel("Other",
           sidebarLayout(
             sidebarPanel("our inputs will go here"),
             mainPanel("our results will go here")
           )
  )
  )
  
))
