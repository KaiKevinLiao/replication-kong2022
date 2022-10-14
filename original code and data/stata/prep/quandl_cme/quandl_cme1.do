* Insheet crude oil futures prices.

clear

forvalues m = 1/36 {
	insheet using "data/quandl/CHRIS-CME_CL`m'.csv", clear
		split date, p("-")
		destring date1 date2 date3, replace
		rename date1 year
		rename date2 month
		rename date3 day
		keep year month day date settle
		order year month day date settle
		sort year month day
		rename settle CL`m'
	save "calculations/quandl/CHRIS-CME_CL`m'.dta", replace
}

* Append data on crude oil futures prices of all maturities.
use "calculations/quandl/CHRIS-CME_CL1.dta", clear
forvalues m = 2/36 {
	merge 1:1 year month day using "calculations/quandl/CHRIS-CME_CL`m'.dta"
	drop _m
}
save "calculations/CL1_through_36_daily.dta", replace

keep date CL*
order date
outsheet using "calculations/CL1_through_36_daily.csv", comma replace
