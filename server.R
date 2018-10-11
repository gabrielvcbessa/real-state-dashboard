library(shiny)
library(leaflet)
library(dplyr)
library(sp)

source('heatmap.R')

server <- function(input, output, session) {
  output$properties_map <- renderLeaflet({
    bh_heatmap(bh.neigh$properties, bh.neigh$ID_BAIRRO)
  })
  
  observeEvent(input$properties_map_shape_click, {
    click = input$properties_map_shape_click
    proxy = leafletProxy('properties_map', data = bh.geojson)
    
    shape.index = match(click$id, bh.neigh$ID_BAIRRO)
    poly = bh.geojson@polygons[[shape.index]]@Polygons[[1]]
    centroid = slot(poly, 'labpt')
    
    proxy %>% setView(lng = centroid[1], lat = centroid[2], zoom = 15) 
  })
  
  observeEvent(input$properties_map_shape_mouseover, {
    mouseover = input$properties_map_shape_mouseover
    proxy = leafletProxy('properties_map', data = bh.geojson)
    
    shape.index = match(mouseover$id, bh.neigh$ID_BAIRRO)
    
    new_info <- paste(bh.neigh[shape.index, 'NOME'],
                      ': ',
                      bh.neigh[shape.index, 'properties'],
                      ' properties', sep = '')
    
    output$neigh_info <- renderText({ new_info })
  })
  
  observeEvent(input$properties_map_shape_mouseout, {
    mouseout = input$properties_map_shape_mouseout
    proxy = leafletProxy('properties_map', data = bh.geojson)
    
    new_info <- paste(sum(bh.neigh[, 'properties'], na.rm = TRUE),
                      ' properties', sep = '')
    
    output$neigh_info <- renderText({ new_info })
  })
}



