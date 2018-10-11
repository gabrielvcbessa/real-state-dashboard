library(shiny)
library(leaflet)
library(dplyr)

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
                             
                             helpText('Control Panel'),
                             
                             selectInput('unit_types', 
                                         'Unit type',
                                         c('All' = 'all',
                                           'Apartments' = 'APARTMENT')),
                             
                             selectInput('price_type', 
                                         'Price',
                                         c('Rental' = 'rental',
                                           'Sale' = 'sale')),
                             
                             textOutput('neigh_info')))))