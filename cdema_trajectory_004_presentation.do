** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					cdema_trajectory_004.do
    //  project:				        
    //  analysts:				       	Ian HAMBLETON
    // 	date last modified	            2-APR-2020
    //  algorithm task			        xxx

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
    log using "`logpath'\cdema_trajectory_004", replace
** HEADER -----------------------------------------------------

**!-------------------------------------------------------------
*! TO DO 
*! 10 Apr 2020
*! -------------------------------------------------------------
** (1) CREATE logarithm CHART for trajectory
** (2) ADD breif reason for logiarithm chart (somewhere)
** (3) Change standard chart - removing South Korea for now
** (4) Automate range / placement of text on low-case graphic
*! -------------------------------------------------------------


*! CHANGE DAILY FILE 
** JH time series COVD-19 data 
use "`datapath'\version01\2-working\jh_time_series_14Apr2020", clear

** Country Labels
#delimit ; 
label define cname_ 1 "Antigua and Barbuda"
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
                    12 "Saint Kitts and Nevis"
                    13 "Saint Lucia"
                    14 "Saint Vincent and the Grenadines"
                    15 "Singapore"
                    16 "South Korea"
                    17 "Suriname"
                    18 "Trinidad and Tobago"
                    19 "UK"
                    20 "USA"
                    ;
#delimit cr 

** Fix Guyana 
replace confirmed = 4 if country==9 & date>=d(17mar2020) & date<=d(23mar2020)

** ELAPSED DAYS and FULL COUNTRY NAME for each country
local clist "ATG BHS BRB BLZ DMA GRD GUY HTI JAM KNA LCA VCT SUR TTO"
foreach country of local clist {
    /// Elapsed days for each country
    gen el_`country'1 = elapsed_max if iso=="`country'"
    egen el_`country' = min(el_`country'1) 
    local el_`country' = el_`country' 
    local te_`country' = el_`country' + 0.25

    /// Long version name for each country
    gen c3 = country if iso=="`country'"
    label values c3 cname_
    egen c4 = min(c3)
    label values c4 cname_
    decode c4, gen(c5)
    local cname = c5
    drop c3 c4 c5

    /// Latest confirmed cases for each country
    sort iso date
    gen con_`country'1 = confirmed if iso=="`country'" & iso[_n+1]!="`country'"
    egen con_`country' = min(con_`country'1)
    local con_`country' = con_`country'
}
local con_BHS = `con_BHS'+4

** Range for HI CASE-LOAD CHART
local range_hi = `el_JAM'+4 


