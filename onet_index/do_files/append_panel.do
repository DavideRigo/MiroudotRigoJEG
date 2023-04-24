
clear

// panel data work with public
forvalues year = 2002(2)2014 { // year 2000 not have BLS data at NAICS 4-digit level
	append using "output/isicadhoc_workwithpublic`year'.dta"
}

save "output/isicadhoc_workwithpublic_panel.dta", replace
