use "../data/beta_blocker_gee.dta", clear
browse

// Q1 - how does pre-treatment DBP & missingness vary across the groups?
tabstat pre if time == 1, by(treat) s(count mean sd)
tabulate first5 treat, col // Placebo group has lower drop out

// Q2 - number of observations at each time point by treatment & how mean dbp
// varies over time
egen pickone = tag(id)
tabstat treat if pickone, s(count sum) // 105 / 200 in active group, 95 placebo
gen rec_p = !missing(dbp) if treat == 0
gen rec_a = !missing(dbp) if treat == 1
gen dbp_a = dbp if treat == 1
gen dbp_p = dbp if treat == 0
tabstat rec_p rec_a, by(time) s(sum mean)  nototal
tabstat dbp_p dbp_a, by(time) s(count mean sd) nototal

// Can people miss one measurement and reenter at a later date?
gen missing_times = missing(dbp) * time
gen re_enter = missing_times < missing_times[_n - 1]
replace re_enter = 0 if time == 1
list id if re_enter == 1, noobs // Yes - 121 & 144 did it

/*
People in the active group are more likely to drop out compared to placebo. Of 
the 105 people assigned to the active treatment 60 (57%) have a final 
measurement recorded, compared to 61 (64%) of the placebo group. Almost everyone
who drops out never returns to the study - if they drop out at time 3, almost
no one returns at time 4 or 5. Only two (1%) people returned, ID 121 & 144.
*/

// Looking at how DBP varies over time - plot of indivi trajectories and means
xtset id time
xtline dbp if treat==0 & first5==0, overlay legend(off) saving(plot1,replace) title(Placebo)
xtline dbp if treat==1 & first5==0, overlay legend(off) saving(plot2,replace) title(Active)
graph combine plot1.gph plot2.gph, title(With missing values)

xtline dbp if treat==0 & first5==1, overlay legend(off) saving(plot1,replace) title(Placebo)
xtline dbp if treat==1 & first5==1, overlay legend(off) saving(plot2,replace) title(Active)
graph combine plot1.gph plot2.gph, title(With missing values)

// Q3 - complete case analysis
mixed dbp time treat c_pre if first5 ==1 || id:, var ml

/*
The average DBP at the start of the study was 93 mmHg. Study participants initial
DBP varied around this mean with a variance of 30.3. DBP decreased over the 
course of the study by .3 mmHg between each visit on average. The average 
treatment effect is a reduction of 6.2 mmHg in DBP. The residual variance in
this model is 43.9 mmHg^2
*/

// Q4 - marginal model fit with GEE
xtset id time
xtgee dbp time treat c_pre if first5 == 1, cor(indep)
/*
Very similar results - this is because we're fitting normal models, and for
normal models the conditional and marginal models are the same
*/

// Q5 - different variance structure
xtgee dbp time treat c_pre if first5 == 1, cor(exch)
/*
Most of the standard errors are higher - so the exchangable structure leads to
a less efficient estimate compared to the independent structure
*/

// Q6 - same models but with robust standard errors
xtgee dbp time treat c_pre if first5 == 1, cor(indep) vce(robust)
xtgee dbp time treat c_pre if first5 == 1, cor(exch) vce(robust)
/*
Now get essentially identical standard errors - specification of variance 
structure isn't too important for GEEs
*/

// Q7 - repeat on all data (not just complete ones)
xtgee dbp time treat c_pre, cor(indep) vce(robust)
xtgee dbp time treat c_pre, cor(exch) vce(robust)
/*
Again very little difference in the standard errors between the two models, the
errors are smaller now because we're using a larger sample - though the 
difference between the complete case analysis is pretty small
*/