*Convert menu data excel to dta for merging

import excel "$Data/Menu_ghg nutri Ofcom_FINAL.xlsx", firstrow clear

rename MenuItemNumber menu_item

distinct menu_item

*Need to remove empty rows otherwise can't merge it
drop if menu_item==.

save "$Data/Menu data ofcom.dta", replace

///////////////

*Import the Qualtrics data from the Excel, with option to keep the first row as variable names

import excel "$Data/Foods Go Green RCT.xlsx", sheet("Sheet0") firstrow clear 

*Destring numeric variables
destring *, replace

*Decode missing values (-99) to use system missing
mvdecode *, mv(-99)

*Drop participants who did not consent
tab consent, mi
drop if consent==0

*Drop participants who are too young and age is missing
tab age, mi
drop if age < 18
drop if age==.

*Label ecolabels variable
label define ecolabel_lbl 1 "treatment" 2 "control"
label values ecolabel ecolabel_lbl

*Drop people with no outcome data
forval x=1/37 {
	gen selected_T_`x'=1 if selection_T_`x'=="On"
	replace selected_T_`x'=0 if selection_T_`x'=="Off"

	gen selected_C_`x'=1 if selection_C_`x'=="On"
	replace selected_C_`x'=0 if selection_C_`x'=="Off"
}
egen totalselections_T = rowtotal(selected_T_1-selected_T_37) if ecolabel==1
egen totalselections_C = rowtotal(selected_C_1-selected_C_37) if ecolabel==2

gen totalselections_merged = totalselections_T if ecolabel==1
replace totalselections_merged=totalselections_C if ecolabel==2

drop totalselections_T totalselections_C

tab totalselections_merged, mi
drop if totalselections_merged==0

drop totalselections_merged 
drop selected_T_1-selected_C_37

*Drop people who completed the survey implausibly quickly (defined as <1/3 of the median completion time).
summarize Durationinseconds, detail 
scalar median = r(p50) 
gen toofast = median/3
di toofast
count if Durationinseconds <toofast
drop if Durationinseconds <toofast

*Create numeric id
gen pid = _n

**#Demographics

*****
*Recode age
*****
recode age (0/17 = 0) (18/29 = 1) (30/44 = 2) (45/59 = 3) (60/115 = 4) , generate(agecat)
label define agelabels 0 "0-17" 1 "18-29 years" 2 "30-44 years" 3 "45-59 years" 4 "60-115 years"
label values agecat agelabels
tab agecat, mi 

*create young adult variable for moderation analyses
gen youngadult =.
replace youngadult =1 if age >= 18 & age <=29
replace youngadult =0 if age <18 | age >29
label define youngadultslabels 1 "youngadult" 0 "notyoungadult" 
label values youngadult youngadultslabels
tab youngadult, mi

*****
*Recode gender
*****
recode gender ("1" = 1) ("2" = 2) ("3" = 3) ("4" = 3) , generate(gendercat)
label define genderlabels 1 "Female" 2 "Male" 3 "Non-binary or another gender" 
label values gendercat genderlabels
tab gendercat, mi

**Create gender category with females and males only for moderation analyses
gen female =.
replace female =1 if gender ==1
replace female =0 if gender ==2
label define femalelabels 1 "Female" 0 "Male" 
label values female femalelabels
tab female, mi

*****
*Recode race
*****

/* Original codes (Check all that apply)
1= American Indian or Alaska Native 
2=Asian 
3=Black or African American 
4=Hispanic, Latino, or Spanish origin
5=Middle Eastern or North African
6=Native Hawaiian or other Pacific Islander
7=White
8=Some other race or ethnicity (please specify):____
*/

*Count total races marked
*To replace those who marked more than 1 race as "other or mutliracial"
egen totalraces = rowtotal(raceeth_1 raceeth_2 raceeth_3 raceeth_4 raceeth_5 raceeth_6 raceeth_7 raceeth_8)
tab totalraces, mi

gen racecat = .
*Single selection
foreach f of numlist 1 3 4 5 7 {
	replace racecat = `f' if raceeth_`f'==1 & totalraces==1 //selected one race
	}
	
*Other or Multiracial
	replace racecat = 20 if totalraces >1 //selected more than one
	replace racecat = 20 if raceeth_8==1 & totalraces==1	
	
*AAPI group
	replace racecat = 2 if raceeth_2==1 & totalraces==1 //selected only Asian
	replace racecat = 2 if raceeth_6==1 & totalraces==1 //selected only NatHI,PI
	replace racecat = 2 if raceeth_2==1 & raceeth_6==1 & totalraces==2 //selected both

*Clean textbox responses
	replace racecat = 1 if raceeth_8_TEXT=="Indigenous American" & totalraces==1 

*Any Hispanic, regardless of number of races
replace racecat = 4 if raceeth_4==1 
	
	label define racecatlabels 1 "Amer Ind Alas Native" 2 "Asian, Native Hawaiian or Pacific Islander" 3 "Black" 4 "Hispanic" 5 "Middle Eastern or North African" 7 "White" 20 "Another race or multi-racial"
	label values racecat racecatlabels

	tab racecat, mi
	
