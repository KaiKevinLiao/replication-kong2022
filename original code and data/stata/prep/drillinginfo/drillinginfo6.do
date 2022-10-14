* Merge production numbers to tractnumbers through township:
* (ii) Production from wells spudded in township during 3 years following auction

use "data/townships.dta", clear

* Flag tracts missing township info.
gen notmissingtwp = missing(twpnum)==0

* One row per tractnum township auctionyear
sort tractnum auctionyear notmissingtwp twpnum twpdir rgenum rgedir
quietly by tractnum auctionyear notmissingtwp twpnum twpdir rgenum rgedir : gen n=_n
keep if n==1
drop n

* Merge productivity data by township
	* wells spudded in 3 years following auction
	merge m:1 twpnum twpdir rgenum rgedir auctionyear using "calculations/DI_prod_by_township_future.dta"
	drop if _m==2
	
	replace boe=. if notmissingtwp==0 // if twp is missing
	replace boe=0 if notmissingtwp==1 & _m==1 // if twp not missing but no production record

* Collapse to tractnum for those leases that span >1 twp
collapse (mean) boepw_ftr_ave , by(tractnum)

* log
gen lnboepw_ftr_ave = ln(boepw_ftr_ave+1)

* Township production index
gen twp_prod_post = lnboepw_ftr_ave

keep tractnum twp_prod_post
label variable twp_prod_post "log production per well, spudded in lease's township during 3 years post auction"
save "calculations/twp_prod_post.dta", replace
