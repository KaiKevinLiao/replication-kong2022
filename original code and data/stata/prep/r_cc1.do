* For any given time, compute the realized inflation rate over the next 1 year as
* inflation % = (gdpipdeflator 1 year from today - gdpipdeflator today)/gdpipdeflator today

use "data/gdpipdeflatorQ.dta", clear

* Assign quarterly GDP deflators to months.
* Generate 3 months per quarter
rename gdpipdeflatorq gdpipdeflatorm1
gen gdpipdeflatorm2 = gdpipdeflatorm1
gen gdpipdeflatorm3 = gdpipdeflatorm1
reshape long gdpipdeflatorm, i(year qtr) j(month)

* correctly define months
replace month = (qtr-1)*3+month

* inflation % = (gdpipdeflator 1 year from today - gdpipdeflator today)/gdpipdeflator today
gen pct_chg_gdpipd_1y = .
local N = _N
forvalues i = 1/`N'{
	replace pct_chg_gdpipd_1y = ( gdpipdeflatorm[`i'+12]-gdpipdeflatorm[`i'] )/gdpipdeflatorm[`i'] in `i'
}

keep year qtr month pct_chg_gdpipd_1y
save "calculations/pct_chg_gdpipd_1y.dta", replace
