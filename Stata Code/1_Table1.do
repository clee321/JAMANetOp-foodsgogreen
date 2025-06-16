*Bring in the cleaned data
use "$Data/FGGRCT_clean_wide.dta", clear

global ecolabel "1 2" 

*AGE 
	*First count total observations with non-missing age
	
	foreach arm in $ecolabel { 
	count if agecat!=. & ecolabel==`arm' 
	mat agecat_totaln_`arm' = r(N)
	
			foreach level in 1 2 3 4 {
			count if agecat==`level' & ecolabel==`arm'
			mat agecat_nl`level'_a`arm' = r(N)  
			mat agecat_propl`level'_a`arm' = agecat_nl`level'_a`arm'[1,1] / agecat_totaln_`arm'[1,1]
		}
	}
	
*GENDER
	*Count non-missing observations
	foreach arm in $ecolabel { 
	count if gendercat!=. & ecolabel==`arm'
	mat gendercat_totaln_`arm' = r(N)
	
		foreach gender in  1 2 3 {
		count if gendercat==`gender' & ecolabel==`arm'
		mat gendercat_nl`gender'_a`arm' = r(N)
		mat gendercat_propl`gender'_a`arm' = gendercat_nl`gender'_a`arm'[1,1] / gendercat_totaln_`arm'[1,1]
		}
	}

*RACE
	foreach arm in $ecolabel { 
	count if racecat!=.  & ecolabel==`arm'
	mat racecat_totaln_`arm' = r(N)
	
	
	foreach race in 1 2 3 4 5 7 20 {
	count if racecat==`race' & ecolabel==`arm'
	mat racecat_nl`race'_a`arm' = r(N)
	mat racecat_propl`race'_a`arm' = racecat_nl`race'_a`arm'[1,1] / racecat_totaln_`arm'[1,1]
	}
	}
	
*EDUCATION
	foreach arm in $ecolabel { 
	count if educcat!=. & ecolabel==`arm'
	mat educcat_totaln_`arm' = r(N)
	
		foreach educ in 1 2 3 4 {
			count if educcat==`educ' & ecolabel==`arm'
			mat educcat_nl`educ'_a`arm' = r(N)
			mat educcat_propl`educ'_a`arm' = educcat_nl`educ'_a`arm'[1,1] / educcat_totaln_`arm'[1,1]
		}
	}
	
*INCOME - 4 level
	foreach arm in $ecolabel { 
	count if income4cat!=. & ecolabel==`arm'
	mat income4cat_totalnl_`arm' = r(N)
		foreach incom in 1 2 3 4 {
			count if income4cat==`incom' & ecolabel==`arm'
			mat income4cat_nl`incom'_a`arm' = r(N)
			mat income4cat_propl`incom'_a`arm' = income4cat_nl`incom'_a`arm'[1,1] / income4cat_totalnl_`arm'[1,1]
		}
	}
		
*HOUSEHOLD SIZE
	foreach arm in $ecolabel { 
	count if hhsizenumcat!=. & ecolabel==`arm'
	mat hhsizenumcat_totalnl_`arm' = r(N)
		
		foreach hhsize in 1 2 3 {
			count if hhsizenumcat==`hhsize' & ecolabel==`arm'
			mat hhsizenumcat_nl`hhsize'_a`arm' = r(N)
			mat hhsizenumcat_propl`hhsize'_a`arm' = hhsizenumcat_nl`hhsize'_a`arm'[1,1] / hhsizenumcat_totalnl_`arm'[1,1]
		}
	}

	
*NUMBER OF CHILDREN
foreach arm in $ecolabel { 
	count if childrennumcat!=.&  ecolabel==`arm'
	mat childrennumcat_totalnl_`arm' = r(N)
	
	foreach children in 1 2 3 4 {
		count if childrennumcat==`children' & ecolabel==`arm'
		mat childrennumcat_nl`children'_a`arm' = r(N)
		mat childrennumcat_propl`children'_a`arm' = childrennumcat_nl`children'_a`arm'[1,1] / childrennumcat_totalnl_`arm'[1,1]
	}
}

*POLITICAL PARTY
	foreach arm in $ecolabel { 
	count if partyidcat!=. & ecolabel==`arm'
	mat partyidcat_totaln_`arm' = r(N)
	
		foreach party in 1 2 3 4{
			count if partyidcat==`party' & ecolabel==`arm'
			mat partyidcat_nl`party'_a`arm' = r(N)
			mat partyidcat_propl`party'_a`arm' = partyidcat_nl`party'_a`arm'[1,1] / partyidcat_totaln_`arm'[1,1]
		}
	}	
	
