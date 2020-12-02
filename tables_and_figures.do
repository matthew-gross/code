*Tables and Figure generation file

local date=date(c(current_date), "DMY")
local date_string=string(year(`date'))+string(month(`date'), "%02.0f")+string(day(`date'), "%02.0f")
confirmdir "C:\Users\\`c(username)'\\Box Sync\Rent Control\Results\tbl\\`date_string'"
if _rc!=0{
	mkdir "C:\Users\\`c(username)'\\Box Sync\Rent Control\Results\tbl\\`date_string'"
}

confirmdir "C:\Users\\`c(username)'\\Box Sync\Rent Control\Results\gph\\`date_string'"
if _rc!=0{
	mkdir "C:\Users\\`c(username)'\\Box Sync\Rent Control\Results\gph\\`date_string'"
}

clear all
set maxvar 10000
cd "C:\Users\\`c(username)'\\Box Sync\Rent Control\Data\Analysis_data"


local results = "C:\Users\\`c(username)'\\Box Sync\Rent Control\Results\tbl\\`date_string'"
global results = "C:\Users\\`c(username)'\\Box Sync\Rent Control\Results\tbl\\`date_string'"

local results_gph="C:\Users\\`c(username)'\\Box Sync\Rent Control\Results\gph\\`date_string'"
global results_gph="C:\Users\\`c(username)'\\Box Sync\Rent Control\Results\gph\\`date_string'"
local results_gph=subinstr("`results_gph'","\","/",.)
global results_gph=subinstr("`results_gph'","\","/",.)

local x = "pop_tract male pop_density age_median white black married sing_par educ_no_hs educ_hs lfp unemployment avg_ind_inc fam_below_pov duration_5 units_total renter_occ_per rent_vac_rate effect_rent_vac avg_gross_rent avg_unit_value"

global x = "pop_tract male pop_density age_median white black married sing_par educ_no_hs educ_hs lfp unemployment avg_ind_inc fam_below_pov duration_5 units_total renter_occ_per rent_vac_rate effect_rent_vac avg_gross_rent avg_unit_value"


local ps_x="`x' pop_density_sq male_sq lfp_sq unemployment_sq fam_below_pov_sq avg_gross_rent_sq rent_vac_rate_sq avg_unit_value_sq white_sq unemp_educ_coll"

*local muni_control = "city_renter_occ_per city_rent_vac_rate city_white city_black city_unemployment city_avg_gross_rent pres_1968_dem pres_1968_wallace population city_fam_below_pov gov_revenue_pc tax_total_revenue_pc tax_property_revenue_share gov_state_igr_share gov_expenditure_total_pc gov_educ_expenditure_pc police_expenditure_pc public_welf_expenditure_pc"

global muni_control = "city_renter_occ_per city_rent_vac_rate city_white city_black city_unemployment city_avg_gross_rent pres_1968_dem pres_1968_wallace population city_fam_below_pov gov_revenue_pc tax_total_revenue_pc tax_property_revenue_share gov_state_igr_share gov_educ_expend_share police_expend_share public_welf_expend_share"


*global muni_control = "city_renter_occ_per city_rent_vac_rate city_white city_black city_unemployment city_avg_gross_rent pres_1968_dem pres_1968_wallace population city_fam_below_pov gov_revenue_pc tax_total_revenue_pc tax_property_revenue_pc gov_state_igr_pc gov_expenditure_total_pc gov_educ_expenditure_pc police_expenditure_pc public_welf_expenditure_pc"
 
global control = "${x} ${muni_control}" 

local wc=wordcount("`x' `muni_control'")

global wc = wordcount("${control}")

local wc_x = wordcount("${x}")
global wc_x = wordcount("${x}")
local wc_mc = wordcount("${muni_control}")
global wc_mc = wordcount("${muni_control}")

local outvar_econ="kfr_top20_pooled_pooled kir_top20_pooled_pooled kfr_pooled_pooled kir_pooled_pooled"
local outvar_social = "teenbrth_pooled_female jail_pooled_pooled working_pooled_pooled lpov_nbh_pooled_pooled"
local outcome=""
foreach var in `outvar_econ' `outvar_social' {
	local outcome = "`outcome' `var'_mean"
}
global outcome "`outcome'"

use "C:\Users\Mateo\Box Sync\Rent Control\Data\Analysis_data\analysis_final.dta", replace


drop if inlist(state,11,24)
drop if missing(population)

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

timer clear 1
timer on 1

*Tables
/***************************************************************************

Tables 1 and 2

*****************************************************************************/
*1. Compare treated and control tracts and cities by main covariates (perhaps a two page table)

do "C:\Users\Mateo\Box Sync\Rent Control\Programs\analysis\ttest_compare.do"


*2. Balance table after matching (split into municipal and tract level traits?)

do "C:\Users\Mateo\Box Sync\Rent Control\Programs\analysis\nnmatch_balance.do"

/*************************************************************************************************************

*3. ATT of rent control on location decisions (weighted and unweighted)

*************************************************************************************************************/
do "C:\Users\Mateo\Box Sync\Rent Control\Programs\analysis\nnmatch_location_att.do"

*4. ATT of long term outcomes (maybe split into two tables, 1 economic and 2 social, weighted and unweighted

do "C:\Users\Mateo\Box Sync\Rent Control\Programs\analysis\nnmatch_outcomes_att.do"	

******************************************************************************************************************************

*5. Table of p25 and p75 outcomes

***************************************************************************************************************

do "C:\Users\Mateo\Box Sync\Rent Control\Programs\analysis\nnmatch_predict_att.do"

******************************************************************************************************************************

*6. Limiting sample to tracts with high proprtion of renters

***************************************************************************************************************
do "C:\Users\Mateo\Box Sync\Rent Control\Programs\analysis\nnmatch_high_renter_outcomes_att.do"

tempfile return
save `return'
*7:. Figure of ATT on immigration over time to test assumption, ATT figures of mechanism/long term effects

do "C:\Users\Mateo\Box Sync\Rent Control\Programs\analysis\att_census_figures.do"

**********************************************************************************************************************
*Appendix

**********************************************************************************************************************

use `return', replace

*do "C:\Users\Mateo\Box Sync\Rent Control\Programs\analysis\eb_balance_att.do"
timer off 1
quietly timer list 1
local total_time = r(t1)/60
display "Total minutes:			`total_time'"

