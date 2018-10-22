library(dplyr)

options('scipen' = 100)
set.seed(100)

two_decimals <- function (number) {
  format(round(number, 2), 
         big.mark = ',', 
         small.mark = '.')
}

price_to_text <- function (price, price_m2) {
  
  if (is.na(price)) {
    return('Data not available')
  }
  
  paste('R$ ',
        two_decimals(price),
        ' (',
        two_decimals(price_m2),
        '/m²)', sep = '')
}

set_info <- function (output, data, neigh_id = NA) {
  
  if (!is.na(neigh_id)) {
    
    # Info regarding neighborhood properties
    shape.index = match(neigh_id, data$ID_BAIRRO)
    properties <- data[shape.index, 'properties']
    
    zone_title <- paste(data[shape.index, 'NOME'], ':', sep = '')
    
    properties_count <- paste(format(properties, big.mark = ',', small.mark = '.'),
                              ' properties', sep = '')
    
    m_sale_price <- data[shape.index, 'm_sale_price']
    m_sale_price_m2 <- data[shape.index, 'm_sale_price_m2']
    
    m_rental_price <- data[shape.index, 'm_rental_price']
    m_rental_price_m2 <- data[shape.index, 'm_rental_price_m2']
    
  } else {
    
    # Info regarding city properties
    properties <- sum(data[, 'properties'], na.rm = TRUE)
    
    m_sale_price <- median(data[, 'm_sale_price'], na.rm = TRUE)
    m_sale_price_m2 <- median(data[, 'm_sale_price_m2'], na.rm = TRUE)
    
    m_rental_price <- median(data[, 'm_rental_price'], na.rm = TRUE)
    m_rental_price_m2 <- median(data[, 'm_rental_price_m2'], na.rm = TRUE)
    
    zone_title <- 'All neighborhoods:'
    
    properties_count <- paste(format(properties, big.mark = ',', small.mark = '.'),
                              ' properties', sep = '')
  }
  
  sale_price <- price_to_text(m_sale_price, m_sale_price_m2)
  rental_price <- price_to_text(m_rental_price, m_rental_price_m2)
  
  output$zone_title <- renderText({ zone_title })
  output$properties_count <- renderText({ properties_count })
  
  output$sale_price <- renderText({ sale_price })
  output$rental_price <- renderText({ rental_price })
}
