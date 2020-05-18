** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					paper01_12fig3.do
    //  project:				        
    //  analysts:				       	Ian HAMBLETON
    // 	date last modified	            13-MAY-2020
    //  algorithm task			        PAPER 01. Situation Analysis. Figure 3

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
    log using "`logpath'\paper01_12fig3", replace
** HEADER -----------------------------------------------------


** -----------------------------------------
** Pre-Load the COVID metrics --> as Global Macros
** -----------------------------------------
qui do "`logpath'\paper01_04metrics"
** -----------------------------------------

** Close any open log file and open a new log file
capture log close
log using "`logpath'\paper01_12fig3", replace


** Fix --> Single Montserrat value 
replace confirmed = 5 if confirmed==0 & iso_num==22 & date==d(01apr2020)

** Attack Rate (per 1,000 --> not yet used)
gen confirmed_rate = (confirmed / pop) * 10000

** SMOOTHED CASES for graphic
bysort iso: asrol confirmed , stat(mean) window(date 3) gen(confirmed_av3)
bysort iso: asrol deaths , stat(mean) window(date 3) gen(deaths_av3)

** REGIONAL VALUES
rename confirmed metric1
rename confirmed_rate metric2
rename deaths metric3
rename recovered metric4
reshape long metric, i(iso_num iso date) j(mtype)
label define mtype_ 1 "cases" 2 "attack rate" 3 "deaths" 4 "recovered"
label values mtype mtype_
keep if mtype==1 | mtype==3
sort iso mtype date 

** METRIC 60
** Cases in past 1-day across region 
global m60 =  $m60_ATG + $m60_BHS + $m60_BRB + $m60_BLZ + $m60_DMA + $m60_GRD + $m60_GUY ///
            + $m60_HTI + $m60_JAM + $m60_KNA + $m60_LCA + $m60_VCT + $m60_SUR + $m60_TTO
** METRIC 62
** Cases in past 7-days across region 
global m62 =  $m62_ATG + $m62_BHS + $m62_BRB + $m62_BLZ + $m62_DMA + $m62_GRD + $m62_GUY ///
            + $m62_HTI + $m62_JAM + $m62_KNA + $m62_LCA + $m62_VCT + $m62_SUR + $m62_TTO

** METRIC 61
** Deaths in past 1-day across region 
global m61 =  $m61_ATG + $m61_BHS + $m61_BRB + $m61_BLZ + $m61_DMA + $m61_GRD + $m61_GUY ///
            + $m61_HTI + $m61_JAM + $m61_KNA + $m61_LCA + $m61_VCT + $m61_SUR + $m61_TTO
** METRIC 63
** Deaths in past 7-days across region 
global m63 =  $m63_ATG + $m63_BHS + $m63_BRB + $m63_BLZ + $m63_DMA + $m63_GRD + $m63_GUY ///
            + $m63_HTI + $m63_JAM + $m63_KNA + $m63_LCA + $m63_VCT + $m63_SUR + $m63_TTO

** METRIC 01 
** CURRENT CONFIRMED CASES across region
global m01 =  $m01_ATG + $m01_BHS + $m01_BRB + $m01_BLZ + $m01_DMA + $m01_GRD + $m01_GUY ///
            + $m01_HTI + $m01_JAM + $m01_KNA + $m01_LCA + $m01_VCT + $m01_SUR + $m01_TTO

** METRIC 02
** CURRENT CONFIRMED DEATHS across region
global m02 =  $m02_ATG + $m02_BHS + $m02_BRB + $m02_BLZ + $m02_DMA + $m02_GRD + $m02_GUY ///
            + $m02_HTI + $m02_JAM + $m02_KNA + $m02_LCA + $m02_VCT + $m02_SUR + $m02_TTO


** UKOTS
** METRIC 60
** Cases in past 1-day across region 
global m60ukot =  $m60_AIA + $m60_BMU + $m60_VGB + $m60_CYM + $m60_MSR + $m60_TCA
** METRIC 62
** Cases in past 7-days across region 
global m62ukot =  $m62_AIA + $m62_BMU + $m62_VGB + $m62_CYM + $m62_MSR + $m62_TCA 

** METRIC 61
** Deaths in past 1-day across region 
global m61ukot =  $m61_AIA + $m61_BMU + $m61_VGB + $m61_CYM + $m61_MSR + $m61_TCA 
** METRIC 63
** Deaths in past 7-days across region 
global m63ukot =  $m63_AIA + $m63_BMU + $m63_VGB + $m63_CYM + $m63_MSR + $m63_TCA 

