** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					covidprofiles_007_slides.do
    //  project:				        
    //  analysts:				       	Ian HAMBLETON
    // 	date last modified	            19-JUN-2020
    //  algorithm task			        SLIDES - summary of all PDF outputs on 30 slides

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
    ** ! This contains a local Windows-specific location 
    ** ! Would need changing for auto saving of PDF to online sync folder
    local outputpath "X:\The University of the West Indies\DataGroup - DG_Projects\PROJECT_p151"
    **local outputpath "X:\The UWI - Cave Hill Campus\DataGroup - PROJECT_p151" // SW to use this outputpath when running the do-file
   
    ** local parent "C:\Users\Ian Hambleton\Sync\Link_folders\COVID19 Surveillance Updates\03 presentations"
    local parent "X:\The University of the West Indies\CaribData - Documents\COVID19Surveillance\PDF_Briefings\03 presentations"
    **local parent "X:\The UWI - Cave Hill Campus\CaribData - Documents\COVID19Surveillance\PDF_Briefings\03 presentations" // SW to use this filepath
    cap mkdir "`parent'\\`today'
    local syncpath "X:\The University of the West Indies\CaribData - Documents\COVID19Surveillance\PDF_Briefings\03 presentations\\`today'"
    **local syncpath "X:\The UWI - Cave Hill Campus\CaribData - Documents\COVID19Surveillance\PDF_Briefings\03 presentations\\`today'" // SW to use this filepath
  
    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\covidprofiles_007_slides", replace
** HEADER -----------------------------------------------------

** -----------------------------------------
** Pre-Load the COVID metrics --> as Global Macros
** -----------------------------------------
qui do "`logpath'\covidprofiles_003_metrics_v5"
** -----------------------------------------


** Close any open log file and open a new log file
capture log close
log using "`logpath'\covidprofiles_007_slides", replace

** Labelling of the internal country numeric
#delimit ; 
label define cname_ 1 "Anguilla" 
                    2 "Bonaire, Saint Eustatius, Saba" 
                    3 "Antigua and Barbuda"
                    4 "The Bahamas"
                    5 "Belize"
                    6 "Bermuda"
                    7 "Barbados"
                    8 "Cuba"
                    9 "Cayman Islands" 
                    10 "Dominica"
                    11 "Dominican Republic"
                    12 "UK" 
                    13 "Grenada"
                    14 "Guyana"
                    15 "Hong Kong"
                    16 "Haiti"
                    17 "Iceland"
                    18 "Jamaica"
                    19 "Saint Kitts and Nevis"
                    20 "South Korea"
                    21 "Saint Lucia"
                    22 "Montserrat"
                    23 "New Zeland"
                    24 "Singapore"
                    25 "Suriname"
                    26 "Turks and Caicos"
                    27 "Trinidad and Tobago"
                    28 "USA"
                    29 "Saint Vincent and the Grenadines"
                    30 "British Virgin Islands"
                    ;
#delimit cr 
** Attack Rate (per 1,000 --> not yet used)
gen cases_rate = (total_cases / pop) * 10000

** SMOOTHED CASES for graphic
bysort iso: asrol total_cases , stat(mean) window(date 3) gen(cases_av3)
bysort iso: asrol total_deaths , stat(mean) window(date 3) gen(deaths_av3)


** REGIONAL VALUES
rename total_cases metric1
rename cases_rate metric2
rename total_deaths metric3
reshape long metric, i(iso_num iso date) j(mtype)
label define mtype_ 1 "cases" 2 "attack rate" 3 "deaths"
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


** UKOTS x6
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




** UKOTS x5
** METRIC 60
** Cases in past 1-day across region 
global m60ukot5 =  $m60_AIA + $m60_BMU + $m60_VGB + $m60_CYM + $m60_MSR 
** METRIC 62
** Cases in past 7-days across region 
global m62ukot5 =  $m62_AIA + $m62_BMU + $m62_VGB + $m62_CYM + $m62_MSR  

** METRIC 61
** Deaths in past 1-day across region 
global m61ukot5 =  $m61_AIA + $m61_BMU + $m61_VGB + $m61_CYM + $m61_MSR  
** METRIC 63
** Deaths in past 7-days across region 
global m63ukot5 =  $m63_AIA + $m63_BMU + $m63_VGB + $m63_CYM + $m63_MSR  

** METRIC 01 
** CURRENT CONFIRMED CASES across region
global m01ukot5 =  $m01_AIA + $m01_BMU + $m01_VGB + $m01_CYM + $m01_MSR   

** METRIC 02
** CURRENT CONFIRMED DEATHS across region
global m02ukot5 = $m02_AIA + $m02_BMU + $m02_VGB + $m02_CYM + $m02_MSR   




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



** ------------------------------------------------------
** PDF REGIONAL REPORT (COUNTS OF CONFIRMED CASES)
** ------------------------------------------------------
    putpdf begin, pagesize(letter) landscape font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.25cm) margin(left,0.5cm) margin(right,0.25cm)

** PAGE 1. DAILY CURVES
** PAGE 1. TITLE, ATTRIBUTION, DATE of CREATION
    putpdf table intro1 = (1,16), width(100%) halign(left) 
    putpdf table intro1(.,.), border(all, nil)
    putpdf table intro1(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro1(1,1)
    putpdf table intro1(1,2), colspan(15)
    putpdf table intro1(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro1(1,2)=("COVID-19 SLIDE DECK: Surveillance in 20 Caribbean Countries and Territories"), halign(left) linebreak font("Calibri Light", 12, 000000)
    putpdf table intro1(1,2)=("Slide deck created by staff of the George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro1(1,2)=("and the Public Health Group of The Faculty of Medical Sciences, Cave Hill Campus, "), halign(left) append  
    putpdf table intro1(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro1(1,2)=("Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro1(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic   
    putpdf table intro1(1,2)=("For all our COVID-19 surveillance outputs, go to "), halign(left) append
    putpdf table intro1(1,2)=("www.uwi.edu/covid19/surveillance "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

** PAGE 1. INTRODUCTION
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("COVID-19 SLIDE DECK. ") , bold linebreak font("Calibri Light", 14)
    putpdf text ("This document contains a series of PDF slides for open-access use by anyone wanting to present on COVID-19 surveillance trends in the Caribbean. ")
    putpdf text ("We start with regional overviews, and follow these overviews with country-by-country updates. ") 
    putpdf text (" 20 Caribbean countries and territories are included. The data presented ") 
    putpdf text ("are correct as of $S_DATE. "), linebreak 
    putpdf text (" "), linebreak 
    putpdf text ("All slides created by Ian Hambleton, Professor of Biostatistics, George Alleyne Chronic Disease Research Centre. "), font("Calibri Light", 12, 8c8c8c)
    putpdf text ("Email "), font("Calibri Light", 12, 8c8c8c)
    putpdf text ("ian.hambleton@cavehill.uwi.edu "), italic font("Calibri Light", 12, 8c8c8c)
    putpdf text ("with any questions related to these slides. All graphics are drawn from our COVID-19 briefings, updated daily and available at: "), linebreak font("Calibri Light", 12, 8c8c8c)
    putpdf text ("www.uwi.edu/covid19/surveillance "), italic font("Calibri Light", 12, 8c8c8c)


** SLIDE 1: REGIONAL SUMMARY
** TITLE, ATTRIBUTION, DATE of CREATION
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("REGIONAL COVID-19 DAILY CASES"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 1"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak

    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf text (" ") , linebreak 
    putpdf table t1 = (5,6), width(100%) halign(center) 
    putpdf table t1(1,1), font("Calibri Light", 20, 000000) colspan(6) border(all, nil) 
    putpdf table t1(2,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,1), font("Calibri Light", 20, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,1), font("Calibri Light", 20, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(4,2), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,2), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,3), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,3), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,4), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,4), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,5), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,5), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,6), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,6), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 

    putpdf table t1(1,1)=("Summary for 14 CARICOM countries"), colspan(6) halign(left) font("Calibri Light", 20, 808080)
    putpdf table t1(2,2)=("Total"), halign(center) 
    putpdf table t1(2,3)=("New"), halign(center) 
    putpdf table t1(3,3)=("(1 day)"), halign(center) 
    putpdf table t1(2,4)=("New"), halign(center) 
    putpdf table t1(3,4)=("(1 week)"), halign(center) 
    putpdf table t1(2,5)=("Date of"), halign(center) 
    putpdf table t1(3,5)=("1st confirmed"), halign(center) 
    putpdf table t1(2,6)=("Days since"), halign(center) 
    putpdf table t1(3,6)=("1st confirmed"), halign(center)

    putpdf table t1(2,1)=("Confirmed"), halign(center) 
    putpdf table t1(3,1)=("Events"), halign(center) 
    putpdf table t1(4,1)=("Cases"), halign(center) 
    putpdf table t1(5,1)=("Deaths"), halign(center)  

    putpdf table t1(4,2)=("${m01}"), halign(center) 
    putpdf table t1(5,2)=("${m02}"), halign(center) 
    putpdf table t1(4,3)=("${m60}"), halign(center) 
    putpdf table t1(5,3)=("${m61}"), halign(center) 
    putpdf table t1(4,4)=("${m62}"), halign(center) 
    putpdf table t1(5,4)=("${m63}"), halign(center) 
    putpdf table t1(4,5)=("${m03}"), halign(center) 
    putpdf table t1(5,5)=("${m04}"), halign(center) 
    putpdf table t1(4,6)=("${m05}"), halign(center) 
    putpdf table t1(5,6)=("${m06}"), halign(center) 

