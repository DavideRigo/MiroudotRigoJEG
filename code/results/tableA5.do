/* -------------------------------------------------------------------------- */
// This do file replicates Table XX
/* -------------------------------------------------------------------------- */

clear all
set matsize 11000
capture log close
set more off


* Set main directory
global home .. 

use "$home/output/data/mp_rta.dta", clear


// Table: deep provisions correlation matrix

keep if year== 2014 | year == 2010 | year == 2006 | year == 2002  | year == 2012 | year == 2008 | year == 2004 | year == 2000
egen depth = rowtotal(serv_prov comp_prov sps_prov tbt_prov proc_prov iprs_prov) // number of provisions beyond inv prov
label variable rta "PTA"
label variable serv_prov "Serv prov"
label variable inv_prov "Invest prov"
label variable comp_prov "Comp prov"
label variable proc_prov "Proc prov"
label variable iprs_prov "IPR prov"
label variable sps_prov "SPS prov"
label variable tbt_prov "TBT prov"
label variable bit "BIT"
label variable depth "Depth"

cd "$home/output/results"
corrtex rta serv_prov inv_prov comp_prov proc_prov sps_prov tbt_prov iprs_prov depth bit, file(tableA5) replace
