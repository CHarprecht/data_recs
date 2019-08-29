# explain: this doc starts first first attempts to cluster the wines according to 
#their features (first try without desciprtion)

library(data.table)
library(tidyverse)
library(dplyr)
library(ggplot2)
library(cluster)
library(klaR)
library(Rtsne)

# load previous data
load("wine_02.RData")
load("gower_dist.RData")

# Compute gower distance matrix
#gower_dist_all = daisy(wine_02[,2:9], metric = "gower", stand = TRUE)

#save data for shiny app
#save(file = "wine_02.RData", list="wine_02")
#save(file = "gower_dist.RData", list="gower_dist_all")


#create gower distance data tables for all wines

i = 1
q = nrow(wine_02)

while (q > i){
  gower_select = as.data.frame(as.matrix(gower_dist_all)[i,])
  
  # get name of wines for recommendation
  recs_select = as.data.frame(wine_02$Wine_Name)
  recs_select$gower_value = gower_select
  colnames(recs_select)[1] = "Name of Wine"
  colnames(recs_select)[2] = "Dissimilarity"
  
  # order by gower value
  recs_select_order = order(recs_select$Dissimilarity)
  
  # save top 6 recommendations per wine 
  assign(paste("recs", i, wine_02$Wine_Name[i], sep = "_"),recs_select[recs_select_order[2:7],1:2])
  
  i = i +1
}





## clustering - not what we are looking for
#gower_cluster = hclust(gower_dist_all, method = "ward.D2") 

## Dendrogram
#plot(gower_cluster)


#compute gower distance for all instances to the selected instance
'q = nrow(wine_02)
i = 1
selection = 1
gower_dist_sel = as.integer(vector(length = q))

while (q > i){
  gower_dist_sel[i] = daisy(wine_02[c(selection,i),2:9], metric = "gower", stand = TRUE)
  i = i+1
}'

## KMods
#Kmodes = kmodes(wine_06[,c(2,3,6,7,8,9,10)],modes = 10, iter.max = 10)

## apply clusters to matrix
#wine_05$clusters = Kmodes$cluster
#view(wine_05[clusters == 10])

selection = 1
q = nrow(wine_02)
i = 1
gower_dist_sel = as.integer(vector(length = q))

while (q > i){
  gower_dist_sel[i] = daisy(wine_02[c(selection,i),2:10], metric = "gower", stand = TRUE)
  i = i+1
}

# get name of wines for recommendation
recs_select = as.data.frame(wine_02$Wine_Name)
recs_select$gower_value = as.data.frame(gower_dist_sel)
colnames(recs_select)[1] = "Name of Wine"
colnames(recs_select)[2] = "Dissimilarity"

# order by gower value
recs_select_order = order(recs_select$Dissimilarity)

# show top 6 recommendations
recs_select[recs_select_order[2:7],1:2]

