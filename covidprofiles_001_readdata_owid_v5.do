** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name				  covidprofiles_001_readdata_owid_v5.do
    //  project:				        
    //  analysts:				  	  Ian HAMBLETON
    // 	date last modified	          18-JUN-2020
    //  algorithm task			      Draw Open Access Data from OWID

    ** General algorithm set-up
    version 16
    clear all
    macro drop _all
    set more 1
    set linesize 80

    ** Set working directories: this is for DATASET and LOGFILE import and export
    ** DATASETS to encrypted SharePoint folder
    local datapath "X:\The University of the West Indies\DataGroup - repo_data\data_p151"
    ** LOGFILES to unencrypted OneDrive folder
    local logpath "X:\OneDrive - The University of the West Indies\repo_datagroup\repo_p151"
    ** Reports and Other outputs
    local outputpath "X:\The University of the West Indies\DataGroup - DG_Projects\PROJECT_p151"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\covidprofiles_001_readdata_owid_v5", replace
** HEADER -----------------------------------------------------

** DATA DRAWN FROM OWID
** https://ourworldindata.org/
** 
** COVID datasets hosted on GitHub 
** https://github.com/owid/covid-19-data

** Data Source A1 - ECDC counts
    python: import pandas as count_csv
    python: count_df = count_csv.read_csv('https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/ecdc/full_data.csv')
    cd "`datapath'\version01\1-input\"
    python: count_df.to_stata('count_owid.dta')

** Data Source A2 - OWID location information
    python: import pandas as loc_csv
    python: loc_df = loc_csv.read_csv('https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/ecdc/locations.csv')
    cd "`datapath'\version01\1-input\"
    python: loc_df.to_stata('loc_owid.dta')

** Data Source A3 - Additional information
    python: import pandas as full_csv
    python: full_df = full_csv.read_csv('https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/owid-covid-data.csv')
    cd "`datapath'\version01\1-input\"
    python: full_df.to_stata('full_owid.dta')

** Data Source B1 - ECDC 
    python: import pandas as count_csv
    python: count_df2 = count_csv.read_csv('https://opendata.ecdc.europa.eu/covid19/casedistribution/csv')
    cd "`datapath'\version01\1-input\"
    python: count_df2.to_stata('count_ecdc.dta')


** Data Preparation of Imported files
** Load counts. Merge with population data (loc) and with iSO data (full) 
tempfile count loc full count_loc
use "`datapath'\version01\1-input\count_owid", clear
drop index 
** DATE OF EVENTS
rename date date_orig 
gen date = date(date_orig, "YMD", 2020)
format date %tdNN/DD/CCYY
drop date_orig
order date 
sort location date 
save `count' 

** Merge with population data
use "`datapath'\version01\1-input\loc_owid", clear
keep location population 
sort location 
save `loc' 
** Merge = 2 if location == WORLD (global totals)
merge m:m location using `count' 
drop _merge 
save `count_loc' 

** Merge with ISO data 
use "`datapath'\version01\1-input\full_owid", clear
keep location iso_code 
rename iso_code iso 
sort location 
save `full' 

use `count_loc' 
merge m:m location using `full' 
** This drops Hong Kong - not in count database from OWID
drop if _merge==2
drop _merge 

** TEXT NAME FOR COUNTRY (STRING)
rename location countryregion 
** POPULATION
rename population pop

** Save out the dataset for next DO file
order countryregion iso pop date new_cases new_deaths total_cases total_deaths 
gsort countryregion -date 
save "`datapath'\version01\2-working\owid_time_series", replace


/*
** 18-JUN-2020
** Use this if we want to bring in ECDC data directly

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


