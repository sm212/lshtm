clear
use "../data/oesophageal_data-1"
browse
codebook tobacco_group alcohol_grp // See numeric codes for each labelled group

// Q1
gen tobacco_2 = 1 if tobacco == 0
replace tobacco_2 = 0 if missing(tobacco_2)

tabulate tobacco_2 alcohol_grp, chi
tabulate tobacco_2 age, chi
tabulate age alcohol_grp, chi
/*
Significant associations between tobacco use and age, tobacco use and alcohol use,
and age and alcohol use. It is likely that age and alcohol use also are
associated with oesophageal cancer, so these are confounders which will need to
be controlled for in the analysis
*/

// Q2
cc case tobacco_2, woolf // Calculates odds ratio & CI using Woolf formula
/*
Exposure is if the person has tobacco_2 == 1, so exposure is never smoking.
Says that the odds ratio of being a case (having oesophageal cancer) is 
0.096 [0.049, 0.191], so the odds of having oesophageal cancer in non smokers
is 99% lower compared to smokers
*/

mhodds case tobacco_2 // Very similar - OR is 0.096 [0.047, 0.196]

// Q3
/*
m1: case ~ tobacco_2 (case = beta_0 + beta_1[tobacco_2])
m2: tobacco_2 ~ case ([tobacco_2] = alpha_0 + alpha_1[case])
*/

logistic case tobacco_2
logistic tobacco_2 case // IDENTICAL odds ratio and CI

// Q4
mhodds case tobacco_2 alcohol_grp
mhodds tobacco_2 case alcohol_grp // IDENTICAL conditional odds ratio and CI

// Q5 - intercept params have no interpretation
glm case i.tobacco_2 i.alcohol_grp, family(binomial) link(logit) eform
glm tobacco_2 i.case i.alcohol_grp, family(binomial) link(logit) eform // IDENTICAL

// Q6
glm case i.tobacco_2 i.alcohol_grp age, family(binomial) link(logit) eform
/*
Very little - could be that age isnt a confounder after adjusting for alcohol
use, or could be due to non-collapsibility of the odds ratio?
*/

// Q7
clear
use "../data/oesophageal_data-2"
gen tobacco_2 = 1 if tobacco == 0
replace tobacco_2 = 0 if missing(tobacco_2)

glm case tobacco_2 alcohol age, family(binomial) link(logit)

/*
Bit more choice in how to include the continuous vars in the model, so may be
misspecifying the model somewhat. On the plus side we're not losing any info
by dichotomising continuous variables like we did in the previous data
*/
