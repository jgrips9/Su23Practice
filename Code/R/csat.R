#Regression example

#Create log file. 
#sink("../../Output/regression_log.txt")
library(tidyverse)

#Import data
reg_data = read.csv("../../Data/csat/states_SAT2006.csv", header = TRUE)

#Get descriptive data of variables
str(reg_data)
summary(reg_data)

#Attempt linear regression. Predict csat from expense, percent, income, high, college
lm(csat ~ expense + percent + income + high + college, data = reg_data)
#Output looks strange. What is going on here?

#Fix percent variable. Needs to be numeric. remove % and convert to numeric
class(reg_data$percent)
#Replace % with empty space. The % is forcing variable to be string. Needs to numeric.
reg_data$percent <- as.numeric(gsub("%", "", reg_data$percent))
#Check the type of variable. 
class(reg_data$percent)

#Check regression results again. This looks better.
lm(csat ~ expense + percent + income + high + college, data = reg_data)

#Look at spread of independent and dependent variables. 
hist(reg_data$csat)
hist(reg_data$expense)
hist(reg_data$percent)

#Remove outliers and missing data
#Missing data
#https://bookdown.org/rwnahhas/IntroToR/exclude-observations-with-missing-data.html#
reg_data <- na.omit(reg_data)

#Outliers. Q3 + 1.5*IQR, Q1 - 1.5*IQR test for outliers. 
outliers = boxplot(reg_data$expense, plot=FALSE)$OUT
reg_data_o = reg_data[-which(reg_data$expense %in% outliers), ]

#Correlation of important variables
#http://www.sthda.com/english/wiki/correlation-matrix-a-quick-start-guide-to-analyze-format-and-visualize-a-correlation-matrix-using-r-software
#Create dataset of variables want to do correlation for.
cor_data <- reg_data %>%
  select(csat, expense, percent, income, high, college)
#Create correlation matrix. 
cor(cor_data)

#Perform some graphs to look at relationship and distribution. Basic scatterplots. 
plot(reg_data$csat, reg_data$high)
plot(reg_data$csat, reg_data$college)
plot(reg_data$csat, reg_data$expense)
plot(reg_data$csat, reg_data$percent)

#Apply transformation on percent variable. Relationship looks a bit curved from scatterplot.
plot(reg_data$csat, reg_data$percent)
#Perform transformation squared
reg_data$percent2 = reg_data$percent**2
#This looks more curved. Try to go the other way. log transformation
plot(reg_data$csat, reg_data$percent2)
reg_data$percent3 = log(reg_data$percent)
#This looks much better.
plot(reg_data$csat, reg_data$percent3)

#Perform regressions
#http://www.sthda.com/english/articles/40-regression-analysis/167-simple-linear-regression-in-r/
orig = lm(csat ~ expense + percent + income + high + college, data = reg_data)
#Summarize model results
summary(orig)
tran1 = lm(csat ~ expense + percent2 + income + high + college, data = reg_data)
summary(tran1)
tran2 = lm(csat ~ expense + percent3 + income + high + college, data = reg_data)
summary(tran2)

#Analyze results. Which one had the best results?

#Export results to a nice formatting table. Through use of package
library(stargazer)
#https://www.princeton.edu/~otorres/NiceOutputR.pdf
stargazer(tran2, type = "text", out = "../../Output/regression_table_csat.txt")

#sink()