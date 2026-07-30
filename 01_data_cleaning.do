*==============================================================
* 01_data_cleaning.do - wage project
* Cleaning the raw Data and Merging it the final to Data_Assignment.dta
* Input: ANNUALWAGES.csv | PPP.csv | WDI.csv | TM_WORLDdb.dta
* By: El Mazbouh, Adam & Önümlü, Kamilhan 
*==============================================================
clear all
set more off
cap log close

cd "/Users/adam/Library/Mobile Documents/com~apple~CloudDocs/Uni /Semester 6/Toolkit/Data"
log using "01_data_cleaning.log", replace


*** ANNUAL WAGES DATA
import delimited "ANNUALWAGES.csv", clear

** Keeping only Obs on CPNCU 

keep if price_base == "V"

** Renaming and labeling the variables 

capture rename ref_area country_code 
capture rename time_period date_period
capture rename price_base base_year
capture rename v8 measure_desc

capture rename v18 sex_desc
capture rename v30 decimals_desc
capture rename obs_value wage_ncu

label var structure "Structure"
label var structure_id "Structure ID"
label var structure_name "Structure Name"

label var action "Action"
label var country_code "Reference area (Code)"
label var referencearea "Reference area (Label)"

label var measure "Measure (Code)"
label var measure_desc "Measure (Label)"
label var unit_measure "Unit of measure (Code)"

label var unitofmeasure "Unit of measure (Label)"
label var pay_period "Pay period (Code)"
label var payperiod "Pay period (Label)"

label var base_year "Price base (Code)"
label var pricebase "Price base (Label)"
label var aggregation_operation "Aggregation operation (Code)" 

label var aggregationoperation "Aggregation operation (Label)" 
label var sex "Sex (Code)"
label var sex_desc "Sex (Label)"

label var date_period "Time period (Code)"
label var base_per "Base period (Code)"
label var obs_status "Observation status (Code)"

label var observationstatus "Observation status (Label)"
label var unit_mult "Unit multiplier (Code)"
label var unitmultiplier "Unit multiplier (Label)"
label var decimals "Decimals (Code)"

label var decimals_desc "Decimals (Label)"
label variable wage_ncu "Average annual wage (NCU)"


*dropping empty/useless vars

drop timeperiod 
drop observationvalue  //they all contain no info
drop baseperiod

save "Cleaned_Global_Wage_Data.dta", replace


* PPP DATA
import delimited "PPP.csv", clear

** Only keeping EXC_A Obs

keep if transaction == "EXC_A" 

** Renaming and Labeling (adapting to cleaned_annual_wages.dta)

capture rename ref_area country_code
capture rename price_base base_year
capture rename time_period date_period

capture rename v38 decimals_desc
capture rename v14 transaction_desc
capture rename v20 expenditure_desc

capture rename v26 transformation_desc
capture rename v44 currency_desc
rename obs_value exch_rate

label variable structure "Structure"
label variable structure_id "Structure ID"
label variable structure_name "Structure Name"

label variable freq "Frequency of observation (Code)"
label variable frequencyofobservation "Frequency of observation (Label)"
label variable country_code "Reference area (Code)"

label variable referencearea "Reference area (Label)"
label variable sector "Institutional sector (Code)"
label variable institutionalsector "Institutional sector (Label)"

label variable counterpart_sector "Counterpart institutional sector (Code)"
label variable counterpartinstitutionalsector "Counterpart institutional sector (Label)"
label variable transaction "Transaction (Code)"

label variable transaction_des "Transaction (Label)"
label variable instr_asset "Financial instruments and non-financial assets (Code)"
label variable financialinstruments "Financial instruments and non-financial assets (Label)"

label variable activity "Economic activity (Code)"
label variable economicactivity "Economic activity (Label)"
label variable expenditure "Expenditure (Code)"

label variable expenditure_des "Expenditure (Label)"
label variable unit_measure "Unit of measure (Code)"
label variable unitofmeasure "Unit of measure (Label)"

label variable base_year "Price base (Code)"
label variable pricebase "Price base (Label)"
label variable transformation "Transformation (Code)"

label variable transformation_desc "Transformation (Label)"
label variable table_identifier "Table identifier (Code)"
label variable tableidentifier "Table identifier (Label)"

label variable date_period "Time period (Code)"
label variable timeperiod "Time period (Label)"
label variable exch_rate "Exchange rate (period-average)"

label variable observationvalue "Observation value (String/Label)"
label variable ref_year_price "Price reference year (Code)"
label variable pricereferenceyear "Price reference year (Label)"

label variable conf_status "Confidentiality status (Code)"
label variable confidentialitystatus "Confidentiality status (Label)"
label variable decimals "Decimals (Code)"

label variable decimals_desc "Decimals (Label)"
label variable obs_status "Observation status (Code)"
label variable observationstatus "Observation status (Label)"

label variable unit_mult "Unit multiplier (Code)"
label variable unitmultiplier "Unit multiplier (Label)"
label variable currency "Currency (Code)"