** METRIC 01 
** CURRENT CONFIRMED CASES across region
global m01ukot =  $m01_AIA + $m01_BMU + $m01_VGB + $m01_CYM + $m01_MSR + $m01_TCA  

** METRIC 02
** CURRENT CONFIRMED DEATHS across region
global m02ukot = $m02_AIA + $m02_BMU + $m02_VGB + $m02_CYM + $m02_MSR + $m02_TCA  

** SUBSETS 
gen touse = 1
replace touse = 0 if    iso=="GBR" | iso=="USA" | iso=="KOR" | iso=="SGP" | iso=="DOM" | iso=="CUB" |   ///
                        iso=="HKG" | iso=="ISL" | iso=="NZL"
gen ukot = 0 
replace ukot =1 if iso=="AIA" | iso=="BMU" | iso=="VGB" | iso=="CYM" | iso=="MSR" | iso=="TCA"


** METRIC 03 
** DATE OF FIRST CONFIRMED CASE
preserve 
    keep if touse==1 & mtype==1 & metric>0 
    egen m03 = min(date) 
    format m03 %td 
    global m03 : disp %tdDD_Month m03
restore
** METRIC 04 
** The DATE OF FIRST CONFIRMED DEATH
preserve 
    keep if touse==1 & mtype==3 & metric>0 
    egen m04 = min(date) 
    format m04 %td 
    global m04 : disp %tdDD_Month m04
restore
** METRIC 05: Days since first reported case
preserve 
    keep if touse==1 & mtype==1 & metric>0
    collapse (sum) metric, by(date)
    gen elapsedc = _n 
    egen m05 = max(elapsedc)
    global m05 = m05 
restore 
** METRIC 06: Days since first reported death
preserve 
    keep if touse==1 & mtype==3 & metric>0
    collapse (sum) metric, by(date)
    gen elapsedd = _n 
    egen m06 = max(elapsedd)
    global m06 = m06 
restore

** UKOTS
** METRIC 03 
** DATE OF FIRST CONFIRMED CASE
preserve 
    keep if ukot==1 & mtype==1 & metric>0 
    egen m03ukot = min(date) 
    format m03ukot %td 
    global m03ukot : disp %tdDD_Month m03
restore
** METRIC 04 
** The DATE OF FIRST CONFIRMED DEATH
preserve 
    keep if ukot==1 & mtype==3 & metric>0 
    egen m04ukot = min(date) 
    format m04ukot %td 
    global m04ukot : disp %tdDD_Month m04
restore
** METRIC 05: Days since first reported case
preserve 
    keep if ukot==1 & mtype==1 & metric>0
    collapse (sum) metric, by(date)
    gen elapsedcukot = _n 
    egen m05ukot = max(elapsedc)
    global m05ukot = m05 
restore 
** METRIC 06: Days since first reported death
preserve 
    keep if ukot==1 & mtype==3 & metric>0
    collapse (sum) metric, by(date)
    gen elapseddukot = _n 
    egen m06ukot = max(elapsedd)
    global m06ukot = m06 
restore



** -----------------------------------------
** Use the FULL PAPER-01 dataset
** -----------------------------------------
use "`datapath'\version02\2-working\paper01_acaps", clear

** Basic heatmap of xx NPI measures 
** Initial data preparation
    keep if sidcon<4
    gen k=1 
    collapse (count) k, by(iso imeasure)
    fillin iso imeasure 
    replace k = 0 if k==.
    gen gmeasure = 0
    bysort iso imeasure: replace gmeasure = 1 if k>=1
    ** NPI Indicator (0 = No and 2=Yes)
    gen gm2 = gmeasure*2


** Group 1. Control movement into country
**       1  "Additional health/documents requirements upon arrival"
**       2  "Border checks"
**       3  "Border closure"
**       4  "Complete border closure"
**       5  "Checkpoints within the country"
**       6  "International flights suspension"
**       8  "Visa restrictions"
**       14 "Health screenings in airports"

** Group 2. Control movement in country
**       7  "Domestic travel restrictions"
**       9  "Curfews"
**       32 "Partial lockdown"
**       33 "Full lockdown"

