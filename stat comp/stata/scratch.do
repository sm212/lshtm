********************************************************************************
* scratch.do
* Place to put misc bits, mostly just messing about trying to learn stata
********************************************************************************

* General stuff:
*	- Anything after a * is a comment, this is a problem for things like ls.
*	  If you want to use * as a wildcard, put it in DOUBLE quotes
*	- Inline comments need to use //
*	- If you open stata by opening a do file, stata automatically sets the
*	  location of the do file as the working directory
*	- Execute line by line: highlight (at least) 1 char of the line you want to
*	  run, then crtl + D

clear // Removes everything from memory
capture log close // Closes any open logs (they stay open if error)

log using scratch.log, replace // Write output to scratch.log - need to close!

ls "../data/*.dta" // list all the .dta files in the data folder
sysuse auto.dta // "use" puts a dataset in memory, auto comes bundled in "sys"

*** Looking at data - all of these work with varlists (see codebook ex below)
describe
browse
summarize // Obs is the number of NUMERIC observations (so no strings or NA)
codebook make price rep78 foreign // varlist = list of columns after command

* In the browser the foreign col was blue, thats because its coded (so not str)

* Looking at the help for browse, you can put an if after to filter:
help browse
browse if missing(rep78)

* Or if you dont want to browse, use list to find the values for a specific col:
list make if missing(rep78) // Get the values of make with missing rep78
********************************************************************************

*** Descriptives
summarize price, detail // Anything after , is optional. this one gets more info
browse if price > 13000

* One way tables - one way (percentages) or two way (interactions):
tabulate foreign
tabulate rep78
tabulate rep78 foreign, row // two way! ,row adds in row percentages

* Grouped summaries can be done by hand if you want:
summarize mpg if foreign == 0
summarize mpg if foreign == 1

* But its easier to use by, which is a PREFIX command. The main thing about
* prefix commands is they basically 2 commands (each with their own ,),
* separated by a :
by foreign : summarize mpg // syntax: by varlist [,] : <command [,]>
* by runs the code after : for each subgroups of the data before the :

* Looking at help tabulate, there's a 3rd option - tabulate followed by a
* summarize will produce tables with a summary of each combination group
tabulate foreign, summarize(mpg)

* Hypothesis test - just do t as an example, others similar
ttest mpg, by(foreign) // NOT the same by as the prefix, this one is an option

* Correlation matrices
correlate mpg weight
by foreign : correlate mpg weight
correlate mpg weight length turn displacement
********************************************************************************

*** Graphs

* Plotting two things at once are called "twoway"s in stata
* By default stata will use the variables Label to label the axes
twoway scatter mpg weight // Make a scatter plot of mpg (x) and weight (y)

* It's a good idea to put the plot command in (), lets you get more complex:
twoway (scatter mpg weight), by(foreign, total) // total adds a total chart
********************************************************************************

*** Regression (and more graphs)
* Model: mpg ~ weight + weight^2 + I[foreign]
* Need to make the weight^2 term first, then do the regression
gen wtsq = weight^2 // This will get added to the data loaded in memory
regress mpg weight wtsq foreign

* Now add predictions into the dataset - predict does the work, you just need to
* give the name of the new predicted variable (mpghat for this example)
predict mpghat

* Plot it
twoway (scatter mpg weight) (line mpghat weight, sort), by(foreign)

* Feels a bit weird that its quadratic - shouldnt mpg vs weight be linear?
* The amount of energy needed to move 2 tons should be double the amount needed 
* to move 1 ton
generate energy_efficiency = 100/mpg
twoway scatter energy_efficiency weight, by(foreign, total)

* The y axis looks daft because there's no label, so make one and replot
label variable energy_efficiency "Gallons per 100 miles"
twoway scatter energy_efficiency weight, by(foreign, total) 

* Looks like a very linear relationship, so try another regression (no sq term!)
regress energy_efficiency weight foreign

* So foreign cars arent more efficient, its just that they're lighter so they
* seemed to be more efficient in the summary stats

* Recreate the regression line plot with this new model:
predict energy_eff_hat
twoway (scatter energy_efficiency weight) (line energy_eff_hat weight, sort), by(foreign)

* Close the log file you opened at the start
log close