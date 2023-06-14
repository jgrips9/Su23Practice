log using "../../Output/presidents_manipulation.log", replace
*download president datasets

*set directory to where files were downloaded. 
clear all
cd "../../Data/presidents"

*Try to import 1 file first. get code for how to import to be used in loop later. 

*recognize all csv files within a folder. 
local csv: dir "." files "*.csv"
foreach file in `csv' {
	*loop through all csv files within folder.
	*import data.
	import delimited using "`file'", clear varnames(1)
	*subset dataset. Only want county election results
	keep if type == "County"
	*save dataset. Saves by default with .dta extension for Stata dataset. 
	save "complete/`file'.dta", replace
}
clear
*inspect format of datasets. Open them up. See how they look.
browse 

*now merge them together.
*start by loading just 1 dataset. Keep only merging variables
use "complete/president2008.csv.dta", clear
*fips is our merging varaible. That is all we need for now. 
keep fips

*recognize all dta files within a folder. Merge together with fips. 
save "complete/base", replace
local dta: dir "complete" files "*.dta"
foreach file in `dta' {
	*Space in the file name.
	merge 1:1 fips using "complete/`file'"
	*saves default with .dta extension
	drop _merge
	save "complete/merging", replace
}

gen demprop8 = democrat2008 / totalvote2008
gen repprop8 = republican2008 / totalvote2008

ttest demprop8 == repprop8

gen repprop20 = republican2020 / totalvote2020
ttest repprop20 == repprop8

sdtest democrat2008 == republican2008

*Reshape from wide to long. 
*help reshape
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