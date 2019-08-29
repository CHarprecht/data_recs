# explanation: this doc does first cleaning of the data

library(data.table)
library(tidyverse)
library(dplyr)
library(tidyr)
library(ggplot2)
library(caret)

# data from https://data.world/markpowell/global-wine-points
wine_01 = fread("../data/wines.csv", encoding = "UTF-8", stringsAsFactors = T)

# define columns

wine_01$vintage = format(as.Date(wine_01$vintage, format = "%Y-%m-%d"), "%Y")
wine_01$harvest_year = wine_01$vintage
wine_01$harvest_year= as.factor(wine_01$harvest_year)
wine_01$vintage = wine_01$title
colnames(wine_01)[1] = "Wine_Name"
wine_01$title = NULL

# remove row if no value (mainly in country)
wine_02 = wine_01[-c(which(wine_01$country == "")),]
wine_02 = wine_02[-c(which(wine_01$province == "")),]

#replace "" with NA

wine_02[,3:4][wine_02[,3:4] == ""] = NA

## create dummy vars
#dummies = dummyVars(~ ., data=wine_04[,c(2,4,6,7,8,9,10)], fullRank = TRUE) 
# = predict(dummies, newdata = wine_04[,c(2,4,6,7,8,9,10)])


# save data table for further processing
save(file = "wine_02.RData", list="wine_02")

