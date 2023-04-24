* ============================================================================ *
* This do file creates the database with the list of PTAs and their provisions
* using DESTA
*
* ============================================================================ * 

* Set main directory
global home ..

/* STEP 1: IMPORT LIST OF TREATIES FROM DESTA AND MERGE PROVISIONS DUMMIES AND RTA VAR */

* import market access data
import excel "$home\input\desta_raw\market_access_01_03.xlsx", firstrow clear
keep number typedepth
replace number ="799" if number =="799+1" // harmonize with list of treaties
* gen var rta
gen rta2 = (typedepth == 2 |typedepth == 3) // FTA or CU
gen rta = (typedepth <= 3) // PSA, FTA or CU
drop typedepth
tempfile rta
save "`rta'", replace

* import services provisions
import excel "$home\input\desta_raw\services_01_03.xlsx", firstrow clear
keep number ser_chap ser_mfn ser_nationaltreat ser_nonestablishment ser_movement
replace number ="799" if number =="799+1" // harmonize with list of treaties
* gen services provisions 
gen serv_prov = (ser_chap == 2) // substantive provisions liberalizing trade in services
gen serv_prov_mfn = (ser_mfn == 1)
gen serv_prov_nt = (ser_nationaltreat==2 | ser_nationaltreat == 1)
gen serv_prov_nonest = (ser_nonestablishment == 1)
gen serv_prov_mov = (ser_movement == 1)
keep number serv_prov serv_prov_mfn serv_prov_nt serv_prov_nonest serv_prov_mov
tempfile serv_prov
save "`serv_prov'"

* import investment provisions
import excel "$home\input\desta_raw\investment_01_03.xlsx", firstrow clear
keep number inv_sect_cov
gen inv_bit = (inv_sect_cov == 2) // if investment chapter relies on an existing BIT
gen inv_serv = (inv_sect_cov == 3) // if only investment in the services sector is protected
gen inv_beyond = (inv_sect_cov == 4) // if investment chapter beyond (separate) services
gen inv_prov = (inv_sect_cov>2) // if it has an investment chapter within or beyond services chapter
// Specific provision on non-discrimination (e.g. pre-establishment oper, establishment, post-establishment, acquisition)
// are multicollinear, no variation among them!
drop inv_sect_cov
tostring number, replace
tempfile invest_prov
save "`invest_prov'"

* import competition provisions
import excel "$home\input\desta_raw\competition_01_03.xlsx", firstrow clear
keep number comp_chap
replace number ="799" if number =="799+1" // harmonize with list of treaties
gen comp_prov = (comp_chap == 1) // agreement includes a competition chapter
drop comp_chap
tempfile comp_prov
save "`comp_prov'"

* import public procurement provisions
import excel "$home\input\desta_raw\public_procurement_01_03.xlsx", firstrow clear
keep number proc_prov
replace number ="799" if number =="799+1" // harmonize with list of treaties
gen proc_prov2 = (proc_prov == 2) // agreement contains substantive provisions on public procurement
drop proc_prov
rename proc_prov2 proc_prov
tempfile proc_prov
save "`proc_prov'"

* import intellectual property rights provisions
import excel "$home\input\desta_raw\depth_01_03.xlsx", firstrow clear
keep number specdepth_iprs
rename specdepth_iprs iprs_prov
replace number ="799" if number =="799+1" // harmonize with list of treaties
tempfile iprs_prov
save "`iprs_prov'"

* import SPS provisions
import excel "$home\input\desta_raw\sps_01_03.xlsx", firstrow clear
keep number sps_prov // agreement contains a SPS chapter or provision(s)
replace number ="799" if number =="799+1" // harmonize with list of treaties
tempfile sps_prov
save "`sps_prov'"

* import TBT provisions
import excel "$home\input\desta_raw\tbt_01_03.xlsx", firstrow clear
keep number tbt_prov // agreement contains a TBT chapter or provision(s)
replace number ="799" if number =="799+1" // harmonize with list of treaties
tempfile tbt_prov
save "`tbt_prov'"

* import dispute settlement
import excel "$home\input\desta_raw\dispute_settlement_01_03.xlsx", firstrow clear
keep number ds_prov
replace number ="799" if number =="799+1" // harmonize with list of treaties
tempfile ds_prov
save "`ds_prov'"


* import list of treaties from DESTA
import excel "$home\input\desta_raw\list_of_treaties_dyadic_01_03.xlsx", firstrow clear
// manually code accession treaties
tostring base_treaty, replace
replace number = base_treaty if entry_type == "accession"
replace coded = 1 if entry_type == "accession"

* clean data
tab entry_type coded
drop if coded == 0 // drop all treaties that are not coded for provisions, such as withdrawal and negotiations
// When entry_type == "base_treaty" refers to a trade agreement between EU and some Caribbean islands (Aruba, Anguilla) & PAFTA
drop if entry_type == "consolidated" // drop all consolidated treaties
replace number ="799" if number =="799+1" // harmonize with list of treaties

