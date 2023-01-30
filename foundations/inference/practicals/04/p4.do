// PRACTICAL 4
clear

// q1
range p 0.01 0.99 999
gen l = p^3 * (1-p)^7
twoway line l p

gen lr = 0.1^3 * (1-0.1)^7 - 0.5^3 * (1-0.5)^7
display lr log(lr)
drop lr
egen max_l = max(l)
list p if l == max_l
gen lr = l / max_l
gen llr = log(lr)
twoway line llr p if llr > -4, yline(-1.92) xline(0.085 0.61) // [0.085, 0.61]
list p llr
list p if abs(llr + 1.92) < 0.05

// q2
gen ll_30 = 30 * log(p) + 70 * log(1-p)
egen max_ll_30 = max(ll_30)
gen llr_30 = ll_30 - max_ll_30
twoway (line llr p if llr > -4) (line llr_30 p if llr_30 > -4)

// q3 - poisson with 8 obs in 160 (lambda = 0.05)
clear
range lambda 0.01 0.1 999
gen ll = -160 * lambda + 8 * log(lambda)
egen max_ll = max(ll)
gen llr = ll - max_ll
twoway line llr lambda if llr > -4, yline(-1.92) xline(.023 .093)
list lambda if abs(llr + 1.92) < 0.05