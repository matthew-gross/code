
local SE="C:\Users\\`c(username)'\\Box Sync\Rent Control\Data\SocialExplorer"

local x = "pop_tract male pop_density age_median white black married sing_par educ_no_hs educ_hs lfp unemployment avg_ind_inc fam_below_pov duration_5 units_total renter_occ_per rent_vac_rate effect_rent_vac avg_gross_rent avg_unit_value"

local ps_x="`x' pop_density_sq male_sq lfp_sq unemployment_sq fam_below_pov_sq avg_gross_rent_sq rent_vac_rate_sq avg_unit_value_sq white_sq unemp_educ_coll"

local muni_control = "city_renter_occ_per city_rent_vac_rate city_white city_black city_unemployment city_avg_gross_rent pres_1968_dem pres_1968_wallace population city_fam_below_pov gov_revenue_pc tax_total_revenue_pc tax_property_revenue_pc gov_state_igr_pc gov_expenditure_total_pc gov_educ_expenditure_pc police_expenditure_pc public_welf_expenditure_pc"

local wc=wordcount("`x' `muni_control'")

local wc_x = wordcount("`x'")
local wc_mc = wordcount("`muni_control'")

keep treat state tract10 name_id ${control}
preserve
	clear
	foreach year in 1970 1980 1990 2000 {
		
		use "`SE'/SE_`year'.dta", replace
		capture drop T*
		capture drop PT*
		capture drop NV*
		capture drop RC*
		
		if "`year'"!="1970" {
		    
			rename (*) (*_`year')
			rename tract10_`year' tract10
		}
		tempfile file`year'
		save `file`year''
		
	}
restore

merge 1:1 tract10 using `file1970', keep(master match) nogen

foreach year in 1980 1990 2000 {
    merge 1:1 tract10 using `file`year'', keep(master match) nogen
}

local black_lab="% black"
local educ_coll_lab="% college"
local unemployment_lab="Unemployment rate"
local duration_5_lab="% in residence for 5+ years"
local units_total_lab="Total units"
local owner_occ_per_lab="% owner occ."
local renter_occ_per_lab="% renter occ."
local comm_60_plus_lab="Commute 1 hour+"
local rent_vac_rate_lab="Rental vacancy"
local pov_below_lab="Poverty rate"
local sing_par_lab="% Single parent family"
local county_migrant_5_lab "\% county migrant"
local state_migrant_5_lab "\% state migrant"
local country_migrant_5_lab "\% country migrant"

foreach var in black educ_coll unemployment duration_5 units_total owner_occ_per renter_occ_per comm_60_plus rent_vac_rate pov_below sing_par county_migrant_5 state_migrant_5 country_migrant_5 {
    display "Variable is: 		`var'"
    matrix `var'=J(3,3,.)
	matrix colname `var'=1980 1990 2000
	return clear

	local i=1
*	foreach year in 1980 1990 2000 {
*	    display "Year is:		`year'"
	    
	quietly kmatch md treat ${x} ${muni_control} (`var'_1980 `var'_1990 `var'_2000 = ${x} ${muni_control}), nn(1) cal(4.5) att vce(cluster name_id) idgen(match) replace
	
	mat `var'[1,1]=r(table)[1,1]
	mat `var'[2,1]=r(table)[5,1]
	mat `var'[3,1]=r(table)[6,1]		
	
	mat `var'[1,2]=r(table)[1,2]
	mat `var'[2,2]=r(table)[5,2]
	mat `var'[3,2]=r(table)[6,2]		

	mat `var'[1,3]=r(table)[1,3]
	mat `var'[2,3]=r(table)[5,3]
	mat `var'[3,3]=r(table)[6,3]		
		
*	}
	
}

foreach var in black educ_coll unemployment duration_5 units_total owner_occ_per renter_occ_per comm_60_plus rent_vac_rate pov_below sing_par county_migrant_5 state_migrant_5 country_migrant_5 {
    
	
	coefplot (m(`var'), ci((2 3)) label("Average") m(oh) mc(black)) || , yline(0, lp(dash) lc(red)) scheme(s1mono) vertical yscale(range(0)) ylabel(., add)

	graph export "${results_gph}\\`var'_att.png", replace
}

*Immigration Figure

file open myfile using "${results_gph}\\inmigration_att.tex", write replace
# delimit;
file write myfile "\begin{figure}[htpb]" _n
"\setlength\tabcolsep{1.5pt}" _n
"\begin{center}" _n
"\caption{Estimated ATT of rent control on immigration outcomes by year} \label{fig:inmigration_att}" _n
"\vspace*{6pt}" _n
"Migrate county \hfil  \hfil  Migrate state\\ \vspace*{3pt}" _n
"\includegraphics[width=.475\linewidth]{{${results_gph}/county_migrant_5_att.png}}" _n
"\includegraphics[width=.475\linewidth]{{${results_gph}/state_migrant_5_att.png}}\\  \vspace*{6pt}" _n
"Country migrant \\ \vspace*{3pt}" _n
"\includegraphics[width=.475\linewidth]{{${results_gph}/country_migrant_5_att.png}} \\ \vspace*{6pt}" _n
"\FigText{\scriptsize Notes: Figures show the average treatment effect on the treated tracts of rent control on immigration outcomes. Each outcome is the percentage of tract inhabitants that have moved from a given location in the last 5 years. The error bars represent 95\% confidence intervals from standard errors that are clustered at the city level.}" _n
"\end{center}" _n
"\end{figure}" _n;
#delimit cr
file close myfile


*Housing Figure
file open myfile using "${results_gph}\\housing_att.tex", write replace
# delimit;
file write myfile "\begin{figure}[htpb]" _n
"\setlength\tabcolsep{1.5pt}" _n
"\begin{center}" _n
"\caption{Estimated ATT of rent control on housing outcomes by year} \label{fig:housing_att}" _n
"\vspace*{6pt}" _n
"P(Living in same house) \hfil  \hfil  Rental Vacancy Rt.\\ \vspace*{3pt}" _n
"\includegraphics[width=.475\linewidth]{{${results_gph}/duration_5_att.png}}" _n
"\includegraphics[width=.475\linewidth]{{${results_gph}/rent_vac_rate_att.png}}\\  \vspace*{6pt}" _n
 "Long Commute \hfil  \hfil  \% Rentals\\  \vspace*{3pt}" _n
"\includegraphics[width=.475\linewidth]{{${results_gph}/comm_60_plus_att.png}}" _n
"\includegraphics[width=.475\linewidth]{{${results_gph}/renter_occ_per_att.png}}\\  \vspace*{6pt}" _n
"Total Units \\ \vspace*{3pt}" _n
"\includegraphics[width=.475\linewidth]{{${results_gph}/units_total_att.png}} \\ \vspace*{6pt}" _n
"\FigText{\scriptsize Notes: Figures show the average treatment effect on the treated tracts of rent control on housing outcomes. The average outcomes are generated using the baseline nearest neighbor match model. The error bars represent 95\% confidence intervals from standard errors that are clustered at the city level.}" _n
"\end{center}" _n
"\end{figure}" _n;
#delimit cr
file close myfile


*Demographic figure
file open myfile using "${results_gph}\\demographic_att.tex", write replace
# delimit;
file write myfile "\begin{figure}[!h]" _n
"\setlength\tabcolsep{1.5pt}" _n
"\begin{center}" _n
"\caption{Estimated ATT of rent control on demographic outcomes} \label{fig:demographic_att}" _n
"\vspace*{6pt}" _n
"Single Parent Rt. \hfil  \hfil  College\\ \vspace*{3pt}" _n
"\includegraphics[width=.475\linewidth]{{${results_gph}/sing_par_att.png}}" _n
"\includegraphics[width=.475\linewidth]{{${results_gph}/educ_coll_att.png}}\\  \vspace*{6pt}" _n
 "Poverty Rt. \hfil  \hfil  Unemployment Rt.\\  \vspace*{3pt}" _n
"\includegraphics[width=.475\linewidth]{{${results_gph}/pov_below_att.png}}" _n
"\includegraphics[width=.475\linewidth]{{${results_gph}/unemployment_att.png}}\\  \vspace*{3pt}" _n
"\FigText{\scriptsize Notes: Figures show the average treatment effect on the treated tracts of rent control on employment and demograhic outcomes. The average outcomes are generated using the baseline nearest neighbor match model. The error bars represent 95\% confidence intervals from standard errors that are clustered at the city level.}" _n
"\end{center}" _n
"\end{figure}" _n;
#delimit cr
file close myfile



/********************************************************************************

High rent sample

*********************************************************************************/
quietly su renter_occ_per if treat==1, d
local median = r(p25)
keep if renter_occ_per>=`median'

foreach var in black educ_coll unemployment duration_5 units_total owner_occ_per renter_occ_per comm_60_plus rent_vac_rate pov_below sing_par county_migrant_5 state_migrant_5 country_migrant_5 {
    display "Variable is: 		`var'"
    matrix `var'=J(3,3,.)
	matrix colname `var'=1980 1990 2000
	return clear

	local i=1
*	foreach year in 1980 1990 2000 {
*	    display "Year is:		`year'"
	    
	quietly kmatch md treat ${x} ${muni_control} (`var'_1980 `var'_1990 `var'_2000 = ${x} ${muni_control}), nn(1) cal(4.5) att vce(cluster name_id) idgen(match) replace
	
	mat `var'[1,1]=r(table)[1,1]
	mat `var'[2,1]=r(table)[5,1]
	mat `var'[3,1]=r(table)[6,1]		
	
	mat `var'[1,2]=r(table)[1,2]
	mat `var'[2,2]=r(table)[5,2]
	mat `var'[3,2]=r(table)[6,2]		

	mat `var'[1,3]=r(table)[1,3]
	mat `var'[2,3]=r(table)[5,3]
	mat `var'[3,3]=r(table)[6,3]		
		
*	}
	
}

foreach var in black educ_coll unemployment duration_5 units_total owner_occ_per renter_occ_per comm_60_plus rent_vac_rate pov_below sing_par county_migrant_5 state_migrant_5 country_migrant_5 {
    
	
	coefplot (m(`var'), ci((2 3)) label("Average") m(oh) mc(black)) || , yline(0, lp(dash) lc(red)) scheme(s1mono) vertical yscale(range(0)) ylabel(., add)

	graph export "${results_gph}\\`var'_att_high_rent.png", replace
}

*Immigration Figure

file open myfile using "${results_gph}\\inmigration_att_high_rent.tex", write replace
# delimit;
file write myfile "\begin{figure}[htpb]" _n
"\setlength\tabcolsep{1.5pt}" _n
"\begin{center}" _n
"\caption{Estimated ATT of rent control on immigration outcomes by year: high rental tract sample} \label{fig:inmigration_att_high_rent}" _n
"\vspace*{6pt}" _n
"Migrate county \hfil  \hfil  Migrate state\\ \vspace*{3pt}" _n
"\includegraphics[width=.475\linewidth]{{${results_gph}/county_migrant_5_att_high_rent.png}}" _n
"\includegraphics[width=.475\linewidth]{{${results_gph}/state_migrant_5_att_high_rent.png}}\\  \vspace*{6pt}" _n
"Country migrant \\ \vspace*{3pt}" _n
"\includegraphics[width=.475\linewidth]{{${results_gph}/country_migrant_5_att_high_rent.png}} \\ \vspace*{6pt}" _n
"\FigText{\scriptsize Notes: Figures show the average treatment effect on the treated tracts of rent control on immigration outcomes. The unit of observation is a census tract with at least 30\% rental share. Each outcome is the percentage of tract inhabitants that have moved from a given location in the last 5 years. The error bars represent 95\% confidence intervals from standard errors that are clustered at the city level.}" _n
"\end{center}" _n
"\end{figure}" _n;
#delimit cr
file close myfile


*Housing Figure
file open myfile using "${results_gph}\\housing_att_high_rent.tex", write replace
# delimit;
file write myfile "\begin{figure}[htpb]" _n
"\setlength\tabcolsep{1.5pt}" _n
"\begin{center}" _n
"\caption{Estimated ATT of rent control on housing outcomes by year: high rental tract sample} \label{fig:housing_att_high_rent}" _n
"\vspace*{6pt}" _n
"P(Living in same house) \hfil  \hfil  Rental Vacancy Rt.\\ \vspace*{3pt}" _n
"\includegraphics[width=.475\linewidth]{{${results_gph}/duration_5_att_high_rent.png}}" _n
"\includegraphics[width=.475\linewidth]{{${results_gph}/rent_vac_rate_att_high_rent.png}}\\  \vspace*{6pt}" _n
 "Long Commute \hfil  \hfil  \% Rentals\\  \vspace*{3pt}" _n
"\includegraphics[width=.475\linewidth]{{${results_gph}/comm_60_plus_att_high_rent.png}}" _n
"\includegraphics[width=.475\linewidth]{{${results_gph}/renter_occ_per_att_high_rent.png}}\\  \vspace*{6pt}" _n
"Total Units \\ \vspace*{3pt}" _n
"\includegraphics[width=.475\linewidth]{{${results_gph}/units_total_att_high_rent.png}} \\ \vspace*{6pt}" _n
"\FigText{\scriptsize Notes: Figures show the average treatment effect on the treated tracts of rent control on housing outcomes. The unit of observation is a census tract with at least 30\% rental share. The average outcomes are generated using the baseline nearest neighbor match model. The error bars represent 95\% confidence intervals from standard errors that are clustered at the city level.}" _n
"\end{center}" _n
"\end{figure}" _n;
#delimit cr
file close myfile


*Demographic figure
file open myfile using "${results_gph}\\demographic_att_high_rent.tex", write replace
# delimit;
file write myfile "\begin{figure}[!h]" _n
"\setlength\tabcolsep{1.5pt}" _n
"\begin{center}" _n
"\caption{Estimated ATT of rent control on demographic outcomes} \label{fig:demographic_att_high_rent}" _n
"\vspace*{6pt}" _n
"Single Parent Rt. \hfil  \hfil  College\\ \vspace*{3pt}" _n
"\includegraphics[width=.475\linewidth]{{${results_gph}/sing_par_att_high_rent.png}}" _n
"\includegraphics[width=.475\linewidth]{{${results_gph}/educ_coll_att_high_rent.png}}\\  \vspace*{6pt}" _n
 "Poverty Rt. \hfil  \hfil  Unemployment Rt.\\  \vspace*{3pt}" _n
"\includegraphics[width=.475\linewidth]{{${results_gph}/pov_below_att_high_rent.png}}" _n
"\includegraphics[width=.475\linewidth]{{${results_gph}/unemployment_att_high_rent.png}}\\  \vspace*{3pt}" _n
"\FigText{\scriptsize Notes: Figures show the average treatment effect on the treated tracts of rent control on employment and demograhic outcomes. The unit of observation is a census tract with at least 30\% rental share. The average outcomes are generated using the baseline nearest neighbor match model. The error bars represent 95\% confidence intervals from standard errors that are clustered at the city level.}" _n
"\end{center}" _n
"\end{figure}" _n;
#delimit cr
file close myfile



