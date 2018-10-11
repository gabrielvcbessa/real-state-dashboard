library(leaflet)

bh_heatmap <- function (domain, ids) {
  bins <- c(1, 100, 250, 500, 1000, 2500, 5000, 7500, 10000, 12500)
  pal <- colorBin(
    c('#FFFFC2', '#FFEDA0', '#FED976', '#FEB24C', 
      '#FD8D3C', '#FC4E2A', '#E31A1C', '#BD0026', '#800026'), 
    domain = domain, 
    na.color = '#BDBDBD',
    bins = bins)
  
  return(
    leaflet(bh.geojson) %>% 
      addTiles() %>% 
      addPolygons(fillColor = ~pal(domain),
                  color = 'white',
                  fillOpacity = 0.75,
                  weight = 1,
                  layerId = ids,
                  highlightOptions = highlightOptions(
                    weight = 2,
                    color = 'white',
                    fillOpacity = 1,
                    bringToFront = TRUE)) %>%
      addLegend(pal = pal, 
                values = domain, 
                opacity = 0.7, 
                title = 'Properties',
                position = 'bottomright') %>% 
      addProviderTiles(providers$CartoDB.Positron) 
  )
}