*GREEN SCALE
foreach arm in $ecolabel {
	 
	sum greenscale_avg if ecolabel==`arm'
	mat greenscale_avg_m_`arm'=r(mean)
	mat greenscale_avg_sd_`arm'=r(sd)

}
 
capture rm "$ResultsRCT/Table1.xlsx"
		
*Set filename for our Sample Characteristics table 
putexcel set "$ResultsRCT/Table1.xlsx" , replace
	
 *Add column headers
	putexcel A1=("Characteristic"), bold
	putexcel B1=("Ecolabel N"), bold
	putexcel C1=("Ecolabel %"), bold
	
	putexcel D1=("Control N"), bold
	putexcel E1=("Control %"), bold
	

*Add row labels
	putexcel A2 = ("Age"),bold border(bottom)
	putexcel A3 = ("18-29 years")
	putexcel A4 = ("30-44 years")
	putexcel A5 = ("45-59 years")
	putexcel A6 = ("60 years or older")
    putexcel A7 = ("Gender"),bold border(bottom)
    putexcel A8 = ("Female")
    putexcel A9 = ("Male")
	putexcel A10 = ("Non-binary or another gender")
	putexcel A11= ("Race and Ethnicity"),bold border(bottom)
	putexcel A12 = ("American Indian or Alaska Native, not Hispanic or Latino")
	putexcel A13 = ("Asian, Native Hawaiian, or Pacific Islander, not Hispanic or Latino")
	putexcel A14 = ("Black or African American, not Hispanic or Latino")
	putexcel A15 = ("Hispanic, Latino, or Spanish origin")	
	putexcel A16 = ("Middle Eastern or North African, not Hispanic or Latino")
	putexcel A17 = ("White, Not Hispanic or Latino")
	putexcel A18 = ("Another race or multi-racial, not Hispanic or Latino")
	putexcel A19 = ("Education"),bold border(bottom)
	putexcel A20 = ("High school diploma or less")
	putexcel A21 = ("Some college")
	putexcel A22 = ("College graduate or associates degree")
	putexcel A23 = ("Graduate degree")
	putexcel A24 = ("Household  income, annual"),bold border(bottom)
	putexcel A25 = ("$0 to $24,999")
	putexcel A26 = ("$25,000 to $49,999")
	putexcel A27 = ("$50,000 to $74,999")
	putexcel A28 = ("$75,000 or more")
	putexcel A29 = ("Household size"),bold border(bottom)
	putexcel A30 = ("1-2")
	putexcel A31 = ("3-4")
	putexcel A32 = ("5 or more")
	putexcel A33 = ("Number of children"),bold border(bottom)
	putexcel A34 = ("0")
	putexcel A35 = ("1-2")
	putexcel A36 = ("3 or more")
	putexcel A37 = ("Political party identification"),bold border(bottom)
	putexcel A38 = ("Democrat")
	putexcel A39 = ("Republican")
	putexcel A40 = ("Indepdendent")
	putexcel A41 = ("Other")
	putexcel A42 = ("Interest in sustainability (GREEN Scale21 score, range 1–5)"),bold 

	*Add statistics to table
	local x = 2 //col1 - start in B 
	local y = 3 //col2 - start in C
		
*Age Categories 
foreach arm in $ecolabel {
	
	local col1: word `x' of `c(alpha)' //this sets a local variable col1 equal to the xth letter of the alphabet 
	local col2: word `y' of `c(alpha)' //this sets a local variable col2 equal to the yth letter of the alphabet 
		
		putexcel `col1'3 = matrix(agecat_nl1_a`arm'), nformat(##)
		putexcel `col2'3 = matrix(agecat_propl1_a`arm'), nformat ((##%))
		
		putexcel `col1'4 = matrix(agecat_nl2_a`arm'), nformat(##)
		putexcel `col2'4 = matrix(agecat_propl2_a`arm'), nformat((##%))
		
		putexcel `col1'5 = matrix(agecat_nl3_a`arm'), nformat(##)
		putexcel `col2'5 = matrix(agecat_propl3_a`arm'), nformat((##%))
		
		putexcel `col1'6 = matrix(agecat_nl4_a`arm'), nformat(##)
		putexcel `col2'6 = matrix(agecat_propl4_a`arm'), nformat((##%))	
	
	local x = `x'+2
	local y = `y'+2
	
	}
	
	
