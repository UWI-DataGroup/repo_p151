** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					paper01_09scratch.do
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
    log using "`logpath'\paper01_09scratch", replace
** HEADER -----------------------------------------------------

** -----------------------------------------
** Pre-Load the COVID metrics --> as Global Macros
** -----------------------------------------
qui do "`logpath'\paper01_04metrics"
** -----------------------------------------

** Close any open log file and open a new log file
capture log close
log using "`logpath'\covidprofiles_006_region1_v3", replace

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
gen confirmed_rate = (confirmed / pop) * 10000
** "Fix" --> Early Guyana values 
replace confirmed = 4 if iso_num==14 & date>=d(17mar2020) & date<=d(23mar2020)
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
use "`datapath'\version02\2-working\paper01_dataset", clear

/*
** Basic heatmap of 31 NPI measures 
** Initial data preparation
preserve
    gen k=1 
    collapse (count) k, by(iso imeasure)
    fillin iso imeasure 
    replace k = 0 if k==.
    gen gmeasure = 0
    bysort iso imeasure: replace gmeasure = 1 if k>=1

    ** New numeric running from 1 to 14 
    gen corder = .
    replace corder = 1 if iso=="ATG"
    replace corder = 2 if iso=="BHS"       
    replace corder = 3 if iso=="BRB"      
    replace corder = 4 if iso=="BLZ"       
    replace corder = 5 if iso=="CUB"       
    replace corder = 6 if iso=="DMA"       
    replace corder = 7 if iso=="DOM"       
    replace corder = 8 if iso=="GRD"       
    replace corder = 9 if iso=="GUY"      
    replace corder = 10 if iso=="HTI"      
    replace corder = 11 if iso=="JAM"      
    replace corder = 12 if iso=="KNA"      
    replace corder = 13 if iso=="LCA"      
    replace corder = 14 if iso=="VCT"      
    replace corder = 15 if iso=="SUR"     
    replace corder = 16 if iso=="TTO"     

    ** NPI Indicator (0 = No and 2=Yes)
    gen gm2 = gmeasure*2


    #delimit ;
        heatplot gm2 i.corder i.imeasure 
        ,
        colors(#e0726c #83c983)
        cuts(@min(1)@max)
        p(lcolor(gs16) lalign(center) lw(0.05))
        discrete
        statistic(asis)

        plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
        graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
        ysize(8) xsize(15)

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
        , labs(2.75) notick nogrid glc(gs16) angle(0))
        yscale(reverse fill noline range(0(1)16)) 
        ///yscale(log reverse fill noline) 
        ytitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 

        xlab(
        , labs(2.75) nogrid glc(gs16) angle(45) format(%9.0f))
        xtitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 

        title("NPIs implemented by $S_DATE", pos(11) ring(1) size(3.5))

        legend(size(2.75) position(2) ring(5) colf cols(1) lc(gs16)
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
restore 


*/

** Bar / Line chart
** Number of days pre and post 1st case

** DATE OF FIRST CASE 
gen dofc1 = c(current_date)
gen dofc = date(dofc1, "DMY") 
format dofc %td
drop dofc1 
local clist = "ATG BHS BRB BLZ CUB DMA DOM GRD GUY HTI JAM KNA LCA VCT SUR TTO" 
foreach country of local clist {
    replace dofc = dofc - ${m05_`country'} + 1 if iso=="`country'"
    }

** DATE OF FIRST NPI, by COUNTRY and by NPI group
bysort iso imeasure : egen fnpi = min(donpi)
format fnpi %td


** ---------------------------------------
** Example graphic -- Border Closure at population level
** ---------------------------------------
preserve
    fillin iso imeasure 
    keep if imeasure==5
    replace tgroup = . if tgroup==1

    sort iso tgroup 
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



    #delimit ;
        gr twoway 
            (line iso_num zero, lw(0.25) lp("-") lc(gs13)) 
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
            ysize(12) xsize(12)
            
            xlab(-20(10)20
            , labs(3) nogrid glc(gs16) angle(0) format(%9.0f))
            xtitle(" ", size(6) margin(l=2 r=2 t=2 b=2)) 

            text(19 -10 "Days before" "1st case" , place(c) size(3) )
            text(19 10 "Days after" "1st case" , place(c) size(3) )

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
            , labs(3) notick nogrid glc(gs16) angle(0))
            yscale( fill noline reverse) 
            ytitle(" ", size(3) margin(l=2 r=2 t=2 b=2)) 
            
            title("Border closure", pos(11) ring(1) size(4))

            legend(off size(3) position(5) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                )
                name(acaps_border) 
                ;
        #delimit cr
        ///graph export "`outputpath'/04_TechDocs/bar_`country'_$S_DATE.png", replace width(6000)
restore


