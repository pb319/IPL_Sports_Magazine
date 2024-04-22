
# Installing Package ggplot2
install.packages("ggplot2")
library(ggplot2)

# Before Model Fitting We need to test our Assumptions
install.packages("lmtest")
library(lmtest)

# First of All we need to fit some model
## Importing Data
library(readxl)
Bating_100 = read_excel("Bating_100(Req).xlsx")

#Model Using All Columns
model2 = lm(Runs~.,data = Bating_100)
summary(model2)

# Perform the Durbin-Watson test(Cheking Autocorrelation)
# Expected Value =2 (1.5,2.5)
dw_result <- dwtest(model2)
dw_result

# AIF Score (lesser the value, effective the model)

# Example: Checking homoscedasticity
# Create a plot of residuals vs. fitted values
plot(model2)

#define model with all predictors
all <- lm(Runs~.,data = Bating_100)

# Initialize a model with all predictors
backward_model <- lm(Runs~.,data = Bating_100)

# Backward stepwise regression
backward_model <- step(backward_model, direction = "backward")

# Akaike information criterion (AIC) is an estimator of prediction error and thereby relative quality of
#statistical models for a given set of data. Given a collection of models for the data, AIC estimates the
#uality of each model, relative to each of the other models.

#Thus, AIC provides a means for model selection.

# Initialize a model with all predictors
both_model <- lm(Runs~.,data = Bating_100)
# Both-direction stepwise regression
both_model <- step(both_model, direction = "both")


plot(lm(Runs~.,data = Bating_100))


# Separation of Dependent and Independent variable
ind_var = Bating_100[,c('NO', 'Avg','BF','SR','100','50','4s','6s')]
dep_var = Bating_100[,c("Runs")] 

## Principal Component Analysis
Dim = prcomp(ind_var)
Dim
summary(Dim)
## Scree Plot showing explained variation
install.packages("factoextra")
library(factoextra)
fviz_eig(Dim)

## Hence it is clearly visible that taking first three Principal Components will suffice
Bating_100$PC1 = ((-0.004390014)*Bating_100$NO)+((-0.206135952)*Bating_100$Avg)+((-0.954977131)*Bating_100$BF)+((-0.143009283)*Bating_100$SR)+((-0.001822171)*Bating_100$`100`)+((-0.010512970)*Bating_100$`50`)+((-0.140155797)*Bating_100$`4s`)+((-0.072788951)*Bating_100$`6s`)      

Bating_100$PC2 = ((0.0053420356)*Bating_100$NO)+((0.1197771531)*Bating_100$Avg)+((-0.1772873319)*Bating_100$BF)+((0.9750834830)*Bating_100$SR)+((0.0002296697)*Bating_100$`100`)+((0.0030177066)*Bating_100$`50`)+((0.0063965098)*Bating_100$`4s`)+((0.0579329335)*Bating_100$`6s`)      

Bating_100$PC3 = ((-0.0457504257)*Bating_100$NO)+((-0.9682368592)*Bating_100$Avg)+((0.1763452449)*Bating_100$BF)+((0.1516984763)*Bating_100$SR)+((-0.0009854498)*Bating_100$`100`)+((-0.0042542952)*Bating_100$`50`)+((0.0777294403)*Bating_100$`4s`)+((-0.0159145808)*Bating_100$`6s`)      

Bating_100
new_model = lm(Runs~PC1+PC2+PC3, data = Bating_100)
summary(new_model)
plot(lm(Runs~PC1+PC2+PC3,data = Bating_100))
# So We can say that the PC3 is not a significant component, henceforth we shall consider only PC1, PC2 while model building in Python
