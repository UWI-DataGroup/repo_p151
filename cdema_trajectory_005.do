** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					cdema_trajectory_005.do
    //  project:				        
    //  analysts:				       	Ian HAMBLETON
    // 	date last modified	            04-APR-2020
    //  algorithm task			        HEATMAP

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
    log using "`logpath'\cdema_trajectory_005", replace
** HEADER -----------------------------------------------------

** JH time series COVD-19 data 
use "`datapath'\version01\2-working\jh_time_series", clear

** JH database correction
** UK has 2 names in database
replace countryregion = "UK" if countryregion=="United Kingdom"
** Bahamas has 3 names in database 
replace countryregion = "Bahamas" if countryregion=="Bahamas, The" | countryregion=="The Bahamas"
** South Korea has 2 names
replace countryregion = "South Korea" if countryregion=="Korea, South" 

** COUNTRY RESTRICTION: CARICOM countries only (N=14)
#delimit ; 
keep if 
        countryregion=="Antigua and Barbuda" |
        countryregion=="Bahamas" |
        countryregion=="Barbados" |
        countryregion=="Belize" |
        countryregion=="Dominica" |
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

** HEATMAP preparation - ADD ROWS
** Want symmetric / rectangular matrix of dates. So we need 
** to backfill dates foreach country to date of first 
** COVID appearance - which I think was in JAM
    fillin date country 
    replace confirmed = 0 if confirmed==.
    replace deaths = 0 if deaths==.
    replace recovered = 0 if recovered==.

** Add ISO codes
gen iso = ""
order iso, after(countryregion)
replace iso = "ATG" if countryregion=="Antigua and Barbuda"
replace iso = "BHS" if countryregion=="Bahamas"
replace iso = "BRB" if countryregion=="Barbados"
replace iso = "BLZ" if countryregion=="Belize"
replace iso = "DMA" if countryregion=="Dominica"
replace iso = "GRD" if countryregion=="Grenada"
replace iso = "GUY" if countryregion=="Guyana"
replace iso = "HTI" if countryregion=="Haiti"
replace iso = "JAM" if countryregion=="Jamaica"
replace iso = "KNA" if countryregion=="Saint Kitts and Nevis"
replace iso = "LCA" if countryregion=="Saint Lucia"
replace iso = "VCT" if countryregion=="Saint Vincent and the Grenadines"
replace iso = "SUR" if countryregion=="Suriname"
replace iso = "TTO" if countryregion=="Trinidad and Tobago"

** Create internal numeric code for country (1-14)
encode countryregion, gen(country)
label list country
* Add days since first reported cases
bysort country: gen elapsed = _n 

** Add country populations
gen pop = . 
** CARICOM COUNTRIES (2020 estimates from UN WPP, 2019 release)
replace pop = 97928 if iso == "ATG"
replace pop = 393248 if iso == "BHS"
replace pop = 287371 if iso == "BRB"
replace pop = 397621 if iso == "BLZ"
replace pop = 71991 if iso == "DMA"
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
                    5 "Dominica"
                    6 "Grenada"
                    7 "Guyana"
                    8 "Haiti"
                    9 "Jamaica"
                    10 "Saint Kitts and Nevis"
                    11 "Saint Lucia"
                    12 "Saint Vincent and the Grenadines"
                    13 "Suriname"
                    14 "Trinidad and Tobago"
                    ;
#delimit cr 

*! -------------------------------------------
*! Temporary Daily Updates
*! Review each morning
*! CHANGE FOR THE 7APR figures --> FEED INTO the 5APR REPORT
replace confirmed = 163 if confirmed == 143 & iso=="JAM" & date==d(17apr2020)
///replace confirmed = 75 if confirmed == 73 & iso=="BRB" & date==d(16apr2020)
*! -------------------------------------------

** Attack Rate (per 1,000 --> not yet used)
gen confirmed_rate = (confirmed / pop) * 10000

** Keep selected variables
decode country, gen(country2)
keep date country country2 iso pop confirmed confirmed_rate deaths recovered
order date country country2 iso pop confirmed confirmed_rate deaths recovered
bysort country : gen elapsed = _n 

** Scroll through multiple identical graphics
** They vary only by Caribbean country
bysort country: egen elapsed_max = max(elapsed)
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
}

keep country date confirmed confirmed_rate deaths recovered
** Fix Guyana 
replace confirmed = 4 if country==7 & date>=d(17mar2020) & date<=d(23mar2020)
rename confirmed metric1
rename confirmed_rate metric2
rename deaths metric3
rename recovered metric4
reshape long metric, i(country date) j(mtype)
label define mtype_ 1 "cases" 2 "attack rate" 3 "deaths" 4 "recovered"
label values mtype mtype_
sort country mtype date 


