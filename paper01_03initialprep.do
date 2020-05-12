** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					paper01_03initialprep.do
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
    log using "`logpath'\paper01_03initialprep", replace
** HEADER -----------------------------------------------------

** RUN covidprofiles_002_jhopkins.do BEFORE this algorithm
use "`datapath'\version02\2-working\paper01_jhopkins", clear 

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
** We keep 14 CARICOM countries:    --> ATG BHS BRB BLZ DMA GRD GUY HTI JAM KNA LCA VCT SUR TTO
** We keep 6 UKOTS                  --> AIA BMU VGB CYM MSR TCA 
** + Cuba                           --> CUB
** + Dominican Republic             --> DOM
#delimit ; 
keep if 
        /// 14 CARICOM countries + CUB + DOM
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
        countryregion=="Trinidad and Tobago" |
        /// 6 UKOTS 
        countryregion=="Anguilla" |
        countryregion=="Bermuda" |
        countryregion=="British Virgin Islands" |
        countryregion=="Cayman Islands" |
        countryregion=="Montserrat" | 
        countryregion=="Turks and Caicos Islands" |
        /// 10 potential comparators
        countryregion=="South Korea" |
        countryregion=="New Zealand" |
        countryregion=="Singapore" |
        countryregion=="Iceland" |
        countryregion=="Fiji" |
        countryregion=="Vietnam" |
        countryregion=="UK" |
        countryregion=="Italy" |
        countryregion=="Germany"|
        countryregion=="Sweden";
#delimit cr    

** UK, US are made up of groups of territories. Collapse and sum
** To give us 1 count of each metric per country per day
collapse (sum) confirmed deaths recovered, by(date countryregion)

** Add International ISO-3 codes for country name standardization
gen iso = ""
order iso, after(countryregion)
/// Caribbean (N=22)
replace iso = "AIA" if countryregion=="Anguilla"
replace iso = "ATG" if countryregion=="Antigua and Barbuda"
replace iso = "BHS" if countryregion=="Bahamas"
replace iso = "BRB" if countryregion=="Barbados"
replace iso = "BLZ" if countryregion=="Belize"
replace iso = "BMU" if countryregion=="Bermuda"
replace iso = "VGB" if countryregion=="British Virgin Islands"
replace iso = "CYM" if countryregion=="Cayman Islands"
replace iso = "CUB" if countryregion=="Cuba"
replace iso = "DMA" if countryregion=="Dominica"
replace iso = "DOM" if countryregion=="Dominican Republic"
replace iso = "GRD" if countryregion=="Grenada"
replace iso = "GUY" if countryregion=="Guyana"
replace iso = "HTI" if countryregion=="Haiti"
replace iso = "JAM" if countryregion=="Jamaica"
replace iso = "MSR" if countryregion=="Montserrat"
replace iso = "KNA" if countryregion=="Saint Kitts and Nevis"
replace iso = "LCA" if countryregion=="Saint Lucia"
replace iso = "VCT" if countryregion=="Saint Vincent and the Grenadines"
replace iso = "SUR" if countryregion=="Suriname"
replace iso = "TCA" if countryregion=="Turks and Caicos Islands"
replace iso = "TTO" if countryregion=="Trinidad and Tobago"
/// Comparators (N=10)
replace iso = "NZL" if countryregion=="New Zealand"
replace iso = "SGP" if countryregion=="Singapore"
replace iso = "ISL" if countryregion=="Iceland"
replace iso = "FJI" if countryregion=="Fiji"
replace iso = "VNM" if countryregion=="Vietnam"
replace iso = "KOR" if countryregion=="South Korea"
replace iso = "ITA" if countryregion=="Italy"
replace iso = "GBR" if countryregion=="UK"
replace iso = "DEU" if countryregion=="Germany"
replace iso = "SWE" if countryregion=="Sweden"

