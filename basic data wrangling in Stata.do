******************************
* M1 Data Wrangling Workshop *
******************************

clear all
cd "/Users/manuellopez/Documents/GitHub/M1 Workshop/Data/M1 - Chile" // this command sets a repository in your local computer

// import delimited "https://raw.githubusercontent.com/Manulobu/M1-Workshop---Data-Wrangling-for-Spatial-Econometrics/main/Data/M1%20-%20Chile/663b57d93119d000cf238462_results.csv", clear // This command could be used to directly fetch the dataset from its GitHub URL

import delimited "663b57d93119d000cf238462_results.csv"


d // provides a description of the dataset

// Before anything, let's check the dataset *

**************************
* Renaming awkward names *
**************************

rename viirs_ntl_annual_v20_avg_masked2 ntl2020
rename v3 ntl2012 
rename worldpop_pop_count_1km_mosaic202 pop2020
rename worldpop_pop_count_1km_mosaic201 pop2012
rename shapename adm3

*****************************
* Basic summary statistics *
*****************************

summarize

* Destringing variable ntl

destring ntl2020, replace

list ntl2012 if missing(real(ntl2012)) // identifies rthe specific observation within the variable containing nonnumeric values
list ntl2020 if missing(real(ntl2020))

// For the purpose illustrating
replace ntl2012 = "10" in 152
replace ntl2020 = "11" in 152

// Destring 

destring ntl2012, replace
destring ntl2020, replace

******************************
* Keeping relevant variables *
******************************

keep adm3 ntl2012 ntl2020 pop2012 pop2020
order adm, first // puts the variable adm3 as first column of the dataset

*************************
* Basic Transformations *
*************************

* Per capita: useful to control for sclae of the poligons
gen ntl_pc2012 = ntl2012 / pop2012
gen ntl_pc2020 = ntl2020 / pop2020

* Checking distributions

hist ntl_pc2012
hist ntl_pc2020

* Taking logarithms
gen l_ntl_pc2012 = ln(ntl_pc2012*10000)
gen l_ntl_pc2020 = ln(ntl_pc2020*10000)

* Checking distributions of the ln variables

hist l_ntl_pc2012
hist l_ntl_pc2020

// keeping only ln variables 

keep adm3 l_ntl_pc2012 l_ntl_pc2020

rename l_ntl_pc2012 ntl2012
rename l_ntl_pc2020 ntl2020

// Labeling variables
label var ntl2012 "Natural logarithm of nighttime lights per capita in 2012, city level"
label var ntl2020 "Natural logarith of nighttime lights per capita in 2020, city level"

**************************
* Shape transformations **
**************************

****************
* Wide to long *
****************

reshape long ntl, i(adm3) j(year)

// Duplicates report

sort adm3
duplicates report adm3
duplicates tag, generate(adm3_report)
duplicates list adm3

drop if _n == 320 // drops observation 320

drop adm3_report

reshape long ntl, i(adm3) j(year)

// Basic summary statistics long format

sum

**********************
* Saving long format *
**********************

save "cl long ntl 2012 - 2020", replace // creates a .dta database in the local GitHub repository
export delimited "cl long ntl 2012 - 2020", replace  // creates a .dta database in the local GitHub repository

****************
* Long to wide *
****************

reshape wide ntl, i(adm3) j(year)

// Basic summary statistics wide format
sum

save "cl wide ntl 2012 - 2020", replace
export delimited "cl wide ntl 2012 - 2020", replace