*Gender
	local x = 2 //col1 - start in B 
	local y = 3 //col2 - start in C
		
	foreach arm in $ecolabel {
	
	local col1: word `x' of `c(alpha)' //this sets a local variable col1 equal to the xth letter of the alphabet 
	local col2: word `y' of `c(alpha)' //this sets a local variable col2 equal to the yth letter of the alphabet 
		
		putexcel `col1'8 = matrix(gendercat_nl1_a`arm'), nformat(##)
		putexcel `col2'8 = matrix(gendercat_propl1_a`arm'), nformat((##%))
		
		putexcel `col1'9 = matrix(gendercat_nl2_a`arm'), nformat(##)
		putexcel `col2'9 = matrix(gendercat_propl2_a`arm'), nformat((##%))
		
		putexcel `col1'10 = matrix(gendercat_nl3_a`arm'), nformat(##)
		putexcel `col2'10 = matrix(gendercat_propl3_a`arm'), nformat((#.00%))
		
	local x = `x'+2
	local y = `y'+2
	
	}
	
*Race
	local x = 2 //col1 - start in B 
	local y = 3 //col2 - start in C
		
	foreach arm in $ecolabel {
	
	local col1: word `x' of `c(alpha)' //this sets a local variable col1 equal to the xth letter of the alphabet 
	local col2: word `y' of `c(alpha)' //this sets a local variable col2 equal to the yth letter of the alphabet 
		
		putexcel `col1'12 = matrix(racecat_nl1_a`arm'), nformat(##)
		putexcel `col2'12 = matrix(racecat_propl1_a`arm'), nformat((#.00%))
		
		putexcel `col1'13 = matrix(racecat_nl2_a`arm'), nformat(##)
		putexcel `col2'13= matrix(racecat_propl2_a`arm'), nformat((##%))
		
		putexcel `col1'14 = matrix(racecat_nl3_a`arm'), nformat(##)
		putexcel `col2'14 = matrix(racecat_propl3_a`arm'), nformat((##%))
		
		putexcel `col1'15 = matrix(racecat_nl4_a`arm'), nformat(##)
		putexcel `col2'15 = matrix(racecat_propl4_a`arm'), nformat((##%))	
		
		putexcel `col1'16 = matrix(racecat_nl5_a`arm'), nformat(##)
		putexcel `col2'16 = matrix(racecat_propl5_a`arm'), nformat((#.00%))	
		
		putexcel `col1'17 = matrix(racecat_nl7_a`arm'), nformat(##)
		putexcel `col2'17 = matrix(racecat_propl7_a`arm'), nformat((##%))	
		
		putexcel `col1'18 = matrix(racecat_nl20_a`arm'), nformat(##)
		putexcel `col2'18 = matrix(racecat_propl20_a`arm'), nformat((##%))	
	
	
	local x = `x'+2
	local y = `y'+2
	
	}
	
*Education
local x = 2 //col1 - start in B 
local y = 3 //col2 - start in C
		
foreach arm in $ecolabel {
	
	local col1: word `x' of `c(alpha)' //this sets a local variable col1 equal to the xth letter of the alphabet 
	local col2: word `y' of `c(alpha)' //this sets a local variable col2 equal to the yth letter of the alphabet 
		
		putexcel `col1'20 = matrix(educcat_nl1_a`arm'), nformat(##)
		putexcel `col2'20 = matrix(educcat_propl1_a`arm'), nformat((##%))
		
		putexcel `col1'21 = matrix(educcat_nl2_a`arm'), nformat(##)
		putexcel `col2'21 = matrix(educcat_propl2_a`arm'), nformat((##%))
		
		putexcel `col1'22 = matrix(educcat_nl3_a`arm'), nformat(##)
		putexcel `col2'22 = matrix(educcat_propl3_a`arm'), nformat((##%))
		
		putexcel `col1'23 = matrix(educcat_nl4_a`arm'), nformat(##)
		putexcel `col2'23= matrix(educcat_propl4_a`arm'), nformat((##%))	
	
	local x = `x'+2
	local y = `y'+2
	
}
*Income
local x = 2 //col1 - start in B 
local y = 3 //col2 - start in C
	
foreach arm in $ecolabel {

local col1: word `x' of `c(alpha)' //this sets a local variable col1 equal to the xth letter of the alphabet 
local col2: word `y' of `c(alpha)' //this sets a local variable col2 equal to the yth letter of the alphabet 
	
	putexcel `col1'25 = matrix(income4cat_nl1_a`arm'), nformat(##)
	putexcel `col2'25 = matrix(income4cat_propl1_a`arm'), nformat((##%))
	
	putexcel `col1'26 = matrix(income4cat_nl2_a`arm'), nformat(##)
	putexcel `col2'26= matrix(income4cat_propl2_a`arm'), nformat((##%))
	
	putexcel `col1'27= matrix(income4cat_nl3_a`arm'), nformat(##)
	putexcel `col2'27= matrix(income4cat_propl3_a`arm'), nformat((##%))
	
	putexcel `col1'28 = matrix(income4cat_nl4_a`arm'), nformat(##)
	putexcel `col2'28 = matrix(income4cat_propl4_a`arm'), nformat((##%))	

	local x = `x'+2
	local y = `y'+2
}
	
