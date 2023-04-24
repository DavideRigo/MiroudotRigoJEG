/* -------------------------------------------------------------------------- */
// This do file replicates Table 7
/* -------------------------------------------------------------------------- */


clear all
set matsize 11000
capture log close
set more off

/**/

* Set main directory
global home .. 

use "$home/output/data/mp_rta_ind.dta", clear


/* -------------------------------------------------------------------------- */
/* ********************** Gen vars of interest ******************************* */
/* -------------------------------------------------------------------------- */

* keep 2-year intervals
keep if year== 2014 | year == 2010 | year == 2006 | year == 2002  | year == 2012 | year == 2008 | year == 2004 | year == 2000


/* take logs of vars */
foreach var of varlist fa_out distw {
		gen ln_`var' =log(`var')
}
 
* gen sector: goods vs services
gen sec = ""
foreach ind in "C10T12" "C13T15" "C16" "C17T18" "C19" "C20T21" "C22" "C23" "C24" ///
	"C25" "C26" "C27" "C28" "C29" "C30" "C31T32" {
	replace sec = "manuf" if ind == "`ind'"
}
foreach ind in "G" "H49" "H50" "H51" "H52" "H53" "I" "J58" "J59T60" "J61" "J62T63" "K" "L" "M" "N" {
	replace sec = "serv" if ind == "`ind'"
}
* keep only manuf and services
keep if sec != ""

* gen clustered provision vars
egen depth = rowtotal(serv_prov comp_prov sps_prov tbt_prov proc_prov iprs_prov) // number of provisions beyond inv prov

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
label variable fa_out "MP"

* gen fixed effects
egen cou_par_ind = group(cou par ind)
egen cou_ind_time = group(cou ind year)
egen par_ind_time = group(par ind year)

* industry measure of importance proximity to the customer
merge m:1 year ind using "$home/onet_index/output/isicadhoc_workwithpublic_panel.dta"
assert _m == 3 if year != 2000
drop _m
gen int_proximity = inv_prov*workwithpublic
label var int_proximity "Invest prov x Proximity"

* industry measure of GVC participation
merge m:1 year ind using "$home/input/scf.dta"
drop if _m == 2
assert _m == 3
drop _m
gen int_gvc = inv_prov*scf
label var int_gvc "Invest prov x GVC"


/* -------------------------------------------------------------------------- */
/* ************************** Run regressions ******************************* */
/* -------------------------------------------------------------------------- */

* Baseline structural gravity
ppmlhdfe fa_out rta inv_prov, absorb(cou_ind_time par_ind_time cou_par_ind) vce(cl cou_par_ind)
outreg2 using "$home/output/results/table7", replace text tex(frag) label nocon ///
	addtext(Host-ind-year FE, YES, Partner-ind-year FE, YES, Host-partner-ind, YES) 

* Interaction GVC participation
ppmlhdfe fa_out rta inv_prov int_gvc, absorb(cou_ind_time par_ind_time cou_par_ind) vce(cl cou_par_ind)
outreg2 using "$home/output/results/table7", append text tex(frag) label nocon ///
	addtext(Host-ind-year FE, YES, Partner-ind-year FE, YES, Host-partner-ind, YES) 	
	
* Interaction proximity to the public
ppmlhdfe fa_out rta inv_prov int_proximity, absorb(cou_ind_time par_ind_time cou_par_ind) vce(cl cou_par_ind)
outreg2 using "$home/output/results/table7", append text tex(frag) label nocon ///
	addtext(Host-ind-year FE, YES, Partner-ind-year FE, YES, Host-partner-ind, YES) 

* Both interactions
ppmlhdfe fa_out rta inv_prov int_gvc int_proximity, absorb(cou_ind_time par_ind_time cou_par_ind) vce(cl cou_par_ind)
outreg2 using "$home/output/results/table7", append text tex(frag) label nocon ///
	addtext(Host-ind-year FE, YES, Partner-ind-year FE, YES, Host-partner-ind, YES) 


/* Calculate magnitude SCF ratio coefficient (avg across years)

* eletronic and optical equipment SCF ratio = 0.44 
* food and tobacco SCF ratio = 0.20
* coefficient GVC*InvProv = 0.955
* coefficient InvProv = 0.293

display ((0.44-0.30)*0.955)/0.293
