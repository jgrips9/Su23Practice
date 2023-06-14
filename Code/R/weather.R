library(purrr)
setwd("../../Data/weather")
#sink("../../Output/weatherlog.txt")

library(haven)
library(tidyverse)
#Recognize all .dta files in folder
#https://www.statmethods.net/input/importingdata.html
files = list.files(path = ".", patter = "*.dta")
#https://stackoverflow.com/questions/75053103/read-all-csv-files-in-a-directory-and-add-the-name-of-each-file-in-a-new-column
#Import all files in folder. combine and append data,
datasets = list.files(path = ".", patter = "*.dta") %>% 
  map_df(~read_dta(.), .id = "file") %>%
  #Create new variables. Convert temperature to farenheit. 
  mutate(tmin_f = (9/5 * tMin)+32, tmax_f = (9/5 * tMax)+32) %>%
  #Compute average farenheit. 
  mutate(tavg_f = (tmin_f + tmax_f)/2)

#Collapse dataset. 1 date for each fips code
datasets_fc = datasets %>%
  group_by(dateNum, file) %>%
  summarise(tminc = mean(tmin_f), tmaxc = mean(tmax_f), tavgc = mean(tavg_f))


#Analysis
#Print summary table
datasets_fc %>%
  group_by(file) %>%
  summarise(min = mean(tminc), max = mean(tmaxc), avg = mean(tavgc))

#Perform anova test. Is average significantly different for 1 fips compared to the others
anov <- aov(tavgc ~ file, data = datasets_fc)
summary(anov)


#Individual files below. 

library(purrr)

library(haven)
files = list.files(path = ".", patter = "*.dta")
data1 = read_dta(files[1])
data1$file = files[1]
data1 = data1 %>%
  mutate(tmin_f = (9/5 * tMin)+32, tmax_f = (9/5 * tMax)+32) %>%
  mutate(tavg_f = (tmin_f + tmax_f)/2)

#Above process for the other 2 files.
data2 = read_dta(files[2])
data2$file = files[2]
data2 = data2 %>%
  mutate(tmin_f = (9/5 * tMin)+32, tmax_f = (9/5 * tMax)+32) %>%
  mutate(tavg_f = (tmin_f + tmax_f)/2)

data3 = read_dta(files[3])
data3$file = files[3]
data3 = data3 %>%
  mutate(tmin_f = (9/5 * tMin)+32, tmax_f = (9/5 * tMax)+32) %>%
  mutate(tavg_f = (tmin_f + tmax_f)/2)

#Append data
data_f = rbind(data1, data2, data3)

#Collapse dataset. 1 date for fips code
data_fc = data_f %>%
  group_by(dateNum, file) %>%
  summarise(tminc = mean(tmin_f), tmaxc = mean(tmax_f), tavgc = mean(tavg_f))


#Analysis
#Print summary table
data_fc %>%
  group_by(file) %>%
  summarise(min = mean(tminc), max = mean(tmaxc), avg = mean(tavgc))

#Perform anova test. Is average significantly different for 1 fips compared to the others
anov <- aov(tavgc ~ file, data = data_fc)
summary(anov)

setwd("../../Code/R")