*****
*Recode education
*****
recode educ ("1"=1) ("2"=1) ("3"=2) ("4"=3) ("5"=3) ("6"=4), generate(educcat)
label define educlabels 1 "High school diploma or less" 2 "Some college" 3 "College graduate or associates degree" 4 "Graduate degree"
label values educcat educlabels
tab educcat

*****
*Recode income
*****
recode income_10cat (1/3 = 1) (4/5 = 2) (6 = 3) (7/10 =4) , generate(income4cat)
label define incomelabel 1 "$0 to $24,999" 2 "$25,000 to $49,999" 3 "$50,000 to $74,999" 4 "$75,000 or more"
label values income4cat incomelabel
tab income4cat

*****
*Recode household size
*****
recode hhsize_num (1/2 =1) (3/4=2) (5/20=3), generate(hhsizenumcat)
label define hhsizenumlabels 1 "1-2" 2 "3-4" 3 "5 or more"
label values hhsizenumcat hhsizenumlabels
tab hhsizenumcat

*****
*Recode children in household
*****
recode childrennum (0=1) (1/2=2) (3/15=3), generate(childrennumcat)
label define childrennumlabels 1 "0" 2 "1-2" 3 "3 or more"
label values childrennumcat childrennumlabels
tab childrennumcat

*****
*recode party ID
*****
recode partyid ("1" =1) ("2"=1) ("3"=1) ("4"=2) ("5"=2) ("6"=2) ("7"=3) ("8"=4), generate(partyidcat)
label define partyidlabels 1 "Democrat" 2 "Republican" 3 "Independent" 4 "Other"
label values partyidcat partyidlabels
tab partyidcat

****Green Scale Score
egen greenscale_avg = rowmean (green_products green_consider green_habits green_wasting green_responsible green_inconven)
sort ecolabel
by ecolabel: sum greenscale_avg

****Reactions to the eco-label
/*Dichotomize responses into agree (scores 4 or 5) vs. disagree or neutral (scores 1-3)
•	Liking of the eco-label
•	Wanting to see the eco-label on restaurant menus
•	Label helpfulness in choosing more environmentally sustainable foods
•	Perceptions of control over making sustainable eating decisions
*/

*Rename the control variable to avoid confusion with treatment status
rename control perceptcontrol

foreach var in accept_like accept_want accept_help perceptcontrol{
	recode `var' (1/3 = 0) (4/5 = 1), gen(`var'cat)
}

foreach var in accept_like accept_want accept_help perceptcontrol{
tab `var'cat, mi
}

*fix typo in var name (needs to be uppercase T to match others)
rename ptaste_s_t12 ptaste_s_T12 

*Perceived sustainability, healthfulness, and taste
foreach factor in health taste sustain { 
	gen p`factor'_s_merged = .
	gen p`factor'_u_merged = . 
	
	forval x=1/13 {
		
			replace p`factor'_s_merged = p`factor'_s_T`x' if ecolabel==1 & p`factor'_s_T`x'!=. 
			replace p`factor'_s_merged = p`factor'_s_C`x' if ecolabel==2 & p`factor'_s_C`x'!=.
		
			replace p`factor'_u_merged = p`factor'_u_`x' if p`factor'_u_`x'!=. 	
	}
}

*drop intermediate variables
drop phealth_s_T*
drop ptaste_s_T*
drop psustain_s_T*
drop phealth_s_C*
drop ptaste_s_C*
drop psustain_s_C*
drop phealth_u_1 phealth_u_2 phealth_u_3 phealth_u_4 phealth_u_5 phealth_u_6 phealth_u_7 phealth_u_8 phealth_u_9 phealth_u_10 phealth_u_11 phealth_u_12 phealth_u_13
drop ptaste_u_1 ptaste_u_2 ptaste_u_3 ptaste_u_4 ptaste_u_5 ptaste_u_6 ptaste_u_7 ptaste_u_8 ptaste_u_9 ptaste_u_10 ptaste_u_11 ptaste_u_12 ptaste_u_13
drop psustain_u_1 psustain_u_2 psustain_u_3 psustain_u_4 psustain_u_5 psustain_u_6 psustain_u_7 psustain_u_8 psustain_u_9 psustain_u_10 psustain_u_11 psustain_u_12 psustain_u_13


****Arm
*Original - 1: treatment, 2: control
*Change control from 2 to 0

gen arm=.
	replace arm=0 if ecolabel==2 //control
	replace arm=1 if ecolabel==1 //ecolabel
	
label define armlab 0 "control" 1 "ecolabel"
label values arm armlab

gen treat = .
replace treat = 1 if arm==1
replace treat = 0 if arm==0

*create a variable for control for use in calculating Cohen's d
gen control=1 if arm==0
replace control=0 if arm==1
tab control arm

*Save cleaned dataset
save "$Data/FGGRCT_clean_wide_intermediate.dta", replace


************************
**#Merge survey data with menu item characteristic data
************************

use "$Data/FGGRCT_clean_wide_intermediate.dta", clear

*Collapse selection_T_X with selection_C_X
*Reshape to long
*Merge each menu item with menu dataset

