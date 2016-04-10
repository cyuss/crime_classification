library(data.table)
library(xgboost)
library(caret)

train <- fread('./data/train.csv')
dim(train)
test <- fread('./data/test.csv')
dim(test)
data <- merge(train, test, by=c('Dates', 'DayOfWeek', 'Address', 'X', 'Y', 'PdDistrict'), all = TRUE)
dim(data)
n <- nrow(data)

# charger les donnees
date_and_time <- strptime(data$Dates, '%Y-%m-%d %H:%M:%S')
data$Year <- as.numeric(format(date_and_time, '%Y'))
data$Month <- as.numeric(format(date_and_time, '%m'))
data$Day <- as.numeric(format(date_and_time, '%d'))
data$Week <- as.numeric(format(date_and_time, '%W'))
data$Hour <- as.numeric(format(date_and_time, '%H'))

# enlever les colonnes non necessaires
columns <- c('Descript', 'Resolution')
for (column in columns) {
    data[[column]] <- NULL
}

# rotation des variables X et Y
idx <- with(data, which(Y == 90))
transform <- preProcess(data[-idx, c('X', 'Y'), with=FALSE], method = c('center', 'scale', 'pca'))
pc <- predict(transform, data[, c('X', 'Y'), with=FALSE]) 
data$X <- pc$PC1
data$Y <- pc$PC2

# separation des donnees
idx <- which(!is.na(data$Category))
classes <- sort(unique(data[idx]$Category))
m <- length(classes)
data$Class <- as.integer(factor(data$Category, levels=classes)) - 1
dim(data)

feature.names <- names(data)[which(!(names(data) %in% c('Id', 'Dates', 'Category', 'Class')))]
for (feature in feature.names){
    if (class(data[[feature]]) == 'character'){
        cat(feature, 'converted\n')
        levels <- unique(data[[feature]])
        data[[feature]] <- as.integer(factor(data[[feature]], levels=levels))
    }
}

param <- list(
    nthread             = 4,
    booster             = 'gbtree',
    objective           = 'multi:softprob',
    num_class           = m,
    eta                 = 1.0,
    #gamma               = 0,
    max_depth           = 6,
    #min_child_weigth    = 1,
    max_delta_step      = 1
)

h <- sample(1:length(idx), floor(9*length(idx)/10))
dval <- xgb.DMatrix(data=data.matrix(data[idx[-h], feature.names, with=FALSE]), label=data[idx[-h]]$Class)
dtrain <- xgb.DMatrix(data=data.matrix(data[idx[h], feature.names, with=FALSE]), label=data[idx[h]]$Class)
watchlist <- list(val=dval, train=dtrain)
bst <- xgb.train( params            = param,
                  data              = dtrain,
                  watchlist         = watchlist,
                  verbose           = 1,
                  eval_metric       = 'mlogloss',
                  nrounds           = 15
)

# predictions
dtest <- xgb.DMatrix(data=data.matrix(data[-idx,][order(Id)][,feature.names, with = FALSE]))
prediction <- predict(bst, dtest)
prediction <- sprintf('%f', prediction)
prediction <- cbind(data[-idx][order(Id)]$Id, t(matrix(prediction, nrow = m)))
dim(prediction)

colnames(prediction) <- c('Id', classes)
write.csv(prediction, 'submission.csv', row.names=FALSE, quote=FALSE)
#zip('submission.zip', 'submission.csv')