// Practical 3 workings. Data folder is one level up, all files use relative paths

use ../data/growgam1.dta, clear

// 190 obs, 4 vars. No missing and no strange looking values
describe
codebook
histogram len

/* 
Not a huge difference in length by sex, easier to see in a boxplot.
Males slightly taller on average, but wider spread in height compared to F
Males have higher mean, median, SD compared to females 
*/
bysort sex : summarize len
graph box len, over(sex)

// Regression length by sex
gen female = 0 if sex == 1
replace female = 1 if sex == 2

/*
Intercept term changes if using the dummy or sex var. This is because they are
coded differently - in the first regression the intercept is the mean height
when female == 0 (ie mean height for males). In the second regression the
intercept is the mean height when sex == 0 which is an extrapolation and 
doesnt have an easy interpretation. In both cases the slope is the change in
mean height from male to female, so that coefficient is unchanged
*/ 
regress len female
regress len sex

/*
Sentence from q4: The intercept is the mean length when the dummy variable is 0.
The mean length of boys is 77.8cm. The slope for the dummy variable shows the
change in mean length when the dummy variable is 1 compared to 0. This means
that girls are 1.92cm shorter than boys
*/

/*
Assumptions: There is a linear relationship between mean height given the sex
of the child. The height of the children are independent from each other, the
height of a child is normally distributed with the same variance for all values
of sex.

Looking at the summary tables, the SDs vary by sex, but not by a huge amount.
Its probably fine for this amount of data
*/

// ANOVA
oneway len sex // F = 3.43, same as in the regressions above
oneway len female // Exact same ANOVA, just recoding the x term
display 173.362242 / 50.5524825 // = 3.43, calculating F by hand
/*
Since the p value for F is 0.066 > 0.05 we cant reject the null. There is no
strong evidence that there are difference in height by sex in this group of kids
*/

// ANCOVA
use ../data/larvae.dta, clear
browse
twoway (scatter lcount group)
regress lcount i.group // The i. prefix tells stata to convert group to a factor
/* 
The intercept is the mean of group 1, then all other coefs are differences
between mean of group i and group 1
*/
oneway lcount group