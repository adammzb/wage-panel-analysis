*==============================================================
* 03_graphs.do - E376
* All graphs reported in the analysis
* Input: Data_Assignment.dta (from data_cleaning.do)
* By: El Mazbouh, Adam (6687616) & Önümlü, Kamilhan (7113198)
*==============================================================

clear all
set more off
cap log close

cd "/Users/adam/Library/Mobile Documents/com~apple~CloudDocs/Uni /Semester 6/Toolkit/Data"
log using "graphs.log", replace

use "Data_Assignment.dta", clear

* 1. Distribution of the Main Variable

* Histogram - wage in levels (right-skew)
histogram wage_usd, bin(25) frequency color(navy%70) lcolor(white) ///
    xtitle("Average Annual Wage (USD)") ytitle("Frequency") ///
    title("Distribution of Average Annual Wage (USD)", size(medium)) ///
    note("N = 494 obs. Source: OECD / WDI")
graph export "graph_hist_wage_usd.png", replace width(1800)

* Histogram + KDE - log wage (bimodal)
histogram ln_wage_usd, bin(25) density kdensity kdenopts(lwidth(medthick) lcolor(red)) ///
    color(navy%60) lcolor(white) ///
    xtitle("Log Average Annual Wage (USD)") ytitle("Density") ///
    title("Distribution of Log Average Annual Wage (USD)", size(medium)) ///
    note("N = 494 obs. Bimodal: two country clusters. Source: OECD / WDI")
graph export "graph_hist_ln_wage.png", replace width(1800)

* Comparison: KDE early vs late period
twoway (kdensity ln_wage_usd if date_period <= 2009, lcolor(blue) lwidth(medthick)) ///
       (kdensity ln_wage_usd if date_period >= 2013, lcolor(red)  lwidth(medthick)), ///
    legend(order(1 "2005-2009" 2 "2013-2017") pos(6) rows(1)) ///
    xtitle("Log Average Annual Wage (USD)") ytitle("Density") ///
    title("KDE of Log Wage: Early vs. Late Period", size(medium)) ///
    note("Years 2010-2012 omitted. Source: OECD / WDI")
graph export "graph_kde_ln_wage_periods.png", replace width(1800)

* Graph Box per Continent
preserve
keep if date_period == 2017

graph box wage_usd, over(region_str, sort(1))   ///
    title("Wage Distribution by Region (2017)")                     ///
    ytitle("Wage USD")                                              ///
    marker(1, mcolor(navy%60) msize(vsmall))
graph export "wage_dist_boxplot.png", replace width(2400)
restore

* 2. WAGE OVER TIME (overview)

* Cross-country mean wage over time
preserve
collapse (mean) wage_usd, by(date_period)
twoway (line wage_usd date_period, lcolor(navy) lwidth(medthick)), ///
    title("Cross-Country Mean Annual Wage over Time", size(medium)) ///
    xtitle("Year") ytitle("Mean Annual Wage (USD)") ///
    xlabel(2005(1)2017, angle(45)) ///
    note("Mean over all sample countries. Source: OECD")
graph export "graph_line_mean_wage_time.png", replace width(2000)
restore

* Regional mean wage over time
preserve
collapse (mean) mean_wage=wage_usd, by(date_period region_str)

twoway ///
       (line mean_wage date_period if region_str=="Americas", lcolor(blue))    ///
       (line mean_wage date_period if region_str=="Asia", lcolor(red))     ///
       (line mean_wage date_period if region_str=="Europe", lcolor(green))   ///
       (line mean_wage date_period if region_str=="Oceania", lcolor(purple)), ///
    title("Mean Annual Wage by Region Over Time")                       ///
    xtitle("Year") ytitle("Mean Wage (USD)")                           ///
    legend(label(1 "Americas") label(2 "Asia")       ///
           label(3 "Europe") label(4 "Oceania")                        ///
           pos(11) ring(0) cols(1))
