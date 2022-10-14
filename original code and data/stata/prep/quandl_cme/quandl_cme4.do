* Insheet all CME data into one .dta file.

* The raw data comes in .gz files. First, extract them to .csv files in the 
* data/cme folder.

* Insheet all the .csv files in the folder data/cme.
cd "data/cme"
local files : dir "data/cme" files "*.csv"
local i = 0
foreach file in `files' {
	local i = `i' + 1
	insheet using "`file'", comma clear
	if `i'>1 {
		append using "calculations/CME_LO.dta"
	}
	save "calculations/CME_LO.dta", replace
}
