#Executive Summary

#This project sets out to demonstrate sound theoretical understanding and the practical application
#of data analytics and machine learning through the 'R' programming language.
#Data pertains to testing information of red wine 'vinho verde' produced in Portugal. 
#Wine from this region was sampled and tested using certification step analytical tests (Cortez et al., 2009). 
#The data set structure has the dimensions of 1599 (n) observations with 12 variables (m).
#The data was partitioned into training and test sets set @ .8 and .2 respectively. 
#The dependent variable 'quality' was identified and analysis was performed with relation to the others. (Training)
#Correlation was assessed between 'quality' and the remaining 11 independent variables.
#Three lesser correlated variables where removed from the analysis step for brevity.
#A Random Forest model was chosen for it's performance in regression and classification problems.
#From the training data a model was generated and refined in terms of optimal randomly selected variables
#and the number of trees for each forest.
#The training model was validated with test data. Producing an RMSE of .53 and an 
#accuracy score of 70% (correct predictions / total predictions).
#I would like to acknowledge and reference the contributors and authors from which this project was created. Specific
#academic reference is provided at the end of this report.

#Install packages and load libraries.

if(!require(tidyverse)) install.packages("tidyverse", repos = "http://cran.us.r-project.org")

if(!require(caret)) install.packages("caret", repos = "http://cran.us.r-project.org")

if(!require(naniar)) install.packages("naniar", repos = "http://cran.us.r-project.org")

if(!require(rpart)) install.packages("rpart", repos = "http://cran.us.r-project.org")

if(!require(rpart.plot)) install.packages("rpart.plot", repos = "http://cran.us.r-project.org")

if(!require(randomForest)) install.packages("randomForest", repos = "http://cran.us.r-project.org")

library(tidyverse)

library(caret)

library(naniar)

#Set seed for consistency in replication.

set.seed(1, sample.kind = "Rounding")

#Download Data

url <- "https://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality-red.csv"

temp <- tempfile()

download.file(url,temp)

#Read in data

VinoRed <- read.csv(temp, header = TRUE, sep = ";")

#Clear cache

rm(temp)

rm(url)

#Initial evaluation of Data

glimpse(VinoRed)

#All variables, excluding 'quality' are of the class "dbl", which is an abbreviation for 'double-precision
#floating point number'. Meaning the information holds a numeric value able to contain decimal values.
#The parameter 'quality' is an integer. This will be our class variable for the supervised model.
#As such, we may have to factorize this parameter for ease in computation and modelling.

#Missing Values

naniar::gg_miss_var(VinoRed)

#Nil missing values.. phew.

#Partition data into training and test sets. Due to the relatively low magnitude of observations, 
#i will set the test data to .2 of the total. (321 Observations) This will prioritize validation accuracy
#over training accuracy, in turn reducing the risk of high variance or an overfit on a small data set.

SegragationIndex <- createDataPartition(y = VinoRed$quality, times = 1, p = .2, list = FALSE)

train <- VinoRed[-SegragationIndex,]

test <- VinoRed[SegragationIndex,]

#Clear cache.

rm(SegragationIndex)

rm(VinoRed)

#Training Data Analysis

str(train)

#All variables within our data set are defined as either numeric or an integer. 
#As such; let's evaluate the correlation between our independent variables and the dependent variable 'quality'. 
#Correlations with lesser statistical relation, will be filtered out of our analysis to
#expedite this project and ensure the project is submitted prior to the advertised deadline.

#Correlation

correlation <- cor(train[-12], train$quality)

correlation <- correlation %>% data.frame()

colnames(correlation) <- "Quality"

correlation

#Adjust values to absolute and arrange values descending.

correlation %>% abs() %>% arrange(., desc(Quality))

#Filter out the 3 least correlated: 
#residual.sugar
#free.sulfur.dioxide
#pH

#Detailed Data Analysis

#Dependent variable - 'quality'

#This variable refers to the subjective quality of our wine samples.
#Values are represented as a median score provided from at least three separate human / 'sensory' testers.
#Testing was conducted using a blind tasting method. 
#Quality was to be graded by each tester in the range of 0(very bad) to 10(excellent).

#sample
train$quality[1:10]

#Histogram
train %>% ggplot() +
  geom_histogram(aes(quality), 
                 stat = "count",
                 fill = "#69b3a2",
                 alpha = .8) +
  ggtitle("Histogram - Quality")

#5 and 6 are the highest reported quality scores from our training data set.

