use "../data/ghq.dta", clear
browse

// Q1 - make mean GHQ score on wide data
gen m_ghq = (GHQ1 + GHQ2) / 2
summarize m_ghq

// Q2 - reshape and calculate on long data
drop m_ghq
reshape long GHQ, i(id) j(occasion)
tabstat GHQ, by(id) statistic(mean sd) // Same mean, slightly diff SD

xtsum GHQ, i(id) // Need to tell xtsum what the cluster variable is

// Q3 - ANOVA
loneway GHQ id // Slightly different to xtsum - larger within, smaller between

// Q4 - mixed effect model
mixed GHQ || id:, reml stddev // Same SD ests as the ANOVA in last question

// Q5 - mixed effect model, fit with ML
mixed GHQ || id:, ml stddev
/*
Smaller parameter & SD estimate for within estimate. Makes sense because the 
MLE is biased (divides by too large a number)
*/

// Q6 - fixed effect for deviation about the mean, calculate SD of intercepts
summarize GHQ
gen c_GHQ = GHQ - r(mean)
regress c_GHQ ibn.id, nocons

matrix A = e(b)
svmat A, names(alpha)
egen mean_id = rmean(alpha1 - alpha12)
egen sd_id = rsd(alpha1 - alpha12)
list mean_id sd_id in 1

/*
Fixed effects have mean zero (needed so the parameters can be estimated), and
standard deviation 6.07. This is an estimate of the between cluster SD (??).
Mixed model estimates the between (residual) SD - from REML - as 1.91, so 
very overestimated
*/

// Q7
reg GHQ // Cons is overall mean of the data, SD is estimate of between cluster SD

// Q8
reg GHQ, robust cluster(id)

/*
Q7 regression correctly estimates the data mean but get the variance wrong. The
variance estimate is too small because it's ignoring the data structure and 
treating all the points as independent.
Q8 regression then clusters the errors and more accurately models the data
structure. This gets a more accurate estimate (1.75) of the true variance (1.91)
but still isn't perfect
*/