*manipulation exercise. 
clear all
cd "../../Data/weather"
local files : dir . files "*.dta"

foreach file of local files {
*open first data file. no need to set directory as it is already the correct location
use "`file'", clear

*CONVERT CELSIUS TO FAHRENHEIT
generate tMin_f = (9/5 * tMin) + 32
generate tMax_f = (9/5 * tMax) + 32
generate tAvg_f = (tMax_f + tMin_f)/2

*Create variable that separates 1 datafile to the next. 
gen file = "`file'"

*GETTING THE GRIDNUMBER AVERAGE
collapse (mean) tMin_f tMax_f tAvg_f prec, by(dateNum file)
*save dataset. Must have unique name. 
save "loop/AVG`file'", replace
*clear dataset from memory.
clear
}

*Now combine all.
cd "loop"
*Find all AVG files created from step above. 
local files : dir . files "AVG*.dta"
foreach file of local files {
	append using `file'
	save "final\final_all.dta", replace
}

use "final\final_all.dta", clear

*Quick analysis. Goal to do ANOVA test. is avg farenheit temperature sig diff for one of the fips? 
bysort file: su tAvg_f prec

*convert fips variable to numeric. Need all variables be numeric to perform ANOVA. 
encode file, generate(fips)

*anova test. avg temp different from any 1 fips?
oneway tAvg_f fips, tabulate

*analyze results. 

cd "../../../Code/Stata"