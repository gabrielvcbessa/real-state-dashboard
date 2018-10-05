library(shiny)
library(data.table)
library(leaflet)
library(geojsonio)
library(ggplot2)
library(dplyr)

bh.data <- fread('viva_real_bh.csv', encoding = 'UTF-8')

bh.data <- bh.data[!duplicated(bh.data$id), ]

bh.neigh <- bh.data %>% 
  group_by(neighborhood) %>% 
  summarise(properties = n())

bh.neigh <- transform(bh.neigh, 
                      neighborhood = iconv(tolower(neighborhood), 
                                           from = 'UTF-8',
                                           to = 'ASCII//TRANSLIT'))

bh.geojson.outer <- geojson_read('./bh.geojson')

bh.geojson <- geojson_read('./bh_neigh.geojson', 
                           what = 'sp', 
                           encoding = 'UTF-8')

bh.geojson@data <- transform(bh.geojson@data, 
                             neighborhood = iconv(tolower(NOME),
                                                  from = 'UTF-8',
                                                  to = 'ASCII//TRANSLIT'))

bh.neigh <- left_join(bh.geojson@data, bh.neigh, by = 'neighborhood')

bins <- c(1, 100, 250, 500, 1000, 2500, 5000, 7500, 10000, 12500)
pal <- colorBin(
  c('#FFFFC2', '#FFEDA0', '#FED976', '#FEB24C', 
    '#FD8D3C', '#FC4E2A', '#E31A1C', '#BD0026', '#800026'), 
  domain = bh.neigh$properties, 
  na.color = '#BDBDBD',
  bins = bins)

ui <- navbarPage(
  'Dashboard', id = 'nav',
  tabPanel('Heatmaps',
           tags$head(
             includeScript('reset_zoom.js'),
             includeCSS('styles.css')),
           
           div(class = 'outer',
               leafletOutput('properties_map', 
                             width = '100%', 
                             height = '100%'),
               
               absolutePanel(id = 'controls', class = 'modal', fixed = TRUE,
                             draggable = TRUE, left = 'auto', right = 20, bottom = 'auto',
                             width = 330, height = 'auto',
                             
                             textInput(label = 'Search for a place',
                                       inputId = 'place-search')))))

server <- function(input, output, session) {
  output$properties_map <- renderLeaflet({
    leaflet(bh.geojson) %>% 
      addTiles() %>% 
      addPolygons(fillColor = ~pal(bh.neigh$properties),
                  color = 'white',
                  fillOpacity = 0.75,
                  weight = 1,
                  highlightOptions = highlightOptions(
                    weight = 2,
                    color = 'white',
                    fillOpacity = 1,
                    bringToFront = TRUE)) %>% 
      addLegend(pal = pal, 
                values = bh.neigh$properties, 
                opacity = 0.7, 
                title = NULL,
                position = 'bottomright') %>% 
      addProviderTiles(providers$CartoDB.Positron) 
  })
}

shinyApp(ui, server)