** Group 3. Control of gatherings 
**       28 "Limit public gatherings"
**       29 "Public services closure"
**       31 "Schools closure"

** Group 4. Control of infection
**       10 "Surveillance and monitoring"
**       11 "Awareness campaigns"
**       12 "Isolation and quarantine policies"
**       17 "Mass population testing"
gen npi_order = .

** additional health docs, border checks, visa restrictions, health screening
replace npi_order = 1 if imeasure==1 | imeasure==2 | imeasure==8 | imeasure==14       
replace npi_order = 2 if imeasure==3        /* border closure */
replace npi_order = 3 if imeasure==6        /* int'l flight suspension */

** Chckpoints and mobility restrictions
replace npi_order = 5 if imeasure==5 | imeasure==7
replace npi_order = 6 if imeasure==9        /* curfews */
replace npi_order = 7 if imeasure==32       /* partial lockdown */
replace npi_order = 8 if imeasure==33       /* full lockdown */

replace npi_order = 10 if imeasure==28       /* limit public gatherings */
replace npi_order = 11 if imeasure==29       /* public services closure */
replace npi_order = 12 if imeasure==31       /* school closure */

replace npi_order = 14 if imeasure==10       /* surv / monitoring */
replace npi_order = 15 if imeasure==11       /* awareness campaigns */
replace npi_order = 16 if imeasure==12       /* isolation / quarantine */
replace npi_order = 17 if imeasure==17       /* mass population testing */

#delimit ;
label define npi_order_
                1 "Border controls"
                2 "Border closure"
                3 "Flight suspension"
                5 "Mobility restrictions"
                6 "Curfews"
                7 "Partial lockdown"
                8 "Full lockdown"
                10 "Limit public gatherings"
                11 "Close public services"
                12 "Close schools";
#delimit cr 
label values npi_order npi_order_

** 1 row per npi_order
collapse (max) measure=gm2, by(iso npi_order)
drop if npi_order>=14

