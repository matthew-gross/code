*Establishing labels for figures and tables*
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

*Creating a balance table for the baseline matching

quietly kmatch md treat ${x} ${muni_control}, nn(1) cal(4.5) att vce(cluster name_id) idgen(match) replace
quietly kmatch summarize ${x} ${muni_control}

mat balance=r(M)[1..${wc},3],r(M)[1..${wc},6],r(V)[1..${wc},3],r(V)[1..${wc},6]

file open myfile using "${results}\\nnmatch_balance.tex", write replace
	#delimit;
	file write myfile "\begin{table}[htpb]" _n
	"\resizebox{.95\textwidth}{!}{" _n
	"\centering" _n
	"\begin{threeparttable}" _n
	"\caption{Comparing means and variances of the raw and weighted samples using the two-step nearest neighbor matching algorithm}\label{table:nnmatch_balance}" _n
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
"\item Table shows the standardized differences in means and variances between the raw and weighted sample. The unit of observation is a census tract. The treated tracts are matched to a control tract using a nearest neighbor Mahalanobis distance matching procedure. The Mahalanobis distance metric includes linear terms for tract-level, city-level and county-level characteristics." _n
"\end{tablenotes}"_n
"\end{threeparttable}"_n
"}"_n
"\end{table}"_n;
#delimit cr

file close myfile


*Balance test figure

mat rowname balance= "Population" "Male" "Pop density" "Age median" "White (%)" "Black (%)" "Married" "Single parent fam (%)" "Educ Less than HS" "Educ HS" "LFP rate" "Unemployment rate" "Avg inc" "Below pov rt" "Same addr 5 years" "Housing units" "Rentals (%)" "Avg home value" "Avg rent" "Rental vac (%)" "Effective rent vac" "City rental (% of total units)" "City rental vacancy rate (%)"  "City white (%)" "City black (%)" "City unemployment rate" "City avg rent" "County Dem vote share 1968" "County Wallace vote share 1968" "City population" "City family poverty rt (%)" "City revenue" "City tax revenue" "Property tax share of rev" "Rev from state share" "Educ share of expenditure" "Police share of expenditure" "Welfare share of expenditure" 

mat balance_tract = balance[1..${wc_x},.]
local start = ${wc_x}+1
mat balance_city = balance[`start'..${wc},.]

*Generating figure of balance tests
coefplot (m(balance_tract[.,1]),m(oh) mc(green) label(raw) ) (m(balance_tract[.,2]), label(weighted) m(th) mc(blue)) ||, xline(.1,lcolor(red) lpattern(dot)) xline(-.1,lcolor(red) lpattern(dot)) xline(.25,lcolor(red) lpattern(dash)) xline(-.25,lcolor(red) lpattern(dash)) xline(0,lcolor(black%20)) scheme(s1mono) name(mean2, replace) title(Std. Mean Difference)

coefplot (m(balance_tract[.,3]),m(oh) mc(green) label(raw) ) (m(balance_tract[.,4]), label(weighted) m(th) mc(blue)) ||, xline(1,lcolor(black%20)) scheme(s1mono) name(var2, replace) title(Var. Ratio)

graph combine mean2 var2, scheme(s1mono)

graph export "${results_gph}\\nnmatch_balance_tract.png", replace

*Generating figure of balance tests
coefplot (m(balance_city[.,1]),m(oh) mc(green) label(raw) ) (m(balance_city[.,2]), label(weighted) m(th) mc(blue)) ||, xline(.1,lcolor(red) lpattern(dot)) xline(-.1,lcolor(red) lpattern(dot)) xline(.25,lcolor(red) lpattern(dash)) xline(-.25,lcolor(red) lpattern(dash)) xline(0,lcolor(black%20)) scheme(s1mono) name(mean2, replace) title(Std. Mean Difference)

coefplot (m(balance_city[.,3]),m(oh) mc(green) label(raw) ) (m(balance_city[.,4]), label(weighted) m(th) mc(blue)) ||, xline(1,lcolor(black%20)) scheme(s1mono) name(var2, replace) title(Var. Ratio)

graph combine mean2 var2, scheme(s1mono)

graph export "${results_gph}\\nnmatch_balance_tract.png", replace

file open myfile using "${results_gph}\\nnmatch_balance_tract.tex", write replace

#delimit;
file write myfile "\begin{figure}[htbp]" _n
"\caption{Comparing means and variances of the raw and weighted samples using a nearest neighbor matching algorithm: tract-level covariates}\label{fig:nnmatch_balance}" _n

"\includegraphics[width=0.9\textwidth]{{${results_gph}/nnmatch_balance_tract.png}}" _n

"\Fignote{\scriptsize The left panel shows the difference in standardized means between the raw and matched samples for each tract-level covariate. The right panel shows the variance ratio of the raw and matched samples. The matched sample is created by using a nearest neighbor Mahalanobis distance matching procedure. The Mahalanobis distance metric used to match includes linear terms for tract-level, city-level and county-level characteristics.}" _n
"\end{figure}" _n;

#delimit cr
file close myfile

file open myfile using "${results_gph}\\nnmatch_balance_city.tex", write replace


#delimit;
file write myfile "\begin{figure}[htbp]" _n
"\caption{Comparing means and variances of the raw and weighted samples using a nearest neighbor matching algorithm: city-level covariates}\label{fig:nnmatch_balance}" _n

"\includegraphics[width=0.9\textwidth]{{${results_gph}/nnmatch_balance_city.png}}" _n

"\Fignote{\scriptsize The left panel shows the difference in standardized means between the raw and matched samples for each city and county-level covariate. All municipal tax and expenditures are measured in per capita terms. The right panel shows the variance ratio of the raw and matched samples. The matched sample is created by using a nearest neighbor Mahalanobis distance matching procedure. The Mahalanobis distance metric used to match includes linear terms for tract-level, city-level and county-level characteristics.}" _n
"\end{figure}" _n;

#delimit cr
file close myfile
