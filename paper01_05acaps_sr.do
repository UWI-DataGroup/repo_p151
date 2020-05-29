** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					paper01_05acaps_sr.do
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
    log using "`logpath'\paper01_05acaps_sr", replace
** HEADER -----------------------------------------------------

tempfile caricomplus ukots 
import excel using "`datapath'\version02\1-input\\ukots_acaps_hambleton_18may2020_MM.xlsx", first clear sheet("IRH_formatted")
replace MEASURE = "Additional health/documents requirements upon arrival" if MEASURE==`"Additional health/documents requirements upon arrival""'
replace MEASURE = "Curfews" if MEASURE=="curfews"

rename DATE_IMPLEMENTED_TEXT temp1
drop MEASURE_ORIG DATE_IMPLEMENTED_ORIG DATE_IMPLEMENTED
gen DATE_IMPLEMENTED = date(temp1, "DMY")
format DATE_IMPLEMENTED %td 
save `ukots' 

local URL_xlsx = "https://www.acaps.org/sites/acaps/files/resources/files/"
local URL_file = "acaps_covid19_goverment_measures_dataset.xlsx"
local URL_file = "acaps_covid19_government_measures_dataset.xlsx"
local URL_file = "acaps_covid19_government_measures_dataset_20200512.xlsx"
cap import excel using "`URL_xlsx'`URL_file'", first clear sheet("Database")
import excel using "`datapath'\version02\1-input\\`URL_file'", first clear sheet("Database")
drop ADMIN_LEVEL_NAME PCODE NON_COMPLIANCE SOURCE SOURCE_TYPE ENTRY_DATE Alternativesource 
drop if ID==.
cap drop S T U V W
save `caricomplus', replace
append using `ukots' , force

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
        /// Comparators (N=9)
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
drop CATEGORY MEASURE 

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


** -----------------------------------------------------
** SIDS-specific categorisation of MEASURES
** -----------------------------------------------------

** Group 1. Control movement into country
** LO      1  "Additional health/documents requirements upon arrival"
** LO      2  "Border checks"
** HI      3  "Border closure"
** HI      4  "Complete border closure"
** HI      6  "International flights suspension"
** HI      8  "Visa restrictions"
** LO      14 "Health screenings in airports"

** Group 2. Control movement in country
** LO      5  "Checkpoints within the country"
** LO      7  "Domestic travel restrictions"
** LO      9  "Curfews"
** LO      32 "Partial lockdown"
** HI      33 "Full lockdown"

** Group 3. Control of gatherings 
**       28 "Limit public gatherings"
**       29 "Public services closure"
**       31 "Schools closure"

** Group 4. Control of infection
**       10 "Surveillance and monitoring"
**       11 "Awareness campaigns"
**       12 "Isolation and quarantine policies"
**       17 "Mass population testing"
gen sidcon = .
replace sidcon = 1 if imeasure==1 | imeasure==2 | imeasure==3 | imeasure==4 | imeasure==6 | imeasure==8 | imeasure==14
replace sidcon = 2 if imeasure==5 | imeasure==7 | imeasure==9 | imeasure==32 | imeasure==33 
replace sidcon = 3 if imeasure==28 | imeasure==29 | imeasure==31
replace sidcon = 4 if imeasure==10 | imeasure==11 | imeasure==12 | imeasure==17
label var sidcon "Specific grouping of control measures in SIDS"
label define sidcon_ 1 "control movement into" 2 "control movement in" 3 "control gatherings" 4 "control infection"
label values sidcon sidcon_ 
order sidcon, after(imeasure)

** Complete DATE information 
replace donpi = donpi[_n-1] if donpi==. & iso==iso[_n-1] 
replace donpi = donpi[_n+1] if donpi==. & iso==iso[_n+1] 

** Keep only those NPIs in our 4 SIDCON categories
drop LINK tgroup
///keep if sidcon<.

** First date of implementation in each SIDCON category
sort iso sidcon donpi 
by iso sidcon: egen mind = min(donpi)
format mind %td
order mind, after(donpi) 

** Date of Curfew
sort iso sidcon donpi 
gen docurf1 = donpi if imeasure==9
by iso : egen docurf = min(docurf1)
format docurf %td
gen curfi1 = 0
replace curfi1 = 1 if imeasure==9
by iso : egen curfi = max(curfi1)
label define curfi_ 0 "no curfew" 1 "curfew"
label values curfi curfi_ 
drop docurf1 curfi1

