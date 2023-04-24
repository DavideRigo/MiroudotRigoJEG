/* -------------------------------------------------------------------------- */
// This do file replicates Table 1
/* -------------------------------------------------------------------------- */

clear all
set matsize 11000
capture log close
set more off


* Set main directory
global home .. 

use "$home/output/data/mp_rta.dta", clear


drop if cou == par

// Table 1
keep if year == 2000 | year == 2005 | year == 2010 | year == 2014
collapse (sum) fas_ds_int* fas_ds_y* fa_exp_int* fa_exp_y* fa_out*, by(year)
gen fa_ds_int_good_sh = fas_ds_intgood/fa_outgood
gen fa_ds_y_good_sh = fas_ds_ygood/fa_outgood
gen fa_exp_int_good_sh = fa_exp_intgood/fa_outgood
gen fa_exp_y_good_sh = fa_exp_ygood/fa_outgood
gen fa_ds_int_serv_sh = fas_ds_intserv/fa_outserv
gen fa_ds_y_serv_sh = fas_ds_yserv/fa_outserv
gen fa_exp_int_serv_sh = fa_exp_intserv/fa_outserv
gen fa_exp_y_serv_sh = fa_exp_yserv/fa_outserv
keep year *_sh
foreach var of varlist *_sh {
	replace `var' = `var'*100
}
export excel using "$home/output/results/table1.xls", sheetreplace sheet("MP_shares") firstrow(variables)

