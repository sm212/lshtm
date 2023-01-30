clear
use "../data/lbw.dta"
browse

// Q1 - EDA and recoding small categories
codebook // No missing, small numbers for FTV (0, 1, 2+), ptl (0, 1+)
gen ftv_agg = 0 if ftv == 0
replace ftv_agg = 1 if ftv == 1
replace ftv_agg = 2 if ftv > 1

gen ptl_agg = 0 if ptl == 0
replace ptl_agg = 1 if ptl > 0

// confounders - which are associated with the outcome?
graph box bwt, over(smoke)
tabulate smoke low, chi2  // Yes
tabulate race low, chi2  // Maybe
tabulate ui low, chi2  // Yes

summarize age, detail
gen ageg = "Q1" if age <= 19
replace ageg = "Q2" if age > 19 & age <= 23
replace ageg = "Q3" if age > 23 & age <= 26
replace ageg = "Q4" if age > 26
tabulate ageg low, chi2 // No

// confounders - which are associated with the treatment?
// Nothing will be significant because only 12 have hypertension (?)
tabulate smoke ht, chi2   // Maybe
tabulate race ht, chi2   // Maybe
tabulate ui ht, chi2    // Maybe
tabulate ageg ht, chi2 // No

bysort ht : summarize bwt
graph box bwt, over(ht)

// Q2 - models
regress bwt i.ht
regress bwt i.ht age lwt i.race smoke ptl_agg
/*
Both models say that there is a significant effect of hypertension on
birthweight. The estimated effect is higher in the fully adjusted model, which
means that the initial estimate from the first model was affected by counfounding
*/

// Q3
// Backward selection - removes age. Brackets make stata keep all levels of factor
xi: stepwise, pr(0.2) lockterm1: regress bwt i.ht age lwt (i.race) (i.smoke) (i.ptl_agg)

// Forward selection - gets the same result as backwards
xi: stepwise, forward pe(0.2) lockterm1: regress bwt i.ht age lwt (i.race) (i.smoke) (i.ptl_agg)

// Q4 - change in estimates. Remove variables, starting with largest pval.
// Stop if change larger than 10%
regress bwt i.ht age lwt i.race i.smoke i.ptl_agg // -511.7718
regress bwt i.ht lwt i.race i.smoke i.ptl_agg // -511.702 (<1% change, continue)
regress bwt i.ht lwt i.race i.smoke //  -521.7028 (19% change, stop)

// Final model on line 56 - same as the forward & backward results

// Q5 - Put everything in, dont care about confounding anymore bc prediction

// Q6 - used different names compared to ones in the pset
// No need to lockterm anything now, and use a smaller cutoff
regress bwt i.ht age lwt i.race i.smoke i.ptl_agg i.ui i.ftv_agg
xi: stepwise, pr(0.05): regress bwt (i.ht) age lwt (i.race) (i.smoke) (i.ptl_agg) (i.ui)
xi: stepwise, forward pe(0.05): regress bwt (i.ht) age lwt (i.race) (i.smoke) (i.ptl_agg) (i.ui) (i.ftv_agg) (i.ftv_agg)


// Q7 - change in MSE
regress bwt i.ht age lwt i.race i.smoke i.ptl_agg i.ui i.ftv_agg
ereturn list // Look at the list of things returned by the model
di e(mss) // Mean sum of squares from the model - saves copy pasting
scalar mss_full = e(mss)

// First round, remove each variable in turn and calculate MSE for each:
regress bwt i.ht age lwt i.race i.smoke i.ptl_agg i.ui
scalar mss_1_ftv = e(mss)
regress bwt i.ht age lwt i.race i.smoke i.ptl_agg i.ftv_agg
scalar mss_1_ui = e(mss)
regress bwt i.ht age lwt i.race i.smoke i.ui i.ftv_agg
scalar mss_1_ptl = e(mss)
regress bwt i.ht age lwt i.race i.ptl_agg i.ui i.ftv_agg
scalar mss_1_smoke = e(mss)
regress bwt i.ht age lwt i.smoke i.ptl_agg i.ui i.ftv_agg
scalar mss_1_race = e(mss)
regress bwt i.ht age i.race i.smoke i.ptl_agg i.ui i.ftv_agg
scalar mss_1_lwt = e(mss)
regress bwt i.ht lwt i.race i.smoke i.ptl_agg i.ui i.ftv_agg
scalar mss_1_age = e(mss)

// Find differences in MSE, remove one with smallest MSE reduction
di mss_1_ftv / mss_full, mss_1_ui / mss_full, mss_1_ptl / mss_full, mss_1_smoke / mss_full, mss_1_race / mss_full, mss_1_lwt / mss_full, mss_1_age / mss_full

// Age has smallest reduction in MSE, so remove and repeat
regress bwt i.ht lwt i.race i.smoke i.ptl_agg i.ui i.ftv_agg
scalar mss_full = e(mss)

regress bwt i.ht lwt i.race i.smoke i.ptl_agg i.ui
scalar mss_2_ftv = e(mss)
regress bwt i.ht lwt i.race i.smoke i.ptl_agg i.ftv_agg
scalar mss_2_ui = e(mss)
regress bwt i.ht lwt i.race i.smoke i.ui i.ftv_agg
scalar mss_2_ptl = e(mss)
regress bwt i.ht lwt i.race i.ptl_agg i.ui i.ftv_agg
scalar mss_2_smoke = e(mss)
regress bwt i.ht lwt i.smoke i.ptl_agg i.ui i.ftv_agg
scalar mss_2_race = e(mss)
regress bwt i.ht i.race i.smoke i.ptl_agg i.ui i.ftv_agg
scalar mss_2_lwt = e(mss)

// Find differences in MSE, remove one with smallest MSE reduction
di mss_2_ftv / mss_full, mss_2_ui / mss_full, mss_2_ptl / mss_full, mss_2_smoke / mss_full, mss_2_race / mss_full, mss_2_lwt / mss_full

// FTV has the smallest reduction in MSE, so remove and repeat
regress bwt i.ht lwt i.race i.smoke i.ptl_agg i.ui
scalar mss_full = e(mss)

regress bwt i.ht lwt i.race i.smoke i.ptl_agg
scalar mss_3_ui = e(mss)
regress bwt i.ht lwt i.race i.smoke i.ui
scalar mss_3_ptl = e(mss)
regress bwt i.ht lwt i.race i.ptl_agg i.ui
scalar mss_3_smoke = e(mss)
regress bwt i.ht lwt i.smoke i.ptl_agg i.ui
scalar mss_3_race = e(mss)
regress bwt i.ht i.race i.smoke i.ptl_agg i.ui
scalar mss_3_lwt = e(mss)

di mss_3_ui / mss_full, mss_3_ptl / mss_full, mss_3_smoke / mss_full, mss_3_race / mss_full, mss_3_lwt / mss_full