graph export "wage_trend_region.png", replace width(2400)
restore

* Wage over time - selected countries
twoway ///
    (line wage_usd date_period if country_code=="USA", lcolor(navy)) ///
    (line wage_usd date_period if country_code=="CHE", lcolor(dkgreen)) ///
    (line wage_usd date_period if country_code=="NOR", lcolor(blue)) ///
    (line wage_usd date_period if country_code=="KOR", lcolor(orange)) ///
    (line wage_usd date_period if country_code=="CZE", lcolor(purple)) ///
    (line wage_usd date_period if country_code=="POL", lcolor(red)) ///
    (line wage_usd date_period if country_code=="MEX", lcolor(maroon)) ///
    (line wage_usd date_period if country_code=="TUR", lcolor(gray)), ///
    legend(order(1 "USA" 2 "CHE" 3 "NOR" 4 "KOR" 5 "CZE" 6 "POL" 7 "MEX" 8 "TUR") ///
           pos(6) rows(2) size(small)) ///
    xtitle("Year") ytitle("Average Annual Wage (USD)") ///
    xlabel(2005(1)2017, angle(45)) ///
    title("Average Annual Wage over Time - Selected Countries", size(medium)) ///
    note("Source: OECD")
graph export "graph_line_wage_countries.png", replace width(2000)

* 3. Scatter Plot - Overview

graph matrix ln_wage_usd gdp_pw hci edu_attain_us gini emp_sector unemp, ///
    msymbol(oh) msize(vsmall) mcolor(navy%40) ///
    title("Scatter-plot matrix: key variables") 
graph export "graph_scatter_matrix.png", replace width(2800)

* 4. Relation Education

*  Wage vs each Attainment Measure
preserve
keep if date_period == 2017

* Bachelor's or above (N = 30 of 38)
twoway (scatter ln_wage_usd edu_attain_ba, mcolor(navy%60) msize(small) ///
            mlabel(country_code) mlabsize(tiny) mlabcolor(gs6)) ///
       (lfit    ln_wage_usd edu_attain_ba, lcolor(cranberry) lwidth(medthick)), ///
    title("Bachelor's+ Attainment") ///
    xtitle("Share with Bachelor's or above (%)") ytitle("ln(Wage USD)") ///
    legend(label(1 "Country") label(2 "OLS fit") pos(11) ring(0) cols(1)) ///
    name(g_ba, replace)
graph save "wage_edu_ba_scatter.gph", replace

* Upper-secondary (N = 33 of 38)
twoway (scatter ln_wage_usd edu_attain_us, mcolor(navy%60) msize(small) ///
            mlabel(country_code) mlabsize(tiny) mlabcolor(gs6)) ///
       (lfit    ln_wage_usd edu_attain_us, lcolor(cranberry) lwidth(medthick)), ///
    title("Upper-Secondary Attainment") ///
    xtitle("Share with upper-secondary (%)") ytitle("ln(Wage USD)") ///
    legend(label(1 "Country") label(2 "OLS fit") pos(11) ring(0) cols(1)) ///
    name(g_us, replace)
graph save "wage_edu_us_scatter.gph", replace
restore

*Combining both

graph combine "wage_edu_ba_scatter.gph" "wage_edu_us_scatter.gph", ///
    cols(2) ycommon imargin(small) ///
    title("Log Wage vs. Educational Attainment (2017)") ///
    note("Source: OECD / WDI")
graph export "wage_edu_combined.png", replace width(3200)

* Bachelor's attainment by region over time
preserve
collapse (mean) edu_attain_ba, by(date_period REGION)
decode REGION, gen(region_str)

