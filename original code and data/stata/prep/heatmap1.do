* Create a list with PLSS townships in column 1, associated tractnums listed long in column 2.

use "data/townships.dta", clear
keep tractnum twpnum twpdir rgenum rgedir

* Drop if township location unknown
drop if missing(twpnum)
drop if missing(rgenum)
drop if twpnum==99 // there is no township number 99

* Generate one variable, "township", that identifies township and range
tostring twpnum rgenum, replace
replace twpnum = "0" + twpnum if length(twpnum)==1
replace rgenum = "0" + rgenum if length(rgenum)==1
gen township = twpnum+twpdir+rgenum+rgedir

* Drop duplicate rows
sort tractnum township
quietly by tractnum township : gen n = _n
keep if n==1
drop n

* Order and sort
order township tractnum
sort township tractnum
destring twpnum rgenum, replace
save "calculations/twp_tractnum_list_num.dta", replace

keep tractnum township
save "calculations/twp_tractnum_list.dta", replace
