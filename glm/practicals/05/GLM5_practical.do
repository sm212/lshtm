********************************************************************************
********************************************************************************
*Model solutions for GLM Practical 5
********************************************************************************
********************************************************************************

* set directory - change this to your own folder
cd "C:\Users\Ruth Keogh\OneDrive - London School of Hygiene and Tropical Medicine\GLM_2022\GLM5_standardization\Practical"

********************************************************************************
********************************************************************************
*PART A
********************************************************************************
********************************************************************************

* Load data
insheet using "kidney_example.csv" , clear

* Explore the data
desc
codebook

** Tabulate the data as in Table 1
tab y x

bysort z: tab y x

********************************************************************************
********************************************************************************
*** Question 1: In this question we will use logistic regression to obtain an estimate of the conditional odds ratio

* i) Logistic regression model for Y with X and Z as explanatory variables (not including their interaction).
*Note that using the 'eform' option means that Stata reports ORs intead of log(OR)s
glm y i.x i.z, family(binomial) eform

*The conditional OR is 1.43 (this is in both Z=0 and Z=1 groups because we have no interaction in the model)

* ii) Logistic regression model for Y with X and Z as explanatory variables (including their interaction).
glm y i.x##i.z, family(binomial) eform

lincom 1.x+1.x#1.z, eform

*The conditional OR is 2.07 in the Z=0 group, and 1.23 in the Z=1 group

*Note: we can also use the 'logistic' command

logistic y i.x##i.z

lincom 1.x+1.x#1.z

********************************************************************************
********************************************************************************
*** Question 2: Using your model from Question 1(b) to obtain estimates of:...

* i) Conditional probabilities
glm y i.x##i.z, family(binomial) eform

predict ypred

list ypred if x==0 & z==0 /* Pr(Y=1|X=0,Z=0)=0.069 */
list ypred if x==0 & z==1 /* Pr(Y=1|X=0,Z=1)=0.270 */ 
list ypred if x==1 & z==0 /* Pr(Y=1|X=1,Z=0)=0.133 */
list ypred if x==1 & z==1 /* Pr(Y=1|X=1,Z=1)=0.313 */

*save these probabilities
summ ypred if x==0 & z==0
scalar Pr1_y1_x0z0=r(mean)

summ ypred if x==0 & z==1
scalar Pr1_y1_x0z1=r(mean)

summ ypred if x==1 & z==0
scalar Pr1_y1_x1z0=r(mean)

summ ypred if x==1 & z==1
scalar Pr1_y1_x1z1=r(mean)

* ii) Conditional risk differences

dis Pr1_y1_x1z0-Pr1_y1_x0z0 /* Risk diff in Z=0 group is 0.064 */

dis Pr1_y1_x1z1-Pr1_y1_x0z1 /* Risk diff in Z=1 group is 0.043 */

* ii) Conditional risk ratios

dis Pr1_y1_x1z0/Pr1_y1_x0z0 /* Risk ratio in Z=0 group is 1.93 */

dis Pr1_y1_x1z1/Pr1_y1_x0z1 /* Risk ratio in Z=1 group is 1.16 */

********************************************************************************
********************************************************************************
*** Question 3: We will next estimate marginal treatment effects.

tab z

* i) Marginal probabilities

scalar Pr1_y1_x0=Pr1_y1_x0z0*0.51+Pr1_y1_x0z1*0.49
dis Pr1_y1_x0 /* Pr(Y=1|X=0)=0.167 */

scalar Pr1_y1_x1=Pr1_y1_x1z0*0.51+Pr1_y1_x1z1*0.49
dis Pr1_y1_x1 /* Pr(Y=1|X=1)=0.221 */

* ii) Marginal risk difference: 0.054

dis Pr1_y1_x1-Pr1_y1_x0

* ii) Marginal risk ratio: 1.32

dis Pr1_y1_x1/Pr1_y1_x0

* ii) Marginal odds ratio: 1.41

dis (Pr1_y1_x1/(1-Pr1_y1_x1))/(Pr1_y1_x0/(1-Pr1_y1_x0))

********************************************************************************
********************************************************************************
*** Question 4: The margins command

* i) Using margins to obtain marginal probability estimates

glm y i.x##i.z, family(binomial) eform

margins x

* ii) Using margins to obtain marginal risk difference estimate

margins x,dydx(x)

********************************************************************************
********************************************************************************
*** Question 5: Empirical standardization

/*
 Make new variables, x0 and x1, which always take value of 0 and 1 respectively
 This will represent the situation where everyone receives surgery or everybody
 receives lithotripsy.
*/

