** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					cdema_simulation_001.do
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
    log using "`logpath'\cdema_simulation_001", replace
** HEADER -----------------------------------------------------

** Population data
** SOURCE: UN WPP (2019)
import excel using "`datapath'/version01/1-input//WPP2019_INT_F03_1_POPULATION_BY_AGE_ANNUAL_BOTH_SEXES.xlsx", sheet("estimates_irh") first cellrange(a1:de18106)
drop Variant Notes

** restrict to latest year
keep if year==2020
drop year



** Keep Caribbean countries (2020 esimates)
keep if parent==915 | cid==915 | cid==84 | cid==328 | cid==740 
drop parent Index 

#delimit ;
local ages "a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16 a17 a18 a19 a20 a21 a22 a23 a24 a25 a26 a27 a28 a29 a30
                a31 a32 a33 a34 a35 a36 a37 a38 a39 a40 a41 a42 a43 a44 a45 a46 a47 a48 a49 a50 a51 a52 a53 a54 a55 a56 a57 a58 a59
                a60 a61 a62 a63 a64 a65 a66 a67 a68 a69 a70 a71 a72 a73 a74 a75 a76 a77 a78 a79 a80 a81 a82 a83 a84 a85 a86 a87 a88 
                a89 a90 a91 a92 a93 a94 a95 a96 a97 a98 a99 a100";
#delimit cr 

** Convert ages to numeric
foreach var of local ages {
    gen n`var' = real(`var')
    drop `var' 
}

** Reshape to long 
reshape long na, i(cid) j(agey)

** Age Grouping 1 (FOR IMPERIAL ARTICLE)
** NINE age groups (10-year groups mostly)
**      0-9 
**      10-19 
**      20-29
**      30-39
**      40-49
**      50-59
**      60-69
**      70-79
**      80+
gen age1 = .
replace age1 = 1 if agey<=9 
replace age1 = 2 if agey>=10 & agey<=19 
replace age1 = 3 if agey>=20 & agey<=29 
replace age1 = 4 if agey>=30 & agey<=39 
replace age1 = 5 if agey>=40 & agey<=49 
replace age1 = 6 if agey>=50 & agey<=59 
replace age1 = 7 if agey>=60 & agey<=69 
replace age1 = 8 if agey>=70 & agey<=79 
replace age1 = 9 if agey>=80 
label define age1_ 1 "0-9" 2 "10-19" 3 "20-29" 4 "30-39" 5 "40-49" 6 "50-59" 7 "60-69" 8 "70-79" 9 "80+" 
label values age1 age1_ 


** Age Grouping 2 (FOR CDC SEIR modelling)
** NINE age groups 
**      0-4 yrs
**      5-18 yrs
**      19-49 yrs
**      50-64 yrs
**      65-69 yrs
**      70-74 yrs
**      75-79 yrs
**      80-84 yrs
**      85+ yrs
gen age2 = .
replace age2 = 1 if agey<=4 
replace age2 = 2 if agey>=5 & agey<=18 
replace age2 = 3 if agey>=19 & agey<=49 
replace age2 = 4 if agey>=50 & agey<=64 
replace age2 = 5 if agey>=65 & agey<=69 
replace age2 = 6 if agey>=70 & agey<=74 
replace age2 = 7 if agey>=75 & agey<=79 
replace age2 = 8 if agey>=80 & agey<=84 
replace age2 = 9 if agey>=85 
label define age2_ 1 "0-4" 2 "5-18" 3 "19-49" 4 "50-64" 5 "65-69" 6 "70-74" 7 "75-79" 8 "80-84" 9 "85+" 
label values age2 age2_ 

** Age Grouping 3 (FOR R COVID RESOURCE MODELLING)
** SEVEN age groups 
**      0-19 yrs
**      20-44 yrs
**      45-54 yrs
**      55-64 yrs
**      65-74 yrs
**      75-84 yrs
**      85+ yrs
gen age3 = .
replace age3 = 1 if agey<=19 
replace age3 = 2 if agey>=20 & agey<=44 
replace age3 = 3 if agey>=45 & agey<=54 
replace age3 = 4 if agey>=55 & agey<=64 
replace age3 = 5 if agey>=65 & agey<=74 
replace age3 = 6 if agey>=75 & agey<=84 
replace age3 = 7 if agey>=85 
label define age3_ 1 "0-19" 2 "20-44" 3 "45-54" 4 "55-64" 5 "65-74" 6 "75-84" 7 "85+" 
label values age3 age3_ 

** Save the population dataset
label data "Caribbean country populations (2020)" 
save "`datapath'/version01/2-working/population_001.xlsx", replace 
