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
** Use the FULL PAPER01 dataset
** -----------------------------------------
use "`datapath'\version02\2-working\paper01_acaps", clear

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


** DATE OF FIRST CASE 
gen dofc1 = c(current_date)
gen dofc = date(dofc1, "DMY") 
format dofc %td
drop dofc1 
** Will need to add UKOTS in time
local clist = "ATG BHS BRB BLZ CUB DMA DOM GRD GUY HTI JAM KNA LCA VCT SUR TTO DEU ISL ITA NZL SGP KOR SWE GBR VNM" 
foreach country of local clist {
    replace dofc = dofc - ${m05_`country'} + 1 if iso=="`country'"
    }

** DATE OF FIRST NPI, by COUNTRY and by NPI group
bysort iso sidcon : egen fnpi = min(donpi)
format fnpi %td

** ---------------------------------------
** Example graphic -- Control Movement INTO country
** ---------------------------------------
preserve
    fillin iso sidcon 
    keep if sidcon==1

    bysort iso: gen touse = _n 
    keep if touse==1 
    replace country = "Antigua and Barbuda" if iso=="ATG"
    replace country = "St Vincent and the Grenadines" if iso=="VCT"
    drop touse _fillin aid 

    ** Elapsed days
    ** NEGATIVE = implementation before first case
    gen edays = fnpi - dofc
    gen zero = dofc - dofc 
    replace zero = 0 if zero==.

    ** Create internal numeric variable for countries 
    gen iso_num = .
    replace iso_num = 1 if iso=="ATG"
    replace iso_num = 2 if iso=="BHS"
    replace iso_num = 3 if iso=="BRB"
    replace iso_num = 4 if iso=="BLZ"
    replace iso_num = 5 if iso=="CUB"
    replace iso_num = 6 if iso=="DMA"
    replace iso_num = 7 if iso=="DOM"
    replace iso_num = 8 if iso=="GRD"
    replace iso_num = 9 if iso=="GUY"
    replace iso_num = 10 if iso=="HTI"
    replace iso_num = 11 if iso=="JAM"
    replace iso_num = 12 if iso=="KNA"
    replace iso_num = 13 if iso=="LCA"
    replace iso_num = 14 if iso=="VCT"
    replace iso_num = 15 if iso=="SUR"
    replace iso_num = 16 if iso=="TTO"
    ** comparators
    replace iso_num = 18 if iso=="DEU"      /* Germany*/
    replace iso_num = 19 if iso=="ISL"      /* Iceland*/
    replace iso_num = 20 if iso=="ITA"      /* Italy */
    replace iso_num = 21 if iso=="NZL"      /* New Zealand */
    replace iso_num = 22 if iso=="SGP"      /* Singapore */
    replace iso_num = 23 if iso=="KOR"      /* South Korea */
    replace iso_num = 24 if iso=="SWE"      /* Sweden */
    replace iso_num = 25 if iso=="GBR"      /* United Kingdom*/
    replace iso_num = 26 if iso=="VNM"      /* Vietnam */


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
            ysize(12) xsize(9)
            
            xlab(-80(20)80
            , labs(3) nogrid glc(gs16) angle(0) format(%9.0f))
            xtitle(" ", size(6) margin(l=2 r=2 t=2 b=2)) 

            text(29 -40 "Days before" "1st case" , place(c) size(3) )
            text(29 40 "Days after" "1st case" , place(c) size(3) )

            ylab(    
            1 "Antigua and Barbuda" 
            2 "The Bahamas" 
            3 "Barbados"
            4 "Belize" 
            5 "Cuba"
            6 "Dominica"
            7 "Dominican Republic" 
            8 "Grenada"
            9 "Guyana"
            10 "Haiti"
            11 "Jamaica"
            12 "St Kitts and Nevis"
            13 "St Lucia"
            14 "St Vincent"
            15 "Suriname"
            16 "Trinidad and Tobago"
            18 "Germany"
            19 "Iceland"
            20 "Italy"
            21 "New Zealand"
            22 "Singapore"
            23 "South Korea"
            24 "Sweden"
            25 "United Kingdom"
            26 "Vietnam"            
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
restore



** ---------------------------------------
** Example graphic -- Control Movement IN country
** ---------------------------------------
preserve
    fillin iso sidcon 
    keep if sidcon==2

    bysort iso: gen touse = _n 
    keep if touse==1 
    replace country = "Antigua and Barbuda" if iso=="ATG"
    replace country = "St Vincent and the Grenadines" if iso=="VCT"
    drop touse _fillin aid 

    ** Elapsed days
    ** NEGATIVE = implementation before first case
    gen edays = fnpi - dofc
    gen zero = dofc - dofc 
    replace zero = 0 if zero==.

    ** Create internal numeric variable for countries 
    gen iso_num = .
    replace iso_num = 1 if iso=="ATG"
    replace iso_num = 2 if iso=="BHS"
    replace iso_num = 3 if iso=="BRB"
    replace iso_num = 4 if iso=="BLZ"
    replace iso_num = 5 if iso=="CUB"
    replace iso_num = 6 if iso=="DMA"
    replace iso_num = 7 if iso=="DOM"
    replace iso_num = 8 if iso=="GRD"
    replace iso_num = 9 if iso=="GUY"
    replace iso_num = 10 if iso=="HTI"
    replace iso_num = 11 if iso=="JAM"
    replace iso_num = 12 if iso=="KNA"
    replace iso_num = 13 if iso=="LCA"
    replace iso_num = 14 if iso=="VCT"
    replace iso_num = 15 if iso=="SUR"
    replace iso_num = 16 if iso=="TTO"
    ** comparators
    replace iso_num = 18 if iso=="DEU"      /* Germany*/
    replace iso_num = 19 if iso=="ISL"      /* Iceland*/
    replace iso_num = 20 if iso=="ITA"      /* Italy */
    replace iso_num = 21 if iso=="NZL"      /* New Zealand */
    replace iso_num = 22 if iso=="SGP"      /* Singapore */
    replace iso_num = 23 if iso=="KOR"      /* South Korea */
    replace iso_num = 24 if iso=="SWE"      /* Sweden */
    replace iso_num = 25 if iso=="GBR"      /* United Kingdom*/
    replace iso_num = 26 if iso=="VNM"      /* Vietnam */


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
            ysize(12) xsize(9)
            
            xlab(-80(20)80
            , labs(3) nogrid glc(gs16) angle(0) format(%9.0f))
            xtitle(" ", size(6) margin(l=2 r=2 t=2 b=2)) 

            text(29 -40 "Days before" "1st case" , place(c) size(3) )
            text(29 40 "Days after" "1st case" , place(c) size(3) )

            ylab(    
            1 "Antigua and Barbuda" 
            2 "The Bahamas" 
            3 "Barbados"
            4 "Belize" 
            5 "Cuba"
            6 "Dominica"
            7 "Dominican Republic" 
            8 "Grenada"
            9 "Guyana"
            10 "Haiti"
            11 "Jamaica"
            12 "St Kitts and Nevis"
            13 "St Lucia"
            14 "St Vincent"
            15 "Suriname"
            16 "Trinidad and Tobago"
            18 "Germany"
            19 "Iceland"
            20 "Italy"
            21 "New Zealand"
            22 "Singapore"
            23 "South Korea"
            24 "Sweden"
            25 "United Kingdom"
            26 "Vietnam"            
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
restore




** ---------------------------------------
** Example graphic -- Control Movement IN country
** ---------------------------------------
preserve
    fillin iso sidcon 
    keep if sidcon==3

    bysort iso: gen touse = _n 
    keep if touse==1 
    replace country = "Antigua and Barbuda" if iso=="ATG"
    replace country = "St Vincent and the Grenadines" if iso=="VCT"
    drop touse _fillin aid 

    ** Elapsed days
    ** NEGATIVE = implementation before first case
    gen edays = fnpi - dofc
    gen zero = dofc - dofc 
    replace zero = 0 if zero==.

    ** Create internal numeric variable for countries 
    gen iso_num = .
    replace iso_num = 1 if iso=="ATG"
    replace iso_num = 2 if iso=="BHS"
    replace iso_num = 3 if iso=="BRB"
    replace iso_num = 4 if iso=="BLZ"
    replace iso_num = 5 if iso=="CUB"
    replace iso_num = 6 if iso=="DMA"
    replace iso_num = 7 if iso=="DOM"
    replace iso_num = 8 if iso=="GRD"
    replace iso_num = 9 if iso=="GUY"
    replace iso_num = 10 if iso=="HTI"
    replace iso_num = 11 if iso=="JAM"
    replace iso_num = 12 if iso=="KNA"
    replace iso_num = 13 if iso=="LCA"
    replace iso_num = 14 if iso=="VCT"
    replace iso_num = 15 if iso=="SUR"
    replace iso_num = 16 if iso=="TTO"
    ** comparators
    replace iso_num = 18 if iso=="DEU"      /* Germany*/
    replace iso_num = 19 if iso=="ISL"      /* Iceland*/
    replace iso_num = 20 if iso=="ITA"      /* Italy */
    replace iso_num = 21 if iso=="NZL"      /* New Zealand */
    replace iso_num = 22 if iso=="SGP"      /* Singapore */
    replace iso_num = 23 if iso=="KOR"      /* South Korea */
    replace iso_num = 24 if iso=="SWE"      /* Sweden */
    replace iso_num = 25 if iso=="GBR"      /* United Kingdom*/
    replace iso_num = 26 if iso=="VNM"      /* Vietnam */


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
            ysize(12) xsize(9)
            
            xlab(-80(20)80
            , labs(3) nogrid glc(gs16) angle(0) format(%9.0f))
            xtitle(" ", size(6) margin(l=2 r=2 t=2 b=2)) 

            text(29 -40 "Days before" "1st case" , place(c) size(3) )
            text(29 40 "Days after" "1st case" , place(c) size(3) )

            ylab(    
            1 "Antigua and Barbuda" 
            2 "The Bahamas" 
            3 "Barbados"
            4 "Belize" 
            5 "Cuba"
            6 "Dominica"
            7 "Dominican Republic" 
            8 "Grenada"
            9 "Guyana"
            10 "Haiti"
            11 "Jamaica"
            12 "St Kitts and Nevis"
            13 "St Lucia"
            14 "St Vincent"
            15 "Suriname"
            16 "Trinidad and Tobago"
            18 "Germany"
            19 "Iceland"
            20 "Italy"
            21 "New Zealand"
            22 "Singapore"
            23 "South Korea"
            24 "Sweden"
            25 "United Kingdom"
            26 "Vietnam"            
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
restore





** -----------------------------------------------------------
** GOOGLE MOVEMENT DATA
** -----------------------------------------------------------
** HEATMAP1 - Average DAILY drop in retail, grocery, workplace and transit mobility dimensions
** HEATMAP2 - Average Daily increase in "stay at home" behaviour
** BAR CHARTS - 2 per country - long and thin
** -----------------------------------------------------------

use "`datapath'\version02\2-working\paper01_google", clear
egen movement = rowmean(orig_retail orig_grocery orig_transit orig_work)
gen home = orig_residential 

bysort iso: asrol movement , stat(mean) window(date 3) gen(movement_av3)
bysort iso: asrol home , stat(mean) window(date 3) gen(home_av3)

    ** New numeric running from 1 to 14 
    gen corder = .
    replace corder = 1 if iso=="ATG"
    replace corder = 2 if iso=="BHS"       
    replace corder = 3 if iso=="BRB"      
    replace corder = 4 if iso=="BLZ"       
    replace corder = 5 if iso=="DOM"       
    replace corder = 6 if iso=="HTI"      
    replace corder = 7 if iso=="JAM"      
    replace corder = 8 if iso=="TTO"  
    replace corder = 9 if iso=="ITA"  
    replace corder = 10 if iso=="NZL"  
    replace corder = 11 if iso=="SGP"  
    replace corder = 12 if iso=="ESP"  
    replace corder = 13 if iso=="GRB"  
    replace corder = 14 if iso=="USA"  
    replace corder = 15 if iso=="VNM"  

** Automate final date on x-axis 
** Use latest date in dataset 
egen fdate1 = max(date)
global fdate = fdate1 
global fdatef : di %tdD_m date("$S_DATE", "DMY")


#delimit ;
    heatplot movement_av3 i.corder date
    ,
    ///color(spmap, blues)
    color(RdYlGn, reverse)
    cuts(@min(10)@max)
    keylabels(all, range(1))
    p(lcolor(white) lalign(center) lw(0.05))
    discrete
    statistic(asis)

    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
    ysize(9) xsize(15)

    ylab(
            1 "Antigua and Barbuda" 
            2 "The Bahamas" 
            3 "Barbados"
            4 "Belize" 
            5 "Dominican Republic"
            6 "Haiti"
            7 "Jamaica"
            8 "Trinidad and Tobago"
            9 "Italy"
            10 "New Zealand"
            11 "Singapore"
            12 "Spain"
            13 "United Kingdom"
            14 "United States"
            15 "Vietnam"

    , labs(2.75) notick nogrid glc(gs16) angle(0))
    yscale(reverse fill noline range(0(1)14)) 
    ///yscale(log reverse fill noline) 
    ytitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 

    xlab(
            21964 "19 Feb" 
            21974 "29 Feb" 
            21984 "10 Mar" 
            21994 "20 Mar" 
            22004 "30 Mar" 
            22015 "10 Apr"
            22025 "20 Apr"
            22035 "30 Apr"
            ///$fdate "$fdatef"
    , labs(2.75) nogrid glc(gs16) angle(45) format(%9.0f))
    xtitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 

    title("Change in movement data $S_DATE", pos(11) ring(1) size(3.5))

    legend(size(2.75) position(2) ring(5) colf cols(1) lc(gs16)
    region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
    sub("Movement" "Change (%)", size(2.75))
                    )
    name(heatmap_movement) 
    ;
#delimit cr
/// graph export "`outputpath'/04_TechDocs/heatmap_growthrate_$S_DATE.png", replace width(4000)



** BAR CHART 
** BARBADOS
#delimit ;
    graph twoway
    (bar movement date if movement>0 & iso=="BRB", color(red%50)  barw(0.75))
    (bar movement date if movement<=0 & iso=="BRB", color(green%50) barw(0.75) )
    ,
    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
    ysize(3) xsize(15)

    ylab(-100(40)20
    , labs(7) notick nogrid glc(gs16) angle(0))
    yscale(fill noline) 
    ytitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 

    xlab(
            21964 "             " 
            21974 "      " 
            21984 "      " 
            21994 "      " 
            22004 "      " 
            22015 "      "
            22025 "      "
            22035 "      "
            ///$fdate "$fdatef"
    , labs(7) nogrid glc(gs16) angle(45) format(%9.0f))
    xtitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 
    xscale(noline) 

    title("Barbados: $S_DATE", pos(11) ring(1) size(9))

    legend(off size(2.75) position(2) ring(5) colf cols(1) lc(gs16)
    region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
    sub("Movement" "Change (%)", size(2.75))
                    )
    name(bar_movement1) 
    ;
#delimit cr
graph export "`outputpath'/04_TechDocs/movement_BRB_$S_DATE.png", replace width(4000)


** BARBADOS
#delimit ;
    graph twoway
    (bar movement date if movement>0 & iso=="TTO", color(red%50)  barw(0.75))
    (bar movement date if movement<=0 & iso=="TTO", color(green%50) barw(0.75) )
    ,
    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
    ysize(3) xsize(15)

    ylab(-100(40)20
    , labs(7) notick nogrid glc(gs16) angle(0))
    yscale(fill noline) 
    ytitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 

    xlab(
            21964 "             " 
            21974 "      " 
            21984 "      " 
            21994 "      " 
            22004 "      " 
            22015 "      "
            22025 "      "
            22035 "      "
            ///$fdate "$fdatef"
    , labs(7) nogrid glc(gs16) angle(45) format(%9.0f))
    xtitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 
    xscale(noline) 

    title("Trinidad and Tobago: $S_DATE", pos(11) ring(1) size(9))

    legend(off size(2.75) position(2) ring(5) colf cols(1) lc(gs16)
    region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
    sub("Movement" "Change (%)", size(2.75))
                    )
    name(bar_movement2) 
    ;
#delimit cr
graph export "`outputpath'/04_TechDocs/movement_TTO_$S_DATE.png", replace width(4000)


** JAMAICA
#delimit ;
    graph twoway
    (bar movement date if movement>0 & iso=="JAM", color(red%50)  barw(0.75))
    (bar movement date if movement<=0 & iso=="JAM", color(green%50) barw(0.75) )
    ,
    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
    ysize(3) xsize(15)

    ylab(-100(40)20
    , labs(7) notick nogrid glc(gs16) angle(0))
    yscale(fill noline) 
    ytitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 

    xlab(
            21964 "19 Feb" 
            21974 "29 Feb" 
            21984 "10 Mar" 
            21994 "20 Mar" 
            22004 "30 Mar" 
            22015 "10 Apr"
            22025 "20 Apr"
            22035 "30 Apr"
            ///$fdate "$fdatef"
    , labs(7) nogrid glc(gs16) angle(45) format(%9.0f))
    xtitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 
    xscale(noline) 

    title("Jamaica: $S_DATE", pos(11) ring(1) size(9))

    legend(off size(2.75) position(2) ring(5) colf cols(1) lc(gs16)
    region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
    sub("Movement" "Change (%)", size(2.75))
                    )
    name(bar_movement3) 
    ;
#delimit cr
graph export "`outputpath'/04_TechDocs/movement_JAM_$S_DATE.png", replace width(4000)
