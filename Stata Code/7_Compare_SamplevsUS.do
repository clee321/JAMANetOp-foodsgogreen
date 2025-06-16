**********Compare Sample to US Population**********

*First, prepare US data so that demographic categories match ours 
*Bring in PUMS 2023 ACS 1-year data

/*
*Note: PUMS data were downloaded from the PUMS websites via FTP
*URL: https://www2.census.gov/programs-surveys/acs/data/pums/2023/1-Year/
*Then select csv_pus.zip
*These data can be uploaded locally to run this do file (Replace yyy with the applicable folder location)

*part a
import delimited "/yyy/PUMS/2023 ACS PUMS 1-year/psam_pusa.csv", clear
save "/yyy/PUMS/2023 ACS PUMS 1-year/PUMS2023_a.dta", replace

*part b
import delimited "/yyy/PUMS/2023 ACS PUMS 1-year/psam_pusb.csv", clear

*Append a to b
append using "/yyy/PUMS/2023 ACS PUMS 1-year/PUMS2023_a.dta"

save "/yyy/PUMS/2023 ACS PUMS 1-year/PUMS2023_appended.dta"

*remove intermediate files 
rm "/yyy/PUMS/2023 ACS PUMS 1-year/PUMS2023_a.dta"
*/

use "/yyy/PUMS/2023 ACS PUMS 1-year/PUMS2023_appended.dta", clear

**Declare the PUMS data as "svy"
svyset [pw=pwgtp]
 
*Create appropriate age categories to match the paper
rename agep age 
gen agecat = .
	replace agecat = 1 if inrange(age, 18,29)
	replace agecat = 2 if inrange(age, 30, 44)
	replace agecat = 3 if inrange(age, 45, 59)
	replace agecat = 4 if age>=60 & age!=. 
	
	label define agecat 1 "18 to 29 years" 2 "30 to 44 years" 3 "45 to 59 years" 4 "60 years and older"
	label values agecat agecat 
	
//should be missing for those <18 - this is fine because we do not need to calculate variances, only proportions
 
*Generate a sex variable to match our "female" variable (we will exlcude NB/other category from comparisons since that is not an option in the ACS data)
	gen female = (sex == 2)
		
*Generate a Hispanic variable to match ours
	gen hispanic = 0 if hisp==1
		replace hispanic = 1 if inrange(hisp, 2,24)
 
*Race - use categories as they are used in Table 1
/*
ACS var is rac1p, using the following coding
1=White alone
2=Black alone
3=Amer Indian alone
4=Alaska Native alone
5=Amer Indian or Alaska Native 
6=Asian alone
7=Native Hawaiian or Other PI alone
8=Some other race alone
9=Two or more races
*/
	gen racecat = . 
		replace racecat = 1 if rac1p ==3 | rac1p==4 | rac1p==5 // AmerInd/Alask Native, not Hispanic
		replace racecat = 2 if rac1p==6 | rac1p==7 //Asian, Native HI or PI, not Hispanic
		replace racecat = 3 if rac1p==2 //Black, not Hispanic
		replace racecat = 7 if rac1p==1 //White, not Hispanic
		replace racecat = 20 if rac1p==8 | rac1p==9	//Another or multi, not Hispanic
		replace racecat = 4 if hispanic==1 // Hispanic; override with Hispanic if hispanic==1
			
	label define racecatlabels 1 "Amer Ind Alas Native" 2 "Asian, Native Hawaiian or Pacific Islander" 3 "Black" 4 "Hispanic" 5 "Middle Eastern or North African" 7 "White" 20 "Another race or multi-racial"
	label values racecat racecatlabels

*Education categories - 4 levels
gen educcat = . 
	replace educcat = 1 if inrange(schl, 1,17) // HS or less
	replace educcat = 2 if inrange(schl, 18, 19) // some college
	replace educcat = 3 if inrange(schl, 20, 21) //associates or 4yr degree
	replace educcat = 4 if inrange(schl, 22, 24) //graduate degree
		
	label define educcat 1 "HS or less" 2 "Some college" 3 "2 or 4-yr degree" 4 "Grad degree"
	label values educcat educcat 
	
*Create a subpop variable to separate adults from children; we will report characteristics in the adult population only
gen subpop=.
	replace subpop=1 if age>=18 & age!=.
	replace subpop=0 if age<18 

*Calculate % in each age category and store in matrix
svy, subpop(if subpop==1): prop agecat
	mat rtable=r(table)
	forval x=1/4 {
		mat usagecat`x'=rtable[1,`x']
	}
*Calculate % in each gender category and store in matrix
svy, subpop(if subpop==1): prop female
	mat rtable=r(table)
	forval x=1/2 {
		mat usfemale`x'=rtable[1,`x']
	}

*Calculate % in each race category and store in matrix
svy, subpop(if subpop==1): prop racecat
	mat rtable=r(table)
	mat usracecat1=rtable[1,1]
	mat usracecat2=rtable[1,2]
	mat usracecat3=rtable[1,3]
	mat usracecat4=rtable[1,4]
	mat usracecat5=0 //no one is in this category so its column is excluded from the r(table) matrix and needs to be added manually
	mat usracecat7=rtable[1,5]
	mat usracecat20=rtable[1,6]
	