#Frequency tabulated
train %>% group_by(quality) %>% 
  summarize(count = n()) %>% 
  mutate(proportion = round(count / nrow(train), digit = 2)) %>% 
  arrange(., desc(proportion))

#Independent Variable 1 - 'fixed.acidity'

#When it comes to taste, it is widely known that acid plays a key role. Food or beverages low in acidity are often
#characterized as dull or dampened, where as high acidity is often described as sour or tart. As such, acidity in wine
#is no different and is believed to be a strong predictor in quality assessments. 

#Fixed acids; loosely meaning they are produced in the fermentation process. 
#The most commonly occuring fixed acids are; tartaric, malic, citric and succinic.

#Plot relationship
train %>% ggplot() +
  geom_jitter(aes(x = fixed.acidity, y = quality),
              colour ="#69b3a2",
              alpha = .8,
              width = .2)

#Box plot for each quality score.
train %>% mutate(quality = as.factor(quality)) %>% 
  ggplot() +
  geom_boxplot(aes(x = fixed.acidity, y = quality),
               fill ="#69b3a2",
               alpha = .8)

#The box plots of fixed.acidity against quality shows minimal variability and no clear relationship.
#Fixed acids within the range of 7 and 11 are most common across each of the quality values. 

#Independent Variable 2 - 'volatile.acidity'
#Volatile acids are often related to aroma as opposed to taste. They are describes as gas like acids within wine.
#Since our smell is a key contributor to taste, i would think there will be a relationship here.

#Box plot for each quality score.
train %>% mutate(quality = as.factor(quality)) %>% 
  ggplot() +
  geom_boxplot(aes(x = volatile.acidity, y = quality),
               fill ="#69b3a2",
               alpha = .8)

#Lesser volatile.acidity values infers a higher quality score.. interesting.

#Independent Variable 3 - 'citric.acid'

#Citric acid is utilized in wine production as a preservative or supplement and is 
#often related to flavors which are tart or sour.

#Box plot for each quality score.
train %>% mutate(quality = as.factor(quality)) %>% 
  ggplot() +
  geom_boxplot(aes(x = citric.acid, y = quality),
               fill ="#69b3a2",
               alpha = .8)

#Higher citric.acid values infers an increase in quality score.

#Independent Variable 4 - 'chlorides'

#Chloride is used as a measure of salt in the wine. 

#Box plot for each quality score.
train %>% mutate(quality = as.factor(quality)) %>% 
  ggplot() +
  geom_boxplot(aes(x = chlorides, y = quality),
               fill ="#69b3a2",
               alpha = .8)

#Increased salt infers a lower quality scored wine.

#Independent Variable 5 - 'total.sulfur.dioxide'

#Is a preservative added to wines in the bottling process, to reduce the likelihood of spoiling.

#Box plot for each quality score.
train %>% mutate(quality = as.factor(quality)) %>% 
  ggplot() +
  geom_boxplot(aes(x = total.sulfur.dioxide, y = quality),
               fill ="#69b3a2",
               alpha = .8)

#Dot Plot
train %>%
  ggplot() +
  geom_point(aes(x = total.sulfur.dioxide, y = quality),
               colour ="#69b3a2",
               alpha = .8)

#The above plots highlight a potential non-linear relationship and a slightly symmetrical distribution. 
#Higher levels of the sulfur dioxide is attributed to consistency / average quality scores.
#Which may highlight it's effectiveness in controlling volatility and stabilizing quality around the mean.

#Independent Variable 6 - 'density'

#Relates the specific gravity of the wine, or weight / mass. Measured in grams per milliliter (g/mL).
#Density is used to describe the proportional composition of sugars, alcohol and other dissolved solids. 

#Box plot for each quality score.
train %>% mutate(quality = as.factor(quality)) %>% 
  ggplot() +
  geom_boxplot(aes(x = density, y = quality),
               fill ="#69b3a2",
               alpha = .8)

#Less dense samples infer higher quality scores.

#Independent variable 7 - 'sulphates'

#Sulphates are another preservative that protect the wine from over oxidization or bacterial spoilage.
#Derived from sulphur dioxide, levels are controlled here in Australia due to safety regulations.
#Negative physiological reactions to wine are often attributed to sulphate levels.
#Which may be a miss conception, as the more common reaction is due to a histamine response.
#Sulphate levels reduce over time, so if you're sensitive to this compound go for older wines.

train %>% mutate(quality = as.factor(quality)) %>% 
  ggplot() +
  geom_boxplot(aes(x = sulphates, y = quality),
               fill ="#69b3a2",
               alpha = .8)

