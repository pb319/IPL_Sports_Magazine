# ---------------------- It Deals with Preprossesing the model like, checking Linearity, Normality, etc assumptions 
# ---------------------- along with addressing the problems (Step-wise Regression, Principal Component Analysis, etc.)
#----------------------- in the dataset under use to fit an effective model

# Installing Package ggplot2
install.packages("ggplot2")
library(ggplot2)

# Before Model Fitting We need to test our Assumptions
install.packages("lmtest")
library(lmtest)

# First of All we need to fit some model
## Importing Data
install.packages("readxl")
library(readxl)
Bowling = read_excel("Bowling_Req.xlsx")
Bowling = scale(Bowling)

#Model Using All Columns
model2 = lm(Wkts~.,data = Bowling)
summary(model2)

# Perform the Durbin-Watson test(Cheking Autocorrelation)
# Expected Value =2 (1.5,2.5)
help.search("dwtest")
library(lmtest)
dw_result <- dwtest(model2)
dw_result


# Example: Checking homoscedasticity
# Create a plot of residuals vs. fitted values
plot(model2) # Reasonbly Normal 

#define model with all predictors
all <- lm(Wkts~.,data = Bowling)

# Initialize a model with all predictors
backward_model <- lm(Wkts~.,data = Bowling)

# Backward stepwise regression
backward_model <- step(backward_model, direction = "backward")

# Akaike information criterion (AIC) is an estimator of prediction error and thereby relative quality of
#statistical models for a given set of data. Given a collection of models for the data, AIC estimates the
#uality of each model, relative to each of the other models.

#Thus, AIC provides a means for model selection.

# Initialize a model with all predictors
both_model <- lm(Wkts~.,data = Bowling)
# Both-direction stepwise regression
both_model <- step(both_model, direction = "both")


plot(lm(Wkts~.,data = Bowling))


# Separation of Dependent and Independent variable
ind_var = Bowling[,c('Mat', 'Ov','Avg','Econ')]
dep_var = Bowling[,c("Wkts")] 

## Principal Component Analysis
install.packages("factoextra")
library(factoextra)
Dim = prcomp(ind_var)
Dim
summary(Dim)
## Scree Plot showing explained variation
fviz_eig(Dim)

## Hence it is clearly visible that taking first three Principal Components will suffice
Bowling$PC1 = ((-0.02003457)*Bowling$Mat)+((-0.05790883)*Bowling$Ov)+((0.99781349)*Bowling$Avg)+((0.02476751)*Bowling$Econ)      

Bowling$PC2 = ((-0.18822317)*Bowling$Mat)+((-0.97898242)*Bowling$Ov)+((0.06179758)*Bowling$Avg)+(( 0.04844082)*Bowling$Econ)      


#Two Component Model
new_model1 = lm(Wkts~PC1+PC2, data = Bowling)
summary(new_model1) # All Coefficients are Significant
plot(lm(Wkts~PC1+PC2, data = Bowling)) # Normality of Errors Improved


install.packages("openxlsx")
library(openxlsx)
file_path <- "Bowling(new).xlsx"
write.xlsx(Bowling, file_path)
