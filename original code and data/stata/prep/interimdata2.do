* Merge auxiliary variables

use "calculations/interimdata1.dta", clear

* Merge implied volatility of front-month futures
merge m:1 tractnum using "calculations/tractnum_iv.dta"
drop if _m==2
drop _m

* Merge township production index
merge m:1 tractnum using "calculations/twp_idx_pre.dta"
drop if _m==2
drop _m

* Merge heatmap indices
merge m:1 tractnum using "calculations/Heatmap_time.dta"
drop if _m==2
drop _m

* Merge production per well from wells spudded in the lease's township during 
* the three years following its auction
merge m:1 tractnum using "calculations/twp_prod_post.dta"
drop if _m==2
drop _m

* Drop if township location of the tract could not be matched.
drop if missing(surffit_lnb2)==1 | missing(twp_idx_pre)==1

save "calculations/interimdata2.dta", replace
