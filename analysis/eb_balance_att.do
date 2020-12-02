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


**********************************************************************************************************************

*Entropy balance balance table and/or figure
**********************************************************************************************************************
quietly kmatch eb treat ${x} ${muni_control}, targets(1) att
quietly kmatch summarize 
mat balance=r(M)[1..${wc},3],r(M)[1..${wc},6],r(V)[1..${wc},3],r(V)[1..${wc},6]


file open myfile using "${results}\\eb_balance.tex", write replace
	#delimit;
	file write myfile "\begin{table}[htpb]" _n
	"\resizebox{.95\textwidth}{!}{" _n	
	"\centering" _n
	"\begin{threeparttable}" _n
	"\caption{Comparing means and variances of the raw and weighted samples when using entropy balancing to generate weights}\label{table:eb_balance}" _n
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
"\bottomrule" _n
"\end{tabular}" _n
"\begin{tablenotes}" _n
"\item Table shows the standardized differences in means and variances between the raw and weighted sample. The weights are generated through an entropy balancing procedure that targets the first moment condition for all tract and city-level covariates." _n
"\end{tablenotes}"_n
"\end{threeparttable}"_n
"}" _n
"\end{table}"_n;
#delimit cr

file close myfile

*Balance test figure

mat rowname balance= "Population" "Male" "Pop density" "Age median" "White (%)" "Black (%)" "Married" "Single parent fam (%)" "Educ Less than HS" "Educ HS" "LFP rate" "Unemployment rate" "Avg inc" "Below pov rt" "Same addr 5 years" "Housing units" "Rentals (%)" "Avg home value" "Avg rent" "Rental vac (%)" "Effective rent vac" "City rental (% of total units)" "City rental vacancy rate (\%)"  "City white (%)" "City black (%)" "City unemployment rate" "City avg rent" "County Dem vote share 1968" "County Wallace vote share 1968" "City population" "City family poverty rt (%)" "City revenue" "City tax revenue" "City property tax revenue" "City revenue from state" "City expenditure" "City education expenditure" "City police expenditure" "City welfare expenditure" 

