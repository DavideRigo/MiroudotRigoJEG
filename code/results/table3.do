/* -------------------------------------------------------------------------- */
// This do file replicates Table 3
/* -------------------------------------------------------------------------- */


clear all
set matsize 11000
capture log close
set more off

* Set main directory
global home .. 

use "$home/output/data/mp_rta.dta", clear

/* -------------------------------------------------------------------------- */
/* ********************** Gen var of interest ******************************* */
/* -------------------------------------------------------------------------- */

* keep 2-year intervals
keep if year== 2014 | year == 2010 | year == 2006 | year == 2002  | year == 2012 | year == 2008 | year == 2004 | year == 2000


/* take logs of vars */
foreach var of varlist fa* distw {
		gen ln_`var' =log(`var')
}



* gen clustered provision vars
egen depth = rowtotal(serv_prov comp_prov sps_prov tbt_prov proc_prov iprs_prov) // number of provisions beyond inv prov


* Label variables
label variable rta "PTA"
label variable serv_prov "Serv prov"
label variable inv_prov "Invest prov"
label variable comp_prov "Comp prov"
label variable proc_prov "Proc prov"
label variable iprs_prov "IPR prov"
label variable depth "Depth"
label variable bit "BIT"
label variable contig "Contiguity"
label variable comlang_off "Common language"
label variable ln_distw "Log distance"
label variable colony "Colony"


foreach var in "" {
	foreach var_type in good serv {
		label variable `var'fa_out`var_type' "FA output"	
	}
}

* gen fixed effects
egen cou_year = group(cou year)
egen par_year = group(par year)
egen cou_par = group(cou par)



/* -------------------------------------------------------------------------- */
/* ************************** Run regressions ******************************* */
/* -------------------------------------------------------------------------- */

***** GOODS

ppmlhdfe fa_outgood rta, absorb(cou_year par_year cou_par) vce(cl cou_par)
outreg2 using "$home/output/results/table3", ///
	replace text addtext(Host-year FE, YES, Partner-year FE, YES, Country-pair FE, YES) label cttop("GOOD")

ppmlhdfe fa_outgood rta inv_prov, absorb(cou_year par_year cou_par) vce(cl cou_par)
outreg2 using "$home/output/results/table3", ///
	append text addtext(Host-year FE, YES, Partner-year FE, YES, Country-pair FE, YES) label cttop("GOOD")

ppmlhdfe fa_outgood rta inv_prov depth, absorb(cou_year par_year cou_par) vce(cl cou_par)
outreg2 using "$home/output/results/table3", ///
	append text addtext(Host-year FE, YES, Partner-year FE, YES, Country-pair FE, YES) label cttop("GOOD")
	
ppmlhdfe fa_outgood rta inv_prov serv_prov, absorb(cou_year par_year cou_par) vce(cl cou_par)
outreg2 using "$home/output/results/table3", ///
	append text addtext(Host-year FE, YES, Partner-year FE, YES, Country-pair FE, YES) label cttop("GOOD")	

ppmlhdfe fa_outgood rta inv_prov bit, absorb(cou_year par_year cou_par) vce(cl cou_par)
outreg2 using "$home/output/results/table3", ///
	append text addtext(Host-year FE, YES, Partner-year FE, YES, Country-pair FE, YES) label cttop("GOOD")	
		


***** SERVICES

ppmlhdfe fa_outserv rta, absorb(cou_year par_year cou_par) vce(cl cou_par)
outreg2 using "$home/output/results/table3", ///
	append text addtext(Host-year FE, YES, Partner-year FE, YES, Country-pair FE, YES) label cttop("SERV")

ppmlhdfe fa_outserv rta inv_prov, absorb(cou_year par_year cou_par) vce(cl cou_par)
outreg2 using "$home/output/results/table3", ///
	append text addtext(Host-year FE, YES, Partner-year FE, YES, Country-pair FE, YES) label cttop("SERV")

ppmlhdfe fa_outserv rta inv_prov depth, absorb(cou_year par_year cou_par) vce(cl cou_par)
outreg2 using "$home/output/results/table3", ///
	append text addtext(Host-year FE, YES, Partner-year FE, YES, Country-pair FE, YES) label cttop("SERV")

ppmlhdfe fa_outserv rta inv_prov serv_prov, absorb(cou_year par_year cou_par) vce(cl cou_par) 
outreg2 using "$home/output/results/table3", ///
	append text tex(frag) addtext(Host-year FE, YES, Partner-year FE, YES, Country-pair FE, YES) label cttop("SERV")

ppmlhdfe fa_outserv rta inv_prov bit, absorb(cou_year par_year cou_par) vce(cl cou_par) 
outreg2 using "$home/output/results/table3", ///
	append text tex(frag) addtext(Host-year FE, YES, Partner-year FE, YES, Country-pair FE, YES) label cttop("SERV")


