library(ggmap)
library(ggplot2)
library(dplyr)

# chemin vers le projet
path <- "./crime_classification/"
setwd(path)

# charger les données
train <- read.csv("train.csv")
# charger la carte géographique de San Francisco
map <- get_map("San Francisco", zoom = 12, color = "bw")

# fonction pour filtrer les données selon la catégorie et les projeter sur la map
map_crime <- function(crime_df, crime) {
    filtered <- filter(crime_df, Category %in% crime)
    plot <- ggmap(map, extent = 'device') + 
        geom_point(data = filtered, aes(x = X, y = Y, color = Category), alpha = 0.6)
    return(plot)
}

map_crime(train, c('SUICIDE', 'ARSON'))
