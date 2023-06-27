/* -------------------------------------------------------------------------- */
// This do file replicates Figure 1
/* -------------------------------------------------------------------------- */



clear all
set matsize 11000
capture log close
set more off
set scheme plotplainblind


/**/


* Set main directory
global home "C:\Users\rigod\Dropbox\GitHub\MiroudotRigo" 

use "$home/output/data/mp_rta.dta", clear

* set parameters
local z_value = 1.96 // 1.645 1.96 2.58


/* -------------------------------------------------------------------------- */
/* ************************** Gen var of interest *************************** */
/* -------------------------------------------------------------------------- */

* keep 2-year intervals
keep if year== 2014 | year == 2010 | year == 2006 | year == 2002  | year == 2012 | year == 2008 | year == 2004 | year == 2000


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


* gen lag/lead vars
egen cou_par = group(cou par)
egen cou_year = group(cou year)
egen par_year = group(par year)
xtset cou_par year
forvalues y = 2(2)4 {
	gen lag`y'_inv_prov = l`y'.inv_prov
}
forvalues y = 2(2)4 {
	gen lead`y'_inv_prov = f`y'.inv_prov
}


/* -------------------------------------------------------------------------- */
/* ************************** Run regressions ******************************* */
/* -------------------------------------------------------------------------- */

***** GOODS

ppmlhdfe fa_outgood rta lag4_inv_prov lag2_inv_prov inv_prov lead2_inv_prov depth, absorb(cou_par cou_year par_year) vce(cl cou_par)

* Plot cumulative effect and 95% confidence intervals
cap drop beta se time up down
gen beta=.
gen se=.
gen time=.

lincom lead2_inv_prov
replace time=-2 in 1
replace beta=`r(estimate)' in 1
replace se=`r(se)' in 1

lincom lead2_inv_prov + inv_prov
replace time=0 in 2
replace beta=`r(estimate)' in 2
replace se=`r(se)' in 2

lincom lead2_inv_prov + inv_prov + lag2_inv_prov
replace time=2 in 3
replace beta=`r(estimate)' in 3
replace se=`r(se)' in 3

lincom lead2_inv_prov + inv_prov + lag2_inv_prov + lag4_inv_prov
replace time=4 in 4
replace beta=`r(estimate)' in 4
replace se=`r(se)' in 4

gen up=beta+`z_value'*se
gen down=beta-`z_value'*se

twoway (line beta time, lc(black)) (line up time, lp(dash) lc(black)) ///
(line down time, lp(dash) lc(black)), title("Goods") leg(off) xlabel(-2(2)4) ///
yline(0, lc(red)) xtitle("Year") ytitle("Cumulative coefficients")

graph save "$home/output/results/dynamic_inv_prov_good.gph", replace


***** SERVICES
		
ppmlhdfe fa_outserv rta lag4_inv_prov lag2_inv_prov inv_prov lead2_inv_prov depth, absorb(cou_par cou_year par_year) vce(cl cou_par)
	
* Plot cumulative effect and 95% confidence intervals
cap drop beta se time up down
gen beta=.
gen se=.
gen time=.

lincom lead2_inv_prov
replace time=-2 in 1
replace beta=`r(estimate)' in 1
replace se=`r(se)' in 1

lincom lead2_inv_prov + inv_prov
replace time=0 in 2
replace beta=`r(estimate)' in 2
replace se=`r(se)' in 2

lincom lead2_inv_prov + inv_prov + lag2_inv_prov
replace time=2 in 3
replace beta=`r(estimate)' in 3
replace se=`r(se)' in 3

lincom lead2_inv_prov + inv_prov + lag2_inv_prov + lag4_inv_prov
replace time=4 in 4
replace beta=`r(estimate)' in 4
replace se=`r(se)' in 4

gen up=beta+`z_value'*se
gen down=beta-`z_value'*se

twoway (line beta time, lc(black)) (line up time, lp(dash) lc(black)) ///
(line down time, lp(dash) lc(black)), title("Services") leg(off) xlabel(-2(2)4) ///
yline(0, lc(red)) xtitle("Year") ytitle("Cumulative coefficients")

graph save "$home/output/results/dynamic_inv_prov_serv.gph", replace
	
graph combine "$home/output/results/dynamic_inv_prov_good.gph" "$home\output\results\dynamic_inv_prov_serv.gph", xcommon ycommon
graph export "$home/output/results/figure1.pdf", replace
erase "$home/output/results/dynamic_inv_prov_good.gph"
erase "$home/output/results/dynamic_inv_prov_serv.gph"
		




