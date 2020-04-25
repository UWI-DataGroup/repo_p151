** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name				  covidprofiles_002_ecdc.do
    //  project:				        
    //  analysts:				  	  Ian HAMBLETON
    // 	date last modified	          25-APR-2020
    //  algorithm task			      Draw Open Access Data from ECDC (link below)

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
    log using "`logpath'\covidprofiles_002_ecdc", replace
** HEADER -----------------------------------------------------

** Data import from European Centre for Disease Control (ECDC, DAILY UPDATES)
** 24-APR-2020
** This will allow 2 things:
**   --> Formal check of ECDC against JHopkins, taking the latest available data
**   --> easier inclusion of the 4 UKOTS 
**   --> Cayman Islands, Turks and Caicos, Monserrat, BVI
** https://www.ecdc.europa.eu/sites/default/files/documents/COVID-19-geographic-disbtribution-worldwide.xlsx
** https://opendata.ecdc.europa.eu/covid19/casedistribution/csv
local URL_csv = "https://opendata.ecdc.europa.eu/covid19/casedistribution/csv"
local URL_xlsx = "https://www.ecdc.europa.eu/sites/default/files/documents/"
local URL_file = "COVID-19-geographic-disbtribution-worldwide.xlsx"
import excel using "`URL_xlsx'`URL_file'", first clear 
drop day month year geoId continentExp 

** DATE OF EVENTS
rename dateRep date 
format date %tdNN/DD/CCYY
** TEXT NAME FOR COUNTRY (STRING)
rename countriesAndTerritories countryregion 
** THREE DIGIT ISO COUNTRY CODE (UPPER CASE STRING)
rename countryterritoryCode iso 
** POPULATION
rename popData2018 pop
** CASES
rename cases confirmed 

** Save out the dataset for next DO file
save "`datapath'\version01\2-working\ecdc_time_series", replace


