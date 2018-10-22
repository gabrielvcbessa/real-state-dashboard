library(shiny)
library(data.table)
library(geojsonio)
library(dplyr)
library(tidyr)

source('ui.R')
source('server.R')

bh.data <- fread('./data/viva_real.csv', encoding = 'UTF-8')

bh.data <- bh.data[!duplicated(bh.data$id), ] %>%
  mutate(rental_price_m2 = case_when(!is.na(rental_price) & usable_area != 0 ~ rental_price / usable_area,
                                      TRUE ~ as.double(NA)),
         sale_price_m2 = case_when(!is.na(sale_price) & usable_area != 0 ~ sale_price / usable_area,
                                    TRUE ~ as.double(NA)))

bh.by_neigh.by_type <- bh.data %>% 
  group_by(neighborhood, unit_types) %>% 
  summarise(properties = n(),
            m_usable_area = median(usable_area, na.rm = TRUE),
            m_rental_price = median(rental_price, na.rm = TRUE),
            m_sale_price = median(sale_price, na.rm = TRUE),
            m_rental_price_m2 = median(rental_price_m2, na.rm = TRUE),
            m_sale_price_m2 = median(sale_price_m2, na.rm = TRUE))

bh.by_neigh.by_type <- transform(bh.by_neigh.by_type,
                                 neighborhood = iconv(tolower(neighborhood), 
                                                      from = 'UTF-8',
                                                      to = 'ASCII//TRANSLIT'))

unit_types <- unique(bh.by_neigh.by_type$unit_types)

bh.geojson <- geojson_read('./data/bh_neigh.geojson', 
                           what = 'sp', 
                           encoding = 'UTF-8')

bh.geojson.data <- transform(bh.geojson@data,
                             neighborhood = iconv(tolower(NOME),
                                                  from = 'UTF-8',
                                                  to = 'ASCII//TRANSLIT'))

bh.geojson.data[, unit_types] <- NA

bh.geojson.data <- bh.geojson.data %>% 
  gather(unit_types, properties, 6:24) %>% 
  select(-'properties')

bh.data.heatmap <- left_join(bh.geojson.data,
                             bh.by_neigh.by_type,
                             by = c('neighborhood', 'unit_types'))
 
shinyApp(ui, server) 
  
  
  