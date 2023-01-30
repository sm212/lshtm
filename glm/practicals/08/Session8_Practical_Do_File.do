/*

Model solutions for GLM Practical 8

January 2023

*/

** Set directory - change this to your own folder
	cd "C:\Users\HP\Dropbox\Work\lshtm\GLM 2022\P8"
** Load data
	use http://www.stata-press.com/data/hh3/medpar, clear
	
** Examine the key variables
	desc los age type*
	codebook los age type*
	sum los age type*
	
********************************************************************************
********************************************************************************
*** Question 1

	* Length of stay
		sum los
		hist los , width(4) start(0)
		tabstat los , s(min p25 med p75 max)

	* Mean (and 95% CI) of los
		ci means los

	* Check assumptions
		hist los, norm   saving(fig1 , replace)
		qnorm los , saving(fig2 , replace)
			** Data are positively skewed
			** But the sample size is large
		graph combine "fig1" "fig2" , rows(1) imargin(0 0 0 0)
		graph export "Q1.png" , width(1000) replace

********************************************************************************
********************************************************************************
*** Question 2
	
	** GLM, count model for los
		glm los , fam(poisson) link(log)
			dis exp(2.287896) // estimate of the mean
			dis exp(2.27174) // lower end of CI
			dis exp(2.304044) // upper end of CI

			* Alternatively, use eform
				lincom _cons , eform
				glm los , fam(poisson) link(log) eform


********************************************************************************
********************************************************************************
*** Question 3
	
	** GLM, count model for los with robust standard error for the log mean count
		glm los , fam(poisson) link(log) robust
			dis exp(2.287896) // estimate of the mean
			dis exp(2.242459) // lower end of CI
			dis exp(2.333333) // upper end of CI
						
			* Alternatively, use eform
				lincom _cons , eform
				glm los , fam(poisson) link(log) robust eform
	** Allowing for overdispersion gives a markedly wider 95% CI than 
	** erroneously assuming that los follows a Poisson distribution (in Q2)
	** The 95% CI in Q3 is close to that in Q1 (where the central limit theorem 
	** compensates for the skewness of los)

********************************************************************************
********************************************************************************
*** Question 4

	** Model containing all type variables
		glm los i.type1 i.type2 i.type3, fam(poisson) link(log) eform
		* Note that Stata automatically drops type1
	
		* We'll omit type 1
		glm los i.type2 i.type3, fam(poisson) link(log) eform
			est store A
		* For comparisson with later models 
	
********************************************************************************
********************************************************************************
*** Question 5

	** Add age as a factor variable
		glm los i.age i.type2 i.type3, fam(poisson) link(log) eform
			est store B
		lrtest A B 

		
	** Check dispersion assumption
		* Deviance / df
			dis 8165.18541/1484
		* Pearson / df
			dis 9346.752373/1484
		* Both ratios are much greater than 1 - clear indication of overdispersion

			
	** Stata tip
		* Stata actually stores the deviance, Pearson, and the dispersion estimates
		* we have just calculated. The can be accessed using the following macros:
			dis e(deviance)
			dis e(deviance_ps)
			dis e(dispers)
			dis e(dispers_ps)
			
		* A list of all of the stored macros can be obtained with:
			ereturn list


********************************************************************************
********************************************************************************
*** Question 6

	** Add the robust option
		glm los i.age i.type2 i.type3, fam(poisson) link(log) eform robust
			est store C
	
		* Try to perform a likelihood ratio test
		lrtest A C
			* Stata says no.

		* Perform a Wald test instead
		testparm i.age

********************************************************************************
********************************************************************************
*** Question 7

	** Negative binomial model
		nbreg los

	** Posson model from Q2
		glm los , fam(poisson) link(log)

********************************************************************************
********************************************************************************
*** Question 8

	** Negative binomial model with type of admission
		* (note the irr option, this is analogous to eform with glm)
		nbreg los i.type2 i.type3 , irr
		
		* Calculate means (we multiply because we're working on the rate ratio scale)
			* Type 1 = 8.83 (constant)
			* Type 2
				dis 8.830688 * 1.267877
			* Type 3
				dis 8.830688 * 2.065477

		* Estimated variances from model
			dis  8.830688 * (1+ (8.830688 * e(alpha) ) )
			dis  11.196226 * (1+ (11.196226 * e(alpha) ) )
			dis  18.239583 * (1+ (18.239583 * e(alpha) ) )

		* Observed variances
			tabstat los if type1==1 , s(var)
			tabstat los if type2==1 , s(var)
			tabstat los if type3==1 , s(var)

	** What happens if we use 'number of days of stay after day of admission' as 
	** the outcome variable?
	
		gen nodosadof = los - 1
		
		glm nodosadof i.type2 i.type3, fam(poisson) link(log) eform robust 

		** Feel free to run other models and compare the results with what we have 
		** concluded above.