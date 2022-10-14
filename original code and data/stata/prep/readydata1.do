* Leave-one-out regression of bid components on covariates.

use "calculations/interimdata2.dta", clear

* To be filled by predictions of leave-one-out regression:
gen e_lncpad = .
gen e_roy = .

sort tractnum nobid
local N = _N // Total rows

* Categories for number of bids. Some numbids don't have enough observations for separate fixed effects in leave-one-out regression.
gen numbidscat = numbids
replace numbidscat=5 if numbids>5

* For each auction, leave out own-auction bids from regression.

forvalues i = 1/`N' {
		disp `i'
		sort tractnum nobid
		
		* Cash
		quietly xi: reg lntotalcash wtim_d r_cc lnacr lnacr2 stateagency twp_idx_pre surffit_lnb2 i.auctionyear i.numbidscat ///
			if tractnum!=tractnum[`i']

		sort tractnum nobid
		quietly predict temp1 if tractnum==tractnum[`i']
		quietly replace e_lncpad=temp1 if tractnum==tractnum[`i']

		* Royalty
		quietly xi: reg royalty wtim_d r_cc lnacr lnacr2 stateagency twp_idx_pre surffit_r2 i.auctionyear i.numbidscat ///
			if tractnum!=tractnum[`i']

		sort tractnum nobid
		quietly predict temp2 if tractnum==tractnum[`i']
		quietly replace e_roy=temp2 if tractnum==tractnum[`i']
	
		drop temp1 temp2
}	
	
order tractnum nobid e_lncpad e_roy	
sort tractnum nobid
keep tractnum e_lncpad e_roy

gen e_cpad = exp(e_lncpad)

* One row per tractnumber
sort tractnum
quietly by tractnum : gen n = _n
keep if n==1
drop n

* Quality index: quantiles of predicted log cash bid
xtile index = e_lncpad, nquantiles(499)
replace index = index/500
label variable index "Quantile of E[ln(cash bid per acre)|covariates]"

save "calculations/Predicted_bid_leaveoneout.dta", replace