twoway (line edu_attain_ba date_period if region_str=="Americas", lcolor(blue)   lwidth(medthick)) ///
       (line edu_attain_ba date_period if region_str=="Asia",     lcolor(red)    lwidth(medthick)) ///
       (line edu_attain_ba date_period if region_str=="Europe",   lcolor(green)  lwidth(medthick)) ///
       (line edu_attain_ba date_period if region_str=="Oceania",  lcolor(purple) lwidth(medthick)), ///
    title("Bachelor's+ Attainment by Region Over Time") ///
    xtitle("Year") ytitle("Share (%)") ///
    legend(order(1 "Americas" 2 "Asia" 3 "Europe" 4 "Oceania") ///
           pos(6) rows(1) size(small)) ///
    note("Mean across sample countries. No African countries in sample. Source: WDI")
graph export "edu_attain_ba_region.png", replace width(2400)
restore

* 5. Relation GINI

* Wage vs Gini (2017)
preserve
keep if date_period == 2017

twoway (scatter ln_wage_usd gini, mcolor(navy%60) msize(small) ///
            mlabel(country_code) mlabsize(tiny) mlabcolor(gs6)) ///
       (lfit   ln_wage_usd gini, lcolor(cranberry) lwidth(medthick)) ///
       (lowess ln_wage_usd gini, lcolor(orange) lwidth(medthick) lpattern(dash)), ///
    title("Log Wage vs. Gini Coefficient (2017)") ///
    xtitle("Gini coefficient") ytitle("ln(Wage USD)") ///
    legend(label(1 "Country") label(2 "OLS fit") label(3 "LOWESS") ///
           pos(1) ring(0) cols(1))
graph export "wage_gini_scatter.png", replace width(2400)


* Box plot: Gini distribution by region (2017)

keep if date_period == 2017 & !missing(gini)

* Gini per Region
graph box gini, over(REGION, label(angle(45))) ///
    ytitle("Gini coefficient") ///
    marker(1, mcolor(navy%60) msize(vsmall)) ///
    name(g_gini_box, replace)

* Mean Wage
graph bar (mean) wage_usd, over(REGION, label(angle(45))) ///
    bar(1, color(navy%70)) ///
    ytitle("Mean wage (USD)") ///
    blabel(bar, format(%9.0fc) size(small)) ///
    name(g_wage_bar, replace)

* Combining both
graph combine g_gini_box g_wage_bar, cols(1) ///
    ysize(7) xsize(5) iscale(0.9) imargin(medium) ///
    title("Inequality and Wage Level by Region (2017)") ///
    note("No African countries in sample. If no Gini in 2017 then omitted. Source: OECD / WDI")
graph export "gini_wage_region_combined.png", replace width(2000) height(2800)
restore

* Dual-axis: mean wage and mean gini over time
preserve
collapse (mean) wage_usd gini, by(date_period)
twoway (line wage_usd date_period, lcolor(navy)      lwidth(medthick)) ///
       (line gini     date_period, lcolor(cranberry) lwidth(medthick) yaxis(2)), ///
    title("Mean Wage and Gini Coefficient Over Time") ///
    xtitle("Year") ///
    ytitle("Mean wage (USD)", axis(1)) ///
    ytitle("Gini coefficient", axis(2)) ///
    legend(label(1 "Mean wage (USD)") label(2 "Gini") ///
           pos(11) ring(0) cols(1)) ///
    note("Dual axis: scales not comparable. Source: OECD / WDI")
graph export "wage_gini_trend.png", replace width(2400)
restore

* Gini for selected countries over time
* High-wage: USA, CHE, NOR | Mid: KOR, CZE, POL | Low: MEX, TUR
twoway ///
    (line gini date_period if country_code=="USA", lcolor(navy) lwidth(medthick)) ///
    (line gini date_period if country_code=="CHE", lcolor(dkgreen) lwidth(medthick)) ///
    (line gini date_period if country_code=="NOR", lcolor(blue)lwidth(medthick)) ///
    (line gini date_period if country_code=="KOR", lcolor(orange) lwidth(medthick)) ///
    (line gini date_period if country_code=="CZE", lcolor(purple)lwidth(medthick)) ///
    (line gini date_period if country_code=="POL", lcolor(red) lwidth(medthick)) ///
    (line gini date_period if country_code=="MEX", lcolor(maroon) lwidth(medthick)) ///
    (line gini date_period if country_code=="TUR", lcolor(gray) lwidth(medthick)), ///
    title("Gini Coefficient Over Time – Selected Countries") ///
    xtitle("Year") ytitle("Gini coefficient") ///
    legend(order(1 "USA" 2 "CHE" 3 "NOR" 4 "KOR" 5 "CZE" 6 "POL" 7 "MEX" 8 "TUR") ///
           pos(6) ring(1) rows(2) size(small))
