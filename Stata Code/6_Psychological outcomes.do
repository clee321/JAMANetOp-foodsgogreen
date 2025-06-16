*Bring in cleaned data
use "$Data/FGGRCT_clean_wide.dta", clear

**Noticed Ecolabel
sum noticed_trial if arm==1
mat noticed_trial_tmean =r(mean)
count if noticed_trial==1 & arm==1
mat noticed_trial_tn =r(N)

sum noticed_trial if arm==0
mat noticed_trial_cmean =r(mean)
count if noticed_trial==1 & arm==0
mat noticed_trial_cn =r(N)

logit noticed_trial i.arm
margins, dydx(arm)
mat noticed_trial_ADE = r(table)[1,2]
mat noticed_trial_LL = r(table)[5,2]
mat noticed_trial_UL = r(table)[6,2]
mat noticed_trial_P = r(table)[4,2]


*Special code for Cohen's d for binary outcomes (different from esize)
*Confirmed this d with online calculator: https://www.campbellcollaboration.org/calculator/
	logit noticed_trial i.arm, or
	scalar OR =r(table)[1,2]
	scalar d = ln(OR) * sqrt(3)/_pi
	di d
	mat noticed_trial_d = d

**********************************************

**Cognitive elaboration
	*Ecolabel mean/sd
	foreach outcome in env health taste {

	sum elab_`outcome' if arm==1
	* return list
	mat elab_`outcome'_tmean=r(mean)
	mat elab_`outcome'_tsd =r(sd)

	*Control mean/sd 
	sum elab_`outcome' if arm==0
	*return list
	mat elab_`outcome'_cmean=r(mean)
	mat elab_`outcome'_csd=r(sd)
}

	**Regress each outcome on an indicator variable for condition (arm) 
	foreach outcome in _env _health _taste {

	regress elab`outcome' i.arm
	*matlist r(table)
	mat elab`outcome'_ADE = r(table)[1,2] //[row,column]
	mat elab`outcome'_LL = r(table)[5,2]
	mat elab`outcome'_UL = r(table)[6,2]
	mat elab`outcome'_P = r(table)[4,2]
	**matlist r(table) shows you placement of values in table
	
	esize twosample elab`outcome', by(control) 
	*return list
	mat elab`outcome'_d = r(d) //[row,column]
}

***************************************
***Perceived sustainability 
	*Ecolabel mean/sd
	foreach outcome in psustain_s_ phealth_s_ ptaste_s_ psustain_u_ phealth_u_ ptaste_u_ {
	sum `outcome'merged if arm==1
	* return list
	mat `outcome'merged_tmean=r(mean)
	mat `outcome'merged_tsd =r(sd)

	*Control mean/sd 
	sum `outcome'merged if arm==0
	*return list
	mat `outcome'merged_cmean=r(mean)
	mat `outcome'merged_csd=r(sd)
}

**Regress
foreach outcome in psustain_s_ phealth_s_ ptaste_s_ psustain_u_ phealth_u_ ptaste_u_ {

	regress `outcome'merged i.arm
	*matlist r(table)
	mat `outcome'merged_ADE = r(table)[1,2] //[row,column]
	mat `outcome'merged_LL = r(table)[5,2]
	mat `outcome'merged_UL = r(table)[6,2]
	mat `outcome'merged_P = r(table)[4,2]
	
	esize twosample `outcome'merged, by(control) 
	*return list
	mat `outcome'merged_d = r(d) //[row,column]
}
 
********
**Output Main Table Regression Results to Excel
********

putexcel set "$ResultsRCT/Table3_SecondaryOutput.xlsx", replace
putexcel B1:C1 = ("Treatment"), merge bold
putexcel D1:E1 = ("Control"), merge bold
putexcel F1:K1= ("Difference, treatment vs. control"), merge bold
putexcel B2 = ("Mean"), bold
putexcel C2=("(SD)"), bold
putexcel D2 = ("Mean"), bold
putexcel E2=("(SD)"), bold
putexcel F2= ("ADE"), bold
putexcel G2:H2=("(95%CI)"), merge bold
putexcel I2= ("p-value"), bold
putexcel J2=("Cohen's d"), bold
putexcel A3=("Noticed ecolabel")
putexcel A4= ("Thinking about sustainability")
putexcel A5=("Thinking about healthfulness")
putexcel A6=("Thinking about taste")
putexcel A7=("Perceptions of sustainable menu items")
putexcel A8=("Perceived sustainability")
putexcel A9=("Perceived healthfulness")
putexcel A10=("Perceived tastiness")
putexcel A11=("Perceptions of unsustainable menu items")
putexcel A12=("Perceived sustainability")
putexcel A13=("Perceived healthfulness")
putexcel A14=("Perceived tastiness")