** --------------------------------------------------------
** DATA UPDATE
** 17 May 2020
** --------------------------------------------------------
** Manual Data Update
** This includes: 
**     (1)  Updating ACAPS errors
**     (2)  Adding the 6 UKOTS
**          Which means a structural change to the graphic
**
*! DATA FROM:
*! PATH: X:\The University of the West Indies\DataGroup - repo_data\data_p151\version02\1-input
*! FILE: uwi_covid_npi_dataentry.xlsx
** --------------------------------------------------------
    gen manual_change = 0
    replace       measure = 2 if iso=="ATG" & npi_order==5 & measure==0       /* ATG. Mobility restrictions */
    replace manual_change = 1 if iso=="ATG" & npi_order==5

    replace       measure = 2 if iso=="BHS" & npi_order==5 & measure==0       /* BHS. Mobility restrictions */
    replace manual_change = 1 if iso=="BHS" & npi_order==5

    replace       measure = 2 if iso=="BRB" & npi_order==5 & measure==0       /* BRB. Mobility restrictions */
    replace manual_change = 1 if iso=="BRB" & npi_order==5

    replace       measure = 0 if iso=="BRB" & npi_order==2 & measure==0       /* BRB. Border NOT closed */
    replace manual_change = 1 if iso=="BRB" & npi_order==2

    replace       measure = 2 if iso=="BLZ" & npi_order==5 & measure==0       /* BLZ. Mobility restrictions */
    replace manual_change = 1 if iso=="BLZ" & npi_order==5

    replace       measure = 2 if iso=="CUB" & npi_order==11 & measure==0      /* CUB. Close public services */
    replace manual_change = 1 if iso=="CUB" & npi_order==11

    replace       measure = 2 if iso=="DMA" & npi_order==12 & measure==0      /* DMA. Close schools */
    replace manual_change = 1 if iso=="DMA" & npi_order==12

    replace       measure = 2 if iso=="DMA" & npi_order==1 & measure==0       /* DMA. Border controls */
    replace manual_change = 1 if iso=="DMA" & npi_order==1

    replace       measure = 2 if iso=="DOM" & npi_order==7 & measure==0       /* DOM. Partial lockdown */
    replace manual_change = 1 if iso=="DOM" & npi_order==7

    replace       measure = 2 if iso=="GRD" & npi_order==5 & measure==0       /* GRD. Mobility restrictions */
    replace manual_change = 1 if iso=="GRD" & npi_order==5

    replace       measure = 2 if iso=="GUY" & npi_order==8 & measure==0       /* GUY. Full lockdown */
    replace manual_change = 1 if iso=="GUY" & npi_order==8

    replace       measure = 2 if iso=="GUY" & npi_order==5 & measure==0       /* GUY. Mobility restrictions */
    replace manual_change = 1 if iso=="GUY" & npi_order==5

    replace       measure = 2 if iso=="HTI" & npi_order==3 & measure==0       /* HTI. Flight suspension */
    replace manual_change = 1 if iso=="HTI" & npi_order==3

    replace       measure = 2 if iso=="JAM" & npi_order==12 & measure==0       /* JAM. Schools closed */
    replace manual_change = 1 if iso=="JAM" & npi_order==12

    replace       measure = 2 if iso=="JAM" & npi_order==10 & measure==0       /* JAM. Limit public gatherings */
    replace manual_change = 1 if iso=="JAM" & npi_order==10

    replace       measure = 2 if iso=="JAM" & npi_order==3 & measure==0       /* JAM. Flight suspension */
    replace manual_change = 1 if iso=="JAM" & npi_order==3

    replace       measure = 2 if iso=="KNA" & npi_order==10 & measure==0       /* KNA. Limit public gatherings */
    replace manual_change = 1 if iso=="KNA" & npi_order==10

    replace       measure = 2 if iso=="LCA" & npi_order==5 & measure==0       /* LCA. Mobility restrictions */
    replace manual_change = 1 if iso=="LCA" & npi_order==5

    replace       measure = 2 if iso=="LCA" & npi_order==12 & measure==0       /* LCA. Close schools */
    replace manual_change = 1 if iso=="LCA" & npi_order==12

    replace       measure = 2 if iso=="VCT" & npi_order==3 & measure==0       /* VCT. Flight suspension */
    replace manual_change = 1 if iso=="VCT" & npi_order==3

    replace       measure = 2 if iso=="VCT" & npi_order==10 & measure==0       /* VCT. Limit public gatherings */
    replace manual_change = 1 if iso=="VCT" & npi_order==10

    replace       measure = 2 if iso=="VCT" & npi_order==1 & measure==0       /* VCT. Border controls */
    replace manual_change = 1 if iso=="VCT" & npi_order==1

    replace       measure = 2 if iso=="VCT" & npi_order==2 & measure==0       /* VCT. Border closure */
    replace manual_change = 1 if iso=="VCT" & npi_order==2

    replace       measure = 2 if iso=="TTO" & npi_order==10 & measure==0       /* TTO. Limit public gatherings */
    replace manual_change = 1 if iso=="TTO" & npi_order==10

    replace       measure = 2 if iso=="TTO" & npi_order==3 & measure==0       /* TTO. Flight suspension */
    replace manual_change = 1 if iso=="TTO" & npi_order==3

    replace       measure = 0 if iso=="NZL" & npi_order==7 & measure==2       /* NZL. NO partial lockdown. Only FULL lockdown */
    replace manual_change = 1 if iso=="NZL" & npi_order==7

    replace       measure = 2 if iso=="SWE" & npi_order==12 & measure==0       /* SWE. Close schools */
    replace manual_change = 1 if iso=="SWE" & npi_order==12