*HH Size
local x = 2 //col1 - start in B 
local y = 3 //col2 - start in C
	
foreach arm in $ecolabel {

local col1: word `x' of `c(alpha)' //this sets a local variable col1 equal to the xth letter of the alphabet 
local col2: word `y' of `c(alpha)' //this sets a local variable col2 equal to the yth letter of the alphabet 
	
	putexcel `col1'30 = matrix(hhsizenumcat_nl1_a`arm'), nformat(##)
	putexcel `col2'30= matrix(hhsizenumcat_propl1_a`arm'), nformat((##%))
	
	putexcel `col1'31 = matrix(hhsizenumcat_nl2_a`arm'), nformat(##)
	putexcel `col2'31= matrix(hhsizenumcat_propl2_a`arm'), nformat((##%))
	
	putexcel `col1'32= matrix(hhsizenumcat_nl3_a`arm'), nformat(##)
	putexcel `col2'32= matrix(hhsizenumcat_propl3_a`arm'), nformat((##%))

local x = `x'+2
local y = `y'+2
}
	
*Number of children
local x = 2 //col1 - start in B 
local y = 3 //col2 - start in C
		
foreach arm in $ecolabel {
	
	local col1: word `x' of `c(alpha)' //this sets a local variable col1 equal to the xth letter of the alphabet 
	local col2: word `y' of `c(alpha)' //this sets a local variable col2 equal to the yth letter of the alphabet 
		
	putexcel `col1'34 = matrix(childrennumcat_nl1_a`arm'), nformat(##)
	putexcel `col2'34 = matrix(childrennumcat_propl1_a`arm'), nformat((##%))
	
	putexcel `col1'35 = matrix(childrennumcat_nl2_a`arm'), nformat(##)
	putexcel `col2'35 = matrix(childrennumcat_propl2_a`arm'), nformat((##%))
	
	putexcel `col1'36 = matrix(childrennumcat_nl3_a`arm'), nformat(##)
	putexcel `col2'36 = matrix(childrennumcat_propl3_a`arm'), nformat((##%))
	
	local x = `x'+2
	local y = `y'+2
}
	
*Political Party
local x = 2 //col1 - start in B 
local y = 3 //col2 - start in C
		
	foreach arm in $ecolabel {
	
	local col1: word `x' of `c(alpha)' //this sets a local variable col1 equal to the xth letter of the alphabet 
	local col2: word `y' of `c(alpha)' //this sets a local variable col2 equal to the yth letter of the alphabet 
		
	putexcel `col1'38 = matrix(partyidcat_nl1_a`arm'), nformat(##)
	putexcel `col2'38 = matrix(partyidcat_propl1_a`arm'), nformat((##%))
	
	putexcel `col1'39 = matrix(partyidcat_nl2_a`arm'), nformat(##)
	putexcel `col2'39 = matrix(partyidcat_propl2_a`arm'), nformat((##%))
	
	putexcel `col1'40 = matrix(partyidcat_nl3_a`arm'), nformat(##)
	putexcel `col2'40 = matrix(partyidcat_propl3_a`arm'), nformat((##%))
	
	putexcel `col1'41 = matrix(partyidcat_nl4_a`arm'), nformat(##)
	putexcel `col2'41 = matrix(partyidcat_propl4_a`arm'), nformat((##%))
		
	local x = `x'+2
	local y = `y'+2
	
}

*Interest in sustainability
local x = 2 //col1 - start in B 
local y = 3 //col2 - start in C
		
	foreach arm in $ecolabel {
	
	local col1: word `x' of `c(alpha)' //this sets a local variable col1 equal to the xth letter of the alphabet 
	local col2: word `y' of `c(alpha)' //this sets a local variable col2 equal to the yth letter of the alphabet 
		
	putexcel `col1'42 = matrix(greenscale_avg_m_`arm'), nformat(#.00)
	putexcel `col2'42 = matrix(greenscale_avg_sd_`arm'), nformat((#.00))
	
	
	local x = `x'+2
	local y = `y'+2
	
	}

*Overwrite formatting for %s <1% -- just 1 significant digit here
foreach cell in C10 E10 C12 E12 C16 E16 {
	putexcel `cell', nformat((.#%))
}


	