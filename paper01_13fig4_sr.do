** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					paper01_13fig4.do
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
    log using "`logpath'\paper01_14fig4", replace
** HEADER -----------------------------------------------------

** -----------------------------------------
** Pre-Load the COVID metrics --> as Global Macros
** -----------------------------------------
qui do "`logpath'\paper01_04metrics"
** -----------------------------------------

** Close any open log file and open a new log file
capture log close
log using "`logpath'\paper01_14fig4", replace

** Attack Rate (per 1,000 --> not yet used)
gen confirmed_rate = (confirmed / pop) * 10000
** Fix --> Single Montserrat value 
replace confirmed = 5 if confirmed==0 & iso_num==22 & date==d(01apr2020)

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
use "`datapath'\version02\2-working\paper01_acaps_sr", clear

** NPI Indicator (0 = No and 2=Yes)
gen measure = yn_npi * 2

gen snpi_order = snpi 
recode snpi_order (4=5) (5=6) (6=7) (7=8) (8=10) (9=11) (10=12)

#delimit ;
label define snpi_order_
                1 "Border controls"
                2 "Partial border closure"
                3 "Full border closure"
                5 "Mobility restrictions"
                6 "Curfews"
                7 "Partial lockdown"
                8 "Full lockdown"
                10 "Limit public gatherings"
                11 "Close public services"
                12 "Close schools";
#delimit cr 
label values snpi_order snpi_order_

** Y-AXIS NUMERIC
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



** DATES for GRAPHIC
** (1) Date of final analysis 
gen dofc1 = c(current_date)
gen dofc = date(dofc1, "DMY") 
format dofc %td
drop dofc1 
** (2) DATE OF FINAL ANALYSIS - ELAPSED DAYS FROM 1st CASE = DATE OF FIRST CASE
local clist = "AIA ATG BHS BRB BMU VGB CYM BLZ CUB DMA DOM GRD GUY HTI JAM MSR KNA LCA VCT SUR TTO TCA DEU ISL ITA NZL SGP KOR SWE GBR VNM" 
foreach country of local clist {
    replace dofc = dofc - ${m05_`country'} + 1 if iso=="`country'"
    }

** ---------------------------------------
** Graphic -- Control Movement INTO country
** ---------------------------------------
preserve
    keep if mnpi==1 
    collapse (min) min_donpi=donpi , by(iso iso_num dofc ctype)
    ** Elapsed days
    ** NEGATIVE = implementation before first case
    gen edays = min_donpi - dofc
    gen zero = dofc - dofc 

    #delimit ;
        gr twoway 
            (line iso_num zero, lw(0.25) lp("l") lc(gs13)) 
            (rbar zero edays iso_num if edays<0, horiz barwidth(0.25) col(green%50) lw(none))
            (rbar zero edays iso_num if edays>0, horiz barwidth(0.25) col(red%50) lw(none))
            (scat iso_num edays if edays<0, msize(2.5) mc(green%75) m(o))
            (scat iso_num edays if edays>0, msize(2.5) mc(red%75) m(o))
            (scat iso_num edays if edays==0, msize(2.5) mc(gs6%75) m(o)
            )
            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(14) xsize(9)
            
            xlab(-80(20)80
            , labs(3) nogrid glc(gs16) angle(0) format(%9.0f))
            xtitle(" ", size(6) margin(l=2 r=2 t=2 b=2)) 

            text(35 -40 "Days before" "1st case" , place(c) size(3) )
            text(35 40 "Days after" "1st case" , place(c) size(3) )

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
            , labs(3) notick nogrid glc(gs16) angle(0))
            yscale( fill noline reverse) 
            ytitle(" ", size(3) margin(l=2 r=2 t=2 b=2)) 
            
            title("(A) Control movement into country", pos(11) ring(1) size(4))

            legend(off size(3) position(5) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                )
                name(acaps_movement_into) 
                ;
        #delimit cr
        ///graph export "`outputpath'/04_TechDocs/bar_`country'_$S_DATE.png", replace width(6000)

    ** Average elapsed time by region
    table ctype, c(mean edays p50 edays p25 edays p75 edays)
