** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					cdema_trajectory_003.do
    //  project:				        
    //  analysts:				       	Ian HAMBLETON
    // 	date last modified	            31-MAR-2020
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
    log using "`logpath'\cdema_trajectory_003", replace
** HEADER -----------------------------------------------------

** -------------------------------------
*! CHANGE THESE ENTRIES FOR EACH COUNTRY FOR PDF REPORT CREATION
*! -------------------------------------------------------------
local pop = "287,371"
local over70 = "32,963" 
local acutebeds = 240
local icubeds = 40
local today = "31 March 2020"
*! -------------------------------------------------------------


** JH time series COVD-19 data 
use "`datapath'\version01\2-working\jh_time_series", clear

** JH database correction
** UK has 2 names in database
replace countryregion = "UK" if countryregion=="United Kingdom"
** Bahamas has 3 names in database 
replace countryregion = "Bahamas" if countryregion=="Bahamas, The" | countryregion=="The Bahamas"


** Keep UK, USA, Sth Korea, Singapore as comparators
** Then keep all Caribbean nations
** Antigua and Barbuda
** NOT YET ADDED Aruba
** Bahamas
** Barbados
** Belize
** NOT YET ADDED Cayman Islands
** Cuba
** NOT YET ADDED Curacao
** Dominica
** Dominican Republic
** NOT YET ADDED French Guiana (also under France)
** Grenada
** NOT YET ADDED Guadeloupe (also under France)
** Guyana
** Haiti
** Jamaica
** NOT YET ADDED Martinique (also under France)
** NOT YET ADDED Puerto Rico (also under US?)
** Saint Kitts and Nevis
** Saint Lucia
** Saint Vincent and the Grenadines
** Suriname
** Trinidad and Tobago

#delimit ; 
keep if countryregion=="South Korea" |
        countryregion=="UK" |
        countryregion=="US" |
        countryregion=="Singapore" |
        countryregion=="Antigua and Barbuda" |
        countryregion=="Bahamas" |
        countryregion=="Barbados" |
        countryregion=="Belize" |
        countryregion=="Cuba" | 
        countryregion=="Dominica" |
        countryregion=="Dominican Republic" |
        countryregion=="Grenada" |
        countryregion=="Guyana" |
        countryregion=="Haiti" |
        countryregion=="Jamaica" |
        countryregion=="Saint Kitts and Nevis" |
        countryregion=="Saint Lucia" |
        countryregion=="Saint Vincent and the Grenadines" |
        countryregion=="Suriname" |
        countryregion=="Trinidad and Tobago";
#delimit cr    
collapse (sum) confirmed deaths recovered, by(date countryregion)

** Add ISO codes
gen iso = ""
order iso, after(countryregion)
replace iso = "ATG" if countryregion=="Antigua and Barbuda"
replace iso = "BHS" if countryregion=="Bahamas"
replace iso = "BRB" if countryregion=="Barbados"
replace iso = "BLZ" if countryregion=="Belize"
replace iso = "CUB" if countryregion=="Cuba"
replace iso = "DMA" if countryregion=="Dominica"
replace iso = "DOM" if countryregion=="Dominican Republic"
replace iso = "GRD" if countryregion=="Grenada"
replace iso = "GUY" if countryregion=="Guyana"
replace iso = "HTI" if countryregion=="Haiti"
replace iso = "JAM" if countryregion=="Jamaica"
replace iso = "KNA" if countryregion=="Saint Kitts and Nevis"
replace iso = "LCA" if countryregion=="Saint Lucia"
replace iso = "VCT" if countryregion=="Saint Vincent and the Grenadines"
replace iso = "SUR" if countryregion=="Suriname"
replace iso = "TTO" if countryregion=="Trinidad and Tobago"
replace iso = "SGP" if countryregion=="Singapore"
replace iso = "KOR" if countryregion=="South Korea"
replace iso = "GBR" if countryregion=="UK"
replace iso = "USA" if countryregion=="US"

