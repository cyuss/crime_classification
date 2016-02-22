library(ggplot2)
library(dplyr)
library(reshape2)

# charger les données
train <- read.csv("train.csv")

add_variables <- function(crime_df) {
    crime_df$Years <- strftime(strptime(crime_df$Dates, "%Y-%m-%d %H:%M:%S"), "%Y")
    crime_df$Month <- strftime(strptime(crime_df$Dates, "%Y-%m-%d %H:%M:%S"), "%m")
    crime_df$DayOfMonth <- strftime(strptime(crime_df$Dates, "%Y-%m-%d %H:%M:%S"), "%d")
    crime_df$Hour <- strftime(strptime(crime_df$Dates, "%Y-%m-%d %H:%M:%S"), "%H")
    
    return(crime_df)
}

d <- add_variables(train)

data_plot <- d %>%
    group_by(Category) %>%
    summarise(count = n()) %>%
    transform(Category = reorder(Category, -count))

data_plot$Percentage <- round(data_plot$count / sum(data_plot$count) * 100, 2)

ggplot(data_plot) + 
    geom_bar(aes(x = Category, y = count, 
                color = Category, fill = Category),
                stat = "identity")+
    coord_flip() +
    theme(legend.position = "None")+
    ggtitle("Nombre de crimes par catégorie")+
    xlab("Nombre de crimes")+
    ylab("Catégorie du crime")

print("Top des crimes")
top_crimes <- data_plot[with(data = data_plot, order(-count)), ]
head(top_crimes, 10)
sum(head(top_crimes, 20)$count)/sum(data_plot$count) * 100

crimes_by_day <- table(d$Category,d$DayOfWeek)
crimes_by_day <- melt(crimes_by_day)
names(crimes_by_day) <- c("Category","DayOfWeek","Count")

g <- ggplot(crimes_by_day, aes(x = Category, y = Count,fill = Category)) + 
    geom_bar(stat = "Identity") + 
    coord_flip() +
    facet_grid(.~DayOfWeek) +
    theme(legend.position = "none")