* replace entry into force with year in which the treaty is signed
// The treaty on avg/median entry into force two years after it was signed!!!
// Solution: adjust these cases manually or replace = year + 2
destring year, replace
replace entryforceyear = year + 2 if entryforceyear==.

* keep only vars of interest
keep country1 country2 base_treaty name number entryforceyear entry_type typememb regioncon
rename entryforceyear year
label var year "year of entry into force"

* merge ctry ISO code (3 digits)
rename country1 country
rename country2 country_par
merge m:1 country using "$home\input\country_isocode3.dta", keep(1 3)
tab _merge
drop _merge
rename iso3 cou
merge m:1 country_par using "$home\input\country_isocode3_par.dta", keep(1 3)
tab _merge
drop _merge
rename iso3 par
drop country country_par iso2
* drop missing ctry iso codes
drop if cou=="(*)"
drop if par=="(*)"
drop if cou==""
drop if par==""

* merge market access var to construct rta
merge m:1 number using "`rta'"
tab _merge // all treaties are matched
drop if _merge==1 // 0 obs dropped
drop if _merge==2 // 57 obs dropped
drop _merge

* merge provisions
merge m:1 number using "`serv_prov'", nogen keep(1 3)
merge m:1 number using "`invest_prov'", nogen keep(1 3)
merge m:1 number using "`comp_prov'", nogen keep(1 3)
merge m:1 number using "`proc_prov'", nogen keep(1 3)
merge m:1 number using "`sps_prov'", nogen keep(1 3)
merge m:1 number using "`tbt_prov'", nogen keep(1 3)
merge m:1 number using "`ds_prov'", nogen keep(1 3)
merge m:1 number using "`iprs_prov'", nogen keep(1 3)


* drop duplicates
bys year cou par: gen n=_n // there are some duplicates (4 per cent of the sample)
drop n



/* STEP 2: EXPAND EACH DYAD UNTIL 2014 */
* expand each dyad from the year in which the treaty is signed until 2014 (last year of FA data)
sort cou par year
drop if year > 2014
rename year year_start
gen year_end=2014
gen diff = year_end - year_start + 1
sort cou par diff
expand diff
gen fill = .
sort number cou par year_start
bys number cou par year_start: replace fill = year_start+(_n-1)
rename fill year
drop diff year_start year_end
* keep only years of interest
keep if year>=2000
order number base_treaty year cou par
sort cou par year



/* STEP 3: GET RID OF DUPLICATES */
/* keep duplicates with the highest value for each provision */
bys year cou par: gen n=_n
collapse (max) rta* serv_prov inv_prov inv_beyond comp_prov proc_prov sps_prov /// 
		tbt_prov iprs_prov ds_prov serv_prov_mfn serv_prov_nt serv_prov_nonest serv_prov_mov, ///
		by(year cou par) fast // no missing values!



/* STEP 4: MAKE THE DTA BIDIRECTIONAL BY APPENDING THE REVERSED DATASET */
* make the dta bidirectional (for every cou-par create a par-cou observation)
preserve

		rename cou c
		rename par cou
		rename c par
		sort year cou par
		tempfile desta2
		save "`desta2'", replace

restore
append using "`desta2'"
* there are some duplicates since some treatries were already bidirectional
bys year cou par: gen n = _n
tab n
collapse (max) rta* serv_prov inv_prov inv_beyond comp_prov proc_prov sps_prov ///
		tbt_prov iprs_prov ds_prov serv_prov_mfn serv_prov_nt serv_prov_nonest serv_prov_mov, ///
		by(year cou par) fast // no missing values!



/* STEP 5: Upon entry into EU, new member states inherit the PTAs previously signed 
* 	by the EU */
tempfile temp_clean_desta
save `temp_clean_desta', replace

keep if cou == "FRA" | par == "FRA"

* gen EU dummy (excluding FRA)
gen eu = 0
foreach cou in AUT	BEL	BGR	CYP	CZE	DEU	DNK	ESP	EST	FIN	GBR	GRC	HRV	/// 
HUN	IRL	ITA	LTU	LUX	LVA	MLT	NLD	POL	PRT	ROU	SVK	SVN	SWE {

	foreach par in AUT	BEL	BGR	CYP	CZE	DEU	DNK	ESP	EST	FIN	GBR	GRC	HRV	/// 
			HUN	IRL	ITA	LTU	LUX	LVA	MLT	NLD	POL	PRT	ROU	SVK	SVN	SWE {
			
		replace eu = 1 if cou == "`cou'"
		replace eu = 1 if par == "`par'"	
	
	}
}

* keep only extra-EU partners
keep if eu == 0
drop eu

