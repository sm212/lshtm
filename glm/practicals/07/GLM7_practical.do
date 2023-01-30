********************************************************************************
********************************************************************************
*Model solutions for GLM Practical 7
********************************************************************************
********************************************************************************

* set directory - change this to your own folder
cd "C:\Users\Ruth Keogh\OneDrive - London School of Hygiene and Tropical Medicine\GLM_2022\GLM7_logregepi\Practical"

* Load the data
	use "oesophageal_data-1.dta" , clear

	** I'm going to label my data
		label define lab_case 0 Control 1 Case , replace
		label values case lab_case
		
		label define lab_age 1 "25-34" 2 "35-44" 3 "45-54" 4 "55-64" 5 "65-74" 6 "75+" , replace
		label values age_group lab_age
		label var age_group "Age (years)"
		
		label define lab_tobacco 0 "None" 1 "1-9" 2 "10-19" 3 "20-29" 4 "30+" , replace
		label values tobacco_group lab_tobacco
		label var tobacco_group "Tobacco intake (g per day)"

		label define lab_alcohol 0 "0-39" 1 "40-79" 2 "80-119" 3 "120+" , replace
		label values alcohol_grp lab_alcohol
		label var alcohol_grp "Alcohol intake (g per day)"

********************************************************************************
********************************************************************************
*** Question 1

** Make new, binary, tobacco variable
	gen tobacco_2=.
		replace tobacco_2=0 if tobacco_group==0
		replace tobacco_2=1 if tobacco_group>=1
		label var tobacco_2 "Smoking status"
		label define lab_tob2 0 "Non-smoker" 1 "Smoker"
		label values tobacco_2 lab_tob2
		tab tobacco_2

* Examine all variables
	tab case

	tab tobacco_2

	tab alcohol_grp

	tab age_group

	* Look at associations between explanatory variables
		** Smoking and alcohol
		tab tobacco_2 alcohol_grp, missing row
		graph bar (count) case , stack percentage over(alcohol_grp) over(tobacco_2) asyvars ///
			 ytitle("Alcohol group (%)") title("Alcohol intake by smoking status") ///
			 legend(col(2) subtitle("Alcohol intake (g per day)"))
		graph export "Q1_i.png" , replace width(1000)

		* Smoking and age
		tab tobacco_2 age_group, miss row
	
	graph bar (count) case , stack percentage over(tobacco_2) over(age_group) asyvars ytitle("Percentage smokers") title("Smoking status by age group")
	graph export "Q1_ii.png" , replace width(1000)

		* Alcohol and age
		tab alcohol_grp age_group , miss col
		graph bar (count) case , stack percentage over(alcohol_grp) over(age_group) asyvars ///
			 ytitle("Alcohol group (%)") title("Alcohol intake by age group") ///
			 legend(col(2) subtitle("Alcohol intake (g per day)"))
		graph export "Q1_iii.png" , replace width(1000)

********************************************************************************
********************************************************************************
*** Question 2

** Association of tobacco and cancer
	** a) Calculate maunually
		tab case tobacco_2
			dis (255*191)/(9*521) // Odds ratio
			dis 1/255+1/191+1/9+1/521 // Var of estimate (that is SE^2)
			dis sqrt(0.12218767)

		** Use the variance of the estimate to calculate Woolf's 95% CI
			dis 10.387076 * exp(-1.96*sqrt((0.12218767))) // Lower
			dis 10.387076 * exp(1.96*sqrt((0.12218767))) // Upper

		**b) PLease see written solutions. 
			
	** c) mhodds
		mhodds case tobacco_2
			* Same estimate, different CI

********************************************************************************
********************************************************************************
*** Question 3

** a)
	glm case i.tobacco_2, family(binomial) eform
	
	*alternative ways of fitting the model - same results!
	logistic case i.tobacco_2
	logit case i.tobacco_2
	
	* Note that we should use the SE for the log OR, not the SE for the OR (which is what is presented in 'logistic' and 'glm' when using the eform option)

** b)
	glm tobacco_2 i.case , family(binomial) eform

********************************************************************************
********************************************************************************
*** Question 4

	** a)
		mhodds case tobacco_2, by(alcohol_grp)

	** b)
		mhodds tobacco_2 case , by(alcohol_grp)


********************************************************************************
********************************************************************************
*** Question 5

	** a) 
		glm case i.tobacco_2 i.alcohol_grp, family(binomial) eform

	** b)
		glm tobacco_2 i.case i.alcohol_grp, family(binomial) eform


********************************************************************************
********************************************************************************
*** Question 6

		glm case i.tobacco_2 i.alcohol_grp i.age_group, family(binomial) eform

********************************************************************************
********************************************************************************
*** Question 7

** Load the extended dataset
	use "oesophageal_data-2.dta", clear

** Re-make the binary tobacco variable
	gen tobacco_2=.
		replace tobacco_2=0 if tobacco_group==0
		replace tobacco_2=1 if tobacco_group>=1
		label var tobacco_2 "Smoking status"
		label define lab_tob2 0 "Non-smoker" 1 "Smoker"
		label values tobacco_2 lab_tob2

** Run the adjusted model
	glm case i.tobacco_2 alcohol age, family(binomial) eform