** Text - 3-digit iso
** Restrict to 20 Caribbean countries and territories + Cuba + DomRep
** We keep 14 CARICOM countries:    --> ATG BHS BRB BLZ DMA GRD GUY HTI JAM KNA LCA VCT SUR TTO
** We keep 6 UKOTS                  --> AIA BMU VGB CYM MSR TCA 
** + Cuba                           --> CUB
** + Dominican Republic             --> DOM
** GOOD COMPARATOR COUNTRIES
**      New Zealand
**      Singapore
**      Iceland
**      Fiji
**      South Korea 
**      Germany
** NOT-SO-GOOD COMPARATOR COUNTRIES
**      Italy
**      United Kingdom
#delimit ; 
    keep if 
        /// Caribbean (N=22)
        iso=="AIA" |
        iso=="ATG" |
        iso=="BHS" |
        iso=="BRB" |
        iso=="BLZ" |
        iso=="BMU" |
        iso=="VGB" |
        iso=="CYM" |
        iso=="CUB" |
        iso=="DMA" |
        iso=="DOM" |
        iso=="GRD" |
        iso=="GUY" |
        iso=="HTI" |
        iso=="JAM" |
        iso=="MSR" |
        iso=="KNA" |
        iso=="LCA" |
        iso=="VCT" |
        iso=="SUR" |
        iso=="TTO" |
        iso=="TCA" | 
        /// Comparators (N=10)
        iso=="NZL" |
        iso=="SGP" |
        iso=="ISL" |
        iso=="FJI" |
        iso=="VNM" |
        iso=="KOR" |
        iso=="ITA" |
        iso=="GBR" |
        iso=="DEU" |
        iso=="SWE";
#delimit cr   
label var iso "text: country 3-digit ISO code"


** Sort the dataset, ready for morning manual review 
sort iso date

** Rename JHopkins variables and save 
drop countryregion
order iso date confirmed deaths recovered
rename (confirmed deaths recovered)  =1
save "`datapath'\version02\2-working\paper01_jhopkins_clean", replace 


** ------------------------------------------------
** ECDC data
** ------------------------------------------------
use "`datapath'\version02\2-working\paper01_ecdc", clear
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
merge 1:1 iso date using "`datapath'\version02\2-working\paper01_jhopkins_clean"
sort iso date 
replace _merge = 3 if _merge==1 & _merge[_n-1]==3 & iso==iso[_n-1]
#delimit ;
    keep if (_merge==3 | _merge==2)                     | 
            (iso=="AIA" | iso=="BMU" | iso=="CYM" | iso=="VGB" | iso=="TCA" | iso=="HKG" | iso=="MSR");
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
** UKOTS
replace pop = 15002 if iso == "AIA"
replace pop = 62273 if iso == "BMU"
replace pop = 30237 if iso=="VGB"
replace pop = 65720 if iso == "CYM"
replace pop = 4999 if iso == "MSR"
replace pop = 5850343 if iso=="TCA"
** CARICOM
replace pop = 97928 if iso == "ATG"
replace pop = 393248 if iso == "BHS"
replace pop = 397621 if iso == "BLZ"
replace pop = 287371 if iso == "BRB"
replace pop = 71991 if iso == "DMA"
replace pop = 112519 if iso == "GRD"
replace pop = 786559 if iso == "GUY"
replace pop = 11402533 if iso == "HTI"
replace pop = 2961161 if iso == "JAM"
replace pop = 53192 if iso == "KNA"
replace pop = 183629 if iso == "LCA"
replace pop = 586634 if iso == "SUR"
replace pop = 1399491 if iso == "TTO"
replace pop = 110947 if iso == "VCT"
** Caribbean - Other
replace pop = 11326616 if iso == "CUB"
replace pop = 10847904 if iso == "DOM"
** Comparators
replace pop = 4822233 if iso == "NZL"
replace pop = 5850343 if iso=="SGP"
replace pop = 341250 if iso == "ISL"
replace pop = 896444 if iso == "FJI"
replace pop = 97338583 if iso == "VNM"
replace pop = 51269183 if iso=="KOR"
replace pop = 60461828 if iso == "ITA"
replace pop = 67886004 if iso=="GBR"
replace pop = 83783945 if iso == "DEU"
replace pop = 1009927 if iso == "SWE"
order iso_num pop, after(iso)

