clear
import delimited "../data/kidney_example.csv"
browse

// PART A - make marginal & conditional effect estimates from practical 5
// P(Z=1) = 0.49, P(Z=0) = 0.51
glm y x z, family(binomial) link(logit)
predict ypred, mu
gen p_z = 0.49 if z == 1
replace p_z = 0.51 if missing(p_z)
gen prod = ypred * p_z

// Conditional estimates
mean y if x == 0 & z == 0 // P(Y=1|X=0,Z=0) = .069
mean y if x == 1 & z == 0 // P(Y=1|X=1,Z=0) = .133
mean y if x == 0 & z == 1 // P(Y=1|X=0,Z=1) = .270
mean y if x == 1 & z == 1 // P(Y=1|X=1,Z=1) = .313

// Marginal estimates - by standardisation
mean prod if x == 0 & z == 0 // P(Y=1|X=0,Z=0)P(Z=0) = .047
mean prod if x == 1 & z == 0 // P(Y=1|X=1,Z=0)P(Z=0) = .064
mean prod if x == 0 & z == 1 // P(Y=1|X=0,Z=1)P(Z=1) = .129
mean prod if x == 1 & z == 1 // P(Y=1|X=1,Z=1)P(Z=1) = .165

/*
Q1
Conditional risk differences:
P(Y=1|X=1,Z=0) - P(Y=1|X=0,Z=0) = .133 - .069 = .064
P(Y=1|X=1,Z=1) - P(Y=1|X=0,Z=1) = .313 - .270 = .043

Marginal risks:
P(Y=1|X=1) = P(Y=1|X=1,Z=0)P(Z=0) + P(Y=1|X=1,Z=1)P(Z=1) = .064 + .165 = .229
P(Y=1|X=0) = P(Y=1|X=0,Z=0)P(Z=0) + P(Y=1|X=0,Z=1)P(Z=1) = .047 + .129 = .176

Marginal risk difference:
P(Y=1|X=1) - P(Y=0|X=0) = .229 - .176 = .053

Risk differences are collapsible with weights P(Z), so the MRD should equal
MRD = CRD(Z=0)P(Z=0) + CRD(Z=1)P(Z=1) = .064*0.51 + .043*0.49 = 0.54 (rounding)	

Q2
Conditional risk ratios:
P(Y=1|X=1,Z=0) / P(Y=1|X=0,Z=0) = .133 / .069 = 1.928
P(Y=1|X=1,Z=1) / P(Y=1|X=0,Z=1) = .313 / .270 = 1.159

Marginal risk ratio:
P(Y=1|X=1) / P(Y=0|X=0) = .229 / .176 = 1.301

Risk ratios are also collapsible, but weights are more complicated...
w(Z=z) = P(Y=1|X=0,Z=z)P(Z=z)/P(Y=1|X=0)
But we have all these terms already so its not too hard to calculate:
w(Z=0) = P(Y=1|X=0,Z=0)P(Z=0)/P(Y=1|X=0) = .069*0.51/.176 =  .1999
w(Z=1) = P(Y=1|X=0,Z=1)P(Z=1)/P(Y=1|X=0) = .270*0.49/.176 =  .752

Marginal risk ratio should be equal to
MRR = CRR(Z=0)w(Z=0) + CRR(Z=1)w(Z=1) = 1.928*.1999 + 1.159*.752 = 1.30 (rounding)

Q3
Can't do the same for the marginal odds ratio because it it non collapsible

Interp:
MRD - change in probability of treatment failure if the entire study pop received
treatment X=1 vs X=0
CRD - change in probability of treatment failure if people with Z=z received
treatment X=1 vs X=0

The marginal is useful for policy decisions, conditional is more useful for
individuals who know their Z
*/

// PART B - Binary outcome, binary confounder (OR not collapsible)
clear
use "../data/simdata_binary"

// Q4
cor x z // = 0, no association

// Q5
glm y i.x##i.z, family(binomial) link(logit)
/*
Y ~ X + Z + XZ. Coeffs
cons = -2.197225, X = 2.197225, Z = 2.197225, XZ = 0

P(Y=1|X=1,Z=1) = 1 / (1 + exp(-(cons + X + Z))) = .9
P(Y=1|X=0,Z=1) = 1 / (1 + exp(-(cons + Z)))     = .5
P(Y=1|X=1,Z=0) = 1 / (1 + exp(-(cons + X)))     = .5
P(Y=1|X=0,Z=0) = 1 / (1 + exp(-(cons)))         = .1

CRD(Z=1) = P(Y=1|X=1,Z=1) - P(Y=1|X=0,Z=1) = .9 - .5 = .4
CRD(Z=0) = P(Y=1|X=1,Z=0) - P(Y=1|X=0,Z=0) = .5 - .1 = .4

Q6
Same conditional effect in both groups, so marginal also = .4

Q7
COR(Z=1) = .9 / (1 - .9) / .5 / (1 - .5) = 9
COR(Z=0) = .5 / (1 - .5) / .1 / (1 - .1) = 9

The coefficients are conditional odds ratios (logged), so can just exp(coef) to
get same result faster, the 'eform' option does this for you automatically
*/
glm y i.x##i.z, family(binomial) link(logit) eform

// Q8
glm y x, family(binomial) link(logit) // MOR = 5.44 (!= COR bc non-collapsible)

// PART C - Binary outcome, continuous confounder (OR not collapsible)
clear
use "../data/simdata_binary2"

// Q9
glm y i.x##c.z, family(binomial) link(logit)
/*
Model says logit(Y|X,Z) = beta_0 + beta_1*X + beta_2*Z + beta_3*XZ, so log(COR)
is logit(Y|X=1,Z) - logit(Y|X=0,Z) = beta_1 + beta_3*Z. Gives a COR of
COR = exp(beta_1 + beta_3*Z).

median(Z) = 27.56752, 10% = 20.03107, 90% = 35.10567, gives COR of
0.93, 1.49, and 0.58
*/

// Q10
// Empirical std - predict outcome for everyone, average and take difference.
// Model coeffs stored in e(b) as row vector
gen x0 = 0
gen x1 = 1

matrix list e(b) // Look at coefficients
gen p_x0 = 1 / (1 + exp(-(e(b)[1, 6] + e(b)[1, 2]*x0 + e(b)[1, 3]*z + e(b)[1,5]*x0*z)))
gen p_x1 = 1 / (1 + exp(-(e(b)[1, 6] + e(b)[1, 2]*x1 + e(b)[1, 3]*z + e(b)[1,5]*x1*z)))

// Ask stata to store the mean from summarize - first run, then store
summarize p_x0
scalar p_y_x0 = r(mean)
summarize p_x1
scalar p_y_x1 = r(mean)

di p_y_x1 - p_y_x0 // Marginal risk difference
di (p_y_x1 / (1 - p_y_x1)) / (p_y_x0 / (1 - p_y_x0)) // Marginal odds ratio

glm y x, family(binomial) link(logit) eform // Different bc OR non collapsible
