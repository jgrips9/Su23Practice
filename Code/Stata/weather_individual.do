*start from scratch beginning of application
clear all
*go to data folder. 
cd "../../Data/weather"

*Find all .dta files within a folder. 
local files : dir . files "*.dta"

foreach file of local files {
*open first data file. no need to set directory as it is already the correct location from above. 
use "`file'", clear

*CONVERT CELSIUS TO FAHRENHEIT. Variable transformation. 
generate tMin_f = (9/5 * tMin) + 32
generate tMax_f = (9/5 * tMax) + 32
generate tAvg_f = (tMax_f + tMin_f)/2

*create column that distinguishes 1 file from the next. 
gen file = "`file'"

*GETTING THE GRIDNUMBER AVERAGE
collapse (mean) tMin_f tMax_f tAvg_f, by(dateNum file)
save "complete/`file'.dta", replace
*clear dataset from memory.
clear
}

*Now combine all for a given year. 
cd "complete"
local files : dir "." files "*.dta"
foreach file of local files {
	append using `file'
	save "final/final2010.dta", replace
}

cd "../../../Code/Stata"