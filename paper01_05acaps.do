** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					paper01_05acaps.do
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
    log using "`logpath'\paper01_05acaps", replace
** HEADER -----------------------------------------------------

local URL_xlsx = "https://www.acaps.org/sites/acaps/files/resources/files/"
local URL_file = "acaps_covid19_goverment_measures_dataset.xlsx"
local URL_file = "acaps_covid19_goverment_measures_dataset_0.xlsx"
import excel using "`URL_xlsx'`URL_file'", first clear sheet("Database")

drop ADMIN_LEVEL_NAME PCODE NON_COMPLIANCE SOURCE SOURCE_TYPE LINK ENTRY_DATE Alternativesource 
cap drop S T U V W

** Internal unique ACAPS ID 
rename ID aid 
label var aid "ACAPS internal ID"

** Text country name - for visualisations
rename COUNTRY country
label var country "Text: country name"

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
** NOT-SO-GOOD COMPARATOR COUNTRIES
**      Italy
**      United Kingdom
**      Spain
**      United States
rename ISO iso 
#delimit ; 
    keep if 
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
        iso=="NZL" |
        iso=="SGP" |
        iso=="ISL" |
        iso=="FJI" |
        iso=="VNM" |
        iso=="KOR" |
        iso=="ITA" |
        iso=="GBR" |
        iso=="ESP" |
        iso=="USA" ;
#delimit cr   
label var iso "text: country 3-digit ISO code"

** Region
rename REGION region
label var region "Country region"

** LOG TYPE
gen logtype = . 
replace logtype = 1 if LOG_TYPE == "Introduction / extension of measures"
replace logtype = 2 if LOG_TYPE == "Phase-out measure"
label var logtype "NPI introduction or Phase-out"
label define logtype_ 1 "introduction/extension" 2 "phase-out"
label values logtype logtype_ 
drop LOG_TYPE
order logtype, after(region)

** Intervention category 
groups CATEGORY, show(f p) 
gen icat = . 
replace icat = 1 if CATEGORY == "Governance and socio-economic measures"
replace icat = 2 if CATEGORY == "Lockdown"
replace icat = 3 if CATEGORY == "Movement restrictions"
replace icat = 4 if CATEGORY == "Public health measures"
replace icat = 5 if CATEGORY == "Social distancing"
label var icat "Intervention category"
order icat, after(logtype)

#delimit ; 
label define icat_  1 "governance"
                    2 "lockdown"
                    3 "restrict movement"
                    4 "general public health"
                    5 "social distancing";
#delimit cr 
label values icat icat_ 

** CODING THE INTERVENTION ONTOLOGY
groups MEASURE, show(f p) 
replace MEASURE = ustrtrim(strtrim(MEASURE)) 

gen imeasure = . 
** Movement Restrictions
replace imeasure = 1 if MEASURE == "Additional health/documents requirements upon arrival"
replace imeasure = 2 if MEASURE == "Border checks"
replace imeasure = 3 if MEASURE == "Border closure"
replace imeasure = 4 if MEASURE == "Complete border closure"
replace imeasure = 5 if MEASURE == "Checkpoints within the country"
replace imeasure = 6 if MEASURE == "International flights suspension"
replace imeasure = 7 if MEASURE == "Domestic travel restrictions"
replace imeasure = 8 if MEASURE == "Visa restrictions"
replace imeasure = 9 if MEASURE == "Curfews"
replace imeasure = 10 if MEASURE == "Surveillance and monitoring"

** Public Health Measures
replace imeasure = 11 if MEASURE == "Awareness campaigns"
replace imeasure = 12 if MEASURE == "Isolation and quarantine policies"
replace imeasure = 13 if MEASURE == "General recommendations"
replace imeasure = 14 if MEASURE == "Health screenings in airports and border crossings"
replace imeasure = 15 if MEASURE == "Obligatory medical tests not related to COVID-19"
replace imeasure = 16 if MEASURE == "Psychological assistance and medical social work"
replace imeasure = 17 if MEASURE == "Mass population testing"
replace imeasure = 18 if MEASURE == "Strengthening the public health system"
replace imeasure = 19 if MEASURE == "Testing policy"
replace imeasure = 20 if MEASURE == "Amendments to funeral and burial regulations"
replace imeasure = 21 if MEASURE == "Requirement to wear protective gear in public"
replace imeasure = 22 if MEASURE == "Other public health measures enforced"

** Government and Socioeconomic Measures
replace imeasure = 23 if MEASURE == "Economic measures"
replace imeasure = 24 if MEASURE == "Emergency administrative structures activated or established"
replace imeasure = 25 if MEASURE == "Limit product imports/exports"
replace imeasure = 26 if MEASURE == "State of emergency declared"
replace imeasure = 27 if MEASURE == "Military deployment"

** Social Distancing
replace imeasure = 28 if MEASURE == "Limit public gatherings" | MEASURE == "limit public gatherings"
replace imeasure = 29 if MEASURE == "Public services closure"
replace imeasure = 30 if MEASURE == "Changes in prison-related policies"
replace imeasure = 31 if MEASURE == "Schools closure"
replace imeasure = 32 if MEASURE == "Partial lockdown"
replace imeasure = 33 if MEASURE == "Full lockdown"
replace imeasure = 34 if MEASURE == "Lockdown of refugee/IDP camps or other minorities"
label var imeasure "Intervention measure"
order imeasure, after(icat)


#delimit ; 
label define imeasure_  
         1  "Additional health/documents requirements upon arrival"
         2  "Border checks"
         3  "Border closure"
         4  "Complete border closure"
         5  "Checkpoints within the country"
         6  "International flights suspension"
         7  "Domestic travel restrictions"
         8  "Visa restrictions"
         9  "Curfews"
         10 "Surveillance and monitoring"

         11 "Awareness campaigns"
         12 "Isolation and quarantine policies"
         13 "General recommendations"
         14 "Health screenings in airports"
         15 "Obligatory non-COVID medical tests"
         16 "Psychological assistance"
         17 "Mass population testing"
         18 "Strengthening the PH system"
         19 "Testing policy"
         20 "Amendments to funeral regs"
         21 "Protective gear in public"
         22 "Other public health measures"

         23 "Economic measures"
         24 "Emergency admin structures"
         25 "Limit product imports/exports"
         26 "State of emergency declared"
         27 "Military deployment"

         28 "Limit public gatherings"
         29 "Public services closure"
         30 "Changes in prison policies"
         31 "Schools closure"
         32 "Partial lockdown"
         33 "Full lockdown"
         34 "Lockdown of refugee/IDP camps";
#delimit cr 
label values imeasure imeasure_
/*drop CATEGORY MEASURE 
/*
** Population group targeted
replace TARGETED_POP_GROUP = ustrtrim(strtrim(TARGETED_POP_GROUP)) 
gen tgroup = .
replace tgroup = 0 if TARGETED_POP_GROUP=="No"
replace tgroup = 1 if TARGETED_POP_GROUP=="Yes"
label define tgroup_ 0 "population-wide" 1 "targeted"
label values tgroup tgroup_ 
drop TARGETED_POP_GROUP
order tgroup, after(imeasure)
label var tgroup "NPI uses a targeted group?"

** Comment
rename COMMENT comment
label var comment "Comment on exact nature of NPI"

** DATE
rename DATE_IMPLEMENTED donpi
label var donpi "Date of NPI"
order donpi, after(region)


** NEW GROUPING WITH CARIBBEAN RELEVANCE



** Save out the dataset for next DO file
save "`datapath'\version02\2-working\paper01_acaps", replace