** Date of PARTIAL lockdown
sort iso sidcon donpi 
gen doplock1 = donpi if imeasure==32
by iso : egen doplock = min(doplock1)
format doplock %td
gen plocki1 = 0
replace plocki1 = 1 if imeasure==32
by iso : egen plocki = max(plocki1)
label define plocki_ 0 "no partial lockdown" 1 "partial lockdown"
label values plocki plocki_ 
drop doplock1 plocki1

** Date of FULL lockdown
sort iso sidcon donpi 
gen doflock1 = donpi if imeasure==33
by iso : egen doflock = min(doflock1)
format doflock %td
gen flocki1 = 0
replace flocki1 = 1 if imeasure==33
by iso : egen flocki = max(flocki1)
label define flocki_ 0 "no full lockdown" 1 "full lockdown"
label values flocki flocki_ 
drop doflock1 flocki1

** Save out the dataset for next DO file
order aid country iso region donpi mind doplock plocki doflock flocki sidcon imeasure comment icat logtype 
save "`datapath'\version02\2-working\paper01_acaps", replace


** 23-MAY-2020 FROM HERE
** RE-VAMP TO ACCOMODATE A NEW DATASET STRUCTURE
** GIVEN THE INTERNAL SYSTEMATIC REVIEW OF NPI MEASURES (SR)

** Drop information on international flights
drop if imeasure == 6

** Generate our NEW 10 NPI categories
gen npi_group = .
** additional health docs, border checks, visa restrictions, health screening
replace npi_group = 1 if imeasure==1 | imeasure==2 | imeasure==8 | imeasure==14   /* Border checks */
replace npi_group = 2 if imeasure==3        /* Partial border closure */ 
replace npi_group = 3 if imeasure==4        /* Complete border closure */
** Chckpoints and mobility restrictions
replace npi_group = 4 if imeasure==5 | imeasure==7      /* Mobility restrictions */
replace npi_group = 5 if imeasure==9        /* curfews */
replace npi_group = 6 if imeasure==32       /* Partial lockdown */ 
replace npi_group = 7 if imeasure==33       /* full lockdown */

replace npi_group = 8 if imeasure==28       /* limit public gatherings */
replace npi_group = 9 if imeasure==29       /* public services closure */
replace npi_group = 10 if imeasure==31       /* school closure */

#delimit ; 
label define npi_group_ 
                1 "Border controls"
                2 "Partial Border closure"
                3 "Full Border closure"
                4 "Mobility restrictions"
                5 "Curfews"
                6 "Partial lockdown"
                7 "Full lockdown"
                8 "Limit public gatherings"
                9 "Close public services"
                10 "Close schools";
#delimit cr 
label values npi_group npi_group_

** ----------------------------------------------------------
** SAVE data check dataset for Maddy and Selvi 
** 23-MAY-2020
** ----------------------------------------------------------
** Push to Excel dataset
** Should contain the following:
** Country name. N=16 Caribbean countries. N=9 comparators
** ISO
** 10 rows per country. 1 row per NPI grouping
** DATE that represents the minimum date for that grouping
** Include the THREE broad NPI categories
** Two blank rows for checked (YES/NO)
** INITIAL of CHECKER + SECOND CHECKER
** ----------------------------------------------------------

** Final NPI dataset review.
** Creation of dataset for inclusion in SUPPLEMENT
keep country iso sidcon donpi npi_group comment
keep if sidcon<4
gen k=1
** minimum date by npi_group 
sort iso npi_group donpi 
bysort iso npi_group : egen min_donpi = min(donpi)
format min_donpi %td 
order country iso sidcon npi_group min_donpi donpi comment
collapse (count) k, by(country iso sidcon npi_group min_donpi)
fillin iso npi_group 
drop _fillin k 
** Complete COUNTRY after fillin 
sort iso min_donpi 
replace country = country[_n-1] if country=="" & country[_n-1]!="" & iso==iso[_n-1]
drop if country=="Venezuela" 
** Complete SIDCON after _fillin
replace sidcon = 1 if sidcon==. & (npi_group==1 | npi_group==2 | npi_group==3)
replace sidcon = 2 if sidcon==. & (npi_group==4 | npi_group==5 | npi_group==6 | npi_group==7)
replace sidcon = 3 if sidcon==. & (npi_group==8 | npi_group==9 | npi_group==10)
** NPI Implemented?
gen npi_yesno = .
replace npi_yesno = 1 if min_donpi<. 
replace npi_yesno = 0 if min_donpi==.
label define npi_yesno_ 0 "no" 1 "yes" 
label values npi_yesno npi_yesno_ 
** NPI Correct?
gen npi_correct = "" 
** Date of minimum NPI correct
gen donpi_correct = ""
** New date of NPI 
gen donpi_new = "" 
** NPI description 
gen npi_description = "" 

