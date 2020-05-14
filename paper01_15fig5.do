** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					paper01_15fig5.do
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
    log using "`logpath'\paper01_15fig5", replace
** HEADER -----------------------------------------------------


** -----------------------------------------
** Pre-Load the COVID metrics --> as Global Macros
** -----------------------------------------
qui do "`logpath'\paper01_04metrics"
** -----------------------------------------

** Close any open log file and open a new log file
capture log close
log using "`logpath'\paper01_15fig5", replace

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
drop if logtype==2

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
bysort iso sidcon : egen npi1 = min(donpi)
format npi1 %td

** Global macros for ALL MINIMUM and MAXIMUM dates
local clist = "ATG BHS BRB BLZ CUB DMA DOM GRD GUY HTI JAM KNA LCA VCT SUR TTO DEU ISL ITA NZL SGP KOR SWE GBR VNM" 
foreach country of local clist {
    forval x = 1(1)3 {
        sort iso sidcon 
        gen d1 = donpi if iso=="`country'" & sidcon==`x'
        egen d2 = min(d1)
        global min_`country'`x' = d2
        egen d3 = max(d1)
        global max_`country'`x' = d3
        global dif_`country'`x'
        drop d1 d2 d3
        }
    }

** CURFEW / PARTIAL LOCKDOWN / FULL LOCKDOWN DATES
replace doplock = doplock+1 if doplock == docurf
replace doflock = doflock+1 if doflock == docurf
replace doflock = doflock+1 if doflock == doplock

