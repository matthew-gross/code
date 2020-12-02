*Establishing locals
local outvar_econ="kfr_top20_pooled_pooled kir_top20_pooled_pooled kfr_pooled_pooled kir_pooled_pooled"
local outvar_social = "teenbrth_pooled_female jail_pooled_pooled working_pooled_pooled lpov_nbh_pooled_pooled"

local outcome_p25=""
foreach var in `outvar_econ' `outvar_social' {
	local outcome_p25 = "`outcome_p25' `var'_p25"
}

local outcome_p75=""
foreach var in `outvar_econ' `outvar_social' {
	local outcome_p75 = "`outcome_p75' `var'_p75"
}

*Nearest neighbor matching for the 25th and 75th percentile predicted samples
quietly kmatch md treat ${x} ${muni_control} (`outcome_p25' = ${x} ${muni_control}), nn(1) cal(4.5) att vce(cluster name_id) idgen(match) replace
mat table_p25 = r(table)

quietly kmatch md treat ${x} ${muni_control} (`outcome_p75' = ${x} ${muni_control}), nn(1) cal(4.5) att vce(cluster name_id) idgen(match) replace
mat table_p75 = r(table)

local column = 1
foreach var in `outvar_econ' `outvar_social' {
	display "Variable is:		`var'"
	local j=1
	local se=2
	local varlist=""
	foreach p in p25 p75 {
				
		local pval=table_`p'[4,`column']
		local b=table_`p'[1,`column']
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
		local `var'_`p'_se=table_`p'[2,`column']
		*mat results_psmatch[`se',`i']=`se_val'
		
		local `var'_`p'="`b'`star'"
		*local `var'_`p'_se=sqrt(e(V)[1,1])
		quietly su `var'_`p' if treat==1 & e(sample)==1
		local `var'_`p'_bl=r(mean)-`b'
		local `var'_`p'_ch=(r(mean)-``var'_`p'_bl')/``var'_`p'_bl'
	}
	
	local column = `column' + 1
	
}

quietly kmatch md treat ${x} ${muni_control}, nn(1) cal(4.5) att vce(cluster name_id) idgen(match) replace

foreach var in `outvar_econ' `outvar_social' {
    quietly count if match1!=. & !missing(`var'_p25)
    local n_treat_`var' = r(N)
	quietly unique match1 if match1!=. & !missing(`var'_p25)
	local n_match_`var' = r(unique)
}


file open myfile using "${results}\\att_nnmatch_predict.tex", write replace
	#delimit;
	file write myfile "\begin{landscape}" _n
	"\begin{table}[htpb]" _n
	"\resizebox{.95\textwidth}{!}{" _n	
	"\centering" _n
	"\begin{threeparttable}" _n
	"\caption{Mahalanobis distance nearest neighbor match estimates of average treatment effect on the treated of rent control on long-term predicted outcomes}\label{table:att_nnmatch_predict}" _n
	"\begin{tabular}{@{}l*{10}S}" _n
	"\toprule" _n
	"&\multicolumn{1}{r}{Top 20\%}&\multicolumn{1}{r}{Top 20\%}&\multicolumn{1}{r}{Percentile}&\multicolumn{1}{r}{Percentile}&\multicolumn{1}{r}{Teen}&\multicolumn{1}{r}{ }&\multicolumn{1}{r}{ }&\multicolumn{1}{r}{Low Pov.}&& \\" _n	
	"&\multicolumn{1}{r}{Fam.}&\multicolumn{1}{r}{Ind.}&\multicolumn{1}{r}{Fam. Inc.}&\multicolumn{1}{r}{Ind. Inc.}&\multicolumn{1}{r}{birth}&\multicolumn{1}{r}{Jail}&\multicolumn{1}{r}{Employed}&\multicolumn{1}{r}{nbhd.}&& \\" _n
	"\midrule" _n;
	#delimit cr
	
	
foreach p in p25 p75{
	local p_out = strupper("`p'")
	if "`p'" == "p25" {
		local letter = "A"
	}
	
	else if "`p'" == "p75" {
		local letter = "B"
	}
	file write myfile "\multicolumn{9}{l}{\emph{Panel `letter': ATT estimates for children at `p_out' of parent income distribution}} \\" _n
	file write myfile"\multicolumn{1}{c}{Estimate}&`kfr_top20_pooled_pooled_`p''&`kir_top20_pooled_pooled_`p''&`kfr_pooled_pooled_`p''&`kir_pooled_pooled_`p''&`teenbrth_pooled_female_`p''&`jail_pooled_pooled_`p''&`working_pooled_pooled_`p''&`lpov_nbh_pooled_pooled_`p''&&\\" _n
	file write myfile "&(`kfr_top20_pooled_pooled_`p'_se')&(`kir_top20_pooled_pooled_`p'_se')&(`kfr_pooled_pooled_`p'_se')&(`kir_pooled_pooled_`p'_se')&(`teenbrth_pooled_female_`p'_se')&(`jail_pooled_pooled_`p'_se')&(`working_pooled_pooled_`p'_se')&(`lpov_nbh_pooled_pooled_`p'_se')&&\\" _n
	file write myfile "\multicolumn{1}{c}{Baseline}&`kfr_top20_pooled_pooled_`p'_bl'&`kir_top20_pooled_pooled_`p'_bl'&`kfr_pooled_pooled_`p'_bl'&`kir_pooled_pooled_`p'_bl'&`teenbrth_pooled_female_`p'_bl'&`jail_pooled_pooled_`p'_bl'&`working_pooled_pooled_`p'_bl'&`lpov_nbh_pooled_pooled_`p'_bl'&&\\" _n
	file write myfile "\multicolumn{1}{c}{\%$\Delta$}&`kfr_top20_pooled_pooled_`p'_ch'&`kir_top20_pooled_pooled_`p'_ch'&`kfr_pooled_pooled_`p'_ch'&`kir_pooled_pooled_`p'_ch'&`teenbrth_pooled_female_`p'_ch'&`jail_pooled_pooled_`p'_ch'&`working_pooled_pooled_`p'_ch'&`lpov_nbh_pooled_pooled_`p'_ch'&&\\" _n
	if "`p'"=="p25"{
		file write myfile "\multicolumn{9}{c}{  } \\" _n
	}
}

#delimit;
file write myfile "\midrule" _n
"N Treat&`n_treat_kfr_top20_pooled_pooled'&`n_treat_kir_top20_pooled_pooled'&`n_treat_kfr_pooled_pooled'&`n_treat_kir_pooled_pooled'&`n_treat_teenbrth_pooled_female'&`n_treat_jail_pooled_pooled'&`n_treat_working_pooled_pooled'&`n_treat_lpov_nbh_pooled_pooled'&&\\" _n
"N Control&`n_match_kfr_top20_pooled_pooled'&`n_match_kir_top20_pooled_pooled'&`n_match_kfr_pooled_pooled'&`n_match_kir_pooled_pooled'&`n_match_teenbrth_pooled_female'&`n_match_jail_pooled_pooled'&`n_match_working_pooled_pooled'&`n_match_lpov_nbh_pooled_pooled'&&\\" _n
"\bottomrule" _n
"\end{tabular}" _n
"\begin{tablenotes}" _n
"\item Estimates are reported for the predicted outcomes of children growing up in tracts at the 25th and 75th percentile of parent income. The predicted outcomes are generated by regressing individual outcomes on a transformation of parent income rank and recovering the fitted values at these two points of the parent income rank. The ATT is estimated using the baseline Mahalanobis distance matching estimator."_n
"\item * = p $<$ 0.1, ** = p $<$ 0.05, *** = p $<$ 0.01."_n
"\end{tablenotes}"_n
"\end{threeparttable}"_n
"}"_n
"\end{table}"_n
"\end{landscape}"_n;
#delimit cr
file close myfile	


******************************************************************************************************************************************************

*Weighted ATT

*******************************************************************************************************************************************
/*
foreach var in `outvar_econ' `outvar_social' {
	display "Variable is:		`var'"
	local j=1
	local se=2
	local varlist=""
	foreach p in p25 p75 {
		local varlist="`varlist' `var'_`p'"
		capture drop gen
		capture drop _*
		
		quietly kmatch md treat ${x} ${muni_control} (`var'_`p' = ${x} ${muni_control}) [fw=`var'_n], nn(1) cal(4.5) att vce(cluster name_id) idgen(match) replace
		local pval=r(table)[4,1]
		local b=e(b)[1,1]
		local n_treat_`var'=e(_N)[1,1]
		local n_match_`var'=e(_N)[1,4]
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
		
		local `var'_`p'="`b'`star'"
		local `var'_`p'_se=sqrt(e(V)[1,1])
		quietly su `var'_`p' if treat==1 & e(sample)==1 [fw = `var'_n]
		local `var'_`p'_bl=r(mean)-e(b)[1,1]
		local `var'_`p'_ch=(r(mean)-``var'_`p'_bl')/``var'_`p'_bl'
	}
}


file open myfile using "${results}\\att_nnmatch_predict_ind_weight.tex", write replace
	#delimit;
	file write myfile "\begin{landscape}" _n
	"\begin{table}[htpb]" _n
	"\centering" _n
	"\begin{threeparttable}" _n
	"\caption{Mahalanobis distance nearest neighbor match estimates of average treatment effect on the treated of rent control on long-term predicted outcomes, weighted by number of children}\label{table:att_nnmatch_predict_ind_weight}" _n
	"\begin{tabular}{@{}l*{10}S}" _n
	"\toprule" _n
	"&\multicolumn{1}{r}{Top 20\%}&\multicolumn{1}{r}{Top 20\%}&\multicolumn{1}{r}{Percentile}&\multicolumn{1}{r}{Percentile}&\multicolumn{1}{r}{Teen}&\multicolumn{1}{r}{ }&\multicolumn{1}{r}{ }&\multicolumn{1}{r}{Low Pov.}&& \\" _n	
	"&\multicolumn{1}{r}{Fam.}&\multicolumn{1}{r}{Ind.}&\multicolumn{1}{r}{Fam. Inc.}&\multicolumn{1}{r}{Ind. Inc.}&\multicolumn{1}{r}{birth}&\multicolumn{1}{r}{Jail}&\multicolumn{1}{r}{Employed}&\multicolumn{1}{r}{nbhd.}&& \\" _n
	"\midrule" _n;
	#delimit cr
	
	
foreach p in p25 p75{
	local p_out = strupper("`p'")
	if "`p'" = "p25" {
		local letter = "A"
	}
	
	else if "`p'" = "p75" {
		local letter = "B"
	}
	file write myfile "\multicolumn{9}{l}{\emph{Panel `letter': ATT estimates for children at `p_out' of parent income distribution}} \\" _n
	file write myfile"\multicolumn{1}{c}{Estimate}&`kfr_top20_pooled_pooled_`p''&`kir_top20_pooled_pooled_`p''&`kfr_pooled_pooled_`p''&`kir_pooled_pooled_`p''&`teenbrth_pooled_female_`p''&`jail_pooled_pooled_`p''&`working_pooled_pooled_`p''&`lpov_nbh_pooled_pooled_`p''&&\\" _n
	file write myfile "&(`kfr_top20_pooled_pooled_`p'_se')&(`kir_top20_pooled_pooled_`p'_se')&(`kfr_pooled_pooled_`p'_se')&(`kir_pooled_pooled_`p'_se')&(`teenbrth_pooled_female_`p'_se')&(`jail_pooled_pooled_`p'_se')&(`working_pooled_pooled_`p'_se')&(`lpov_nbh_pooled_pooled_`p'_se')&&\\" _n
	file write myfile "\multicolumn{1}{c}{Baseline}&`kfr_top20_pooled_pooled_`p'_bl'&`kir_top20_pooled_pooled_`p'_bl'&`kfr_pooled_pooled_`p'_bl'&`kir_pooled_pooled_`p'_bl'&`teenbrth_pooled_female_`p'_bl'&`jail_pooled_pooled_`p'_bl'&`working_pooled_pooled_`p'_bl'&`lpov_nbh_pooled_pooled_`p'_bl'&&\\" _n
	file write myfile "\multicolumn{1}{c}{\%$\Delta$}&`kfr_top20_pooled_pooled_`p'_ch'&`kir_top20_pooled_pooled_`p'_ch'&`kfr_pooled_pooled_`p'_ch'&`kir_pooled_pooled_`p'_ch'&`teenbrth_pooled_female_`p'_ch'&`jail_pooled_pooled_`p'_ch'&`working_pooled_pooled_`p'_ch'&`lpov_nbh_pooled_pooled_`p'_ch'&&\\" _n
	if "`p'"=="p25"{
		file write myfile "\multicolumn{9}{c}{  } \\" _n
	}
}

#delimit;
file write myfile "\midrule" _n
"N Treat&`n_treat_kfr_top20_pooled_pooled'&`n_treat_kir_top20_pooled_pooled'&`n_treat_kfr_pooled_pooled'&`n_treat_kir_pooled_pooled'&`n_treat_teenbrth_pooled_female'&`n_treat_jail_pooled_pooled'&`n_treat_working_pooled_pooled'&`n_treat_lpov_nbh_pooled_pooled'&&\\" _n
"N Control&`n_match_kfr_top20_pooled_pooled'&`n_match_kir_top20_pooled_pooled'&`n_match_kfr_pooled_pooled'&`n_match_kir_pooled_pooled'&`n_match_teenbrth_pooled_female'&`n_match_jail_pooled_pooled'&`n_match_working_pooled_pooled'&`n_match_lpov_nbh_pooled_pooled'&&\\" _n
"\bottomrule" _n
"\end{tabular}" _n
"\begin{tablenotes}" _n
"\item Estimates are reported for the predicted outcomes of children growing up in tracts at the 25th and 75th percentile of parent income. The predicted outcomes are generated by regressing individual outcomes on a transformation of parent income rank and recovering the fitted values at these two points of the parent income rank. The ATT is estimated using the baseline Mahalanobis distance matching estimator."_n
"\item * = p $<$ 0.1, ** = p $<$ 0.05, *** = p $<$ 0.01."_n
"\end{tablenotes}"_n
"\end{threeparttable}"_n
"\end{table}"_n
"\end{landscape}"_n;
#delimit cr
file close myfile	

