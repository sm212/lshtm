* ================================================
* Syntax is sample size, pop mean, pop var
* Amended DRA 2004
* Amended TJC 2017
* ================================================

prog cishowi

* preserve
clear
syntax anything  [ , UNKnown REPeats(integer 200) LEVel(integer 95) Graph NAMe(string) SAVIng(string) REPLACE ]

gettoken obs 0: 0  
gettoken mean 0: 0 
gettoken var 0: 0 , parse(",")

confirm integer number `obs'
confirm number `mean'
confirm number `var'

	if  "`unknown'"=="" {
            local k known
				}
	else 	{
	    local k unknown
		}



if `level' <=0 | `level'>=100 {
		di in r "Level should be between 0 and 100
		exit
		} 

tempvar x
if "`saving'"~="" {
		  local cishow `saving'
		  }
else 	{
	tempfile cishow
	}

qui postfile temp smean svar n using `cishow'  , `replace'

local sd `var'^0.5
local i=1
while `i'<`repeats'+1 	{
	qui set obs `obs'
	qui gen x=`mean'+`sd'*invnorm(uniform())
	qui summ x, d
	post temp (`r(mean)') (`r(Var)') (`r(N)')
	drop x
	local i=`i'+1
	}
postclose temp

qui use `cishow' , clear
qui sort smean
qui gen id=_n

	if  "`unknown'"=="" {
			local b=invnorm((100+`level')/200)
			local k known
			gen se=(`var'/`obs')^0.5 /*var known: taking se from this*/	
			}
	else 	{
		local t=(100-`level')/200
		local b=invttail(`obs'-1 , `t')
		local k unknown
		gen se=((svar/n)^0.5) /*variance unknown:taking se from sample; I think n=`obs'*/
		}

qui gen low=smean-`b'*se /*I've replaced the previous se here*/
qui gen up=smean+`b'*se /*ditto*/
qui gen ci=(low<=`mean' & up<=`mean' | low>=`mean' & up>=`mean')

qui count if ci==0
local n1=r(N)
local p=round((`n1'/`repeats')*100)


dis in green _newline
di in green "This program samples " in yellow "`obs'" in green " observations from the following distribution:" 
di in green "                     Normal with mean " in yellow "`mean'" in green  " and variance " in yellow "`var'" 
dis in green _newline
di in green  "The sampling is repeated " in yellow "`repeats'" in green " times." 
di in green  "For each sample we calculate a " in yellow "`level'" in green "% CI assuming the variance is " in yellow "`k'". 
dis in green _newline
di in g "In this set of `repeats' samples `n1' (`p'%) CIs included the true mean"
di _newline 


if "`graph'"~="" {

if "`name'"~="" {
		local name name(`name')
		}

#delimit ;
graph twoway 
	(rspike low up id if ci==0 , lcol(gs5) lwidth(*0.8) )
	(scatter smean id if ci==0  , ms(s) msize(*0.7) mcol(gs1)) 
	(rspike low up id if ci==1, lcol(red) lwidth(*0.8) )
	(scatter smean id if ci==1 , ms(s) msize(*0.7) mcol(red)) 
	,
	scheme(s1mono)
	legend(off)
	xscale( range(0, `repeats') )
	title("`p'% of CIs include {&mu}" "Population variance is assumed to be `k'" , size(*0.7) )
	yline(`mean' , lpat(dash) )
	xlab()
	ylab()
	xtitle("Sample" , m(t+2))
	ytitle("Sample Mean (`level'% CI)")
	`name'	
;
#delimit cr
}

* restore

end