** TABLE: REGIONAL SUMMARY METRICS
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf text (" ") , linebreak
    putpdf table t1 = (5,6), width(100%) halign(center) 
    putpdf table t1(1,1), font("Calibri Light", 20, 000000) colspan(6) border(all, nil) 
    putpdf table t1(2,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,1), font("Calibri Light", 20, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,1), font("Calibri Light", 20, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(4,2), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,2), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,3), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,3), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,4), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,4), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,5), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,5), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,6), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,6), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 

    putpdf table t1(1,1)=("Summary for 6 United Kingdom Overseas Territies (UKOTS)"), colspan(6) halign(left)  font("Calibri Light", 20, 808080)
    putpdf table t1(2,2)=("Total"), halign(center) 
    putpdf table t1(2,3)=("New"), halign(center) 
    putpdf table t1(3,3)=("(1 day)"), halign(center) 
    putpdf table t1(2,4)=("New"), halign(center) 
    putpdf table t1(3,4)=("(1 week)"), halign(center) 
    putpdf table t1(2,5)=("Date of"), halign(center) 
    putpdf table t1(3,5)=("1st confirmed"), halign(center) 
    putpdf table t1(2,6)=("Days since"), halign(center) 
    putpdf table t1(3,6)=("1st confirmed"), halign(center) 
    putpdf table t1(2,1)=("Confirmed"), halign(center) 
    putpdf table t1(3,1)=("Events"), halign(center) 
    putpdf table t1(4,1)=("Cases"), halign(center) 
    putpdf table t1(5,1)=("Deaths"), halign(center)  

    putpdf table t1(4,2)=("${m01ukot}"), halign(center) 
    putpdf table t1(5,2)=("${m02ukot}"), halign(center) 
    putpdf table t1(4,3)=("${m60ukot}"), halign(center) 
    putpdf table t1(5,3)=("${m61ukot}"), halign(center) 
    putpdf table t1(4,4)=("${m62ukot}"), halign(center) 
    putpdf table t1(5,4)=("${m63ukot}"), halign(center) 
    putpdf table t1(4,5)=("${m03ukot}"), halign(center) 
    putpdf table t1(5,5)=("${m04ukot}"), halign(center) 
    putpdf table t1(4,6)=("${m05ukot}"), halign(center) 
    putpdf table t1(5,6)=("${m06ukot}"), halign(center) 



