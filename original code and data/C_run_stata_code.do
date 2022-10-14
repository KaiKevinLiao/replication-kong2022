* Run all stata code
timer clear 1
timer on 1

*** Change directory to the folder containing this file ***
cd "$rep"

* Heatmap index computation- continued
do "stata/prep/heatmap4.do"

* Merge auxiliary variables to main data
do "stata/prep/interimdata2.do"

* Prepare data for main analysis
do "stata/prep/readydata1.do"
do "stata/prep/readydata2.do"

* Export data to Matlab programs
do "stata/prep/exportdata1.do"
do "stata/prep/exportdata2.do"
do "stata/prep/exportdata3.do"
do "stata/prep/exportdata4.do"

* Produce tables 1, 3, A1
do "stata/tables/table1.do"
do "stata/tables/table3.do"
do "stata/tables/tableA1.do"

timer off 1
timer list 1
