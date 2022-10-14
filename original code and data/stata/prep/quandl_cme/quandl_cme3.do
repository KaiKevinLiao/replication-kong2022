* Regression to obtain term structure of ln(realized volatility) of oil futures

clear
estimates clear
insheet using "calculations/CL_realizedvol.csv", comma names

rename index date
sort date
gen date2 = _n // Numerical representation of date.

reshape long cl, i(date) j(maturity)
rename cl rvol

* Replace "NA" with "."
replace rvol="." if rvol=="NA"
destring rvol, replace

* Treat date as the "entity", maturity as "time"  
xtset date2 maturity

* Extract year
gen year = substr(date,1,4)
gen month = substr(date,6,2)
destring year month, replace

* Fixed effects regression. fe takes care of date fixed effects
gen lnrvol = ln(rvol)
gen mdiff = .
forvalues y = 1986/2003 {
	forvalues mo = 1/12 {
		replace mdiff = (`y'-year)*12 + `mo'-month
		eststo: xi: xtreg lnrvol i.maturity if abs(mdiff)<=6, fe
	}
}
* Export results
esttab using "calculations/realizedvol_term_structure.csv", keep(_Imaturity*) nogaps not nocons nonote nodep nomti nonum nostar plain replace