** Add Structural change
** Include rows for the 6 UKOTS 
preserve 
    drop _all
    tempfile ukots
    input str3 iso npi_order measure manual_change
    "AIA" 1 4 1            /* 1 "Border checks" */
    "AIA" 2 4 1            /* 2 "Border closure" */
    "AIA" 3 4 1            /* 3 "Flight suspension" */
    "AIA" 5 4 1            /* 5 "Mobility restrictions" */
    "AIA" 6 4 1            /* 6 "Curfews" */
    "AIA" 7 4 1            /* 7 "Partial lockdown" */
    "AIA" 8 4 1            /* 8 "Full lockdown" */
    "AIA" 10 4 1           /* 10 "Limit public gatherings" */
    "AIA" 11 4 1           /* 11 "Close public services" */
    "AIA" 12 4 1           /* 12 "Close schools" */
    "BMU" 1 4 1            /* 1 "Border checks" */
    "BMU" 2 4 1            /* 2 "Border closure" */
    "BMU" 3 4 1            /* 3 "Flight suspension" */
    "BMU" 5 4 1            /* 5 "Mobility restrictions" */
    "BMU" 6 4 1            /* 6 "Curfews" */
    "BMU" 7 4 1            /* 7 "Partial lockdown" */
    "BMU" 8 4 1            /* 8 "Full lockdown" */
    "BMU" 10 4 1           /* 10 "Limit public gatherings" */
    "BMU" 11 4 1           /* 11 "Close public services" */
    "BMU" 12 4 1           /* 12 "Close schools" */
    "VGB" 1 4 1            /* 1 "Border checks" */
    "VGB" 2 4 1            /* 2 "Border closure" */
    "VGB" 3 4 1            /* 3 "Flight suspension" */
    "VGB" 5 4 1            /* 5 "Mobility restrictions" */
    "VGB" 6 4 1            /* 6 "Curfews" */
    "VGB" 7 4 1            /* 7 "Partial lockdown" */
    "VGB" 8 4 1            /* 8 "Full lockdown" */
    "VGB" 10 4 1           /* 10 "Limit public gatherings" */
    "VGB" 11 4 1           /* 11 "Close public services" */
    "VGB" 12 4 1           /* 12 "Close schools" */
    "CYM" 1 4 1            /* 1 "Border checks" */
    "CYM" 2 4 1            /* 2 "Border closure" */
    "CYM" 3 4 1            /* 3 "Flight suspension" */
    "CYM" 5 4 1            /* 5 "Mobility restrictions" */
    "CYM" 6 4 1            /* 6 "Curfews" */
    "CYM" 7 4 1            /* 7 "Partial lockdown" */
    "CYM" 8 4 1            /* 8 "Full lockdown" */
    "CYM" 10 4 1           /* 10 "Limit public gatherings" */
    "CYM" 11 4 1           /* 11 "Close public services" */
    "CYM" 12 4 1           /* 12 "Close schools" */    
    "MSR" 1 4 1            /* 1 "Border checks" */
    "MSR" 2 4 1            /* 2 "Border closure" */
    "MSR" 3 4 1            /* 3 "Flight suspension" */
    "MSR" 5 4 1            /* 5 "Mobility restrictions" */
    "MSR" 6 4 1            /* 6 "Curfews" */
    "MSR" 7 4 1            /* 7 "Partial lockdown" */
    "MSR" 8 4 1            /* 8 "Full lockdown" */
    "MSR" 10 4 1           /* 10 "Limit public gatherings" */
    "MSR" 11 4 1           /* 11 "Close public services" */
    "MSR" 12 4 1           /* 12 "Close schools" */    
    "TCA" 1 4 1            /* 1 "Border checks" */
    "TCA" 2 4 1            /* 2 "Border closure" */
    "TCA" 3 4 1            /* 3 "Flight suspension" */
    "TCA" 5 4 1            /* 5 "Mobility restrictions" */
    "TCA" 6 4 1            /* 6 "Curfews" */
    "TCA" 7 4 1            /* 7 "Partial lockdown" */
    "TCA" 8 4 1            /* 8 "Full lockdown" */
    "TCA" 10 4 1           /* 10 "Limit public gatherings" */
    "TCA" 11 4 1           /* 11 "Close public services" */
    "TCA" 12 4 1           /* 12 "Close schools" */        
    end
    save `ukots', replace 
restore 
** append using `ukots' 

** Finally - merge partial and full lockdown 
gen npi_final = npi_order
replace npi_final = 7 if npi_order==7 | npi_order==8
collapse (max) measure_ld=measure, by(iso npi_final manual_change)
recode npi_final 10=9 11=10 12=11

#delimit ;
label define npi_final_
                1 "Border controls"
                2 "Border closure"
                3 "Flight suspension"
                5 "Mobility restrictions"
                6 "Curfew"
                7 "Lockdown"
                9 "Limit public gatherings"
                10 "Close public services"
                11 "Close schools";
