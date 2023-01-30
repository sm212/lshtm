// Practical 4 workings. Data folder is one level up, all files use relative paths

use ../data/growgam2.dta, clear
browse
describe
graph matrix sex age length mheight // Look at everything at once

histogram length
twoway (scatter length age) 
twoway (scatter length mheight) 
corr length age
corr length mheight
corr length sex

bysort sex : summarize length
/*
Theres a strong positive correlation between age and length, and a positive but
weaker correlation between length and mheight. There are differences in
height by sex, with males being slightly taller on average but with a higher
standard deviation
*/

// Univariable regressions
regress length age     // Strong relationship
regress length i.sex   // OK relationship
regress length mheight // Weak relationship

// Multivariable regressions part 1
regress length i.sex age

/*
On average, females are 1.39cm smaller than males of the same age (in this data).
The p-value of the coefficient is small, so the difference is statistically 
significant.
The coefficient is smaller in the regression of sex & age compared to the 
coefficient in the regression of just sex. This is because the regression of
sex and age is comparing the height of males vs females in children of the same
age. The regression of length on sex is comparing mean height by sex, and will 
be comparing heights for children of different ages. In the data, boys are
slighlty older (~.75 of a year) compared to girls.
Because age is strongly correlated with length, not adjusting for age in the 
analysis will confound the result. We can see in the second regression that the
standard error (and so confidence intervals) are smaller (narrower) in the 2nd
regression - it is a more accurate prediction of the effect of sex on length
*/

// Multivariable regressions part 2
regress length mheight age
/*
In this regression the mothers height is significant. The positive coefficient
means that taller mothers have, on average, taller children. Would expect to see
a positive correlation 
*/
corr length mheight // 0.2, positive

// Multivariable regressions part 3
regress length i.sex age mheight

/*
|   coef   |  univar  |    m1    |    m2    |    m3    |
|----------|----------|----------|----------|----------|
|  sexF    |  -1.93   |  -1.39   |          |  -1.30   |
|  age     |   0.74   |   0.74   |   0.74   |   0.73   |
|  mheight |   0.24   |          |   0.16   |   0.16   |

age is unchanged in all models, suggesting that length increases by 0.74 per 
month with very little variation by sex or mother height. Similarly mothers
height has a constant effect, suggesting that there is a positive effect and
the effect is constant by sex and age. The sex coefficient changes in each model
because we're making more accurate comparisons, though i dont think there's a
huge amount of difference between the estimates from m1 and m3 (this seems
true looking at the CIs for sex in m1 and m3, they overlap a lot)
*/

// Assumption checks
