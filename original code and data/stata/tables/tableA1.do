* Produce Table A1 of appendix

estimates clear
use "calculations/readydata.dta", clear

* count cumulative number of bids for each bidder
sort bidder
quietly by bidder : gen cumbids = _N
* define fringe bidder:
gen fringe = cumbids<=10

* Fraction of bids from fringe bidders
tab fringe // 76%
* Fraction of wins from fringe bidders
tab fringe if accbid==1 // 76%

* For 2 bidder auctions:
keep if numbids==2
	
sort tractnum // by auction,
quietly by tractnum : egen meanroy = mean(royalty) // compute mean royalty bid
quietly by tractnum : egen meanlncash = mean(lntotalcashpad) // compute mean log cash bid

gen relroy = (royalty - meanroy)*2 // difference from competing royalty bid
gen rellncash = (lntotalcash - meanlncash)*2 // log difference from competing cash bid
		
* generate interactions with oil price:	
gen rellncash_x_wti = rellncash*wtim_d
gen relroy_x_wti = relroy*wtim_d
	
* probit regressions
	* Table A1 column (1)
	probit accbid fringe rellncash relroy 
	estimates store reg1
	* Table A1 column (2)
	probit accbid fringe rellncash relroy rellncash_x_wti relroy_x_wti
	estimates store reg2
	
* Variable Labels
label variable accbid "win"
label variable fringe "fringe bidder"
label variable rellncash "log difference from competing bid's cash"
label variable relroy "difference from competing bid's royalty"
label variable rellncash_x_wti "log cash difference x oil price"
label variable relroy_x_wti "royalty difference x oil price"

esttab reg* ///
	using "output/TableA1.tex" ///
	, label se pr2 b(%6.3f) nostar ///
	replace
