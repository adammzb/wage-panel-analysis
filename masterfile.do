*==============================================================
* MASTER DO-FILE - E376 Assignment
* Dr. Camila Cisneros-Acevedo
*
* Runs the full project end to end:
*   01 data_cleaning   : raw CSVs -> cleaned, merged Data_Assignment.dta
*   02 descriptives    : summary stats, correlations, regressions
*   03 graphs          : all figures
* By: El Mazbouh, Adam (6687616) & Önümlü, Kamilhan (7113198)
*==============================================================

clear all
set more off
cap log close

* ---- set working directory (only place the path is defined) ----
cd "/Users/adam/Library/Mobile Documents/com~apple~CloudDocs/Uni /Semester 6/Toolkit/Data"


do "01_data_cleaning.do"
do "02_descriptives.do"    
do "03_graphs.do"          

cap log close


