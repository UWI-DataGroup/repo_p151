** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					covidprofiles_003_initialprep_v3.do
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
    log using "`logpath'\covidprofiles_003_initialprep_v3", replace
** HEADER -----------------------------------------------------

** RUN covidprofiles_002_jhopkins.do BEFORE this algorithm
use "`datapath'\version01\2-working\jh_time_series", clear 

** JOHNS HOKINS DATABASE CORRECTIONS TO COUNTRY NAMES
** UK has 2 names in database
replace countryregion = "UK" if countryregion=="United Kingdom"
** Bahamas has 3 names in database 
replace countryregion = "Bahamas" if countryregion=="Bahamas, The" | countryregion=="The Bahamas"
** South Korea has 2 names
replace countryregion = "South Korea" if countryregion=="Korea, South" 
** Hong Kong has 2 names
replace countryregion = "Hong Kong" if countryregion=="Hong Kong SAR" 
replace countryregion = "Hong Kong" if countryregion=="China" & combined_key=="Hong Kong, China" 


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
        countryregion=="Hong Kong" |
        countryregion=="Iceland" |
        countryregion=="Jamaica" |
        countryregion=="New Zealand" |
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
replace iso = "HKG" if countryregion=="Hong Kong"
replace iso = "ISL" if countryregion=="Iceland"
replace iso = "JAM" if countryregion=="Jamaica"
replace iso = "NZL" if countryregion=="New Zealand"
replace iso = "KNA" if countryregion=="Saint Kitts and Nevis"
replace iso = "LCA" if countryregion=="Saint Lucia"
replace iso = "VCT" if countryregion=="Saint Vincent and the Grenadines"
replace iso = "SUR" if countryregion=="Suriname"
replace iso = "TTO" if countryregion=="Trinidad and Tobago"
replace iso = "SGP" if countryregion=="Singapore"
replace iso = "KOR" if countryregion=="South Korea"
replace iso = "GBR" if countryregion=="UK"
replace iso = "USA" if countryregion=="US"


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

** 17 April 2020
replace confirmed = 163 if confirmed == 143 & iso=="JAM" & date==d(17apr2020)

** 18-Apr-2020
replace confirmed = 173 if confirmed == 163 & iso=="JAM" & date==d(18apr2020)

** 19-Apr-2020
replace confirmed = 60 if confirmed == 55 & iso=="BHS" & date==d(19apr2020)
replace confirmed = 196 if confirmed == 173 & iso=="JAM" & date==d(19apr2020)
replace confirmed = 15 if confirmed == 14 & iso=="KNA" & date==d(19apr2020)

** 20-Apr-2020
replace confirmed = 66 if confirmed == 65 & iso=="GUY" & date==d(20apr2020)

** 21-Apr-2020
replace confirmed = 24 if confirmed == 23 & iso=="ATG" & date==d(21apr2020)
replace confirmed = 58 if confirmed == 57 & iso=="HTI" & date==d(21apr2020)

** 22-Apr-2020
replace confirmed = 76 if confirmed == 75 & iso=="BRB" & date==d(22apr2020)
replace confirmed = 252 if confirmed == 233 & iso=="JAM" & date==d(22apr2020)

** 23-Apr-2020
replace confirmed = 14 if confirmed == 13 & iso=="VCT" & date==d(23apr2020)

** 24-Apr-2020
** NO CHANGES

** 25-Apr-2020
** NO CHANGES

** 26-Apr-2020
** NO CHANGES

*! -------------------------------------------

** Rename JHopkins variables and save 
drop countryregion
order iso date confirmed deaths recovered
rename (confirmed deaths recovered)  =1
save "`datapath'\version01\2-working\jh_time_series_clean", replace 


** ------------------------------------------------
** ECDC data
** ------------------------------------------------
use "`datapath'\version01\2-working\ecdc_time_series"
rename (confirmed deaths pop)  =2
drop pop2 

** ECDC cleaning - adding a few ISO codes
replace iso = "AIA" if iso=="" & countryregion=="Anguilla"
replace iso = "FLK" if iso=="" & countryregion=="Falkland_Islands_(Malvinas)"
replace iso = "ANT" if iso=="" & countryregion=="Bonaire, Saint Eustatius and Saba"
drop countryregion 

