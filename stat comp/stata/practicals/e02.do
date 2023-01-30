/*
Practical 2 workings
Last edit: 20221011

Folder structure (needed for relative paths to work):
	/stat_comp
		/data
		/stata
			/practicals
				e02.do
*/

use "../../data/bl_demog.dta"
describe // 2500 obs, 21 vars. 17 have variable labels, 2 have value labels
browse // 1 row per pt, some missing wc_unit & different wc_units used
browse ptid wt ht wc

// Sort by wt (ascending)
sort wt
browse ptid wt ht wc

// Sort by wc (descending)
gsort -wc
browse ptid wt ht wc
browse ptid wt ht wc if wt > 130 & !missing(wt)

list ptid age wt sbp dbp if sbp < 90
count if sbp < 90 // Number of obs with sbp < 90
list ptid age wt sbp dbp if sbp > 180 // Includes missings - coded as big nums
list ptid *bp if _n in 1/10 // First 10 rows
list ptid *bp if _n in -10/l // Bottom 10 rows (l means last)

duplicates report ptid // No duplicate ptid
codebook ptid birthdt age agegroup race smkstat wt lvef diab

summarize age wt, detail

tabulate agegroup
tabulate sex
tabulate smkstat
tabulate agegroup hfdiag
tabulate agegroup diab, missing

histogram sbp, bin(15)
histogram wc // Weird spike near 0 is people measured in M
histogram hrate
histogram egfr
histogram lvef // Whole number lumping at multiple of 5

use "../../data/bl_labsall.dta"
browse
duplicates report ptid
codebook

histogram creat // Missings coded as 9999 (or 8888 in regid = 2). Others similar
histogram hb
histogram pot
histogram totbil if totbil < 1000

by regid : summarize hb, detail
list creat hb pot totbil if creat > 1000 // Not all missing

use "../../data/vitals_long.dta" // Repeated measures / longitudinal data
tabulate visit
tabulate param

by param : summarize value, detail // Some very big numbers in WC & DBP
histogram value if value < 200, by(param)
histogram value if value < 200 & param == 1, by(visit)

duplicates report ptid

