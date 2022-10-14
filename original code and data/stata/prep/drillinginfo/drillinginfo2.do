
* Insheet and clean Drillinginfo "Production Headers" file
	clear
	insheet using "data/Production Headers.csv", comma names // This file contains 1 row per entityid.
	* Clean
	format apiuwi %14.0f
	replace township = "06S" if township=="T6S"
	replace township = "07S" if township=="T7S"
	replace township = "09S" if township=="T9S"
	replace township = "19N" if township=="N19"
	replace range = "02E" if range=="R2E"
	replace range = "07W" if range=="R7W"
	replace range = "09W" if range=="R9W"
save "calculations/LA_DI_Production_Headers.dta", replace


* From Drillinginfo "Production Headers": form dataset of entityid and spuddate
	use "calculations/LA_DI_Production_Headers.dta", clear
	keep entityid spuddate
	order entityid spuddate
	* Destring dates
	replace spuddate = subinstr(spuddate,"-","",.)
	destring spuddate, replace
save "calculations/DI_wells_entityid_dates.dta", replace


* Using Drillinginfo "Production Headers": find the township associated with 
* each well.
	use "calculations/LA_DI_Production_Headers.dta", clear
	* Clean Township
	replace township="" if inlist(substr(township,length(township),1),"N","S")==0
	replace township = "05S" if township=="T5S"
	gen twpnum = substr(township,1,2)
	destring twpnum, replace
	gen twpdir = substr(township,3,1)
	* Clean Range
	replace range="" if inlist(substr(range,length(range),1),"E","W")==0
	replace range="01W" if range=="R1W"
	replace range="07E" if range=="R7E"
	replace range="09E" if range=="R9E"
	gen rgenum = substr(range,1,2)
	destring rgenum, replace
	replace rgenum=. if rgenum==0
	gen rgedir = substr(range,3,1)
save "calculations/DI_allwells_STR_final.dta", replace
