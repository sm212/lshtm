use "../data/mental.dta"
browse
twoway scatter mentact prement, by(treat)
lowess mentact prement, bw(0.8)
hist(mentact)
hist(prement)
lowess mentact prement, bw(0.8) by(treat)
/*
- linear relationship between prement and mentact
- erorrs do seem normally distributed but changing variance
- mentact is right skewed

- treat == 1 looks good, treat == 2 a bit dodgy, treat == 3 probably not ok
*/

// Models 1, 2, ..., 5
regress mentact
regress mentact i.treat // treat is called 'drugs' in the pset
regress mentact prement
regress mentact i.treat prement
regress mentact i.treat##c.prement

// Add on predicted values from last model
predict pred_vals
browse
twoway (scatter mentact prement) (line pred_vals prement), by(treat)
/*
Intercepts and slopes for each group
treat == 1: intercept = 1.98, slope = 0.59
treat == 2: intercept = 0.77, slope = 0.51
treat == 3: intercept = 0.52, slope = 0.28
*/

// !!! CHECK SOLUTIONS FOR THIS, SYNTAX DOESNT WORK ON MODELS 4v5
// F-tests btw model 3 and 4, and model 4 and 5 - ORDER OF VARS MATTERS!!
// model 3 vs 4. Fit big model first (with var to compare last), then do test
regress mentact prement treat
test treat
/*
By hand RSS(m3) = 884.3, RSS(m4) = 752.1. Diff = 132.2, diff_df(m4, m3) = 2
MSE(m4) = RSS(m4) / resid_df(m4) = 752.1 / 68 = 11.06
F = Diff / diff_df(m4, m3) / MSE(m4) = 132.2 / 11.06 = 12.0 (close enough, rounding?)
*/

// model 4 and 5
regress mentact prement treat prement#treat
test prement#treat
/*
By hand RSS(m5) = 733.1, RSS(m4) = 752.1. Diff = 19
MSE(m5) = 733.1 / 66 = 11.12
F = Diff / MSE(m5) = 19 / 11.12 = 1.71
*/

glm mentact i.treat prement, family(gaussian) link(identity)
regress mentact i.treat prement
// Slightly different p values and conf ints - because GLM uses t instead of z

// Table for Q8
regress mentact i.treat
regress mentact i.treat prement

/*
Post injection mental activity does differ among groups. People treated with
heroin have significantly lower mental activity compared to placebo.
Adjusting for mental activity before drug assignent increases the size of this
effect.
There is evidence that the effect of the drugs varies by the persons level of
mental activity before injection, however after adjusting for the drug given this
effect is no longer significant
*/