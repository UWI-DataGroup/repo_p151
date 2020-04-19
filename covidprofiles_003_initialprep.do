** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					covidprofiles_003_initialprep.do
    //  project:				        
    //  analysts:				       	Ian HAMBLETON
    // 	date last modified	            17-APR-2020
    //  algorithm task			        Initial cleaning of JHopkns download

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
    log using "`logpath'\covidprofiles_003_initialprep", replace
** HEADER -----------------------------------------------------

** JH time series COVD-19 data 
** RUN covidprofiles_002_jhopkins.do BEFORE this algorithm
use "`datapath'\version01\2-working\jh_time_series", clear

** JOHNS HOKINS DATABASE CORRECTIONS TO COUNTRY NAMES
** UK has 2 names in database
replace countryregion = "UK" if countryregion=="United Kingdom"
** Bahamas has 3 names in database 
replace countryregion = "Bahamas" if countryregion=="Bahamas, The" | countryregion=="The Bahamas"
** South Korea has 2 names
replace countryregion = "South Korea" if countryregion=="Korea, South" 

** RESTRICT TO SELECTED COUNTRIES
** Keep UK, USA, Sth Korea, Singapore as comparators. Then keep all Caribbean nations
**      Antigua and Barbuda
**      --> NOT YET ADDED Aruba
**      Bahamas
**      Barbados
**      Belize
**      --> NOT YET ADDED Cayman Islands
**      Cuba
**      --> NOT YET ADDED Curacao
**      Dominica
**      Dominican Republic
**      --> NOT YET ADDED French Guiana (also under France)
**      Grenada
**      --> NOT YET ADDED Guadeloupe (also under France)
**      Guyana
**      Haiti
**      Jamaica
**      --> NOT YET ADDED Martinique (also under France)
**      --> NOT YET ADDED Puerto Rico (also under US?)
**      Saint Kitts and Nevis
**      Saint Lucia
**      Saint Vincent and the Grenadines
**      Suriname
**      Trinidad and Tobago
#delimit ; 
keep if countryregion=="South Korea" |
        countryregion=="UK" |
        countryregion=="US" |
        countryregion=="Singapore" |
        countryregion=="Antigua and Barbuda" |
        countryregion=="Bahamas" |
        countryregion=="Barbados" |
        countryregion=="Belize" |
        countryregion=="Cuba" | 
        countryregion=="Dominica" |
        countryregion=="Dominican Republic" |
        countryregion=="Grenada" |
        countryregion=="Guyana" |
        countryregion=="Haiti" |
        countryregion=="Jamaica" |
        countryregion=="Saint Kitts and Nevis" |
        countryregion=="Saint Lucia" |
        countryregion=="Saint Vincent and the Grenadines" |
        countryregion=="Suriname" |
        countryregion=="Trinidad and Tobago";
#delimit cr    
** UK, US are made up of groups of territories. Collapse and sum
** To give us 1 count of each metric per country per day
collapse (sum) confirmed deaths recovered, by(date countryregion)

** Add International ISO-3 codes for country name standardization
gen iso = ""
order iso, after(countryregion)
replace iso = "ATG" if countryregion=="Antigua and Barbuda"
replace iso = "BHS" if countryregion=="Bahamas"
replace iso = "BRB" if countryregion=="Barbados"
replace iso = "BLZ" if countryregion=="Belize"
replace iso = "CUB" if countryregion=="Cuba"
replace iso = "DMA" if countryregion=="Dominica"
replace iso = "DOM" if countryregion=="Dominican Republic"
replace iso = "GRD" if countryregion=="Grenada"
replace iso = "GUY" if countryregion=="Guyana"
replace iso = "HTI" if countryregion=="Haiti"
replace iso = "JAM" if countryregion=="Jamaica"
replace iso = "KNA" if countryregion=="Saint Kitts and Nevis"
replace iso = "LCA" if countryregion=="Saint Lucia"
replace iso = "VCT" if countryregion=="Saint Vincent and the Grenadines"
replace iso = "SUR" if countryregion=="Suriname"
replace iso = "TTO" if countryregion=="Trinidad and Tobago"
replace iso = "SGP" if countryregion=="Singapore"
replace iso = "KOR" if countryregion=="South Korea"
replace iso = "GBR" if countryregion=="UK"
replace iso = "USA" if countryregion=="US"

** Create internal numeric variable for countries 
encode countryregion, gen(country)

** METRIC: Days since first reported case
** bysort country: gen elapsed = _n 

** save "`datapath'\version01\2-working\jh_covide19_long", replace

** METRIC: Country populations
gen pop = . 
** SGP. Singapore
replace pop = 5850343 if iso=="SGP"
** USA. United States
replace pop = 331002647 if iso=="USA"
** UK. UNited Kingdom
replace pop = 67886004 if iso=="GBR"
** KOR. South Korea
replace pop = 51269183 if iso=="KOR"
** 14 CARICOM countries + Cuba + Dominican Republic
replace pop = 97928 if iso == "ATG"
replace pop = 393248 if iso == "BHS"
replace pop = 287371 if iso == "BRB"
replace pop = 397621 if iso == "BLZ"
replace pop = 11326616 if iso == "CUB"
replace pop = 71991 if iso == "DMA"
replace pop = 10847904 if iso == "DOM"
replace pop = 112519 if iso == "GRD"
replace pop = 786559 if iso == "GUY"
replace pop = 11402533 if iso == "HTI"
replace pop = 2961161 if iso == "JAM"
replace pop = 53192 if iso == "KNA"
replace pop = 183629 if iso == "LCA"
replace pop = 110947 if iso == "VCT"
replace pop = 586634 if iso == "SUR"
replace pop = 1399491 if iso == "TTO"
order pop, after(iso)

** Labelling of the internal country numeric
#delimit ; 
label define cname_ 1 "Antigua and Barbuda"
                    2 "The Bahamas"
                    3 "Barbados"
                    4 "Belize"
                    5 "Cuba"
                    6 "Dominica"
                    7 "Dominican Republic"
                    8 "Grenada"
                    9 "Guyana"
                    10 "Haiti"
                    11 "Jamaica"
                    12 "Saint Kitts and Nevis"
                    13 "Saint Lucia"
                    14 "Saint Vincent and the Grenadines"
                    15 "Singapore"
                    16 "South Korea"
                    17 "Suriname"
                    18 "Trinidad and Tobago"
                    19 "UK"
                    20 "USA"
                    ;
#delimit cr 

** Sort the dataset, ready for morning manual review 
sort iso date

*! -------------------------------------------
*! UPDATE EACH MORNING. TO DO THIS. 
*! (1) Stop code just before this code block 
*! (2) Open Stata dataset. Should see dataset oredered by country, then by date
*! (3) Look at last row for each country (last row per country)
*! (4) Find variable "Confirmed"
*! (5) Compare # in Stata to JHopkins web panel (LHS isting)
*! (6) Link for JHopkins panel (https://coronavirus.jhu.edu/map.html)
*! (7) Occassionally the JH number will be higher than our Stata number
*! (8) If so, complete one line of code as below
*! (9) FOUR ITEMS to alter:
*!              --> New #. Old #. iso code. Date.
replace confirmed = 163 if confirmed == 143 & iso=="JAM" & date==d(17apr2020)
replace confirmed = 173 if confirmed == 163 & iso=="JAM" & date==d(18apr2020)
*! -------------------------------------------

** Save the cleaned and restricted dataset
save "`datapath'\version01\2-working\jh_time_series_restricted", replace

