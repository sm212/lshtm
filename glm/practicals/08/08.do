clear
use "http://www.stata-press.com/data/hh3/medpar"

// Q1 - look at the data, make a CI for LOS
browse
codebook
graph bar died, by(white)
graph bar died, by(age)
summarize

/* 
mean LOS = 9.854181, SD =  8.832906, N = 1495
-> SE = SD / sqrt(N) = 8.832906 / sqrt(1495) = .22844571
-> CI = [mean - 1.96 * SE, mean + 1.96 * SE] = [9.41, 10.30]
*/

// Q2 - basic Poisson model
glm los, family(poisson) link(log) eform // cons = mean LOS

// Q3 - robust Poisson
glm los, family(poisson) link(log) robust eform

/*
| method | mean |      CI       |
---------------------------------
|   Q1   | 9.85 | [9.41, 10.30] |
|   Q2   | 9.85 | [9.70, 10.01] |
|   Q3   | 9.85 | [9.42, 10.31] |

Q2 CI is least appropriate because of overdispersion (deviance / df ~ 6), so a
poisson model would underestimate the actual variance resulting in a overly
narrow CI. Q1 assumes LOS is normally distributed so more accurately estimates
the variance and gets a more resonable CI, and the robust poisson model in Q3
gets similar results - so Q1 & Q3 are most appropriate
*/

// Q4 - add type of admission
glm los i.type1 i.type2 i.type3, family(poisson)
/*
Admission type is strongly associated with length of stay, patients with 
admission type 3 have a significantly longer length of stay on average compared
to people with admission type 2 or 1.
The average LOS for people with admission type = 3 is e(2.9) = 18.2 days, for
people with type = 2 its e(2.9 -.488) = 11.2, and for type = 1 its 
e(2.9 - .725) = 8.8.
*/

// Q5 - add age
glm los i.type1 i.type2 i.type3 i.age, family(poisson)

/*
L: log likelihood
dof: number of residual degrees of freedom
m1: los ~ admiss_type
m2: los ~ admiss_type + age

L(m1) = -6949.388592, dof(m1) = 1492
L(m2) = -6940.167491, dof(m2) = 1484
-2 * (L(m1) - L(m2)) = 18.44
Compare to a chi square with dof(m1) - dof(m2) = 8 degrees of freedom:
1 - chi2(8, 18.44) = 0.018
Age is a predictor of LOS adjusting for admission type. This test is appropriate
because the models are nested
*/

// Make stata do it for you
glm los i.type1 i.type2 i.type3, family(poisson)
est store m1
glm los i.type1 i.type2 i.type3 i.age, family(poisson)
est store m2
lrtest m2 m1

// Q6 - LRT isnt applicable to robust regression, so need to do MV wald test
glm los i.type1 i.type2 i.type3 i.age, family(poisson) link(log) robust
testparm i.age // Age not significant after adjusting for admission type

/*
Prefer the outputs from robust regression, the SE estimates from regular 
poisson regression assume the model is correctly specified so the SEs can be
estimated from the information matrix. Quite likely that the model is missing
some important variables so no reason to assume that the model is correct
*/

gen admi_type = 1 if type1 == 1
replace admi_type = 2 if type2 == 1
replace admi_type = 3 if type3 == 1

tabulate age admi_type, chi

// Q7 - negative binomial regression (no variables)
nbreg los
/*
LRT is testing against a negative binomial with alpha = 0, ie just a poisson
model with no variables. This is what we fit back in Q3 (call it m0, and the 
negative binomial model m1). Then
L(m0) = -7308.141824
L(m1) = -4856.494 
Which gives a LR test stat of
-2 * (L(m0) - L(m1)) = 4903.30
There's one extra parameter between these two models (alpha), so the LRT stat
is distributed chi2(1) - this gives a p-value of 
1 - chi2(1, 4903.30) = 0. Strong evidence of overdispersion
*/

// Q8 - negative binom with variables
nbreg los i.type1 i.type2 i.type3 // e(b) contains params, try list matrix e(b)
/*
Output: cons = 2.903594, type1 = -.7253612, type2 = -.4880173, alpha = .4478236

Pred mean = exp(linear predictor)
Pred var = mean(1 + alpha * mean)
*/

scalar alpha = exp(e(b)[1,8]) // save alpha coef - only log(alpha) is reported
// type 1
scalar m1 = exp(e(b)[1, 7] + e(b)[1, 2])
scalar sd1 = sqrt(m1 * (1 + m1 * alpha))
// type 2
scalar m2 = exp(e(b)[1, 7] + e(b)[1, 4])
scalar sd2 = sqrt(m2 * (1 + m2 * alpha))
// type 3
scalar m3 = exp(e(b)[1, 7])
scalar sd3 = sqrt(m3 * (1 + m3 * alpha))

bysort admi_type : summarize los
di sd1, sd2, sd3 // Overestimates observed variance in admissions types != 3
di m1, m2, m3 // Pretty good at observed means though