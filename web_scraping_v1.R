library(rvest)
library(xml2)
library(selectr)
library(tidyverse)
library(data.table)
library(stringr)
library(RCurl)
library(XML)

#clear environment
remove(list = ls())

#scrape main page for urls to sub pages
main_page = getURL("https://www.weinfreunde.de/rotwein/?p=1&n=36")
main_doc_l = htmlTreeParse(main_page, useInternal = TRUE)
#get number of main pages
pages = xpathApply(main_doc_l,"//a[@title = 'Letzte Seite']", xmlValue)
pages = sub("*(\\n)", "", pages)
pages = as.integer(pages[1])
k = 1
data = data.frame(Name=character(), Farbe=character(), Herkunftsland=character(), Herkunftsregion=character(),
                  Rebsorte=character(), Geschmack=character(),Weinstil=character(),Qualitätsstufe=character(),
                  Alkoholgehalt=numeric(),Trinktemperatur=numeric(), Restsüße=numeric(),
                  Säuregehalt=numeric(),Trinkreife=character(),Ausbau=character(),Hersteller=character(), 
                  Jahrgang=integer(),stringsAsFactors = FALSE)

# loop to scrape wine data 

for (i in 1:pages){
  main_page = getURL(paste("https://www.weinfreunde.de/rotwein/?p=",i,"&n=36", sep = ""))
  main_doc = htmlTreeParse(main_page, useInternal = TRUE)
  objects = xpathApply(main_doc,"//a[@class='product-link']/@href")
  objects = length(objects)
  
  for (j in 1:objects) {
  urls = xpathApply(main_doc,"//a[@class='product-link']/@href")
  
  xpath_sub_page = getURL(urls[j], .encoding = "UTF-8")
  sub_doc = htmlTreeParse(xpath_sub_page, useInternal = TRUE, encoding = "UTF-8")
  name = xpathApply(sub_doc, "/html/body/div[1]/section/div/div/div/div[1]/header/div[1]/h1", xmlValue)

  #get values
  colour = xpathApply(sub_doc, "//td[@class='product--properties-label' and 
                       text() = 'Farbe']/following-sibling::td[1]", xmlValue)
  origin_country = xpathApply(sub_doc, "(//td[@class='product--properties-label' and 
                       text() = 'Herkunftsland']/following-sibling::td[1])[1]", xmlValue)
  origin_region = xpathApply(sub_doc, "(//td[@class='product--properties-label' and 
                       text() = 'Herkunftsregion']/following-sibling::td[1])[1]", xmlValue)
  origin_country = xpathApply(sub_doc, "(//td[@class='product--properties-label' and 
                       text() = 'Herkunftsland']/following-sibling::td[1])[1]", xmlValue)
  grape = xpathApply(sub_doc, "(//td[@class='product--properties-label' and 
                       text() = 'Rebsorte']/following-sibling::td[1])[1]", xmlValue)
  style = xpathApply(sub_doc, "(//td[@class='product--properties-label' and 
                       text() = 'Weinstil']/following-sibling::td[1])[1]", xmlValue)
  quality = xpathApply(sub_doc, "(//td[@class='product--properties-label' and 
                       starts-with(text(), 'Qualit')]/following-sibling::td[1])[1]", xmlValue, encoding = "UTF-8")
  alcohol = xpathApply(sub_doc, "(//td[@class='product--properties-label' and 
                       text() = 'Alkoholgehalt']/following-sibling::td[1])[1]", xmlValue)
  temp = xpathApply(sub_doc, "(//td[@class='product--properties-label' and 
                       text() = 'Trinktemperatur']/following-sibling::td[1])[1]", xmlValue, encoding = "UTF-8")
  sweet = xpathApply(sub_doc, "(//td[@class='product--properties-label' and 
                       starts-with(text(), 'Rests')]/following-sibling::td[1])[1]", xmlValue, encoding = "UTF-8")
  sour = xpathApply(sub_doc, "(//td[@class='product--properties-label' and 
                       starts-with(text(),'S')]/following-sibling::td[1])[1]", xmlValue, encoding = "UTF-8")
  ripe = xpathApply(sub_doc, "(//td[@class='product--properties-label' and 
                       text() = 'Trinkreife']/following-sibling::td[1])[1]", xmlValue)
  expansion = xpathApply(sub_doc, "(//td[@class='product--properties-label' and 
                       text() = 'Ausbau']/following-sibling::td[1])[1]", xmlValue)
  producer = xpathApply(sub_doc, "(//td[@class='product--properties-label' and 
                       text() = '\nHersteller\n']/following-sibling::td[1])[1]", xmlValue)
  year = xpathApply(sub_doc, "(//td[@class='product--properties-label' and 
                       text() = 'Jahrgang']/following-sibling::td[1])[1]", xmlValue)
  taste = xpathApply(sub_doc, "(//td[@class='product--properties-label' and 
                       text() = 'Geschmack']/following-sibling::td[1])[1]", xmlValue)
  
  # clean data
  alcohol = sub("% Vol.", "", alcohol)
  alcohol = as.numeric(sub(",", ".", alcohol))
  temp = sub("°C", "", temp)
  temp = as.numeric(sub(",", ".", temp))
  sweet = sub(" g/l", "", sweet)
  sweet = as.numeric(sub(",", ".", sweet))
  sour = sub(" g/l", "", sour)
  sour = as.numeric(sub(",", ".", sour))
  name = as.character(sub("*\n", "", name))
  colour = as.character(colour)
  origin_country = as.character(origin_country)
  origin_region = as.character(origin_region)
  grape = as.character(grape)
  taste = as.character(taste)
  style = as.character(style)
  quality = as.character(quality)
  ripe = as.character(ripe)
  expansion = as.character(expansion)
  producer = as.character(sub("*\n", "", producer))
  year = as.integer(year)
  
  data_new = list(name, colour, origin_country, origin_region, grape, taste, style, quality, alcohol, 
                  temp, sweet, sour, ripe, expansion, producer, year)
  
  #replace character(0) with NA
  data_new = lapply(data_new, function(x) if(
    identical(x, character(0))) NA_character_ 
    else x
    )
  data_new = lapply(data_new, function(x) if(
    identical(x, numeric(0))) NA_character_ 
    else x
  )
  data_new = lapply(data_new, function(x) if(
    identical(x, integer(0))) NA_character_ 
    else x
  )
  
  # if too many missing values per instance, leave it out
  if(sum(is.na(data_new)) > 9){
  break
  }
  
  data[k,] = data_new
  k = k+1
  }
}

save(file = "weinfreunde_data.RData", list="data")

