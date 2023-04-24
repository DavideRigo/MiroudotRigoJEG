clear all
set more off

// set working directories
cd "C:/Users/Davide/Dropbox/MP_PTA_project/MP & PTA/data/ONET"

// import correspondance table NAICS 2002 to ISIC rev 3.1
import excel "input/2002_NAICS_to_ISIC_3.1.xls", firstrow case(lower) clear
drop lineid notes
rename (naicsus naicsustitle) (naics6d naics6d_title)
tostring naics6d, replace
gen l = length(naics6d)
drop if l != 6
drop l
gen naics4d = substr(naics6d,1,4)
gen l = length(isic31)
drop if l > 4
drop l
destring isic31, replace force
save "output/NAICS2002_ISICrev31.dta", replace


// import correspondance table ISIC rev 3.1 to ISIC rev 4
import delimited "input\ISICrev31_ISICrev4.txt", delimiter(comma) clear
keep isic31code isic4code
rename isic31code isic31
save "output/ISICrev31_ISICrev4.dta", replace


// Convert NAICS 2002 to ISIC rev 4
use "output/NAICS2002_ISICrev31.dta", clear
merge m:m isic31 using "output/ISICrev31_ISICrev4.dta", keep(3) nogen
rename isic4code isic4d
tostring isic4d, replace
gen l = length(isic4d)
replace isic4d = "0" + isic4d if l == 3
drop l
gen isic2d = substr(isic4d,1,2)
keep naics4d isic2d
save "output/NAICS2002_ISICrev4.dta", replace
