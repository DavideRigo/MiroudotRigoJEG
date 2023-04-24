
clear all
set more off

// set working directories
cd "C:/Users/Davide/Dropbox/MP_PTA_project/MP & PTA/data/ONET"

// import correspondance table
import excel "input/2007_NAICS_to_ISIC_4", firstrow case(lower) clear sheet("NAICS 07 to ISIC 4 technical")
drop noteslinkcontentbasedonna f
rename (isic40 isicrevision40title) (isic4d isic4d_title)
rename (naicsus naicsustitle) (naics6d naics6d_title)
tostring naics6d, replace
gen l = length(naics6d)
drop if l != 6
drop l
gen naics4d = substr(naics6d,1,4)
gen l = length(isic4d)
replace isic4d = "0" + isic4d if l == 3
drop l
gen isic2d = substr(isic4d,1,2)
keep naics4d isic2d
duplicates drop naics4d isic2d, force
save "output/NAICS2007_ISICrev4.dta", replace
