* Generate Table 3

use "calculations/readydata.dta", clear

* Regress cash on observable characteristics
xi: reg lntotalcash wtim_d r_cc lnacr lnacr2 stateagency twp_idx_pre surffit_lnb2 i.auctionyear i.numbids 
estimates store reg1
predict resid_b, residuals
testparm _Inumbids*

* Regress royalty on observable characteristics
xi: reg royalty wtim_d r_cc lnacr lnacr2 stateagency twp_idx_pre surffit_r2 i.auctionyear i.numbids 
estimates store reg2
predict resid_a, residuals
testparm _Inumbids*
 
* Variable Labels
label variable surffit_lnb2 "Heatmap log Cash Index"
label variable surffit_r2 "Heatmap Royalty Index"
label variable twp_idx_pre "Township Production Index"
label variable wtim_d "Oil Price"
label variable r_cc "Interest Rate"
label variable lnacr "log(acreage)"
label variable lnacr2 "log(acreage)$^2$"
label variable stateagency "Royalty Recipient not DNR"
label variable lntotalcash "log(cash per acre)"
label variable royalty "royalty"

esttab reg* ///
	using "output/Table3.tex" ///
	, label se b(%6.3f) nostar r2 ar2 ///
	drop(_Iauctionye* _Inumbid*) ///
	replace

* Correlation between bid-component residuals within bidder
corr resid_a resid_b
