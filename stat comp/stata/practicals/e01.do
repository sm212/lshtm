* Changing working directory to data - dont bother with this so change it back
cd "../../data/"
cd "../stata/practicals"

* Load dataset into memory & browse - 2500 rows, 21 cols. factors are blue
use "../../data/bl_demog.dta"
browse

* Load in different data - if youve kept the browse window open it auto updates
use "../../data/vitals_long.dta"
use "../../data/bl_demog.dta" // Switch back

* List all .dta files in the data folder, if no path given lists cwd
ls "../../data/*.dta"

* Summarising data
tabulate agegroup
summarize age sbp hrate, detail
tabulate agegroup diab // Only has 2,499 obs - 1 missing?
list ptid agegroup diab if missing(diab) | missing(agegroup) // No diab recorded
tabulate agegroup diab, missing // Tell stata to include the missing obs
tabulate agegroup diab, row // Adds in row percentages

* Describing data, adding labels
describe // sbp, hrate both missing labels so add them
label variable sbp "Systolic Blood Pressure (mmHg)"
label variable hrate "Heart Rate (bpm)"
codebook ptid // Get example values, show how many missing etc for varlist
list ptid birthdt age sex if _n in 1/10 // _n is row number
sort age // Now try rerunning the list command above, should be different

* Graphics
histogram wt, bin(50) // Default is continuous with 30 bins
histogram wt, discrete // One bin for each unique value of wt
histogram wt, bin(40) frequency // Instead of density

histogram smkstat // Example for a discrete var with few levels
graph bar (mean) egfr, over(agegroup) // (summary stat) varlist, options
graph bar (mean) egfr, over(smkstat) by(agegroup) // Facets
graph bar (mean) egfr, over(agegroup) over(sex) // Facet single plot
graph bar (mean) egfr, over(agegroup) over(smkstat) // May look busy though...

graph box egfr, over(agegroup) over(sex) title("A bar chart")
* ytitle(), caption(), notes(), all options to label things on the chart

* Summary stats - correlation (print out & graph)
pwcorr age wt ht wc sbp hrate
graph matrix age wt ht wc sbp hrate
