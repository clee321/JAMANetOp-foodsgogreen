*Bring in the cleaned data
use "$Data/FGGRCT_clean_wide.dta", clear

*****************
***Entrees/Apps
*****************

**Calculate means and SDs for each outcome, by condition, and store results
foreach outcome in avg_ofcom total_ghg total_Fiber total_Prot  total_Sod total_Sat total_Sugar total_kcal {
	*Ecolabel mean/sd
	sum `outcome'_entree if arm==1
	* return list
	mat `outcome'_entree_tmean=r(mean)
	mat `outcome'_entree_tsd =r(sd)

	*Control mean/sd 
	sum `outcome'_entree if arm==0
	*return list
	mat `outcome'_entree_cmean=r(mean)
	mat `outcome'_entree_csd=r(sd)

}

*Regress each outcome on an indicator variable for condition (arm) 
foreach outcome in  avg_ofcom total_ghg total_Fiber total_Prot  total_Sod total_Sat total_Sugar total_kcal   {

	regress `outcome'_entree i.arm
	*matlist r(table) - will show you what is stored in r(table)
	mat `outcome'_entree_ADE = r(table)[1,2] //[row,column] * matlist r(table) to find placement in table
	mat `outcome'_entree_LL = r(table)[5,2]
	mat `outcome'_entree_UL = r(table)[6,2]
	mat `outcome'_entree_P = r(table)[4,2]
	**matlist r(table) shows you placement of values in table
	
}

*****************
***Overall order
*****************

**Calculate means and SDs for each outcome, by condition, and store results
foreach outcome in  avg_ofcom total_ghg total_Fiber total_Prot  total_Sod total_Sat total_Sugar total_kcal {
	
	*Ecolabel mean/sd
	sum `outcome'_overall if arm==1
	* return list
	mat `outcome'_overall_tmean=r(mean)
	mat `outcome'_overall_tsd =r(sd)

	*Control mean/sd 
	sum `outcome'_overall if arm==0
	*return list
	mat `outcome'_overall_cmean=r(mean)
	mat `outcome'_overall_csd=r(sd)	
}

**Regress each outcome on an indicator variable for condition (arm) 
foreach outcome in avg_ofcom total_ghg total_Fiber total_Prot  total_Sod total_Sat total_Sugar total_kcal  {

	regress `outcome'_overall i.arm
	*matlist r(table) - will show you what is stored in r(table)
	mat `outcome'_overall_ADE = r(table)[1,2] //[row,column] * matlist r(table) to find placement in table
	mat `outcome'_overall_LL = r(table)[5,2]
	mat `outcome'_overall_UL = r(table)[6,2]
	mat `outcome'_overall_P = r(table)[4,2]
	**matlist r(table) shows you placement of values in table
}


*********
*Total number of items
*********

**Calculate means and SDs for each outcome, by condition, and store results
foreach outcome in ttl_entreeapp ttl_beverage ttl_dessert {
	*Ecolabel mean/sd
	sum `outcome' if arm==1
	* return list
	mat `outcome'_tmean=r(mean)
	mat `outcome'_tsd =r(sd)

	*Control mean/sd 
	sum `outcome' if arm==0
	*return list
	mat `outcome'_cmean=r(mean)
	mat `outcome'_csd=r(sd)

}

**Regress each outcome on an indicator variable for condition (arm) 
foreach outcome in ttl_entreeapp ttl_beverage ttl_dessert   {

	regress `outcome' i.arm
	*matlist r(table) - will show you what is stored in r(table)
	mat `outcome'_ADE = r(table)[1,2] //[row,column] * matlist r(table) to find placement in table
	mat `outcome'_LL = r(table)[5,2]
	mat `outcome'_UL = r(table)[6,2]
	mat `outcome'_P = r(table)[4,2]
	**matlist r(table) shows you placement of values in table
}


****************
**Calculate Cohen's d's
****************

*Entrees
foreach outcome in avg_ofcom total_ghg total_Fiber total_Prot  total_Sod total_Sat total_Sugar  total_kcal  {
	
	di "`outcome'_entree"
	esize twosample `outcome'_entree, by(control) 
	*return list - will show you what is stored in r(table)
	mat `outcome'_entree_d = r(d) //[row,column] * matlist r(table) to find placement in table		
}
 
