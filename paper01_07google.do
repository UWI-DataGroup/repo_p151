** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					paper01_07google.do
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
    log using "`logpath'\paper01_07google", replace
** HEADER -----------------------------------------------------

** Import Daily CSV file from Google
** https://www.gstatic.com/covid19/mobility/Global_Mobility_Report.csv?cachebust=a88b56a24e1a1e25


cd "`datapath'\version02\1-input\"
import delimited using "Global_Mobility_Report_20200511.csv", clear 

** RESTRICT TO SELECTED COUNTRIES
** Keep UK, USA, Sth Korea, Singapore as comparators. Then keep all Caribbean nations
**      Antigua and Barbuda
**      The Bahamas
**      Barbados
**      Belize
**      Cuba                                --> not in db
**      Dominica                            --> not in db
**      Dominican Republic
**      Grenada                             --> not in db         
**      Guyana                              --> not in db
**      Haiti
**      Jamaica
**      Saint Kitts and Nevis               --> not in db
**      Saint Lucia                         --> not in db
**      Saint Vincent and the Grenadines    --> not in db
**      Suriname                            --> not in db
**      Trinidad and Tobago
#delimit ; 
keep if 
        /// Available Caribbean countries (N=8)
        country_region=="Antigua and Barbuda" |
        country_region=="The Bahamas" |
        country_region=="Barbados" |
        country_region=="Belize" |
        country_region=="Dominican Republic" |
        country_region=="Haiti" |
        country_region=="Jamaica" |
        country_region=="Trinidad and Tobago" |
        /// Comparators (N=7)
        country_region=="New Zealand" |
        country_region=="Singapore" |
        country_region=="Fiji" |
        country_region=="United Kingdom" |
        country_region=="Vietnam" |
        country_region=="Italy" |
        country_region=="Germany" |
        country_region=="Sweden";
#delimit cr    

** Add ISO for each country
gen iso3 = ""
    replace iso3="ATG" if country_region=="Antigua and Barbuda"
    replace iso3="BHS" if country_region=="The Bahamas"
    replace iso3="BRB" if country_region=="Barbados"
    replace iso3="BLZ" if country_region=="Belize"
    replace iso3="DOM" if country_region=="Dominican Republic"
    replace iso3="HTI" if country_region=="Haiti"
    replace iso3="JAM" if country_region=="Jamaica"
    replace iso3="TTO" if country_region=="Trinidad and Tobago"

    replace iso3="NZL" if country_region=="New Zealand"
    replace iso3="SGP" if country_region=="Singapore"
    replace iso3="FJI" if country_region=="Fiji"
    replace iso3="GRB" if country_region=="United Kingdom"
    replace iso3="VNM" if country_region=="Vietnam"
    replace iso3="ITA" if country_region=="Italy"
    replace iso3="DEU" if country_region=="Germany"
    replace iso3="SWE" if country_region=="Sweden"
order iso3, after(country_region_code)

** Renaming
rename country_region_code iso2
rename country_region country 
rename sub_region_1 region1 
rename sub_region_2 region2 
rename retail_and_recreation_percent_ch orig_retail
rename grocery_and_pharmacy_percent_cha orig_grocery
rename parks_percent_change_from_baseli orig_parks 
rename transit_stations_percent_change_ orig_transit 
rename residential_percent_change_from_ orig_residential
rename workplaces_percent_change_from_b orig_work
order iso2 iso3 country date orig_* region1 region2 

** Date
rename date temp1
gen date = date(temp1, "YMD")
order date, after(country)
format date %td 
drop temp1 

** DROP REGIONAL DATA
drop if iso3=="BRB" & region1!="" 
drop if iso3=="ESP" & region1!="" 
drop if iso3=="GRB" & region1!="" 
drop if iso3=="ITA" & region1!="" 
drop if iso3=="NZL" & region1!="" 
drop if iso3=="USA" & region1!=""
drop region1 region2
rename iso3 iso 

** Save out the dataset for next DO file
save "`datapath'\version02\2-working\paper01_google", replace
