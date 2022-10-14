* Generate Table 1

use "calculations/readydata.dta", clear

count
sort tractnum
quietly by tractnum : gen n = _n
tab numbids if n==1 // 568 auctions
corr royalty lntotal
keep royalty totalcashpa_d advertised numbids lntotal
order lntotal royalty numbids

* Export data for scatterplot in Matlab
outsheet using "calculations/summary_and_scatter.csv", comma replace

* Summary stats - Table 1, rows 1 and 2
	keep royalty totalcashpa_d
	order totalcashpa_d royalty
	outreg2 using "output/Table1a", ///
		replace sum(detail) excel eqkeep(mean p10 p25 p50 p75 p90)

* Summary stats - Table 1, rows 3 and 4
	use "calculations/readydata.dta", clear
	sort tractnum
	quietly by tractnum : gen n = _n
	keep if n==1 // keep one row per auction
	keep numbids advertised 
	order numbids advertised 
	outreg2 using "output/Table1b", ///
		replace sum(detail) excel eqkeep(mean p10 p25 p50 p75 p90)
