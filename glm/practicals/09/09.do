clear
use "../data/rubber.dta"
browse

// Q1 - crude death rates
total deaths pyrs // CDR = 160 / 19345 = .00827087 = 8.3 deaths per 1000 years

// Q2 - crude death rates by factory
total deaths pyrs, over(factory) // F1 = 7.4 per 1kPY, F2 = 9.2 per 1kPY

// Q3 - plot
gen l_dr = log(deaths / pyrs)
twoway scatter l_dr agegrp, mlabel(factory)
// Deaths increase with age and are higher in factory 2

// Q4 - initial model
// l_dr = b_0 + b_1[60] + b_2[70] + b_3[80]

// Q5 - estimates
gen l_deaths = log(deaths)
gen l_pyrs = log(pyrs)
glm deaths i.agegrp, family(poisson) link(log) offset(l_pyrs)

// Strong evidence of an age effect. Risk estimates are:
// Risk of death in 60-69 year olds relative to 50-59 year olds
di exp(1.582834), exp(1.004549), exp(2.161118) // Almost 4x higher

// Risk of death in 80-89 year olds relative to 70-79 year olds
lincom 4.agegrp - 3.agegrp
di exp( .2517118), exp(-.2822054), exp(.7856289) // ~30% higher

// Q6 - with factory
glm deaths i.agegrp i.factory, family(poisson) link(log) offset(l_pyrs) eform
// Weak evidence for a between factory effect - p = 0.226. CI contains 0 
testparm 2.factory

// Q7 - with interaction (saturated model)
glm deaths i.agegrp##i.factory, family(poisson) link(log) offset(l_pyrs)
/* 
Weak evidence for factory effect - no significant coef estimates.
Model has the form
d = b0 + b1[60] + b2[70] + b3[80] + b4[f2] + b5[f2][60] + b6[f2][70] + b7[f2][80]
8 params fitted to 8 datapoints.

Log death rates for certain situations are:
F1, 70-79 = b0 + b2 = -6.359327 + 2.277842 = -4.08
F2, 50-59 = b0 + b4 = -6.359327 + .0888786 = -6.27
F2, 60-69 = b0 + b1 + b4 + b5 = -6.36 + 1.47 + 0.09 + 0.19 = -4.61

Exactly matches to data, which is what you'd expect with a saturated model
*/

// Q8 - continuous agegrp
glm deaths agegrp i.factory, family(poisson) link(log) offset(l_pyrs) eform
// For every ~10 year increase in age, risk of death increases by ~120%

// Could also try continuous age with interaction on factory
glm deaths c.agegrp##i.factory, family(poisson) link(log) offset(l_pyrs) eform
// Not a huge change

/*
Q9 - conclusion: age has a significant impact on risk of death in factory
workers. There is some evidence of the death rates differing by factory, though
the difference is not significant.
Our models show evidence of overdispersion, this overdispersion remains even in
robust poisson models. This suggests that the model fit could potentially be 
improved - for example by gathering data on additional variables which may 
impact risk of death
*/
