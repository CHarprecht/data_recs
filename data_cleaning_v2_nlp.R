# explain: this doc starts textmining the description variable of the different wines to further process it later.

library(data.table)
library(tidyverse)
library(dplyr)
library(ggplot2)
library(tm)
library(SnowballC)

# load current data table from data_cleaning_v1
load("../wine_04.RData")

# remove everything that is none-text
wine_04$description = gsub("[^A-Za-z]", " ", wine_04$description)
wine_04$description[1]

# first try without description, see how thats working
wine_05 = wine_04[,-c(3)]


save(file = "../wine_05.RData", list="wine_05")
