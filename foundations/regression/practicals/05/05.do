use ../data/vitC.dta, clear

browse
summarize age height cigs weight sex seruvitc ctakers
codebook // 1 missing weight and height, are they the same?
list serial height if missing(height) 
list serial weight if missing(height) // Yes

// Correlations
foreach var of varlist age height cigs weight sex ctakers{
	correlate seruvitc `var'
}
graph matrix age height cigs weight sex ctakers seruvitc

// Tables of categorical variables - add in agecat
gen ageg = cond(age <= 66, "65-66", cond(age <= 68, "67-68", cond(age <= 70, "69-70", cond(age <= 72, "71-72", "73-74"))))
foreach var of varlist cigs sex ctakers{
	bysort `var' : summarize seruvitc
}
graph box seruvitc, over(ageg)
/*
No real difference by age, maybe difference in cigs, sex, and ctakers
*/