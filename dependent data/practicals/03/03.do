use "../data/hsb_selected.dta", clear
egen pickone = tag(schoolid)

// Q2 - difference between REML & ML for large sample size
di _N // 7185 obs
mixed mathach ses || schoolid:, reml stddev
mixed mathach ses || schoolid:, ml stddev

/*
No huge difference (large sample size).
\sigma_u = 2.17, \sigma_e = 6.08
*/

// Q3 - impact of including sector on the standard deviations
bysort sector: summarize mathach
graph box mathach, over(sector)

mixed mathach ses sector || schoolid:, reml stddev
mixed mathach ses sector || schoolid:, ml stddev
/*
\sigma_u = 1.90, \sigma_e = 6.08
*/

// Q4
summarize size
gen c_size = (size - r(mean)) / 100

mixed mathach ses sector c_size || schoolid:, reml stddev
mixed mathach ses sector c_size || schoolid:, ml stddev
/*
\sigma_u = 1.91, \sigma_e = 6.09. Almost no change from previous model
*/

// Q5
mixed mathach ses i.sector##c.c_size || schoolid:, reml stddev
mixed mathach ses i.sector##c.c_size || schoolid:, ml stddev

/*
No strong evidence of an effect (Wald test on interaction coefficient = .07).
\sigma_u = 1.89, \sigma_e = 6.09. Summary table for Q6

| model | sig_u_reml | sig_e_reml | sig_u_ml | sig_e_ml |
|------ | ---------- | ---------- | -------- | -------- |
|   1   |    2.18    |    6.09    |   2.17   |   6.09   |
|   2   |    1.92    |    6.09    |   1.90   |   6.09   |
|   3   |    1.91    |    6.09    |   1.88   |   6.09   |
|   4   |    1.89    |    6.09    |   1.85   |   6.09   |
*/

// Q7 - adding cluster level covariates
mixed mathach ses i.sector##c.c_size female minority || schoolid:, reml stddev

/*
Reduces sigma_u but doesnt change sigma_e very much. Makes sense because these
are all level 2 variables they can only effect the variation across the clusters,
not within
*/

// Q8 - is female & minority (level 1) associated with sector (level 2)
tabulate sector minority, chi2 column nokey // Sig assoc (sig higher in christian)
tabulate sector female, chi2 column nokey   // No sig assoc

// Does the effect of female or minority vary by sector?
mixed mathach ses i.sector##c.c_size i.sector##i.female minority || schoolid:, reml stddev // 0.709 - No evidence of variation of effect by sector
mixed mathach ses i.sector##c.c_size i.sector##i.minority female || schoolid:, reml stddev // <0.0001 - Evidence of variation of effect by sector

// Q9 - level 1 & 2 residuals on Q7 model
mixed mathach ses i.sector##c.c_size female minority || schoolid:, reml stddev
predict uhat_eb, reffects reses(uhat_eb_se) // Level 2 (unstandardised!)
predict ehat, rstandard                     // Level 1
browse

// Need to standardise the level 2 residuals before looking at diagnostics
bysort schoolid: gen n_child = _N // Adds in count of obs for each schoolid
gen R = 1.481716^2 / (1.481716^2 + 5.980756^2 / n_child)
gen var_sig_uj = R * 1.481716^2
gen uhat_eb_std = uhat_eb / sqrt(var_sig_uj)

// Level 1 plots - bit weird at large values
summarize ehat
hist ehat
qnorm ehat

// Level 2 plots - not bad (need to do pickone otherwise you try to plot individs!!)
summarize uhat_eb_std if pickone
hist uhat_eb_std if pickone
qnorm uhat_eb_std if pickone

// Q10 - find weird schools
list schoolid if pickone == 1 & abs(uhat_eb_std) > 2, noobs

// Q11
egen mean_ses = mean(ses), by(schoolid)
gen diff_ses = ses - mean_ses

mixed mathach ses || schoolid:, reml stddev
mixed mathach mean_ses diff_ses || schoolid:, reml stddev
test mean_ses == diff_ses