gen x0 = 0
gen x1 = 1

* Obtain the exected (predicted) outcome Y for each person in these two scenarios
* First, run the interaction model using the original X values
glm y i.x##i.z, family(binomial)

* Then use the coefficients from the model to obtain Pr(Y=1|X=x0,Z=z) and Pr(Y=1|X=x1,Z=z)

gen ypred_x0_z = exp(-2.60269+0.7308873*x0+1.607874*z-0.5245292*x0*z)/(1+exp(-2.60269+0.7308873*x0+1.607874*z-0.5245292*x0*z))

gen ypred_x1_z = exp(-2.60269+0.7308873*x1+1.607874*z-0.5245292*x1*z)/(1+exp(-2.60269+0.7308873*x1+1.607874*z-0.5245292*x1*z))

* Calculate the mean of the outcome in each scenario
mean ypred_x0_z
mean ypred_x1_z

* Calculate the mean difference
dis 0.2211249-0.1674537

*  0.054, same as calculated using margins and standardization.

********************************************************************************
********************************************************************************
*PART B
********************************************************************************
********************************************************************************

* Load data
insheet using "kidney_example_continuousY.csv" , clear

* Explore the data
desc
codebook

********************************************************************************
********************************************************************************
*** Question 6: What are the means of Y in each of the four groups defined by X and Z?

summ y if x==0 & z==0
scalar meany_x0_z0=r(mean)

summ y if x==0 & z==1
scalar meany_x0_z1=r(mean)

summ y if x==1 & z==0
scalar meany_x1_z0=r(mean)

summ y if x==1 & z==1
scalar meany_x1_z1=r(mean)

dis meany_x0_z0 meany_x0_z1 meany_x1_z0 meany_x1_z1

********************************************************************************
********************************************************************************
*** Question 7: regression of y on x,z,x*z

regress y i.x##i.z

*The intercept is meany_x0_z0
*_cons+1.x=meany_x1_z0
*_cons+1.z=meany_x0_z1
*_cons+1.x+1.z+1.x*1.z=meany_x1_z1

*we can check this using lincom
lincom _cons+1.x
lincom _cons+1.z
lincom _cons+1.x+1.z+1.x#1.z

********************************************************************************
********************************************************************************
*** Question 8: conditional mean differences

*Conditional mean diff in Z=0 group: 0.355
*THis is equal to the coefficient for X in the linear regression 
dis meany_x1_z0-meany_x0_z0

lincom (_cons+1.x)-(_cons)

*Conditional mean diff in Z=1 group: 0.978
dis meany_x1_z1-meany_x0_z1

lincom (_cons+1.x+1.z+1.x#1.z)-(_cons+1.z)
lincom 1.x+1.x#1.z

********************************************************************************
********************************************************************************
*** Question 9: marginal expectations and marginal mean differences

*i)

*Marginal expectation: E(Y|do(X=0))=-0.31

tab z

scalar meany_do_x0=meany_x0_z0*0.51+meany_x0_z1*0.49
dis meany_do_x0

*Marginal expectation: E(Y|do(X=1))=0.348

scalar meany_do_x1=meany_x1_z0*0.51+meany_x1_z1*0.49
dis meany_do_x1

*Marginal mean diff: E(Y|do(X=1))-E(Y|do(X=0))=0.661
dis meany_do_x1-meany_do_x0

* ii) We can do the same using margins 

regress y i.x##i.z

margins x, dydx(x)

********************************************************************************
********************************************************************************
*** Question 10: Empirical standardization to get marginal expectations

gen x0 = 0
gen x1 = 1

* Obtain the expected (predicted) outcome Y for each person in these two scenarios
* First, run the interaction model using the original X values
regress y i.x##i.z

* Then use the coefficients from the model to obtain Pr(Y=1|X=x0,Z=z) and Pr(Y=1|X=x1,Z=z)

gen ypred_x0_z =0.2012412+0.3553808*x0-1.049502*z+0.6228426*x0*z

gen ypred_x1_z =0.2012412+0.3553808*x1-1.049502*z+0.6228426*x1*z

* Calculate the mean of the outcome in each scenario
mean ypred_x0_z
mean ypred_x1_z

* Calculate the mean difference
dis .3475589-(-.3130148)

********************************************************************************
********************************************************************************
*** Question 11: Linar regression without interacion x*z

regress y i.x i.z
*conditional mean difference is 0.655 in the two Z groups

margins x, dydx(x)