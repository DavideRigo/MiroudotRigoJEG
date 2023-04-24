* ============================================================================ *
* This do file creates the working dtas for the empirical analysis
* 
* This do file merge the following data:
*	- MP data balanced with WIOD tables; 2000-2014; ISIC rev. 4 (2 digits) for more information see Cadestin et al. (2018)
*	- PTAs data from DESTA
*	- BIT data from World Trade Institute
*	- Gravity vars from CEPII
*
* ============================================================================ *

clear all
set matsize 11000
capture log close
set more off



* Set main directory
global home .. 

* Use MP data
use "$home\input\mp_data.dta", clear

* Merge RTAs and provisions from DESTA
merge m:1 year cou par using "$home\input\desta_clean.dta"
foreach var of varlist rta* serv_prov inv_prov comp_prov proc_prov sps_prov iprs_prov tbt_prov {
	replace `var' = 0 if _merge==1 // assuming that DESTA includes the universe of treaties
}
drop if _merge==2
drop _merge


* Merge gravity vars from CEPII
merge m:1 year cou par using "$home\input\grav_vars.dta", nogen keep(3)


* Merge BITs from World Trade Institute (Berne)
merge m:1 year cou par using "$home\input\bit.dta"
gen bit = 1 if _merge == 3
replace bit=0 if _merge == 1
drop if _merge==2
drop _merge

* Drop small countries
drop if cou == "CYP" | cou == "MLT"
drop if par == "CYP" | par == "MLT"

* Rename vars
rename *,lower

* save dta at sectoral level
compress
order year cou par ind
sort year cou par 
save "$home\output\data\mp_rta_ind.dta", replace


* Create dta by sector (manufacturing & services) instead of industry
merge m:1 ind using "$home\input\ind_sec_classification.dta"
gen sec = ""
replace sec = "good" if ind_num>=3&ind_num<=19 // manufacturing
replace sec = "serv" if ind_num>=23&ind_num<=37 // commercial services
collapse (sum) fas_ds_int fas_ds_y fa_exp_int fa_exp_y fa_out, by(year cou par sec) fast
drop if sec == ""
reshape wide fa*, i(year cou par) j(sec) string


* Merge RTAs and provisions from DESTA
merge m:1 year cou par using "$home\input\desta_clean.dta"
foreach var of varlist rta* serv_prov inv_prov comp_prov proc_prov sps_prov iprs_prov tbt_prov {
	replace `var' = 0 if _merge==1 // assuming that DESTA includes the universe of treaties
}
drop if _merge==2
drop _merge


* Merge gravity vars from CEPII
merge m:1 year cou par using "$home\input\grav_vars.dta", nogen keep(3)


* Merge BITs from World Trade Institute (Berne)
merge m:1 year cou par using "$home\input\bit.dta"
gen bit = 1 if _merge == 3
replace bit = 0 if _merge == 1
drop if _merge==2
drop _merge

* save dta at year-cou-par level
save "$home\output\data\mp_rta.dta", replace

