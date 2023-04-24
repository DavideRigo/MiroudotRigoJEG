/* *****************************************************************************
* This do file import the importance scores from the O*NET database for the
* work activity "Performing for or Working Directly with the Public" and
* collapse the indicator at the 6-digit SOC 2010
*
***************************************************************************** */

clear all
set more off

* Set main directory
global home .. 

cd "$home/onet_index"


forvalues year = 2000(2)2014 {

	// import raw data from O*NET database
	if `year' == 2000 {
		import delimited using "input/Work_Activities_`year'.txt", delim(",") clear
	
	}
	else if `year' != 2000 {
		import delimited using "input/Work_Activities_`year'.txt", delim(tab) clear
	}
	
	//keep only importance score
	keep if scaleid=="IM"

	// keep only activity of interest
	keep if elementid == "4.A.4.a.8"

	// gen var of interest
	gen workwithpublic = datavalue

	// gen standardized scores on a scale 1-100
	gen workwithpublic_std = ((datavalue-1)/(5-1))*100

	// collapse at the 6 digit level using sample size as weights
	// the soc classification clusters occupation in 23 major groups (2 digits) and
	// 96 minor groups (4 digits)
	gen onetsoccode6d = substr(onetsoccode, 1, 7)
	if `year' >= 2006 {
		destring n, replace force
		collapse (mean) workwithpublic workwithpublic_std [w=n], by(onetsoccode6d)
	}
	else if `year' <= 2004 {
		collapse (mean) workwithpublic workwithpublic_std, by(onetsoccode6d)
	}
	
	// label vars
	label variable workwithpublic "Performing for or Working Directly with the Public (1-5)"
	label variable workwithpublic_std "Performing for or Working Directly with the Public (0-100)"
	
	// gen year
	gen year = `year'

	// save data set importance scores at soc 6 digit level
	keep year onetsoccode6d workwithpublic workwithpublic_std
	rename onetsoccode6d soc_code
	save "output/onet_workwithpublic`year'.dta", replace

}
