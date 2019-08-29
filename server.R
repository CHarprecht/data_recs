library(shiny)
library(data.table)
library(cluster)

load("weinfreunde_data_1.RData")

shinyServer(function(input, output) {
  
  output$wine_table = renderTable({
    
    req(input$WineInput != "type and select here")
    
    selection_pre = which(data$Name == as.character(input$WineInput))
    
    #only consider same wine colour
    data_colour = data[data$Farbe == data$Farbe[selection_pre],]
    data_colour = data_colour[,-2]
    selection = which(data_colour$Name == as.character(input$WineInput))
    
    #create gower matrix 
    gower_dist = daisy(data_colour[,2:16], metric = "gower", stand = TRUE)
    
    # get name of wines for recommendation
    recs_select = as.data.frame(data_colour$Name, data_colour$Preis, data_colour$Jahrgang)
    recs_select$gower_value = as.data.frame(as.matrix(gower_dist)[selection,])
    colnames(recs_select)[1] = "Name of Wine"
    colnames(recs_select)[2] = "Preis"
    colnames(recs_select)[3] = "Jahrgang"
    colnames(recs_select)[4] = "Dissimilarity"
    
    # order by gower value
    recs_select_order = order(recs_select$Dissimilarity)
    
    # show top 6 recommendations
    recs_select[recs_select_order[2:7],1:4]
  })
  
  output$wine_selection = renderText({
    
    req(input$WineInput != "type and select here")
    
    paste("For your selection of", input$WineInput, "the six most similar wines are:")
    
  })
})