#Higher sulphates infer higher quality scores.

#Independent variable 8 - 'alcohol'

#Alcohol is a natural by product of the fermentation process.

train %>% mutate(quality = as.factor(quality)) %>% 
  ggplot() +
  geom_boxplot(aes(x = alcohol, y = quality),
               fill ="#69b3a2",
               alpha = .8)

#Higher alcohol infers higher quality scores.

#Analysis Summary

#From our observations of the numeric data. It can be argued that statistical relationships exist between
#our outcome (dependent) variable and the selected parameters (independent variables) in training. 
#As such a Random Forest model will be generated due to their strengths in regression and classification tasks.

#Model Formulation

#In order to understand random forests, one must first understand the principle of 
#Classification And Regression Trees (CARTs). This is due to the fact that Random Forests
#form an aggregate value produced by numerous randomly generated CARTs.

#Classification And Regression Trees (CARTs):
#CARTs break apart a given predictor space at a specific value; into sub partitions.
#Thus, placing all data points into either one or the other partition.
#The model then measures the 'homogeneity' / similarity of classes within each partition.
#Adjusting the partition value until achieving the most accurate homogeneity.
#The above steps then start again with a new partition, only if the resulting homogeneity of class 
#becomes better.

#Example Trees.

library(rpart)

library(rpart.plot)

#Single variable Tree
exampleSingleClass <- rpart(quality ~ alcohol, data = train)

rpart.plot(exampleSingleClass, box.palette = "grey")

#Multi variable Tree

exampleMulticlass <- rpart(quality ~ ., data = train)

rpart.plot(exampleMulticlass, box.palette = "grey")

rm(exampleSingleClass, exampleMulticlass)

#The effectiveness of CARTs is also their disadvantage, as they often create models that are highly accurate, but
#"overfit" the training data and when shown new information produce greater than acceptable error.
#Such error relative to training performance is known as High Variance. 
#However, a solution to this variance can be found through randomness. Enter the Random Forests.

#Random Forests:

#Randomly select (with replacement) rows from our data. Ensuring the row total is equal to our original data.
#Randomly select a subset of predictor variables.
#Generate CARTs from the selected predictor variables.
#Aggregate results to choose the highest performing combinations | permutations.
#Random Forests also provide a means to review variable importance.
#Meaning which independent variables ellicit the greatest performance change in our model.

#Method:

#Model Generation

#Add a control feature, to utilize cross validation five fold for our training data.

control <- trainControl(method = "cv", number = 5)

fit <- train(quality ~ ., data = train, method = "rf", trControl = control)

fit$bestTune

plot(fit)

plot(fit$finalModel)

#The model stabilizes with the least error after approx. 150 trees. 
#Therefor we will reduce computational effort, setting our maximum number of trees to 150. I.e. ntree = 150.
#The optimal number of randomly sampled variables for our model is 6. I.e. Mtry = 6.

fit <- train(quality ~ ., data = train, method = "rf", trControl = control, ntree = 150)

#Demonstrate the Random Forest (caret) variable importance function.

varImp(fit)

plot(varImp(fit))

#As expected our results are similar to the correlation figure earlier in the project.

#Testing

y_hat <- predict(fit, test[,1:11])

y_hat[1:5]

#Resultant RMSE for regression fit.

resultRMSE <- RMSE(y_hat, test$quality)

resultRMSE

#Resultant classification accuracy. Rounded predictions to the nearest integer.

y_hat <- y_hat %>% round(., digits = 0) 

resultClassification <- mean(as.numeric(y_hat) == as.numeric(test$quality))

resultClassification

#Summary:

#Through data analysis and the generation of a Random Forest Machine Learning model the project
#has achieved a test RMSE of .53 and an overall accuracy of 70% (correct prediction / total predictions).
#Thus demonstrating that wine testing data in the form of our independent variables is a reasonable input
#to produce quality predictions subjective to our testers.
#To generalize our predictions i'd suggest the 'quality' variable should be increased in terms of tester sample size
#or the number of tested to which the median value is derived, this would reduce bias. 
#Given a large enough data set. Future projects could also generate recommender systems between wine and consumers.

#Acknowledgement:

#Thankyou edX and HarvardX for an incredible professional certificate. This is just the beginning of my 
#journey into Data Science. Your efforts are greatly appreciated.

#Referencing:

#Cortez, P., Cerdeira, A., Almeida, F., Matos, T., and Reis, J., 2009. 
#Modeling wine preferences by data mining from physicochemical properties. Decision Support Systems, 47 (4), 547-553. 