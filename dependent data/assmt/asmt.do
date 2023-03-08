use "assignment_full2.dta", clear
browse

// baseline measurement (time 0), then month 3, 6, 12, 24
bysort treat: tabulate time
sort id time

/******************************** Part 1.1 ********************************/
// Missing data pattern
gen present_a = !missing(pro) if treat == 1
gen present_p = !missing(pro) if treat == 0
bysort id: gen n_attend2 = sum(present_a) if treat == 1
bysort id: replace n_attend2 = sum(present_p) if treat == 0
egen n_attend = max(n_attend2), by(id)
egen pickone = tag(id)
gen attend_all = n_attend == 5
gen missing_times = time if missing(pro)
egen first_missing = min(missing_times), by(id)
drop n_attend2

tabstat present_*, s(sum mean) by(time) c(s) // Number of patients
tabulate first_missing treat if pickone == 1 // First missing obs by time
tabstat attend_all if pickone == 1, s(sum mean) by(treat) // Number with all obs


hist pro, by(time treat) normal // Data is roughly normal at all times
preserve // Pro over time in the two groups
  keep time treat pro
  collapse (mean) pro_mean = pro (sd) pro_sd = pro, by(time treat) 
  sort treat time
  list
  twoway (line pro_mean time if treat == 0) (line pro_mean time if treat == 1)
restore

preserve // Pro over time - complete case only
  keep if attend_all == 1
  keep time treat pro
  collapse (mean) pro_mean = pro (sd) pro_sd = pro, by(time treat) 
  sort treat time
  list
  twoway (line pro_mean time if treat == 0) (line pro_mean time if treat == 1)
restore

/******************************** Part 1.2 ********************************/
twoway (line pro time) if mod(id, 5) == 0, by(treat) // Some trajectories

keep if time != 0 // Remove baseline covar as we're including it as a covariate
summarize baseline
gen c_base = baseline - r(mean)

// Determine variance structure
mixed pro time baseline i.treat i.sex ///
 /*2 inter*/ c.time#c.baseline c.time#i.treat c.time#i.sex ///
 /*2 inter*/ c.baseline#i.treat c.baseline#i.sex i.treat#i.sex ///
 /*3 inter*/ c.time#c.baseline#i.treat c.time#i.treat#i.sex c.baseline#i.treat#i.sex ///
 /*4 inter*/ c.time#c.baseline#i.treat#i.sex ///
  || id: time, ml cov(un) resid(indep, by(sex))
est store m0
  
mixed pro time baseline i.treat i.sex ///
 /*2 inter*/ c.time#c.baseline c.time#i.treat c.time#i.sex ///
 /*2 inter*/ c.baseline#i.treat c.baseline#i.sex i.treat#i.sex ///
 /*3 inter*/ c.time#c.baseline#i.treat c.time#i.treat#i.sex c.baseline#i.treat#i.sex ///
 /*4 inter*/ c.time#c.baseline#i.treat#i.sex ///
  || id: time, ml cov(un)
est store un

lrtest m0 un // No evidence that varying residuals better (p = 0.1223)

qui mixed pro time baseline i.treat i.sex ///
 /*2 inter*/ c.time#c.baseline c.time#i.treat c.time#i.sex ///
 /*2 inter*/ c.baseline#i.treat c.baseline#i.sex i.treat#i.sex ///
 /*3 inter*/ c.time#c.baseline#i.treat c.time#i.treat#i.sex c.baseline#i.treat#i.sex ///
 /*4 inter*/ c.time#c.baseline#i.treat#i.sex ///
  || id: time, ml cov(independent)
est store indep

qui mixed pro time baseline i.treat i.sex ///
 /*2 inter*/ c.time#c.baseline c.time#i.treat c.time#i.sex ///
 /*2 inter*/ c.baseline#i.treat c.baseline#i.sex i.treat#i.sex ///
 /*3 inter*/ c.time#c.baseline#i.treat c.time#i.treat#i.sex c.baseline#i.treat#i.sex ///
 /*4 inter*/ c.time#c.baseline#i.treat#i.sex ///
  || id: time, ml cov(ex)
est store ex

lrtest un indep // unstructured better, p = 0.03
lrtest un ex    // unstructured better, p < 0.0001. => use unstructured

// Determine mean structure
mixed pro time baseline i.treat i.sex ///
 /*2 inter*/ c.time#c.baseline c.time#i.treat c.time#i.sex ///
 /*2 inter*/ c.baseline#i.treat c.baseline#i.sex i.treat#i.sex ///
 /*3 inter*/ c.time#c.baseline#i.treat c.time#i.treat#i.sex c.baseline#i.treat#i.sex ///
 /*4 inter*/ c.time#c.baseline#i.treat#i.sex ///
  || id: time, ml cov(un)
  
// Remove treatment & time interaction (p = 0.997)
mixed pro time baseline i.treat i.sex ///
 /*2 inter*/ c.time#c.baseline  c.time#i.sex ///
 /*2 inter*/ c.baseline#i.treat c.baseline#i.sex i.treat#i.sex ///
 /*3 inter*/ c.baseline#i.treat#i.sex ///
  || id: time, ml cov(un)
  
// Remove sex & baseline interaction (p = 0.909)
mixed pro time baseline i.treat i.sex ///
 /*2 inter*/ c.time#c.baseline  c.time#i.sex ///
 /*2 inter*/ c.baseline#i.treat i.treat#i.sex ///
  || id: time, ml cov(un)
  
// Remove sex & time interaction (p = 0.56)
mixed pro time baseline i.treat i.sex ///
 /*2 inter*/ c.time#c.baseline c.baseline#i.treat i.treat#i.sex ///
  || id: time, ml cov(un)
  
// Remove treat & sex interaction (p = 0.283)
mixed pro time baseline i.treat i.sex c.time#c.baseline c.baseline#i.treat ///
      || id: time, ml cov(un)
est store m

lrtest un m

// GEE
xtset id time

xtgee pro time baseline i.treat i.sex c.time#c.baseline c.baseline#i.treat, cor(ind) vce(robust)


/******************************** Part 1.3 ********************************/
// Results