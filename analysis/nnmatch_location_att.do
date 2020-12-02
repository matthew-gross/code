************************************************************************************************************
*Unweighted
**********************************************************************************************************

foreach var in frac_years_xw_pooled_pooled stayhome_pooled_pooled_mean staytract_pooled_pooled_mean staycz_pooled_pooled_mean {
	display "Variable is:		`var'"
	local j=1
	local se=2
	local varlist=""
	*foreach p of local percentile {
		local varlist="`varlist' `var'"
		capture drop gen _*
		
		quietly kmatch md treat ${x} ${muni_control} (`var' = ${x} ${muni_control}), nn(1) cal(4.5) att vce(cluster name_id) idgen(match) replace
		*mat results_psmatch[`j',`i']=e(b)
		local pval=r(table)[4,1]
		local b=r(table)[1,1]
		*quietly unique gen if e(sample) & treat==1
		local nt_`var'=e(_N)[1,1]
		local nm_`var'=e(_N)[1,4]
		if inrange(`pval',0,.01) {
				local star="***"
			}
			else if inrange(`pval',.01,.05) {
				local star="**"
			}
			else if inrange(`pval',.05,.1){
				local star="*"
			}
			else {
				local star=" "
			}
		local se_val=sqrt(e(V)[1,1])
		*mat results_psmatch[`se',`i']=`se_val'
		
		local `var'="`b'`star'"
		local `var'_se=r(table)[2,1]
		quietly su `var' if treat==1 & e(sample)==1
		local `var'_bl=r(mean)-`b'
		local `var'_ch=(r(mean)-``var'_bl')/``var'_bl'
		*local j=`j'+2
		*local se=`se'+2
*	}
	*mat results_psmatch[13,`i']=e(N)
	*mat results_psmatch[14,`i']=e(n1)	
}


file open myfile using "${results}\\att_location_mean.tex", write replace
	#delimit;
	file write myfile "\begin{table}[htpb]" _n
	"\centering" _n
	"\begin{threeparttable}" _n
	"\caption{Mahalanobis distance nearest neighbor match estimates of average treatment effect on the treated of rent control on location as child and adult}\label{table:att_location_mean}" _n
	"\begin{tabular}{@{}l*{6}S}" _n
	"\toprule" _n
"&\multicolumn{1}{r}{Frac. years}&\multicolumn{1}{r}{Stay}&\multicolumn{1}{r}{Stay}&\multicolumn{1}{r}{Stay}&& \\" _n	
	"&\multicolumn{1}{r}{in tract}&\multicolumn{1}{r}{home}&\multicolumn{1}{r}{Tract}&\multicolumn{1}{r}{Comm. Zone}&& \\" _n
	"\midrule" _n;
	#delimit cr



file write myfile "ATT&`frac_years_xw_pooled_pooled'&`stayhome_pooled_pooled_mean'&`staytract_pooled_pooled_mean'&`staycz_pooled_pooled_mean'&&\\" _n
file write myfile "&(`frac_years_xw_pooled_pooled_se')&(`stayhome_pooled_pooled_mean_se')&(`staytract_pooled_pooled_mean_se')&(`staycz_pooled_pooled_mean_se')&&\\" _n

file write myfile "Baseline&`frac_years_xw_pooled_pooled_bl'&`stayhome_pooled_pooled_mean_bl'&`staytract_pooled_pooled_mean_bl'&`staycz_pooled_pooled_mean_bl'&&\\" _n	

file write myfile "\%$\Delta$&`frac_years_xw_pooled_pooled_ch'&`stayhome_pooled_pooled_mean_ch'&`staytract_pooled_pooled_mean_ch'&`staycz_pooled_pooled_mean_ch'&&\\" _n	
	

#delimit;
file write myfile "\midrule" _n
"N Treat&`nt_frac_years_xw_pooled_pooled'&`nt_stayhome_pooled_pooled_mean'&`nt_staytract_pooled_pooled_mean'&`nt_staycz_pooled_pooled_mean'&&\\" _n
"N Control&`nm_frac_years_xw_pooled_pooled'&`nm_stayhome_pooled_pooled_mean'&`nm_staytract_pooled_pooled_mean'&`nm_staycz_pooled_pooled_mean'&&\\" _n
"\bottomrule" _n
"\end{tabular}" _n
"\begin{tablenotes}" _n
"\item The ATT row reports the average treatment effect on the treated of rent control on the average tract outcome. The ATT estimates are generated using a nearest neighbor Mahalanobis distance metric matching estimator. The baseline row represents the average outcome of the matched counterfactual tracts."_n
"\item * = p $<$ 0.1, ** = p $<$ 0.05, *** = p $<$ 0.01."_n
"\end{tablenotes}"_n
"\end{threeparttable}"_n
"\end{table}"_n;
#delimit cr
file close myfile	







***************************************************************************************************************************************


*Weighted


****************************************************************************************************************************************

foreach var in stayhome_pooled_pooled_mean staytract_pooled_pooled_mean staycz_pooled_pooled_mean {
	display "Variable is:		`var'"
	local j=1
	local se=2
	local varlist=""
	*foreach p of local percentile {
		local varlist="`varlist' `var'"
		capture drop gen _*
		local weight = subinstr("`var'", "_mean","_n",.)
		
		quietly kmatch md treat ${x} ${muni_control} (`var' = ${x} ${muni_control}) [fw =`weight'] , nn(1) cal(4.5) att vce(cluster name_id) idgen(match) replace
		*mat results_psmatch[`j',`i']=e(b)
		local pval=r(table)[4,1]
		local b=e(b)[1,1]
		*quietly unique gen if e(sample) & treat==1
		local nt_`var'=e(_N)[1,1]
		local nm_`var'=e(_N)[1,4]
		if inrange(`pval',0,.01) {
				local star="***"
			}
			else if inrange(`pval',.01,.05) {
				local star="**"
			}
			else if inrange(`pval',.05,.1){
				local star="*"
			}
			else {
				local star=" "
			}
		local se_val=sqrt(e(V)[1,1])
		*mat results_psmatch[`se',`i']=`se_val'
		
		local `var'="`b'`star'"
		local `var'_se=sqrt(e(V)[1,1])
		quietly su `var' if treat==1 & e(sample)==1 [fw=`weight']
		local `var'_bl=r(mean)-e(b)[1,1]
		local `var'_ch=(r(mean)-``var'_bl')/``var'_bl'
		*local j=`j'+2
		*local se=`se'+2
*	}
	*mat results_psmatch[13,`i']=e(N)
	*mat results_psmatch[14,`i']=e(n1)	
}


file open myfile using "${results}\\att_location_mean_ind_weight.tex", write replace
	#delimit;
	file write myfile "\begin{table}[htpb]" _n
	"\centering" _n
	"\begin{threeparttable}" _n
	"\caption{Mahalanobis distance nearest neighbor match estimates of average treatment effect on the treated of rent control on location as child and adult, weighted by number of children}\label{table:att_location_mean_ind_weight}" _n
	"\begin{tabular}{@{}l*{5}S}" _n
	"\toprule" _n
"&\multicolumn{1}{r}{Stay}&\multicolumn{1}{r}{Stay}&\multicolumn{1}{r}{Stay}&& \\" _n	
	"&\multicolumn{1}{r}{home}&\multicolumn{1}{r}{Tract}&\multicolumn{1}{r}{Comm. Zone}&& \\" _n
	"\midrule" _n;
	#delimit cr



file write myfile "ATT&`stayhome_pooled_pooled_mean'&`staytract_pooled_pooled_mean'&`staycz_pooled_pooled_mean'&&\\" _n
file write myfile "&(`stayhome_pooled_pooled_mean_se')&(`staytract_pooled_pooled_mean_se')&(`staycz_pooled_pooled_mean_se')&&\\" _n

file write myfile "Baseline&`stayhome_pooled_pooled_mean_bl'&`staytract_pooled_pooled_mean_bl'&`staycz_pooled_pooled_mean_bl'&&\\" _n	

file write myfile "\%$\Delta$&`stayhome_pooled_pooled_mean_ch'&`staytract_pooled_pooled_mean_ch'&`staycz_pooled_pooled_mean_ch'&&\\" _n	
	

#delimit;
file write myfile "\midrule" _n
"N Treat&`nt_stayhome_pooled_pooled_mean'&`nt_staytract_pooled_pooled_mean'&`nt_staycz_pooled_pooled_mean'&&\\" _n
"N Control&`nm_stayhome_pooled_pooled_mean'&`nm_staytract_pooled_pooled_mean'&`nm_staycz_pooled_pooled_mean'&&\\" _n
"\bottomrule" _n
"\end{tabular}" _n
"\begin{tablenotes}" _n
"\item The ATT row reports the average treatment effect on the treated of rent control on the average tract outcome, weighted by the number of children linked to each tract. The ATT estimates are generated using a nearest neighbor propensity score matching estimator. The baseline row represents the average outcome of the matched counterfactual tracts."_n
"\item * = p $<$ 0.1, ** = p $<$ 0.05, *** = p $<$ 0.01."_n
"\end{tablenotes}"_n
"\end{threeparttable}"_n
"\end{table}"_n;
#delimit cr
file close myfile	



