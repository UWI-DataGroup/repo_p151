** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name				  covidprofiles_001_readdata_owid_v5.do
    //  project:				        
    //  analysts:				  	  Ian HAMBLETON
    // 	date last modified	          09-Dec-2020
    //  algorithm task			      Draw Open Access Data from OWID / ECDC / JH

    ** General algorithm set-up
    version 16
    clear all
    macro drop _all
    set more 1
    set linesize 80

    ** Set working directories: this is for DATASET and LOGFILE import and export
    ** DATASETS to encrypted SharePoint folder
    local datapath "X:\The University of the West Indies\DataGroup - repo_data\data_p151"
    **local datapath "X:\The UWI - Cave Hill Campus\DataGroup - repo_data\data_p151" // SW to use this datapath when running the do-file
    
    ** LOGFILES to unencrypted OneDrive folder
    local logpath "X:\OneDrive - The University of the West Indies\repo_datagroup\repo_p151"
    **local logpath "X:\OneDrive - The UWI - Cave Hill Campus\repo_datagroup\repo_p151" // SW to use this logpath when running the do-file
    
    ** Reports and Other outputs
    local outputpath "X:\The University of the West Indies\DataGroup - DG_Projects\PROJECT_p151"
    **local outputpath "X:\The UWI - Cave Hill Campus\DataGroup - PROJECT_p151" // SW to use this outputpath when running do-file
   
    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\covidprofiles_001_readdata_owid_v5", replace

** HEADER -----------------------------------------------------

** PRIMARY DATA SOURCE
** DATA DRAWN FROM OWID
** https://ourworldindata.org/
** COVID datasets hosted on GitHub 
** https://github.com/owid/covid-19-data
** -------------------------------------
** SECONDARY DATA SOURCE
** European Centre for Disease Control
** https://opendata.ecdc.europa.eu/covid19/casedistribution/csv
** -------------------------------------
** SECONDARY DATA SOURCE
** Johns Hopkins 
** https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/
** -------------------------------------




** Data Source A1 - OWID full dataset
    python: import pandas as full_csv
    python: full_df = full_csv.read_csv('https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/owid-covid-data.csv')
    cd "`datapath'\version01\1-input\"
    python: full_df.to_stata('full_owid.dta')


