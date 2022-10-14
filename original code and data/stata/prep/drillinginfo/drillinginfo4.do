* From Drillinginfo production data, compute cumulative production per well 
* for each township appearing in auction data, for wells spudded in 1987-2006 
* = time frame of auction data + 3 years (lease duration)

use "calculations/LA_DI_Production_Time_Series.dta", clear

* Attach township-range info.
merge m:1 entityid using "calculations/DI_allwells_STR_final.dta"
drop if _m==2
drop _m
keep if missing(twpnum)==0 & missing(twpdir)==0 & missing(rgenum)==0 & missing(rgedir)==0	
keep entityid twpnum twpdir rgenum rgedir liquidbbl gasmcf

* Attach well dates to production time series data.
merge m:1 entityid using "calculations/DI_wells_entityid_dates.dta"
drop if _m==2
drop _m
* spuddate in 1987-2006
keep if missing(spuddate)==0 & spuddate>19870000 & spuddate<20070000

* Sum cumulative per well
collapse (sum) liquidbbl gasmcf , by(entityid twpnum twpdir rgenum rgedir)

* BOE: barrel of oil equivalents
gen boe = liquidbbl + gasmcf/6
	
* Now collapse to township average
collapse (mean) boepw_ave=boe , by(twpnum twpdir rgenum rgedir)
label variable boepw_ave "Average BOE produced per well spudded during 1987-2006"

* Save township-level average cumulative production
save "calculations/temp.dta", replace

* Get townships appearing in the auction data
use "data/townships.dta", clear

* Get unique townships
sort twpnum twpdir rgenum rgedir
quietly by twpnum twpdir rgenum rgedir : gen n=_n
keep if n==1
keep twpnum twpdir rgenum rgedir
drop if missing(twpnum)==1 | missing(rgenum)==1

* Merge above cumulative production by township
	merge m:1 twpnum twpdir rgenum rgedir using "calculations/temp.dta"
	keep if _m==3
	keep boepw_ave twpnum twpdir rgenum rgedir

* Summarize
sum boepw_ave, d

save "calculations/twp_aveprod_1987_2006.dta", replace
