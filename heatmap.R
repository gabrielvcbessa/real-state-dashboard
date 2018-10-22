library(leaflet)

heatmap <- function (domain, ids, domain_bins = NA, legend_title = NULL) {
  bins <- case_when(is.na(domain_bins) ~ quantile(as.double(domain), 
                                                  c(seq(0, by = .2, length.out = 4), 
                                                    seq(.7, .95, .125), 
                                                    seq(.97, .99, .02),
                                                    1), 
                                                  type = 1,
                                                  na.rm = TRUE),
                    TRUE ~ as.double(domain_bins))
  
  pal <- colorBin(
    c('#FFFFC2', '#FFEDA0', '#FED976', '#FEB24C', 
      '#FD8D3C', '#FC4E2A', '#E31A1C', '#BD0026', '#800026'), 
    domain = domain, 
    na.color = '#BDBDBD',
    bins = unique(bins))
  
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
                title = legend_title,
                position = 'bottomright') %>% 
      addProviderTiles(providers$CartoDB.Positron) 
  )
}
