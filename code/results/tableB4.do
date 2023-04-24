* =============================================================================
* This do file replicates Table B4
* =============================================================================


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


foreach var in "" {
	foreach var_type in good serv {
		label variable `var'fa_out`var_type' "FA output"	
	}
}

**** Gen EU dummy: changes over time

* EU members before 2000
gen eu = 0
foreach c1 in AUT BEL DEU DNK ESP FRA FIN GBR GRC IRL ITA LUX NLD PRT SWE {

		foreach c2 in AUT BEL DEU DNK ESP FRA FIN GBR GRC IRL ITA LUX NLD PRT SWE {
		
			replace eu = 1 if cou == "`c1'" & par == "`c2'" & year >= 2000
			replace eu = 1 if par == "`c1'" & cou == "`c2'" & year >= 2000

			
		}
}

* EU enlargement in 2004
foreach c1 in CZE CYP EST POL LTU LVA SVK SVN HUN MLT {

	foreach c2 in AUT BEL DEU DNK ESP FRA FIN GBR GRC IRL ITA LUX NLD PRT SWE CZE CYP EST POL LTU LVA SVK SVN HUN MLT {

			replace eu = 1 if cou == "`c1'" & par == "`c2'" & year >= 2004
			replace eu = 1 if par == "`c1'" & cou == "`c2'" & year >= 2004
			 
		}
}
	

* EU enlargement in 2007
foreach c1 in BGR ROU {

		foreach c2 in AUT BEL DEU DNK ESP FRA FIN GBR GRC IRL ITA LUX NLD PRT SWE CZE CYP EST POL LTU LVA SVK SVN HUN MLT BGR ROU {
		
			replace eu = 1 if cou == "`c1'" & par == "`c2'" & year >= 2007
			replace eu = 1 if par == "`c1'" & cou == "`c2'" & year >= 2007

		}
}
		
* EU enlargement in 2013
foreach c1 in HRV {

		foreach c2 in AUT BEL DEU DNK ESP FRA FIN GBR GRC IRL ITA LUX NLD PRT SWE CZE CYP EST POL LTU LVA SVK SVN HUN MLT BGR ROU HRV {
		
			replace eu = 1 if cou == "`c1'" & par == "`c2'" & year >= 2013
			replace eu = 1 if par == "`c1'" & cou == "`c2'" & year >= 2013
		
		}
}



/* -------------------------------------------------------------------------- */
/* ************************** Run regressions ******************************* */
/* -------------------------------------------------------------------------- */


***** GOODS

ppml_panel_sg fa_outgood rta eu, ex(par) im(cou) y(year) 
outreg2 using "$home/output/results/tableB4", ///
replace text addtext(Host-year FE, YES, Partner-year FE, YES, Country-pair FE, YES) label cttop("GOOD")

ppml_panel_sg fa_outgood rta inv_prov eu, ex(par) im(cou) y(year) 
outreg2 using "$home/output/results/tableB4", ///
append text addtext(Host-year FE, YES, Partner-year FE, YES, Country-pair FE, YES) label cttop("GOOD")
		


***** SERVICES

ppml_panel_sg fa_outserv rta eu, ex(par) im(cou) y(year) 
outreg2 using "$home/output/results/tableB4", ///
append text addtext(Host-year FE, YES, Partner-year FE, YES, Country-pair FE, YES) label cttop("SERV")

ppml_panel_sg fa_outserv rta inv_prov eu, ex(par) im(cou) y(year) 
outreg2 using "$home/output/results/tableB4", ///
append text tex(frag) addtext(Host-year FE, YES, Partner-year FE, YES, Country-pair FE, YES) label cttop("SERV")
	

