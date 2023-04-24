/* -------------------------------------------------------------------------- */
// This do file replicates Table 5 & 6
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


* gen clustered provision vars
egen depth = rowtotal(serv_prov comp_prov sps_prov tbt_prov proc_prov iprs_prov) // number of provisions beyond inv prov


* Label variables
label variable rta "PTA"
label variable serv_prov "Serv prov"
label variable inv_prov "Invest prov"
label variable bit "BIT"
label variable depth "Depth"

* Label dep vars
label var fas_ds_intgood "Domestic MP"
label var fas_ds_ygood "Horizontal MP"
label var fa_exp_intgood "Vertical MP"
label var fa_exp_ygood "Export-platform MP"
label var fas_ds_intserv "Domestic MP"
label var fas_ds_yserv "Horizontal MP"
label var fa_exp_intserv "Vertical MP"
label var fa_exp_yserv "Export-platform MP"

  

/* -------------------------------------------------------------------------- */
/* ************************** Run regressions ******************************* */
/* -------------------------------------------------------------------------- */

cap erase "$home/output/results/table5.txt"
cap erase "$home/output/results/table6.txt"


***** GOODS
foreach dep_var of varlist fas_ds_intgood fas_ds_ygood fa_exp_intgood fa_exp_ygood {

		ppml_panel_sg `dep_var' rta inv_prov, ex(par) im(cou) y(year) 
		outreg2 using "$home/output/results/table5", append text tex(frag) ///
			addtext(Host-year FE, YES, Partner-year FE, YES, Country-pair FE, YES) label
		
}


***** SERVICES

foreach dep_var of varlist fas_ds_intserv fas_ds_yserv fa_exp_intserv fa_exp_yserv {
		
		ppml_panel_sg `dep_var' rta inv_prov, ex(par) im(cou) y(year) 
		outreg2 using "$home/output/results/table6", append text tex(frag) ///
			addtext(Host-year FE, YES, Partner-year FE, YES, Country-pair FE, YES) label
	
}

