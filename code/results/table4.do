/* -------------------------------------------------------------------------- */
// This do file replicates Table 4
/* -------------------------------------------------------------------------- */



clear all
set matsize 11000
capture log close
set more off

/**/

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


foreach var in "" "ln_" {
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



/* -------------------------------------------------------------------------- */
/* ************************** Run regressions ******************************* */
/* -------------------------------------------------------------------------- */

* Set missing to zero
// This happens when both numerator and denominator are zero
replace invprov_iv = 0 if invprov_iv == .

gen iv = invprov_iv
label var iv "Invest Prov (IV)"

* CONTROL FUNCTION APPROACH BY WOOLDRIDGE

* First stage
*************

xtset cou_par year
xtreg inv_prov rta iv i.cou_year i.par_year, fe vce(robust)
outreg2 using "$home/output/results/table4", replace text nocons keep(iv rta) ///
			addtext(Host-year FE, YES, Partner-year FE, YES, Country-pair FE, YES) label cttop("1-stage")	
predict double resid, e // gen prediction of the error term
label var resid "Residuals"


* Second stage
**************
	
ppmlhdfe fa_outgood rta inv_prov resid, absorb(cou_year par_year cou_par) vce(cluster cou_par)
outreg2 using "$home/output/results/table4", append text nocons ///
			addtext(Host-year FE, YES, Partner-year FE, YES, Country-pair FE, YES) label cttop("Good")	
			
ppmlhdfe fa_outserv rta inv_prov resid, absorb(cou_year par_year cou_par) vce(cluster cou_par)
outreg2 using "$home/output/results/table4", append text tex(frag) nocons ///
			addtext(Host-year FE, YES, Partner-year FE, YES, Country-pair FE, YES) label cttop("Serv")	


