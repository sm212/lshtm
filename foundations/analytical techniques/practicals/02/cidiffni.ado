* ----------------------------------
* Stata program to illustrate effect
* of (i) increasing sample size and
* (ii) assuming known or unknown 
* population variance on CIs 
* ----------------------------------
* Updated 27-09-2021
* ----------------------------------

cap prog drop cidiffni
prog define cidiffni

preserve
clear
syntax anything  [ , UNKnown n(string) LEVel(integer 95) GRaph NAme(string)  ]

gettoken mean 0: 0 
gettoken sd 0: 0 , parse(",")

confirm number `mean'
confirm number `sd'

tokenize "`n'" , parse(",")
local nfirst `1'
local nlast `3'
local nstep `5'

	if  "`unknown'"=="" {
            local k known
				}
	else 	{
	    local k unknown
		}

local var=`sd'^2

if `level' <=0 | `level'>=100 {
		di in r "Level should be between 0 and 100
		exit
		} 

local obs= 1+ int((`nlast' - `nfirst')/`nstep')

clear
qui set obs `obs'
qui gen id=_n
qui gen n=`nfirst' + (id -1) *`nstep'

	if  "`unknown'"=="" {
					qui gen b=invnorm((100+`level')/200)
					local k known
				}
	else 	{
		local t=(100-`level')/200
		qui gen b=invttail(n , `t')
		local k unknown
		}
qui gen var=`var'
qui gen se=(`var'/n)^0.5
qui gen low=`mean'-b*(se)
qui gen up=`mean'+b*(se)
gen smean=`mean'
qui gen ci=(low<=`mean' & up<=`mean' | low>=`mean' & up>=`mean')
qui for var smean low up:gen X0=X if ci==0
qui for var smean low up:gen X1=X if ci==1


dis in green _newline
	if  "`unknown'"=="" {
            local t=((100+`level')/200)
            dis in green "     Mean   Var     N       SE      Z(`t')   Confidence interval"
            }
	else 	{
            local t=1-`t'
	    dis in green "     Mean   Var     N       SE      t(N,`t')  Confidence interval"
	}


dis in green "-------------------------------------------------------------------------"
list smean var n se b low up, clean noheader noobs
dis in green _newline
dis in green _newline



if "`graph'"~="" {

if "`name'"~="" {
		local name name(`name')
		}

#delimit ;
graph twoway 
	(rspike low0 up0 n , lcol(gs5) )
	(scatter smean n , ms(S) mcol(gs1)) 
	,
	scheme(s1mono)
	legend(off)
	xscale( range(`nfirst', `nlast') )
	xtitle("Sample size" , m(t+1))
	title("`lev'% CI for the mean mu with different sample size" "Population variance is assumed to be `k'" , size(*0.7) )
	yline(`mean' , lpat(dash) )
	xlab(`nfirst'(`nstep')`nlast')
	`name'	
;
#delimit cr
}

restore

end