*Overall orders
foreach outcome in  avg_ofcom total_ghg total_Fiber total_Prot  total_Sod total_Sat total_Sugar  total_kcal  {

	di "`outcome'_overall"
	esize twosample `outcome'_overall, by(control) 
	*return list - will show you what is stored in r(table)
	mat `outcome'_overall_d = r(d) 		
}

*Number of items selected
foreach outcome in  ttl_entreeapp ttl_beverage ttl_dessert {

	di "`outcome'"
	esize twosample `outcome', by(control) 
	*return list - will show you what is stored in r(table)
	mat `outcome'_d = r(d) 	
}


********
**Output Main Table Regression Results to Excel
********

putexcel set "$ResultsRCT/Table2_RegressionOutput.xlsx", replace

*Add column and row headings
 *Add column headers
	putexcel B1:C1 = ("Treatment"), merge top hcenter bold 
	putexcel D1:E1=("Control"), merge top hcenter bold 
	putexcel F1:J1=("Difference, treatment vs. control"), merge top hcenter bold 
	putexcel B2=("Mean"), bold border(bottom)
	putexcel C2=("(SD)"), bold border(bottom)
	putexcel D2=("Mean"), bold border(bottom)
	putexcel E2=("(SD)"), bold border(bottom)
	putexcel F2=("Diff."), bold border(bottom)
	putexcel G2:H2= ("95% CI"), merge bold border(bottom)
	putexcel I2=("p-value"), bold border(bottom)
	putexcel J2= ("Cohen's d"), bold border(bottom)
	
	
*Add row names, bolding groups of constructs
	putexcel A3 = ("Healthfulness, 0-100"), bold
	putexcel A4 = ("Entrees and appetizers")
	putexcel A5 = ("Entire order ")
	putexcel A6 = ("Carbon footprint, grams of CO2-eq"), bold
	putexcel A7 = ("Entrees and appetizers")
	putexcel A8 = ("Entire order ")
	putexcel A9 = ("Fiber, g"), bold
	putexcel A10 = ("Entrees and appetizers")
	putexcel A11 = ("Entire order ")
	putexcel A12 =("Protein, g"), bold
	putexcel A13 = ("Entrees and appetizers")
	putexcel A14= ("Entire order ")
	putexcel A15=("Sodium, mg"), bold
	putexcel A16= ("Entrees and appetizers")
	putexcel A17= ("Entire order ")
	putexcel A18 =("Saturated fat, g"), bold
	putexcel A19= ("Entrees and appetizers")
	putexcel A20= ("Entire order ")
	putexcel A21=("Sugar, g"), bold
	putexcel A22= ("Entrees and appetizers")
	putexcel A23= ("Entire order ")
	putexcel A24 =("Calories, kcal"), bold
	putexcel A25= ("Entrees and appetizers")
	putexcel A26= ("Entire order ")
	putexcel A27 = ("Items ordered"), bold
	putexcel A28 = ("Entrees and appetizers")
	putexcel A29 = ("Beverages")
	putexcel A30 = ("Desserts")
	

	*Ofcom
	*Entree Treatment mean and SD
	putexcel B4 = matrix(avg_ofcom_entree_tmean), nformat(0.0)
	putexcel C4 = matrix(avg_ofcom_entree_tsd), nformat("(0.0)")
		
	*Entree Control mean and SD
	putexcel D4 = matrix(avg_ofcom_entree_cmean), nformat(0.0)
	putexcel E4 = matrix(avg_ofcom_entree_csd), nformat("(0.0)")

	*Diff
	putexcel F4 = matrix(avg_ofcom_entree_ADE), nformat(0.00)
	putexcel G4 = matrix(avg_ofcom_entree_LL), nformat("(0.00;(-0.00")
	putexcel H4 = matrix(avg_ofcom_entree_UL),  nformat(", 0.00);, -0.00) ")
	putexcel I4 = matrix(avg_ofcom_entree_P), nformat(0.00)
		
	*Cohen's d
	putexcel J4 = matrix(avg_ofcom_entree_d), nformat(0.00)
		
	*Total Treatment mean and SD total
	putexcel B5 = matrix(avg_ofcom_overall_tmean), nformat(0.0)
	putexcel C5 = matrix(avg_ofcom_overall_tsd), nformat("(0.0)")
		
	*Control mean and SD
	putexcel D5 = matrix(avg_ofcom_overall_cmean), nformat(0.0)
	putexcel E5 = matrix(avg_ofcom_overall_csd), nformat("(0.0)")

	*Diff
	putexcel F5 = matrix(avg_ofcom_overall_ADE), nformat(0.00)
	putexcel G5 = matrix(avg_ofcom_overall_LL), nformat("(0.00;(-0.00")
	putexcel H5 = matrix(avg_ofcom_overall_UL), nformat(", 0.00);, -0.00) ")
	putexcel I5 = matrix(avg_ofcom_overall_P), nformat(0.00)
					
	*Cohen's d
	putexcel J5 = matrix(avg_ofcom_overall_d), nformat(0.00)
	
