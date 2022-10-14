* Obtain front-month implied volatility from 3-month iv using the 
* term structure of realized volatility
clear

* Insheet 3-month implied volatility computed by Matlab
	insheet using "calculations/impliedvol_m3.csv", comma
		rename v1 year 
		rename v2 month 
		rename v3 maturity 
		rename v4 S 
		rename v5 F 
		rename v6 r 
		rename v7 V 
		rename v8 iv

	keep year month iv
	replace iv = "." if iv=="NaN"
	destring iv, replace
	
	* Compute median for each month
	collapse (median) ivd3=iv , by(year month)	
	save "calculations/impliedvol_m3.dta", replace

* Apply the term structure of realized volatility
	clear
	insheet using "calculations/realizedvol_term_structure.csv", comma names

	* Transpose
	xpose, clear
	drop if _n==1 // blank row
	* Extract maturity fixed effect of 3-month maturity (relative to front month) on realized volatility 
	keep v2
	rename v2 _imaturity_3
	* Dates
	gen month = mod(_n-1,12)+1
	gen year = 1986 + floor((_n-1)/12)

	* Merge implied volatility computed from 3-month options
	merge 1:1 year month using "calculations/impliedvol_m3.dta"
	drop if _m==2
	drop _m

	* Compute IV for front-month options using term structure
	gen iv = ivd3*exp(0 - _imaturity_3)
	label variable iv "Implied volatility"

	drop if missing(iv)==1
	keep year month iv
	save "calculations/impliedvol.dta", replace

* Merge implied volatility to tract numbers
	use "data/maindata.dta", clear
	gen year = auctionyear
	gen month = auctionmonth
	merge m:1 year month using "calculations/impliedvol.dta" 
	keep if _m==3 // Note: implied volatility is only available from November 1986.
	drop _m
	keep tractnum iv
	* Keep one row per tract number
	sort tractnum
	quietly by tractnum : gen n=_n
	keep if n==1
	drop n

save "calculations/tractnum_iv.dta", replace
