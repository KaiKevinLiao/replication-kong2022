* Prepare option dataset for computing implied volatility
* Use 3-month maturity options

	use "calculations/CME_LO_with_maturity.dta", clear

	* 3-month maturity call options.
	keep if maturity==3
	keep if putcall=="C" // call options
	* Keep necessary variables
	keep tradeyear trademonth tradeday maturity strikeprice settlement 
	rename tradeyear year
	rename trademonth month
	rename tradeday day
	rename settlement optionprice

	* Oil 3-month futures prices, daily
	merge m:1 year month day using "calculations/quandl/CHRIS-CME_CL3.dta"
	keep if _m==3
	drop _m

	* Risk-free nominal interest rate. Monthly is the highest frequency available.
	merge m:1 year month using "calculations/r_cc_nom.dta"
	keep if _m==3
	drop _m

	* Price does not make sense if:
	* V < exp(-rt)*(F-S)
	drop if optionprice < exp(-r_cc*maturity/12)*(CL3-strikeprice)
	* V > F
	drop if optionprice > CL3

	keep year month maturity strikeprice CL3 r_cc_nom optionprice
	order year month maturity strikeprice CL3 r_cc_nom optionprice

	save "calculations/option_data_for_impliedvol_m3.dta", replace
	outsheet using "calculations/option_data_for_impliedvol_m3.csv", comma replace
