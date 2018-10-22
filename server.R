library(shiny)
library(leaflet)
library(ggplot2)
library(dplyr)
library(sp)

source('heatmap.R')
source('set_info.R')
source('info_types.R')
source('plots.R')

server <- function(input, output, session) {
  
  # Properties to be analyzed
  properties <- reactive({
    bh.data.heatmap %>% 
      filter(unit_types == input$unit_types)
  })

  # Selectors observer
  observeEvent({
    input$unit_types
    input$color
  }, {
    output$properties_map <- renderLeaflet({
      
      # Generate info about all properties
      set_info(output, properties())
      
      # Update our heatmap
      domain <- properties()[[input$color]]
      title <- names(info_types)[info_types == input$color][1]
      heatmap(domain, 
              properties()$ID_BAIRRO, 
              legend_title = title)
    })
  })
  
  # Click observer
  observeEvent(input$properties_map_shape_click, {
    click = input$properties_map_shape_click
    proxy = leafletProxy('properties_map', data = bh.geojson)
    
    shape.index = match(click$id, properties()$ID_BAIRRO)
    poly = bh.geojson@polygons[[shape.index]]@Polygons[[1]]
    centroid = slot(poly, 'labpt')
    
    # Zooming on the clicked neighborhood
    proxy %>% setView(lng = centroid[1], lat = centroid[2], zoom = 15) 
  })
  
  # Mouseover observer
  observeEvent(input$properties_map_shape_mouseover, {
    mouseover = input$properties_map_shape_mouseover
    
    # Generate the neighborhood info
    set_info(output, properties(), mouseover$id)
  })
  
  # Mouseout observer
  observeEvent(input$properties_map_shape_mouseout, {

    # Generate info about all properties
    set_info(output, properties())
  })
}



