* --------------------------------------
* Stats Computing: Stata
* Exercise 1: Introduction to the Stata software, and to Stata commands and results
* --------------------------------------

cd "H:\Stats Computing\Stata\Data\Exercise 1"
log using Log_exercise1.log, replace 



* Ex 1.1 - familiarising yourself with the Stata windows interface (no specific solutions)

* Ex 1.2
* Data Drop-down Menu
use "H:\Stats Computing\Stata\Data\Exercise 1\bl_demog.dta", clear
describe
describe using "H:\Stats Computing\Stata\Data\Exercise 1\vitals_long.dta"

codebook ptid birthdt age smkstat sbp diab
label variable birthdt "Date of birth"

list ptid birthdt age sex in 1/10
sort age
list ptid birthdt age sex in 1/10

* Graphics Drop-down Menu
histogram wt
histogram wt, discrete
histogram wt, frequency
histogram wt, bin(20) frequency 

histogram smkstat, discrete frequency

graph bar (mean) egfr, over(agegroup)  name(egfr1, replace) 
graph bar (mean) egfr, over(agegroup) over(sex) ///
	ytitle(Mean egfr (ml/min/1.73msq)) name(egfr2 , replace) 

graph matrix age wt ht wc sbp hrate , name(matrix1, replace) 
graph matrix age wt ht wc sbp hrate, ///
	half msymbol(smcircle_hollow) name(matrix1, replace) 

graph box egfr, name(box1, replace)
graph box egfr, over(agegroup) name(box2, replace)
graph box egfr, over(agegroup) over(sex) name(box3, replace)
graph box egfr, over(sex) over(agegroup) name(box4, replace) 
graph box egfr, over(agegroup) by(sex) name(box5, replace)

* Statistics Drop-down Menu
summarize age wt sbp
summarize age wt sbp, detail

pwcorr age wt ht wc sbp hrate
pwcorr age wt ht wc sbp hrate, obs

tabulate agegroup
tabulate diab

tabulate agegroup diab
tabulate agegroup diab, row
by sex, sort : tabulate agegroup diab, row
by sex, sort : tabulate agegroup diab if diab~=., row

log close  

* End of file

