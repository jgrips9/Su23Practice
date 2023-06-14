#Analysis exercise
#Load sample dataset
data = mtcars

#Goal. Predict mpg from wt and hp. Assuming the larger the wt and hp the lower the mpg. 
library(tidyverse)

#Create statistics by am group. Comparing automatic and manual cars
summary_table <- data %>%
  group_by(am) %>%
  summarise(hpmean = mean(hp), hpsd = sd(hp),
            mpgmean = mean(mpg), mpgsd = sd(mpg))

#Print summary table
summary_table

#Look at distribution of variables
library(ggplot2)
#MPG by weight
ggplot(data) +
  geom_point(aes(x = mpg, y = wt, color = am)) 

#mpg by horsepower
ggplot(data) +
  geom_point(aes(x = mpg, y = hp, color = am)) 

hist(data$mpg)
hist(data$wt)
hist(data$hp)

#Correlation.
cordata <- data %>%
  select(mpg, hp, wt)

cor(cordata)

model = lm(mpg~wt + hp, data = data)
summary(model)
#Export to nice table
library(stargazer)
#https://www.princeton.edu/~otorres/NiceOutputR.pdf
stargazer(model, type = "text", out = "../../Output/regression_table_cars.txt")

#TTest of automatic and manual cars.
t.test(mpg ~ am, data = data)
