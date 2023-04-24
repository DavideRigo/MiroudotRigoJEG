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
global home ..

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

* Gen year of treatment
gen year2 = year if inv_prov == 1
bys cou par (year): egen yeartreat = min(year2)
drop year2

* Gen var lag/lead for treatment
gen time_to_treat = year - yeartreat
replace time_to_treat = 0 if missing(yeartreat)

* Stata does not allow factors with negative values
sum time_to_treat
bys cou par (year): gen shifted_ttt = time_to_treat - r(min)

* Gen relative-time indicators for treated groups ignoring distant leads/lags
// any effect outside these leads/lags is assumed to be 0!
tab time_to_treat
forvalues t = -4(2)4 {
	if `t' < -1 {
	    local tname = abs(`t')
		gen g_m`tname' = time_to_treat == `t'
	}
	else if `t' >= 0 {
	    gen g_`t' = time_to_treat == `t'
	}
}

* Bin endpoints 
// because it is a strong assumption to assume the effect to be 0 outside the effect window
bys cou par (year): replace g_m4 = g_m4[_n+1] if g_m4[_n+1] == 1
bys cou par (year): replace g_m4 = g_m4[_n+1] if g_m4[_n+1] == 1
bys cou par (year): replace g_4 = g_4[_n-1] if g_4[_n-1] == 1


* Gen fixed effects
egen cou_par = group(cou par)
egen cou_year = group(cou year)
egen par_year = group(par year)


/* -------------------------------------------------------------------------- */
/* ************************** Run regressions ******************************* */
/* -------------------------------------------------------------------------- */

***** GOODS

ppmlhdfe fa_outgood rta g_m4 g_0 g_2 g_4, absorb(cou_par cou_year par_year) vce(cl cou_par)

* Plot cumulative effect and 95% confidence intervals
cap drop beta se time up down
gen beta=.
gen se=.
gen time=.

replace time=-4 in 1
replace beta=_b[g_m4] in 1
replace se=_se[g_m4] in 1

replace time=-2 in 2
replace beta=0 in 2
replace se=0 in 2

replace time=0 in 3
replace beta=_b[g_0] in 3
replace se=_se[g_0] in 3

replace time=2 in 4
replace beta=_b[g_2] in 4
replace se=_se[g_2] in 4

replace time=4 in 5
replace beta=_b[g_4] in 5
replace se=_se[g_4] in 5

gen up=beta+`z_value'*se
gen down=beta-`z_value'*se

twoway (scatter beta time, connect(line) lc(black)) ///
	   (rcap up down time, lp(dash) lc(black)), ///
	   title("Goods") leg(off) xlabel(-4(2)4) ///
	   yline(0, lc(red)) xtitle("Year") ytitle("Cumulative coefficients")

graph save "$home/output/results/dynamic_inv_prov_good.gph", replace


***** SERVICES
		
ppmlhdfe fa_outserv rta g_m4 g_0 g_2 g_4, absorb(cou_par cou_year par_year) vce(cl cou_par)

* Plot cumulative effect and 95% confidence intervals
cap drop beta se time up down
gen beta=.
gen se=.
gen time=.

replace time=-4 in 1
replace beta=_b[g_m4] in 1
replace se=_se[g_m4] in 1

replace time=-2 in 2
replace beta=0 in 2
replace se=0 in 2

replace time=0 in 3
replace beta=_b[g_0] in 3
replace se=_se[g_0] in 3

replace time=2 in 4
replace beta=_b[g_2] in 4
replace se=_se[g_2] in 4

replace time=4 in 5
replace beta=_b[g_4] in 5
replace se=_se[g_4] in 5

gen up=beta+`z_value'*se
gen down=beta-`z_value'*se

twoway (scatter beta time, connect(line) lc(black)) ///
	   (rcap up down time, lp(dash) lc(black)), ///
	   title("Services") leg(off) xlabel(-4(2)4) ///
	   yline(0, lc(red)) xtitle("Year") ytitle("Cumulative coefficients")

graph save "$home/output/results/dynamic_inv_prov_serv.gph", replace
	
graph combine "$home/output/results/dynamic_inv_prov_good.gph" "$home\output\results\dynamic_inv_prov_serv.gph", xcommon ycommon
graph export "$home/output/results/figure1.pdf", replace
erase "$home/output/results/dynamic_inv_prov_good.gph"
erase "$home/output/results/dynamic_inv_prov_serv.gph"
		