** Region 
gen country_type = 1
replace country_type = 2 if iso=="DEU" | iso=="ISL" | iso=="ITA" | iso=="NZL" | iso=="SGP" | iso=="KOR" | iso=="SWE" | iso=="GBR" | iso=="VNM"
label define country_type_ 1 "caribbean" 2 "comparator" 
label values country_type country_type_ 

order country iso country_type sidcon npi_group npi_yesno npi_correct min_donpi donpi_correct donpi_new npi_description
sort country_type country npi_group min_donpi 
drop if iso=="FJI" 
export excel using "`datapath'\version02\3-output\npi_check_23may2020", first(var) sheet("npi_check", replace)





**----------------------------------------------------------
** LOAD RESULTING COMPLETED DATASET 
** FOR FIGURES 3, 4, 5, and Supplement
**----------------------------------------------------------
*! We will re-import the completed dataset here 
**----------------------------------------------------------
import excel using "`datapath'\version02\3-output\npi_check_23may2020", first sheet("npi_check") clear
import excel using "`datapath'\version02\3-output\npi_check_23may2020_clean(CHv2)", first sheet("npi_check") clear

** ISO codes (as numerics) 
gen iso_num = . 
replace iso_num = 1 if iso=="AIA"
replace iso_num = 2  if iso=="ATG" 
replace iso_num = 3  if iso=="BHS" 
replace iso_num = 4  if iso=="BRB"
replace iso_num = 5  if iso=="BLZ" 
replace iso_num = 6  if iso=="BMU"
replace iso_num = 7  if iso=="VGB" 
replace iso_num = 8  if iso=="CYM" 
replace iso_num = 9  if iso=="CUB"
replace iso_num = 10  if iso=="DMA"
replace iso_num = 11  if iso=="DOM"
replace iso_num = 12  if iso=="GRD"
replace iso_num = 13  if iso=="GUY"
replace iso_num = 14  if iso=="HTI"
replace iso_num = 15  if iso=="JAM"
replace iso_num = 16  if iso=="MSR" 
replace iso_num = 17  if iso=="KNA"
replace iso_num = 18  if iso=="LCA"
replace iso_num = 19  if iso=="VCT"
replace iso_num = 20  if iso=="SUR"
replace iso_num = 21  if iso=="TTO"
replace iso_num = 22  if iso=="TCA"
replace iso_num = 24  if iso=="DEU"
replace iso_num = 25  if iso=="ISL"
replace iso_num = 26  if iso=="ITA"
replace iso_num = 27  if iso=="NZL"
replace iso_num = 28  if iso=="SGP"
replace iso_num = 29  if iso=="KOR"
replace iso_num = 30  if iso=="SWE"
replace iso_num = 31  if iso=="GBR"
replace iso_num = 32  if iso=="VNM"

#delimit ; 
label define iso_num_
1  "AIA"
2  "ATG" 
3  "BHS" 
4  "BRB"
5  "BLZ" 
6  "BMU"
7  "VGB" 
8  "CYM" 
9  "CUB"
10 "DMA"
11 "DOM"
12 "GRD"
13 "GUY"
14 "HTI"
15 "JAM"
16 "MSR" 
17 "KNA"
18 "LCA"
19 "VCT"
20 "SUR"
21 "TTO"
22 "TCA"
24 "DEU"
25 "ISL"
26 "ITA"
27 "NZL"
28 "SGP"
29 "KOR"
30 "SWE"
31 "GBR"
32 "VNM";
#delimit cr 
label values iso_num iso_num_            

** Region 
drop country_type 
gen ctype = 1
replace ctype = 2 if iso=="DEU" | iso=="ISL" | iso=="ITA" | iso=="NZL" | iso=="SGP" | iso=="KOR" | iso=="SWE" | iso=="GBR" | iso=="VNM"
label define ctype_ 1 "caribbean" 2 "comparator" 
label values ctype ctype_ 

