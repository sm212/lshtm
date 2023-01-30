/*

Model solutions for GLM Practical 3

January 2023

*/

** Set directory - change this to your own folder
	cd "C:\Users\HP\Dropbox\Work\lshtm\GLM 2022\P3"

********************************************************************************
********************************************************************************
*** Question 1

	** Import the data
		use insect.dta , clear

	** Examine the dataset
		count // Number of *groups* = 8
		list // About 60 insects per group
		tabstat n , s(sum) // 481 insects 

********************************************************************************
********************************************************************************
*** Question 2

	** Generate proportion
		gen p = r / n
			label var p "Proportion killed in group"
		list

		scatter p dose
			graph export "Q2_scatter.png" , width(1000) replace

********************************************************************************
********************************************************************************
*** Question 3

	** (a) Generate log proportions
		gen logprop = log(p)
			label var logprop "Log of the proportion of death in each group"

	** (b) Generate log odds
		gen logodds = log( p / (1-p) )
			label var logodds "Log odds of death in each group"

	** Plot the values
	twoway (scatter logprop dose, mcolor(black) msymbol(O) ) ///
		   (scatter logodds dose, mcolor(green) msymbol(T) ) ///
		   , legend(rows(2))
	graph export "Q3_scatter.png" , width(1000) replace

********************************************************************************
********************************************************************************
*** Question 5

	** Fit the model
		glm r dose , fam(bin n) link(logit)

	** (d)
		glm r dose , fam(bin n) link(logit) eform

********************************************************************************
********************************************************************************
*** Question 6
	
	** Get predicted values
		predict fitval
			label var fitval "Fitted value"

	** Calculate fitted proprtions
		** Make variable for fitted proportions
			gen fitprop = fitval / n
				label var fitprop "Fitted proportion from linear model"

	** Plot the observed vs fitted proportions
		twoway (scatter p dose, mcolor(black) msymbol(Oh)) (scatter fitprop dose, mcolor(red) msymbol(Dh)),  ///
			ytitle(Observed and fitted proportions killed)
		graph export "Q6_scatter.png" , width(1000) replace

********************************************************************************
********************************************************************************
*** Question 7
	
	** Generate new dose-squared variable
		gen dose2 = dose^2
			label var dose2 "Dose-squared"

	** Fit the model
		glm r dose dose2, fam(bin n) link(logit) eform

	** Get new fitted values
		predict fitval2
		gen fitprop2 = fitval2 / n
			label var fitprop2 "Fitted proportion from quadratic model"

		list p fitprop fitprop2

	** Plot observed vs the two fitted proportions
	twoway (scatter p dose, mcolor(black) msymbol(Oh)) ///
		   (scatter fitprop dose, mcolor(red) msymbol(Dh)) ///
		   (scatter fitprop2 dose, mcolor(blue) msymbol(Th)), ///
		   ytitle(Observed and fitted proportions killed) ///
		   legend(rows(3))
		graph export "Q7_scatter_fitted_props.png" , width(1000) replace
		

********************************************************************************
********************************************************************************
*** Question 8
	
	** Generate new indicator variables for dose
		egen dosecat = rank(dose)
		
	** Run glm models (a) link = logit
		glm r i.dosecat, family(binomial n) link(logit)
		
	** Run glm models (a) link = log
		glm r i.dosecat, family(binomial n) link(log)
		
	** Run glm models (a) link = identity
		glm r i.dosecat, family(binomial n) link(id)

	** Fit a model with both categotrical and continuous dose
		glm r dose i.dosecat, family(binomial n) link(logit)
			* Note that Stata warns you it is dropping category 8
	
	** Test the categorical variables in this model
		test 2.dosecat 3.dosecat 4.dosecat 5.dosecat 6.dosecat 7.dosecat







