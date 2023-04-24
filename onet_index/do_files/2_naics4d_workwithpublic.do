/* *****************************************************************************
* This do file create the indicator at NAICS 4 digit level
*
***************************************************************************** */

clear all
set more off

* Set main directory
global home .. 
cd "$home/onet_index"

forvalues year = 2002(2)2014 {

	// import BLS data
	if `year' == 2012 {
		use "input/nat4d_M2012_dl.dta", clear
	}
	else if `year' != 2012 {
		import excel "input/nat4d_M`year'_dl", firstrow case(lower) clear
	}
	
	// keep only detailed SOC categories
	merge m:1 occ_code using "output\list_detailed_soccodes.dta", keep(3) nogen

	keep naics naics_title occ_code occ_title tot_emp
	gen naics4d = substr(naics,1,4)
	preserve
		keep naics4d tot_emp
		save "output/bls_naics4d_emp`year'.dta", replace
	restore

	// merge ONET data
	rename occ_code soc_code
	merge m:1 soc_code using "output/onet_workwithpublic`year'.dta", keep(1 3)
	drop if _m == 1
	drop _m

	// gen index at NAICS 4-digit level
	destring tot_emp, force replace
	collapse (mean) workwithpublic workwithpublic_std [w=tot_emp], by(naics4d naics_title)
	save "output/naics4d_workwithpublic`year'.dta", replace

}
