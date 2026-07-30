*==============================================================
* MASTER DO-FILE -  wage project
* 
*
* Runs the full project end to end:
*   01 data_cleaning   : raw CSVs -> cleaned, merged Data_Assignment.dta
*   02 descriptives    : summary stats, correlations, regressions
*   03 graphs          : all figures
* By: El Mazbouh, Adam & Önümlü, Kamilhan 
*==============================================================

clear all
set more off
cap log close

* ---- set working directory  ----
cd "path/to/your/data"


do "01_data_cleaning.do"
do "02_descriptives.do"    
do "03_graphs.do"          

cap log close


