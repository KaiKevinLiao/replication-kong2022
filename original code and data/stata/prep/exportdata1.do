* Export data for kernel density estimation of bids in 2-bidder auctions.

use "calculations/readydata.dta", clear

* This data will be used to compute the kernel density of bids in 2-bidder auctions.
keep if numbids==2
sort tractnum nobid
keep lncpad_dm roy_dm accbid
order roy_dm lncpad_dm accbid

outsheet using "calculations/Data_for_kdensity.csv", comma replace
