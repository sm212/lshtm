/*

Model solutions for GLM Practical 1

January 2023

*/

** Set directory - change this to your own folder
    cd "C:\Users\HP\Dropbox\Work\lshtm\GLM 2022\P1"
	
********************************************************************************
********************************************************************************
*** Question 1

** Import the data
	use mental.dta , clear

** Label the variables
	label var treat Treatment
	label var prement "Pre-injection score"
	label var mentact "Post-injection score"
	label define lab_treat 1 "Placebo Group" 2 "Morphine Group" 3 "Heroin Group"
	label values treat lab_treat

** Examine the dataset
	count
	codebook
	tab treat
	bysort treat : sum mentact prement

** Plots
	hist prement
	hist prement , by(treat)
		graph rename before
	hist mentact , by(treat)
		graph rename after

	twoway (scatter mentact pre if treat==1, mcolor(red)) (lfit mentact pre if treat==1, lcolor(red)) ///
		(scatter mentact pre if treat==2, mcolor(green)) (lfit mentact pre if treat==2, lcolor(green)) ///
		(scatter mentact pre if treat==3, mcolor(blue))  (lfit mentact pre if treat==3, lcolor(blue))

	hist prement, width(1) saving(g1, replace)
	hist mentact, width(1) saving(g2, replace)
	scatter mentact prement, saving(g3, replace)
		graph combine "g1" "g2" "g3"
		graph export  "Q1.png" , width(1000) replace

********************************************************************************
********************************************************************************
*** Question 2
	lowess mentact pre if treat==1, title("Placebo") bw(0.8)
		graph rename point8g1
	lowess mentact pre if treat==2, title("Morphine") bw(0.8)
		graph rename point8g2
	lowess mentact pre if treat==3, title("Heroin") bw(0.8)
		graph rename point8g3
	graph combine point8g1 point8g2 point8g3	
		graph export "Q2_lowess.png" , width(1000) replace

	* What about other values for the bandwidth?
	* Smaller?
		lowess mentact pre if treat==1, bw(0.4)
			graph rename point4
		lowess mentact pre if treat==1, bw(0.2)
			graph rename point2
		lowess mentact pre if treat==1, bw(0.1)
			graph rename point1
	
		** Increasingly jagged
	
	* Larger?
		lowess mentact pre if treat==1, bw(0.9)
			graph rename point9
			
		** Very similar
			
	** Very large, zero, or negative?
		lowess mentact pre if treat==1, bw(1)
			graph rename one
		lowess mentact pre if treat==1, bw(2)
			graph rename two
		lowess mentact pre if treat==1, bw(100)
			graph rename hundred
		lowess mentact pre if treat==1, bw(0)
			graph rename zero
		lowess mentact pre if treat==1, bw(-100)
			graph rename negative

		** Stata rightly ignores your frivolity and uses the default value (0.8)
	
	* Clear the graphs
		graph drop _all

********************************************************************************
********************************************************************************
*** Question 4

	** Model 1
		regress mentact

	** Model 2
		regress mentact i.treat

	** Model 3
		regress mentact prement

	** Model 4
		regress mentact i.treat prement

	** Model 5
		regress mentact i.treat##c.prement

********************************************************************************
********************************************************************************
*** Question 5

   ** Fitted values
        predict fv
   
   ** Graph
        twoway (line fv prement if treat==1) (line fv prement if treat==2) (line fv prement if treat==3), ///
		title(Fitted values from model 5 by trial arm) legend(on order(1 "Placebo" 2 "Morphine" 3 "Heroin"))
		
********************************************************************************
********************************************************************************
*** Question 6
	** 3 vs 4: Re-run model 4 to be sure it's the most recent model
		regress mentact i.treat prement
			test 2.treat 3.treat

	** 4 vs 5: Re-run model 5
		regress mentact i.treat##c.prement
			test 2.treat#c.prement 3.treat#c.prement
	
********************************************************************************
********************************************************************************
*** Question 7
	** Remind ourselves of Model 4 using regress
		regress mentact i.treat prement

	** Compare output to glm
		glm mentact i.treat prement , fam(normal) link(id)

********************************************************************************
********************************************************************************
*** Question 10

	** Using lincom
		* Re-run Model 4
			regress mentact i.treat prement
		
		* Use lincom to get differnece between morphine and heoin groups
			lincom 3.treat - 2.treat

	** Re-parameterise the model. Make Morphine (group 2) the baseline
		* Re-run Model 4
			regress mentact b2.treat prement
		
		* The coefficient for the Heroin arm matches the lincom results above.
