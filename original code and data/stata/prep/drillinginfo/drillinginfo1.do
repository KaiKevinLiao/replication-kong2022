* Collapse Drillinginfo production data to well-year level.

/* Note: 
`productiondate' may also be called `monthlyproductiondate'
`liquidbbl' may also be called `monthlyoil'
`gasmcf' may also be called `monthlygas'
*/

* Insheet Drillinginfo "Producing Entity Monthly Production"
	clear
	insheet using "data/Producing Entity Monthly Production.csv", comma names
	
* Clean
	format apiuwi %14.0f
	replace productiondate = subinstr(productiondate,"-","",.)
	destring productiondate, replace
	replace gasmcf = "" if gasmcf=="NA"
	destring gasmcf, replace
	replace liquidbbl = "" if liquidbbl=="NA"
	destring liquidbbl, replace
	
* Collapse to well-year	level
	gen prodyear = floor(productiondate/10000)
	collapse (sum) liquidbbl gasmcf , by(entityid prodyear)
	
save "calculations/LA_DI_Production_Time_Series.dta", replace