** SLIDE 2. DAILY NEW CASES
** TITLE, ATTRIBUTION, DATE of CREATION
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("REGIONAL COVID-19 DAILY CASES"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 2"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
    ///putpdf table intro2(1,16)=("Prepared by Ian Hambleton"), halign(right)  font("Calibri Light", 13, 8c8c8c)  append
** FIGURE 
    putpdf table f2 = (1,1), width(100%) border(all,nil) halign(center)
    putpdf table f2(1,1)=image("`outputpath'/04_TechDocs/heatmap_newcases_$S_DATE.png")

** SLIDE 3. GROWTH CURVES
** TITLE, ATTRIBUTION, DATE of CREATION
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("REGIONAL COVID-19 GROWTH RATES"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 3"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
** FIGURE 
    putpdf table f2 = (1,1), width(100%) border(all,nil) halign(center)
    putpdf table f2(1,1)=image("`outputpath'/04_TechDocs/heatmap_growthrate_$S_DATE.png")

** SLIDE 4. CUMULATIVE CURVES
** TITLE, ATTRIBUTION, DATE of CREATION
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("REGIONAL COVID-19 CUMULATIVE CASES"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 4"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
** FIGURE 
    putpdf table f2 = (1,1), width(100%) border(all,nil) halign(center)
    putpdf table f2(1,1)=image("`outputpath'/04_TechDocs/heatmap_cases_$S_DATE.png")

** SLIDE 5. DEATHS
** TITLE, ATTRIBUTION, DATE of CREATION
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("REGIONAL COVID-19 DEATHS"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 5"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
** FIGURE 
    putpdf table f2 = (1,2), width(100%) border(all,nil) halign(center)
    putpdf table f2(1,1)=image("`outputpath'/04_TechDocs/heatmap_newdeaths_$S_DATE.png")
    putpdf table f2(1,2)=image("`outputpath'/04_TechDocs/heatmap_deaths_$S_DATE.png")


** SLIDE 6. GROWTH CURVES. 4 COUNTRIES
** TITLE, ATTRIBUTION, DATE of CREATION
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("REGIONAL COVID-19 GROWTH CURVES"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 6"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
** FIGURE 
    putpdf table f2 = (4,2), width(80%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("Angilla"), halign(left) font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,1)=image("`outputpath'/04_TechDocs/spark_AIA_$S_DATE.png")
    putpdf table f2(1,2)=("Antigua and Barbuda"), halign(left) font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,2)=image("`outputpath'/04_TechDocs/spark_ATG_$S_DATE.png")
    putpdf table f2(3,1)=("The Bahamas"), halign(left) font("Calibri Light", 20, 0e497c)  
    putpdf table f2(4,1)=image("`outputpath'/04_TechDocs/spark_BHS_$S_DATE.png")
    putpdf table f2(3,2)=("Barbados"), halign(left) font("Calibri Light", 20, 0e497c)  
    putpdf table f2(4,2)=image("`outputpath'/04_TechDocs/spark_BRB_$S_DATE.png")


** SLIDE 7. GROWTH CURVES. 4 COUNTRIES
** TITLE, ATTRIBUTION, DATE of CREATION
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("REGIONAL COVID-19 GROWTH CURVES"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 7"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
** FIGURE 
    putpdf table f2 = (4,2), width(80%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("Belize"), halign(left) font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,1)=image("`outputpath'/04_TechDocs/spark_BLZ_$S_DATE.png")
    putpdf table f2(1,2)=("Bermuda"), halign(left) font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,2)=image("`outputpath'/04_TechDocs/spark_BMU_$S_DATE.png")
    putpdf table f2(3,1)=("British Virgin Islands"), halign(left) font("Calibri Light", 20, 0e497c)  
    putpdf table f2(4,1)=image("`outputpath'/04_TechDocs/spark_VGB_$S_DATE.png")
    putpdf table f2(3,2)=("Cayman Islands"), halign(left) font("Calibri Light", 20, 0e497c)  
    putpdf table f2(4,2)=image("`outputpath'/04_TechDocs/spark_CYM_$S_DATE.png")


** SLIDE 8. GROWTH CURVES. 4 COUNTRIES
** TITLE, ATTRIBUTION, DATE of CREATION
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("REGIONAL COVID-19 GROWTH CURVES"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 8"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
** FIGURE 
    putpdf table f2 = (4,2), width(80%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("Dominica"), halign(left) font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,1)=image("`outputpath'/04_TechDocs/spark_DMA_$S_DATE.png")
    putpdf table f2(1,2)=("Grenada"), halign(left) font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,2)=image("`outputpath'/04_TechDocs/spark_GRD_$S_DATE.png")
    putpdf table f2(3,1)=("Guyana"), halign(left) font("Calibri Light", 20, 0e497c)  
    putpdf table f2(4,1)=image("`outputpath'/04_TechDocs/spark_GUY_$S_DATE.png")
    putpdf table f2(3,2)=("Haiti"), halign(left) font("Calibri Light", 20, 0e497c)  
    putpdf table f2(4,2)=image("`outputpath'/04_TechDocs/spark_HTI_$S_DATE.png")



** SLIDE 9. GROWTH CURVES. 4 COUNTRIES
** TITLE, ATTRIBUTION, DATE of CREATION
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("REGIONAL COVID-19 GROWTH CURVES"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 9"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
** FIGURE 
    putpdf table f2 = (4,2), width(80%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("Jamaica"), halign(left) font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,1)=image("`outputpath'/04_TechDocs/spark_JAM_$S_DATE.png")
    putpdf table f2(1,2)=("Montserrat"), halign(left) font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,2)=image("`outputpath'/04_TechDocs/spark_MSR_$S_DATE.png")
    putpdf table f2(3,1)=("St Kitts & Nevis"), halign(left) font("Calibri Light", 20, 0e497c)  
    putpdf table f2(4,1)=image("`outputpath'/04_TechDocs/spark_KNA_$S_DATE.png")
    putpdf table f2(3,2)=("St Lucia"), halign(left) font("Calibri Light", 20, 0e497c)  
    putpdf table f2(4,2)=image("`outputpath'/04_TechDocs/spark_LCA_$S_DATE.png")


** SLIDE 10. GROWTH CURVES. 4 COUNTRIES
** TITLE, ATTRIBUTION, DATE of CREATION
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("REGIONAL COVID-19 GROWTH CURVES"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 10"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
** FIGURE 
    putpdf table f2 = (4,2), width(80%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("St Vincent & the Grenadines"), halign(left) font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,1)=image("`outputpath'/04_TechDocs/spark_VCT_$S_DATE.png")
    putpdf table f2(1,2)=("Suriname"), halign(left) font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,2)=image("`outputpath'/04_TechDocs/spark_SUR_$S_DATE.png")
    putpdf table f2(3,1)=("Trinidad & Tobago"), halign(left) font("Calibri Light", 20, 0e497c)  
    putpdf table f2(4,1)=image("`outputpath'/04_TechDocs/spark_TTO_$S_DATE.png")
    putpdf table f2(3,2)=("Turks and Caicos Islands"), halign(left) font("Calibri Light", 20, 0e497c)  
    putpdf table f2(4,2)=image("`outputpath'/04_TechDocs/spark_TCA_$S_DATE.png")



** 05-AUG-2020
** EXTRA SLIDE - ALL GROWTH CURVES ON ONE SLIDES
putpdf pagebreak
    putpdf table intro2 = (1,1), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 12, 000000)  
    putpdf table intro2(1,1)=("Figure 2: "), bold halign(left)
    putpdf table intro2(1,1)=("COVID-19 outbreak growth rates for 20 CARICOM countries as of August 5 2020 (www.uwi.edu/covid19/surveillance). "), halign(left) append   
    putpdf table intro2(1,1)=("The solid line represents the growth rate for each country. The shaded regions represent the "), halign(left) append   
    putpdf table intro2(1,1)=("interquartile range (25th to 75th percentile, dark blue area) and range (5th to 95th percentile, lighter blue area) for the remaining 19 countries. "), append halign(left) linebreak  

** FIGURE 
    putpdf table f2 = (8,5), width(100%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("Angilla"), halign(left) font("Calibri Light", 12, 0e497c)  
    putpdf table f2(2,1)=image("`outputpath'/04_TechDocs/spark_AIA_$S_DATE.png")
    putpdf table f2(1,2)=("Antigua and Barbuda"), halign(left) font("Calibri Light", 12, 0e497c)  
    putpdf table f2(2,2)=image("`outputpath'/04_TechDocs/spark_ATG_$S_DATE.png")
    putpdf table f2(1,3)=("The Bahamas"), halign(left) font("Calibri Light", 12, 0e497c)  
    putpdf table f2(2,3)=image("`outputpath'/04_TechDocs/spark_BHS_$S_DATE.png")
    putpdf table f2(1,4)=("Barbados"), halign(left) font("Calibri Light", 12, 0e497c)  
    putpdf table f2(2,4)=image("`outputpath'/04_TechDocs/spark_BRB_$S_DATE.png")
    putpdf table f2(1,5)=("Belize"), halign(left) font("Calibri Light", 12, 0e497c)  
    putpdf table f2(2,5)=image("`outputpath'/04_TechDocs/spark_BLZ_$S_DATE.png")

    putpdf table f2(3,1)=("Bermuda"), halign(left) font("Calibri Light", 12, 0e497c)  
    putpdf table f2(4,1)=image("`outputpath'/04_TechDocs/spark_BMU_$S_DATE.png")
    putpdf table f2(3,2)=("British Virgin Islands"), halign(left) font("Calibri Light", 12, 0e497c)  
    putpdf table f2(4,2)=image("`outputpath'/04_TechDocs/spark_VGB_$S_DATE.png")
    putpdf table f2(3,3)=("Cayman Islands"), halign(left) font("Calibri Light", 12, 0e497c)  
    putpdf table f2(4,3)=image("`outputpath'/04_TechDocs/spark_CYM_$S_DATE.png")
    putpdf table f2(3,4)=("Dominica"), halign(left) font("Calibri Light", 12, 0e497c)  
    putpdf table f2(4,4)=image("`outputpath'/04_TechDocs/spark_DMA_$S_DATE.png")
    putpdf table f2(3,5)=("Grenada"), halign(left) font("Calibri Light", 12, 0e497c)  
    putpdf table f2(4,5)=image("`outputpath'/04_TechDocs/spark_GRD_$S_DATE.png")

    putpdf table f2(5,1)=("Guyana"), halign(left) font("Calibri Light", 12, 0e497c)  
    putpdf table f2(6,1)=image("`outputpath'/04_TechDocs/spark_GUY_$S_DATE.png")
    putpdf table f2(5,2)=("Haiti"), halign(left) font("Calibri Light", 12, 0e497c)  
    putpdf table f2(6,2)=image("`outputpath'/04_TechDocs/spark_HTI_$S_DATE.png")
    putpdf table f2(5,3)=("Jamaica"), halign(left) font("Calibri Light", 12, 0e497c)  
    putpdf table f2(6,3)=image("`outputpath'/04_TechDocs/spark_JAM_$S_DATE.png")
    putpdf table f2(5,4)=("Montserrat"), halign(left) font("Calibri Light", 12, 0e497c)  
    putpdf table f2(6,4)=image("`outputpath'/04_TechDocs/spark_MSR_$S_DATE.png")
    putpdf table f2(5,5)=("St Kitts & Nevis"), halign(left) font("Calibri Light", 12, 0e497c)  
    putpdf table f2(6,5)=image("`outputpath'/04_TechDocs/spark_KNA_$S_DATE.png")

    putpdf table f2(7,1)=("St Lucia"), halign(left) font("Calibri Light", 12, 0e497c)  
    putpdf table f2(8,1)=image("`outputpath'/04_TechDocs/spark_LCA_$S_DATE.png")
    putpdf table f2(7,2)=("St Vincent & the Grenadines"), halign(left) font("Calibri Light", 12, 0e497c)  
    putpdf table f2(8,2)=image("`outputpath'/04_TechDocs/spark_VCT_$S_DATE.png")
    putpdf table f2(7,3)=("Suriname"), halign(left) font("Calibri Light", 12, 0e497c)  
    putpdf table f2(8,3)=image("`outputpath'/04_TechDocs/spark_SUR_$S_DATE.png")
    putpdf table f2(7,4)=("Trinidad & Tobago"), halign(left) font("Calibri Light", 12, 0e497c)  
    putpdf table f2(8,4)=image("`outputpath'/04_TechDocs/spark_TTO_$S_DATE.png")
    putpdf table f2(7,5)=("Turks and Caicos Islands"), halign(left) font("Calibri Light", 12, 0e497c)  
    putpdf table f2(8,5)=image("`outputpath'/04_TechDocs/spark_TCA_$S_DATE.png")



** SLIDE 11: ANGUILLA
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 SUMMARY for Anguilla"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 11"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
** TABLE: KEY SUMMARY METRICS
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table t1 = (5,6), width(100%) halign(center)    
    putpdf table t1(1,1), font("Calibri Light", 20, 000000) colspan(6) border(all, nil) 
    putpdf table t1(2,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)  
    putpdf table t1(3,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,1), font("Calibri Light", 20, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,1), font("Calibri Light", 20, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(4,2), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,2), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,3), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,3), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,4), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,4), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,5), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,5), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,6), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,6), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(1,1)=("Summary statistics for Anguilla"), colspan(6) halign(left) font("Calibri Light", 20, 808080)
    putpdf table t1(2,2)=("Total"), halign(center) 
    putpdf table t1(2,3)=("New"), halign(center) 
    putpdf table t1(3,3)=("(1 day)"), halign(center) 
    putpdf table t1(2,4)=("New"), halign(center) 
    putpdf table t1(3,4)=("(1 week)"), halign(center) 
    putpdf table t1(2,5)=("Date of"), halign(center) 
    putpdf table t1(3,5)=("1st confirmed"), halign(center) 
    putpdf table t1(2,6)=("Days since"), halign(center) 
    putpdf table t1(3,6)=("1st confirmed"), halign(center) 
    putpdf table t1(2,1)=("Confirmed"), halign(center) 
    putpdf table t1(3,1)=("Events"), halign(center) 
    putpdf table t1(4,1)=("Cases"), halign(center) 
    putpdf table t1(5,1)=("Deaths"), halign(center)  
    putpdf table t1(4,2)=("${m01_AIA}"), halign(center) 
    putpdf table t1(5,2)=("${m02_AIA}"), halign(center) 
    putpdf table t1(4,3)=("${m60_AIA}"), halign(center) 
    putpdf table t1(5,3)=("${m61_AIA}"), halign(center) 
    putpdf table t1(4,4)=("${m62_AIA}"), halign(center) 
    putpdf table t1(5,4)=("${m63_AIA}"), halign(center) 
    putpdf table t1(4,5)=("${m03_AIA}"), halign(center) 
    putpdf table t1(5,5)=("${m04_AIA}"), halign(center) 
    putpdf table t1(4,6)=("${m05_AIA}"), halign(center) 
    putpdf table t1(5,6)=("${m06_AIA}"), halign(center) 
** FIGURE 
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table f2 = (2,1), width(95%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("Outbreak growth compared with international locations"), font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,1)=image("`outputpath'/04_TechDocs/line_AIA_$S_DATE.png")




** SLIDE 12: Antigua and Barbuda
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 SUMMARY for Antigua and Barbuda"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 12"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
** TABLE: KEY SUMMARY METRICS
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table t1 = (5,6), width(100%) halign(center)    
    putpdf table t1(1,1), font("Calibri Light", 20, 000000) colspan(6) border(all, nil) 
    putpdf table t1(2,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)  
    putpdf table t1(3,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,1), font("Calibri Light", 20, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,1), font("Calibri Light", 20, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(4,2), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,2), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,3), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,3), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,4), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,4), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,5), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,5), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,6), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,6), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(1,1)=("Summary statistics for Antigua and Barbuda"), colspan(6) halign(left) font("Calibri Light", 20, 808080)
    putpdf table t1(2,2)=("Total"), halign(center) 
    putpdf table t1(2,3)=("New"), halign(center) 
    putpdf table t1(3,3)=("(1 day)"), halign(center) 
    putpdf table t1(2,4)=("New"), halign(center) 
    putpdf table t1(3,4)=("(1 week)"), halign(center) 
    putpdf table t1(2,5)=("Date of"), halign(center) 
    putpdf table t1(3,5)=("1st confirmed"), halign(center) 
    putpdf table t1(2,6)=("Days since"), halign(center) 
    putpdf table t1(3,6)=("1st confirmed"), halign(center) 
    putpdf table t1(2,1)=("Confirmed"), halign(center) 
    putpdf table t1(3,1)=("Events"), halign(center) 
    putpdf table t1(4,1)=("Cases"), halign(center) 
    putpdf table t1(5,1)=("Deaths"), halign(center)  
    putpdf table t1(4,2)=("${m01_ATG}"), halign(center) 
    putpdf table t1(5,2)=("${m02_ATG}"), halign(center) 
    putpdf table t1(4,3)=("${m60_ATG}"), halign(center) 
    putpdf table t1(5,3)=("${m61_ATG}"), halign(center) 
    putpdf table t1(4,4)=("${m62_ATG}"), halign(center) 
    putpdf table t1(5,4)=("${m63_ATG}"), halign(center) 
    putpdf table t1(4,5)=("${m03_ATG}"), halign(center) 
    putpdf table t1(5,5)=("${m04_ATG}"), halign(center) 
    putpdf table t1(4,6)=("${m05_ATG}"), halign(center) 
    putpdf table t1(5,6)=("${m06_ATG}"), halign(center) 
