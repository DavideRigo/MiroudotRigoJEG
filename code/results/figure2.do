/* -------------------------------------------------------------------------- */
// This do file replicates Figure 2
/* -------------------------------------------------------------------------- */



clear all
set matsize 11000
capture log close
set more off

set scheme plotplainblind

/**/

* Set main directory
global home .. 

use "$home\output\data\mp_rta.dta", clear


* set local number of repetition
local norep = 2000

forvalues i = 1/`norep' {

	use "$home\output\data\mp_rta.dta", clear


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

	* gen false inv provision
	tab inv_prov // 33% of country-pairs have a inv prov
	gen false_inv_prov = uniform() <= .33 // keep the same share of inv prov among ptas!
	replace false_inv_prov = 0 if rta == 0

	* Label variables
	label variable rta "PTA"
	label variable serv_prov "Serv prov"
	label variable inv_prov "Invest prov"
	label variable comp_prov "Comp prov"
	label variable proc_prov "Proc prov"
	label variable depth "Depth"
	label variable iprs_prov "IPR prov"
	label variable bit "BIT"
	label variable contig "Contiguity"
	label variable comlang_off "Common language"
	label variable ln_distw "Log distance"
	label variable colony "Colony"


	foreach var in "" "ln_" {
		foreach var_type in good serv {
			label variable `var'fa_out`var_type' "FA output"		
		}	
	}




	/* -------------------------------------------------------------------------- */
	/* ************************** Run regressions ******************************* */
	/* -------------------------------------------------------------------------- */

	* ############################################################################# *
	// Intra analysis

	***** GOODS
	
	ppml_panel_sg fa_outgood rta false_inv_prov, ex(par) im(cou) y(year) // 
	parmest, saving("$home\output\results\beta_good_`i'", replace)					


	***** SERVICES

	ppml_panel_sg fa_outserv rta false_inv_prov, ex(par) im(cou) y(year) // 
	parmest, saving("$home\output\results\beta_serv_`i'", replace)					

}


	* Gen graphs
	************

* GOODS
clear
forvalues i = 1/`norep' {
	append using "$home\output\results\beta_good_`i'.dta"
	erase "$home\output\results\beta_good_`i'.dta"
}
keep if parm == "false_inv_prov"
gen sig = (p < 0.05)
count if sig == 10
display `r(N)'/`norep' "% of coefficients are significant at 5% level"
* histogram
twoway hist estimate || scatteri 0 .230 20 .230, recast(line) lw(thin) ///
	legend(off) xtitle("Coefficient on Inv Prov") ytitle(Density) title("Goods")
graph save "$home\output\results\hist_good.gph", replace 


* SERVICES
clear
forvalues i = 1/`norep' {
	append using "$home\output\results\beta_serv_`i'.dta"
	erase "$home\output\results\beta_serv_`i'.dta"
}
keep if parm == "false_inv_prov"
gen sig = (p < 0.05)
count if sig == 1
display `r(N)'/`norep' "% of coefficients are significant at 5% level"
* histogram
twoway hist estimate || scatteri 0 .295 20 .295, recast(line) lw(thin) ///
	legend(off) xtitle("Coefficient on Inv Prov") ytitle(Density) title("Services")
graph save "$home\output\results\hist_serv.gph", replace 



	* Combine graphs GOODS & SERV
	*****************************
graph combine "$home\output\results\hist_good.gph" "$home\output\results\hist_serv.gph", xcommon // ycommon
graph export "$home\output\results\figure2.pdf", replace

erase "$home\output\results\hist_good.gph"
erase "$home\output\results\hist_serv.gph"