mat balance_tract = balance[1..${wc_x},.]
local start = ${wc_x}+1
mat balance_city = balance[`start'..${wc_x}+${wc_mc},.]

*Generating figure of balance tests
coefplot (m(balance_tract[.,1]),m(oh) mc(green) label(raw) ) (m(balance_tract[.,2]), label(weighted) m(th) mc(blue)) ||, xline(.1,lcolor(red) lpattern(dot)) xline(-.1,lcolor(red) lpattern(dot)) xline(.25,lcolor(red) lpattern(dash)) xline(-.25,lcolor(red) lpattern(dash)) xline(0,lcolor(black%20)) scheme(s1mono) name(mean2, replace) title(Std. Mean Difference)

coefplot (m(balance_tract[.,3]),m(oh) mc(green) label(raw) ) (m(balance_tract[.,4]), label(weighted) m(th) mc(blue)) ||, xline(1,lcolor(black%20)) scheme(s1mono) name(var2, replace) title(Var. Ratio)

graph combine mean2 var2, scheme(s1mono)

graph export "${results_gph}\\eb_balance_tract.png", replace

*Generating figure of balance tests
coefplot (m(balance_city[.,1]),m(oh) mc(green) label(raw) ) (m(balance_city[.,2]), label(weighted) m(th) mc(blue)) ||, xline(.1,lcolor(red) lpattern(dot)) xline(-.1,lcolor(red) lpattern(dot)) xline(.25,lcolor(red) lpattern(dash)) xline(-.25,lcolor(red) lpattern(dash)) xline(0,lcolor(black%20)) scheme(s1mono) name(mean2, replace) title(Std. Mean Difference)

coefplot (m(balance_city[.,3]),m(oh) mc(green) label(raw) ) (m(balance_city[.,4]), label(weighted) m(th) mc(blue)) ||, xline(1,lcolor(black%20)) scheme(s1mono) name(var2, replace) title(Var. Ratio)

graph combine mean2 var2, scheme(s1mono)

graph export "${results_gph}\\eb_balance_city.png", replace

file open myfile using "${results_gph}\\eb_balance_tract.tex", write replace

#delimit;
file write myfile "\begin{figure}[htbp]" _n
"\caption{Comparing means and variances of the raw and weighted samples using entropy balancing: tract-level covariates}\label{fig:eb_balance_tract}" _n

"\includegraphics[width=0.9\textwidth]{{${results_gph}/eb_balance_tract.png}}" _n

"\Fignote{\scriptsize The left panel shows the difference in standardized means between the raw and matched samples for each tract-level covariate. The right panel shows the variance ratio of the raw and matched samples. The matched sample is created by using an entropy balancing algorithm that targets the first moment condition for each covariate.}" _n
"\end{figure}" _n;

#delimit cr
file close myfile


file open myfile using "${results_gph}\\eb_balance_city.tex", write replace


#delimit;
file write myfile "\begin{figure}[htbp]" _n
"\caption{Comparing means and variances of the raw and weighted samples using entropy balancing: city-level covariates}\label{fig:nnmatch_balance}" _n

"\includegraphics[width=0.9\textwidth]{{${results_gph}/eb_balance_city.png}}" _n

"\Fignote{\scriptsize The left panel shows the difference in standardized means between the raw and matched samples for each tract-level covariate. The right panel shows the variance ratio of the raw and matched samples. The matched sample is created by using an entropy balancing algorithm that targets the first moment condition for each covariate.}" _n
"\end{figure}" _n;

#delimit cr
file close myfile

********************************************************************************************************************

*Entropy balance results

****************************************************************************************************************
local outvar_econ="kfr_top20_pooled_pooled kir_top20_pooled_pooled kfr_pooled_pooled kir_pooled_pooled"
local outvar_social = "teenbrth_pooled_female jail_pooled_pooled working_pooled_pooled lpov_nbh_pooled_pooled"

foreach var in `outvar_econ' `outvar_social' {	
	*Entropy balance
	quietly kmatch eb treat ${x} ${muni_control} (`var'_p25 `var'_p75 `var'_mean), targets(1) att vce(cluster name_id)
	local N_`var'=e(N)
	local N1_`var'=e(_N)[1,1]
	mat b=e(b)'
	mat v=vecdiag(e(V))
	mat v=v'
	matmap v se,map(sqrt(@))
	
	local j=1
	foreach p in p25 p75 mean{
		local b=e(b)[1,`j']
		*local `var'_`p'_se=sqrt(e(V)[`j',`j'])
		local pval=r(table)[4,`j']
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
		
		local `var'_`p'="`b'`star'"
		local `var'_`p'_se=r(table)[2,`j']
		local j=`j'+1
	}
	
	quietly kmatch eb treat ${x} ${muni_control} (`var'_mean), targets(1) att vce(cluster name_id)
	quietly su `var'_mean if treat==1 & e(sample)==1
	local `var'_bl=r(mean)-e(b)[1,1]
	local `var'_ch=(r(mean)-``var'_bl')/``var'_bl'
	
}

file open myfile using "${results}\\att_eb_mean.tex", write replace
	#delimit;
	file write myfile "\begin{landscape}" _n
	"\begin{table}[htpb]" _n
	"\resizebox{.95\textwidth}{!}{" _n	
	"\centering" _n
	"\begin{threeparttable}" _n
	"\caption{Entropy balance estimates of average treatment effect on the treated of rent control on long-term outcomes}\label{table:att_eb_mean}" _n
	"\begin{tabular}{@{}l*{10}S}" _n
	"\toprule" _n
	"&\multicolumn{1}{r}{Top 20\%}&\multicolumn{1}{r}{Top 20\%}&\multicolumn{1}{r}{Percentile}&\multicolumn{1}{r}{Percentile}&\multicolumn{1}{r}{Teen}&\multicolumn{1}{r}{ }&\multicolumn{1}{r}{ }&\multicolumn{1}{r}{Low Pov.}&& \\" _n	
	"&\multicolumn{1}{r}{Fam.}&\multicolumn{1}{r}{Ind.}&\multicolumn{1}{r}{Fam. Inc.}&\multicolumn{1}{r}{Ind. Inc.}&\multicolumn{1}{r}{birth}&\multicolumn{1}{r}{Jail}&\multicolumn{1}{r}{Employed}&\multicolumn{1}{r}{nbhd.}&& \\" _n
	"\midrule" _n;
	#delimit cr


	
foreach p in mean{
	file write myfile "ATT&`kfr_top20_pooled_pooled_`p''&`kir_top20_pooled_pooled_`p''&`kfr_pooled_pooled_`p''&`kir_pooled_pooled_`p''&`teenbrth_pooled_female_`p''&`jail_pooled_pooled_`p''&`working_pooled_pooled_`p''&`lpov_nbh_pooled_pooled_`p''&&\\" _n
	file write myfile "&(`kfr_top20_pooled_pooled_`p'_se')&(`kir_top20_pooled_pooled_`p'_se')&(`kfr_pooled_pooled_`p'_se')&(`kir_pooled_pooled_`p'_se')&(`teenbrth_pooled_female_`p'_se')&(`jail_pooled_pooled_`p'_se')&(`working_pooled_pooled_`p'_se')&(`lpov_nbh_pooled_pooled_`p'_se')&&\\" _n
	
	file write myfile "Baseline&`kfr_top20_pooled_pooled_bl'&`kir_top20_pooled_pooled_bl'&`kfr_pooled_pooled_bl'&`kir_pooled_pooled_bl'&`teenbrth_pooled_female_bl'&`jail_pooled_pooled_bl'&`working_pooled_pooled_bl'&`lpov_nbh_pooled_pooled_bl'&&\\" _n
	file write myfile "\%$\Delta$&`kfr_top20_pooled_pooled_ch'&`kir_top20_pooled_pooled_ch'&`kfr_pooled_pooled_ch'&`kir_pooled_pooled_ch'&`teenbrth_pooled_female_ch'&`jail_pooled_pooled_ch'&`working_pooled_pooled_ch'&`lpov_nbh_pooled_pooled_ch'&&\\" _n
}

#delimit;
file write myfile "\midrule" _n
"N &`N_kfr_top20_pooled_pooled'&`N_kir_top20_pooled_pooled'&`N_kfr_pooled_pooled'&`N_kir_pooled_pooled'&`N_teenbrth_pooled_female'&`N_jail_pooled_pooled'&`N_working_pooled_pooled'&`N_lpov_nbh_pooled_pooled'&&\\" _n

"N Control&`N1_kfr_top20_pooled_pooled'&`N1_kir_top20_pooled_pooled'&`N1_kfr_pooled_pooled'&`N1_kir_pooled_pooled'&`N1_teenbrth_pooled_female'&`N1_jail_pooled_pooled'&`N1_working_pooled_pooled'&`N1_lpov_nbh_pooled_pooled'&&\\" _n
"\bottomrule" _n
"\end{tabular}" _n
"\begin{tablenotes}" _n
"\item The ATT row reports the average treatment effect on the treated of rent control on the average tract outcome. The ATT estimates are generated using inverse weights generated by entropy weighting as proposed by Hainmueller (2012). The baseline row represents the average counterfactual outcome."_n
"\item * = p $<$ 0.1, ** = p $<$ 0.05, *** = p $<$ 0.01."_n
"\end{tablenotes}"_n
"\end{threeparttable}"_n
"}"_n
"\end{table}"_n
"\end{landscape}" _n;
#delimit cr
file close myfile