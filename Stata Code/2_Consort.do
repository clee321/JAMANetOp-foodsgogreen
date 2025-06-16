*Import the Qualtrics data from the Excel, with option to keep the first row as variable names

import excel "$Data/Foods Go Green RCT.xlsx", firstrow clear

mvdecode *, mv(-99)

destring *, replace

*Create a PID
gen pid=_n

*Clicked hyperlink to start survey
count 

*Count if excluded because did not consent
count if consent!=1

*Drop if did not consent
drop if consent!=1

*Count if excluded because never began survey (age, first question, is missing)
count if age==.

*Drop if age is missing
drop if age==. 

*Count if age<18
count if age<18
drop if age<18

*Count number excluded because not randomized in experiment
count if ecolabel==.

*Drop those not randomized
drop if ecolabel==.

*Count total number randomized
count 

*Count number randomized in each arm
label define armlab 2 "control" 1 "ecolabel"
label values ecolabel armlab
count if ecolabel==1
count if ecolabel==2

*Count number who should be excluded from each total for each reason and overall/total 
//present in order used in paper: control, ecolabel
*Following order in dataprep

*A) Didn't finish = did not complete menu selection task
	forval x=1/37 {
		gen selected_T_`x'=1 if selection_T_`x'=="On"
		replace selected_T_`x'=0 if selection_T_`x'=="Off"

		gen selected_C_`x'=1 if selection_C_`x'=="On"
		replace selected_C_`x'=0 if selection_C_`x'=="Off"
	}

	egen totalselections_T = rowtotal(selected_T_1-selected_T_37) if ecolabel==1
	egen totalselections_C = rowtotal(selected_C_1-selected_C_37) if ecolabel==2

	gen totalselections_merged = totalselections_T if ecolabel==1
	replace totalselections_merged = totalselections_C if ecolabel==2

	drop totalselections_T totalselections_C

count if totalselections==0 & ecolabel==1
count if totalselections==0 & ecolabel==2

	drop selected_T_1-selected_C_37


*No outcome
foreach cond in  1  2 {
	di "ecolabel 1 is treatment and 2 is control"
	di "ecolabel is `cond'"
	count if totalselections==0 & ecolabel==`cond'
	local nooutcomedata=r(N)
	di "No outcome data is `nooutcomedata'"
}

drop if totalselections==0

*B) Completed the survey too fast
summarize Durationinseconds, detail 
scalar median = r(p50) 
gen toofast = median/3
di toofast
count if Durationinseconds <toofast

foreach cond in  1  2 {
	di "ecolabel 1 is treatment and 2 is control"
	di "ecolabel is `cond'"
	count if Durationinseconds < toofast & totalselections!=0 & ecolabel==`cond'
	local toofast=r(N)
	di "Too fast is `toofast'"
}

drop if Durationinseconds < toofast

*Count number remaining for analyses in each condition
foreach cond in  1  2 {
	di "ecolabel 1 is treatment and 2 is control"
	di "ecolabel is `cond'"
	count if ecolabel==`cond'
}




