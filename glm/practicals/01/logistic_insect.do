log using "logistic_insect.log", replace
clear
use "insect.dta"
glm r dose, family(binomial n) link(logit)

// Convert to individual format
expand n
sort dose

// Make 'dead' 0/1 column - give each insect in each group an id (0, 1, ...),
// any insect with id < r is dead
gen rn = _n
egen grp_min_rn = min(rn), by(dose)
gen grp_idx = rn - grp_min_rn
gen dead = 1 if grp_idx < r
replace dead = 0 if missing(dead)

glm dead dose, family(binomial) link(logit)