** FIGURE 
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table f2 = (2,1), width(95%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("Outbreak growth compared with international locations"), font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,1)=image("`outputpath'/04_TechDocs/line_ATG_$S_DATE.png")




** SLIDE 13: The Bahamas
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 SUMMARY for The Bahamas"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 13"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
** TABLE: KEY SUMMARY METRICS
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table t1 = (5,6), width(100%) halign(center)    
    putpdf table t1(1,1), font("Calibri Light", 20, 000000) colspan(6) border(all, nil) 
    putpdf table t1(2,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)  
    putpdf table t1(3,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,1), font("Calibri Light", 20, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,1), font("Calibri Light", 20, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(4,2), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,2), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,3), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,3), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,4), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,4), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,5), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,5), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,6), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,6), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(1,1)=("Summary statistics for The Bahamas"), colspan(6) halign(left) font("Calibri Light", 20, 808080)
    putpdf table t1(2,2)=("Total"), halign(center) 
    putpdf table t1(2,3)=("New"), halign(center) 
    putpdf table t1(3,3)=("(1 day)"), halign(center) 
    putpdf table t1(2,4)=("New"), halign(center) 
    putpdf table t1(3,4)=("(1 week)"), halign(center) 
    putpdf table t1(2,5)=("Date of"), halign(center) 
    putpdf table t1(3,5)=("1st confirmed"), halign(center) 
    putpdf table t1(2,6)=("Days since"), halign(center) 
    putpdf table t1(3,6)=("1st confirmed"), halign(center) 
    putpdf table t1(2,1)=("Confirmed"), halign(center) 
    putpdf table t1(3,1)=("Events"), halign(center) 
    putpdf table t1(4,1)=("Cases"), halign(center) 
    putpdf table t1(5,1)=("Deaths"), halign(center)  
    putpdf table t1(4,2)=("${m01_BHS}"), halign(center) 
    putpdf table t1(5,2)=("${m02_BHS}"), halign(center) 
    putpdf table t1(4,3)=("${m60_BHS}"), halign(center) 
    putpdf table t1(5,3)=("${m61_BHS}"), halign(center) 
    putpdf table t1(4,4)=("${m62_BHS}"), halign(center) 
    putpdf table t1(5,4)=("${m63_BHS}"), halign(center) 
    putpdf table t1(4,5)=("${m03_BHS}"), halign(center) 
    putpdf table t1(5,5)=("${m04_BHS}"), halign(center) 
    putpdf table t1(4,6)=("${m05_BHS}"), halign(center) 
    putpdf table t1(5,6)=("${m06_BHS}"), halign(center) 
** FIGURE 
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table f2 = (2,1), width(95%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("Outbreak growth compared with international locations"), font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,1)=image("`outputpath'/04_TechDocs/line_BHS_$S_DATE.png")



** SLIDE 14: Barbados
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 SUMMARY for Barbados"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 14"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
** TABLE: KEY SUMMARY METRICS
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table t1 = (5,6), width(100%) halign(center)    
    putpdf table t1(1,1), font("Calibri Light", 20, 000000) colspan(6) border(all, nil) 
    putpdf table t1(2,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)  
    putpdf table t1(3,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,1), font("Calibri Light", 20, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,1), font("Calibri Light", 20, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(4,2), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,2), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,3), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,3), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,4), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,4), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,5), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,5), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,6), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,6), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(1,1)=("Summary statistics for Barbados"), colspan(6) halign(left) font("Calibri Light", 20, 808080)
    putpdf table t1(2,2)=("Total"), halign(center) 
    putpdf table t1(2,3)=("New"), halign(center) 
    putpdf table t1(3,3)=("(1 day)"), halign(center) 
    putpdf table t1(2,4)=("New"), halign(center) 
    putpdf table t1(3,4)=("(1 week)"), halign(center) 
    putpdf table t1(2,5)=("Date of"), halign(center) 
    putpdf table t1(3,5)=("1st confirmed"), halign(center) 
    putpdf table t1(2,6)=("Days since"), halign(center) 
    putpdf table t1(3,6)=("1st confirmed"), halign(center) 
    putpdf table t1(2,1)=("Confirmed"), halign(center) 
    putpdf table t1(3,1)=("Events"), halign(center) 
    putpdf table t1(4,1)=("Cases"), halign(center) 
    putpdf table t1(5,1)=("Deaths"), halign(center)  
    putpdf table t1(4,2)=("${m01_BRB}"), halign(center) 
    putpdf table t1(5,2)=("${m02_BRB}"), halign(center) 
    putpdf table t1(4,3)=("${m60_BRB}"), halign(center) 
    putpdf table t1(5,3)=("${m61_BRB}"), halign(center) 
    putpdf table t1(4,4)=("${m62_BRB}"), halign(center) 
    putpdf table t1(5,4)=("${m63_BRB}"), halign(center) 
    putpdf table t1(4,5)=("${m03_BRB}"), halign(center) 
    putpdf table t1(5,5)=("${m04_BRB}"), halign(center) 
    putpdf table t1(4,6)=("${m05_BRB}"), halign(center) 
    putpdf table t1(5,6)=("${m06_BRB}"), halign(center) 
** FIGURE 
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table f2 = (2,1), width(95%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("Outbreak growth compared with international locations"), font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,1)=image("`outputpath'/04_TechDocs/line_BRB_$S_DATE.png")


** SLIDE 15: Belize
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 SUMMARY for Belize"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 15"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
** TABLE: KEY SUMMARY METRICS
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table t1 = (5,6), width(100%) halign(center)    
    putpdf table t1(1,1), font("Calibri Light", 20, 000000) colspan(6) border(all, nil) 
    putpdf table t1(2,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)  
    putpdf table t1(3,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,1), font("Calibri Light", 20, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,1), font("Calibri Light", 20, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(4,2), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,2), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,3), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,3), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,4), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,4), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,5), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,5), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,6), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,6), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(1,1)=("Summary statistics for Belize"), colspan(6) halign(left) font("Calibri Light", 20, 808080)
    putpdf table t1(2,2)=("Total"), halign(center) 
    putpdf table t1(2,3)=("New"), halign(center) 
    putpdf table t1(3,3)=("(1 day)"), halign(center) 
    putpdf table t1(2,4)=("New"), halign(center) 
    putpdf table t1(3,4)=("(1 week)"), halign(center) 
    putpdf table t1(2,5)=("Date of"), halign(center) 
    putpdf table t1(3,5)=("1st confirmed"), halign(center) 
    putpdf table t1(2,6)=("Days since"), halign(center) 
    putpdf table t1(3,6)=("1st confirmed"), halign(center) 
    putpdf table t1(2,1)=("Confirmed"), halign(center) 
    putpdf table t1(3,1)=("Events"), halign(center) 
    putpdf table t1(4,1)=("Cases"), halign(center) 
    putpdf table t1(5,1)=("Deaths"), halign(center)  
    putpdf table t1(4,2)=("${m01_BLZ}"), halign(center) 
    putpdf table t1(5,2)=("${m02_BLZ}"), halign(center) 
    putpdf table t1(4,3)=("${m60_BLZ}"), halign(center) 
    putpdf table t1(5,3)=("${m61_BLZ}"), halign(center) 
    putpdf table t1(4,4)=("${m62_BLZ}"), halign(center) 
    putpdf table t1(5,4)=("${m63_BLZ}"), halign(center) 
    putpdf table t1(4,5)=("${m03_BLZ}"), halign(center) 
    putpdf table t1(5,5)=("${m04_BLZ}"), halign(center) 
    putpdf table t1(4,6)=("${m05_BLZ}"), halign(center) 
    putpdf table t1(5,6)=("${m06_BLZ}"), halign(center) 
** FIGURE 
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table f2 = (2,1), width(95%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("Outbreak growth compared with international locations"), font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,1)=image("`outputpath'/04_TechDocs/line_BLZ_$S_DATE.png")




