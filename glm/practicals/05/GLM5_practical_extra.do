********************************************************************************
********************************************************************************
*Extra code for GLM practical 5 (end of Part A): 
*using bootstrapping to obtain 95% CIs for marginal treatment effect estimates.
********************************************************************************
********************************************************************************

* Load data
insheet using "../data/kidney_example.csv" , clear


capture program drop myboot
program myboot,rclass
               glm y i.x##i.z, family(binomial) eform
			   
               margins x
               matrix marg_probs=r(b)
               scalar marg_probs_x0=marg_probs[1,1]
               scalar marg_probs_x1=marg_probs[1,2]
			   
               scalar riskdiff=marg_probs_x1-marg_probs_x0
               scalar riskratio=marg_probs_x1/marg_probs_x0
               scalar oddsratio=(marg_probs_x1/(1-marg_probs_x1))/(marg_probs_x0/(1-marg_probs_x0))
			   
               return scalar riskdiff=riskdiff
               return scalar riskratio=riskratio
               return scalar oddsratio=oddsratio
               end
               
bootstrap riskdiff=r(riskdiff) riskratio=r(riskratio) oddsratio=r(oddsratio),rep(1000) seed(123): myboot

estat bootstrap, percentile
*This gives estimated 95% CIs for the marginal risk difference, marginal risk ratio, and marginal odds ratio

**********
*The margins command gives us a marginal risk difference and 95% CI:
glm y i.x##i.z, family(binomial) eform
margins x, dydx(x)

*The 95% CI for the risk difference obtained using the margins command is obtained using the delta method. The estimated 95% CI is very similar (but not identical) to the bootstrap 95% CI.
