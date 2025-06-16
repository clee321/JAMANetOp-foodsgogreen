*Bring in cleaned data
use "$Data/FGGRCT_clean_wide.dta", clear

**Regress Primary Outcome: Healthfulness

*MODERATOR 1 = AGE: regress healthfulnes with moderator of age (young adult)

**Entrees
	regress  avg_ofcom_entree i.arm##i.youngadult
	testparm i.arm#i.youngadult 
	return list
	mat avg_ofcom_entree_age_P = r(p)
	margins, dydx(arm) at (youngadult=(1 0)) post coefleg 

*Store effects of trial arm at each level of the moderator
	mat avg_ofcom_entree_ya_ADE = r(table)[1,3]
	mat avg_ofcom_entree_ya_LL = r(table)[5,3]
	mat avg_ofcom_entree_ya_UL = r(table)[6,3]

	mat avg_ofcom_entree_Nya_ADE = r(table)[1,4]
	mat avg_ofcom_entree_Nya_LL = r(table)[5,4]
	mat avg_ofcom_entree_Nya_UL = r(table)[6,4]

	
*MODERATOR 2 = Interest in environmental sustainability: regress healthfulnes with moderator of greenscale_avg

	sum greenscale_avg
	global greenscale_avg_mean = r(mean)
	global greenscale_avg_sd =r(sd)
	global greenscale_avg_low = $greenscale_avg_mean - $greenscale_avg_sd
	global greenscale_avg_hi = $greenscale_avg_mean + $greenscale_avg_sd

	regress avg_ofcom_entree i.arm##c.greenscale_avg
	testparm i.arm#c.greenscale_avg 
	mat avg_ofcom_entree_greenscale_P = r(p)

	*Store effects of trial arm on greenscale at each level of the moderator
	regress avg_ofcom_entree i.arm##c.greenscale_avg	
	margins, dydx(arm) at (greenscale_avg=($greenscale_avg_low $greenscale_avg_mean $greenscale_avg_hi)) post coefleg 

	mat avg_ofcom_entree_low_ADE = r(table)[1,4]
	mat avg_ofcom_entree_low_LL = r(table)[5,4]
	mat avg_ofcom_entree_low_UL = r(table)[6,4]
	
	mat avg_ofcom_entree_med_ADE = r(table)[1,5]
	mat avg_ofcom_entree_med_LL = r(table)[5,5]
	mat avg_ofcom_entree_med_UL = r(table)[6,5]

	mat avg_ofcom_entree_hi_ADE = r(table)[1,6]
	mat avg_ofcom_entree_hi_LL = r(table)[5,6]
	mat avg_ofcom_entree_hi_UL = r(table)[6,6]

putexcel set "$ResultsRCT/Moderation.xlsx", replace

*Add column and row headings 
 *Add column headers
	putexcel A1 = ("Characteristic"),  bold border(bottom)
	putexcel B3=("Diff"), bold
	putexcel C3:D3= ("(95% CI)"), merge bold hcenter
	putexcel E3= ("p for interaction"), bold hcenter
	
	putexcel B2:E2=("Eco-label v. Control"),  merge bold border (bottom) hcenter
	
	putexcel A4=("Age"), bold
	putexcel A5=("18-29")
	putexcel A6 = ("30+")
	
	putexcel A7 =("Greenscale"), bold
	putexcel A8 =("Mean - 1 SD ")
	putexcel A9 =("Mean")
	putexcel A10 =("Mean + 1 SD ")
	
	putexcel B5 = matrix(avg_ofcom_entree_ya_ADE), nformat(0.00)
	putexcel C5 = matrix(avg_ofcom_entree_ya_LL), nformat("(0.00;(-0.00")  
	putexcel D5 = matrix(avg_ofcom_entree_ya_UL), nformat(", 0.00);, -0.00) ") 
	
	putexcel B6 = matrix(avg_ofcom_entree_Nya_ADE), nformat(0.00)
	putexcel C6 = matrix(avg_ofcom_entree_Nya_LL), nformat("(0.00;(-0.00") 
	putexcel D6 = matrix(avg_ofcom_entree_Nya_UL), nformat(", 0.00);, -0.00) ") 
	
	putexcel E6 = matrix(avg_ofcom_entree_age_P), nformat(.00) 
	
	
	*low
	putexcel B8 = matrix(avg_ofcom_entree_low_ADE), nformat(0.00)
	putexcel C8 = matrix(avg_ofcom_entree_low_LL), nformat("(0.00;(-0.00") 
	putexcel D8 = matrix(avg_ofcom_entree_low_UL), nformat(", 0.00);, -0.00) ")
	
	*medium
	putexcel B9 = matrix(avg_ofcom_entree_med_ADE), nformat(0.00)
	putexcel C9 = matrix(avg_ofcom_entree_med_LL), nformat("(0.00;(-0.00") 
	putexcel D9 = matrix(avg_ofcom_entree_med_UL), nformat(", 0.00);, -0.00) ")
	
	*highest
	putexcel B10 = matrix(avg_ofcom_entree_hi_ADE), nformat(0.00)
	putexcel C10 = matrix(avg_ofcom_entree_hi_LL), nformat("(0.00;(-0.00") 
	putexcel D10 = matrix(avg_ofcom_entree_hi_UL), nformat(", 0.00);, -0.00) ")
	putexcel E10 = matrix(avg_ofcom_entree_greenscale_P), nformat(.00) 
	

