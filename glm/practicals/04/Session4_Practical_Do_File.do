/*

Model solutions for GLM Practical 4

January 2023

*/

** Set directory - change this to your own folder
	cd "C:\Users\HP\Dropbox\Work\lshtm\GLM 2022\P4"

********************************************************************************
********************************************************************************
*** PART A

********************************************************************************
********************************************************************************
*** Question 1

	* Load the data from the Stata website
		webuse lbw.dta , clear

		describe
			
	* Logistic model using (a) glm	
		glm low lwt , fam(bin) link(logit)

	* Logistic model using (a) logistic
		logistic low lwt
			dis ln(.9860609)
			dis ln(2.706788)

	* Logistic model using (a) logit
		logit low lwt

		** Note that the given log likelihood is the same for all models.

********************************************************************************
********************************************************************************
*** Question 2
	** Obtain the fitted probabilities
		logit low lwt , nolog
			predict fitted_prob if e(sample), pr
				label var fitted_prob "Fitted probabilities from model with just mother's weight"
	* Lowess plot
		#delimit ;
			twoway  (lowess low lwt, lpattern(dash))
					(line fitted_prob lwt, sort c(L))
				    (scatter low lwt, msymbol(X))
			,
			title (Observed data and fitted probabilities of death)
			legend(order(1 "lowess fit" 2 "logistic model fit" 3 "observed data"))
		;
		#delimit cr
		graph export "Q2.png" , width(1000) replace

********************************************************************************
********************************************************************************
*** Question 3

		dis exp((120*-.0140371) + .9957626) // odds
		dis .50223387 / (1 + .50223387) // probability

********************************************************************************
********************************************************************************
*** Question 4
	** Using lincom
		logit low lwt
			lincom 120*lwt + _cons , eform
			* The CI for the probabilty is given by
				dis .365678 / (1 + .365678)
				dis .6897819 / (1 + .6897819)
				** 95% CI is from 27% to 41%

	** Re-parameterise
gen lwt120 = lwt - 120
logistic low lwt120, nolog
			** Here the constant term is the predicted odds for a woman of 120 lbs
			** It gives the same results as from the lincom command above
			** The probability and CI can be calculated as above

********************************************************************************
********************************************************************************
*** Question 5

	** Using logit
		logit low i.race lwt
			* Wald test
			test 2.race 3.race
			
			* Likelihood ratio test
	        est store A
            logit low lwt
            est store B
			lrtest A B

********************************************************************************
********************************************************************************
*** Question 6

	** Null model
		logit low
			est store C
			
	** Compare model with race and mother's weight to the null model
		lrtest A C

********************************************************************************
********************************************************************************
*** Question 7

    ** (Quietly) refit the model with race and mother's weight as predictors 
	qui logit low lwt i.race
		
		* Hosmer-Lemeshow test
		estat gof , group(10)
		
		estat gof , group(5)
		
		estat gof , group(2)
		estat gof , group(3)
		estat gof , group(4)

		estat gof , group(20)
		estat gof , group(30)
		estat gof , group(40)
		estat gof , group(50)
		estat gof , group(60)

	    estat gof , group(100)


********************************************************************************
********************************************************************************
*** PART B

********************************************************************************
********************************************************************************
*** Question 8

	use insect.dta, clear

	** GLM model with logit link
		glm r dose , fam(bin n) link(logit)

	** The deviance from the above model is 4.615
	** We compare this the a chi-square dist with n - p = 8 - 2 = 6 degrees of freedom.
		dis chi2tail(6, 4.615)
		
		* This provides no evidence that the model isn't a good fit.

		** The above test is equivalent to comparing this model to the saturated model:
		egen dosecat = rank(dose)
		glm r dose , fam(bin n) link(logit)
			est store D
		glm r i.dosecat , fam(bin n) link(logit)
			est store E
		lrtest D E
		* Note that the chi-square value is again 4.62

********************************************************************************
********************************************************************************
*** Question 9
	gen dose2 = dose^2
		label var dose2 "Dose squared"

	glm r dose dose2, fam(bin n) link(logit)
		est store F
		** The Wald test for the quadratic term is z=1.17, p=0.243
	
	** Compare the Wald test to a profile likelihood ratio test
	lrtest D F
		* Here we find p=0.2315, slightly lower.
		* The chi-square value is 1.43. This is equivalent to a z-value of
			dis sqrt(1.43) // 1.196
		* Compared to the z=1.17 we saw with the Wald test

