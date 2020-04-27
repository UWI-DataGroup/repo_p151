** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					cdema_simulation_002.do
    //  project:				        Preparing BB population data
    //  analysts:				       	Ian HAMBLETON
    // 	date last modified	            24-MAR-2020
    //  algorithm task			        Preparing simulation dataset for all Caribbean countries

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
    local outputpath "X:\The University of the West Indies\DataGroup - DG_Projects\PROJECT_p151\05_Outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\cdema_simulation_002", replace
** HEADER -----------------------------------------------------

use "`datapath'/version01/2-working/population_001.xlsx", clear 

** --------------------------------------------
** CARICOM membership 
** --------------------------------------------
** FULL MEMBER ( * need population data)
** Antigua 
** Bahamas
** Barbados 
** Belize *
** Dominica *
** Grenada 
** Guyana *
** Haiti 
** Jamaica 
** Monserrat 
** Saint Kitts and Nevis * 
** Saint Lucia 
** Saint Vincent 
** Suriname * 
** Trinidad and Tobago 
** 
** ASSOCIATE 
** Anguilla *
** Bermuda *
** BVI *
** Cayman Islands * 
** Turks and Caicos Islands * 
** 
** OBSERVERS 
** Aruba 
** Colombia 
** Curacao 
** Dominican Republic 
** Mexico 
** Puerto Rico 
** Sint Maarten 
** Venezuela
** --------------------------------------------

** Country Labels 
#delimit ;
label define cid_   28 "Antigua and Barbuda"
                    44 "Bahamas"
                    52 "Barbados"
                    84 "Belize"
                    192 "Cuba"
                    214 "Dominican Reublic"
                    308 "Grenada"
                    312 "Guadeloupe"
                    328 "Guyana"
                    332 "Haiti"
                    388 "Jamaica"
                    474 "Martinique"
                    531 "Curacao"
                    533 "Aruba"
                    630 "Puerto Rico"
                    662 "Saint Lucia"
                    670 "Saint Vincent"
                    740 "Suriname"
                    780 "Trinidad and Tobago"
                    850 "USVI"
                    915 "Caribbean";
#delimit cr 
label values cid cid_ 

** Don't need the following for now 
** Cuba 
drop if cid==192 
** Dominican Republic 
drop if cid==214 
** Guadeloupe
drop if cid==312 
** Martinique 
drop if cid==474 
** Curacao
drop if cid==531 
** Aruba
drop if cid==533
** Puerto Rico
drop if cid==630 
** USVI
drop if cid==850 

** Multiply by 1000
gen gtot = na * 1000

** Country population total 
bysort cid: egen age_tot = sum(gtot)

** % population tabulations for SEIR modelling
preserve 
    collapse (sum) gtot (mean) mage_tot = age_tot , by(cid age2) 
    gen page2 = (gtot/mage_tot)*100 
    tabdisp age2 cid, cell(page2) format(%9.1f)
restore

** % population tabulations for IMPERIAL COLLEGE MODELLING
preserve 
    collapse (sum) gtot (mean) mage_tot = age_tot , by(cid age1) 
    gen page1 = (gtot/mage_tot)*100 
    tabdisp age1 cid, cell(page1) format(%9.1f)
restore

** % population tabulations for RESOURCE MODELLING
preserve 
    collapse (sum) gtot (mean) mage_tot = age_tot , by(cid age3) 
    gen page3 = (gtot/mage_tot)*100 
    tabdisp age3 cid, cell(page3) format(%9.1f)
restore

** Numbers 70 and older
bysort cid: egen seventy_plus = sum(gtot) if agey>=70 

** TABLE OF TOTAL POPULATIONS
preserve 
    collapse (sum) gtot , by(cid) 
    tabdisp cid, cell(gtot) format(%12.0fc)
restore

** TABLE OF OVER 70s
gen over70i = 0
replace over70i = 1 if agey>=70 
preserve 
    collapse (sum) gtot , by(cid over70i) 
    tabdisp cid over70i, cell(gtot) format(%12.0fc)
restore

