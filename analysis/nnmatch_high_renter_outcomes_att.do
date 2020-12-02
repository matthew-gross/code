*Establishing locals

local pop_tract_lab="Population"
local male_lab="Male (\%)"
local pop_density_lab="Pop./sq. mile"
local age_median_lab="Age median"
local white_lab="white (\%)"
local black_lab="black (\%)"
local hh_occ_lab="Total HH"
local married_lab="Married (\%)"
local educ_no_hs_lab="Educ. Less than HS (\%)"
local educ_hs_lab="Educ. HS (\%)"
local lfp_lab="LFP rate"
local unemployment_lab="Unemployment rate"
local avg_fam_inc_lab="Avg. family inc."
local avg_ind_inc_lab="Avg. inc."
local fam_below_pov_lab="Family poverty rt. (\%)"
local duration_5_lab="Current addr. 5 years (\%)"
local units_total_lab="Housing units"
local renter_occ_per_lab="Rental (\% of total units)"
local avg_unit_value_lab="Avg. home value"
local avg_gross_rent_lab="Avg. rent"
local foreign_born_lab="Foreign born (\%)"
local rent_vac_rate_lab="Rental vacancy rate (\%)"
local effect_rent_vac_lab = "Rent vacancy x Rental \%"
local sing_par_lab="Single parent fam. (\%)"

local city_renter_occ_per_lab = "City rental (\% of total units)" 
local city_rent_vac_rate_lab = "City rental vacancy rate (\%)"
local city_white_lab = "City white (\%)"
local city_black_lab = "City black (\%)" 
local city_unemployment_lab = "City unemployment rate" 
local city_avg_gross_rent_lab = "City avg. rent"
local pres_1968_dem_lab = "County Dem. vote share 1968"
local pres_1968_wallace_lab = "County Wallace vote share 1968"
local population_lab = "City population"
local city_fam_below_pov_lab = "City family poverty rt. (\%)"
local gov_revenue_pc_lab = "City revenue per capita"
local tax_total_revenue_pc_lab = "City tax revenue per capita"
local tax_property_revenue_pc_lab = "City property tax revenue per capita"
local gov_state_igr_pc_lab = "City revenue from state per capita"
local gov_expenditure_total_pc_lab = "City expenditure per capita"
local gov_educ_expenditure_pc_lab = "City education expenditure per capita"
local police_expenditure_pc_lab =  "City police expenditure per capita"
local public_welf_expenditure_pc_lab = "City welfare expenditure per capita"

local tax_property_revenue_share_lab = "Property tax share of rev."
local gov_state_igr_share_lab = "Other gov. sources share of rev."
local gov_educ_expend_share_lab = "Educ. share of expenditure"
local police_expend_share_lab = "Police share of expenditure"
local public_welf_expend_share_lab= "Welfare share of expenditure"

*Keeping observations above the 25th percentile of rent occupancy in the rent controlled tracts
quietly su renter_occ_per if treat==1, d
local median = r(p25)