restore



** ---------------------------------------
** Example graphic -- Control Movement IN country
** ---------------------------------------
preserve
    keep if mnpi==2 
    collapse (min) min_donpi=donpi , by(iso iso_num dofc ctype)
    ** Elapsed days
    ** NEGATIVE = implementation before first case
    gen edays = min_donpi - dofc
    gen zero = dofc - dofc 

    #delimit ;
        gr twoway 
            (line iso_num zero, lw(0.25) lp("l") lc(gs13)) 
            (rbar zero edays iso_num if edays<0, horiz barwidth(0.25) col(green%50) lw(none))
            (rbar zero edays iso_num if edays>0, horiz barwidth(0.25) col(red%50) lw(none))
            (scat iso_num edays if edays<0, msize(2.5) mc(green%75) m(o))
            (scat iso_num edays if edays>0, msize(2.5) mc(red%75) m(o))
            (scat iso_num edays if edays==0, msize(2.5) mc(gs6%75) m(o)
            )
            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(14) xsize(9)
            
            xlab(-80(20)80
            , labs(3) nogrid glc(gs16) angle(0) format(%9.0f))
            xtitle(" ", size(6) margin(l=2 r=2 t=2 b=2)) 

            text(35 -40 "Days before" "1st case" , place(c) size(3) )
            text(35 40 "Days after" "1st case" , place(c) size(3) )

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
            , labs(3) notick nogrid glc(gs16) angle(0))
            yscale( fill noline reverse) 
            ytitle(" ", size(3) margin(l=2 r=2 t=2 b=2)) 
            
            title("(B) Control movement in country", pos(11) ring(1) size(4))

            legend(off size(3) position(5) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                )
                name(acaps_movement_in) 
                ;
        #delimit cr
        ///graph export "`outputpath'/04_TechDocs/bar_`country'_$S_DATE.png", replace width(6000)

    ** Average elapsed time by region
    table ctype, c(mean edays p50 edays p25 edays p75 edays)

restore




** ---------------------------------------
** Example graphic -- Control Gatherings
** ---------------------------------------
preserve
    keep if mnpi==3
    collapse (min) min_donpi=donpi , by(iso iso_num dofc ctype)
    ** Elapsed days
    ** NEGATIVE = implementation before first case
    gen edays = min_donpi - dofc
    gen zero = dofc - dofc 

    #delimit ;
        gr twoway 
            (line iso_num zero, lw(0.25) lp("l") lc(gs13)) 
            (rbar zero edays iso_num if edays<0, horiz barwidth(0.25) col(green%50) lw(none))
            (rbar zero edays iso_num if edays>0, horiz barwidth(0.25) col(red%50) lw(none))
            (scat iso_num edays if edays<0, msize(2.5) mc(green%75) m(o))
            (scat iso_num edays if edays>0, msize(2.5) mc(red%75) m(o))
            (scat iso_num edays if edays==0, msize(2.5) mc(gs6%75) m(o)
            )
            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(14) xsize(9)
            
            xlab(-80(20)80
            , labs(3) nogrid glc(gs16) angle(0) format(%9.0f))
            xtitle(" ", size(6) margin(l=2 r=2 t=2 b=2)) 

            text(35 -40 "Days before" "1st case" , place(c) size(3) )
            text(35 40 "Days after" "1st case" , place(c) size(3) )

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
            , labs(3) notick nogrid glc(gs16) angle(0))
            yscale( fill noline reverse) 
            ytitle(" ", size(3) margin(l=2 r=2 t=2 b=2)) 
            
            title("(C) Control gatherings", pos(11) ring(1) size(4))

            legend(off size(3) position(5) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                )
                name(acaps_gatherings) 
                ;
        #delimit cr
        ///graph export "`outputpath'/04_TechDocs/bar_`country'_$S_DATE.png", replace width(6000)

    ** Average elapsed time by region
    table ctype, c(mean edays p50 edays p25 edays p75 edays)     
restore

