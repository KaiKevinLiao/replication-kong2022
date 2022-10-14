* From Drillinginfo production data, compute the following types of production by township:
* (i) during the 5 years preceding an auction
* (ii) from wells that were spudded during the 3 years after an auction
	
use "calculations/LA_DI_Production_Time_Series.dta", clear

* Attach township-range info.
merge m:1 entityid using "calculations/DI_allwells_STR_final.dta"
drop if _m==2
drop _m
keep if missing(twpnum)==0 & missing(twpdir)==0 & missing(rgenum)==0 & missing(rgedir)==0	
keep entityid twpnum twpdir rgenum rgedir liquidbbl gasmcf prodyear

* Attach well dates to production time series data.
merge m:1 entityid using "calculations/DI_wells_entityid_dates.dta"
drop if _m==2
drop _m
save "calculations/temp.dta", replace


*** Compute for each auctionyear-township, production during 5 years pre auction:	
forvalues y = 1974/2003 { // y represents auctionyear

	use "calculations/temp.dta", clear
	keep if prodyear<`y' & prodyear>=`y'-5 // 5 years preceding auction.
	
	* Total production during those years by well
	collapse (sum) liquidbbl* gasmcf* , by(entityid twpnum twpdir rgenum rgedir)

	* BOE: barrel of oil equivalents
	gen boe = liquidbbl + gasmcf/6
	
	* Collapse to average production per well by township
	collapse (mean) boepw_past_ave=boe , by(twpnum twpdir rgenum rgedir)
	
	gen auctionyear=`y'	

	if `y'>1974 {
		append using "calculations/DI_prod_by_township_past.dta"
	}
	save "calculations/DI_prod_by_township_past.dta", replace 
}	
order auctionyear twpnum twpdir rgenum rgedir
sort auctionyear twpnum twpdir rgenum rgedir
save "calculations/DI_prod_by_township_past.dta", replace 
	

*** Compute for each auctionyear-township, production from wells spudded in 3 years post auction
forvalues y = 1974/2003 { // y represents auctionyear

	use "calculations/temp.dta", clear
	local y1 = `y' + 1
	local y4 = `y' + 4
	keep if missing(spuddate)==0 & spuddate>`y1'*10000 & spuddate<`y4'*10000
	
	* Total production by well-township
	collapse (sum) liquidbbl* gasmcf* , by(entityid twpnum twpdir rgenum rgedir)

	* BOE: barrel of oil equivalents
	gen boe = liquidbbl + gasmcf/6
	
	* Collapse to average production per well by township
	collapse (mean) boepw_ftr_ave=boe , by(twpnum twpdir rgenum rgedir)
	
	gen auctionyear=`y'	

	if `y'>1974 {
		append using "calculations/DI_prod_by_township_future.dta"
	}
	save "calculations/DI_prod_by_township_future.dta", replace 
}	
order auctionyear twpnum twpdir rgenum rgedir
sort auctionyear twpnum twpdir rgenum rgedir
save "calculations/DI_prod_by_township_future.dta", replace 
