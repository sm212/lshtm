use "../data/pefr.dta", clear
browse

// Scatter of measurements about the total mean.
// Bit less variation compared to the WM chart
twoway (scatter wp1 id) (scatter wp2 id), xtitle(Subject ID) ytitle(W) yline(447.8824)

// Q3 - reshape data
reshape long wp wm, i(id) j(occasion)
tabstat wp wm, by(id) statistic(mean)

// Q4 - ANOVA
loneway wp id // Between ID MS = 27599.908, within ID MS = 234.29412, n = 2
di sqrt((27599.908 - 234.29412) / 2) // Between ID variation SD, already reported

// Q5 - same result with regression but taking first id as reference
regress wp i.id // y_{ij} = \mu + \alpha_j + [id_i] + e_{ij}

// Q6 - variation from mean
summarize wp
gen c_wp = wp - r(mean)
regress c_wp ibn.id, nocons // ibn tells stata to include all levels of the factor

// Q7 high school & beyond data
use "../data/hsb_selected.dta", clear
browse

sort schoolid
egen pickone = tag(schoolid) // 1 if first obs with schoolid val
tab sector if pickone
summarize size if pickone

// Q8 - Filter to first 5 schools, calculate mean SES & maths scores for each
keep if schoolid < 1320
egen mean_ses = mean(ses), by(schoolid)
egen mean_math = mean(mathach), by(schoolid)

// Q9 - Total regression, ignoring cluster structure
scatter mathach ses
regress mathach ses
predict pred_T, xb // Linear predictor (mean mathach)

// Q10 - Between regression using cluster means
regress mean_math mean_ses if pickone
predict pred_B if pickone // xb is the default so dont need to specify

// Q11 - merge
statsby inter=_b[_cons] slope=_b[ses] seslope=_se[ses], by(schoolid) ///
saving(ols,replace): regress mathach ses
sort schoolid
merge m:1 schoolid using ols
gen pred_W = inter + slope * ses

// Q12 - different predictions are close to each other
summarize pred_*

// Q13
sort school ses
twoway (line pred_W ses, connect(ascending) lcol(green) lpat(dash)) ///
(line pred_T ses, connect(ascending) lcol(blue) lw(medium) ) ///
(line pred_B mean_ses, connect(ascending) sort lcol(red) lw(thick)) ///
(scatter mean_math mean_ses, msym(T) mcol(red)), ///
xtitle(SES) ///
ytitle(Fitted regression lines) ///
legend(order(1 "Within" 2 "Total" 3 "Between" 4 "School Mean"))

// Q14
regress mathach ses i.schoolid