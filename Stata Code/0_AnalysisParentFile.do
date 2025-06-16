*AnalysisParentFile for FoodsGoGreen RCT 

*Replace xxx with your Stata username
	*If your forgot your username, run the following command to retrieve your username: [display "`c(username)'"] 
*Replace yyy with the applicable folder location

*User file paths
if "`c(username)'" =="xxx" {

	global Data "/yyy/JAMANetOp-foodsgogreen/Project folders-files/Data"
	global Code "/yyy/JAMANetOp-foodsgogreen/Stata Code"
	global ResultsRCT "/yyy/JAMANetOp-foodsgogreen/Project folders-files/Results"

}

*************
*Run the codes below:

*Data cleaning and preparation
run "$Code/0b_DataPrep.do"
run "$Code/1_Table1.do"
run "$Code/2_Consort.do" 
run "$Code/3_Analysis.do" 
run "$Code/4_ModerationAnalysis.do"
run "$Code/5_Acceptability.do" 
run "$Code/6_Psychological outcomes.do" 

*manually run "$Code/7_Compare_SamplevsUS.do" if of interest.
