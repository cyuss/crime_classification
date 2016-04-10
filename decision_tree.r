library(rpart)
library(rattle)
library(RColorBrewer)
library(rpart.plot)
library(randomForest)

# chemin
if (Sys.info()[['sysname']] == "Linux") {
    path <- "/media/youcef/3c1e8ee4-6478-457b-a5ff-0587a29a0078/Dropbox/crime_classification/"
} else {
    path <- "C:/Users/Youcef/Dropbox/crime_classification"
} 
setwd(path)

train <- read.csv("./data/train.csv", header = TRUE)
test <- read.csv("./data/test.csv", header = TRUE)

names(train) <- c("dates", "category_predict", "description", "dayofweek", "district", "resolution", "addresse", "x", "y")
names(test) <- c("Id", "date", "dayofweek", "district", "address", "x", "y")

train$hour <- as.numeric(strftime(strptime(train$date, "%Y-%m-%d %H:%M:%S"), "%H"))
train$month <- as.numeric(strftime(strptime(train$date, "%Y-%m-%d %H:%M:%S"), "%m"))
train$year <- as.numeric(strftime(strptime(train$date, "%Y-%m-%d %H:%M:%S"), "%Y"))

train_model <- data.frame(category_predict = train$category_predict, 
                          x = train$x, 
                          y = train$y, 
                          hour = train$hour,
                          month = train$month,
                          year = train$year,
                          dayofweek = train$dayofweek,
                          district = train$district)

test$hour <- as.numeric(strftime(strptime(test$date, "%Y-%m-%d %H:%M:%S"), "%H"))
test$month <- as.numeric(strftime(strptime(test$date, "%Y-%m-%d %H:%M:%S"), "%m"))
test$year <- as.numeric(strftime(strptime(test$date, "%Y-%m-%d %H:%M:%S"), "%Y"))

test_model <- data.frame(x = test$x, 
                         y = test$y, 
                         hour = test$hour,
                         month = test$month,
                         year = test$year,
                         dayofweek = test$dayofweek,
                         district = test$district)

tree <- rpart(category_predict ~ x + y + hour + month + year + dayofweek + district,
              data = train_model,
              method = "class",
              control = rpart.control(minsplit = 200, cp = 0)
)

predicted <- predict(object = tree, newdata = test_model)
final <- data.frame(Id = test$Id , predicted)
colnames(final)  <- c("Id",levels(train$category_predict))