list date countryregion confirmed deaths recovered in -9/l, sepby(date) abbreviate(13)
encode countryregion, gen(country)
list date countryregion country in -9/l, sepby(date) abbreviate(13)
label list country
tsset country date, daily
* Add days since first reported cases
bysort country: gen elapsed = _n 
save "`datapath'\version01\2-working\jh_covide19_long", replace


** Add country populations
gen pop = . 
** Singapore
replace pop = 5850343 if iso=="SGP"
** USA
replace pop = 331002647 if iso=="USA"
** UK
replace pop = 67886004 if iso=="GBR"
* KOR
replace pop = 51269183 if iso=="KOR"
** CARIBBEAN NATIONS
replace pop = 97928 if iso == "ATG"
replace pop = 393248 if iso == "BHS"
replace pop = 287371 if iso == "BRB"
replace pop = 397621 if iso == "BLZ"
replace pop = 11326616 if iso == "CUB"
replace pop = 71991 if iso == "DMA"
replace pop = 10847904 if iso == "DOM"
replace pop = 112519 if iso == "GRD"
replace pop = 786559 if iso == "GUY"
replace pop = 11402533 if iso == "HTI"
replace pop = 2961161 if iso == "JAM"
replace pop = 53192 if iso == "KNA"
replace pop = 183629 if iso == "LCA"
replace pop = 110947 if iso == "VCT"
replace pop = 586634 if iso == "SUR"
replace pop = 1399491 if iso == "TTO"
order pop, after(iso)


** Labelling
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

*! -------------------------------------------
*! Temporary Daily Updates
*! Review each morning
*! CHANGE FOR THE 4APR figures --> FEED INTO the 5APR REPORT
replace confirmed = 29 if confirmed == 28 & iso=="BHS" & date==d(5apr2020)
replace confirmed = 29 if confirmed == 24 & iso=="GUY" & date==d(5apr2020)
replace confirmed = 105 if confirmed == 104 & iso=="TTO" & date==d(5apr2020)
*! -------------------------------------------

** Rate per 1,000 (not yet used)
gen confirmed_rate = (confirmed / pop) * 10000

decode country, gen(country2)
keep date country country2 iso pop confirmed confirmed_rate deaths recovered
order date country country2 iso pop confirmed confirmed_rate deaths recovered
bysort country : gen elapsed = _n 

** Scroll through multiple identical graphics
** They vary only by Caribbean country

bysort country: egen elapsed_max = max(elapsed)

** SAVE THE FILE FOR REGIONAL WORK 
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    save "`datapath'\version01\2-working\jh_time_series_`date_string'", replace

