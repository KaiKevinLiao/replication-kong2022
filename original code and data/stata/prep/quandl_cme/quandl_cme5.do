* Clean CME data.

use "calculations/CME_LO.dta", clear

* Extract trade year, month, day
tostring tradedate, replace
gen tradeyear = substr(tradedate,1,4)
gen trademonth = substr(tradedate,5,2)
gen tradeday = substr(tradedate,7,2)
destring trade*, replace

* Compute maturity of option in months
gen maturity = (contractyear-tradeyear)*12 + (contractmonth-trademonth) // in months

order trade* maturity
save "calculations/CME_LO_with_maturity.dta", replace