*******************
*GHG total_ghg
*******************
	
	*Entree Treatment mean and SD
	putexcel B7 = matrix(total_ghg_entree_tmean), nformat(0.0)
	putexcel C7 = matrix(total_ghg_entree_tsd), nformat("(0.0)")
		
	*Entree Control mean and SD
	putexcel D7 = matrix(total_ghg_entree_cmean), nformat(0.0)
	putexcel E7 = matrix(total_ghg_entree_csd), nformat("(0.0)")

	*Diff
	putexcel F7 = matrix(total_ghg_entree_ADE), nformat(0.00)
	putexcel G7 = matrix(total_ghg_entree_LL), nformat("(0.00;(-0.00")
	putexcel H7 = matrix(total_ghg_entree_UL), nformat(", 0.00);, -0.00) ")
	putexcel I7 = matrix(total_ghg_entree_P), nformat(0.00)
		
	*Cohen's d
	putexcel J7 = matrix(total_ghg_entree_d), nformat(0.00)
			
	*Total Treatment mean and SD total
	putexcel B8 = matrix(total_ghg_overall_tmean), nformat(0.0)
	putexcel C8 = matrix(total_ghg_overall_tsd), nformat("(0.0)")
		
	*Control mean and SD
	putexcel D8 = matrix(total_ghg_overall_cmean), nformat(0.0)
	putexcel E8 = matrix(total_ghg_overall_csd), nformat("(0.0)")

	*Diff
	putexcel F8 = matrix(total_ghg_overall_ADE), nformat(0.00)
	putexcel G8 = matrix(total_ghg_overall_LL), nformat("(0.00;(-0.00")
	putexcel H8 = matrix(total_ghg_overall_UL), nformat(", 0.00);, -0.00) ")
	putexcel I8 = matrix(total_ghg_overall_P), nformat(0.00)
	
	*Cohen's d
	putexcel J8 = matrix(total_ghg_overall_d), nformat(0.00)
		
	*Fix p-values
	*Replace pvalues <0.001 with "<0.001" or >0.99 if ==1.00
		local adjp = total_ghg_entree_P[1,1]
		if `adjp'<0.001 {
			putexcel I7=("<0.001")
		}
		
		local adjp = total_ghg_overall_P[1,1]
		if `adjp'<0.001 {
			putexcel I8=("<0.001")
		}
		
