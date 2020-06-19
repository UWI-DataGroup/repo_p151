


** 18-Jun-2020
** Use this if we want to bring in ECDC data directly
** We have switched from ECDC to OWID for two reasons:
**  (A) Cleaner dataset from OWID - has undergone some internal sweeping
**  (B) Downtime of ECDC data server prevented updates

** Load the basic ECDC dataset (counts and deaths)
tempfile count loc full count_loc count_full
use "`datapath'\version01\1-input\count_ecdc", clear
drop index geoId continentExp day month year
rename countriesAndTerritories location_ecdc 
rename countryterritoryCode iso 
replace iso="MSR" if iso=="MSF" & location_ecdc=="Montserrat" 
** DATE OF EVENTS
gen date = date(dateRep, "DMY", 2020)
format date %tdNN/DD/CCYY
drop dateRep
order date 
sort iso date 
order iso location_ecdc date 
save `count' 

** Merge with ISO data 
use "`datapath'\version01\1-input\full_owid", clear
keep location iso_code 
rename iso_code iso 
sort location 
save `full' 
** Merge (1) = Hong Kong, Kosovo, World, Taiwan 
** Merge (2) = Taiwan, Kosovo, Hong Kong, Kosovo, World, Taiwan 
merge m:m iso using `count' 
keep if _merge==3 
drop _merge
save `count_full' 

** Merge with population data
use "`datapath'\version01\1-input\loc_owid", clear
keep location population 
sort location 
save `loc' 
** Merge = 2 if location == WORLD (global totals)
merge m:m location using `count_full' 
drop _merge 
save `count_loc' 

** TEXT NAME FOR COUNTRY (STRING)
drop location_ecdc popData2019 
rename location countryregion 
** POPULATION
rename population pop
rename cases total_cases
rename deaths total_deaths
** Save out the dataset for next DO file
order countryregion iso pop date total_cases total_deaths 
gsort countryregion -date 
save "`datapath'\version01\2-working\owid_time_series", replace

