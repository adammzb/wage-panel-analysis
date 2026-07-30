*==============================================================
* 02_descriptives.do - wage project
* All summary statistics, correlations, regressions, tables
* Input: Data_Assignment.dta (from 01_datacleaning.do)
* By: El Mazbouh, Adam & Önümlü, Kamilhan
*==============================================================
clear all
set more off
cap log close

cd "path/to/your/data", replace

use "Data_Assignment.dta", clear

* Panel declaration
capture encode country_code, gen(country_id)
xtset country_id date_period

capture decode REGION, gen(region_str)

***** START of ANALYSIS 


* 1. Data Overview

* First Look 
xtdescribe

codebook country_code date_period, compact

tab date_period

count      

tab country_name                          

* Summary statistics of the main variables
tabstat wage_usd ln_wage_usd gdp_pw edu_attain_us edu_attain_ba ///
        emp_agri emp_ind emp_sector gini unemp labor_fem labor_male, ///
        stats(n mean sd min p50 max) columns(statistics)
		
	* By country (avg wage)
tabstat wage_usd, by(country_name) stat(mean sd min max) format(%9.0f)

	* By year (avg wage)
tabstat wage_usd, by(date_period) stat(mean sd) format(%9.0f)

	* By Region
tabstat wage_usd, by(REGION) stat(mean sd n) format(%9.0f)


* Checking on what is Missing

misstable sum /// Shows every missing Obs
	wage_usd ln_wage_usd gdp_pw edu_attain_us edu_attain_ba ///
	emp_agri emp_ind emp_sector gini unemp ///
	labor_fem labor_male hci literacy 

* Confirm balanced panel (each country has to appear 13 times)
tab country_name date_period, missing

* 2. Simple Correlations

* Correlation Matrix
corr ln_wage_usd gdp_pw edu_attain_us emp_sector unemp gini labor_fem

* with significance stars
pwcorr ln_wage_usd gdp_pw edu_attain_us emp_sector unemp gini labor_fem, ///
    sig star(0.05)

* 3. Relation-Specific Correlations

* Education
pwcorr   ln_wage_usd edu_attain_us edu_attain_ba, sig star(0.05)
spearman ln_wage_usd edu_attain_us edu_attain_ba, stats(rho p) 

* Employment by sector
pwcorr ln_wage_usd emp_agri emp_ind emp_sector, sig star(0.05)

* Inequality (Gini) 
pwcorr   ln_wage_usd gini, sig star(0.05)
spearman ln_wage_usd gini, stats(rho p)

	* Keeping the Analysis consistent 

label var lgdp_pw "ln(GDP per person employed)"

pcorr ln_wage_usd gini lgdp_pw

* Gender / labour participation
pwcorr   ln_wage_usd labor_fem labor_male, sig star(0.05)
spearman ln_wage_usd labor_fem, stats(rho p)

* Unemployment
pwcorr   ln_wage_usd unemp, sig star(0.05)
spearman ln_wage_usd unemp, stats(rho p)

* 4. Regression

	* Pooled OLS
reg ln_wage_usd edu_attain_us emp_sector unemp gini, vce(cluster country_id)
estimates store m_pols

	* FE, within-country Variation
xtreg ln_wage_usd edu_attain_us emp_sector unemp gini, fe vce(cluster country_id)
estimates store m_fe

	* Two-way FE, country + years (absorbs global shocks)
xtreg ln_wage_usd edu_attain_us emp_sector unemp gini i.date_period, fe vce(cluster country_id)
estimates store m_fe2

	* Comparison Table
estimates table m_pols m_fe m_fe2, ///
    keep(edu_attain_us emp_sector unemp gini) ///
    b(%9.4f) star stats(N r2 r2_w) ///
    title("ln(Average Annual Wage, USD): POLS vs FE vs Two-way FE")

	* Confirming FE: Hausman Test
quietly xtreg ln_wage_usd edu_attain_us emp_sector unemp gini, fe
estimates store fe_h
quietly xtreg ln_wage_usd edu_attain_us emp_sector unemp gini, re
estimates store re_h
hausman fe_h re_h 

log close
