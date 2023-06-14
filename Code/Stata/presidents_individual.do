log using "../../Output/presidents_manipulation.log", replace
clear all
cd "../../Data/presidents"

import delimited using "president2008.csv", clear
save president2008, replace

import delimited using "president2012.csv", clear
save president2012, replace

import delimited using "president2016.csv", clear
save president2016, replace

import delimited using "president2020.csv", clear
save president2020, replace

use president2008, clear
merge 1:1 fips using president2012, nogen
merge 1:1 fips using president2016, nogen
merge 1:1 fips using president2020, nogen

save master, replace
keep if type == "County"

gen demprop8 = democrat2008 / totalvote2008
gen repprop8 = republican2008 / totalvote2008

ttest demprop8 == repprop8

gen repprop20 = republican2020 / totalvote2020
ttest repprop20 == repprop8

sdtest democrat2008 == republican2008



reshape long totalvote democrat republican others write_ins none_of_these_candidates, i(fips) j(year)

*now perform some statistics.
*create proportions for %dem, %rep. 
gen demp = democrat / totalvote
gen repp = republican / totalvote

log close
log using "../../Output/presidents_analysis.log", replace

*compare average percent for dems and reps. Total. T test
ttest demp == repp
*By a specific year
ttest demp == repp if year == 2008

*create summary dataset sum of total votes for democrats and republicans. 
preserve
collapse (sum) democrat republican
browse
restore

*ttest frequency of same group 2 specific years. 
*applying changes to dataset. Use preserve as my undo function. 
preserve
keep if year == 2008 | year == 2020
ttest repp, by(year)
ttest demp, by(year)

*F test compare standard deviation. 
sdtest demp == repp

*counter to preserve. Returns dataset to structure before 'preserve' is used. 
restore


*2 way graph change in percent dem and rep over time. Both on same graph.
twoway (line demp year, lcolor(yellow)) (line repp year, lcolor(lime))
*Looks ugly. Rearrange dataset and do again.
preserve
tabstat repp demp, by(year) s(mean med sd) 
collapse (mean) repp demp (sum) democrat republican, by (year)
twoway (line demp year, lcolor(yellow)) (line repp year, lcolor(lime))
restore

*ANOVA test are proportions for all years dems, reps equal? 
bysort year: summarize totalvote democrat republican
bysort year: summarize totalvote democrat republican, detail

log close

cd "../../Code/Stata"