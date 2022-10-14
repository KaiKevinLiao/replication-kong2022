* Run all stata code
timer clear 1
timer on 1

*** Change directory to the folder containing this file ***
cd "$rep"

* Prepare auxiliary variables
* Risk-free (treasury) real interest rate, continuously compounded
do "stata/prep/r_cc1.do"
do "stata/prep/r_cc2.do"

	/* Code for deriving variables from Drillinginfo production data (data not provided):
	do "stata/prep/drillinginfo/drillinginfo1.do"
	do "stata/prep/drillinginfo/drillinginfo2.do"
	do "stata/prep/drillinginfo/drillinginfo3.do"
	do "stata/prep/drillinginfo/drillinginfo4.do"
	do "stata/prep/drillinginfo/drillinginfo5.do"
	do "stata/prep/drillinginfo/drillinginfo6.do"
	* Output from above that are necessary for subsequent steps (provided):
	* "calculations/twp_idx_pre.dta"
	* "calculations/twp_prod_post.dta"
	*/

	/* Code for deriving variables from Quandl and CME data (data not provided):
	do "stata/prep/quandl_cme/quandl_cme1.do"
	* Then in R, run "R/quandl_cme2.R" 
	do "stata/prep/quandl_cme/quandl_cme3.do"
	do "stata/prep/quandl_cme/quandl_cme4.do"
	do "stata/prep/quandl_cme/quandl_cme5.do"
	do "stata/prep/quandl_cme/quandl_cme6.do"
	* In MATLAB, run "matlab/quandl_cme7.m"
	do "stata/prep/quandl_cme/quandl_cme8.do"
	* Output from above that are necessary for subsequent steps (provided):
	* "calculations/tractnum_iv.dta"
	*/

* Merge and generate additional variables
do "stata/prep/interimdata1.do"

* Compute heatmap index
do "stata/prep/heatmap1.do"
do "stata/prep/heatmap2.do"

* Next: In MATLAB, run "matlab/B_heatmap3.m"

timer off 1
timer list 1