** SLIDE 16: Bermuda
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 SUMMARY for Bermuda"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 16"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
** TABLE: KEY SUMMARY METRICS
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table t1 = (5,6), width(100%) halign(center)    
    putpdf table t1(1,1), font("Calibri Light", 20, 000000) colspan(6) border(all, nil) 
    putpdf table t1(2,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)  
    putpdf table t1(3,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,1), font("Calibri Light", 20, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,1), font("Calibri Light", 20, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(4,2), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,2), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,3), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,3), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,4), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,4), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,5), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,5), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,6), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,6), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(1,1)=("Summary statistics for Bermuda"), colspan(6) halign(left) font("Calibri Light", 20, 808080)
    putpdf table t1(2,2)=("Total"), halign(center) 
    putpdf table t1(2,3)=("New"), halign(center) 
    putpdf table t1(3,3)=("(1 day)"), halign(center) 
    putpdf table t1(2,4)=("New"), halign(center) 
    putpdf table t1(3,4)=("(1 week)"), halign(center) 
    putpdf table t1(2,5)=("Date of"), halign(center) 
    putpdf table t1(3,5)=("1st confirmed"), halign(center) 
    putpdf table t1(2,6)=("Days since"), halign(center) 
    putpdf table t1(3,6)=("1st confirmed"), halign(center) 
    putpdf table t1(2,1)=("Confirmed"), halign(center) 
    putpdf table t1(3,1)=("Events"), halign(center) 
    putpdf table t1(4,1)=("Cases"), halign(center) 
    putpdf table t1(5,1)=("Deaths"), halign(center)  
    putpdf table t1(4,2)=("${m01_BMU}"), halign(center) 
    putpdf table t1(5,2)=("${m02_BMU}"), halign(center) 
    putpdf table t1(4,3)=("${m60_BMU}"), halign(center) 
    putpdf table t1(5,3)=("${m61_BMU}"), halign(center) 
    putpdf table t1(4,4)=("${m62_BMU}"), halign(center) 
    putpdf table t1(5,4)=("${m63_BMU}"), halign(center) 
    putpdf table t1(4,5)=("${m03_BMU}"), halign(center) 
    putpdf table t1(5,5)=("${m04_BMU}"), halign(center) 
    putpdf table t1(4,6)=("${m05_BMU}"), halign(center) 
    putpdf table t1(5,6)=("${m06_BMU}"), halign(center) 
** FIGURE 
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table f2 = (2,1), width(95%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("Outbreak growth compared with international locations"), font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,1)=image("`outputpath'/04_TechDocs/line_BMU_$S_DATE.png")


** SLIDE 17: British Virgin islands
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 SUMMARY for The British Virgin Islands"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 17"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
** TABLE: KEY SUMMARY METRICS
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table t1 = (5,6), width(100%) halign(center)    
    putpdf table t1(1,1), font("Calibri Light", 20, 000000) colspan(6) border(all, nil) 
    putpdf table t1(2,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)  
    putpdf table t1(3,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,1), font("Calibri Light", 20, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,1), font("Calibri Light", 20, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(4,2), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,2), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,3), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,3), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,4), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,4), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,5), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,5), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,6), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,6), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(1,1)=("Summary statistics for The British Virgin Islands"), colspan(6) halign(left) font("Calibri Light", 20, 808080)
    putpdf table t1(2,2)=("Total"), halign(center) 
    putpdf table t1(2,3)=("New"), halign(center) 
    putpdf table t1(3,3)=("(1 day)"), halign(center) 
    putpdf table t1(2,4)=("New"), halign(center) 
    putpdf table t1(3,4)=("(1 week)"), halign(center) 
    putpdf table t1(2,5)=("Date of"), halign(center) 
    putpdf table t1(3,5)=("1st confirmed"), halign(center) 
    putpdf table t1(2,6)=("Days since"), halign(center) 
    putpdf table t1(3,6)=("1st confirmed"), halign(center) 
    putpdf table t1(2,1)=("Confirmed"), halign(center) 
    putpdf table t1(3,1)=("Events"), halign(center) 
    putpdf table t1(4,1)=("Cases"), halign(center) 
    putpdf table t1(5,1)=("Deaths"), halign(center)  
    putpdf table t1(4,2)=("${m01_VGB}"), halign(center) 
    putpdf table t1(5,2)=("${m02_VGB}"), halign(center) 
    putpdf table t1(4,3)=("${m60_VGB}"), halign(center) 
    putpdf table t1(5,3)=("${m61_VGB}"), halign(center) 
    putpdf table t1(4,4)=("${m62_VGB}"), halign(center) 
    putpdf table t1(5,4)=("${m63_VGB}"), halign(center) 
    putpdf table t1(4,5)=("${m03_VGB}"), halign(center) 
    putpdf table t1(5,5)=("${m04_VGB}"), halign(center) 
    putpdf table t1(4,6)=("${m05_VGB}"), halign(center) 
    putpdf table t1(5,6)=("${m06_VGB}"), halign(center) 
** FIGURE 
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table f2 = (2,1), width(95%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("Outbreak growth compared with international locations"), font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,1)=image("`outputpath'/04_TechDocs/line_VGB_$S_DATE.png")



** SLIDE 18: Cayman Islands
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 SUMMARY for The Cayman Islands"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 18"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
** TABLE: KEY SUMMARY METRICS
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table t1 = (5,6), width(100%) halign(center)    
    putpdf table t1(1,1), font("Calibri Light", 20, 000000) colspan(6) border(all, nil) 
    putpdf table t1(2,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)  
    putpdf table t1(3,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,1), font("Calibri Light", 20, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,1), font("Calibri Light", 20, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(4,2), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,2), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,3), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,3), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,4), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,4), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,5), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,5), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,6), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,6), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(1,1)=("Summary statistics for The Cayman Islands"), colspan(6) halign(left) font("Calibri Light", 20, 808080)
    putpdf table t1(2,2)=("Total"), halign(center) 
    putpdf table t1(2,3)=("New"), halign(center) 
    putpdf table t1(3,3)=("(1 day)"), halign(center) 
    putpdf table t1(2,4)=("New"), halign(center) 
    putpdf table t1(3,4)=("(1 week)"), halign(center) 
    putpdf table t1(2,5)=("Date of"), halign(center) 
    putpdf table t1(3,5)=("1st confirmed"), halign(center) 
    putpdf table t1(2,6)=("Days since"), halign(center) 
    putpdf table t1(3,6)=("1st confirmed"), halign(center) 
    putpdf table t1(2,1)=("Confirmed"), halign(center) 
    putpdf table t1(3,1)=("Events"), halign(center) 
    putpdf table t1(4,1)=("Cases"), halign(center) 
    putpdf table t1(5,1)=("Deaths"), halign(center)  
    putpdf table t1(4,2)=("${m01_CYM}"), halign(center) 
    putpdf table t1(5,2)=("${m02_CYM}"), halign(center) 
    putpdf table t1(4,3)=("${m60_CYM}"), halign(center) 
    putpdf table t1(5,3)=("${m61_CYM}"), halign(center) 
    putpdf table t1(4,4)=("${m62_CYM}"), halign(center) 
    putpdf table t1(5,4)=("${m63_CYM}"), halign(center) 
    putpdf table t1(4,5)=("${m03_CYM}"), halign(center) 
    putpdf table t1(5,5)=("${m04_CYM}"), halign(center) 
    putpdf table t1(4,6)=("${m05_CYM}"), halign(center) 
    putpdf table t1(5,6)=("${m06_CYM}"), halign(center) 
** FIGURE 
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table f2 = (2,1), width(95%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("Outbreak growth compared with international locations"), font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,1)=image("`outputpath'/04_TechDocs/line_CYM_$S_DATE.png")




** SLIDE 19: Dominica
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 SUMMARY for Dominica"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 19"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
** TABLE: KEY SUMMARY METRICS
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table t1 = (5,6), width(100%) halign(center)    
    putpdf table t1(1,1), font("Calibri Light", 20, 000000) colspan(6) border(all, nil) 
    putpdf table t1(2,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)  
    putpdf table t1(3,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,1), font("Calibri Light", 20, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,1), font("Calibri Light", 20, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(4,2), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,2), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,3), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,3), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,4), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,4), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,5), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,5), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,6), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,6), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(1,1)=("Summary statistics for Dominica"), colspan(6) halign(left) font("Calibri Light", 20, 808080)
    putpdf table t1(2,2)=("Total"), halign(center) 
    putpdf table t1(2,3)=("New"), halign(center) 
    putpdf table t1(3,3)=("(1 day)"), halign(center) 
    putpdf table t1(2,4)=("New"), halign(center) 
    putpdf table t1(3,4)=("(1 week)"), halign(center) 
    putpdf table t1(2,5)=("Date of"), halign(center) 
    putpdf table t1(3,5)=("1st confirmed"), halign(center) 
    putpdf table t1(2,6)=("Days since"), halign(center) 
    putpdf table t1(3,6)=("1st confirmed"), halign(center) 
    putpdf table t1(2,1)=("Confirmed"), halign(center) 
    putpdf table t1(3,1)=("Events"), halign(center) 
    putpdf table t1(4,1)=("Cases"), halign(center) 
    putpdf table t1(5,1)=("Deaths"), halign(center)  
    putpdf table t1(4,2)=("${m01_DMA}"), halign(center) 
    putpdf table t1(5,2)=("${m02_DMA}"), halign(center) 
    putpdf table t1(4,3)=("${m60_DMA}"), halign(center) 
    putpdf table t1(5,3)=("${m61_DMA}"), halign(center) 
    putpdf table t1(4,4)=("${m62_DMA}"), halign(center) 
    putpdf table t1(5,4)=("${m63_DMA}"), halign(center) 
    putpdf table t1(4,5)=("${m03_DMA}"), halign(center) 
    putpdf table t1(5,5)=("${m04_DMA}"), halign(center) 
    putpdf table t1(4,6)=("${m05_DMA}"), halign(center) 
    putpdf table t1(5,6)=("${m06_DMA}"), halign(center) 
** FIGURE 
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table f2 = (2,1), width(95%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("Outbreak growth compared with international locations"), font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,1)=image("`outputpath'/04_TechDocs/line_DMA_$S_DATE.png")


