library(ggmap)
library(ggplot2)
library(dplyr)
library(caret)
library(e1071)
library(dbscan)
library(MASS)
library(ggExtra)
library(LiblineaR)
library(readr)

# chemin vers le projet
path <- "/media/youcef/3c1e8ee4-6478-457b-a5ff-0587a29a0078/Dropbox/crime_classification/"
setwd(path)

# charger les données
data_train <- read.csv("./data/train.csv")
data_test <- read.csv("./data/test.csv")
# charger la carte géographique de San Francisco
#map <- get_map("San Francisco", zoom = 12, color = "bw")


make_vars_date <- function(crime_df) {
    crime_df$Years <- strftime(strptime(crime_df$Dates,
                                       "%Y-%m-%d %H:%M:%S"),"%Y")
    crime_df$Month <- strftime(strptime(crime_df$Dates,
                                       "%Y-%m-%d %H:%M:%S"),"%m")
    crime_df$DayOfMonth <- strftime(strptime(crime_df$Dates,
                                            "%Y-%m-%d %H:%M:%S"),"%d")
    crime_df$Hour <- strftime(strptime(crime_df$Dates,
                                      "%Y-%m-%d %H:%M:%S"),"%H")
    
    crime_df$DayOfWeek <- factor(crime_df$DayOfWeek,
                                levels=c("Monday","Tuesday",
                                         "Wednesday","Thursday",
                                         "Friday","Saturday","Sunday"),
                                ordered = TRUE)
    
    #crime_df$weekday <- "Weekday"
    #crime_df$weekday[crime_df$DayOfWeek == "Saturday" | 
    #                     crime_df$DayOfWeek == "Sunday" | 
    #                     crime_df$DayOfWeek == "Friday" ] <- "Weekend"
    
    
    return(crime_df)
}

make_training_factors <- function(df) {
    df$Years <- paste("Yr", df$Years, sep = ".")
    df$Years <- factor(df$Years)
    y <- as.data.frame(model.matrix(~df$Years - 1))
    names(y) <- levels(df$Years)
    
    df$Hour=paste("Hr", df$Hour,sep = ".")
    df$Hour = factor(df$Hour)
    h <- as.data.frame(model.matrix(~df$Hour - 1))
    names(h) <- levels(df$Hour)
    
    dow <- as.data.frame(model.matrix(~df$DayOfWeek - 1))
    names(dow) <- levels(df$DayOfWeek)
    
    df$Month=paste("Mon",df$Month,sep = ".")
    df$Month = factor(df$Month)
    m <- as.data.frame(model.matrix(~df$Month - 1))
    names(m) <- levels(df$Month)
    
    district <- as.data.frame(model.matrix(~df$PdDistrict - 1))
    names(district) <- levels(df$PdDistrict)
    
    df$pY=paste(df$PdDistrict,df$Years,sep = ".")
    df$pY = factor(df$pY)
    pY <- as.data.frame(model.matrix(~df$pY - 1))
    names(pY) <- levels(df$pY)

    train <- data.frame(y, dow, h, district, m, pY)

    return(train)
}

# fonction pour calcul de la fonction de perte
MultiLogLoss <- function(act, pred) {
    eps = 1e-15;
    nr <- nrow(pred)
    pred = matrix(sapply( pred, function(x) max(eps,x)), nrow = nr)      
    pred = matrix(sapply( pred, function(x) min(1-eps,x)), nrow = nr)
    ll = sum(act*log(pred) + (1-act)*log(1-pred))
    ll = ll * -1/(nrow(act))
    
    return(ll);
}

# modele
set.seed(22)
data_train <- make_vars_date(data_train)
data_test <- make_vars_date(data_test)

train <- data_train
target <- data_train$Category
train <- make_training_factors(train)
model <- LiblineaR(train, target, type = 7, verbose = FALSE)

test <- data_test
Id <- test$Id
test <- make_training_factors(test)

submit <- data.frame(predict(model, test, proba = TRUE)$probabilities[, levels(target)])
write.csv(file = "submit.csv", x = submit)
