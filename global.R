library(shiny)
library(data.table)
library(geojsonio)
library(dplyr)
library(tidyr)

source('ui.R')
source('server.R')

bh.data <- fread('./data/viva_real.csv', encoding = 'UTF-8')

bh.data <- bh.data[!duplicated(bh.data$id), ]

bh.neigh <- bh.data %>% 
  group_by(neighborhood, unit_types) %>% 
  summarise(properties = n()) %>% 
  spread(unit_types, properties)

bh.neigh$properties <- rowSums(bh.neigh[-1], na.rm = TRUE)

bh.neigh <- transform(bh.neigh, 
                      neighborhood = iconv(tolower(neighborhood), 
                                           from = 'UTF-8',
                                           to = 'ASCII//TRANSLIT'))

bh.geojson <- geojson_read('./data/bh_neigh.geojson', 
                           what = 'sp', 
                           encoding = 'UTF-8')

bh.geojson.data <- transform(bh.geojson@data,
                             neighborhood = iconv(tolower(NOME),
                                                  from = 'UTF-8',
                                                  to = 'ASCII//TRANSLIT'))

bh.neigh <- left_join(bh.geojson.data, bh.neigh, by = 'neighborhood')

shinyApp(ui, server) 