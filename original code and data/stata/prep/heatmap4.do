* Insheet results of heatmap surface fit.

clear
insheet using "calculations/Heatmap_time.csv", comma
rename v1 tractid
rename v2 twp
rename v3 rge
rename v4 surffit_lnb2
rename v5 surffit_r2

* Unique row per tractid-township (there were multiple rows per, due to multiple bids)
collapse (mean) surffit* , by(tractid twp rge)

* Then average by tractid (there were multiple townships a tract is associated with)
collapse (mean) surffit*, by(tractid)

* Reattach tractnum
merge 1:1 tractid using "calculations/tractid_tractnum.dta" // all merged
drop _m

order tractnum
label variable surffit_lnb2 "Heatmap cash index"
label variable surffit_r2 "Heatmap royalty index"
save "calculations/Heatmap_time.dta", replace