* countries joining in 2004
preserve
		keep if year >= 2004
		tempfile temp
		save `temp'
		foreach var in CZE CYP MLT EST POL LTU LVA SVK SVN HUN {
			use `temp'
			replace cou = "`var'" if cou == "FRA"
			replace par = "`var'" if par == "FRA"
			tempfile temp_`var'
			save "`temp_`var''"
		}
restore

* countries joining in 2007
preserve
		keep if year >= 2007
		tempfile temp
		save `temp'
		foreach var in BGR ROU {
			use `temp'
			replace cou = "`var'" if cou == "FRA"
			replace par = "`var'" if par == "FRA"
			tempfile temp_`var'
			save "`temp_`var''"
		}
restore

* countries joining in 2013
preserve
		keep if year >= 2013
		tempfile temp
		save `temp'
		foreach var in HRV {
			use `temp'
			replace cou = "`var'" if cou == "FRA"
			replace par = "`var'" if par == "FRA"
			tempfile temp_`var'
			save "`temp_`var''"
		}
restore

* append inherited treaties
use `temp_clean_desta', clear
foreach var in CZE CYP EST POL LTU LVA SVK SVN HUN MLT BGR ROU HRV {
	append using "`temp_`var''"
}
* collapse duplicates
collapse (max) rta* serv_prov inv_prov inv_beyond comp_prov proc_prov sps_prov ///
		tbt_prov iprs_prov ds_prov serv_prov_mfn serv_prov_nt serv_prov_nonest serv_prov_mov, ///
		by(year cou par) fast
		


/* STEP 6: Upon entry into EU, all provisions go to 1 */

* EU members before 2000
gen eu = 0
foreach c1 in AUT BEL DEU DNK ESP FRA FIN GBR GRC IRL ITA LUX NLD PRT SWE {

		foreach c2 in AUT BEL DEU DNK ESP FRA FIN GBR GRC IRL ITA LUX NLD PRT SWE {
		
			replace eu = 1 if cou == "`c1'" & par == "`c2'"
			
		}
}

foreach var in rta2 rta serv_prov inv_prov comp_prov proc_prov sps_prov tbt_prov iprs_prov ///
			serv_prov_mfn serv_prov_nt serv_prov_nonest serv_prov_mov {

			replace `var' = 1 if eu == 1
}
drop eu			

		
* countries joining in 2004
gen eu = 0
foreach c1 in AUT	BEL	DEU	DNK	ESP	FRA FIN	GBR	GRC	IRL	ITA	LUX	NLD	PRT	SWE {

		foreach c2 in CZE CYP EST POL LTU LVA SVK SVN HUN MLT {
		
			replace eu = 1 if cou == "`c1'" & par == "`c2'"
			replace eu = 1 if par == "`c1'" & cou == "`c2'"
			 
		}
}

* set to 1 for intra new EU members
foreach c1 in CZE CYP EST POL LTU LVA SVK SVN HUN MLT {
		foreach c2 in CZE CYP EST POL LTU LVA SVK SVN HUN MLT {
				replace eu = 1 if cou == "`c1'" & par == "`c2'"
		}
}
		
foreach var in rta2 rta serv_prov inv_prov comp_prov proc_prov sps_prov tbt_prov iprs_prov ///
			serv_prov_mfn serv_prov_nt serv_prov_nonest serv_prov_mov {

			replace `var' = 1 if eu == 1 & year >= 2004
}
drop eu


* countries joining in 2007
gen eu = 0
foreach c1 in AUT	BEL	DEU	DNK	ESP	FRA FIN	GBR	GRC	IRL	ITA	LUX	NLD	PRT	SWE CZE CYP EST POL LTU LVA SVK SVN HUN MLT {

		foreach c2 in BGR ROU {
		
			replace eu = 1 if cou == "`c1'" & par == "`c2'"
			replace eu = 1 if par == "`c1'" & cou == "`c2'"

		}
}

foreach c1 in BGR ROU {
		foreach c2 in BGR ROU {
			replace eu = 1 if cou == "`c1'" & par == "`c2'" 
		}
}
	
foreach var in rta2 rta serv_prov inv_prov comp_prov proc_prov sps_prov tbt_prov iprs_prov ///
			serv_prov_mfn serv_prov_nt serv_prov_nonest serv_prov_mov {

			replace `var' = 1 if eu == 1 & year >= 2007
}
drop eu

* countries joining in 2013
gen eu = 0
foreach c1 in AUT	BEL	DEU	DNK	ESP	FRA FIN	GBR	GRC	IRL	ITA	LUX	NLD	PRT	SWE CZE CYP EST POL LTU LVA SVK SVN HUN MLT BGR ROU {

		foreach c2 in HRV {
		
			replace eu = 1 if cou == "`c1'" & par == "`c2'"
			replace eu = 1 if par == "`c1'" & cou == "`c2'"
		
		}
}
			
foreach var in rta2 rta serv_prov inv_prov comp_prov proc_prov sps_prov tbt_prov iprs_prov ///
			serv_prov_mfn serv_prov_nt serv_prov_nonest serv_prov_mov {

			replace `var' = 1 if eu == 1 & year >= 2013
}
drop eu


/* END */

* save dta
order year cou par
sort year cou par
save "$home\input\desta_clean", replace
