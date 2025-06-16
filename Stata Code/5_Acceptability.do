*Bring in the cleaned data
use "$Data/FGGRCT_clean_wide.dta", clear

*Summarize endorsement of acceptability items
foreach outcome in perceptcontrol accept_help accept_like accept_want {
	sum `outcome'cat
	mat `outcome'prop = r(mean)
} 

putexcel set "$ResultsRCT/Acceptability_PropEndorse.xlsx", replace

putexcel A2 = "Want to see the ecolabels on menus"
putexcel B2 = matrix(accept_wantprop), nformat(##%)

putexcel A3 = "Like the ecolabel"
putexcel B3 = matrix(accept_likeprop), nformat(##%)

putexcel A4= "Ecolabels would help choose more sustainable foods"
putexcel B4= matrix(accept_helpprop), nformat(##%)

putexcel A5= "Ecolabels increase control over making sustainable eating decisions"
putexcel B5= matrix(perceptcontrolprop), nformat(##%)