*Calculate % in each education category and store in matrix
svy, subpop(if subpop==1): prop educcat
	mat rtable=r(table)
	forval x=1/4 {
		mat useduccat`x'=rtable[1,`x']
	}
	
*Store results for %s that were derived from sources other than PUMS

**Reports for income categories are from the CPS 2023: https://docs.google.com/viewer?url=https%3A%2F%2Fwww2.census.gov%2Flibrary%2Fpublications%2F2024%2Fdemo%2Fp60-282.pdf
*see table on pg 16
mat usincomecat1=.074+.067
mat usincomecat2=.069+.103
mat usincomecat3=.157
mat usincomecat4=.121+.17+.095+.144
//check sums to ~100: mat incomecheck=usincomecat1[1,1]+usincomecat2[1,1]+usincomecat3[1,1]+usincomecat4[1,1]

****************************************	
*Now re-calculate characteristics for study sample and store results so we can easily output them here
****************************************

*Bring in the cleanded data (result of DataPrep.do)
use "$Data/FGGRCT_clean_wide.dta", clear

prop agecat
	mat rtable=r(table)
	forval x=1/4 {
		mat sampagecat`x'=rtable[1,`x']
	}

prop gendercat
	mat rtable=r(table)
	forval x=1/3 {
		mat sampgendercat`x'=rtable[1,`x']
	}

prop racecat
	mat rtable=r(table)
	mat sampracecat1=rtable[1,1]
	mat sampracecat2=rtable[1,2]
	mat sampracecat3=rtable[1,3]
	mat sampracecat4=rtable[1,4]
	mat sampracecat5=rtable[1,5] //no one is in this category so its column is excluded from the matrix
	mat sampracecat7=rtable[1,6]
	mat sampracecat20=rtable[1,7]

prop educcat
	mat rtable=r(table)
	forval x=1/4 {
		mat sampeduccat`x'=rtable[1,`x']
	}
	
prop income4cat
	mat rtable=r(table)
	forval x=1/4 {
		mat sampincomecat`x'=rtable[1,`x']
	}	
	
****************************************	
*Output results to Excel
****************************************

capture rm "$ResultsRCT/USvsSample.xlsx"
putexcel set "$ResultsRCT/USvsSample.xlsx", replace

****
*Add column headers
****

putexcel A2=("Characteristic")
putexcel B1=("Sample")
putexcel B2=("%")
putexcel C1=("US Population")
putexcel C2=("%")

****
*Add US and sample results
****

**Age
putexcel A3=("Age")
putexcel A4=("18-29")
putexcel A5=("30-44")
putexcel A6=("45-59")
putexcel A7=("60+")

local row=4
forval x=1/4 {
	putexcel B`row'=matrix(sampagecat`x'), nformat(0%)
	putexcel C`row'= matrix(usagecat`x'), nformat(0%)
	local ++row
}

**Gender
putexcel A8=("Gender")
putexcel A9=("Female")
putexcel A10=("Male")
putexcel A11=("Non-binary / another")

	*Sample
	local row=9
	foreach x in 1 2 3  { 
		putexcel B`row'= matrix(sampgendercat`x'), nformat(0%)
		local ++row
	}
	
	*override nformat for NB (1 sig dig after decimal)
	putexcel B11, nformat(0.0%)
	
	*US
	local row=9
	foreach x in 2 1  { //opposite order so female is first, male second
		putexcel C`row'= matrix(usfemale`x'), nformat(0%)
		local ++row
	}
	putexcel C`row'=("--") //NB in NA for US sample b/c of how the ACS question is asked

**Race cat
putexcel A12=("Race")
putexcel A13=("American Indian")
putexcel A14=("Asian/Pac Islander")
putexcel A15=("Black or Af Am")
putexcel A16=("Hispanic")
putexcel A17=("Middle Eastern / N African")
putexcel A18=("White")
putexcel A19=("Another or multi")

local row=13
foreach x in 1 2 3 4 5 7 20  {
	putexcel B`row'=matrix(sampracecat`x'), nformat(0%)
	putexcel c`row'=matrix(usracecat`x'), nformat(0%)
	local ++row
}

putexcel B17, nformat(0.0%)
putexcel B13, nformat(0.0%)

**Education
putexcel A20=("Education")
putexcel A21=("HS or less")
putexcel A22=("Some college")
putexcel A23=("College grad or associates")
putexcel A24=("Graduate degree")

local row=21
forval x=1/4 {
	putexcel B`row'=matrix(sampeduccat`x'), nformat(0%)
	putexcel C`row'=matrix(useduccat`x'), nformat(0%)
	local ++row
}

**Household income
putexcel A25=("Household income")
putexcel A26=("0-24k")
putexcel A27=("25-49k")
putexcel A28=("50-74k")
putexcel A29=("75k+")

local row=26
forval x=1/4 {
	putexcel B`row'=matrix(sampincomecat`x'), nformat(0%)
	putexcel C`row'=matrix(usincomecat`x'), nformat(0%)
	local ++row
}

