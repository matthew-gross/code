*Tables and Figure generation file

clear all
set maxvar 10000
cd "C:\Users\\`c(username)'\\Box Sync\Rent Control\Data\Analysis_data"


*Setting local and global macros

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


global results = "C:\Users\\`c(username)'\\Box Sync\Rent Control\Results\tbl\\`date_string'"

local results_gph="C:\Users\\`c(username)'\\Box Sync\Rent Control\Results\gph\\`date_string'"
global results_gph="C:\Users\\`c(username)'\\Box Sync\Rent Control\Results\gph\\`date_string'"
local results_gph=subinstr("`results_gph'","\","/",.)
global results_gph=subinstr("`results_gph'","\","/",.)


global x = "pop_tract male pop_density age_median white black married sing_par educ_no_hs educ_hs lfp unemployment avg_ind_inc fam_below_pov duration_5 units_total renter_occ_per rent_vac_rate effect_rent_vac avg_gross_rent avg_unit_value"


global muni_control = "city_renter_occ_per city_rent_vac_rate city_white city_black city_unemployment city_avg_gross_rent pres_1968_dem pres_1968_wallace population city_fam_below_pov gov_revenue_pc tax_total_revenue_pc tax_property_revenue_share gov_state_igr_share gov_educ_expend_share police_expend_share public_welf_expend_share"

 
global control = "${x} ${muni_control}" 

global wc = wordcount("${control}")

global wc_x = wordcount("${x}")
global wc_mc = wordcount("${muni_control}")

local outvar_econ="kfr_top20_pooled_pooled kir_top20_pooled_pooled kfr_pooled_pooled kir_pooled_pooled"
local outvar_social = "teenbrth_pooled_female jail_pooled_pooled working_pooled_pooled lpov_nbh_pooled_pooled"
local outcome=""
foreach var in `outvar_econ' `outvar_social' {
	local outcome = "`outcome' `var'_mean"
}
global outcome "`outcome'"

use "C:\Users\\`c(username)'\\Box Sync\Rent Control\Data\Analysis_data\analysis_final.dta", replace

/* Dropping if in Washington DC or Maryland*/
drop if inlist(state,11,24)
drop if missing(population)


timer clear 1
timer on 1

*Tables
/***************************************************************************

Tables 1 and 2

*****************************************************************************/
*1. Compare treated and control tracts and cities by main covariates (perhaps a two page table)

do "C:\Users\\`c(username)'\\Box Sync\Rent Control\Programs\analysis\ttest_compare.do"


*2. Balance table after matching (split into municipal and tract level traits?)

do "C:\Users\\`c(username)'\\Box Sync\Rent Control\Programs\analysis\nnmatch_balance.do"

/*************************************************************************************************************

*3. ATT of rent control on location decisions (weighted and unweighted)

*************************************************************************************************************/
do "C:\Users\\`c(username)'\\Box Sync\Rent Control\Programs\analysis\nnmatch_location_att.do"

*4. ATT of long term outcomes (maybe split into two tables, 1 economic and 2 social, weighted and unweighted

do "C:\Users\\`c(username)'\\Box Sync\Rent Control\Programs\analysis\nnmatch_outcomes_att.do"	

******************************************************************************************************************************

*5. Table of p25 and p75 outcomes

***************************************************************************************************************

do "C:\Users\\`c(username)'\\Box Sync\Rent Control\Programs\analysis\nnmatch_predict_att.do"

******************************************************************************************************************************

*6. Limiting sample to tracts with high proprtion of renters

***************************************************************************************************************
do "C:\Users\\`c(username)'\\Box Sync\Rent Control\Programs\analysis\nnmatch_high_renter_outcomes_att.do"

tempfile return
save `return'
*7:. Figure of ATT on immigration over time to test assumption, ATT figures of mechanism/long term effects

do "C:\Users\\`c(username)'\\Box Sync\Rent Control\Programs\analysis\att_census_figures.do"

**********************************************************************************************************************
*Appendix

**********************************************************************************************************************

use `return', replace

*do "C:\Users\\`c(username)'\\Box Sync\Rent Control\Programs\analysis\eb_balance_att.do"
timer off 1
quietly timer list 1
local total_time = r(t1)/60
display "Total minutes:			`total_time'"

