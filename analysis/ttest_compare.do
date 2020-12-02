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


capture drop sample
quietly reg kfr_top20_pooled_pooled_mean ${x} ${muni_control}
gen sample=e(sample)
quietly sum treat if sample==1 & state==6
local ca_treat=r(sum)
local ca_control=r(N)-r(sum)

quietly sum treat if sample==1 & state==25
local ma_treat=r(sum)
local ma_control=r(N)-r(sum)

quietly sum treat if sample==1 & state==34
local nj_treat=r(sum)
local nj_control=r(N)-r(sum)

quietly sum treat if sample==1 
local treat=r(sum)
local control=r(N)-r(sum)


count if inlist(state,6,25,34,11,24)==0 & sample==1
local other_control=r(N)


file open myfile using "${results}\\table_1_tract.tex", write replace
#delimit;
file write myfile "\begin{table}[htpb]" _n
"\resizebox{.95\textwidth}{!}{" _n
"\centering" _n
"\begin{threeparttable}" _n
"\caption{T-test of means to compare characteristics of treated and controlled census tracts}\label{table:meanttest_tract}" _n
"\begin{tabular}{@{}l*{8}S}" _n
"\toprule" _n
"&\multicolumn{2}{c}{Average}&&&\\" _n
"&\multicolumn{1}{c}{Control}&\multicolumn{1}{c}{Treat}&\multicolumn{1}{c}{Difference} &\multicolumn{1}{c}{CA Diff.}&\multicolumn{1}{c}{MA Diff.}&\multicolumn{1}{c}{NJ Diff.}&&\\" _n
"\midrule" _n;
#delimit cr
foreach var of global x {
    local name=subinstr("`var'","_","\_",.)
    quietly ttest `var' if sample==1, by(treat) unequal
	local mean_1=r(mu_1)
	local mean_2=r(mu_2)
	
	local dif=`mean_2'-`mean_1'
	if inrange(r(p),0,.01) {
	    local p="***"
	}
	else if inrange(r(p),.01,.05) {
		local p="**"
	}
	else if inrange(r(p),.05,.1){
		local p="*"
	}
	else {
	    local p=""
	}
	local dif_p="`dif'`p'"
	foreach state in 6 25 34 {
	    quietly ttest `var' if sample==1 & state ==`state', by(treat) unequal
		
		local dif_`state'=r(mu_2)-r(mu_1)
		if inrange(r(p),0,.01) {
			local p_`state'="***"
		}
		else if inrange(r(p),.01,.05) {
			local p_`state'="**"
		}
		else if inrange(r(p),.05,.1){
			local p_`state'="*"
		}
		else {
			local p_`state'=""
		}
		
		local dif_p_`state' = "`dif_`state''`p_`state''" 
		
	}
	
	
	file write myfile "``var'_lab'&" %10.3fc (`mean_1') "&" %10.3fc (`mean_2') "&`dif_p' &`dif_p_6'&`dif_p_25'&`dif_p_34'&&\\" _n
}
#delimit;
file write myfile "\midrule" _n
"N&\multicolumn{1}{r}{" %10.0fc (`control') "}&\multicolumn{1}{r}{" %10.0fc (`treat') "}&&&&&&\\" _n
"N by State:&&&&&\\" _n
"California&\multicolumn{1}{r}{" %10.0fc (`ca_control') "}&\multicolumn{1}{r}{" %10.0fc (`ca_treat') "}&&&&&&\\" _n
"Massachusetts&\multicolumn{1}{r}{" %10.0fc (`ma_control') "}&\multicolumn{1}{r}{" %10.0fc (`ma_treat') "}&&&&&&\\" _n
"New Jersey&\multicolumn{1}{r}{" %10.0fc (`nj_control') "}&\multicolumn{1}{r}{" %10.0fc (`nj_treat') "}&&&&&&\\" _n
"Other States&\multicolumn{1}{r}{" %10.0fc (`other_control') "}&\multicolumn{1}{r}{}&&&&&&\\" _n
"\bottomrule" _n
"\end{tabular}" _n
"\begin{tablenotes}" _n
"\item Sample includes tracts in all states except Washington DC, Maryland and New York. These excluded states had cities with rent control and cannot be used as possible control tracts."_n
"\item * = p < 0.1, ** = p < 0.05, *** = p < 0.01."_n
"\end{tablenotes}"_n
"\end{threeparttable}"_n
"}"_n
"\end{table}"_n;
#delimit cr

file close myfile


preserve
	collapse (max) treat ${muni_control}, by(name state)
	quietly sum treat if state==6
	local ca_treat=r(sum)
	local ca_control=r(N)-r(sum)

	quietly sum treat if state==25
	local ma_treat=r(sum)
	local ma_control=r(N)-r(sum)

	quietly sum treat if state==34
	local nj_treat=r(sum)
	local nj_control=r(N)-r(sum)

	count if inlist(state,6,25,34,11,24)==0 
	local other_control=r(N)
	
	quietly sum treat 
	local treat=r(sum)
	local control=r(N)-r(sum)


	file open myfile using "${results}\\table_1_city.tex", write replace
	#delimit;
	file write myfile "\begin{table}[htpb]" _n
	"\resizebox{.95\textwidth}{!}{" _n
	"\centering" _n
	"\begin{threeparttable}" _n
	"\caption{T-test of means to compare characteristics of treated and controlled cities}\label{table:meanttest_city}" _n
	"\begin{tabular}{@{}l*{8}S}" _n
	"\toprule" _n
	"&\multicolumn{2}{c}{Average}&&&\\" _n
	"&\multicolumn{1}{c}{Control}&\multicolumn{1}{c}{Treat}&\multicolumn{1}{c}{Difference} &\multicolumn{1}{c}{CA Diff.}&\multicolumn{1}{c}{MA Diff.}&\multicolumn{1}{c}{NJ Diff.}&&\\" _n
	"\midrule" _n;
	#delimit cr
	foreach var of global muni_control {
		local name=subinstr("`var'","_","\_",.)
		quietly ttest `var', by(treat) unequal
		local mean_1=r(mu_1)
		local mean_2=r(mu_2)
		
		local dif=`mean_2'-`mean_1'
		if inrange(r(p),0,.01) {
			local p="***"
		}
		else if inrange(r(p),.01,.05) {
			local p="**"
		}
		else if inrange(r(p),.05,.1){
			local p="*"
		}
		else {
			local p=""
		}
		local dif_p="`dif'`p'"
		
		foreach state in 6 25 34 {
	    quietly ttest `var' if state ==`state', by(treat) unequal
				
		local dif_`state'=r(mu_2)-r(mu_1)
		if inrange(r(p),0,.01) {
			local p_`state'="***"
		}
		else if inrange(r(p),.01,.05) {
			local p_`state'="**"
		}
		else if inrange(r(p),.05,.1){
			local p_`state'="*"
		}
		else {
			local p_`state'=""
		}
		
		local dif_p_`state' = "`dif_`state''`p_`state''" 
		
	}
		
		local dif_p="`dif'`p'"
		file write myfile "``var'_lab'&" %10.3fc (`mean_1') "&" %10.3fc (`mean_2') "&`dif_p' &`dif_p_6'&`dif_p_25'&`dif_p_34'&&\\" _n
	}
	#delimit;
	file write myfile "\midrule" _n
	"N&\multicolumn{1}{r}{" %10.0fc (`control') "}&\multicolumn{1}{r}{" %10.0fc (`treat') "}&&&&&&\\" _n
	"N by State:&&&&&\\" _n
	"California&\multicolumn{1}{r}{" %10.0fc (`ca_control') "}&\multicolumn{1}{r}{" %10.0fc (`ca_treat') "}&&&&&&\\" _n
	"Massachusetts&\multicolumn{1}{r}{" %10.0fc (`ma_control') "}&\multicolumn{1}{r}{" %10.0fc (`ma_treat') "}&&&&&&\\" _n
	"New Jersey&\multicolumn{1}{r}{" %10.0fc (`nj_control') "}&\multicolumn{1}{r}{" %10.0fc (`nj_treat') "}&&&&&&\\" _n
	"Other States&\multicolumn{1}{r}{" %10.0fc (`other_control') "}&\multicolumn{1}{r}{}&&&&&&\\" _n
	"\bottomrule" _n
	"\end{tabular}" _n
	"\begin{tablenotes}" _n
	"\item Sample includes cities from all states except Washington DC, Maryland and New York. These excluded states had cities with rent control and cannot be used as possible control cities."_n
	"\item * = p < 0.1, ** = p < 0.05, *** = p < 0.01."_n
	"\end{tablenotes}"_n
	"\end{threeparttable}"_n
	"}"_n
	"\end{table}"_n;
	#delimit cr

	file close myfile
restore
/*
********************************************************************************


Table to calculate naive average treatment effect
********************************************************************************
*/

local kfr_top20_pooled_pooled_mean_lb =  "Top 20\% fam. inc."
local kir_top20_pooled_pooled_mean_lb = "Top 20\% ind. inc."
local kfr_pooled_pooled_mean_lb = "Percentile fam. inc."
local kir_pooled_pooled_mean_lb = "Percentile ind. inc."
local teenbrth_pooled_female_mean_lb = "Teen birth"
local jail_pooled_pooled_mean_lb = "Jail"
local working_pooled_pooled_mean_lb = "Employed"
local lpov_nbh_pooled_pooled_mean_lb = "Low pov. nbhd."


local frac_years_xw_pooled_pooled_lb = "Fract. years in tract"
local stayhome_pooled_pooled_mean_lb = "Live with parents"
local staytract_pooled_pooled_lb = "Stay tract"
local staycz_pooled_pooled_mean_lb = "Stay comm. zone"

file open myfile using "${results}\\table_3_outcomes.tex", write replace
#delimit;
file write myfile "\begin{table}[htpb]" _n
"\resizebox{.95\textwidth}{!}{" _n
"\centering" _n
"\begin{threeparttable}" _n
"\caption{T-test of means to compare outcomes of treated and controlled census tracts}\label{table:meanttest_outcomes}" _n
"\begin{tabular}{@{}l*{8}S}" _n
"\toprule" _n
"&\multicolumn{2}{c}{Average}&&&&&&\\" _n
"&\multicolumn{1}{c}{Control}&\multicolumn{1}{c}{Treat}&\multicolumn{1}{c}{Difference} &\multicolumn{1}{c}{CA Diff.}&\multicolumn{1}{c}{MA Diff.}&\multicolumn{1}{c}{NJ Diff.}&&\\" _n
"\midrule" _n;
#delimit cr



local outcome = "frac_years_xw_pooled_pooled stayhome_pooled_pooled_mean staytract_pooled_pooled_mean staycz_pooled_pooled_mean"
foreach var of global outcome {
    local outcome = "`outcome' `var'"
}



foreach var of local outcome {	
    local name=subinstr("`var'","_","\_",.)
    quietly ttest `var' if sample==1, by(treat) unequal
	local mean_1=r(mu_1)
	local mean_2=r(mu_2)
	
	local dif=`mean_2'-`mean_1'
	if inrange(r(p),0,.01) {
	    local p="***"
	}
	else if inrange(r(p),.01,.05) {
		local p="**"
	}
	else if inrange(r(p),.05,.1){
		local p="*"
	}
	else {
	    local p=""
	}
	local dif_p="`dif'`p'"
	
	foreach state in 6 25 34 {
	    quietly ttest `var' if state ==`state', by(treat) unequal
				
		local dif_`state'=r(mu_2)-r(mu_1)
		if inrange(r(p),0,.01) {
			local p_`state'="***"
		}
		else if inrange(r(p),.01,.05) {
			local p_`state'="**"
		}
		else if inrange(r(p),.05,.1){
			local p_`state'="*"
		}
		else {
			local p_`state'=""
		}
		
		local dif_p_`state' = "`dif_`state''`p_`state''" 
		
	}
	
	
	if "`var'"=="staytract_pooled_pooled_mean" {
	    file write myfile "`staytract_pooled_pooled_lb'&" %10.3fc (`mean_1') "&" %10.3fc (`mean_2') "&`dif_p' &`dif_p_6'&`dif_p_25'&`dif_p_34'&&\\" _n
	}
	
	else{
		file write myfile "``var'_lb'&" %10.3fc (`mean_1') "&" %10.3fc (`mean_2') "&`dif_p' &`dif_p_6'&`dif_p_25'&`dif_p_34'&&\\" _n
	}
	
}	
	
#delimit;

file write myfile "\bottomrule" _n
"\end{tabular}" _n
"\begin{tablenotes}" _n
"\item Sample includes tracts in all states except Washington DC, Maryland and New York. These excluded states had cities with rent control and cannot be used as possible control tracts."_n
"\item * = p < 0.1, ** = p < 0.05, *** = p < 0.01."_n
"\end{tablenotes}"_n
"\end{threeparttable}"_n
"}"_n
"\end{table}"_n;
#delimit cr

file close myfile


drop sample