local clist "ATG BHS BRB BLZ DMA GRD GUY HTI JAM KNA LCA VCT SUR TTO"
///local clist "ATG"
foreach country of local clist {

    gen el_`country'1 = elapsed_max if iso=="`country'"
    egen el_`country'2 = min(el_`country'1) 
    local elapsed = el_`country'2

    gen c3 = country if iso=="`country'"
    label values c3 cname_
    egen c4 = min(c3)
    label values c4 cname_
    decode c4, gen(c5)
    local cname = c5

    #delimit ;
        gr twoway 
            (line confirmed elapsed if iso=="USA" & elapsed<=`elapsed', lc(green%40) lw(0.35) lp("-"))
            (line confirmed elapsed if iso=="GBR" & elapsed<=`elapsed', lc(orange%40) lw(0.35) lp("-"))
            (line confirmed elapsed if iso=="KOR" & elapsed<=`elapsed', lc(red%40) lw(0.35) lp("-"))
            (line confirmed elapsed if iso=="SGP" & elapsed<=`elapsed', lc(purple%40) lw(0.35) lp("-"))
            ///(line confirmed elapsed if iso=="`country'" & elapsed<=`elapsed', lc(gs0) lw(0.4) lp("-"))
            (line confirmed elapsed if iso=="`country'" & elapsed<=`elapsed', lc(gs8) lw(0.4) lp("-"))
            (scat confirmed elapsed if iso=="`country'" & elapsed<=`elapsed', mc(gs8) m(o))
            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(5) xsize(10)
            
                xlab(
                    , labs(5) notick nogrid glc(gs16))
                xscale(fill noline) 
                xtitle("Days since first case", size(5) margin(l=2 r=2 t=2 b=2)) 
                
                ylab(
                ,
                labs(5) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Cumulative # of Cases", size(5) margin(l=2 r=2 t=2 b=2)) 

                legend(size(5) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                order(1 2 3 4 5) 
                lab(1 "USA") 
                lab(2 "UK") 
                lab(3 "South Korea") 
                lab(4 "Singapore") 
                lab(5 "`cname'")
                )
                name(trajectory_`country') 
                ;
        #delimit cr
        graph export "`outputpath'/04_TechDocs/trajectory_`country'_$S_DATE.png", replace width(4000)


** THE CURRENT NUMBER OF CASES IN EACH COUNTRY
bysort country: egen cmax = max(confirmed)
** Caribbean Confirmed Case
gen cmax_`country'1 = cmax if iso=="`country'"
egen cmax_`country'2 = min(cmax_`country'1)
local cmax_`country' = cmax_`country'2

** The DATE OF FIRST CONFIRMED CASE
bysort country: egen dmin = min(date)
format dmin %td 
** Caribbean Date of First Confirmed Case
gen dmin_`country'1 = dmin if iso=="`country'"
egen dmin_`country'2 = min(dmin_`country'1)
local dmin_`country' : disp %tdDD_Month dmin_`country'2
** COMPARISON COUNTRIES
foreach comp in SGP KOR GBR USA {
    gen dmin_`comp'1 = dmin if iso=="`comp'"
    egen dmin_`comp'2 = min(dmin_`comp'1)
    local dmin_`comp' : disp %tdDD_Month dmin_`comp'2
    }

** DAYS SINCE FIRST CONFIRMED CASE
bysort country: egen emax = max(elapsed)
** Caribbean Days Since First Confirmed Case
gen emax_`country'1 = emax if iso=="`country'"
egen emax_`country'2 = min(emax_`country'1)
local emax_`country' = emax_`country'2
** COMPARISON COUNTRIES
foreach comp in SGP KOR GBR USA {
    gen emax_`comp'1 = emax if iso=="`comp'"
    egen emax_`comp'2 = min(emax_`comp'1)
    local emax_`comp' = emax_`comp'2
    }

** DAYS UNTIL N=10 cases
gen t10 = date if confirmed>=10 & confirmed[_n-1]<10
bysort country: egen d10 = min(t10)
gen diff10 = d10 - dmin 
** Caribbean Days until N=10 Cases
gen diff10_`country'1 = diff10 if iso=="`country'"
egen diff10_`country'2 = min(diff10_`country'1)
local diff10_`country' = diff10_`country'2
** COMPARISON COUNTRIES
foreach comp in SGP KOR GBR USA {
    gen diff10_`comp'1 = diff10 if iso=="`comp'"
    egen diff10_`comp'2 = min(diff10_`comp'1)
    local diff10_`comp' = diff10_`comp'2
    }

** DAYS UNTIL N=30 cases
gen t30 = date if confirmed>=30 & confirmed[_n-1]<30
bysort country: egen d30 = min(t30)
gen diff30 = d30 - dmin 
** Caribbean Days until N=30 Cases
gen diff30_`country'1 = diff30 if iso=="`country'"
egen diff30_`country'2 = min(diff30_`country'1)
local diff30_`country' = diff30_`country'2
** COMPARISON COUNTRIES
foreach comp in SGP KOR GBR USA {
    gen diff30_`comp'1 = diff30 if iso=="`comp'"
    egen diff30_`comp'2 = min(diff30_`comp'1)
    local diff30_`comp' = diff30_`comp'2
    }
** DAYS UNTIL n=50 cases
gen t50 = date if confirmed>=50 & confirmed[_n-1]<50
bysort country: egen d50 = min(t50)
gen diff50 = d50 - dmin 
** Caribbean Days until N=50 Cases
gen diff50_`country'1 = diff50 if iso=="`country'"
egen diff50_`country'2 = min(diff50_`country'1)
local diff50_`country' = diff50_`country'2
** COMPARISON COUNTRIES
foreach comp in SGP KOR GBR USA {
    gen diff50_`comp'1 = diff50 if iso=="`comp'"
    egen diff50_`comp'2 = min(diff50_`comp'1)
    local diff50_`comp' = diff50_`comp'2
    }

** DAYS UNTIL n=100 cases
gen t100 = date if confirmed>=100 & confirmed[_n-1]<100
bysort country: egen d100 = min(t100)
gen diff100 = d100 - dmin 
** Caribbean Days until N=100 Cases
gen diff100_`country'1 = diff100 if iso=="`country'"
egen diff100_`country'2 = min(diff100_`country'1)
local diff100_`country' = diff100_`country'2
** COMPARISON COUNTRIES
foreach comp in SGP KOR GBR USA {
    gen diff100_`comp'1 = diff100 if iso=="`comp'"
    egen diff100_`comp'2 = min(diff100_`comp'1)
    local diff100_`comp' = diff100_`comp'2
    }

** DAYS UNTIL n=1,000 cases
gen t1000 = date if confirmed>=1000 & confirmed[_n-1]<1000
bysort country: egen d1000 = min(t1000)
gen diff1000 = d1000 - dmin 
** Caribbean Days until N=1,000 Cases
gen diff1000_`country'1 = diff1000 if iso=="`country'"
egen diff1000_`country'2 = min(diff1000_`country'1)
local diff1000_`country' = diff1000_`country'2
** COMPARISON COUNTRIES
foreach comp in SGP KOR GBR USA {
    gen diff1000_`comp'1 = diff1000 if iso=="`comp'"
    egen diff1000_`comp'2 = min(diff1000_`comp'1)
    local diff1000_`comp' = diff1000_`comp'2
    }

** DAYS UNTIL n=10,000 cases
gen t10000 = date if confirmed>=10000 & confirmed[_n-1]<10000
bysort country: egen d10000 = min(t10000)
gen diff10000 = d10000 - dmin 
** Caribbean Days until N=10,000 Cases
gen diff10000_`country'1 = diff10000 if iso=="`country'"
egen diff10000_`country'2 = min(diff10000_`country'1)
local diff10000_`country' = diff10000_`country'2
** COMPARISON COUNTRIES
foreach comp in SGP KOR GBR USA {
    gen diff10000_`comp'1 = diff10000 if iso=="`comp'"
    egen diff10000_`comp'2 = min(diff10000_`comp'1)
    local diff10000_`comp' = diff10000_`comp'2
    }

** 1 DAY INCREASE
sort country date 
gen t1 = confirmed - confirmed[_n-1] if country!=country[_n+1] & iso=="`country'"
egen t2 = min(t1)
local change1 = t2 
** 7 DAY INCREASE
gen t3 = confirmed - confirmed[_n-7] if country!=country[_n+1] & iso=="`country'"
egen t4 = min(t3)
local change7 = t4 


drop cmax* dmin* emax* t10 t30 t50 t100 t1000 t10000 d10 d30 d50 d100 d1000 d10000
drop diff10* diff30* diff50* diff100* diff1000* diff10000* c3 c4 c5
drop t1 t2 t3 t4 

** ------------------------------------------------------
** PDF COUNTRY REPORT
** ------------------------------------------------------
    putpdf begin, pagesize(letter) font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.25cm) margin(left,0.5cm) margin(right,0.25cm)

** TITLE, ATTRIBUTION, DATE of CREATION
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("COVID-19 trajectory for `cname'"), bold linebreak
    putpdf paragraph ,  font("Calibri Light", 8)
    putpdf text ("Briefing created by staff of the George Alleyne Chronic Disease Research Centre ") 
    putpdf text ("and the Public Health Group of The Faculty of Medical Sciences, Cave Hill Campus, ") 
    putpdf text ("The University of the West Indies. ")
    putpdf text ("Contact Ian Hambleton (ian.hambleton@cavehill.uwi.edu) "), italic
    putpdf text ("for details of quantitative analyses. "), font("Calibri Light", 8) italic
    putpdf text ("Contact Maddy Murphy (madhuvanti.murphy@cavehill.uwi.edu) "), italic 
    putpdf text ("for details of national public health interventions and policy implications."), font("Calibri Light", 8) italic linebreak
    putpdf text ("Updated on: $S_DATE at $S_TIME"), font("Calibri Light", 8) bold italic linebreak

** INTRODUCTION
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Aim of this briefing. ") , bold
    putpdf text ("We present the cumulative number of confirmed cases")
    putpdf text (" 1"), script(super) 
    putpdf text (" of COVID-19 infection in `cname' since the start of the outbreak, which ") 
    putpdf text ("we measure as the number of days since the first confirmed case. We compare the `cname' trajectory against key comparator countries ") 
    putpdf text ("(Singapore, South Korea, UK, USA), which are further along their epidemic curves. Epidemic progress is likely to vary markedly ") 
    putpdf text ("between countries, and this graphic is presented as a guide only. "), linebreak 

** TABLE: KEY SUMMARY METRICS
    putpdf table t1 = (2,3), width(75%) halign(center) 
    putpdf table t1(1,.), font("Calibri Light", 13, ffffff) border(all,single,ffffff) bgcolor(a6a6a6) 
    putpdf table t1(2,.), font("Calibri Light", 18) border(all,nil) 
    putpdf table t1(1,1)=("Confirmed Cases"), halign(center) 
    putpdf table t1(1,2)=("Date of First Confirmed Case"), halign(center)  
    putpdf table t1(1,3)=("Days Since First Confirmed Case"), halign(center) 
    putpdf table t1(2,1)=("`cmax_`country''"), halign(center) 
    putpdf table t1(2,2)=("`dmin_`country''"), halign(center) 
    putpdf table t1(2,3)=("`emax_`country''"), halign(center) 

** PARAGRAPH. ABOUT TABLE ABOVE
    putpdf table p1 = (1,1), width(75%) halign(center) 
    putpdf table p1(1,1), font("Calibri Light", 10) border(all,nil,000000) bgcolor(ffffff)
    putpdf table p1(1,1)=("`cname' has `cmax_`country'' confirmed cases of COVID-19. "), halign(center)  
    putpdf table p1(1,1)=("This is a 24-hour increase of `change1', and a one-week increase of "), append 
    putpdf table p1(1,1)=("`change7' confirmed cases."), append 

** TABLE: DAYS UNTIL 30, 50, 100, 1,000, 10,000 CASES
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Table."), bold
    putpdf text (" Days between first confirmed case and 10, 30, 50, 100, 1,000 and 10,000 cases"), linebreak

    putpdf table t2 = (6,7), width(75%) halign(center) 
    putpdf table t2(1,.), font("Calibri Light", 10, 000000) border(all,single,000000) bgcolor(cccccc)
    putpdf table t2(.,1), font("Calibri Light", 10, 000000) border(all,single,000000) bgcolor(cccccc)
    putpdf table t2(2,.), font("Calibri Light", 10, 000000) 
    
    putpdf table t2(1,1)=("Country"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(1,2)=("10 cases"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(1,3)=("30 cases"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(1,4)=("50 cases"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(1,5)=("100 cases"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(1,6)=("1,000 cases"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(1,7)=("10,000 cases"), halign(center) border(top) border(bottom) border(left) border(right) 
    
    putpdf table t2(2,1)=("Singapore"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(3,1)=("South Korea"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(4,1)=("UK"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(5,1)=("USA"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(6,1)=("`cname'"), halign(center) border(top) border(bottom) border(left) border(right) 

    putpdf table t2(2,2)=("`diff10_SGP'"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(3,2)=("`diff10_KOR'"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(4,2)=("`diff10_GBR'"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(5,2)=("`diff10_USA'"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(6,2)=("`diff10_`country''"), halign(center) border(top) border(bottom) border(left) border(right) 

    putpdf table t2(2,3)=("`diff30_SGP'"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(3,3)=("`diff30_KOR'"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(4,3)=("`diff30_GBR'"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(5,3)=("`diff30_USA'"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(6,3)=("`diff30_`country''"), halign(center) border(top) border(bottom) border(left) border(right) 

    putpdf table t2(2,4)=("`diff50_SGP'"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(3,4)=("`diff50_KOR'"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(4,4)=("`diff50_GBR'"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(5,4)=("`diff50_USA'"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(6,4)=("`diff50_`country''"), halign(center) border(top) border(bottom) border(left) border(right) 

    putpdf table t2(2,5)=("`diff100_SGP'"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(3,5)=("`diff100_KOR'"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(4,5)=("`diff100_GBR'"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(5,5)=("`diff100_USA'"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(6,5)=("`diff100_`country''"), halign(center) border(top) border(bottom) border(left) border(right) 
 
    putpdf table t2(2,6)=("`diff1000_SGP'"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(3,6)=("`diff1000_KOR'"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(4,6)=("`diff1000_GBR'"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(5,6)=("`diff1000_USA'"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(6,6)=("`diff1000_`country''"), halign(center) border(top) border(bottom) border(left) border(right) 
 
    putpdf table t2(2,7)=("`diff10000_SGP'"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(3,7)=("`diff10000_KOR'"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(4,7)=("`diff10000_GBR'"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(5,7)=("`diff10000_USA'"), halign(center) border(top) border(bottom) border(left) border(right) 
    putpdf table t2(6,7)=("`diff10000_`country''"), halign(center) border(top) border(bottom) border(left) border(right) 

** PARAGRAPH. ABOUT TABLE ABOVE
    putpdf table p2 = (1,1), width(75%) halign(center) 
    putpdf table p2(1,1), font("Calibri Light", 10) border(all,nil,000000) bgcolor(ffffff)
    putpdf table p2(1,1)=("The table above presents the number of days taken to reach 10 confirmed cases, "), halign(center)
    putpdf table p2(1,1)=("30 cases, and so on. Use the table along with the graph below to examine "), halign(center) append
    putpdf table p2(1,1)=("the outbreak trajectory in `cname' to date."), halign(center) append

** FIGURE OF COVID-19 trajectory
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Graph."), bold
    putpdf text (" Cumulative cases in `cname' as of $S_DATE (`emax_`country'' outbreak days)"), linebreak
    putpdf table f1 = (1,1), width(70%) border(all,nil) halign(center)
    putpdf table f1(1,1)=image("`outputpath'/04_TechDocs/trajectory_`country'_$S_DATE.png")

** DATA REFERENCE
    putpdf table p3 = (1,1), width(100%) halign(center) 
    putpdf table p3(1,1), font("Calibri Light", 8) border(all,nil,000000) bgcolor(ffffff)
    putpdf table p3(1,1)=("(1) Data Source. "), bold halign(left)
    putpdf table p3(1,1)=("Dong E, Du H, Gardner L. An interactive web-based dashboard to track COVID-19 "), append 
    putpdf table p3(1,1)=("in real time. Lancet Infect Dis; published online Feb 19. https://doi.org/10.1016/S1473-3099(20)30120-1"), append

** Save the PDF
    local c_date = c(current_date)
    local c_time = c(current_time)
    local c_time_date = "`c_date'"+"_" +"`c_time'"
    local time_string = subinstr("`c_time_date'", ":", "_", .)
    local time_string = subinstr("`time_string'", " ", "", .)
    putpdf save "`outputpath'/05_Outputs/covid19_trajectory_`country'_`time_string'", replace
}