#delimit cr 
label values npi_final npi_final_

    ** 17-MAY-2020
    ** New numeric running from 1 to 16 (CARICOM + CUB + DOM) 
    ** IN the end, this will run from 1-22, with the inclusion of the 6 UKOTS
    **
    ** From 17-25 is the 9 additional comparator countries
    gen corder = .
    ** Caribbean
    replace corder = 1 if iso=="AIA" 
    replace corder = 2 if iso=="ATG"
    replace corder = 3 if iso=="BHS"       
    replace corder = 4 if iso=="BRB"      
    replace corder = 5 if iso=="BLZ"       
    replace corder = 6 if iso=="BMU"       
    replace corder = 7 if iso=="VGB"       
    replace corder = 8 if iso=="CYM"       
    replace corder = 9 if iso=="CUB"       
    replace corder = 10 if iso=="DMA"       
    replace corder = 11 if iso=="DOM"       
    replace corder = 12 if iso=="GRD"       
    replace corder = 13 if iso=="GUY"      
    replace corder = 14 if iso=="HTI"      
    replace corder = 15 if iso=="JAM"      
    replace corder = 16 if iso=="MSR"      
    replace corder = 17 if iso=="KNA"      
    replace corder = 18 if iso=="LCA"      
    replace corder = 19 if iso=="VCT"      
    replace corder = 20 if iso=="SUR"     
    replace corder = 21 if iso=="TTO"     
    replace corder = 22 if iso=="TCA"     
    ** comparators
    replace corder = 24 if iso=="DEU"      /* Germany*/
    replace corder = 25 if iso=="ISL"      /* Iceland*/
    replace corder = 26 if iso=="ITA"      /* Italy */
    replace corder = 27 if iso=="NZL"      /* New Zealand */
    replace corder = 28 if iso=="SGP"      /* Singapore */
    replace corder = 29 if iso=="KOR"      /* South Korea */
    replace corder = 30 if iso=="SWE"      /* Sweden */
    replace corder = 31 if iso=="GBR"      /* United Kingdom*/
    replace corder = 32 if iso=="VNM"      /* Vietnam */

    #delimit ;
        heatplot measure corder npi_final 
        ,
        colors(#e0726c #83c983)
        ///colors(#e0726c #83c983 #cccccc)
        ///cuts(@min(2)@max)
        cuts(0 1 3) 
        p(lcolor(gs16) lalign(center) lw(0.05))
        discrete
        statistic(asis)

        plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
        graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
        ysize(17) xsize(11)

        ylab(   
                1 "Anguilla" 
                2 "Antigua and Barbuda" 
                3 "The Bahamas" 
                4 "Barbados"
                5 "Belize" 
                6 "Bermuda"
                7 "British Virgin Islands"
                8 "Cayman Islands" 
                9 "Cuba"
                10 "Dominica"
                11 "Dominican Republic"
                12 "Grenada"
                13 "Guyana"
                14 "Haiti"
                15 "Jamaica"
                16 "Montserrat"
                17 "St Kitts and Nevis"
                18 "St Lucia"
                19 "St Vincent"
                20 "Suriname"
                21 "Trinidad and Tobago"
                22 "Turks and Caicos Islands"
                24 "Germany"
                25 "Iceland"
                26 "Italy"
                27 "New Zealand"
                28 "Singapore"
                29 "South Korea"
                30 "Sweden"
                31 "United Kingdom"
                32 "Vietnam"
        , labs(2.5) notick nogrid glc(gs16) angle(0))
        yscale(reverse fill noline range(-5(1)26)) 
        ///yscale(log reverse fill noline) 
        ytitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 

        xlab(
                1 "Border controls"
                2 "Border closure"
                3 "Flight suspension"
                5 "Mobility restrictions"
                6 "Curfew"
                7 "Lockdown"
                9 "Limit public gatherings"
                10 "Close public services"
                11 "Close schools"
                ///14 "Surveillance / monitoring"
                ///15 "Awareness campaigns"
                ///16 "Isolation / quarantine"
                ///17 "Mass population testing"
        , labs(2.5) nogrid glc(gs16) angle(45) format(%9.0f) labgap(2))
        xtitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 

        ///title("NPIs implemented by $S_DATE", pos(11) ring(1) size(3.5))
        text(-1.5 2 "Control" "movement" "into country" , place(c) size(2.5) )
        text(-1.5 6 "Control" "movement" "in country" , place(c) size(2.5) )
        text(-1.5 10 "Control" "gatherings" , place(c) size(2.5) )

        legend(size(2.5) position(2) ring(5) colf cols(1) lc(gs16)
        region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
        sub("NPI", size(2.75))
        order(1 2)
        lab(1 "No")
        lab(2 "Yes")
        )
        name(heatmap_acaps1) 
        ;
    #delimit cr
    ///graph export "`outputpath'/04_TechDocs/heatmap_newcases_$S_DATE.png", replace width(4000)