****************
*total_Fiber
****************

	*Entree Treatment mean and SD
	putexcel B10 = matrix(total_Fiber_entree_tmean), nformat(0.0)
	putexcel C10= matrix(total_Fiber_entree_tsd), nformat("(0.0)")
		
	*Entree Control mean and SD
	putexcel D10 = matrix(total_Fiber_entree_cmean), nformat(0.0)
	putexcel E10 = matrix(total_Fiber_entree_csd), nformat("(0.0)")

	*Diff
	putexcel F10 = matrix(total_Fiber_entree_ADE), nformat(0.00)
	putexcel G10 = matrix(total_Fiber_entree_LL), nformat("(0.00;(-0.00")
	putexcel H10 = matrix(total_Fiber_entree_UL), nformat(", 0.00);, -0.00) ")
	putexcel I10 = matrix(total_Fiber_entree_P), nformat(0.00)
		
	*Cohen's d
	putexcel J10 = matrix(total_Fiber_entree_d), nformat(0.00)
		
	*Total Treatment mean and SD total
	putexcel B11 = matrix(total_Fiber_overall_tmean), nformat(0.0)
	putexcel C11 = matrix(total_Fiber_overall_tsd), nformat("(0.0)")
		
	*Control mean and SD
	putexcel D11 = matrix(total_Fiber_overall_cmean), nformat(0.0)
	putexcel E11 = matrix(total_Fiber_overall_csd), nformat("(0.0)")

	*Diff
	putexcel F11 = matrix(total_Fiber_overall_ADE), nformat(0.00)
	putexcel G11 = matrix(total_Fiber_overall_LL), nformat("(0.00;(-0.00")
	putexcel H11 = matrix(total_Fiber_overall_UL), nformat(", 0.00);, -0.00) ")
	putexcel I11 = matrix(total_Fiber_overall_P), nformat(0.00)
	
	*Cohen's d
	putexcel J11 = matrix(total_Fiber_overall_d), nformat(0.00)
		
	
****************
*total_Prot
****************

	*Entree Treatment mean and SD
	putexcel B13 = matrix(total_Prot_entree_tmean), nformat(0.0)
	putexcel C13= matrix(total_Prot_entree_tsd), nformat("(0.0)")
		
	*Entree Control mean and SD
	putexcel D13 = matrix(total_Prot_entree_cmean), nformat(0.0)
	putexcel E13 = matrix(total_Prot_entree_csd), nformat("(0.0)")

	*Diff
	putexcel F13 = matrix(total_Prot_entree_ADE), nformat(0.00)
	putexcel G13 = matrix(total_Prot_entree_LL), nformat("(0.00;(-0.00")
	putexcel H13 = matrix(total_Prot_entree_UL), nformat(", 0.00);, -0.00) ")
	putexcel I13 = matrix(total_Prot_entree_P), nformat(0.00)
		
	*Cohen's d
	putexcel J13 = matrix(total_Prot_entree_d), nformat(0.00)
		
	*Total Treatment mean and SD total
	putexcel B14 = matrix(total_Prot_overall_tmean), nformat(0.0)
	putexcel C14 = matrix(total_Prot_overall_tsd), nformat("(0.0)")
		
	*Control mean and SD
	putexcel D14 = matrix(total_Prot_overall_cmean), nformat(0.0)
	putexcel E14 = matrix(total_Prot_overall_csd), nformat("(0.0)")

	*Diff
	putexcel F14 = matrix(total_Prot_overall_ADE), nformat(0.00)
	putexcel G14 = matrix(total_Prot_overall_LL), nformat("(0.00;(-0.00")
	putexcel H14 = matrix(total_Prot_overall_UL), nformat(", 0.00);, -0.00) ")
	putexcel I14 = matrix(total_Prot_overall_P), nformat(0.00)
	
	*Cohen's d
	putexcel J14 = matrix(total_Prot_overall_d), nformat(0.00)
		
