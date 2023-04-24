/* -------------------------------------------------------------------------- */
// This do file replicates Table 2
/* -------------------------------------------------------------------------- */

clear all
set matsize 11000
capture log close
set more off


* Set main directory
global home .. 

use "$home/output/data/mp_rta.dta", clear



// Table 2

* count number of provisions
gen index = 1
collapse (sum) index rta serv_prov inv_prov bit, by(year)

foreach var of varlist rta serv_prov inv_prov bit {
		gen sh_`var' = (`var'/index)*100
		drop `var'
}
drop index
keep if year == 2000 | year == 2005 | year == 2010 | year == 2014

export excel using "$home/output/results/table2.xls", sheetreplace sheet("prov_shares") firstrow(variables)