** Final CASE and DEATH variables

** CASES
** We choose to use ECDC data...!!
gen confirmed = confirmed2 
replace confirmed = confirmed1 if iso=="SUR" & confirmed1<=4
gen deaths = deaths2 
replace deaths = deaths1 if iso=="SUR" & deaths1==0
rename recovered1 recovered 

** Some early numbers are missing from the ECDC time series - replace with the JHopkins numbers
** This applies to:
** Antigua, Bahamas, Cuba
#delimit ; 
replace confirmed = confirmed1 if confirmed==. & confirmed1<. & 
            (iso=="ATG" | iso=="BHS" | iso=="BLZ" | iso=="CUB" | iso=="DMA" | 
             iso=="DOM" | iso=="FJI" | iso=="GRD" | iso=="GUY" | iso=="JAM" |
             iso=="KNA" | iso=="LCA" | iso=="NZL" | iso=="VCT" | iso=="VNM");
replace deaths = deaths1 if deaths==. & deaths1<. & 
            (iso=="ATG" | iso=="BHS" | iso=="BLZ" | iso=="CUB" | iso=="DMA" | 
             iso=="DOM" | iso=="FJI" | iso=="GRD" | iso=="GUY" | iso=="JAM" |
             iso=="KNA" | iso=="LCA" | iso=="NZL" | iso=="VCT" | iso=="VNM");
#delimit cr 

** Barbados need to impute backwards
replace confirmed = confirmed[_n+1] if confirmed==. & confirmed[_n+1]<. & iso=="BRB"

sort iso date 
** gen confirmed = confirmed1
** replace confirmed = confirmed2 if confirmed1==. & (iso==iso[_n-1]) & (confirmed2>confirmed1[_n-1])
** replace confirmed = confirmed1[_n-1] if confirmed==. & confirmed1[_n-1]<. & (iso==iso[_n-1]) 
** replace confirmed = confirmed2 if confirmed==. & confirmed1==. & confirmed2<. 
** DEATHS
** sort iso date 
** gen deaths = deaths1
** replace deaths = deaths2 if deaths1==. & (iso==iso[_n-1]) & (deaths2>deaths1[_n-1])
** replace deaths = deaths1[_n-1] if deaths==. & deaths1[_n-1]<. & (iso==iso[_n-1]) 
** replace deaths = deaths2 if deaths==. & deaths1==. & deaths2<. 
drop confirmed1 confirmed2 deaths1 deaths2 
sort iso date
///drop if date>date[_n+1] & iso!=iso[_n+1] & (iso!="AIA" & iso!="ANT" & iso!="BMU" & iso!="CYM" & iso!="VGB" & iso!="TCA" & iso!="HKG" & iso!="MSR")



** CARICOM, UKOT, OTHER, COMPARATOR
gen cgroup = .
replace cgroup = 1 if iso=="ATG" | iso=="BHS" | iso=="BRB" | iso=="BLZ" | iso=="DMA" | iso=="GRD" | iso=="GUY" | iso=="HTI" | iso=="JAM" | iso=="KNA" | iso=="LCA" | iso=="VCT" | iso=="SUR" | iso=="TTO"
replace cgroup = 2 if iso=="AIA" | iso=="BMU" | iso=="VGB" | iso=="CYM" | iso=="MSR" | iso=="TCA"
replace cgroup = 3 if iso=="CUB" | iso=="DOM"
replace cgroup = 4 if iso=="NZL" | iso=="SGP" | iso=="ISL" | iso=="FJI" | iso=="VNM" | iso=="KOR" | iso=="ITA" | iso=="GBR" | iso=="DEU" | iso=="SWE"
label define cgroup_ 1 "caricom" 2 "ukot" 3 "car-other" 4 "comparator"
label values cgroup cgroup_ 

** Save the cleaned and restricted dataset
order date iso iso_num cgroup pop confirmed deaths recovered
save "`datapath'\version02\2-working\paper01_covid", replace
    