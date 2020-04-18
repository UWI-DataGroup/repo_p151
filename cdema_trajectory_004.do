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
use "`datapath'\version01\2-working\jh_time_series_18Apr2020", clear

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

** Range for HI CASE-LOAD CHART
local range_hi = `el_JAM'+5
local te_UK = `el_JAM'-1 

local con1_JAM = `con_JAM'+12
local te1_JAM = `te_JAM'-1

local con1_TTO = `con_TTO'+12
local te1_TTO = `te_TTO'-7

local con1_GUY = `con_GUY'-14
local te1_GUY = `te_GUY'-1

local con1_BRB = `con_BRB'+11
local te1_BRB = `te_BRB' -2

local con1_BHS = `con_BHS'+5
local te1_BHS = `te_BHS' 


** GRAPHIC: HIGH CASE COUNTRIES
    ** BHS, BRB, JAM, TTO   
        #delimit ;
        gr twoway 
            (line confirmed elapsed if iso=="USA" & elapsed<=`te_JAM', lc(green%20) lw(0.35) lp("-"))
            (line confirmed elapsed if iso=="GBR" & elapsed<=`te_UK', lc(orange%20) lw(0.35) lp("-"))
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
                
                ylab(0(40)180
                ,
                labs(5) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Cumulative # of Cases", size(5) margin(l=2 r=2 t=2 b=2)) 
                ///yscale(log)


                text(`con1_BHS' `te1_BHS' "BHS" "(`con_BHS')", size(3) place(e) color(gs8) j(left))
                text(`con1_BRB' `te1_BRB' "Barbados" "(`con_BRB', `el_BRB'd)", size(3) place(e) color(gs8) j(left))
                text(`con1_JAM' `te1_JAM' "Jamaica" "(`con_JAM' cases, `el_JAM' days)", size(3) place(e) color(gs8) j(left))
                text(`con1_TTO' `te1_TTO' "Trinidad and Tobago" "(`con_TTO' cases, `el_TTO' days)", size(3) place(e) color(gs8) j(left))
                text(`con1_GUY' `te1_GUY' "Guyana" "(`con_GUY' cases, `el_GUY' days)", size(3) place(e) color(gs8) j(left))

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
        graph export "`outputpath'/04_TechDocs/trajectory_region01_$S_DATE.png", replace width(4000)

** Placements for LO CASE-LOAD CHART 
local range_lo = `range_hi' -1
local title = `range_lo' - 12
local ctitle = `title'+8

** GRAPHIC: LOW CASE COUNTRIES
    ** 3-APR-2020: The REST (!) --> ATG BLZ DMA GRD GUY HTI KNA LCA VCT SUR 
    keep if iso=="ATG" | iso=="BLZ" | iso=="DMA" | iso=="GRD" |   /// 
            iso=="HTI" | iso=="KNA" | iso=="LCA" | iso=="VCT" | iso=="SUR" | ///
            iso=="SGP" | iso=="KOR" | iso=="GBR" | iso=="USA"
    keep date country  iso pop confirmed confirmed_rate elapsed
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
                
                ylab(
                ,
                labs(5) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Cumulative # of Cases", size(5) margin(l=2 r=2 t=2 b=2)) 

                text(190 `title' "Current Situation" "($S_DATE)", size(3) place(e) color(4) j(left))
                text(190 `ctitle' "Antigua and Barbuda" "(`con_ATG' cases, `el_ATG' days)", size(3) place(e) color(gs8) j(left))
                text(170 `ctitle' "Belize" "(`con_BLZ' cases, `el_BLZ' days)", size(3) place(e) color(gs8) j(left))
                text(150 `ctitle' "Dominica" "(`con_DMA' cases, `el_DMA' days)", size(3) place(e) color(gs8) j(left))
                text(130 `ctitle' "Grenada" "(`con_GRD' cases, `el_GRD' days)", size(3) place(e) color(gs8) j(left))
                ///text(60 `ctitle' "Guyana" "(`con_GUY' cases, `el_GUY' days)", size(3) place(e) color(gs8) j(left))
                text(110 `ctitle' "Haiti" "(`con_HTI' cases, `el_HTI' days)", size(3) place(e) color(gs8) j(left))
                text(90 `ctitle' "St Kitts and Nevis" "(`con_KNA' cases, `el_KNA' days)", size(3) place(e) color(gs8) j(left))
                text(70 `ctitle' "St Lucia" "(`con_LCA' cases, `el_LCA' days)", size(3) place(e) color(gs8) j(left))
                text(50 `ctitle' "St Vincent" "(`con_VCT' cases, `el_VCT' days)", size(3) place(e) color(gs8) j(left))
                text(30 `ctitle' "Suriname" "(`con_SUR' cases, `el_SUR' days)", size(3) place(e) color(gs8) j(left))

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
        graph export "`outputpath'/04_TechDocs/trajectory_region02_$S_DATE.png", replace width(4000)


** ------------------------------------------------------
** PDF REGIONAL REPORT (COUNTS OF CONFIRMED CASES)
** ------------------------------------------------------
    putpdf begin, pagesize(letter) font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.25cm) margin(left,0.5cm) margin(right,0.25cm)

** TITLE, ATTRIBUTION, DATE of CREATION
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("COVID-19 trajectories for 14 CARICOM countries "), bold
    putpdf text ("(Counts of Confirmed Cases)"), bold linebreak
    putpdf paragraph ,  font("Calibri Light", 8)
    putpdf text ("Briefing created by staff of the George Alleyne Chronic Disease Research Centre ") 
    putpdf text ("and the Public Health Group of The Faculty of Medical Sciences, Cave Hill Campus, ") 
    putpdf text ("The University of the West Indies. ")
    putpdf text ("Contact Ian Hambleton (ian.hambleton@cavehill.uwi.edu) "), italic
    putpdf text ("for details of quantitative analyses. "), font("Calibri Light", 8) italic
    putpdf text ("Contact Maddy Murphy (madhuvanti.murphy@cavehill.uwi.edu) "), italic 
    putpdf text ("for details of national public health interventions and policy implications."), font("Calibri Light", 8) italic linebreak
    putpdf text ("Updated on: $S_DATE at $S_TIME"), font("Calibri Light", 8) bold italic

** INTRODUCTION
    putpdf paragraph ,  font("Calibri Light", 9)
    putpdf text ("Aim of this briefing. ") , bold
    putpdf text ("We present the cumulative number of confirmed cases")
    putpdf text (" 1"), script(super) 
    putpdf text (" of COVID-19 infection among CARICOM countries since the start of the outbreak, which ") 
    putpdf text ("we measure as the number of days since the first confirmed case in each country. We compare trajectories with selected countries ") 
    putpdf text ("further along the epidemic curve. This allows us to assess progress in restricting COVID-19 transmission ") 
    putpdf text ("compared to interventions in comparator countries. Epidemic progress is likely to vary markedly between countries, ") 
    putpdf text ("and these graphics are presented as a guide only. ") 
    *! CHANGE THESE TWO ROWS - EACH DAY
    putpdf text ("As of $S_DATE, there are two countries with more than 100 confirmed cases, 1 country with more than 70 confirmed cases, ") 
    putpdf text ("2 countries with more than 50 confirmed cases, and 1 country with more than 40 or more confirmed cases (Figures 1 and 2). ") 
    putpdf text ("The remaining 8 countries have confirmed case numbers ranging from 10 to 23 (Figure 2)."), linebreak 

** FIGURES OF REGIONAL COVID-19 COUNT trajectories
    putpdf paragraph ,  font("Calibri Light", 9)
    putpdf text ("Graph 1."), bold
    putpdf text ("Cumulative cases in 4 CARICOM countries as of $S_DATE")
    putpdf table f1 = (1,1), width(82%) border(all,nil) halign(center)
    putpdf table f1(1,1)=image("`outputpath'/04_TechDocs/trajectory_region01_$S_DATE.png")
    putpdf paragraph ,  font("Calibri Light", 9)
    putpdf text ("Graph 2."), bold
    putpdf text ("Cumulative cases in 10 CARICOM countries as of $S_DATE")
    putpdf table f2 = (1,1), width(82%) border(all,nil) halign(center)
    putpdf table f2(1,1)=image("`outputpath'/04_TechDocs/trajectory_region02_$S_DATE.png")

** DATA REFERENCE
    putpdf table p3 = (1,1), width(100%) halign(center) 
    putpdf table p3(1,1), font("Calibri Light", 8) border(all,nil,000000) bgcolor(ffffff)
    putpdf table p3(1,1)=("(1) Data Source. "), bold halign(left)
    putpdf table p3(1,1)=("Dong E, Du H, Gardner L. An interactive web-based dashboard to track COVID-19 "), append 
    putpdf table p3(1,1)=("in real time. Lancet Infect Dis; published online Feb 19. https://doi.org/10.1016/S1473-3099(20)30120-1"), append

** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    putpdf save "`outputpath'/05_Outputs/covid19_trajectory_caricom_count_bycountry_`date_string'", replace
