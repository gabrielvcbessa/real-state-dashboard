library(shiny)
library(leaflet)
library(geojsonio)
library(ggplot2)
library(dplyr)

df <- read.csv('./viva_real.csv')

bh.geojson <- geojson_read('bh.geojson', what = 'sp')

ui <- navbarPage(
  'Dashboard', id = 'nav',
  tabPanel('Map',
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
                                       inputId = 'place-search'),
                             
                             plotOutput('histogram', height = 200)))))

server <- function(input, output, session) {
  output$properties_map <- renderLeaflet({
    leaflet(data = bh.geojson) %>% 
      addTiles() %>% 
      addPolygons(fillColor = '#6692CC',
                  color = '#6692CC',
                  fillOpacity = .1,
                  weight = 2) %>% 
      addMarkers(data = df, 
                 clusterOptions = markerClusterOptions()) %>% 
      addProviderTiles(providers$CartoDB.Positron)
  })
  
  output$histogram <- renderPlot(
    ggplot(df, aes(rental_price)) +
      geom_histogram()
  )
}

shinyApp(ui, server)