** SLIDE 20: Grenada
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 SUMMARY for Grenada"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 20"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
** TABLE: KEY SUMMARY METRICS
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table t1 = (5,6), width(100%) halign(center)    
    putpdf table t1(1,1), font("Calibri Light", 20, 000000) colspan(6) border(all, nil) 
    putpdf table t1(2,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)  
    putpdf table t1(3,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,1), font("Calibri Light", 20, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,1), font("Calibri Light", 20, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(4,2), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,2), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,3), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,3), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,4), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,4), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,5), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,5), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,6), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,6), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(1,1)=("Summary statistics for Grenada"), colspan(6) halign(left) font("Calibri Light", 20, 808080)
    putpdf table t1(2,2)=("Total"), halign(center) 
    putpdf table t1(2,3)=("New"), halign(center) 
    putpdf table t1(3,3)=("(1 day)"), halign(center) 
    putpdf table t1(2,4)=("New"), halign(center) 
    putpdf table t1(3,4)=("(1 week)"), halign(center) 
    putpdf table t1(2,5)=("Date of"), halign(center) 
    putpdf table t1(3,5)=("1st confirmed"), halign(center) 
    putpdf table t1(2,6)=("Days since"), halign(center) 
    putpdf table t1(3,6)=("1st confirmed"), halign(center) 
    putpdf table t1(2,1)=("Confirmed"), halign(center) 
    putpdf table t1(3,1)=("Events"), halign(center) 
    putpdf table t1(4,1)=("Cases"), halign(center) 
    putpdf table t1(5,1)=("Deaths"), halign(center)  
    putpdf table t1(4,2)=("${m01_GRD}"), halign(center) 
    putpdf table t1(5,2)=("${m02_GRD}"), halign(center) 
    putpdf table t1(4,3)=("${m60_GRD}"), halign(center) 
    putpdf table t1(5,3)=("${m61_GRD}"), halign(center) 
    putpdf table t1(4,4)=("${m62_GRD}"), halign(center) 
    putpdf table t1(5,4)=("${m63_GRD}"), halign(center) 
    putpdf table t1(4,5)=("${m03_GRD}"), halign(center) 
    putpdf table t1(5,5)=("${m04_GRD}"), halign(center) 
    putpdf table t1(4,6)=("${m05_GRD}"), halign(center) 
    putpdf table t1(5,6)=("${m06_GRD}"), halign(center) 
** FIGURE 
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table f2 = (2,1), width(95%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("Outbreak growth compared with international locations"), font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,1)=image("`outputpath'/04_TechDocs/line_GRD_$S_DATE.png")


** SLIDE 21: Guyana
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 SUMMARY for Guyana"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 21"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
** TABLE: KEY SUMMARY METRICS
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table t1 = (5,6), width(100%) halign(center)    
    putpdf table t1(1,1), font("Calibri Light", 20, 000000) colspan(6) border(all, nil) 
    putpdf table t1(2,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)  
    putpdf table t1(3,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,1), font("Calibri Light", 20, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,1), font("Calibri Light", 20, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(4,2), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,2), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,3), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,3), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,4), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,4), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,5), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,5), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,6), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,6), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(1,1)=("Summary statistics for Guyana"), colspan(6) halign(left) font("Calibri Light", 20, 808080)
    putpdf table t1(2,2)=("Total"), halign(center) 
    putpdf table t1(2,3)=("New"), halign(center) 
    putpdf table t1(3,3)=("(1 day)"), halign(center) 
    putpdf table t1(2,4)=("New"), halign(center) 
    putpdf table t1(3,4)=("(1 week)"), halign(center) 
    putpdf table t1(2,5)=("Date of"), halign(center) 
    putpdf table t1(3,5)=("1st confirmed"), halign(center) 
    putpdf table t1(2,6)=("Days since"), halign(center) 
    putpdf table t1(3,6)=("1st confirmed"), halign(center) 
    putpdf table t1(2,1)=("Confirmed"), halign(center) 
    putpdf table t1(3,1)=("Events"), halign(center) 
    putpdf table t1(4,1)=("Cases"), halign(center) 
    putpdf table t1(5,1)=("Deaths"), halign(center)  
    putpdf table t1(4,2)=("${m01_GUY}"), halign(center) 
    putpdf table t1(5,2)=("${m02_GUY}"), halign(center) 
    putpdf table t1(4,3)=("${m60_GUY}"), halign(center) 
    putpdf table t1(5,3)=("${m61_GUY}"), halign(center) 
    putpdf table t1(4,4)=("${m62_GUY}"), halign(center) 
    putpdf table t1(5,4)=("${m63_GUY}"), halign(center) 
    putpdf table t1(4,5)=("${m03_GUY}"), halign(center) 
    putpdf table t1(5,5)=("${m04_GUY}"), halign(center) 
    putpdf table t1(4,6)=("${m05_GUY}"), halign(center) 
    putpdf table t1(5,6)=("${m06_GUY}"), halign(center) 
** FIGURE 
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table f2 = (2,1), width(95%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("Outbreak growth compared with international locations"), font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,1)=image("`outputpath'/04_TechDocs/line_GUY_$S_DATE.png")


** SLIDE 22: Haiti
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 SUMMARY for Haiti"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 22"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
** TABLE: KEY SUMMARY METRICS
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table t1 = (5,6), width(100%) halign(center)    
    putpdf table t1(1,1), font("Calibri Light", 20, 000000) colspan(6) border(all, nil) 
    putpdf table t1(2,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)  
    putpdf table t1(3,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,1), font("Calibri Light", 20, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,1), font("Calibri Light", 20, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(4,2), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,2), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,3), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,3), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,4), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,4), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,5), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,5), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,6), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,6), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(1,1)=("Summary statistics for Haiti"), colspan(6) halign(left) font("Calibri Light", 20, 808080)
    putpdf table t1(2,2)=("Total"), halign(center) 
    putpdf table t1(2,3)=("New"), halign(center) 
    putpdf table t1(3,3)=("(1 day)"), halign(center) 
    putpdf table t1(2,4)=("New"), halign(center) 
    putpdf table t1(3,4)=("(1 week)"), halign(center) 
    putpdf table t1(2,5)=("Date of"), halign(center) 
    putpdf table t1(3,5)=("1st confirmed"), halign(center) 
    putpdf table t1(2,6)=("Days since"), halign(center) 
    putpdf table t1(3,6)=("1st confirmed"), halign(center) 
    putpdf table t1(2,1)=("Confirmed"), halign(center) 
    putpdf table t1(3,1)=("Events"), halign(center) 
    putpdf table t1(4,1)=("Cases"), halign(center) 
    putpdf table t1(5,1)=("Deaths"), halign(center)  
    putpdf table t1(4,2)=("${m01_HTI}"), halign(center) 
    putpdf table t1(5,2)=("${m02_HTI}"), halign(center) 
    putpdf table t1(4,3)=("${m60_HTI}"), halign(center) 
    putpdf table t1(5,3)=("${m61_HTI}"), halign(center) 
    putpdf table t1(4,4)=("${m62_HTI}"), halign(center) 
    putpdf table t1(5,4)=("${m63_HTI}"), halign(center) 
    putpdf table t1(4,5)=("${m03_HTI}"), halign(center) 
    putpdf table t1(5,5)=("${m04_HTI}"), halign(center) 
    putpdf table t1(4,6)=("${m05_HTI}"), halign(center) 
    putpdf table t1(5,6)=("${m06_HTI}"), halign(center) 
** FIGURE 
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table f2 = (2,1), width(95%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("Outbreak growth compared with international locations"), font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,1)=image("`outputpath'/04_TechDocs/line_HTI_$S_DATE.png")




** SLIDE 23: Jamaica
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 SUMMARY for Jamaica"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 23"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
** TABLE: KEY SUMMARY METRICS
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table t1 = (5,6), width(100%) halign(center)    
    putpdf table t1(1,1), font("Calibri Light", 20, 000000) colspan(6) border(all, nil) 
    putpdf table t1(2,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)  
    putpdf table t1(3,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,1), font("Calibri Light", 20, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,1), font("Calibri Light", 20, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(4,2), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,2), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,3), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,3), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,4), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,4), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,5), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,5), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,6), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,6), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(1,1)=("Summary statistics for Jamaica"), colspan(6) halign(left) font("Calibri Light", 20, 808080)
    putpdf table t1(2,2)=("Total"), halign(center) 
    putpdf table t1(2,3)=("New"), halign(center) 
    putpdf table t1(3,3)=("(1 day)"), halign(center) 
    putpdf table t1(2,4)=("New"), halign(center) 
    putpdf table t1(3,4)=("(1 week)"), halign(center) 
    putpdf table t1(2,5)=("Date of"), halign(center) 
    putpdf table t1(3,5)=("1st confirmed"), halign(center) 
    putpdf table t1(2,6)=("Days since"), halign(center) 
    putpdf table t1(3,6)=("1st confirmed"), halign(center) 
    putpdf table t1(2,1)=("Confirmed"), halign(center) 
    putpdf table t1(3,1)=("Events"), halign(center) 
    putpdf table t1(4,1)=("Cases"), halign(center) 
    putpdf table t1(5,1)=("Deaths"), halign(center)  
    putpdf table t1(4,2)=("${m01_JAM}"), halign(center) 
    putpdf table t1(5,2)=("${m02_JAM}"), halign(center) 
    putpdf table t1(4,3)=("${m60_JAM}"), halign(center) 
    putpdf table t1(5,3)=("${m61_JAM}"), halign(center) 
    putpdf table t1(4,4)=("${m62_JAM}"), halign(center) 
    putpdf table t1(5,4)=("${m63_JAM}"), halign(center) 
    putpdf table t1(4,5)=("${m03_JAM}"), halign(center) 
    putpdf table t1(5,5)=("${m04_JAM}"), halign(center) 
    putpdf table t1(4,6)=("${m05_JAM}"), halign(center) 
    putpdf table t1(5,6)=("${m06_JAM}"), halign(center) 
