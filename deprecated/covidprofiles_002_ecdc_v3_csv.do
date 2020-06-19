** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name				  covidprofiles_002_ecdc_v3.do
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
    log using "`logpath'\covidprofiles_002_ecdc_v3", replace
** HEADER -----------------------------------------------------

** Data import from European Centre for Disease Control (ECDC, DAILY UPDATES)
** 24-APR-2020

** This will allow 2 things:
**   --> Formal check of ECDC against JHopkins, taking the latest available data
**   --> easier inclusion of the 6 UKOTS 
**   --> Anguilla, Bermuda, Cayman Islands, Turks and Caicos, Montserrat, BVI
** https://www.ecdc.europa.eu/sites/default/files/documents/COVID-19-geographic-disbtribution-worldwide.xlsx
** https://opendata.ecdc.europa.eu/covid19/casedistribution/csv

** Last resort local download if URL access is not available
** This last happened on Monday 27-Apr-2020
** import excel using "`datapath'/version01/1-input/temp_ecdc/COVID-19-geographic-disbtribution-worldwide.xlsx", first clear
///local URL_csv = "https://opendata.ecdc.europa.eu/covid19/casedistribution/csv"
///local URL_xlsx = "https://www.ecdc.europa.eu/sites/default/files/documents/"
///local URL_file = "COVID-19-geographic-disbtribution-worldwide.xlsx"
///import excel using "`URL_xlsx'`URL_file'", first clear 

** Download Daily CSV file from ECDC using PYTHON (-pandas- data analytics library) import and transfer
python: import pandas as covid_csv
python: covid_df = covid_csv.read_csv('https://opendata.ecdc.europa.eu/covid19/casedistribution/csv')
cd "`datapath'\version01\1-input\"
python: covid_df.to_stata('covid_ecdc.dta')
use "`datapath'\version01\1-input\covid_ecdc", clear

** Data Preparation of Imported file, in preparation for combining with Johns hopkins dataset 
drop day month year geoId continentExp 
///drop index day month year geoId continentExp 

** DATE OF EVENTS
gen date = date(dateRep, "DMY", 2020)
format date %tdNN/DD/CCYY
drop dateRep 

** TEXT NAME FOR COUNTRY (STRING)
rename countriesAndTerritories countryregion 
** THREE DIGIT ISO COUNTRY CODE (UPPER CASE STRING)
rename countryterritoryCode iso 
** POPULATION
rename popData2018 pop
** CASES
rename cases confirmed 

** Save out the dataset for next DO file
order countryregion iso date pop confirmed deaths 
save "`datapath'\version01\2-working\ecdc_time_series", replace