graph export "gini_trend_countries.png", replace width(2400)

* 6. Relation Sectors of Employment


* lnWage vs Sectors (2017)
preserve
keep if date_period == 2017

twoway (scatter ln_wage_usd emp_agri, mcolor(navy%60) msize(small))        ///
       (lfit    ln_wage_usd emp_agri, lcolor(cranberry) lwidth(medthick)), ///
    title("Agriculture") xtitle("Employment in agriculture (%)")           ///
    ytitle("ln(Wage USD)") legend(off) name(g_agri, replace)

twoway (scatter ln_wage_usd emp_ind, mcolor(navy%60) msize(small))         ///
       (lfit    ln_wage_usd emp_ind, lcolor(cranberry) lwidth(medthick)),  ///
    title("Industry") xtitle("Employment in industry (%)")                 ///
    ytitle("") legend(off) name(g_ind, replace)

twoway (scatter ln_wage_usd emp_sector, mcolor(navy%60) msize(small))      ///
       (lfit    ln_wage_usd emp_sector, lcolor(cranberry) lwidth(medthick)), ///
    title("Services") xtitle("Employment in services (%)")                 ///
    ytitle("") legend(off) name(g_serv, replace)

graph combine g_agri g_ind g_serv, rows(1) ycommon                         ///
    title("Log Wage vs. Employment by Sector (2017)")                      ///
    subtitle("Red line = OLS fit") note("Source: OECD / WDI")
graph export "wage_empsector_scatter.png", replace width(2400)
restore

* Sectors over Time
preserve
collapse (mean) emp_agri emp_ind emp_sector, by(date_period)
twoway (line emp_agri   date_period, lcolor(forest_green) lwidth(medthick)) ///
       (line emp_ind    date_period, lcolor(navy)         lwidth(medthick)) ///
       (line emp_sector date_period, lcolor(cranberry)    lwidth(medthick)), ///
    title("Employment Structure Over Time (sample mean)")                   ///
    xtitle("Year") ytitle("Employment share (%)")                           ///
    legend(label(1 "Agriculture") label(2 "Industry") label(3 "Services")   ///
           rows(1) pos(6))                                                   ///
    note("Mean across sample countries. Source: WDI")
graph export "emp_structure_trend.png", replace width(2400)
restore

* 7. Relation Female Labour Force Participation

* Wage vs Female Participation (2017) 
preserve
keep if date_period == 2017
twoway (scatter ln_wage_usd labor_fem, mcolor(navy%60) msize(small) ///
            mlabel(country_code) mlabsize(tiny) mlabcolor(gs6)) ///
       (lfit   ln_wage_usd labor_fem, lcolor(cranberry) lwidth(medthick)) ///
       (lowess ln_wage_usd labor_fem, lcolor(orange) lwidth(medthick) lpattern(dash)), ///
    title("Log Wage vs. Female Labour Participation (2017)") ///
    xtitle("Female labour force participation (%)") ytitle("ln(Wage USD)") ///
    legend(label(1 "Country") label(2 "OLS fit") label(3 "LOWESS") ///
           pos(5) ring(0) cols(1))
graph export "wage_laborfem_scatter.png", replace width(2400)
restore

