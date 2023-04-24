/* -------------------------------------------------------------------------- */
// This do file replicates the effective F-statistic developed by Olea and Pueger (2013) in Table 4
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
label variable depth "Depth"
label variable iprs_prov "IPR prov"
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

* Gen fixed effects
egen cou_year = group(cou year)
egen par_year = group(par year)
egen cou_par = group(cou par)


* Merge WB geo region and income vars
merge m:1 par using "$home/input/wb_regions_par.dta", nogen keep(1 3)
merge m:1 cou using "$home/input/wb_regions_cou.dta", nogen keep(1 3)
gen sameregion = (region_cou == region_par)
gen sameincome = (income_cou == income_par)
 

* Gen bilateral weights based on GDP per capita similarity between country i and j
gen gdppc_similarity = 1 - (gdpcap_par/(gdpcap_par + gdpcap_cou))^2 - (gdpcap_cou/(gdpcap_par + gdpcap_cou))^2
gen lgdppc_similarity = log(gdppc_similarity)
gen gdp_similarity = 1 - (gdp_par/(gdp_par + gdp_cou))^2 - (gdp_cou/(gdp_par + gdp_cou))^2
gen lgdp_similarity = log(gdp_similarity)


* Gen denominator: total number of PTAs signed by i
bys year cou: egen nopta_cou = total(rta)
bys year par: egen nopta_par = total(rta)
gen noregion = (sameregion == 0)
gen ptanoregion = rta*noregion
bys year cou: egen nopta_cou_noregion = total(ptanoregion)
gen noincome = (sameincome == 0)
gen ptanoincome = rta*noincome
bys year cou: egen nopta_cou_noincome = total(ptanoincome)
gen noregionincome = (sameincome == 0 & sameincome == 0)
gen ptanoregionincome = rta*noregionincome
bys year cou: egen nopta_cou_noregionincome = total(ptanoregionincome)


* Gen IV as average no inv prov that host and partner country have with third countries
bys year cou: egen noinvprov_cou = total(inv_prov)
bys year par: egen noinvprov_par = total(inv_prov)
gen invprov_iv = (noinvprov_cou - inv_prov)/(nopta_cou - rta) + (noinvprov_par - inv_prov)/(nopta_par - rta)
replace invprov_iv = 0 if cou == par
label var invprov_iv "Invest prov (IV)"
rename invprov_iv iv_var
replace iv_var = 0 if iv_var == .


* Demean all vars
unab list: fa_outgood fa_outserv ln_fa_outgood ln_fa_outserv rta inv_prov bit ///
		   iv_var
foreach var of local list {
	reghdfe `var', absorb(cou_year par_year cou_par) vce(cl cou_par) res(res_`var')
}


* Gen effective F-statistic developed by Olea and Pueger (2013)

local ivs res_iv_var
local nivs : word count `ivs'
matrix P = J(`nivs',2,.)
matrix rowname P = `ivs'
matrix colname P = Good Serv

local i = 1
foreach iv of local ivs {
	
	* Store effective F-stat for goods
	ivreg2 res_ln_fa_outgood res_rta (res_inv_prov = `iv'), cluster(cou_par) ffirst
	weakivtest
	local Feff = r(F_eff)
	matrix P[`i',1] = `Feff'
	
	* Store effective F-stat for services
	ivreg2 res_ln_fa_outserv res_rta (res_inv_prov = `iv'), cluster(cou_par) ffirst
	weakivtest
	local Feff = r(F_eff)
	matrix P[`i',2] = `Feff'
	
	local ++i

}

matrix list P, format(%2.1f)

mat2txt, matrix(P) saving("$home/output/results/table4_Fstat.csv") title(Table. Effective F-stat) replace

