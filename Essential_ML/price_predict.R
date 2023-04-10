## load library
library(caret)
library(tidyverse)
library(readxl)
library(ggplot2)

# House Price Prediction
# 1. load data
df <- read_excel("HousePriceIndia.xlsx")
glimpse(df)

# Normal Distribution
mean(df$Price)
sd(df$Price)
y <- dnorm(df$Price, mean = 538932.2, sd = 367532.4)
plot(df$Price,y)

# histogram
hist(df$Price, main = "Normal DIstribution")

# 2. data prep

# take log to normalize data
df$Price <- log(df$Price)
hist(df$Price, main = "Normal DIstribution")

# rename
df <- df %>% rename_with(~ tolower(gsub(" ", "_", .x, fixed = TRUE)))
colnames(df)


# 3.split data

#subset_df <- df %>%
#  select(id, number_of_bedrooms, number_of_bathrooms, living_area, lot_area, number_of_floors, #built_year, price) %>%
#  as_tibble()

train_test_split <- function(data, trainRatio=0.7) {
  set.seed(42)
  n <- nrow(data)
  id <- sample(1:n, size=trainRatio*n)
  train_data <- data[id, ]
  test_data <- data[-id, ]
  
  list(train=train_data, test=test_data) 
}

splitData <- train_test_split(df, 0.7)
train_data <- splitData$train
test_data <- splitData$test



# 4. train
set.seed(42)

ctrl <- trainControl(
  method = "cv", # k-fold golden standard
  number = 5, # k=5
  verboseIter = TRUE #print log processing
)

# Stepwise Regression Essentials
step_model <- train(price ~ ., 
                    data = train_data[ ,-1],
                    method = "leapSeq", 
                    tuneGrid = data.frame(nvmax = 1:5),
                    preProcess = c("center", "scale"),
                    trControl = ctrl)

summary(step_model$finalModel)
step_model$bestTune

# the best 5-variables model contains living_area, number_of_views, grade_of_the_house, built_year, lattitude

#Linear regression
lm_model <- train(price ~ living_area + number_of_views + grade_of_the_house + built_year + lattitude,
                  data = train_data,
                  method = "lm",
                  preProcess = c("center", "scale"), #standardization
                  trControl = ctrl) 

# KNN
# tuneLength random search
knn_model <- train(price ~ living_area + number_of_views + grade_of_the_house + built_year + lattitude,
                    data = train_data,
                    method = "knn",
                    metric = "Rsquared",
                    tuneLength = 3,    #random 3 k
                    preProcess = c("center", "scale"),
                    trControl = ctrl)

# Random Forest
rf_model <- train(price ~ living_area + number_of_views + grade_of_the_house + built_year + lattitude, 
                  data = train_data,
                  method = "rf", # random forest
                  trControl = ctrl) 

#rf > knn > lm
## compare models 

list_models <- list(lm = lm_model,
                    knn = knn_model,
                    randomForest = rf_model)

result <- resamples(list_models)

summary(result)

# 3. score
price_pred <- predict(rf_model, newdata = test_data)

# 4. evaluate

RSQUARE = function(y_actual,y_predict){
  cor(y_actual,y_predict)^2
}

RSQUARE(test_data$price, price_pred)

# 5. save model
saveRDS(rf_model, "rf_regression_v1.RDS")