*  Wage vs Gender Gap (2017)
preserve
keep if date_period == 2017
capture gen gender_gap = labor_male - labor_fem
label var gender_gap "Gender gap in participation (M - F, pp)"
twoway (scatter ln_wage_usd gender_gap, mcolor(navy%60) msize(small) ///
            mlabel(country_code) mlabsize(tiny) mlabcolor(gs6)) ///
       (lfit   ln_wage_usd gender_gap, lcolor(cranberry) lwidth(medthick)) ///
       (lowess ln_wage_usd gender_gap, lcolor(orange) lwidth(medthick) lpattern(dash)), ///
    title("Log Wage vs. Gender Gap in Labour Participation (2017)") ///
    xtitle("Gender gap (male - female, pp)") ytitle("ln(Wage USD)") ///
    legend(label(1 "Country") label(2 "OLS fit") label(3 "LOWESS") ///
           pos(1) ring(0) cols(1))
graph export "wage_gendergap_scatter.png", replace width(2400)
restore

* Gender gap over time: by region + global 
preserve
collapse (mean) labor_fem labor_male, by(date_period REGION)
gen gender_gap = labor_male - labor_fem
decode REGION, gen(region_str)
twoway (line gender_gap date_period if region_str=="Americas", lcolor(blue) lwidth(medthick)) ///
       (line gender_gap date_period if region_str=="Asia", lcolor(red) lwidth(medthick)) ///
       (line gender_gap date_period if region_str=="Europe", lcolor(green) lwidth(medthick)) ///
       (line gender_gap date_period if region_str=="Oceania", lcolor(purple) lwidth(medthick)), ///
    title("By Region") xtitle("Year") ytitle("Gender gap (pp)") ///
    legend(label(1 "Americas") label(2 "Asia") label(3 "Europe") label(4 "Oceania") ///
           pos(1) ring(0) cols(1) size(small))
graph save "region_gap.gph", replace
restore


preserve
collapse (mean) labor_fem labor_male, by(date_period)
gen gender_gap = labor_male - labor_fem
twoway (line gender_gap date_period, lcolor(navy) lwidth(medthick)), ///
    title("Global") xtitle("Year") ytitle("Gender gap (pp)")
graph save "global_gap.gph", replace
restore

graph combine "region_gap.gph" "global_gap.gph", cols(2) ///
    title("Gender Gap in Labour Participation Over Time") ///
    imargin(small) ///
    note("No African countries in sample. Source: WDI")
graph export "gendergap_combined.png", replace width(3200)

* 8. Relation Unemployment

*  Wage vs Unemployment (2017)
preserve
keep if date_period == 2017
twoway (scatter ln_wage_usd unemp, mcolor(navy%60) msize(small) ///
            mlabel(country_code) mlabsize(tiny) mlabcolor(gs6)) ///
       (lfit   ln_wage_usd unemp, lcolor(cranberry) lwidth(medthick)) ///
       (lowess ln_wage_usd unemp, lcolor(orange) lwidth(medthick) lpattern(dash)), ///
    title("Log Wage vs. Unemployment Rate (2017)") ///
    xtitle("Unemployment rate (%)") ytitle("ln(Wage USD)") ///
    legend(label(1 "Country") label(2 "OLS fit") label(3 "LOWESS") ///
           pos(1) ring(0) cols(1))
graph export "wage_unemp_scatter.png", replace width(2400)
restore

* Dual-axis: mean wage & unemployment over time 
preserve
collapse (mean) wage_usd unemp, by(date_period)
twoway (line wage_usd date_period, lcolor(navy) lwidth(medthick)) ///
       (line unemp    date_period, lcolor(cranberry) lwidth(medthick) yaxis(2)), ///
    title("Mean Wage and Unemployment Rate Over Time") ///
    xtitle("Year") ///
    ytitle("Mean wage (USD)", axis(1)) ///
    ytitle("Unemployment rate (%)", axis(2)) ///
    legend(label(1 "Mean wage (USD)") label(2 "Unemployment (%)") ///
           pos(1) ring(0) cols(1)) ///
    note("Source: OECD / WDI")