** GRAPHIC: HIGH CASE COUNTRIES - NO CARICOM
    ** BHS, BRB, JAM, TTO   
        #delimit ;
        gr twoway 
            (line confirmed elapsed if iso=="USA" & elapsed<=`te_JAM', lc(green) lw(0.35) lp("-"))
            (line confirmed elapsed if iso=="GBR" & elapsed<=`te_JAM', lc(orange) lw(0.35) lp("-"))
            (line confirmed elapsed if iso=="SGP" & elapsed<=`te_JAM', lc(purple) lw(0.35) lp("-"))

            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(5) xsize(10)
            
                xlab(
                    , labs(5) notick nogrid glc(gs16))
                xscale(fill noline range(0(1)`range_hi')) 
                xtitle("Days since first case", size(5) margin(l=2 r=2 t=2 b=2)) 
                
                ylab(0(20)120
                ,
                labs(5) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Cumulative # of Cases", size(5) margin(l=2 r=2 t=2 b=2)) 

                legend(size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                order(1 2 3) 
                lab(1 "USA") 
                lab(2 "UK") 
                ///lab(3 "South Korea") 
                lab(3 "Singapore") 
                )
                name(trajectory_region_00) 
                ;
        #delimit cr




** GRAPHIC: HIGH CASE COUNTRIES - WITH CARICOM
    ** BHS, BRB, JAM, TTO   
        #delimit ;
        gr twoway 
            (line confirmed elapsed if iso=="USA" & elapsed<=`te_JAM', lc(green%20) lw(0.35) lp("-"))
            (line confirmed elapsed if iso=="GBR" & elapsed<=`te_JAM', lc(orange%20) lw(0.35) lp("-"))
            ///(line confirmed elapsed if iso=="KOR" & elapsed<=`te_JAM', lc(red%20) lw(0.35) lp("-"))
            (line confirmed elapsed if iso=="SGP" & elapsed<=`te_JAM', lc(purple%20) lw(0.35) lp("-"))
            /// BAHAMAS
            (line confirmed elapsed if iso=="BHS" & elapsed<=`el_BHS', lc(gs10) lw(0.3) lp("l"))
            (scat confirmed elapsed if iso=="BHS" & elapsed<=`el_BHS', mc(gs8) m(o) msize(1.5))
            /// BARBADOS
            (line confirmed elapsed if iso=="BRB" & elapsed<=`el_BRB', lc(gs10) lw(0.3) lp("l"))
            (scat confirmed elapsed if iso=="BRB" & elapsed<=`el_BRB', mc(gs8) m(o) msize(1.5))
            /// JAMAICA
            (line confirmed elapsed if iso=="JAM" & elapsed<=`el_JAM', lc(gs10) lw(0.3) lp("l"))
            (scat confirmed elapsed if iso=="JAM" & elapsed<=`el_JAM', mc(gs8) m(o) msize(1.5))
            /// TRINIDAD
            (line confirmed elapsed if iso=="TTO" & elapsed<=`el_TTO', lc(gs10) lw(0.3) lp("l"))
            (scat confirmed elapsed if iso=="TTO" & elapsed<=`el_TTO', mc(gs8) m(o) msize(1.5))
            /// GUYANA
            (line confirmed elapsed if iso=="GUY" & elapsed<=`el_GUY', lc(gs10) lw(0.3) lp("l"))
            (scat confirmed elapsed if iso=="GUY" & elapsed<=`el_GUY', mc(gs8) m(o) msize(1.5))
            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(5) xsize(10)
            
                xlab(
                    , labs(5) notick nogrid glc(gs16))
                xscale(fill noline range(0(1)`range_hi')) 
                xtitle("Days since first case", size(5) margin(l=2 r=2 t=2 b=2)) 
                
                ylab(0(20)120
                ,
                labs(5) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Cumulative # of Cases", size(5) margin(l=2 r=2 t=2 b=2)) 

                text(`con_BHS' `te_BHS' "The Bahamas" "(`con_BHS', `el_BHS' days)", size(3) place(e) color(gs8) j(left))
                text(`con_BRB' `te_BRB' "Barbados" "(`con_BRB', `el_BRB' days)", size(3) place(e) color(gs8) j(left))
                text(`con_JAM' `te_JAM' "Jamaica" "(`con_JAM' cases, `el_JAM' days)", size(3) place(e) color(gs8) j(left))
                text(`con_TTO' `te_TTO' "Trinidad and Tobago" "(`con_TTO' cases, `el_TTO' days)", size(3) place(e) color(gs8) j(left))
                text(`con_GUY' `te_GUY' "Guyana" "(`con_GUY' cases, `el_GUY' days)", size(3) place(e) color(gs8) j(left))

                legend(size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                order(1 2 3) 
                lab(1 "USA") 
                lab(2 "UK") 
                ///lab(3 "South Korea") 
                lab(3 "Singapore") 
                )
                name(trajectory_region_01) 
                ;
        #delimit cr









/*
** Placements for LO CASE-LOAD CHART 
local range_lo = `range_hi' 
local title = `range_hi'-10
local ctitle = `title'+5

** GRAPHIC: LOW CASE COUNTRIES
    ** 3-APR-2020: The REST (!) --> ATG BLZ DMA GRD GUY HTI KNA LCA VCT SUR 
    keep if iso=="ATG" | iso=="BLZ" | iso=="DMA" | iso=="GRD" |  /// 
            iso=="HTI" | iso=="KNA" | iso=="LCA" | iso=="VCT" | iso=="SUR" | ///
            iso=="SGP" | iso=="KOR" | iso=="GBR" | iso=="USA"
    keep date country country2 iso pop confirmed confirmed_rate elapsed
    keep if elapsed<=`range_lo'-6
    preserve 
        tempfile file1 
        keep if iso=="ATG" | iso=="BLZ" | iso=="DMA" | iso=="GRD" | iso=="GUY" | /// 
            iso=="HTI" | iso=="KNA" | iso=="LCA" | iso=="VCT" | iso=="SUR" 
        ** Fix Guyana 
        replace confirmed = 4 if iso=="GUY" & date>=d(17mar2020) & date<=d(23mar2020)
        collapse (min) con_min=confirmed (max) con_max=confirmed, by(date) 
        gen elapsed  = _n 
        gen iso = "ALL"
        gen country2 = "All"
        save `file1'
    restore
    append using `file1'

  
        #delimit ;
        gr twoway 
            (line confirmed elapsed if iso=="USA" & elapsed<=elapsed, lc(green%20) lw(0.35) lp("-"))
            (line confirmed elapsed if iso=="GBR" & elapsed<=elapsed, lc(orange%20) lw(0.35) lp("-"))
            ///(line confirmed elapsed if iso=="KOR" & elapsed<=elapsed, lc(red%20) lw(0.35) lp("-"))
            (line confirmed elapsed if iso=="SGP" & elapsed<=elapsed, lc(purple%20) lw(0.35) lp("-"))
            /// LOW CASE CARIBBEAN REGION
            (rarea con_min con_max elapsed if iso=="ALL" , col(blue%25) lw(none))
            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(5) xsize(10)
            
                xlab(
                    , labs(5) notick nogrid glc(gs16))
                xscale(fill noline range(0(1)`range_hi')) 
                xtitle("Days since first case", size(5) margin(l=2 r=2 t=2 b=2)) 
                
                ylab(0(20)100
                ,
                labs(5) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Cumulative # of Cases", size(5) margin(l=2 r=2 t=2 b=2)) 

                text(100 `title' "Current Situation" "($S_DATE)", size(3) place(e) color(4) j(left))
                text(100 `ctitle' "Antigua and Barbuda" "(`con_ATG' cases, `el_ATG' days)", size(3) place(e) color(gs8) j(left))
                text(90 `ctitle' "Belize" "(`con_BLZ' cases, `el_BLZ' days)", size(3) place(e) color(gs8) j(left))
                text(80 `ctitle' "Dominica" "(`con_ATG' cases, `el_ATG' days)", size(3) place(e) color(gs8) j(left))
                text(70 `ctitle' "Grenada" "(`con_GRD' cases, `el_GRD' days)", size(3) place(e) color(gs8) j(left))
                ///text(60 28 "Guyana" "(`con_GUY' cases, `el_GUY' days)", size(3) place(e) color(gs8) j(left))
                text(60 `ctitle' "Haiti" "(`con_HTI' cases, `el_HTI' days)", size(3) place(e) color(gs8) j(left))
                text(50 `ctitle' "St Kitts and Nevis" "(`con_KNA' cases, `el_KNA' days)", size(3) place(e) color(gs8) j(left))
                text(40 `ctitle' "St Lucia" "(`con_LCA' cases, `el_LCA' days)", size(3) place(e) color(gs8) j(left))
                text(30 `ctitle' "St Vincent" "(`con_VCT' cases, `el_VCT' days)", size(3) place(e) color(gs8) j(left))
                text(20 `ctitle' "Suriname" "(`con_SUR' cases, `el_SUR' days)", size(3) place(e) color(gs8) j(left))

                legend(size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                order(1 2 3 4) 
                lab(1 "USA") 
                lab(2 "UK") 
                ///lab(3 "South Korea") 
                lab(3 "Singapore") 
                lab(4 "9 Caribbean countries") 
                )
                name(trajectory_region_02) 
                ;
        #delimit cr
