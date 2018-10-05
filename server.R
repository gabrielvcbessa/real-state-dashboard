library(shiny)
library(data.table)
library(leaflet)
library(geojsonio)
library(ggplot2)
library(dplyr)

get_color <- function (d) {
  case_when(d > 1000 ~ '#800026',
            d > 500  ~ '#BD0026',
            d > 200  ~ '#E31A1C',
            d > 100  ~ '#FC4E2A',
            d > 50   ~ '#FD8D3C',
            d > 20   ~ '#FEB24C',
            d > 10   ~ '#FED976',
            TRUE     ~ '#FFEDA0')
}

bh.data <- fread('viva_real_bh.csv', encoding = 'UTF-8')

bh.data <- bh.data[!duplicated(bh.data$id), ]
iconv(bh.neigh$neighborhood,from="UTF-8",to="ASCII//TRANSLIT")
bh.neigh <- bh.data %>% 
  group_by(neighborhood) %>% 
  summarise(properties = n())

bh.neigh <- transform(bh.neigh, 
                      neighborhood = iconv(tolower(neighborhood), 
                                           from = 'UTF-8',
                                           to = 'ASCII//TRANSLIT'))

bh.geojson <- geojson_read('./bh_neigh.geojson', 
                           what = 'sp', 
                           encoding = 'UTF-8')

bh.geojson@data <- transform(bh.geojson@data, 
                             NOME = iconv(tolower(NOME), 
                                          from = 'UTF-8',
                                          to = 'ASCII//TRANSLIT'))

ui <- navbarPage(
  'Dashboard', id = 'nav',
  tabPanel('Neighborhoods',
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
      addPolygons(fillColor = '#6692CC',
                  color = '#6692CC',
                  fillOpacity = .1,
                  weight = 1,
                  highlightOptions = highlightOptions(
                    weight = 2,
                    bringToFront = TRUE)) %>% 
      addProviderTiles(providers$CartoDB.Positron)
  })
}

shinyApp(ui, server)

