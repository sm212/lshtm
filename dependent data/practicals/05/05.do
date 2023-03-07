use "../data/beta_blocker.dta", clear

// Longitudinal data with missing values (increase as trial goes on). Look at
// the drop off over time - active group falls out faster, especially at 6
label define treat 0 "P" 1 "A"
label value treat treat
tabstat pre dbp*, by(treat) stat(count mean sd)

/*
Possibly because active drug is better than placebo, so people drop out of the
trial because they start to get better compared to placebo group
*/

// Q2 - plot mean DBP over time for treatment and control groups
preserve
collapse (mean) pre dbp*, by(treat)
rename pre dbp0
reshape long dbp, i(treat) j(time)
gen dbp_act = dbp if treat == 1
gen dbp_plc = dbp if treat == 0
twoway (line dbp_act time, sort) (line dbp_plc time, sort)
restore

// Q3
bysort treat: pwcorr dbp*, obs
pwcorr dbp*, obs

// Q4 - reshaping and calculating difference in pre vs grand mean
summarize pre
gen mean_pre = r(mean)
reshape long dbp, i(id) j(time)
gen c_pre = pre - mean_pre
egen pickone = tag(id)

// Q5
hist dbp, by(time) // Looks normal (few data points as time goes on but ok)

// Q6 - random intercept model
mixed dbp time treat c_pre || id:, reml stddev

/*
Interpretation: The mean intercept (for someone in the placebo group at time 0,
with a pre-treatment DBP equal to the overall mean) is 92.2 [90.5, 93.9], the
clusters vary about this mean with a standard deviation of 5.7 [5.0, 6.6]. DBP
drops over the course of the study, decreasing by .34 [.66, .02] mmHg between
each visit. The average treatment effect is a decrease of 5.3 [3.4, 7.2] mmHg
on DBP. People who's baseline DBP is 1 mmHg above the overall average baseline
have a DBP which is on average .2 [.1, .4] mmHg higher at all subsequent times.
*/

// Q7 - model diagnostics
predict r_inter, reffects
predict res_std, rstandard

qnorm r_inter if pickone == 1 // Level 2 residuals are normal
qnorm res_std // As are level 1, though some evidence of deviance in the tails