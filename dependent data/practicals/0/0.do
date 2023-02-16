use "../data/births.dta", clear
browse

// Q2 Add labels for hyp & sex vars
label define hyp_lab 0 "normal" 1 "hypertensive"
label value hyp hyp_lab
label define sex_lab 1 "boy" 2 "girl"
label value sex sex_lab

// Q3 Chart
graph box bweight, over(hyp) by(sex, total)

/*
Non-hypertensive mothers have slightly higher birth weights compared to 
hypertensive (not significant). The difference varies by sex, with baby girls
having a smaller difference in birth weights by hypertension status than boys.
Boys have greater variation in birth weights compared to girls
*/

// Recreate some of the things in the chart by hand
tabstat bweight, by(sex) statistics(mean sd)
tabstat bweight, by(hyp) statistics(mean sd)

// Q4
regress bweight i.hyp // ANOVA - hypertensive mothers have babies ~431g lighter
oneway bweight i.hyp
ttest bweight, by(hyp) unequal

// Q5 Relation between bweight and gestational age, split by hypertension status
scatter bweight gest, by(hyp) // Looks fairly linear, bit hard to see in normals

// Q6
summarize gest
gen c_gest = gest - r(mean)
regress bweight i.hyp
regress bweight c_gest
regress bweight i.hyp c_gest
regress bweight i.hyp##c.c_gest

// Q7 Assumptions
