* Merge production numbers to tractnumbers through township:
* (i) Production during 5 years preceding auction = township production index

use "data/townships.dta", clear

* Flag tracts missing township info.
gen notmissingtwp = missing(twpnum)==0

* One row per tractnum township auctionyear
sort tractnum auctionyear notmissingtwp twpnum twpdir rgenum rgedir
quietly by tractnum auctionyear notmissingtwp twpnum twpdir rgenum rgedir : gen n=_n
keep if n==1
drop n

* Merge productivity data by township
	* production preceding auction
	merge m:1 twpnum twpdir rgenum rgedir auctionyear using "calculations/DI_prod_by_township_past.dta"
	drop if _m==2
	
	replace boe=. if notmissingtwp==0 // if twp is missing
	replace boe=0 if notmissingtwp==1 & _m==1 // if twp not missing but no production record

* Collapse to tractnum, for those leases that span >1 twp
collapse (mean) boepw_past_ave , by(tractnum)

* log
gen lnboepw_past_ave = ln(boepw_past_ave+1)

* Township production index
gen twp_idx_pre = lnboepw_past_ave

keep tractnum twp_idx_pre
label variable twp_idx_pre "Township production index"
save "calculations/twp_idx_pre.dta", replace
