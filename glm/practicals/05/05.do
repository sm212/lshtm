clear
import delimited "../data/kidney_example.csv"

// Make tables
tabulate y x
bysort z : tabulate y x

// Q1
glm y i.x i.z, family(binomial) link(logit)
glm y i.x##i.z, family(binomial) link(logit)

// Q2
predict ypred, mu
summarize ypred if x == 1 & z == 0 // .133
summarize ypred if x == 0 & z == 0 // .069
summarize ypred if x == 1 & z == 1 // .313
summarize ypred if x == 0 & z == 1 // .270

/*
conditional risk difference
Z = 0: .133 - .069 = .064
Z = 1: .313 - .270 = .043

conditional risk ratio
Z = 0: .133 / .069 = 1.93
Z = 1: .313 / .270 = 1.16

Same direction as table 5.2 but slightly larger effect sizes (bc adjusted?).
The probability of treatment failure is higher in all groups if everyone
received lithotripsy (.064 larger in the small stone group, .043 larger in the 
large stone group). Would need Z to be the only confounder for this to be causal
*/

// Q3
tabulate z // P(Z = 0) = 0.51, P(Z = 1) = 0.49
gen p_z = 0.51 if z == 0
replace p_z = 0.49 if missing(p_z)
gen prod = p_z * ypred

summarize prod if x == 1 & z == 0 // .068
summarize prod if x == 0 & z == 0 // .035
summarize prod if x == 1 & z == 1 // .153
summarize prod if x == 0 & z == 1 // .132

/*
P(Y=1|do(X=1)) = .068 + .153 = .221
P(Y=0|do(X=0)) = .035 + .132 = .167

Interp: The probability of treatment failure is higher if we gave everyone in 
the study population surgery, and if we gave everyone in the study population
lithotripsy
*/

// Q4
margins x
margins x, dydx(x) // prob of failure higher if everyone got lithotripsy, not sig

// Q5 - use model formula directly to get probs in each group
di 1 / (1 + exp(-(-2.60269))) 								   // P(Y=1|X=0,Z=0) = .069
di 1 / (1 + exp(-(-2.60269 + .7308873))) 					   // P(Y=1|X=1,Z=0) = .133
di 1 / (1 + exp(-(-2.60269 + 1.607874))) 					   // P(Y=1|X=0,Z=1) = .270
di 1 / (1 + exp(-(-2.60269 + 1.607874 + .7308873 - .5245292))) // P(Y=1|X=1,Z=1) = .312
/*
P(Z=0) = 0.51
P(Z=1) = 0.49
P(Y=1|X=0) = P(Y=1|X=0,Z=0)P(Z=0) + P(Y=1|X=0,Z=1)P(Z=1)
		   = .069*.51 + .27*.49
		   = .167
		   
P(Y=1|X=1) = P(Y=1|X=1,Z=0)P(Z=0) + P(Y=1|X=1,Z=1)P(Z=1)
		   = .133*.51 + .312*.49
		   = .221
		   
P(Y=1|X=1) - P(Y=1|X=0) = .221 - .167 = .054
*/


clear
import delimited "../data/kidney_example_continuousY.csv"

// Q7
summarize y if x == 0 & z == 0 //  .201
summarize y if x == 1 & z == 0 //  .556
summarize y if x == 0 & z == 1 // -.848
summarize y if x == 1 & z == 1 //  .130

// Q8
regress y i.x##i.z // Same coeffs

// Conditional mean differences. Causal if Z only confounder
di .556 - .201  // E[Y|do(X=1),Z=0] - E[Y|do(X=0),Z=0] = .355
di .130 - -.848 // E[Y|do(X=1),Z=1] - E[Y|do(X=0),Z=1] = .978

// Q9 marginal effects by standardisation & using margins
tabulate z // Still have P(Z=1) = 0.49, P(Z=0) = 0.51
gen p_z = 0.49 if z == 1
replace p_z = 0.51 if missing(p_z)
predict ypred
gen prod = ypred * p_z

summarize prod if x == 0 & z == 1 // -.416
summarize prod if x == 1 & z == 1 //  .064
summarize prod if x == 0 & z == 0 //  .103
summarize prod if x == 1 & z == 0 //  .284

/*
E[Y|do(X=1)] = .064 + .284 =  .348
E[Y|do(X=0)] = .103 - .416 = -.313
E[Y|do(X=1)] - E[Y|do(X=0)] = .348 - -.313 = .661

Average happiness scores would be higher in the study population if everyone
received surgery?
*/

margins x, dydx(x)

// Q10
summarize ypred if x == 1 & z == 0 

// Q11
regress y i.x i.z // Conditional mean difference is 1.x term
margins x