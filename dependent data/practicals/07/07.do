use "../data/cornea.dta",clear

// Q1 - patient level characteristics
egen pickone = tag(id)
tabulate dispcat medium if pickone == 1

// Q2 - number of visits per patient (id)
egen n_visit = max(visit), by(id)
hist n_visit if pickone == 1 // Mode is 10 visits

// Q3 - do the number of visits vary by patient level characteristics
hist n_visit if pickone == 1, by(medium dispcat) // Not really. ChiSq agrees...

tabulate n_visit dispcat if pickone == 1, chi2
tabulate n_visit medium if pickone == 1, chi2

// Q4 - patient trajectories. Generally decend over time, not linear for all
sort id date
twoway (line score date, c(ascending)) if mod(id, 6) == 0, by(id)

// Q5 - is the score normal or do we need to transform it?
hist score, by(visit) // Close enough, might be clearer if we group visits
egen visit_grp = cut(visit), at(0, 5, 10, 15)
hist score, by(visit_grp) // Looks normal enough

// Q6+7 - build model. First saturate the mean structure and model the variance
gen date_sq = date^2
mixed score c.date##c.date_sq##i.dispcat##i.medium || id: date, reml cov(un)
est store var_unstruct

mixed score c.date##c.date_sq##i.dispcat##i.medium || id: date, reml cov(un) ///
                                                      resid(indep, by(dispcat))
est store var_unstruct_indep

// Q8 - which variance structure is the better fit?
lrtest var_unstruct_indep var_unstruct // Independed errors is a better fit

// Q9 - simplify the mean structure - use ML so can use LRT.
// First write out the formula in full so its easy to remove terms:

/*
mixed score date date2 i.medium i.dispcat c.date#i.medium c.date#i.dispcat ///
c.date2#i.medium c.date2#i.dispcat i.medium#i.dispcat ///
i.medium#i.dispcat#c.date i.medium#i.dispcat#c.date2 ///
|| id: date, reml cov(unstr) residuals(independent, by(dispcat))
*/

qui mixed score date date_sq i.medium i.dispcat c.date#i.medium c.date#i.dispcat ///
c.date_sq#i.medium c.date_sq#i.dispcat i.medium#i.dispcat ///
i.medium#i.dispcat#c.date i.medium#i.dispcat#c.date_sq ///
|| id: date, ml cov(unstr) residuals(independent, by(dispcat))
est store full

// Largest p-value is i.medium#i.dispcat, remove any terms involving the interaction
qui mixed score date date_sq i.medium i.dispcat c.date#i.medium c.date#i.dispcat ///
c.date_sq#i.medium c.date_sq#i.dispcat  ///
|| id: date, ml cov(unstr) residuals(independent, by(dispcat))
est store reduced

lrtest full reduced // No significant difference between the two models

// Now higest p-values are on the interaction between data and the factors, get rid
qui mixed score date date_sq i.medium i.dispcat  ///
|| id: date, ml cov(unstr) residuals(independent, by(dispcat))
est store reduced

lrtest full reduced

// Could try removing the disparity term as well, but the residuals vary by
// disparity so doesn't make sense to not include it in the model. Final model is
mixed score date date_sq i.medium i.dispcat || id: date, ml cov(unstr) residuals(independent, by(dispcat))

// Q10 - how does final model fit?
predict u_slope u_inter, reffects
predict resid_lv1, rstandard

hist resid_lv1
qnorm resid_lv1 // Level 1 residuals are normally distributed

hist u_inter if pickone == 1 // Bit skewed but fairly normal
qnorm u_inter if pickone == 1 // Same as before, bit weird in the tails
hist u_slope if pickone == 1 // Fine
qnorm u_slope if pickone == 1 // And again but of non-normality in the upper tail

