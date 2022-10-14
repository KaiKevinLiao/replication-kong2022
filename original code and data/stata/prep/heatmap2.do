* Create data file of townships and bids by tract number

use "calculations/interimdata1.dta", clear

* Get RESIDUAL of bids after controlling for auctionyear
xi: reg lnbonuspa_d i.auctionyear
predict lnbonuspad_res, resid
xi: reg royalty i.auctionyear
predict roy_res, resid

* Reshape bids wide by tract
keep tractnum numbids lnbonuspad_res roy_res auctionyear
sort tractnum
quietly by tractnum : gen num=_n
reshape wide lnbonuspad_res roy_res, i(tractnum auctionyear) j(num)
            
* Merge on the township list
merge 1:m tractnum using "calculations/twp_tractnum_list_num.dta"
keep if _m==3
drop _m

* Reshape bids long
reshape long lnbonuspad_res roy_res, i(tractnum township auctionyear) j(bidn)
drop if missing(roy_res)==1
drop if missing(lnbonuspad_res)==1

* Assign negative numbers for S direction township
gen twp = twpnum
replace twp = twpnum*-1 if twpdir=="S"
* Assign negative numbers for W direction range
gen rge = rgenum
replace rge = rgenum*-1 if rgedir=="W"
drop twpnum twpdir rgenum rgedir township

* Group by tractnum
egen tractid = group(tractnum)

keep tractid tractnum twp rge lnbonuspad_res roy_res numbids auctionyear
order tractid tractnum twp rge lnbonuspad_res roy_res numbids auctionyear
sort tractid twp rge lnbonuspad_res roy_res

save "calculations/Heatmap_township_tracts_bids.dta", replace

drop tractnum
* csv file for use in Matlab
outsheet using "calculations/Heatmap_township_tracts_bids.csv", comma replace

* Output tractid-tractnum table
use "calculations/Heatmap_township_tracts_bids.dta", clear
keep tractid tractnum
sort tractid
quietly by tractid : gen n = _n
keep if n==1
drop n
save "calculations/tractid_tractnum.dta", replace