** ---------------------------------------
** Example graphic -- Curfew 
** ---------------------------------------
preserve
    fillin iso imeasure 
    keep if imeasure==8
    replace tgroup = . if tgroup==1

    sort iso tgroup 
    bysort iso: gen touse = _n 
    keep if touse==1 
    replace country = "The Bahamas" if iso=="BHS"
    replace country = "Cuba" if iso=="CUB"
    replace country = "St Kitts and Nevis" if iso=="KNA"
    replace country = "St Vincent and the Grenadines" if iso=="VCT"
    replace country = "Trinidad and Tobago" if iso=="TTO"
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



    #delimit ;
        gr twoway 
            (line iso_num zero, lw(0.25) lp("-") lc(gs13)) 
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
            ysize(12) xsize(12)
            
            xlab(-20(10)20
            , labs(3) nogrid glc(gs16) angle(0) format(%9.0f))
            xtitle(" ", size(6) margin(l=2 r=2 t=2 b=2)) 

            text(19 -10 "Days before" "1st case" , place(c) size(3) )
            text(19 10 "Days after" "1st case" , place(c) size(3) )

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
            , labs(3) notick nogrid glc(gs16) angle(0))
            yscale( fill noline reverse) 
            ytitle(" ", size(3) margin(l=2 r=2 t=2 b=2)) 
            
            title("Curfew", pos(11) ring(1) size(4))

            legend(off size(3) position(5) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                )
                name(acaps_curfew) 
                ;
        #delimit cr
        ///graph export "`outputpath'/04_TechDocs/bar_`country'_$S_DATE.png", replace width(6000)
restore


** ---------------------------------------
** Example graphic -- Full Lockdown 
** ---------------------------------------
preserve
    fillin iso imeasure 
    keep if imeasure==12
    replace tgroup = . if tgroup==1

    sort iso tgroup 
    bysort iso: gen touse = _n 
    keep if touse==1 
    replace country = "Belize" if iso=="BLZ"
    replace country = "Cuba" if iso=="CUB"  
    replace country = "Dominican Republic" if iso=="DOM"
    replace country = "Guyana" if iso=="GUY"
    replace country = "Haiti" if iso=="HTI"
    replace country = "Jamaica" if iso=="JAM"
    replace country = "St Kitts and Nevis" if iso=="KNA"
    replace country = "St Lucia" if iso=="LCA"
    replace country = "Suriname" if iso=="SUR"
    replace country = "St Vincent and the Grenadines" if iso=="VCT"
    replace country = "Trinidad and Tobago" if iso=="TTO"
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



    #delimit ;
        gr twoway 
            (line iso_num zero, lw(0.25) lp("-") lc(gs13)) 
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
            ysize(12) xsize(12)
            
            xlab(-20(10)20
            , labs(3) nogrid glc(gs16) angle(0) format(%9.0f))
            xtitle(" ", size(6) margin(l=2 r=2 t=2 b=2)) 

            text(19 -10 "Days before" "1st case" , place(c) size(3) )
            text(19 10 "Days after" "1st case" , place(c) size(3) )

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
            , labs(3) notick nogrid glc(gs16) angle(0))
            yscale( fill noline reverse) 
            ytitle(" ", size(3) margin(l=2 r=2 t=2 b=2)) 
            
            title("Full Lockdown", pos(11) ring(1) size(4))

            legend(off size(3) position(5) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                )
                name(acaps_lockdown) 
                ;
        #delimit cr
        ///graph export "`outputpath'/04_TechDocs/bar_`country'_$S_DATE.png", replace width(6000)
restore


** ---------------------------------------
** Example graphic -- Full Lockdown 
** ---------------------------------------
preserve
    fillin iso imeasure 
    keep if imeasure==16
    replace tgroup = . if tgroup==1
    sort iso tgroup 
    bysort iso: gen touse = _n 
    keep if touse==1 
    replace country = "Antigua and Barbuda" if iso=="ATG"
    replace country = "St Kitts and Nevis" if iso=="KNA"
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



    #delimit ;
        gr twoway 
            (line iso_num zero, lw(0.25) lp("-") lc(gs13)) 
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
            ysize(12) xsize(12)
            
            xlab(-20(10)20
            , labs(3) nogrid glc(gs16) angle(0) format(%9.0f))
            xtitle(" ", size(6) margin(l=2 r=2 t=2 b=2)) 

            text(19 -10 "Days before" "1st case" , place(c) size(3) )
            text(19 10 "Days after" "1st case" , place(c) size(3) )

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
            , labs(3) notick nogrid glc(gs16) angle(0))
            yscale( fill noline reverse) 
            ytitle(" ", size(3) margin(l=2 r=2 t=2 b=2)) 
            
            title("Isolation Policies", pos(11) ring(1) size(4))

            legend(off size(3) position(5) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                )
                name(acaps_isolation) 
                ;
        #delimit cr
        ///graph export "`outputpath'/04_TechDocs/bar_`country'_$S_DATE.png", replace width(6000)
restore