* Compute the risk-free (treasury) REAL interest rate, continuously compounded.

	* Use 1 year treasury rates
	use "data/treasury_1y_monthly.dta", clear

	* Merge 1 year realized inflation %
	merge 1:1 year month using "calculations/pct_chg_gdpipd_1y.dta"
	keep if _m==3
	drop _merge

	* Real interest rate : on top of inflation.
	* Fisher Equation:
	gen r = (1 + treasury_1y_m/100)/(1 + pct_chg_gdpipd_1y) - 1

	* Convert to continuously compounded rate, as required by Black-Scholes.
	gen r_cc = ln(1+r)

	keep year month r_cc
	label variable r_cc "Risk-free (treasury) real interest rate, continuously compounded"
	save "calculations/r_cc.dta", replace


* Compute the risk-free (treasury) NOMINAL interest rate, continuously compounded.
	* Use 1 year treasury rates
	use "data/treasury_1y_monthly.dta", clear

	* Convert to continuously compounded rate, as required by Black.
	gen r_cc_nom = ln(1 + treasury_1y_m/100)

	keep year month r_cc_nom
	save "calculations/r_cc_nom.dta", replace
