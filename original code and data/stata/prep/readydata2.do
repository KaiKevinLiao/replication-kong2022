* Normalize bids relative to the predicted bid given covariates.

use "calculations/interimdata2.dta", clear

* Merge predicted bid components and quality index
merge m:1 tractnum using "calculations/Predicted_bid_leaveoneout.dta" 
keep if _m==3
drop _m

* Deviation from predicted bid- "demeaned" bid
gen roy_dm = royalty - e_roy
gen lncpad_dm = lntotalcashpad - e_lncpad

* scatter lncpad_dm roy_dm if numbids==2
* -> some outliers

* flag outliers given N==2 by 1.5*IQR rule
sum roy_dm if numbids==2, d
	local rp25 = r(p25)
	local rp75 = r(p75)
	local riqr = `rp75'-`rp25'
sum lncpad_dm if numbids==2, d
	local cp25 = r(p25)
	local cp75 = r(p75)
	local ciqr = `cp75'-`cp25'	
sort tractnum
quietly by tractnum : egen outlier = total(roy_dm>`rp75'+1.5*`riqr' | roy_dm<`rp25'-1.5*`riqr' ///
	| lncpad_dm>`cp75'+1.5*`ciqr' | lncpad_dm<`cp25'-1.5*`ciqr' )	

sort tractnum nobid
save "calculations/readydata.dta", replace
