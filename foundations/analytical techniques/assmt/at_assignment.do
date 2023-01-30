use ATREG_assign2022.dta, clear
browse
ttest sdmt, by(group) unequal
corrci sdmt age
corrci sdmt age if group == 1
corrci sdmt age if group == 2
corrci sdmt cag if group == 2
corrci age cag if group == 2
gen age_cen = age - 40.81667
gen cag_cen = cag - 43.14167
regress sdmt age_cen cag_cen if group == 2

twoway scatter cag age
