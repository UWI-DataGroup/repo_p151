** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name				  covidprofiles_run.do
    //  project:				        
    //  analysts:				  	  Ian HAMBLETON
    // 	date last modified	          10-MAY-2020
    //  algorithm task			      Run Do file batch

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
    log using "`logpath'\covidprofiles_run", replace
** HEADER -----------------------------------------------------

** Load data
** do "`logpath'\covidprofiles_002_ecdc_v3_excel"
** do "`logpath'\covidprofiles_002_ecdc_v3_excel_16may2020"
do "`logpath'\covidprofiles_002_ecdc_v3_csv"
do "`logpath'\covidprofiles_002_jhopkins_v3"
** Prepare data
do "`logpath'\covidprofiles_003_initialprep_v3"
do "`logpath'\covidprofiles_004_metrics_v3"
** Country Profiles
do "`logpath'\covidprofiles_005_country1_v3"
** Regional Profiles
do "`logpath'\covidprofiles_006_region1_v3"
do "`logpath'\covidprofiles_007_region2_v4"
** Slide Deck
do "`logpath'\covidprofiles_009_slides"
