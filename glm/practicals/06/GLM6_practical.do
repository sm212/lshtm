********************************************************************************
********************************************************************************
*Model solutions for GLM Practical 6
********************************************************************************
********************************************************************************

* set directory - change this to your own folder
cd "C:\Users\Ruth Keogh\OneDrive - London School of Hygiene and Tropical Medicine\GLM_2022\GLM6_collapsibility\Practical"

********************************************************************************
********************************************************************************
*PART A
********************************************************************************
********************************************************************************

* Load data
insheet using "kidney_example.csv" , clear

********************************************************************************
********************************************************************************
*** Question 1: Marginal risk diffs are a weighted combination of conditional mean diffs

* In practical 5 we found the conditional risk diffs as follows
glm y i.x##i.z, family(binomial) eform

predict ypred

summ ypred if x==0 & z==0
scalar Pr1_y1_x0z0=r(mean)

summ ypred if x==0 & z==1
scalar Pr1_y1_x0z1=r(mean)

summ ypred if x==1 & z==0
scalar Pr1_y1_x1z0=r(mean)

summ ypred if x==1 & z==1
scalar Pr1_y1_x1z1=r(mean)

scalar RD_z0=Pr1_y1_x1z0-Pr1_y1_x0z0 /* Risk diff in Z=0 group is 0.064 */
dis RD_z0

scalar RD_z1=Pr1_y1_x1z1-Pr1_y1_x0z1 /* Risk diff in Z=1 group is 0.043 */
dis RD_z1

*We know that the marginal risk diff is a weighted average of the conditional risk diffs
*The weights are Pr(Z=0) for Pr1_y1_x1z0 and Pr(Z=1) for Pr1_y1_x1z1

tab y

dis RD_z0*0.51+RD_z1*0.49
*The marginal risk diff is 0.054, which is what we found in practical 5

********************************************************************************
********************************************************************************
*** Question 2: Marginal risk ratios are a weighted combination of conditional mean ratios

* The conditional risk ratios are as follows

scalar RR_z0=Pr1_y1_x1z0/Pr1_y1_x0z0 /* Risk ratio in Z=0 group is 1.933 */
dis RR_z0

scalar RR_z1=Pr1_y1_x1z1/Pr1_y1_x0z1 /* Risk ratio in Z=1 group is 1.158 */
dis RR_z1

*The marginal probability Pr(Y=1|do(x=0)), which we use below to get the weights, is:

scalar Pr1_y1_x0=Pr1_y1_x0z0*0.51+Pr1_y1_x0z1*0.49
dis Pr1_y1_x0 /* Pr(Y=1|do(X=0))=0.167 */

*We know that the marginal RR is a weighted average of the conditional RRs
*The weights are w0 and w1 as defined in the lecture notes (pg 72)

scalar w0=Pr1_y1_x0z0*0.51/Pr1_y1_x0 
scalar w1=Pr1_y1_x0z1*0.49/Pr1_y1_x0 

dis w0 w1

*weighted combination of the conditional RRs
dis RR_z0*w0+RR_z1*w1

dis RD_z0*0.51+RD_z1*0.49
*The marginal RR is 1.32, which is what we found in practical 5

********************************************************************************
********************************************************************************
*** Question 3: See solutions

********************************************************************************
********************************************************************************
*PART B
********************************************************************************
********************************************************************************

* Load data
use "simdata_binary.dta" , clear

********************************************************************************
********************************************************************************
*** Question 4: Quantify the relationship between X and Z

tab x z
*X and Z are not associated

********************************************************************************
********************************************************************************
*** Question 5: Logistic regression of Y on X, Z, X*Z

glm y i.x##i.z, family(binomial)

predict ypred

summ ypred if x==0 & z==0
scalar Pr1_y1_x0z0=r(mean)

summ ypred if x==0 & z==1
scalar Pr1_y1_x0z1=r(mean)

summ ypred if x==1 & z==0
scalar Pr1_y1_x1z0=r(mean)

summ ypred if x==1 & z==1
scalar Pr1_y1_x1z1=r(mean)

scalar RD_z0=Pr1_y1_x1z0-Pr1_y1_x0z0 /* Risk diff in Z=0 group is 0.4 */
dis RD_z0

scalar RD_z1=Pr1_y1_x1z1-Pr1_y1_x0z1 /* Risk diff in Z=1 group is 0.4 */
dis RD_z1

*The conditional risk diff is 0.4 in both Z groups

********************************************************************************
********************************************************************************
*** Question 6: Marginal risk diff

*Because of non-collapsibility, and because there is no interaction between X and Z,
*the marginal risk diff is equal to the conditional risk diff.
*We can also check this easily using margins:

glm y i.x##i.z, family(binomial)
margins x, dydx(x)

********************************************************************************
********************************************************************************
*** Question 7: Conditional ORs

glm y i.x##i.z, family(binomial) eform

********************************************************************************
********************************************************************************
*** Question 8: Marginal OR
*This assumes Z is not a confounder, which is true here because there is no association between X and Z

glm y i.x, family(binomial) eform

********************************************************************************
********************************************************************************
*PART C
********************************************************************************
********************************************************************************

* Load data
use "simdata_binary2.dta" , clear

********************************************************************************
********************************************************************************
*** Question 9: a logistic regression of $Y$ on $X$ and $Z$ and their interaction

glm y i.x##c.z, family(binomial)

summ z, detail

*(a) Median of Z is 27.56752
*We can get the conditional OR (given this value of Z) using lincom

lincom 1.x+1.x#c.z*27.56752, eform

*(b) 10th percentile of Z is 20.03107

lincom 1.x+1.x#c.z*20.03107, eform

*(c) 90th percentile of Z is 35.10567

lincom 1.x+1.x#c.z*35.10567, eform

********************************************************************************
********************************************************************************
*** Question 10: Marginal OR estimate using empirical standardization

/*
 Make new variables, x0 and x1, which always take value of 0 and 1 respectively
 This will represent the situation where everyone receives surgery or everybody
 receives lithotripsy.
*/

gen x0 = 0
gen x1 = 1

* Obtain the exected (predicted) outcome Y for each person in these two scenarios
glm y i.x##c.z, family(binomial)

matrix list e(b)
scalar beta_0=e(b)[1,6]
scalar beta_X=e(b)[1,2]
scalar beta_Z=e(b)[1,3]
scalar beta_XZ=e(b)[1,5]

dis beta_0 beta_X beta_Z beta_XZ

* Then use the coefficients from the model to obtain Pr(Y=1|X=x0,Z=z) and Pr(Y=1|X=x1,Z=z)

gen ypred_x0_z = exp(beta_0+beta_X*x0+beta_Z*z+beta_XZ*x0*z)/(1+exp(beta_0+beta_X*x0+beta_Z*z+beta_XZ*x0*z))

gen ypred_x1_z = exp(beta_0+beta_X*x1+beta_Z*z+beta_XZ*x1*z)/(1+exp(beta_0+beta_X*x1+beta_Z*z+beta_XZ*x1*z))

* Calculate the marginal probabilities Pr(Y=1|do(X=0)) and Pr(Y=1|do(X=1))
summ ypred_x0_z
scalar Pr_y_x0=r(mean)

summ ypred_x1_z
scalar Pr_y_x1=r(mean)

*marginal OR

dis (Pr_y_x1/(1-Pr_y_x1))/(Pr_y_x0/(1-Pr_y_x0))

********************************************************************************
********************************************************************************
*** Question 11: Crude marginal OR estimate

glm y i.x, family(binomial) eform