graph export "wage_unemp_trend.png", replace width(2400)
restore

* Box plot: unemployment distribution by region (2017)
preserve
keep if date_period == 2017
graph box unemp, over(REGION, sort(1) label(angle(45))) ///
    title("Unemployment Rate Distribution by Region (2017)") ///
    ytitle("Unemployment rate (%)") ///
    marker(1, mcolor(navy%60) msize(small) ///
              mlabel(country_code) mlabsize(small) mlabcolor(gs4) mlabposition(3)) ///
    note("Source: WDI")
graph export "unemp_boxplot_region.png", replace width(2400)
restore
* (4) Unemployment over time: selected countries 
* Same selection as wage analysis (high/mid/low wage)
twoway ///
    (line unemp date_period if country_code=="USA", lcolor(navy)    lwidth(medthick)) ///
    (line unemp date_period if country_code=="CHE", lcolor(dkgreen) lwidth(medthick)) ///
    (line unemp date_period if country_code=="NOR", lcolor(blue)    lwidth(medthick)) ///
    (line unemp date_period if country_code=="KOR", lcolor(orange)  lwidth(medthick)) ///
    (line unemp date_period if country_code=="CZE", lcolor(purple)  lwidth(medthick)) ///
    (line unemp date_period if country_code=="POL", lcolor(red)     lwidth(medthick)) ///
    (line unemp date_period if country_code=="MEX", lcolor(maroon)  lwidth(medthick)) ///
    (line unemp date_period if country_code=="TUR", lcolor(gray)    lwidth(medthick)), ///
    title("Unemployment Rate Over Time - Selected Countries") ///
    xtitle("Year") ytitle("Unemployment rate (%)") ///
    xlabel(2005(1)2017, angle(45)) ///
    legend(order(1 "USA" 2 "CHE" 3 "NOR" 4 "KOR" 5 "CZE" 6 "POL" 7 "MEX" 8 "TUR") ///
           pos(6) rows(2) size(small)) ///
    note("Source: OECD / WDI")
graph export "unemp_trend_countries.png", replace width(2400)

*9. Mapping 

capture ssc install spmap
preserve

capture merge m:1 country_code using "TM_WORLD_slim.dta"

* 2017 cross-section, one row per polygon, rename id -> _ID for spmap
keep if date_period == 2017
keep id country_code wage_usd
drop if missing(id)
isid id   // safety: must be unique

* Verify the link before drawing
count if !missing(wage_usd)   //

gen wage_map = round(wage_usd/1000)

spmap wage_map using "TM_WORLDcoord.dta", id(id) ///
    clmethod(quantile) clnumber(5) ///
    fcolor(Blues) ocolor(gs10 ..) osize(vthin ..) ///
    ndfcolor(gs14) ndocolor(gs10) ///
    legtitle("Avg. annual wage ($1,000s), 2017") ///
    legend(position(7) size(small) ///
        label(2 "8 - 16") ///
        label(3 "16 - 30") ///
        label(4 "30 - 45") ///
        label(5 "45 - 53") ///
        label(6 "53 - 91")) ///
    title("Average Annual Wage by Country (2017)", size(medium)) ///
    note("Only Countries in Sample. Wage quintiles. Source: OECD / WDI")
graph export "map_wage_2017.png", replace width(2800)
restore

* 10. Ranking

* HCI Ranking (top 20)
preserve
collapse (mean) hci, by(country_name)
drop if missing(hci)
gsort -hci                      // sort high to low
gen rank = _n
keep if rank <= 20              

graph hbar (mean) hci, over(country_name, sort(1) label(labsize(small))) ///
    ytitle("Human Capital Index") ///
    title("Top Countries by Human Capital Index", size(medium)) ///
    bar(1, color(navy%70)) ///
    blabel(bar, format(%4.2f) size(vsmall)) ///
    note("HCI observed for few countries/years only. Source: WDI")
graph export "hci_ranking_top20.png", replace width(2000)
restore

log close
