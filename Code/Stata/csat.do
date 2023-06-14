cd "../../Data/csat"
use "States_SAT2006", clear
*https://www.princeton.edu/~otorres/Regression101.pdf

*regress csat expense percent income high college

*performing regression. Assumptions below.
*random sample. 
* representative of population.
* no outliers
* variables normal distribution.

describe csat expense percent income high college region 
summarize csat expense percent income high college region

*run regression quickly. view results. Commented out as command below gives error.
*regress csat expense percent income high college

*what is wrong. How to fix. 

*Correct some errors.
*This does not work.
gen perc = real(percent)
browse
drop perc

*Replace the % with empty space. Then convert. 
gen perc = real(subinstr(percent, "%", "", .))

*check distribution

hist csat
hist expense
hist perc3

*drop outliers. mention auto saved results.
su expense
drop if expense > `r(mean)' + 3*`r(sd)' | expense < `r(mean)' - 3*`r(sd)'


*check correlation
corr csat expense perc income high college

scatter csat high
scatter csat college

scatter csat expense
scatter csat perc

*transform the variable. Experiment.
gen perc2 = perc^2
scatter csat perc2
gen perc3 = log(perc)
scatter csat perc3

*Which transformation of percent gives the best resulkts. Why?
regress csat expense perc income high college
regress csat expense perc2 income high college
regress csat expense perc3 income high college

regress csat expense perc3 income high college i.region

*apply value labels for region. Use menu. 
*1 - west, 2 - NEast, 3 - South, 4 - Midwest

*export regerssion output nicely with the use of a package


ssc install estout, replace

regress csat expense perc2 income high college
eststo model1
regress csat expense perc income high college i.region 
eststo model2

esttab using "../../Output/Regression_csat_Stata.csv", replace

cd "../../Code/Stata"