**Noticed ecolabel 
putexcel B3 = matrix(noticed_trial_tmean), nformat(##%)
putexcel C3 = matrix(noticed_trial_tn), nformat("(##)")

putexcel D3 = matrix(noticed_trial_cmean), nformat(##%)
putexcel E3 = matrix(noticed_trial_cn), nformat("(##)")

putexcel F3 = matrix(noticed_trial_ADE), nformat(0.00)
putexcel G3 = matrix(noticed_trial_LL), nformat("(0.00")
putexcel H3 = matrix(noticed_trial_UL), nformat(", 0.00);, -0.00) ")
putexcel I3 = matrix(noticed_trial_P), nformat(0.00)
		
putexcel J3 = matrix(noticed_trial_d), nformat(0.00)

*Thinking about sustainability
putexcel B4 = matrix(elab_env_tmean), nformat(0.00)
putexcel C4 = matrix(elab_env_tsd), nformat("(0.0)")

putexcel D4 = matrix(elab_env_cmean), nformat(0.00)
putexcel E4 = matrix(elab_env_csd), nformat("(0.0)")

putexcel F4 = matrix(elab_env_ADE), nformat(0.00)
putexcel G4 = matrix(elab_env_LL), nformat("(0.00;(-0.00")
putexcel H4 = matrix(elab_env_UL), nformat(", 0.00);, -0.00) ")
putexcel I4 = matrix(elab_env_P), nformat(0.00)
		
putexcel J4 = matrix(elab_env_d), nformat(0.00)

*Thinking about health
putexcel B5 = matrix(elab_health_tmean), nformat(0.00)
putexcel C5 = matrix(elab_health_tsd), nformat("(0.0)")

putexcel D5 = matrix(elab_health_cmean), nformat(0.00)
putexcel E5 = matrix(elab_health_csd), nformat("(0.0)")

putexcel F5 = matrix(elab_health_ADE), nformat(0.00)
putexcel G5 = matrix(elab_health_LL), nformat("(0.00;(-0.00")
putexcel H5 = matrix(elab_health_UL), nformat(", 0.00);, -0.00) ")
putexcel I5 = matrix(elab_health_P), nformat(0.00)
		
putexcel J5 = matrix(elab_health_d), nformat(0.00)

*Thinking about taste
putexcel B6 = matrix(elab_taste_tmean), nformat(0.00)
putexcel C6 = matrix(elab_taste_tsd), nformat("(0.0)")

putexcel D6 = matrix(elab_taste_cmean), nformat(0.00)
putexcel E6 = matrix(elab_taste_csd), nformat("(0.0)")

putexcel F6 = matrix(elab_taste_ADE), nformat(0.00)
putexcel G6 = matrix(elab_taste_LL), nformat("(0.00;(-0.00")
putexcel H6 = matrix(elab_taste_UL), nformat(", 0.00);, -0.00) ")
putexcel I6 = matrix(elab_taste_P), nformat(0.00)
		
putexcel J6 = matrix(elab_taste_d), nformat(0.00)

*Fix p-values for noticing, thinking outcomes
	*Replace pvalues <0.001 with "<0.001" 
		local row = 3
		foreach outcome in noticed_trial elab_env elab_health elab_taste { 
			local adjp = `outcome'_P[1,1]
			if `adjp'<0.001 {
				putexcel I`row'=("<0.001")
			}
			local ++row
		}

*************
*Perceptions of sustainable items
*************
	local row=8
	foreach outcome in psustain_s_ phealth_s_ ptaste_s_ {
		
		*Treatment mean and SD entree and appetizers
		putexcel B`row' = matrix(`outcome'merged_tmean), nformat(0.00)
		putexcel C`row' = matrix(`outcome'merged_tsd), nformat("(0.00)")
		
		*Control mean and SD
		putexcel D`row' = matrix(`outcome'merged_cmean), nformat(0.00)
		putexcel E`row' = matrix(`outcome'merged_csd), nformat("(0.00)")

		*Diff
		putexcel F`row' = matrix(`outcome'merged_ADE), nformat(0.00)
		putexcel G`row' = matrix(`outcome'merged_LL), nformat("(0.00;(-0.00")
		putexcel H`row' = matrix(`outcome'merged_UL), nformat(", 0.00);, -0.00) ")
		putexcel I`row' = matrix(`outcome'merged_P), nformat(0.00)
		
		*Cohen's d
		putexcel J`row' = matrix(`outcome'merged_d), nformat(0.00)
				
*Fix p-values for perceptions of sustainable items
	*Replace pvalues <0.001 with "<0.001" 
		local adjp = `outcome'merged_P[1,1]
		if `adjp'<0.001 {
			putexcel I`row'=("<0.001")
		}
		local ++row
	}
	
*Fix perceived healthfulness p-value (>.001 but less than <0.01)
	putexcel I9, nformat(0.000)
		
**********
*Perceptions of unsustainable items 
**********
*loop for entering in the results 
*starts in row 12
	local row=12
	foreach outcome in psustain_u_ phealth_u_ ptaste_u_ {
	
		*Treatment mean and SD entree and appetizers
		putexcel B`row' = matrix(`outcome'merged_tmean), nformat(0.00)
		putexcel C`row' = matrix(`outcome'merged_tsd), nformat("(0.00)")
		
		*Control mean and SD
		putexcel D`row' = matrix(`outcome'merged_cmean), nformat(0.00)
		putexcel E`row' = matrix(`outcome'merged_csd), nformat("(0.00)")

		*Diff
		putexcel F`row' = matrix(`outcome'merged_ADE), nformat(0.00)
		putexcel G`row' = matrix(`outcome'merged_LL), nformat("(0.00;(-0.00")
		putexcel H`row' = matrix(`outcome'merged_UL), nformat(", 0.00);, -0.00) ")
		putexcel I`row' = matrix(`outcome'merged_P), nformat(0.00)
		
		*Cohen's d
		putexcel J`row' = matrix(`outcome'merged_d), nformat(0.00)
	
	*Fix p-values for perceptions of sustainable items
	*Replace pvalues <0.001 with "<0.001" 
		local adjp = `outcome'merged_P[1,1]
		if `adjp'<0.001 {
			putexcel I`row'=("<0.001")
		}
	local ++ row		
}
	







