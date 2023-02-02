/*
CHECK FOR ANY !!! & 'line' AND MAKE ANY EDITS BEFORE FINAL SUBMISSION

Stata .do file for GLM assignment. Contains all models, charts, and calculations
used in the report.
File is split into 4 parts, with each part corresponding to a separate question
on the assignment paper.

Aim: 
  To quantify the effect of smoking and waist to hip ratio on carotid
  plaque, adjusting for confounders.

Last modified on: 
  20230202

NOTES: 
  * This file will only run if the data file (assign2023.dta) is in the same
  folder as the script. Please ensure that you have this file & the data 
  file saved in the same location before running this file.
  * The code uses bootstrapping to estimate confidence intervals for odds ratios
  in part 2. The bootstrap uses 1000 replications so can take a while to run.
  The do_boot scalar below switches the bootstrap code on or off - I've kept the
  bootstrap setion on so the code reproduces everything in the report. If you
  want to turn the bootstrap section off just set do_boot = 0.
*/

scalar do_boot = 1  // Do you want to run bootstrap (=1) or not (=0)?

********************************************************************************
****** Part 1 - preliminary descriptive analysis

// Load data and get a quick look at the variables
use "assign2023.dta", clear
codebook // No missing data except for plaque_count (70% missing)

// Make table 1 - first make wider age groups to save space in report
gen ageg = 1 if age_cat <= 2
replace ageg = 2 if age_cat > 2 & age_cat <= 4
replace ageg = 3 if age_cat > 4
label define ageg_labs 1 "40-49" 2 "50-59" 3 "60-69"
label values ageg ageg_labs

foreach var of varlist ageg sex education smoking {
	tabulate `var' plaque, row
	bysort `var': summarize plaque_count if !missing(plaque_count)
}

// Extra bits - not included in report

// How does plaque vary with whr within the categories? 
lowess plaque whr, by(education) // No sign of interaction
lowess plaque whr, by(sex)       // Bit steeper in males
lowess plaque whr, by(age_cat)   // Generally increases, bit weird in 50-4, 65-9
lowess plaque whr, by(smoking)   // Potential interaction in current smokers

