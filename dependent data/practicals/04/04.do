use "../data/gcse_selected.dta", clear

// Data prep
egen pickone = tag(school)
label define schgen 1 "mixed" 2 "boys only" 3 "girls only"
label values schgen schgen
tabulate schgen if pickone == 1 // Number of different school types

egen av_gcse = mean(gcse), by(school)
egen av_lrt = mean(lrt), by(school)
egen av_girl = mean(girl), by(school)
summarize av_* if pickone == 1

// Fixed effect models

// Replicate what was in slides
drop if school == 48
reg gcse lrt ibn.school, nocon // sigma^2_e = 7.52

reg gcse i.schgen // sigma^2_e = 9.93, model explains less of the variance
				  // Also - sex specific schools do better than mixed, esp girls
				  
// Mixed effect models p1 - intercept only

mixed gcse lrt || school:, reml stddev // Random intercept model, LL = -14022
									   // simga^2_e = 7.52, as before
									   // => clusters alone not capturing var
									   
/*
The estimated effect of LRT is .56 [.54, .59], the mean intercept is
.03 [-.76, .83], and the intercepts vary normally about this mean with standard
deviation 3.07 [2.52, 3.75].

Null hypothesis is simga^2_u = 0, ie comparing the likelihood of the mixed 
effect model to a linear model with NO SCHOOL PREDICTOR and FIT BY ML. See LLs
from output of next two lines for numbers
-2 * (-14220.23201 - -14018.571) = 403.32202, as reported by stata.
Need to fit both models by ML so its a valid comparison
*/

mixed gcse lrt || school:, ml    // LL = -14018.571 
glm gcse lrt, family(gaussian)   // LL = -14220.23201 


mixed gcse lrt i.schgen || school:, reml stddev // LL = -14016.32
di 1 - chi2(2, -2 * (-14016.32 - -14022)) // p = 1, Not sig better
// ??? How to do this using test?

// Mixed effect models p2 - coefs

mixed gcse lrt i.schgen || school: lrt, reml cov(unstructured) stddev
est store rc // LL = -13994.393

// Is this an improvement on the intercept only model?
mixed gcse lrt i.schgen || school:, reml stddev
est store ri // LL = -14016.32

lrtest rc ri // LRT = 43.85, p-val < 0.0001. RC better fit than RI
scalar lrt_byhand = -2 * (-14016.32 - -13994.393)
di lrt_byhand, chi2tail(2, lrt_byhand) // Same result as lrtest

mixed gcse lrt i.schgen || school: lrt, reml stddev
est store rc_indep
lrtest rc rc_indep // Unstructured covariance matrix better fit than identical

// Reload the data and redo some calculations with school 48 (2 obs) included
use "../data/gcse_selected.dta", clear

reg gcse lrt if school == 48 // LRT coef is huge, 'model' just links points
twoway (scatter gcse lrt) (lfit gcse lrt) if school == 48

mixed gcse lrt i.schgen || school: lrt, reml cov(unstructured) stddev
/*
But hardly any change at all to the mixed model - daft estimate for school 48
is getting shrunk towards the school population mean because there's so few data
*/

// Level 2 residuals - pretty much unchanged compared to the previous model
egen pickone = tag(school)
predict l2_slope l2_int if pickone == 1, reffects

qnorm l2_slope if pickone == 1
qnorm l2_int if pickone == 1

// Level 1 residuals - normal
predict l1_resid, rstandard
qnorm l1_resid