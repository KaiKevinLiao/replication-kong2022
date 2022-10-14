* Generate additional variables

use "data/maindata.dta", clear

* ln(acreage) and log squared
gen lnacr = ln(advertisedacreage)
gen lnacr2 = lnacr^2

* Indicator for royalty recipient is a state agency other than the DNR
gen stateagency = tractkindcode=="4 - STATE AGENCY"

* Development = there is record of royalty income and/or completed well
gen develop = income==1 | well==1

* Variables used for merging purposes
gen year = auctionyear
gen month = auctionmonth
gen qtr = auctionqtr
gen yearmonth = auctionyear*100 + auctionmonth

* Merge quarterly GDP implicit price deflator, BEA. 2009=100.	
merge m:1 year qtr using "data/gdpipdeflatorQ.dta"
drop if _merge==2
drop _merge
label variable gdpipdeflatorq "GDP implicit price deflator, quarterly"

* Merge r_cc: 1 year risk-free real interest rate, continuously compounded.
merge m:1 year month using "calculations/r_cc.dta"
drop if _m==2
drop _m
	
	
* Deflate dollars by GDP implicit price deflator
foreach var of varlist cashbonus rentals wtim {
	gen `var'_d = `var'/gdpipdeflator*100 // 2009 dollars
}	

* bonus per acre
gen bonusperacre_d = cashbonus_d/acresbid
gen lnbonuspa_d = ln(bonusperacre_d+1)
	
* Total cash payment = bonus + rentals
gen totalcashpa_d = ( cashbonus_d + rentals_d*(exp(-r_cc*1) + exp(-r_cc*2)) )/advertisedacreage
gen lntotalcashpad = ln(totalcashpa_d)

save "calculations/interimdata1.dta", replace
