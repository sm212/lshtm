clear
webuse "lbw"
browse

// Q1 fitting model syntax
glm low lwt, family(binomial) link(logit) // Coeffs & CIs are log odds ratios
logistic low lwt // Coeffs & CIs have been expoentiated - odds ratios
logit low lwt // Shorthand for glm command on line 5

// Q2 is the effect linear on the logit scale?
predict prob // pr option tells stata to compute the probabilities from logit model
twoway (scatter low lwt) (lowess low lwt) (scatter prob lwt)

/*
Looks ok - bit of a gap between model and actual in the middle but otherwise
fine. Wouldn't expect perfect smooth relationship between lwt and low anyway due
to sample variability, so some discrepancy is fine
*/

// Q3 - prediction for specific value (by hand)
/*
From stata: cons = .9957626, lwt = -.0140371. So prob of low birth weight is
P(low|lwt=120) = 1 / (1 + exp(-(.9957626 + -.0140371 * 120))) = .334
*/

// Q4 - same prediction, make stata do the work
lincom _cons + lwt * 120 // Gives prediction results on the logit scale
/*
Output from lincom = -.6886911, so
log(p / (1-p)) = -.6886911
p / (1-p) = exp(-.6886911)
p = exp(-.6886911) / (1 + exp(-.6886911)) = 1 / (1 + exp(.6886911)) = .334
*/

// Q5 - does adding race to model improve performance?
logit low lwt i.race
/*
m1: low ~ lwt
m2: low ~ lwt + race

LL(m1) = -114.35403 
LL(m2) = -111.63836 
LR(m1, m2) = -114.35403 - -111.63836 = -2.71567
Compare -2LR(m1, m2) = 5.43 to a chi square with 2 DOF:
*/
di chi2tail(2, 5.43) // p = 0.066, some weak evidence that low assoc with race

// Can also make stata do it for you - need to save each model as you go
logit low lwt
est store m1
logit low lwt i.race
est store m2

lrtest m2 m1

// Q6 - understanding LR part of output
/*
If you run logit or logisitic, stata automatically outputs a LR stat and p-val.
These compare the log likelihood of the current model to a null model. If we 
get the log likelihood from the null model:
*/
logit low // LL = -117.336
/*
and use this to form the log likelihood ratio test stat -2LR:
LR = LL(mod_null) - LL(mod) = -117.336 - -111.63836 = -5.69764
-2LR = 11.4
Which is what stata outputs automatically. In this case it says that the model
which uses mothers weight is significantly better than the null model
*/

// Q7 - Hosmer Lemeshow GOF
logit low lwt
estat gof, group(10) // No evidence of poor model fit. p-val varies with n so
					 // unreliable test (since it depends on arbitrary n_group)
					 
// Q8 - GOF on grouped data (can use deviance instead of LL, but equiv)
clear
use "../data/insect.dta"
glm r dose, family(binomial n) link(logit) // Deviance = 4.615 (m1)
di chi2tail(8-2, 4.615) // p = 0.59, no evidence of poor fit

// Could also compare against a saturated model
gen rn = _n
glm r dose i.rn, family(binomial n) link(logit) // LL = - -14.38925003 (m2)
/*
LL(m1) = -16.69698926  
LR(m1, m2) = -16.69698926 - -14.38925003 = -2.308
-2LR = 4.615, compare to chi square with 8-2 DOF
*/

// Q9 - does adding a quadratic term help model fit
gen quad = dose^2
glm r dose quad, family(binomial n) link(logit) // No, Wald test not sig