preserve
	keep if renter_occ_per>=`median'
	quietly kmatch md treat ${x} ${muni_control}, nn(1) cal(4.5) att vce(cluster name_id) idgen(match) replace
	quietly kmatch summarize ${x} ${muni_control}

	mat balance=r(M)[1..${wc},3],r(M)[1..${wc},6],r(V)[1..${wc},3],r(V)[1..${wc},6]

	file open myfile using "${results}\\nnmatch_balance_high_rent.tex", write replace
		#delimit;
		file write myfile "\begin{table}[htpb]" _n
		"\resizebox{.95\textwidth}{!}{" _n
		"\centering" _n
		"\begin{threeparttable}" _n
		"\caption{Comparing means and variances of the raw and weighted samples using the two-step nearest neighbor matching algorithm: high rental tract sample}\label{table:nnmatch_balance_high_rent}" _n
		"\begin{tabular}{@{}l*{6}S}" _n
		"\toprule" _n
		"&\multicolumn{2}{c}{Std. Mean Diff.}&\multicolumn{2}{c}{Var. Ratio}&& \\" _n
		"&\multicolumn{1}{c}{Raw}&\multicolumn{1}{c}{Matched}&\multicolumn{1}{c}{Raw}&\multicolumn{1}{c}{Matched}&& \\" _n
		"\midrule" _n;
		#delimit cr

	local i=1
	foreach var of global control {
		local mean_diff_raw=balance[`i',1]
		local mean_diff_match=balance[`i',2]
		local var_diff_raw=balance[`i',3]
		local var_diff_match=balance[`i',4]
		
		file write myfile "``var'_lab'&" %04.3fc (`mean_diff_raw') "&" %04.3fc (`mean_diff_match') "&" %04.3fc (`var_diff_raw') "&" %04.3fc (`var_diff_match') "&&\\" _n
		local i=`i'+1
	}

	#delimit;
	file write myfile "\midrule" _n
	"N&\multicolumn{1}{r}{" %10.0fc (e(N)) "}&&&&&\\" _n
		"N Treat&\multicolumn{1}{r}{" %10.0fc (e(_N)[1,1]) "}&&&&&\\" _n
		"N unique control &\multicolumn{1}{r}{" %10.0fc (e(_N)[1,4]) "}&&&&&\\" _n
	"\bottomrule" _n
	"\end{tabular}" _n
	"\begin{tablenotes}" _n
	"\item Table shows the standardized differences in means and variances between the raw and weighted sample. The unit of observation is a census tract with at least 30\% rental share. The treated tracts are matched to a control tract using a nearest neighbor Mahalanobis distance matching procedure. The Mahalanobis distance metric includes linear terms for tract-level, city-level and county-level characteristics." _n
	"\end{tablenotes}"_n
	"\end{threeparttable}"_n
	"}"_n
	"\end{table}"_n;
	#delimit cr

	file close myfile
	
	
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


	file open myfile using "${results}\\att_location_high_rent_mean.tex", write replace
		#delimit;
		file write myfile "\begin{table}[htpb]" _n
		"\centering" _n
		"\begin{threeparttable}" _n
		"\caption{Mahalanobis distance nearest neighbor match estimates of average treatment effect on the treated of rent control on location as child and adult: high rental tract sample}\label{table:att_location_high_rent_mean}" _n
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
	"\item The ATT row reports the average treatment effect on the treated of rent control on the average tract outcome. The unit of observation is a census tract with at least 30\% rental share. The ATT estimates are generated using a nearest neighbor Mahalanobis distance metric matching estimator. The baseline row represents the average outcome of the matched counterfactual tracts."_n
	"\item * = p $<$ 0.1, ** = p $<$ 0.05, *** = p $<$ 0.01."_n
	"\end{tablenotes}"_n
	"\end{threeparttable}"_n
	"\end{table}"_n;
	#delimit cr
	file close myfile	
	
	

	
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
	file open myfile using "${results}\\att_nnmatch_high_rent.tex", write replace
		#delimit;
		file write myfile "\begin{landscape}" _n
		"\begin{table}[htpb]" _n
		"\resizebox{.95\textwidth}{!}{" _n
		"\centering" _n
		"\begin{threeparttable}" _n
		"\caption{Mahalanobis distance nearest neighbor match estimates of average treatment effect on the treated of rent control on long-term outcomes: high rental tract sample}\label{table:att_nnmatch_high_rent}" _n
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
	"\item The ATT row reports the average treatment effect on the treated of rent control on the average tract outcome. Only tracts with more than 30\% rental share are included in the sample. The ATT estimates are generated using a nearest neighbor Mahalanobis distance matching estimator that accounts for tract, city and county-level traits. The baseline row represents the average outcome of the matched counterfactual tracts."_n
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

	file open myfile using "${results}\\att_nnmatch_high_rent_ind_weight.tex", write replace
		#delimit;
		file write myfile "\begin{landscape}" _n
		"\begin{table}[htpb]" _n
		"\resizebox{.95\textwidth}{!}{" _n
		"\centering" _n
		"\begin{threeparttable}" _n
		"\caption{Mahalanobis distance nearest neighbor match estimates of average treatment effect on the treated of rent control on long-term outcomes, weighted by children linked to a tract and limited to the high rental tract sample}\label{table:att_nnmatch_high_rent_ind_weight}" _n
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
	"\item The ATT row reports the average treatment effect on the treated of rent control on the average tract outcome, weighted by the number of children linked to each tract. Only tracts with more than 30\% rental share are included in the sample. The ATT estimates are generated using a nearest neighbor Mahalanobis distance matching estimator that accounts for tract, city and county-level traits. The baseline row represents the average outcome of the matched counterfactual tracts."_n
	"\item * = p $<$ 0.1, ** = p $<$ 0.05, *** = p $<$ 0.01."_n
	"\end{tablenotes}"_n
	"\end{threeparttable}"_n
	"}"_n
	"\end{table}"_n
	"\end{landscape}"_n;
	#delimit cr
	file close myfile	
	
	
	
	/*****************************************************************************************
	
	Predicted outcomes table
	
	
		
	
	*****************************************************************************************/

	
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


	file open myfile using "${results}\\att_nnmatch_high_rent_predict.tex", write replace
		#delimit;
		file write myfile "\begin{landscape}" _n
		"\begin{table}[htpb]" _n
		"\resizebox{.95\textwidth}{!}{" _n	
		"\centering" _n
		"\begin{threeparttable}" _n
		"\caption{Mahalanobis distance nearest neighbor match estimates of average treatment effect on the treated of rent control on long-term predicted outcomes: high rental tract sample }\label{table:att_nnmatch_high_rent_predict}" _n
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
	"\item Estimates are reported for the predicted outcomes of children growing up in tracts at the 25th and 75th percentile of parent income. Only tracts with more than 30\% rental share are included in the sample. The predicted outcomes are generated by regressing individual outcomes on a transformation of parent income rank and recovering the fitted values at these two points of the parent income rank. The ATT is estimated using the baseline Mahalanobis distance matching estimator."_n
	"\item * = p $<$ 0.1, ** = p $<$ 0.05, *** = p $<$ 0.01."_n
	"\end{tablenotes}"_n
	"\end{threeparttable}"_n
	"}"_n
	"\end{table}"_n
	"\end{landscape}"_n;
	#delimit cr
	file close myfile	
	
restore