** Create cumulative CASE and DEATH data for ecdc
sort iso date
rename confirmed2 temp2 
bysort iso: gen confirmed2 = sum(temp2)
drop temp2
sort iso date
rename deaths2 temp2 
bysort iso: gen deaths2 = sum(temp2)
drop temp2
sort iso date

** Link the two datasets and bring across jhopkins data (#1) to ecdc data (#2)
** Keep all countries in both datasets +
** HKG -- HONG KONG from jhopkins
** CYM -- CAYMAN ISLANDS from ECDC
** VGB -- BVI from ECDC
** AIA -- ANGUILLA from ECDC
** TCA -- TURKS and CAICOS from ECDC
** ANT -- Bonaire, Saint Eustatius and Saba from ECDC
** BMU - Bermuda
merge 1:1 iso date using "`datapath'\version01\2-working\jh_time_series_clean"
sort iso date 
replace _merge = 3 if _merge==1 & _merge[_n-1]==3 & iso==iso[_n-1]
#delimit ;
    keep if (_merge==3 | _merge==2)                     | 
            (iso=="AIA" | iso=="ANT" | iso=="BMU" | iso=="CYM" | iso=="VGB" | iso=="TCA" | iso=="HKG" | iso=="MSR");
#delimit cr
drop _merge


order date iso confirmed1 confirmed2 deaths1 deaths2 recovered1


** ---------------------------------------------------------
** FINAL PREPARATION
** ---------------------------------------------------------

** Create internal numeric variable for countries 
encode iso, gen(iso_num)


** METRIC: Country populations
** SOURCE UN WPP 2019
gen pop = . 
replace pop = 15002 if iso == "AIA"
replace pop = 26221 if iso == "ANT"
replace pop = 97928 if iso == "ATG"
replace pop = 393248 if iso == "BHS"
replace pop = 397621 if iso == "BLZ"

replace pop = 62273 if iso == "BMU"
replace pop = 287371 if iso == "BRB"
replace pop = 11326616 if iso == "CUB"
replace pop = 65720 if iso == "CYM"
replace pop = 71991 if iso == "DMA"

replace pop = 10847904 if iso == "DOM"
replace pop = 67886004 if iso=="GBR"
replace pop = 112519 if iso == "GRD"
replace pop = 786559 if iso == "GUY"
replace pop = 7496988 if iso == "HKG"

replace pop = 11402533 if iso == "HTI"
replace pop = 341250 if iso == "ISL"
replace pop = 2961161 if iso == "JAM"
replace pop = 53192 if iso == "KNA"
replace pop = 51269183 if iso=="KOR"

replace pop = 183629 if iso == "LCA"
replace pop = 4999 if iso == "MSR"
replace pop = 4822233 if iso == "NZL"
replace pop = 5850343 if iso=="SGP"
replace pop = 586634 if iso == "SUR"

replace pop = 5850343 if iso=="TCA"
replace pop = 1399491 if iso == "TTO"
replace pop = 331002647 if iso=="USA"
replace pop = 110947 if iso == "VCT"
replace pop = 30237 if iso=="VGB"
order iso_num pop, after(iso)

** Final CASE and DEATH variables

** CASES
sort iso date 
gen confirmed = confirmed1
replace confirmed = confirmed2 if confirmed1==. & (iso==iso[_n-1]) & (confirmed2>confirmed1[_n-1])
replace confirmed = confirmed1[_n-1] if confirmed==. & confirmed1[_n-1]<. & (iso==iso[_n-1]) 
replace confirmed = confirmed2 if confirmed==. & confirmed1==. & confirmed2<. 
** DEATHS
sort iso date 
gen deaths = deaths1
replace deaths = deaths2 if deaths1==. & (iso==iso[_n-1]) & (deaths2>deaths1[_n-1])
replace deaths = deaths1[_n-1] if deaths==. & deaths1[_n-1]<. & (iso==iso[_n-1]) 
replace deaths = deaths2 if deaths==. & deaths1==. & deaths2<. 

drop confirmed1 confirmed2 deaths1 deaths2 
sort iso date
** drop if date>date[_n+1] & iso!=iso[_n+1]

rename recovered1 recovered 

** Save the cleaned and restricted dataset
save "`datapath'\version01\2-working\jh_time_series_restricted", replace