label variable currency_des "Currency (Label)"
label variable action "Action"

* dropping empty/useless vars

drop observationvalue 
drop ref_year_price
drop pricereferenceyear


save "CLEANED_PPP.dta", replace

*** WDI DATA

import delimited "WDICSV.csv", varnames(1) stringcols(_all) case(preserve) clear

* 1. Renaming Year-Vars
foreach var of varlist v* {
    local year : variable label `var'
    rename `var' yr`year'
}

* 2. Keep only relevant indicators
keep if inlist(IndicatorCode, ///
    "SE.SEC.CUAT.UP.ZS", /// Upper secondary attainment
    "SL.SRV.EMPL.ZS",    /// Employment in services
    "SL.GDP.PCAP.EM.KD", /// GDP per worker
    "SL.TLF.CACT.FE.ZS", /// Labour force part., female
    "HD_HCIP_OVRL_TO",   /// HCI+ total
    "SE.ADT.LITR.ZS",    /// Literacy rate, total
    "SI.POV.GINI",       /// Gini index
    "SL.UEM.TOTL.ZS",    /// Unemployment, total
    "SL.TLF.CACT.MA.ZS") /// Labour force part., male
    | inlist(IndicatorCode, ///
    "SE.TER.CUAT.BA.ZS", /// Bachelor's attainment
    "SL.AGR.EMPL.ZS",    /// Employment in agriculture
    "SL.IND.EMPL.ZS")    /// Employment in industry

drop IndicatorName // can be ommited, since we are renaming

* Keeping solely relevant Years
keep CountryCode CountryName IndicatorCode yr2005-yr2017

* 4. reshape (long)
reshape long yr, i(CountryCode CountryName IndicatorCode) j(year)
rename yr val

* 5. destring
destring val, replace force

* 6. giving names which we can work with for reshape
replace IndicatorCode = subinstr(IndicatorCode, ".", "_", .)

* 7. Reshape (Wide)
reshape wide val, i(CountryCode CountryName year) j(IndicatorCode) string

* 8. renaming
rename val* *
rename HD_HCIP_OVRL_TO hci
rename  SL_GDP_PCAP_EM_KD gdp_pw
rename SE_ADT_LITR_ZS literacy
rename SE_SEC_CUAT_UP_ZS edu_attain_us
rename SE_TER_CUAT_BA_ZS edu_attain_ba
rename SI_POV_GINI gini
rename SL_SRV_EMPL_ZS emp_sector
rename SL_TLF_CACT_FE_ZS labor_fem
rename SL_TLF_CACT_MA_ZS labor_male
rename SL_UEM_TOTL_ZS unemp
rename SL_AGR_EMPL_ZS emp_agri
rename SL_IND_EMPL_ZS emp_ind
rename CountryCode country_code
rename year date_period
rename CountryName country_name

* 9. Labeling

label variable edu_attain_ba "Bachelor's Attainment"
label variable gdp_pw "GDP per worker"
label variable hci "Human Capital Index"
label variable labor_fem "Labor force part. rate, female"
label var labor_male "Labor force part. rate, male"
label variable edu_attain_us "Secondary School Attainment"
label var literacy "Literacy Rate"
label var gini "GINI Coefficient"
label var unemp "Unemployment Rate"
label var emp_sector "Employment in services (% of total)"   
label var emp_agri   "Employment in agriculture (% of total)"
label var emp_ind    "Employment in industry (% of total)"

sort country_code date_period


save "WDI_clean.dta", replace

*** MERGING THE 3 DATASETS

*1. First Merge 
merge 1:1 country_code date_period using "CLEANED_PPP.dta"
drop if _merge != 3 
drop _merge

*2. Second Merge
merge 1:1 country_code date_period using "Cleaned_Global_Wage_Data.dta"
drop if _merge != 3 
drop _merge

* Avg Annual Wage in USD
gen wage_usd = wage_ncu / exch_rate

* Log of wage_usd
gen ln_wage_usd = ln(wage_usd)

save "Data_Assignment.dta", replace

*** MERGING FINAL DATASET WITH TM WORLD
use "TM_WORLDdb.dta", clear

* Cleaning the File

keep ISO3 REGION SUBREGION LAT LON id
rename ISO3 country_code
save "TM_WORLD_slim.dta", replace

use "Data_Assignment.dta", clear
sort country_code

* 3. Merging
merge m:1 country_code using "TM_WORLD_slim.dta"
keep if _merge == 3
drop _merge

* Making sure only 2005-2017 in final Data

keep if inrange(date_period, 2005, 2017)

* Some final adjustments

label define reg_lbl 9 "Oceania" 142 "Asia" 150 "Europe" 19 "Americas"
label values REGION reg_lbl
drop referencearea

	* Useful for Plotting
capture decode REGION, gen(region_str)

	* Useful for Correlation
gen lgdp_pw = ln(gdp_pw)
label var lgdp_pw "ln(GDP per person employed)"

save "Data_Assignment.dta", replace
log close