** FIGURE 
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table f2 = (2,1), width(95%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("Outbreak growth compared with international locations"), font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,1)=image("`outputpath'/04_TechDocs/line_JAM_$S_DATE.png")



** SLIDE 24: Montserrat
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 SUMMARY for Montserrat"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 24"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
** TABLE: KEY SUMMARY METRICS
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table t1 = (5,6), width(100%) halign(center)    
    putpdf table t1(1,1), font("Calibri Light", 20, 000000) colspan(6) border(all, nil) 
    putpdf table t1(2,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)  
    putpdf table t1(3,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,1), font("Calibri Light", 20, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,1), font("Calibri Light", 20, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(4,2), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,2), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,3), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,3), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,4), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,4), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,5), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,5), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,6), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,6), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(1,1)=("Summary statistics for Montserrat"), colspan(6) halign(left) font("Calibri Light", 20, 808080)
    putpdf table t1(2,2)=("Total"), halign(center) 
    putpdf table t1(2,3)=("New"), halign(center) 
    putpdf table t1(3,3)=("(1 day)"), halign(center) 
    putpdf table t1(2,4)=("New"), halign(center) 
    putpdf table t1(3,4)=("(1 week)"), halign(center) 
    putpdf table t1(2,5)=("Date of"), halign(center) 
    putpdf table t1(3,5)=("1st confirmed"), halign(center) 
    putpdf table t1(2,6)=("Days since"), halign(center) 
    putpdf table t1(3,6)=("1st confirmed"), halign(center) 
    putpdf table t1(2,1)=("Confirmed"), halign(center) 
    putpdf table t1(3,1)=("Events"), halign(center) 
    putpdf table t1(4,1)=("Cases"), halign(center) 
    putpdf table t1(5,1)=("Deaths"), halign(center)  
    putpdf table t1(4,2)=("${m01_MSR}"), halign(center) 
    putpdf table t1(5,2)=("${m02_MSR}"), halign(center) 
    putpdf table t1(4,3)=("${m60_MSR}"), halign(center) 
    putpdf table t1(5,3)=("${m61_MSR}"), halign(center) 
    putpdf table t1(4,4)=("${m62_MSR}"), halign(center) 
    putpdf table t1(5,4)=("${m63_MSR}"), halign(center) 
    putpdf table t1(4,5)=("${m03_MSR}"), halign(center) 
    putpdf table t1(5,5)=("${m04_MSR}"), halign(center) 
    putpdf table t1(4,6)=("${m05_MSR}"), halign(center) 
    putpdf table t1(5,6)=("${m06_MSR}"), halign(center) 
** FIGURE 
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table f2 = (2,1), width(95%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("Outbreak growth compared with international locations"), font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,1)=image("`outputpath'/04_TechDocs/line_MSR_$S_DATE.png")




** SLIDE 25: St Kitts and Nevis
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 SUMMARY for St Kitts and Nevis"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 25"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
** TABLE: KEY SUMMARY METRICS
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table t1 = (5,6), width(100%) halign(center)    
    putpdf table t1(1,1), font("Calibri Light", 20, 000000) colspan(6) border(all, nil) 
    putpdf table t1(2,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)  
    putpdf table t1(3,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,1), font("Calibri Light", 20, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,1), font("Calibri Light", 20, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(4,2), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,2), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,3), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,3), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,4), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,4), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,5), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,5), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,6), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,6), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(1,1)=("Summary statistics for St Kitts and Nevis"), colspan(6) halign(left) font("Calibri Light", 20, 808080)
    putpdf table t1(2,2)=("Total"), halign(center) 
    putpdf table t1(2,3)=("New"), halign(center) 
    putpdf table t1(3,3)=("(1 day)"), halign(center) 
    putpdf table t1(2,4)=("New"), halign(center) 
    putpdf table t1(3,4)=("(1 week)"), halign(center) 
    putpdf table t1(2,5)=("Date of"), halign(center) 
    putpdf table t1(3,5)=("1st confirmed"), halign(center) 
    putpdf table t1(2,6)=("Days since"), halign(center) 
    putpdf table t1(3,6)=("1st confirmed"), halign(center) 
    putpdf table t1(2,1)=("Confirmed"), halign(center) 
    putpdf table t1(3,1)=("Events"), halign(center) 
    putpdf table t1(4,1)=("Cases"), halign(center) 
    putpdf table t1(5,1)=("Deaths"), halign(center)  
    putpdf table t1(4,2)=("${m01_KNA}"), halign(center) 
    putpdf table t1(5,2)=("${m02_KNA}"), halign(center) 
    putpdf table t1(4,3)=("${m60_KNA}"), halign(center) 
    putpdf table t1(5,3)=("${m61_KNA}"), halign(center) 
    putpdf table t1(4,4)=("${m62_KNA}"), halign(center) 
    putpdf table t1(5,4)=("${m63_KNA}"), halign(center) 
    putpdf table t1(4,5)=("${m03_KNA}"), halign(center) 
    putpdf table t1(5,5)=("${m04_KNA}"), halign(center) 
    putpdf table t1(4,6)=("${m05_KNA}"), halign(center) 
    putpdf table t1(5,6)=("${m06_KNA}"), halign(center) 
** FIGURE 
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table f2 = (2,1), width(95%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("Outbreak growth compared with international locations"), font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,1)=image("`outputpath'/04_TechDocs/line_KNA_$S_DATE.png")




** SLIDE 26: St Lucia
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 SUMMARY for St Lucia"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 26"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
** TABLE: KEY SUMMARY METRICS
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table t1 = (5,6), width(100%) halign(center)    
    putpdf table t1(1,1), font("Calibri Light", 20, 000000) colspan(6) border(all, nil) 
    putpdf table t1(2,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)  
    putpdf table t1(3,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,1), font("Calibri Light", 20, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,1), font("Calibri Light", 20, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(4,2), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,2), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,3), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,3), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,4), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,4), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,5), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,5), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,6), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,6), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(1,1)=("Summary statistics for St Lucia"), colspan(6) halign(left) font("Calibri Light", 20, 808080)
    putpdf table t1(2,2)=("Total"), halign(center) 
    putpdf table t1(2,3)=("New"), halign(center) 
    putpdf table t1(3,3)=("(1 day)"), halign(center) 
    putpdf table t1(2,4)=("New"), halign(center) 
    putpdf table t1(3,4)=("(1 week)"), halign(center) 
    putpdf table t1(2,5)=("Date of"), halign(center) 
    putpdf table t1(3,5)=("1st confirmed"), halign(center) 
    putpdf table t1(2,6)=("Days since"), halign(center) 
    putpdf table t1(3,6)=("1st confirmed"), halign(center) 
    putpdf table t1(2,1)=("Confirmed"), halign(center) 
    putpdf table t1(3,1)=("Events"), halign(center) 
    putpdf table t1(4,1)=("Cases"), halign(center) 
    putpdf table t1(5,1)=("Deaths"), halign(center)  
    putpdf table t1(4,2)=("${m01_LCA}"), halign(center) 
    putpdf table t1(5,2)=("${m02_LCA}"), halign(center) 
    putpdf table t1(4,3)=("${m60_LCA}"), halign(center) 
    putpdf table t1(5,3)=("${m61_LCA}"), halign(center) 
    putpdf table t1(4,4)=("${m62_LCA}"), halign(center) 
    putpdf table t1(5,4)=("${m63_LCA}"), halign(center) 
    putpdf table t1(4,5)=("${m03_LCA}"), halign(center) 
    putpdf table t1(5,5)=("${m04_LCA}"), halign(center) 
    putpdf table t1(4,6)=("${m05_LCA}"), halign(center) 
    putpdf table t1(5,6)=("${m06_LCA}"), halign(center) 
** FIGURE 
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table f2 = (2,1), width(95%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("Outbreak growth compared with international locations"), font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,1)=image("`outputpath'/04_TechDocs/line_LCA_$S_DATE.png")


** SLIDE 27: St Vincent & the Grenadines
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 SUMMARY for St Vincent & the Grenadines"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 27"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
** TABLE: KEY SUMMARY METRICS
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table t1 = (5,6), width(100%) halign(center)    
    putpdf table t1(1,1), font("Calibri Light", 20, 000000) colspan(6) border(all, nil) 
    putpdf table t1(2,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)  
    putpdf table t1(3,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,1), font("Calibri Light", 20, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,1), font("Calibri Light", 20, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(4,2), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,2), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,3), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,3), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,4), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,4), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,5), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,5), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,6), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,6), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(1,1)=("Summary statistics for St Vincent & the Grenadines"), colspan(6) halign(left) font("Calibri Light", 20, 808080)
    putpdf table t1(2,2)=("Total"), halign(center) 
    putpdf table t1(2,3)=("New"), halign(center) 
    putpdf table t1(3,3)=("(1 day)"), halign(center) 
    putpdf table t1(2,4)=("New"), halign(center) 
    putpdf table t1(3,4)=("(1 week)"), halign(center) 
    putpdf table t1(2,5)=("Date of"), halign(center) 
    putpdf table t1(3,5)=("1st confirmed"), halign(center) 
    putpdf table t1(2,6)=("Days since"), halign(center) 
    putpdf table t1(3,6)=("1st confirmed"), halign(center) 
    putpdf table t1(2,1)=("Confirmed"), halign(center) 
    putpdf table t1(3,1)=("Events"), halign(center) 
    putpdf table t1(4,1)=("Cases"), halign(center) 
    putpdf table t1(5,1)=("Deaths"), halign(center)  
    putpdf table t1(4,2)=("${m01_VCT}"), halign(center) 
    putpdf table t1(5,2)=("${m02_VCT}"), halign(center) 
    putpdf table t1(4,3)=("${m60_VCT}"), halign(center) 
    putpdf table t1(5,3)=("${m61_VCT}"), halign(center) 
    putpdf table t1(4,4)=("${m62_VCT}"), halign(center) 
    putpdf table t1(5,4)=("${m63_VCT}"), halign(center) 
    putpdf table t1(4,5)=("${m03_VCT}"), halign(center) 
    putpdf table t1(5,5)=("${m04_VCT}"), halign(center) 
    putpdf table t1(4,6)=("${m05_VCT}"), halign(center) 
    putpdf table t1(5,6)=("${m06_VCT}"), halign(center) 
