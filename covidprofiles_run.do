** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name				  covidprofiles_run.do
    //  project:				        
    //  analysts:				  	  Ian HAMBLETON
    // 	date last modified	          24-JULY-2020
    //  algorithm task			      Run DO file batch

    ** General algorithm set-up
    version 16
    clear all
    macro drop _all
    set more 1
    set linesize 80

    ** Create folder with today's date as name 
    local c_date = c(current_date)
    local today = lower(subinstr("`c_date'", " ", "_", .))

    ** Set working directories: this is for DATASET and LOGFILE import and export
    ** DATASETS to encrypted SharePoint folder
    local datapath "X:\The University of the West Indies\DataGroup - repo_data\data_p151"
    **local datapath "X:\The UWI - Cave Hill Campus\DataGroup - repo_data\data_p151" // SW to use this datapath when running the do-file
    
    ** LOGFILES to unencrypted OneDrive folder
    local logpath "X:\OneDrive - The University of the West Indies\repo_datagroup\repo_p151"
    **local logpath "X:\OneDrive - The UWI - Cave Hill Campus\repo_datagroup\repo_p151" // SW to use this logpath when running the do-file
    
    ** Reports and Other outputs
    local outputpath "X:\The University of the West Indies\DataGroup - DG_Projects\PROJECT_p151"
    **local outputpath "X:\The UWI - Cave Hill Campus\DataGroup - PROJECT_p151" //SW to use this outputpath when running the do-file
    
    local syncpath "X:\The University of the West Indies\CaribData - Documents\COVID19Surveillance\PDF_Briefings\01 country_summaries\\`today'"
    **local syncpath "X:\The UWI - Cave Hill Campus\CaribData - Documents\COVID19Surveillance\PDF_Briefings\01 country_summaries\\`today'" //  SW to use this syncpathtpath when running the do-file
    
    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\covidprofiles_run", replace
** HEADER -----------------------------------------------------

** Load data
do "`logpath'\covidprofiles_001_readdata_owid_v6"
** Prepare data
do "`logpath'\covidprofiles_002_initialprep_v6"
do "`logpath'\covidprofiles_003_metrics_v5"
** Country Profiles
do "`logpath'\covidprofiles_004_country_v5"
** Regional Profiles
do "`logpath'\covidprofiles_005_region1_v5"
do "`logpath'\covidprofiles_006_region2_v5"
** Slide Deck
do "`logpath'\covidprofiles_007_slides"
** Weekly Summary
do "`logpath'\covidprofiles_008_weeklysummary_v5"

