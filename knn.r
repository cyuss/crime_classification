# charger les packages
library(data.table)
library(kknn)
library(clusterSim)
library(class)

# chemin
if (Sys.info()[['sysname']] == "Linux") {
    path <- "/media/youcef/3c1e8ee4-6478-457b-a5ff-0587a29a0078/Dropbox/crime_classification/"
} else {
    path <- "C:/Users/Youcef/Dropbox/crime_classification"
} 
setwd(path)

# charger les donnees
train <- read.csv("train.csv", header = TRUE)
#train <- data.table(read.csv("train.csv", header = TRUE))
#test <- data.table(read.csv("test.csv", header = TRUE))

# changer les noms
names(train) <- c('date', 'category_predict', 'description_ignore', 'day_of_week', 'pd_district', 'resolution', 'address', 'x', 'y')
#names(test) <- c('id', 'date', 'day_of_week', 'pd_district', 'address', 'x', 'y')

# ajouter l'heure
train$hour <- as.numeric(strftime(strptime(train$date, "%Y-%m-%d %H:%M:%S"), "%H"))
train$month <- as.numeric(strftime(strptime(train$date, "%Y-%m-%d %H:%M:%S"), "%m"))
#test$hour <- as.numeric(strftime(strptime(test$date, "%Y-%m-%d %H:%M:%S"), "%H"))
#test$month <- as.numeric(strftime(strptime(test$date, "%Y-%m-%d %H:%M:%S"), "%m"))

# normaliser les donnees
x_train_scaled <- data.Normalization(train$x, type = "n1")
y_train_scaled <- data.Normalization(train$y, type = "n1")
hour_train_scaled <- data.Normalization(train$hour, type = "n1")
month_train_scaled <- data.Normalization(train$month, type = "n1")

#x_test_scaled <- data.Normalization(test$x, type = "n4")
#y_test_scaled <- data.Normalization(test$y, type = "n4")
#hour_test_scaled <- data.Normalization(test$hour, type = "n4")
#month_test_scaled <- data.Normalization(test$month, type = "n4")

train_model <- data.frame(category_predict = train$category_predict, 
                          x_scaled = x_train_scaled, 
                          y_scaled = y_train_scaled, 
                          hour_scaled = hour_train_scaled,
                          month_scaled = month_train_scaled)

names(train_model) <- c("category_predict", "x_scaled", "y_scaled", "hour_scaled", "month_scaled")

#test_model <- data.table(x_scaled = x_test_scaled, 
                         #y_scaled = y_test_scaled, 
                         #hour_scaled = hour_test_scaled,
                         #month_scaled = month_test_scaled)

#test_model <- data.table(category_predict = train$category_predict[570732:878049], 
                          #x_scaled = x_train_scaled[570732:878049], 
                          #y_scaled = y_train_scaled[570732:878049], 
                          #hour_scaled = hour_train_scaled[570732:878049],
                          #month_scaled = month_train_scaled[570732:878049])
#test_model <- train_model[570732:878049, ]
#train_model <- train_model[1:570731, ]

#train_model_labels <- train_model$category_predict
#test_model_labels <- test_model$category_predict

#model_pred <- knn(train = train_model, 
#                  test = test_model, 
#                  cl = train_model_labels,
#                  k = 50)




# une autre partie
subset = train_model[c(1:30000, 30024, 33954, 37298, 41097, 41980, 44479, 48707, 48837, 49306, 53715, 93717, 102637, 102645, 102678, 102919, 103517, 103712, 107734, 148476, 148476, 192191, 205046, 252094, 279792, 316491, 317527, 332821, 337881), ]

set.seed(1)

model <- category_predict ~ x_scaled + y_scaled + hour_scaled + month_scaled

knn_train <- kknn(formula = model,
                  train = subset,
                  test = train_model,
                  scale = TRUE)

#knn_test <- kknn(formula = model,
#                 train = subset,
#                 test = test_model,
#                 scale = TRUE)

train_pred <- data.table(knn_train$fitted.values)
#test_pred <- data.table(knn_test$prob)

train_model$pred <- train_pred$V1

print('Training Accuracy')
print(table(train_model$category_predict == train_model$pred))
print(prop.table(table(train_model$category_predict == train_model$pred)))

cv = cv.kknn(model, 
             data = subset, 
             kcv = 2, 
             scale = T)

cv = data.table(cv[[1]])
print('Cross Validation Accuracy')
print(table(cv$y == cv$yhat))
print(prop.table(table(cv$y == cv$yhat)))