** FIGURE 
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table f2 = (2,1), width(95%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("Outbreak growth compared with international locations"), font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,1)=image("`outputpath'/04_TechDocs/line_VCT_$S_DATE.png")




** SLIDE 28: Suriname
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 SUMMARY for Suriname"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 28"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
** TABLE: KEY SUMMARY METRICS
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table t1 = (5,6), width(100%) halign(center)    
    putpdf table t1(1,1), font("Calibri Light", 20, 000000) colspan(6) border(all, nil) 
    putpdf table t1(2,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)  
    putpdf table t1(3,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,1), font("Calibri Light", 20, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,1), font("Calibri Light", 20, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(4,2), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,2), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,3), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,3), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,4), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,4), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,5), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,5), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,6), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,6), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(1,1)=("Summary statistics for Suriname"), colspan(6) halign(left) font("Calibri Light", 20, 808080)
    putpdf table t1(2,2)=("Total"), halign(center) 
    putpdf table t1(2,3)=("New"), halign(center) 
    putpdf table t1(3,3)=("(1 day)"), halign(center) 
    putpdf table t1(2,4)=("New"), halign(center) 
    putpdf table t1(3,4)=("(1 week)"), halign(center) 
    putpdf table t1(2,5)=("Date of"), halign(center) 
    putpdf table t1(3,5)=("1st confirmed"), halign(center) 
    putpdf table t1(2,6)=("Days since"), halign(center) 
    putpdf table t1(3,6)=("1st confirmed"), halign(center) 
    putpdf table t1(2,1)=("Confirmed"), halign(center) 
    putpdf table t1(3,1)=("Events"), halign(center) 
    putpdf table t1(4,1)=("Cases"), halign(center) 
    putpdf table t1(5,1)=("Deaths"), halign(center)  
    putpdf table t1(4,2)=("${m01_SUR}"), halign(center) 
    putpdf table t1(5,2)=("${m02_SUR}"), halign(center) 
    putpdf table t1(4,3)=("${m60_SUR}"), halign(center) 
    putpdf table t1(5,3)=("${m61_SUR}"), halign(center) 
    putpdf table t1(4,4)=("${m62_SUR}"), halign(center) 
    putpdf table t1(5,4)=("${m63_SUR}"), halign(center) 
    putpdf table t1(4,5)=("${m03_SUR}"), halign(center) 
    putpdf table t1(5,5)=("${m04_SUR}"), halign(center) 
    putpdf table t1(4,6)=("${m05_SUR}"), halign(center) 
    putpdf table t1(5,6)=("${m06_SUR}"), halign(center) 
** FIGURE 
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table f2 = (2,1), width(95%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("Outbreak growth compared with international locations"), font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,1)=image("`outputpath'/04_TechDocs/line_SUR_$S_DATE.png")




** SLIDE 29: Trinidad & Tobago
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 SUMMARY for Trinidad & Tobago"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 29"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
** TABLE: KEY SUMMARY METRICS
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table t1 = (5,6), width(100%) halign(center)    
    putpdf table t1(1,1), font("Calibri Light", 20, 000000) colspan(6) border(all, nil) 
    putpdf table t1(2,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)  
    putpdf table t1(3,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,1), font("Calibri Light", 20, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,1), font("Calibri Light", 20, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(4,2), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,2), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,3), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,3), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,4), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,4), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,5), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,5), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,6), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,6), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(1,1)=("Summary statistics for Trinidad & Tobago"), colspan(6) halign(left) font("Calibri Light", 20, 808080)
    putpdf table t1(2,2)=("Total"), halign(center) 
    putpdf table t1(2,3)=("New"), halign(center) 
    putpdf table t1(3,3)=("(1 day)"), halign(center) 
    putpdf table t1(2,4)=("New"), halign(center) 
    putpdf table t1(3,4)=("(1 week)"), halign(center) 
    putpdf table t1(2,5)=("Date of"), halign(center) 
    putpdf table t1(3,5)=("1st confirmed"), halign(center) 
    putpdf table t1(2,6)=("Days since"), halign(center) 
    putpdf table t1(3,6)=("1st confirmed"), halign(center) 
    putpdf table t1(2,1)=("Confirmed"), halign(center) 
    putpdf table t1(3,1)=("Events"), halign(center) 
    putpdf table t1(4,1)=("Cases"), halign(center) 
    putpdf table t1(5,1)=("Deaths"), halign(center)  
    putpdf table t1(4,2)=("${m01_TTO}"), halign(center) 
    putpdf table t1(5,2)=("${m02_TTO}"), halign(center) 
    putpdf table t1(4,3)=("${m60_TTO}"), halign(center) 
    putpdf table t1(5,3)=("${m61_TTO}"), halign(center) 
    putpdf table t1(4,4)=("${m62_TTO}"), halign(center) 
    putpdf table t1(5,4)=("${m63_TTO}"), halign(center) 
    putpdf table t1(4,5)=("${m03_TTO}"), halign(center) 
    putpdf table t1(5,5)=("${m04_TTO}"), halign(center) 
    putpdf table t1(4,6)=("${m05_TTO}"), halign(center) 
    putpdf table t1(5,6)=("${m06_TTO}"), halign(center) 
** FIGURE 
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table f2 = (2,1), width(95%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("Outbreak growth compared with international locations"), font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,1)=image("`outputpath'/04_TechDocs/line_TTO_$S_DATE.png")




** SLIDE 30: Turks & Caicos Islands
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 SUMMARY for Turks & Caicos Islands"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 30"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
** TABLE: KEY SUMMARY METRICS
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table t1 = (5,6), width(100%) halign(center)    
    putpdf table t1(1,1), font("Calibri Light", 20, 000000) colspan(6) border(all, nil) 
    putpdf table t1(2,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)  
    putpdf table t1(3,1), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,1), font("Calibri Light", 20, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,1), font("Calibri Light", 20, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,2), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(4,2), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,2), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,3), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,3), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,3), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,4), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,4), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,4), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,5), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,5), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,5), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,6), font("Calibri Light", 18, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,6), font("Calibri Light", 18, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,6), font("Calibri Light", 18, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(1,1)=("Summary statistics for Turks & Caicos Islands"), colspan(6) halign(left) font("Calibri Light", 20, 808080)
    putpdf table t1(2,2)=("Total"), halign(center) 
    putpdf table t1(2,3)=("New"), halign(center) 
    putpdf table t1(3,3)=("(1 day)"), halign(center) 
    putpdf table t1(2,4)=("New"), halign(center) 
    putpdf table t1(3,4)=("(1 week)"), halign(center) 
    putpdf table t1(2,5)=("Date of"), halign(center) 
    putpdf table t1(3,5)=("1st confirmed"), halign(center) 
    putpdf table t1(2,6)=("Days since"), halign(center) 
    putpdf table t1(3,6)=("1st confirmed"), halign(center) 
    putpdf table t1(2,1)=("Confirmed"), halign(center) 
    putpdf table t1(3,1)=("Events"), halign(center) 
    putpdf table t1(4,1)=("Cases"), halign(center) 
    putpdf table t1(5,1)=("Deaths"), halign(center)  
    putpdf table t1(4,2)=("${m01_TCA}"), halign(center) 
    putpdf table t1(5,2)=("${m02_TCA}"), halign(center) 
    putpdf table t1(4,3)=("${m60_TCA}"), halign(center) 
    putpdf table t1(5,3)=("${m61_TCA}"), halign(center) 
    putpdf table t1(4,4)=("${m62_TCA}"), halign(center) 
    putpdf table t1(5,4)=("${m63_TCA}"), halign(center) 
    putpdf table t1(4,5)=("${m03_TCA}"), halign(center) 
    putpdf table t1(5,5)=("${m04_TCA}"), halign(center) 
    putpdf table t1(4,6)=("${m05_TCA}"), halign(center) 
    putpdf table t1(5,6)=("${m06_TCA}"), halign(center) 
** FIGURE 
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table f2 = (2,1), width(95%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("Outbreak growth compared with international locations"), font("Calibri Light", 20, 0e497c)  
    putpdf table f2(2,1)=image("`outputpath'/04_TechDocs/line_TCA_$S_DATE.png")



** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    ** putpdf save "`outputpath'/05_Outputs/covid19_uwi_slides_`date_string'", replace
    ** putpdf save "`syncpath'/covid19_uwi_slides_`date_string'", replace
    putpdf save "`syncpath'/`date_string' Slides", replace
    *putpdf save "`syncpath'/covid19_uwi_slides_forClive_`date_string'", replace
