#Create log file. Track of all output and commands.
#sink("../../Output/president_manipulation.txt")
#Download data files online. president2008.csv, president2012.csv, president2016.csv, president2020.csv
#Set directory to where data files are
setwd("../../Data/presidents")

#Recognize all files in a specific directory.
#Load required packages
library(data.table)
library(tidyverse)
library(readr)

#Data manipulation section

#Locate all files in directory and import. This option does not work. Need to mergeby fips number not append.
#https://sparkbyexamples.com/r-programming/r-read-multiple-csv-files/
datasets = list.files(path = ".", patter = "*.csv") %>%
  map_df(~fread(.))
View(datasets)
#Try again. Different method merge. This is what we want. Combine by fips. 
#https://statisticsglobe.com/merge-csv-files-in-r
library(purrr)
datasets = list.files(path = ".", patter = "*.csv") %>% 
  lapply(read_csv) %>%
  reduce(full_join, by="fips")
View(datasets)

datasets = datasets %>%
  filter(type.x == "County")

datasets$demprop8 <- datasets$democrat2008 / datasets$totalvote2008
datasets$repprop8 <- datasets$republican2008 / datasets$totalvote2008
datasets$repprop20 <- datasets$republican2020 / datasets$totalvote2020

#Ttest from above created variables. 
t.test(datasets$demprop8, datasets$repprop8)
t.test(datasets$repprop20, datasets$repprop8)

#Variance test
var.test(datasets$democrat2008, datasets$republican2008)


#Apply subset. Only keep rows where type is county. Clean dataset to keep important columns. 
#https://dplyr.tidyverse.org/reference/filter.html
data_w <- datasets %>%
  filter(type.x == "County") %>%
  select(fips, name.x, type.x, totalvote2008, democrat2008, republican2008, others2008, 
         totalvote2012, democrat2012, republican2012, others2012, 
         totalvote2016, democrat2016, republican2016, others2016,
         totalvote2020, democrat2020, republican2020, others2020)

#Create better names for columns. Change names of columns 2 and 3
#https://sparkbyexamples.com/r-programming/rename-column-in-r/
colnames(data_w)[2] = "name"
colnames(data_w)[3] = "type"

#Describe data
str(data_w)

#Reshape dataset to be long format. 
library(tidyr)
#https://weiyangtham.github.io/stata_reshape/

data_L = data_w %>% tidyr::gather("var", "value", c(totalvote2008:others2020))
data_L = data_L %>%
  tidyr::extract("var", c("colname", "year"), regex = "([a-z]+)(\\d+)") %>%
  tidyr::spread("colname", "value")


#Now perform analysis section. 

#Create new columns for percentage of total votes to dems and reps. 
data_L$demp = data_L$democrat/data_L$totalvote
data_L$repp = data_L$republican/data_L$totalvote

#sink()
#Create log file to keep track of code and results. 
#sink("../../Output/presidents_analysis.txt")
#Ttest comparing democratic proportion to republican all time
t.test(data_L$demp, data_L$repp)

#Same thing but for a specific year
#Select year = 2008
data2008 <- data_L %>%
  filter(year == "2008")

#Perform ttest. 
t.test(data2008$demp, data2008$repp)

#Create summary dataset. Average proportion of republican and democratic votes for all fips split by years
#https://dplyr.tidyverse.org/reference/summarise.html
data_sum <- data_L %>%
  group_by(year) %>%
  summarise(meanrep = mean(repp, na.rm = TRUE), meandem = mean(demp, na.rm = TRUE), 
            sumrep = sum(totalvote, na.rm = TRUE), sumdem = sum(totalvote, na.rm = TRUE))
View(data_sum)
#Next compare 2008 to 2012 within political party
data2008_12 <- data_L %>%
  filter(year == "2008" | year == "2012")

#Now perform ttest
t.test(demp ~ year, data = data2008_12)
t.test(repp ~ year, data = data2008_12)

#Perform FTest to compare standard deviation of dem and rep for 2008. 
#http://www.sthda.com/english/wiki/f-test-compare-two-variances-in-r
var.test(data2008$republican, data2008$democrat)

#Now create overlapping line graph change of percentage rep and dem votes by year.
#Setup dataset again.
data_sum <- data_L %>%
  group_by(year) %>%
  summarise(meanrep = mean(repp, na.rm = TRUE), meandem = mean(demp, na.rm = TRUE), 
            sumrep = sum(totalvote, na.rm = TRUE), sumdem = sum(totalvote, na.rm = TRUE))

library(ggplot2)
#https://www.r-bloggers.com/2021/10/line-plots-in-r-time-series-data-visualization/

#Create overlapping line graph. 
ggplot(data_sum, aes(x=as.numeric(year))) +
  geom_line(aes(y=meanrep), color = "blue") + 
  geom_line(aes(y=meandem), color = "red")

#Save image.
save.image("../../Output/presidents_Rimage.RData")

#Save log file. 
#sink()
setwd("../../Code/R")
