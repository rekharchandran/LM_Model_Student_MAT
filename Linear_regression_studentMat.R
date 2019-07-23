

#Loading libraries
library(readr)
library(ggplot2)
library(ggthemes)
library(dplyr)
library(corrplot)
library(corrgram)
library(caTools)
df <- read.csv('student-mat.csv',sep=';')
View(df)
getwd()
summary(df)
# check for NA values
any(is.na(df))
#Categorical features
str(df)

###EDA
#Correlation and CorrPlots
# Grab only numeric columns
num.cols <- sapply(df, is.numeric)
corrplot(cor.data,method='color')

# Filter to numeric columns for correlation
cor.data <- cor(df[,num.cols])

cor.data

corrgram(df,order=TRUE, lower.panel=panel.shade,
         upper.panel=panel.pie, text.panel=panel.txt)
ggplot(df,aes(x=G3)) + geom_histogram(bins=20,alpha=0.5,fill='blue') + theme_minimal()

### Building a Model

## Traion & Test the Data
# Set a random see so your "random" results are the same as this notebook
set.seed(101) 

# Split up the sample, basically randomly assigns a booleans to a new column "sample"
sample <- sample.split(df$age, SplitRatio = 0.70) # SplitRatio = percent of sample==TRUE

# Training Data
train = subset(df, sample == TRUE)

# Testing Data
test = subset(df, sample == FALSE)

#Training our Model
model <- lm(G3 ~ .,train)
summary(model)

#Visualize our Model
# Grab residuals
res <- residuals(model)

# Convert to DataFrame for gglpot
res <- as.data.frame(res)

head(res)

 #Using ggplot
# Histogram of residuals
ggplot(res,aes(res)) +  geom_histogram(fill='blue',alpha=0.5)

plot(model)

#predictions

G3.predictions <- predict(model,test)
results <- cbind(G3.predictions,test$G3) 
colnames(results) <- c('pred','real')
results <- as.data.frame(results)

#negative predictions!
to_zero <- function(x){
  if  (x < 0){
    return(0)
  }else{
    return(x)
  }
}

results$pred <- sapply(results$pred,to_zero)

# Evaluate prediction Value

mse <- mean((results$real-results$pred)^2)
print(mse)

# root mean squared error:
mse^0.5

#R-Squared Value for our model (just for the predictions)
SSE = sum((results$pred - results$real)^2)
SST = sum( (mean(df$G3) - results$real)^2)

R2 = 1 - SSE/SST
R2
