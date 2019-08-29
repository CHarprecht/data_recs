library(shiny)
library(data.table)
library(cluster)

load("wine_02.RData")
load("gower_dist.RData")

shinyServer(function(input, output) {
  
  output$wine_table = renderTable({
    
    req(input$WineInput != "type and select here")
    
    selection_text = as.character(input$WineInput)
    selection = which(wine_02$Wine_Name == selection_text)
    gower_select = as.data.frame(as.matrix(gower_dist_all)[selection,])
    
    # get name of wines for recommendation
    recs_select = as.data.frame(wine_02$Wine_Name)
    recs_select$gower_value = gower_select
    colnames(recs_select)[1] = "Name of Wine"
    colnames(recs_select)[2] = "Dissimilarity"
    
    # order by gower value
    recs_select_order = order(recs_select$Dissimilarity)
    
    # show top 6 recommendations
    recs_select[recs_select_order[2:7],1:2]
  })
  
  output$wine_selection = renderText({
    
    req(input$WineInput != "type and select here")
    
    paste("For your selection of", input$WineInput, "the six most similar wines are:")
    
  })
})