** MAJOR NPI CATEGORIES 
gen mnpi = 1 if sidcon=="control movement into"
replace mnpi = 2 if sidcon=="control movement in"
replace mnpi = 3 if sidcon=="control gatherings"
label define mnpi_ 1 "control movement into" 2 "control movement in" 3 "control gatherings"
label values mnpi mnpi_
drop sidcon 

** SUB NPI CATEGORIES 
gen snpi = 1 if npi_group == "Border controls"
replace snpi = 2 if npi_group == "Partial Border closure"
replace snpi = 3 if npi_group == "Full Border closure"
replace snpi = 4 if npi_group == "Mobility restrictions"
replace snpi = 5 if npi_group == "Curfews"
replace snpi = 6 if npi_group == "Partial lockdown"
replace snpi = 7 if npi_group == "Full lockdown"
replace snpi = 8 if npi_group == "Limit public gatherings"
replace snpi = 9 if npi_group == "Close public services"
replace snpi = 10 if npi_group == "Close schools";
#delimit cr 
#delimit ; 
label define snpi_ 
                1 "Border controls"
                2 "Partial Border closure"
                3 "Full Border closure"
                4 "Mobility restrictions"
                5 "Curfews"
                6 "Partial lockdown"
                7 "Full lockdown"
                8 "Limit public gatherings"
                9 "Close public services"
                10 "Close schools";
#delimit cr 
label values snpi snpi_
drop npi_group 


** ----------------------------------------------
** YES/NO FOR EACH NPI GROUP 
** ----------------------------------------------

** The original YES/NO from ACAPS
gen yn_npi = .
replace yn_npi = 0 if npi_yesno=="no" 
replace yn_npi = 1 if npi_yesno=="yes" 
label define yn_npi_ 0 "no" 1 "yes" 
label values yn_npi yn_npi_ 

** Variable highlighting if original ACAPS (yes/no) is correct
rename npi_correct temp1
gen npi_correct = .
replace npi_correct = 0 if temp=="no" 
replace npi_correct = 1 if temp=="yes" 
label define npi_correct_ 0 "no" 1 "yes" 
label values npi_correct npi_correct_ 
drop temp 

** If ACAPS incorrect --> correct the erroneous values
** --> convert incorrect-yes to no 
replace yn_npi = 0 if npi_yes=="yes" & npi_correct==0
** --> convert incorrect-no to yes 
replace yn_npi = 1 if npi_yes=="no" & npi_correct==0

** Keep only the correct Y/N variable
**drop npi_yesno npi_correct 



** ----------------------------------------------
** DATE OF NPI
** ----------------------------------------------
** We update the date if our SR has highlighted an ACAPS error
** The original date loaded into new variable
gen donpi = min_donpi 
** corrected date converted to date format 
gen correct_date = daily(donpi_new, "DMY", 2020) 
order correct_date, after(donpi_new)
format correct_date %td 
format donpi %td 

** Replace original date with corrected date if in error

** Original NO in error --> Changed to YES
replace donpi = correct_date if npi_yesno=="no" & npi_correct==0

** Original NO is OK --> No Change (all dates are OK)

** Original YES in error --> Changed to NO (must remove dates)
replace donpi = . if npi_yesno=="yes" & npi_correct==0

** Original YES is OK --> No Change (update dates if necessary)
replace donpi = correct_date if npi_yesno=="yes" & npi_correct==1 & correct_date<. & correct_date!=min_donpi 

** order npi_yesno npi_correct yn_npi min_donpi correct_date donpi 
** sort npi_yesno npi_correct 

label var country "Country name" 
label var ctype "Caribbean or comparator country"
label var iso "Country 3-digit ISO code: text"
label var iso_num "Country 3-digit code: numeric" 
label var mnpi "Major NPI categories"
label var snpi "Sub (minor) NPI categories"
label var yn_npi "NPI implemented: No(0), Yes(1)"
label var donpi "Date of NPI implementaion"

cap drop npi_correct 
cap drop donpi_correct 
cap drop donpi_new 
cap drop npi_description 
cap drop min_donpi 
cap drop correct_date 
cap drop npi_yesno
cap drop Source 
cap drop M 
order country iso iso_num ctype mnpi snpi yn_npi donpi 

save "`datapath'\version02\2-working\paper01_acaps_sr", replace