****************		
*total_Sod
****************

	*Entree Treatment mean and SD
	putexcel B16 = matrix(total_Sod_entree_tmean), nformat(0.0)
	putexcel C16= matrix(total_Sod_entree_tsd), nformat("(0.0)")
		
	*Entree Control mean and SD
	putexcel D16 = matrix(total_Sod_entree_cmean), nformat(0.0)
	putexcel E16 = matrix(total_Sod_entree_csd), nformat("(0.0)")

	*Diff
	putexcel F16 = matrix(total_Sod_entree_ADE), nformat(0.00)
	putexcel G16 = matrix(total_Sod_entree_LL), nformat("(0.00;(-0.00")
	putexcel H16 = matrix(total_Sod_entree_UL), nformat(", 0.00);, -0.00) ")
	putexcel I16 = matrix(total_Sod_entree_P), nformat(0.00)
		
	*Cohen's d
	putexcel J16 = matrix(total_Sod_entree_d), nformat(0.00)
		
	*Total Treatment mean and SD total
	putexcel B17 = matrix(total_Sod_overall_tmean), nformat(0.0)
	putexcel C17 = matrix(total_Sod_overall_tsd), nformat("(0.0)")
		
	*Control mean and SD
	putexcel D17 = matrix(total_Sod_overall_cmean), nformat(0.0)
	putexcel E17 = matrix(total_Sod_overall_csd), nformat("(0.0)")

	*Diff
	putexcel F17 = matrix(total_Sod_overall_ADE), nformat(0.00)
	putexcel G17 = matrix(total_Sod_overall_LL), nformat("(0.00;(-0.00")
	putexcel H17 = matrix(total_Sod_overall_UL), nformat(", 0.00);, -0.00) ")
	putexcel I17 = matrix(total_Sod_overall_P), nformat(0.00)
	
	*Cohen's d
	putexcel J17 = matrix(total_Sod_overall_d), nformat(0.00)
		
	

****************
*total_Sat
****************

	*Entree Treatment mean and SD
	putexcel B19 = matrix(total_Sat_entree_tmean), nformat(0.0)
	putexcel C19= matrix(total_Sat_entree_tsd), nformat("(0.0)")
		
	*Entree Control mean and SD
	putexcel D19 = matrix(total_Sat_entree_cmean), nformat(0.0)
	putexcel E19 = matrix(total_Sat_entree_csd), nformat("(0.0)")

	*Diff
	putexcel F19 = matrix(total_Sat_entree_ADE), nformat(0.00)
	putexcel G19 = matrix(total_Sat_entree_LL), nformat("(0.00;(-0.00")
	putexcel H19 = matrix(total_Sat_entree_UL), nformat(", 0.00);, -0.00) ")
	putexcel I19 = matrix(total_Sat_entree_P), nformat(0.00)
		
	*Cohen's d
	putexcel J19 = matrix(total_Sat_entree_d), nformat(0.00)
		
		
	*Total Treatment mean and SD total
	putexcel B20 = matrix(total_Sat_overall_tmean), nformat(0.0)
	putexcel C20 = matrix(total_Sat_overall_tsd), nformat("(0.0)")
		
	*Control mean and SD
	putexcel D20 = matrix(total_Sat_overall_cmean), nformat(0.0)
	putexcel E20 = matrix(total_Sat_overall_csd), nformat("(0.0)")

	*Diff
	putexcel F20 = matrix(total_Sat_overall_ADE), nformat(0.00)
	putexcel G20 = matrix(total_Sat_overall_LL), nformat("(0.00;(-0.00")
	putexcel H20 = matrix(total_Sat_overall_UL), nformat(", 0.00);, -0.00) ")
	putexcel I20 = matrix(total_Sat_overall_P), nformat(0.00)
	
	*Cohen's d
	putexcel J20 = matrix(total_Sat_overall_d), nformat(0.00)
		
	

