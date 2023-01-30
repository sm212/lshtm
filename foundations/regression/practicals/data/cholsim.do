capture program drop cholsim
program define cholsim, rclass
version 16.0
syntax , [ ]

preserve

di in y "Regressions for simulated outcome: chol2_s"

* generate a simulated outcome variable
di in w "gen chol2_s = 110 + 0.6*chol1+rnormal(0,30) "
nois gen chol2_s = 110 + 0.6*chol1+rnormal(0,30) 

* generate a centred version of cholesterol at visit 1
su chol1
capture drop cenchol1
nois gen cenchol1=chol1-r(mean)
di in w "gen cenchol1=chol1-r(mean)"

*run a regression model using cholesterol at visit 1 as predictor
di
di in y "Predictor: cholesterol at visit 1"
di in w "regress chol2_s`i' chol1"

regress chol2_s`i' chol1
return scalar beta=_b[chol1]
return scalar beta_se=_se[chol1]
return scalar alpha=_b[_cons]
return scalar alpha_se=_se[_cons]

*run a regression model using centred cholesterol at visit 1 as predictor
di
di in y "Predictor: centred cholesterol at visit 1 (cenchol1)"
di in w "regress chol2_s`i' cenchol1"
regress chol2_s`i' cenchol1
return scalar cbeta=_b[cenchol1]
return scalar cbeta_se=_se[cenchol1]
return scalar calpha=_b[_cons]
return scalar calpha_se=_se[_cons]

drop chol2_s
restore

end cholsim



