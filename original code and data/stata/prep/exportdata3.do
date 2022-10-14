* Export data for estimation of type distribution

use "calculations/readydata.dta", clear

* Need implied volatilities for type estimation. Only available for 1987+
keep if auctionyear>=1987

* Estimate for N==2 auctions
keep if numbids==2
drop if outlier>0 
	
* Drop variables not used
drop saledate month auctionqtr gdpipdeflator bidder acresbid ///
	cashbonus bonusperacre cashbonus_d tractkindcode 
	
* Summarize
sum roy_dm, d
	local sdr = r(sd)
	local maxr = r(max)
	local minr = r(min)
sum lncpad_dm, d
	local sdc = r(sd)
	local maxc = r(max)
	local minc = r(min)
	
* Silverman's=Scott's rule bandwidths, dimension=2
local hr = `sdr'*_N^(-1/6)
local hc = `sdc'*_N^(-1/6)	
disp `hr'
disp `hc'
	
* Trim boundaries per GPV(2000) and Li Perrigne Vuong (2000).
gen totrim = lncpad_dm>`maxc'-`hc' | lncpad_dm<`minc'+`hc' | roy_dm>`maxr'-`hr' | roy_dm<`minr'+`hr'
keep if totrim==0
* count bids left per auction
sort tractnum
quietly by tractnum : gen nb = _N

* Data for export
gsort -nb tractnum nobid
gen rowid = _n
order accbid roy_dm lncpad_dm royalty totalcashpa_d ///
	e_roy e_lncpad wtim_d r_cc primaryterm ///
	auctionyear iv develop stateagency rowid ///
	advertisedacreage index nb
save "calculations/Data_for_theta_est.dta", replace
drop tractnum // drop string variables
outsheet using "calculations/Data_for_theta_est.csv", comma replace
