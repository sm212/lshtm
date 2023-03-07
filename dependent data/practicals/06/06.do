use "../data/beta_blocker.dta", clear

// Continuation of 05.do - ended with random intercepts, now do coefs. First
// get the data in the same format as before
summarize pre
gen mean_pre = r(mean)
reshape long dbp, i(id) j(time)
gen c_pre = pre - mean_pre
egen pickone = tag(id)

// Q8 - random coefficients - allow time effect to vary within person
mixed dbp time treat c_pre || id: time, cov(unstructured) reml
est store m1

// Q9 - Look at diagnostics, stats reffects returns slope & intercept residuals
predict r_slope r_inter, reffects

qnorm r_slope if pickone == 1 // OK but some outliers in tails
qnorm r_inter if pickone == 1 // OK

// Q10 - is random coefficients better than random intercept?
mixed dbp time treat c_pre || id:, reml
est store m0

lrtest m1 m0 // p = 0.0003, random coef better

// Q11 - do slopes vary with treatment?
mixed dbp c.time##i.treat c_pre || id: time, cov(unstructured) reml
// z = 0.18, p = 0.86, no evidence that treatment effect varies over time

// Q12 -  calculating correlations by hand and comparing
mixed dbp time treat c_pre || id: time, cov(unstructured) reml

// Stata stores all parameter estimates in e(b). It stores the log of the SDs
// of all random effects, and tanh^{-1} of the correlation between them:
matrix b = e(b)
scalar idx_sig11 = colnumb(b, "lns1_1_1:")
scalar idx_sig00 = colnumb(b, "lns1_1_2:")
scalar idx_sig_e = colnumb(b, "lnsig_e:")
scalar idx_cor01 = colnumb(b, "atr1_1_1_2:")
scalar sig_11 = exp(b[1, idx_sig11])
scalar sig_00 = exp(b[1, idx_sig00])
scalar sig_e  = exp(b[1, idx_sig_e])
scalar cov_01 = tanh(b[i, idx_cor01]) * sig_00 * sig_11

foreach i of numlist 1/6{
	foreach j of numlist 1/6{
		if `j' == `i' di "cor(", `i', `j', ") = 1"
		if `i' < `j' {
			scalar cov = sig_00^2 + (`i' + `j') * cov_01 + `i' * `j' * sig_11^2
			scalar vi  = sig_00^2 + 2 * `i' * cov_01 + `i'^2 * sig_11^2 + sig_e^2
			scalar vj  = sig_00^2 + 2 * `j' * cov_01 + `j'^2 * sig_11^2 + sig_e^2
			di "cor(", `i', `j', ") =", cov / sqrt(vi * vj)
		}
	}
}

// Predicted correlations are close to observed

// Q13 - mean profiles in active & placebo groups
predict y_pred, fitted 
preserve
keep y_pred time id pre treat
reshape wide y_pred, i(id) j(time)
collapse pre y_pred*, by(treat)
rename pre y_pred0
reshape long y_pred, i(treat) j(time)
gen active = y_pred if treat == 1
gen placebo = y_pred if treat == 0
twoway (line active time) (line placebo time)
restore

// Q14 - predictions for a selection of patients
twoway (line y_pred time, sort) (scatter dbp time) if mod(id, 19) == 0, by(id)

// Q15 - standard errors
drop r*
predict est_slope est_inter, reffects reses(slope_se inter_se)
gen low = est_inter - 1.96 * inter_se
gen high = est_inter + 1.96 * inter_se
preserve
keep if pickone == 1
sort est_inter
gen person = _n
twoway (rspike low high person) (scatter est_inter person, msize(small)) if pickone == 1
restore