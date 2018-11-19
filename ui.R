library(shiny)
library(leaflet)
library(dplyr)

source('unit_types.R')
source('info_types.R')

ui <- navbarPage(
  'Dashboard', id = 'nav',
  tabPanel('Heatmap',
           tags$head(
             includeCSS('styles.css')),
           
           div(class = 'outer',
               leafletOutput('properties_map', 
                             width = '100%', 
                             height = '100%'),
               
               absolutePanel(id = 'controls', 
                             class = 'modal', 
                             fixed = TRUE,
                             draggable = TRUE,
                             left = 'auto',
                             right = 20, 
                             bottom = 'auto',
                             width = 330,
                             height = 'auto',
                             
                             selectInput('unit_types', 
                                         'Property Type:',
                                         unit_types),
                             
                             selectInput('color', 
                                         'Color',
                                         info_types,
                                         selected = 'm_rental_price'),
                             
                             h5(textOutput('zone_title')),
                             
                             textOutput('properties_count'),
                             
                             h6('Sale Price (median):'),
                             textOutput('sale_price'),
                             
                             h6('Rental Price (median):'),
                             textOutput('rental_price'),
                             
                             h6('Area (median):'),
                             textOutput('usable_area')))))
