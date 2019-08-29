library(shiny)
library(data.table)
library(cluster)

load("wine_02.RData")

shinyServer(function(input, output) {
  
  output$wine_table = renderTable({
    
    req(input$WineInput != "type and select here")
    
    selection_text = as.character(input$WineInput)
    selection = which(wine_02$Wine_Name == selection_text)
    
    #only use wines with same grape (variety) to reduce complexity and improve performance
    wine_variety = wine_02[wine_02$variety == wine_02$variety[selection]]
    
    #cut out variety variable as all are same
    selection_variety = which(wine_variety$Wine_Name == selection_text)
    wine_variety = wine_variety[,-8]
    q = nrow(wine_variety)
    gower_dist_sel = as.integer(vector(length = q))
    
    #create gower matrix for only selection wine and wines with same grape(s)
    for (i in 1:q){
      gower_dist_sel[i] = daisy(wine_variety[c(selection_variety,i),2:9], metric = "gower", stand = TRUE, 
                                weights = c(2,1,0.5,2,3,2,1,1))
    }
    
    # get name of wines for recommendation
    recs_select = as.data.frame(wine_variety$Wine_Name)
    recs_select$gower_value = as.data.frame(gower_dist_sel)
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