local clist = "ATG BHS BRB BLZ CUB DMA DOM GRD GUY HTI JAM KNA LCA VCT SUR TTO DEU ISL ITA NZL SGP KOR SWE GBR VNM" 
foreach country of local clist {
        gen d1 = docurf if iso=="`country'"
        egen d2 = min(d1)
        global curfew_`country' = d2

        gen d3 = doplock if iso=="`country'"
        egen d4 = min(d3)
        global plock_`country' = d4

        gen d5 = doflock if iso=="`country'"
        egen d6 = min(d5)
        global flock_`country' = d6

        /// Minimum of the three
        egen d7 = rowmin(d2 d4 d6)
        global minnpi_`country' = d7
        /// Maximum of the three
        egen d8 = rowmax(d2 d4 d6)
        global maxnpi_`country' = d8

        drop d1 d2 d3 d4 d5 d6 d7 d8
        }



** -----------------------------------------------------------
** GOOGLE MOVEMENT DATA
** HORIZONTAL STACKED BAR CHART
** -----------------------------------------------------------

use "`datapath'\version02\2-working\paper01_google", clear
egen movement = rowmean(orig_retail orig_grocery orig_transit orig_work)
gen home = orig_residential 

bysort iso: asrol movement , stat(mean) window(date 3) gen(movement_av3)
bysort iso: asrol home , stat(mean) window(date 3) gen(home_av3)

    ** Create internal numeric variable for countries 
    gen iso_num = .
    replace iso_num = 1 if iso=="ATG"
    replace iso_num = 2 if iso=="BHS"
    replace iso_num = 3 if iso=="BRB"
    replace iso_num = 4 if iso=="BLZ"
    replace iso_num = 5 if iso=="DOM"
    replace iso_num = 6 if iso=="HTI"
    replace iso_num = 7 if iso=="JAM"
    replace iso_num = 8 if iso=="TTO"
    ** comparators
    replace iso_num = 10 if iso=="DEU"      /* Germany*/
    replace iso_num = 11 if iso=="ITA"      /* Italy */
    replace iso_num = 12 if iso=="NZL"      /* New Zealand */
    replace iso_num = 13 if iso=="SGP"      /* Singapore */
    replace iso_num = 14 if iso=="KOR"      /* South Korea */
    replace iso_num = 15 if iso=="SWE"      /* Sweden */
    replace iso_num = 16 if iso=="GBR"      /* United Kingdom*/
    replace iso_num = 17 if iso=="VNM"      /* Vietnam */

label define iso_num_ 1 "Antigua" 2 "Bahamas" 3 "Barbados" 4 "Belize" 5 "Dom Rep" 6 "Haiti" 7 "Jamaica" 8 "Trinidad"   ///
                      10 "Germany" 11 "Italy" 12 "New Zealand" 13 "Singapore" 14 "S.Korea" 15 " Sweden" 16 "UK" 17 "Vietnam"
label values iso_num iso_num_

** Summary movement metrics

** 1. Weekly summary 
**    26feb2020 = start of week 9
gen woy = week(date)

tempfile movement1 movement2 movement3
save `movement1', replace

** Collapse the movement dataset 
collapse (mean) avmov=movement (p50) p50mov=movement (min) minmov=movement, by(iso_num woy)
** Minimum average weekly movement reduction
keep if woy>9 & woy<18
bysort iso_num: egen t1 = min(avmov)
gen t2 = woy if t1==avmov
bysort iso_num : egen minwoy = min(t2) 
drop t1 t2
collapse (min) minavmov=avmov, by(iso_num minwoy)
save `movement2', replace 

** Average through April (WKS 14 to 17)
use `movement1', clear
collapse (mean) avmov=movement (p50) p50mov=movement (min) minmov=movement, by(iso_num woy)
keep if woy>9 & woy<18
gen woy1 = woy 
recode woy1 (10 11 12 13 = 1) (14 15 16 17 = 2)
label define woy1_ 1 "march" 2 "april" 
label values woy1 woy1_ 
collapse (mean) avmov=avmov, by(iso_num woy1)
rename woy1 month 
reshape wide avmov, i(iso_num) j(month)

merge 1:1 iso_num using `movement2' 
drop _merge

        #delimit ;
        gr twoway 
            (bar minavmov iso_num , horiz lcol(gs16) fcol("52 153 75") barwidth(0.9))           
            (bar avmov2 iso_num , horiz lcol(gs16) fcol("117 204 128") barwidth(0.9))           
            (bar avmov1 iso_num , horiz lcol(gs16) fcol("180 242 184") barwidth(0.9))           
            /// Antigua
            (scatteri 1 32 , msize(4) mlc(gs8%50) mfcolor("66 146 198%50"))
            (scatteri 1 21 , msize(4) mlc(gs8%50) mfcolor("241 105 19%0"))
            (scatteri 1 10 , msize(4) mlc(gs8%50) mfcolor("128 125 186%50"))
            /// Bahamas
            (scatteri 2 32 , msize(4) mlc(gs8%50) mfcolor("66 146 198%0"))
            (scatteri 2 21 , msize(4) mlc(gs8%50) mfcolor("241 105 19%0"))
            (scatteri 2 10 , msize(4) mlc(gs8%50) mfcolor("128 125 186%50")
            )
            ,
            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(10) xsize(12)


            xlab(0(-20)-100   
            , labs(3) nogrid glc(gs16) angle(45) format(%9.0f))
            xtitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 
            xscale(noextend reverse) 
                
            ylab(
                1 "Antigua and Barbuda" 
                2 "The Bahamas" 
                3 "Barbados"
                4 "Belize" 
                5 "Dominican Republic"
                6 "Haiti"
                7 "Jamaica"
                8 "Trinidad and Tobago"
                10 "Germany"
                11 "Italy"
                12 "New Zealand"
                13 "Singapore"
                14 "South Korea"
                15 "Sweden"
                16 "United Kingdom"
                17 "Vietnam"                
            , labs(3) notick nogrid glc(gs16) angle(0))
            yscale(reverse fill noline range(0(1)14)) 
            ytitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 
            
            ///title("", pos(11) ring(1) size(4))

            legend(off size(3) position(12) ring(1) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                order(1 2 3 4) 
                lab(1 "xxx")
                lab(2 "xxx")
                lab(3 "xxx")
                lab(4 "xxx")
                )
                name(movement_bar) 
                ;
        #delimit cr
        ///graph export "`outputpath'/04_TechDocs/cumcases_region_$S_DATE.png", replace width(4000)




/*