*Collapse selection_T_X with selection_C_X
forval f=1/37{
	gen selection`f' = ""
		replace selection`f' = selection_C_`f' if arm==0
		replace selection`f' = selection_T_`f' if arm==1
}

drop selection_T_1-selection_C_37

*Reshape to long
reshape long selection, i(pid) j(menu_item)

*Merge with menu data on menu_item
merge m:1 menu_item using "$Data/Menu data ofcom.dta"

************************************************
*Create derived selection variables
************************************************

*Convert selection to numeric by creating a new numeric variable "selected"
gen selected=1 if selection=="On"
replace selected=0 if selection=="Off"

*Drop rows of items not selected
drop if selected==0

*Create variable for entree or appetizer
gen entreeapp=.
	replace entreeapp=1 if Group=="Appetizers" | Group=="Burgers & Sandwiches" | Group=="Fajitas & Quesadillas" | Group=="Grill & BBQ" | Group=="Pasta & Bowls" | Group=="Salads & Soups"
	replace entreeapp=0 if Group=="Beverages" | Group=="Desserts"
	
	//check
	tab entreeapp Group
	mdesc entreeapp
	
*Create variables for type of item (entree/app, dessert, bev) to look at # items bought in each category

gen dessert = .
	replace dessert = 1 if Group=="Desserts"
	replace dessert = 0 if Group=="Appetizers" | Group=="Burgers & Sandwiches" | Group=="Fajitas & Quesadillas" | Group=="Grill & BBQ" | Group=="Pasta & Bowls" | Group=="Salads & Soups" | Group=="Beverages"
	
gen beverage = .
	replace beverage = 1 if Group=="Beverages"
	replace beverage = 0 if Group=="Appetizers" | Group=="Burgers & Sandwiches" | Group=="Fajitas & Quesadillas" | Group=="Grill & BBQ" | Group=="Pasta & Bowls" | Group=="Salads & Soups" | Group=="Desserts"


*Convert densities per 100 grams into totals per item
foreach dv in kJ Sod Sat Sugar Fiber Prot {
	gen `dv'item = `dv'100 * (g/100)
}

*convert kJ to kcal 
gen kcalitem = kJitem * 0.239006

*Create variable for total items selected by each participant
bysort pid: egen totalitems = total(selected)
tab totalitems, miss //should be 1-4 with no missing

*Create a variable for total entrees/apps selected
egen totalentrees = total(selected * (entreeapp == 1)), by(pid)

*Create variables for total GHG and nutrients selected overall and from entrees/appetizers
foreach dv in kcal Sod Sat Sugar Fiber Prot ghgper {
	egen total_`dv'_overall = total (`dv'item * selected), by(pid)
	egen total_`dv'_entree = total (`dv'item * selected * (entreeapp==1)), by(pid)
}

rename total_ghgper_overall total_ghg_overall
rename total_ghgper_entree total_ghg_entree

	//check that total is always more or equal to entree
	foreach dv in kcal Sod Sat Sugar Fiber Prot ghg {
		assert total_`dv'_overall >= total_`dv'_entree
	}
	
*Create average Ofcom score across all items and across entrees/appetizers 
egen unwtd_avg_ofcom_overall = mean(Ofcom_adj), by(pid)
bysort pid: egen unwtd_avg_ofcom_entree_temp = mean(Ofcom_adj) if entreeapp==1

*Create weighted average Ofcom scores across all items and across entrees/appetizers
	* Total weighted sum and total weights by pid
	gen wgtscore = Ofcom_adj * g
	egen sum_wgtscore_overall = total(wgtscore), by(pid)
	egen sum_weight_overall = total(g), by(pid)

	* Weighted average
	gen avg_ofcom_overall = sum_wgtscore_overall / sum_weight_overall

	* Generate weighted score only for entrees/appetizers
	gen wgtscore_entree = Ofcom_adj * g if entreeapp == 1
	gen g_entree = g if entreeapp == 1

	egen sum_wgtscore_entree = total(wgtscore_entree), by(pid)
	egen sum_weight_entree = total(g_entree), by(pid)

	*Weighted average
	gen avg_ofcom_entree = sum_wgtscore_entree / sum_weight_entree


*Create variables for total items, entrees/apps, beverages, and desserts selected
egen ttl_entreeapp = total(selected * (entreeapp==1)), by(pid)
egen ttl_beverage = total(selected * (beverage==1)), by(pid)
egen ttl_dessert = total(selected * (dessert==1)), by(pid)

egen ttl_items = total(selected), by(pid)

*Create variables for total healthy items selected 
gen item_healthy = 1 if healthy=="Healthier"
replace item_healthy=0 if healthy=="Unhealthier"
egen ttl_healthy = total(selected * (item_healthy==1)), by(pid)

gen prop_healthy = ttl_healthy / ttl_items

*Save cleaned dataset
save "$Data/FGGRCT_clean_long.dta", replace


*Collapse back to a wide dataset - only need 1 row per participant
duplicates drop pid, force

*Save cleaned dataset 
save "$Data/FGGRCT_clean_wide.dta", replace 