****************
*total_Sugar 
****************
	
	*Entree Treatment mean and SD
	putexcel B22 = matrix(total_Sugar_entree_tmean), nformat(0.0)
	putexcel C22= matrix(total_Sugar_entree_tsd), nformat("(0.0)")
		
	*Entree Control mean and SD
	putexcel D22 = matrix(total_Sugar_entree_cmean), nformat(0.0)
	putexcel E22 = matrix(total_Sugar_entree_csd), nformat("(0.0)")

	*Diff
	putexcel F22 = matrix(total_Sugar_entree_ADE), nformat(0.00)
	putexcel G22 = matrix(total_Sugar_entree_LL), nformat("(0.00;(-0.00")
	putexcel H22 = matrix(total_Sugar_entree_UL), nformat(", 0.00);, -0.00) ")
	putexcel I22 = matrix(total_Sugar_entree_P), nformat(0.00)
		
	*Cohen's d
	putexcel J22 = matrix(total_Sugar_entree_d), nformat(0.00)
		
		
	*Total Treatment mean and SD total
	putexcel B23 = matrix(total_Sugar_overall_tmean), nformat(0.0)
	putexcel C23 = matrix(total_Sugar_overall_tsd), nformat("(0.0)")
		
	*Control mean and SD
	putexcel D23 = matrix(total_Sugar_overall_cmean), nformat(0.0)
	putexcel E23 = matrix(total_Sugar_overall_csd), nformat("(0.0)")

	*Diff
	putexcel F23 = matrix(total_Sugar_overall_ADE), nformat(0.00)
	putexcel G23 = matrix(total_Sugar_overall_LL), nformat("(0.00;(-0.00")
	putexcel H23 = matrix(total_Sugar_overall_UL), nformat(", 0.00);, -0.00) ")
	putexcel I23 = matrix(total_Sugar_overall_P), nformat(0.00)
	
	*Cohen's d
	putexcel J23 = matrix(total_Sugar_overall_d), nformat(0.00)
		
	


	*total_kcal  
	*Entree Treatment mean and SD
	putexcel B25 = matrix(total_kcal _entree_tmean), nformat(0.0)
	putexcel C25= matrix(total_kcal _entree_tsd), nformat("(0.0)")
		
	*Entree Control mean and SD
	putexcel D25 = matrix(total_kcal _entree_cmean), nformat(0.0)
	putexcel E25 = matrix(total_kcal _entree_csd), nformat("(0.0)")

	*Diff
	putexcel F25 = matrix(total_kcal _entree_ADE), nformat(0.00)
	putexcel G25 = matrix(total_kcal _entree_LL), nformat("(0.00;(-0.00")
	putexcel H25 = matrix(total_kcal_entree_UL), nformat(", 0.00);, -0.00) ")
	putexcel I25 = matrix(total_kcal_entree_P), nformat(0.00)
		
	*Cohen's d
	putexcel J25 = matrix(total_kcal _entree_d), nformat(0.00)
		
		
	*Total Treatment mean and SD total
	putexcel B26 = matrix(total_kcal_overall_tmean), nformat(0.0)
	putexcel C26 = matrix(total_kcal_overall_tsd), nformat("(0.0)")
		
	*Control mean and SD
	putexcel D26 = matrix(total_kcal_overall_cmean), nformat(0.0)
	putexcel E26 = matrix(total_kcal_overall_csd), nformat("(0.0)")

	*Diff
	putexcel F26 = matrix(total_kcal_overall_ADE), nformat(0.00)
	putexcel G26 = matrix(total_kcal_overall_LL), nformat("(0.00;(-0.00")
	putexcel H26 = matrix(total_kcal_overall_UL), nformat(", 0.00);, -0.00) ")
	putexcel I26 = matrix(total_kcal_overall_P), nformat(0.00)
	
	*Cohen's d
	putexcel J26 = matrix(total_kcal_overall_d), nformat(0.00)
		
********
*Items ordered
********


**Number of entrees and appetizers ordered
local row=28 
foreach item in entreeapp beverage dessert {
	*Treatment mean and SD
	putexcel B`row' = matrix(ttl_`item'_tmean), nformat(0.0)
	putexcel C`row' = matrix(ttl_`item'_tsd), nformat("(0.0)")
		
	*Control mean and SD
	putexcel D`row' = matrix(ttl_`item'_cmean), nformat(0.0)
	putexcel E`row' = matrix(ttl_`item'_csd), nformat("(0.0)")

	*Diff
	putexcel F`row' = matrix(ttl_`item'_ADE), nformat(0.00)
	putexcel G`row' = matrix(ttl_`item'_LL), nformat("(0.00;(-0.00")
	putexcel H`row' = matrix(ttl_`item'_UL),  nformat(", 0.00);, -0.00) ")
	putexcel I`row' = matrix(ttl_`item'_P), nformat(0.00)
		
	*Cohen's d
	putexcel J`row' = matrix(ttl_`item'_d), nformat(0.00)	
	local ++row 
}
	