// Crosstabs to examine relation between plaque status & categorical variables
foreach var of varlist age_cat education smoking sex {
	tabulate `var' plaque, chi2
}

********************************************************************************
****** Part 2 - smoking & plaque status

// Group data & fit a binomial logistic model
gen plaquecopy=plaque
collapse (count) plaquecopy (sum) plaque, by(sex age_cat smoking education)
rename plaquecopy n

glm plaque i.smoking i.age_cat i.sex i.education, family(binomial n) link(logit)
di 1 - chi2(e(df), e(deviance)) // p = .41822, no evidence of poor fit
est store m0

// More complex models & LR tests - fit quietly to save on uneeded output
qui glm plaque i.smoking##i.age_cat i.sex i.education, family(binomial n) link(logit)
est store m1
qui glm plaque i.smoking i.age_cat##i.education i.sex, family(binomial n) link(logit)
est store m2
qui glm plaque i.smoking##i.sex i.age_cat i.education, family(binomial n) link(logit)
est store m3
qui glm plaque i.smoking##i.age_cat##i.sex##i.education, family(binomial n) link(logit)
est store m4

lrtest m0 m1 // p = .659
lrtest m0 m2 // p = .891
lrtest m0 m3 // p = .155
lrtest m0 m4 // p = .418. Stick with initial model since no p < .05

// Residual analysis - no strong pattern, random scatter about 0. Good fit
qui glm plaque i.smoking i.age_cat i.sex i.education, family(binomial n) link(logit)
predict resid, pearson standard
gen rn = _n 
lowess resid rn, yline(0, lcolor(black))

// Switch back to individual level data & get marginal probs for smoking
use "assign2023.dta", clear
glm plaque i.smoking i.age_cat i.sex i.education, family(binomial) link(logit)

margins i.smoking
// Store probs and calculate odds ratios. Also get lower & upper for never
// smoker prob (needed for line 107)
scalar p_never = r(table)[1, 1] // .590
scalar p_ex = r(table)[1, 2]    // .612
scalar p_cu = r(table)[1, 3]    // .715
scalar p_never_l = r(table)[5, 1]
scalar p_never_u = r(table)[6, 1]

di (p_ex / (1 - p_ex)) / (p_never / (1 - p_never)) 
di (p_cu / (1 - p_cu)) / (p_never / (1 - p_never)) // ORs for table 2. CIs below

// How does 'everyone never smokes' compare to actual prevalence? % diff + nums
summarize plaque // 62.6% prevalence
di r(mean) - p_never, 2700 * (r(mean) - p_never)
di r(mean) - p_never_u, 2700 * (r(mean) - p_never_u)
di r(mean) - p_never_l, 2700 * (r(mean) - p_never_l)

// Bootstrap CIs for odds ratios
capture program drop or_bs
program or_bs, rclass
	glm plaque i.smoking i.age_cat i.sex i.education, family(binomial) link(logit)
	
	margins i.smoking
	scalar p_never = r(table)[1, 1]
	scalar p_ex = r(table)[1, 2]
	scalar p_cu = r(table)[1, 3]
	
	scalar ex_v_never = (p_ex / (1 - p_ex)) / (p_never / (1 - p_never))
	scalar cu_v_never = (p_cu / (1 - p_cu)) / (p_never / (1 - p_never))
	
	return scalar ex_v_never = ex_v_never
	return scalar cu_v_never = cu_v_never
	end

if do_boot {
	bootstrap ex = r(ex_v_never) cu = r(cu_v_never), rep(1000) seed(43): or_bs
	estat bootstrap, percentile
}

// Sense check - does empirical standardisation get same probabilities?
// First refit the model after running bootstrap to be consistent
qui glm plaque i.smoking i.age_cat i.sex i.education, family(binomial) link(logit)

gen smoking_orig = smoking
replace smoking = 1     // Make everyone never smokers
predict pred_never, mu  // Predicted probs. Repeat for other smoking status
replace smoking = 2 
predict pred_ex, mu
replace smoking = 3
predict pred_current, mu

// Put smoking back to how it was
replace smoking = smoking_orig
drop smoking_orig

summarize pred_never pred_ex pred_current // Means are same as margins output
drop pred_never pred_ex pred_current      // Tidy up

********************************************************************************
****** Part 3 - waist to hip ratio (whr) & plaque status

gen w2h = 10 * whr // Scaled so coef is 0.1 unit change

// Add waist to hip ratio, examine poss interaction with LR tests
qui glm plaque i.smoking i.age_cat i.sex i.education, family(binomial) link(logit)
est store m0
glm plaque w2h i.smoking i.age_cat i.sex i.education, family(binomial) link(logit) 
est store m1
lrtest m0 m1 // p < 0.0001. Definite improvement to model from part 2

// Try interactions between age_cat and smoking
qui glm plaque c.w2h##i.smoking i.age_cat i.sex i.education, family(binomial) link(logit)
est store m2
qui glm plaque c.w2h##i.age_cat i.smoking i.sex i.education, family(binomial) link(logit)
est store m3

lrtest m1 m2
lrtest m1 m3 // No significant improvements, use m1 w2h estimate in report

// Add in interaction between W2H & sex
glm plaque c.w2h##i.sex i.smoking i.age_cat i.education, family(binomial) link(logit)
est store m4
lrtest m1 m4 // p = 0.6931. Keep because model useful for our aims

// Increase of 0.1 whr (increase w2h by 1) in females & males
lincom w2h, eform
lincom w2h + 1.sex#w2h, eform

// Prevalence estimates if no-one obese:
// Make changes in w2h based on WHO guidelines, then get marginals
gen whr_who = whr
replace whr_who = 0.9 if sex == 1 & whr > 0.9
replace whr_who = 0.85 if sex == 0 & whr > 0.85
gen w2h_who = 10 * whr_who

gen w2h_copy = w2h
replace w2h = w2h_who

margins // Estimated prevalence if WHO obesity guidelines followed

// Sense check - does margins output match up with empirical?
predict p_who, mu
summarize p_who // Yes

// Tidy up - change w2h back to actual values & remove extra vars
replace w2h = w2h_copy
drop whr_who
drop w2h_who
drop w2h_copy

********************************************************************************
****** Part 4 - modelling count data (negative binomial models)

// Filter to observations with plaque_count recorded
keep if !missing(plaque_count)

// Fit negative binomial models due to overdispersion from part 1
nbreg plaque_count i.smoking i.age_cat i.sex i.education
est store m0

// Try interactions between age & sex, age & smoking
qui nbreg plaque_count i.smoking i.age_cat##i.sex i.education
est store m1
qui nbreg plaque_count i.smoking##i.age_cat i.sex i.education
est store m2

lrtest m0 m1
lrtest m0 m2 // Not significant, dont add to model

// For part 4a
nbreg plaque_count i.smoking i.age_cat i.sex i.education
lincom 2.smoking, eform // Mean plaque count increase - ex vs never smokers
lincom 3.smoking, eform // Current vs never smokers


// For part 4b - add w2h to model
nbreg plaque_count w2h i.smoking i.age_cat i.sex i.education
lincom w2h, eform // Mean plaque count increase for 0.1 increase in whr

// For part 4c - add interaction on w2h & sex
nbreg plaque_count c.w2h##i.sex i.smoking i.age_cat i.education
lincom w2h, eform // Females
lincom w2h + 1.sex#c.w2h, eform // Males