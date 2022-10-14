* Export data to Matlab for win/loss scatterplot

use "calculations/readydata.dta", clear
keep tractnum accbid royalty totalcashpa_d numbids 

* Create a column containing the winning bid.
sort tractnum
quietly by tractnum : egen winningcash = total(totalcashpa_d*accbid)
quietly by tractnum : egen winningroy = total(royalty*accbid)

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

* Reshape long
gen n = _n
reshape long roy cash diffc diffr lndiffc, i(n) j(win)

sort n win
keep win diffr diffc
order win diffr diffc
outsheet using "calculations/scatter_win_loss.csv", comma replace
