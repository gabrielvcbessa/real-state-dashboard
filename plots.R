library(shiny)
library(ggplot2)

generate_scatter <- function (x) {
  return(
    ggplot(bh.data, aes(usable_area, rental_price)) +
      geom_point()
  )
}
