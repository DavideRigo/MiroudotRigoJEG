// ISIC rev 4 list https://unstats.un.org/unsd/classifications/Econ/Download/In%20Text/ISIC_Rev_4_english_structure.Txt

// gen correspondance ISIC rev 4 2-digit to ISIC rev 4 in our paper
gen ind = ""
replace ind = "C10T12" if isic2d >=10 & isic2d <=12
replace ind = "C13T15" if isic2d >=13 & isic2d <=15
replace ind = "C16" if isic2d ==16
replace ind = "C17T18" if isic2d >=17 & isic2d <=18
replace ind = "C19" if isic2d == 19
replace ind = "C20T21" if isic2d >=20 & isic2d <=21
replace ind = "C22" if isic2d ==22
replace ind = "C23" if isic2d ==23
replace ind = "C24" if isic2d ==24
replace ind = "C25" if isic2d ==25
replace ind = "C26" if isic2d ==26
replace ind = "C27" if isic2d ==27
replace ind = "C28" if isic2d ==28
replace ind = "C29" if isic2d ==29
replace ind = "C30" if isic2d ==30
replace ind = "C31T32" if isic2d >=31 & isic2d <=32
replace ind = "G" if isic2d >=45 & isic2d <=47
replace ind = "H49" if isic2d ==49
replace ind = "H50" if isic2d ==50
replace ind = "H51" if isic2d ==51
replace ind = "H52" if isic2d ==52
replace ind = "H53" if isic2d ==53
replace ind = "I" if isic2d >=55 & isic2d <=56
replace ind = "J58" if isic2d ==58
replace ind = "J59T60" if isic2d >=59 & isic2d <=60
replace ind = "J61" if isic2d ==61
replace ind = "J62T63" if isic2d >=62 & isic2d <=63
replace ind = "K" if isic2d >=64 & isic2d <=66
replace ind = "L" if isic2d ==68
replace ind = "M" if isic2d >=69 & isic2d <=75
replace ind = "N" if isic2d >=77 & isic2d <=82
