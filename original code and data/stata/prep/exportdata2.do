* Export data for estimating government choice probabilities

use "calculations/readydata.dta", clear
sort tractnum nobid
keep tractnum accbid royalty totalcashpa_d numbids index

* Create a column containing the winning bid.
quietly by tractnum : egen winningcash = total(totalcashpa_d*accbid)
quietly by tractnum : egen winningroy = total(royalty*accbid)
drop if winningcash==0 | winningroy==0

drop if accbid==1 // drop winning rows
drop accbid tractnum numbids

* Every row contains 1 winning, 1 losing bid from an auction.
rename royalty roy0
rename totalcashpa_d cash0
rename winningroy roy1
rename winningcash cash1

* Difference from the other bid
gen diffc1 = cash1 - cash0
gen diffr1 = roy1 - roy0
gen diffc0 = -diffc1
gen diffr0 = -diffr1
gen lndiffc1 = ln(cash1) - ln(cash0)
gen lndiffc0 = -lndiffc1

* Reshape long
gen n = _n
reshape long roy cash diffc diffr lndiffc, i(n) j(win)
gen oroy = roy - diffr // The other bid's royalty
gen ocash = cash - diffc // The other bid's cash

* Convert lndiffc and diffr to Quantiles
xtile dcn = lndiffc, nquantiles(499)
replace dcn = dcn/500
label variable dcn "Quantile of log difference from competing cash bid"

xtile drn = diffr, nquantiles(499)
replace drn = drn/500
label variable drn "Quantile of difference from competing royalty bid"

order win dcn drn diffc diffr lndiffc index
outsheet using "calculations/Data_for_gchoice.csv", comma replace
