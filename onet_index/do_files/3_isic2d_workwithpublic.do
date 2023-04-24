/* *****************************************************************************
* This do file create the indicator at ISIC rev 4 level
*
***************************************************************************** */


clear all
set more off

* Set main directory
global home .. 
cd "$home/onet_index"


forvalues year = 2002(2)2014 {
	
	// create index ISIC rev. 4 2-digit	
	use "output/naics4d_workwithpublic`year'.dta", clear
	if `year' <=2014 & `year'>=2012  {
		merge 1:m naics4d using "output/NAICS2012_ISICrev4.dta", keep(1 3)
	}
	else if `year' <=2010 & `year'>=2008 {
		merge 1:m naics4d using "output/NAICS2007_ISICrev4.dta", keep(1 3)
	}
	else if `year' <=2006 & `year'>=2002 {
		merge 1:m naics4d using "output/NAICS2002_ISICrev4.dta", keep(1 3)
	}
	tab naics4d if _merge == 1
	drop if _m == 1
	drop _merge
	merge m:m naics4d using "output/bls_naics4d_emp`year'.dta", keep(1 3) // merge empl weights by NAICS 4-digit
	assert _m == 3
	drop _m
	destring tot_emp, replace force
	collapse (mean) workwithpublic workwithpublic_std [w=tot_emp], by(isic2d)
	gen year = `year'
	save "output/isic2d_workwithpublic`year'.dta", replace
	
	
	// create index ISIC rev. 4 ad hoc
	use "output/naics4d_workwithpublic`year'.dta", clear	
	if `year' <=2014 & `year'>=2012  {
		merge 1:m naics4d using "output/NAICS2012_ISICrev4.dta", keep(1 3)
	}
	else if `year' <=2010 & `year'>=2008 {
		merge 1:m naics4d using "output/NAICS2007_ISICrev4.dta", keep(1 3)
	}
	else if `year' <=2006 & `year'>=2002 {	
		merge 1:m naics4d using "output/NAICS2002_ISICrev4.dta", keep(1 3)
	}
	tab naics4d if _merge == 1 // three NAICS industries (9991;9992;9993), not important for our analysis!
	drop if _m == 1
	drop _merge
	merge m:m naics4d using "output/bls_naics4d_emp`year'.dta", keep(1 3) // merge empl weights by NAICS 4-digit
	assert _m == 3
	drop _m
	destring tot_emp, replace force
	destring isic2d, replace
	do "do_files/correspondances/corres_isic4d_isicadhoc.do"
	drop if ind == ""
	collapse (mean) workwithpublic workwithpublic_std [w=tot_emp], by(ind)
	gen year = `year'
	save "output/isicadhoc_workwithpublic`year'.dta", replace

}