** HEATMAP -- CASES
#delimit ;
    heatplot metric i.country date if mtype==1
    ,
    cuts(@min(10)@max)
    color(spmap, blues)
    keylabels(all, range(1))

    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
    ysize(12) xsize(10)

    ylab(   1 "Antigua and Barbuda" 
            2 "The Bahamas" 
            3 "Barbados"
            4 "Belize" 
            5 "Dominica"
            6 "Grenada"
            7 "Guyana"
            8 "Haiti"
            9 "Jamaica"
            10 "St Kitts and Nevis"
            11 "St Lucia"
            12 "St Vincent"
            13 "Suriname"
            14 "Trinidad and Tobago"
    , labs(3) notick nogrid glc(gs16) angle(0))
    yscale(reverse fill noline range(0(1)14)) 
    ytitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 

    xlab(21984 "10 Mar" 21994 "20 Mar" 22004 "30 Mar" 22015 "10 Apr"
    , labs(3) nogrid glc(gs16) angle(45) format(%9.0f))
    xtitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 

    title("Confirmed cases by $S_DATE", pos(11) ring(1) size(4))

    legend(size(3) position(2) ring(4) colf cols(1) lc(gs16)
    region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
    sub("Confirmed" "Cases", size(3))
                    )
    name(heatmap_cases) 
    ;
#delimit cr
    graph export "`outputpath'/04_TechDocs/heatmap_cases_$S_DATE.png", replace width(4000)


** HEATMAP -- DEATHS
#delimit ;
    heatplot metric i.country date if mtype==3
    ,
    cuts(@min(1)@max)
    color(spmap, reds)
    keylabels(all, range(1))

    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
    ysize(12) xsize(10)

    ylab(   1 "Antigua and Barbuda" 
            2 "The Bahamas" 
            3 "Barbados"
            4 "Belize" 
            5 "Dominica"
            6 "Grenada"
            7 "Guyana"
            8 "Haiti"
            9 "Jamaica"
            10 "St Kitts and Nevis"
            11 "St Lucia"
            12 "St Vincent"
            13 "Suriname"
            14 "Trinidad and Tobago"
    , labs(3) notick nogrid glc(gs16) angle(0))
    yscale(reverse fill noline range(0(1)14)) 
    ytitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 

    xlab(21984 "10 Mar" 21994 "20 Mar" 22004 "30 Mar" 22015 "10 Apr"
    , labs(3) nogrid glc(gs16) angle(45) format(%9.0f))
    xtitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 

    title("Confirmed deaths by $S_DATE", pos(11) ring(1) size(4))

    legend(size(3) position(2) ring(4) colf cols(1) lc(gs16)
    region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
    sub("Confirmed" "Deaths", size(3))
    order(9 8 7 6 5 4 3 2 1) 
        lab(1 "0") 
        lab(2 "1") 
        lab(3 "2") 
        lab(4 "3")
        lab(5 "4")
        lab(6 "5")
        lab(7 "6")
        lab(8 "7")
        lab(9 "8-9")
    )
    name(heatmap_deaths) 
    ;
#delimit cr 
    graph export "`outputpath'/04_TechDocs/heatmap_deaths_$S_DATE.png", replace width(4000)



** ------------------------------------------------------
** PDF REGIONAL REPORT (COUNTS OF CONFIRMED CASES)
** ------------------------------------------------------
    putpdf begin, pagesize(letter) font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.25cm) margin(left,0.5cm) margin(right,0.25cm)

** TITLE, ATTRIBUTION, DATE of CREATION
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("COVID-19 Heatmap for 14 CARICOM countries "), bold
    putpdf text ("(Counts of Confirmed Cases and Deaths)"), bold linebreak
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
    putpdf text ("We present the cumulative number of confirmed COVID-19 cases and deaths")
    putpdf text (" 1"), script(super) 
    putpdf text (" among CARICOM countries since the start of the outbreak.  ") 
    putpdf text ("We use heatmaps to visually summarise the situation as of $S_DATE. ") 
    putpdf text ("The intention is to highlight outbreak hotspots."), linebreak 

** FIGURES OF REGIONAL COVID-19 COUNT trajectories
    putpdf table f1 = (1,2), width(100%) border(all,nil) halign(center)
    putpdf table f1(1,1)=image("`outputpath'/04_TechDocs/heatmap_cases_$S_DATE.png")
    putpdf table f1(1,2)=image("`outputpath'/04_TechDocs/heatmap_deaths_$S_DATE.png")

** DATA REFERENCE
    putpdf table p3 = (1,1), width(100%) halign(center) 
    putpdf table p3(1,1), font("Calibri Light", 8) border(all,nil,000000) bgcolor(ffffff)
    putpdf table p3(1,1)=("(1) Data Source. "), bold halign(left)
    putpdf table p3(1,1)=("Dong E, Du H, Gardner L. An interactive web-based dashboard to track COVID-19 "), append 
    putpdf table p3(1,1)=("in real time. Lancet Infect Dis; published online Feb 19. https://doi.org/10.1016/S1473-3099(20)30120-1"), append

** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    putpdf save "`outputpath'/05_Outputs/covid19_trajectory_caricom_heatmap_`date_string'", replace
