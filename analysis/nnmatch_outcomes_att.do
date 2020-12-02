local outvar_econ="kfr_top20_pooled_pooled kir_top20_pooled_pooled kfr_pooled_pooled kir_pooled_pooled"
local outvar_social = "teenbrth_pooled_female jail_pooled_pooled working_pooled_pooled lpov_nbh_pooled_pooled"
local outcome=""
foreach var in `outvar_econ' `outvar_social' {
	local outcome = "`outcome' `var'_mean"
}

quietly kmatch md treat ${x} ${muni_control} (`outcome' = ${x} ${muni_control}), nn(1) cal(4.5) att vce(cluster name_id) idgen(match) replace
matrix table = r(table)
local column = 1
foreach var in `outvar_econ' `outvar_social' {
	local pval=table[4,`column']
	local b=table[1,`column']
	*local n_treat_`var'=e(_N)[1,1]
	*local n_match_`var'=e(_N)[1,4]
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
	local se_val=table[2,`column']
	*mat results_psmatch[`se',`i']=`se_val'
	
	local `var'="`b'`star'"
	
	local `var'_se=table[2,`column']
	
	quietly su `var'_mean if treat==1 & e(sample)==1
		
	local `var'_bl=r(mean)- `b'
		
	local `var'_ch=(r(mean)-``var'_bl')/``var'_bl'
		
	local column = `column'+1
}

quietly kmatch md treat ${x} ${muni_control}, nn(1) cal(4.5) att vce(cluster name_id) idgen(match) replace

foreach var in `outvar_econ' `outvar_social' {
    quietly count if match1!=. & !missing(`var'_mean)
    local n_treat_`var' = r(N)
	quietly unique match1 if match1!=. & !missing(`var'_mean)
	local n_match_`var' = r(unique)
}
file open myfile using "${results}\\att_nnmatch.tex", write replace
	#delimit;
	file write myfile "\begin{landscape}" _n
	"\begin{table}[htpb]" _n
	"\resizebox{.95\textwidth}{!}{" _n
	"\centering" _n
	"\begin{threeparttable}" _n
	"\caption{Mahalanobis distance nearest neighbor match estimates of average treatment effect on the treated of rent control on long-term outcomes}\label{table:att_nnmatch}" _n
	"\begin{tabular}{@{}l*{10}S}" _n
	"\toprule" _n
	"&\multicolumn{1}{r}{Top 20\%}&\multicolumn{1}{r}{Top 20\%}&\multicolumn{1}{r}{Percentile}&\multicolumn{1}{r}{Percentile}&\multicolumn{1}{r}{Teen}&\multicolumn{1}{r}{ }&\multicolumn{1}{r}{ }&\multicolumn{1}{r}{Low Pov.}&& \\" _n	
	"&\multicolumn{1}{r}{Fam.}&\multicolumn{1}{r}{Ind.}&\multicolumn{1}{r}{Fam. Inc.}&\multicolumn{1}{r}{Ind. Inc.}&\multicolumn{1}{r}{birth}&\multicolumn{1}{r}{Jail}&\multicolumn{1}{r}{Employed}&\multicolumn{1}{r}{nbhd.}&& \\" _n
	"\midrule" _n;
	#delimit cr

	file write myfile "ATT&`kfr_top20_pooled_pooled'&`kir_top20_pooled_pooled'&`kfr_pooled_pooled'&`kir_pooled_pooled'&`teenbrth_pooled_female'&`jail_pooled_pooled'&`working_pooled_pooled'&`lpov_nbh_pooled_pooled'&&\\" _n
	file write myfile "&(`kfr_top20_pooled_pooled_se')&(`kir_top20_pooled_pooled_se')&(`kfr_pooled_pooled_se')&(`kir_pooled_pooled_se')&(`teenbrth_pooled_female_se')&(`jail_pooled_pooled_se')&(`working_pooled_pooled_se')&(`lpov_nbh_pooled_pooled_se')&&\\" _n
	file write myfile "Baseline&`kfr_top20_pooled_pooled_bl'&`kir_top20_pooled_pooled_bl'&`kfr_pooled_pooled_bl'&`kir_pooled_pooled_bl'&`teenbrth_pooled_female_bl'&`jail_pooled_pooled_bl'&`working_pooled_pooled_bl'&`lpov_nbh_pooled_pooled_bl'&&\\" _n
	file write myfile "\%$\Delta$&`kfr_top20_pooled_pooled_ch'&`kir_top20_pooled_pooled_ch'&`kfr_pooled_pooled_ch'&`kir_pooled_pooled_ch'&`teenbrth_pooled_female_ch'&`jail_pooled_pooled_ch'&`working_pooled_pooled_ch'&`lpov_nbh_pooled_pooled_ch'&&\\" _n


#delimit;
file write myfile "\midrule" _n
"N Treat&`n_treat_kfr_top20_pooled_pooled'&`n_treat_kir_top20_pooled_pooled'&`n_treat_kfr_pooled_pooled'&`n_treat_kir_pooled_pooled'&`n_treat_teenbrth_pooled_female'&`n_treat_jail_pooled_pooled'&`n_treat_working_pooled_pooled'&`n_treat_lpov_nbh_pooled_pooled'&&\\" _n
"N Control&`n_match_kfr_top20_pooled_pooled'&`n_match_kir_top20_pooled_pooled'&`n_match_kfr_pooled_pooled'&`n_match_kir_pooled_pooled'&`n_match_teenbrth_pooled_female'&`n_match_jail_pooled_pooled'&`n_match_working_pooled_pooled'&`n_match_lpov_nbh_pooled_pooled'&&\\" _n
"\bottomrule" _n
"\end{tabular}" _n
"\begin{tablenotes}" _n
"\item The ATT row reports the average treatment effect on the treated of rent control on the average tract outcome. The ATT estimates are generated using a nearest neighbor Mahalanobis distance matching estimator that accounts for tract, city and county-level traits. The baseline row represents the average outcome of the matched counterfactual tracts."_n
"\item * = p $<$ 0.1, ** = p $<$ 0.05, *** = p $<$ 0.01."_n
"\end{tablenotes}"_n
"\end{threeparttable}"_n
"}"_n
"\end{table}"_n
"\end{landscape}"_n;
#delimit cr
file close myfile	





****************************************************************************************************************************************************************

*weighted version

****************************************************************************************************************************************************************

foreach var in `outvar_econ' `outvar_social' {
	
	quietly kmatch md treat ${x} ${muni_control} (`var'_mean = ${x} ${muni_control}) [fw=`var'_n], nn(1) cal(4.5) att vce(cluster name_id) idgen(match) replace
	
	local pval=r(table)[4,1]
	local b=e(b)[1,1]
	*local n_treat_`var'=e(_N)[1,1]
	*local n_match_`var'=e(_N)[1,4]
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
	quietly su `var'_mean if treat==1 & e(sample)==1 [fw=`var'_n]
	local `var'_bl=r(mean)-e(b)[1,1]
	local `var'_ch=(r(mean)-``var'_bl')/``var'_bl'
}

file open myfile using "${results}\\att_nnmatch_ind_weight.tex", write replace
	#delimit;
	file write myfile "\begin{landscape}" _n
	"\begin{table}[htpb]" _n
	"\resizebox{.95\textwidth}{!}{" _n
	"\centering" _n
	"\begin{threeparttable}" _n
	"\caption{Mahalanobis distance nearest neighbor match estimates of average treatment effect on the treated of rent control on long-term outcomes, weighted by children linked to a tract}\label{table:att_nnmatch_ind_weight}" _n
	"\begin{tabular}{@{}l*{10}S}" _n
	"\toprule" _n
	"&\multicolumn{1}{r}{Top 20\%}&\multicolumn{1}{r}{Top 20\%}&\multicolumn{1}{r}{Percentile}&\multicolumn{1}{r}{Percentile}&\multicolumn{1}{r}{Teen}&\multicolumn{1}{r}{ }&\multicolumn{1}{r}{ }&\multicolumn{1}{r}{Low Pov.}&& \\" _n	
	"&\multicolumn{1}{r}{Fam.}&\multicolumn{1}{r}{Ind.}&\multicolumn{1}{r}{Fam. Inc.}&\multicolumn{1}{r}{Ind. Inc.}&\multicolumn{1}{r}{birth}&\multicolumn{1}{r}{Jail}&\multicolumn{1}{r}{Employed}&\multicolumn{1}{r}{nbhd.}&& \\" _n
	"\midrule" _n;
	#delimit cr

	file write myfile "ATT&`kfr_top20_pooled_pooled'&`kir_top20_pooled_pooled'&`kfr_pooled_pooled'&`kir_pooled_pooled'&`teenbrth_pooled_female'&`jail_pooled_pooled'&`working_pooled_pooled'&`lpov_nbh_pooled_pooled'&&\\" _n
	file write myfile "&(`kfr_top20_pooled_pooled_se')&(`kir_top20_pooled_pooled_se')&(`kfr_pooled_pooled_se')&(`kir_pooled_pooled_se')&(`teenbrth_pooled_female_se')&(`jail_pooled_pooled_se')&(`working_pooled_pooled_se')&(`lpov_nbh_pooled_pooled_se')&&\\" _n
	file write myfile "Baseline&`kfr_top20_pooled_pooled_bl'&`kir_top20_pooled_pooled_bl'&`kfr_pooled_pooled_bl'&`kir_pooled_pooled_bl'&`teenbrth_pooled_female_bl'&`jail_pooled_pooled_bl'&`working_pooled_pooled_bl'&`lpov_nbh_pooled_pooled_bl'&&\\" _n
	file write myfile "\%$\Delta$&`kfr_top20_pooled_pooled_ch'&`kir_top20_pooled_pooled_ch'&`kfr_pooled_pooled_ch'&`kir_pooled_pooled_ch'&`teenbrth_pooled_female_ch'&`jail_pooled_pooled_ch'&`working_pooled_pooled_ch'&`lpov_nbh_pooled_pooled_ch'&&\\" _n


#delimit;
file write myfile "\midrule" _n
"N Treat&`n_treat_kfr_top20_pooled_pooled'&`n_treat_kir_top20_pooled_pooled'&`n_treat_kfr_pooled_pooled'&`n_treat_kir_pooled_pooled'&`n_treat_teenbrth_pooled_female'&`n_treat_jail_pooled_pooled'&`n_treat_working_pooled_pooled'&`n_treat_lpov_nbh_pooled_pooled'&&\\" _n
"N Control&`n_match_kfr_top20_pooled_pooled'&`n_match_kir_top20_pooled_pooled'&`n_match_kfr_pooled_pooled'&`n_match_kir_pooled_pooled'&`n_match_teenbrth_pooled_female'&`n_match_jail_pooled_pooled'&`n_match_working_pooled_pooled'&`n_match_lpov_nbh_pooled_pooled'&&\\" _n
"\bottomrule" _n
"\end{tabular}" _n
"\begin{tablenotes}" _n
"\item The ATT row reports the average treatment effect on the treated of rent control on the average tract outcome, weighted by the number of children linked to each tract. The ATT estimates are generated using a nearest neighbor Mahalanobis distance matching estimator that accounts for tract, city and county-level traits. The baseline row represents the average outcome of the matched counterfactual tracts."_n
"\item * = p $<$ 0.1, ** = p $<$ 0.05, *** = p $<$ 0.01."_n
"\end{tablenotes}"_n
"\end{threeparttable}"_n
"}"_n
"\end{table}"_n
"\end{landscape}"_n;
#delimit cr
file close myfile	

