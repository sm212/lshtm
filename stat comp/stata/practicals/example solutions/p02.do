* --------------------------------
* Stats Computing: Stata
* --------------------------------
* Exercise 2: Inspecting Data
* --------------------------------

* Change working directory to exercise 2 folder
cd "H:\Stats Computing\Stata\Data\Exercise 2"

log using Log_exercise2.log , replace

* ----------------------------
* Exercise 2.1
* ----------------------------
use bl_demog, clear

describe

browse
browse ptid wt ht wc

sort wt
browse ptid wt ht wc

gsort -wc
browse ptid wt ht wc

browse ptid wt ht wc if wt>130

list ptid age wt sbp dbp if sbp<90
list ptid age wt sbp dbp if sbp>180

list ptid *bp in 1/10
list ptid *bp in -10/l

codebook ptid birthdt age agegroup race smkstat wt lvef diab

summarize age wt, detail

tabulate agegroup
tabulate sex
tabulate smkstat

tab1 agegroup sex smkstat

tabulate agegroup hfdiag
tabulate agegroup diab

tabulate agegroup hfdiag, missing
tabulate agegroup diab, missing

histogram sbp
histogram wc
histogram hrate
histogram egfr

twoway scatter sbp dbp, ms(oh)
twoway scatter wt wc, ms(oh)

* --------------------------------
* Exercise 2.2
* --------------------------------
use bl_labsall, clear 

describe
browse
codebook

summ creat hb pot sodium totbil
summ creat if creat<9999
summ creat if creat<8888
summ hb if hb<8888
summ pot if pot<8888
summ sodium if sodium<8888
summ totbil if totbil<8888

tab creat if creat>=8888
tab hb if hb>=8888
tab pot if pot>=8888
tab sodium if sodium>=8888
tab totbil if totbil>=8888

hist creat
hist creat if creat<8888
hist hb if hb<8888
hist pot if pot<8888
hist sodium if sodium<8888
hist totbil if totbil<8888

corr pot creat 
corr pot creat if creat<8888 & pot<8888

* --------------------------------
* Exercise 2.3
* --------------------------------
use vitals_long , clear 

describe
browse
codebook

tab1 visit param
tab visit param 

summ value
bysort param: summ value
summ value if param==2, det   // values of 850 and 7171 not possible
summ value if param==5, det   // value of 970 not possible

hist value if value<250, by(param)
hist value if value<250 & param==1, by(visit)

duplicates report ptid
duplicates report ptid visit
duplicates report ptid visit param

duplicates tag ptid visit param, gen(tag1)
br if tag1>0
list  if tag1>0  // a few records just double entered. Could drop one copy.

duplicates drop ptid visit param, force
duplicates report ptid visit param

save vitals_long2 , replace 

log close


* End of file