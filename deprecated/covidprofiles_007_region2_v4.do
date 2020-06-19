** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					covidprofiles_007_region2_v4.do
    //  project:				        
    //  analysts:				       	Ian HAMBLETON
    // 	date last modified	            7-JUN-2020
    //  algorithm task			        HEATMAP

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
    ** LOGFILES to unencrypted OneDrive folder
    local logpath "X:\OneDrive - The University of the West Indies\repo_datagroup\repo_p151"
    ** Reports and Other outputs
    local outputpath "X:\The University of the West Indies\DataGroup - DG_Projects\PROJECT_p151"
    local parent "C:\Users\Ian Hambleton\Sync\Link_folders\COVID19 Surveillance Updates\02 regional_summaries"
    cap mkdir "`parent'\\`today'
    local syncpath "C:\Users\Ian Hambleton\Sync\Link_folders\COVID19 Surveillance Updates\02 regional_summaries\\`today'"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\covidprofiles_007_region2_v4", replace
** HEADER -----------------------------------------------------


** -----------------------------------------
** Pre-Load the COVID metrics --> as Global Macros
** -----------------------------------------
qui do "`logpath'\covidprofiles_004_metrics_v3"
** -----------------------------------------

** Close any open log file and open a new log file
capture log close
log using "`logpath'\covidprofiles_007_region2_v4", replace

** Country Labels
#delimit ; 
label define cname_ 1 "Anguilla" 
                    2 "Antigua and Barbuda"
                    3 "The Bahamas"
                    4 "Belize"
                    5 "Bermuda"
                    6 "Barbados"
                    7 "Cayman Islands" 
                    8 "Dominica"
                    9 "Grenada"
                    10 "Guyana"
                    11 "Haiti"
                    12 "Jamaica"
                    13 "Saint Kitts and Nevis"
                    14 "Saint Lucia"
                    15 "Montserrat"
                    16 "Suriname"
                    17 "Turks and Caicos"
                    18 "Trinidad and Tobago"
                    19 "Saint Vincent and the Grenadines"
                    20 "British Virgin Islands"
                    ;
#delimit cr 


** COUNTRY RESTRICTION: CARICOM countries only (N=14)
#delimit ; 
    keep if 
        iso=="AIA" |
        iso=="ATG" |
        iso=="BHS" |
        iso=="BRB" |
        iso=="BLZ" |
        iso=="BMU" |
        iso=="VGB" |
        iso=="CYM" |
        iso=="DMA" |
        iso=="GRD" |
        iso=="GUY" |
        iso=="HTI" |
        iso=="JAM" |
        iso=="MSR" |
        iso=="KNA" |
        iso=="LCA" |
        iso=="VCT" |
        iso=="SUR" |
        iso=="TTO" |
        iso=="TCA";
#delimit cr    

** HEATMAP preparation - ADD ROWS
** Want symmetric / rectangular matrix of dates. So we need 
** to backfill dates foreach country to date of first 
** COVID appearance - which I think was in JAM
    fillin date iso_num 
    sort iso_num date
    ///drop if date>date[_n+1] & iso_num!=iso_num[_n+1]
    ///drop if inlist(_n, _N)
    replace confirmed = 0 if confirmed==.
    replace deaths = 0 if deaths==.
    replace recovered = 0 if recovered==.

** Attack Rate (per 1,000 --> not yet used)
gen confirmed_rate = (confirmed / pop) * 10000

** Keep selected variables
decode iso_num, gen(country2)
keep date iso_num country2 iso pop confirmed confirmed_rate deaths recovered
order date iso_num country2 iso pop confirmed confirmed_rate deaths recovered
bysort iso_num : gen elapsed = _n 
keep iso_num pop date confirmed confirmed_rate deaths recovered

** Fix Guyana 
replace confirmed = 4 if iso_num==14 & date>=d(17mar2020) & date<=d(23mar2020)
** Fix --> Single Montserrat value 
replace confirmed = 5 if confirmed==0 & iso_num==22 & date==d(01apr2020)
replace pop = 4999 if pop==. & iso_num==22 & date==d(01apr2020)
rename confirmed metric1
rename confirmed_rate metric2
rename deaths metric3
rename recovered metric4
reshape long metric, i(iso_num pop date) j(mtype)
label define mtype_ 1 "cases" 2 "attack rate" 3 "deaths" 4 "recovered"
label values mtype mtype_
sort iso_num mtype date 
drop if mtype==2 | mtype==4 


** DOUBLING RATE
** Then create a rolling average 
** Using 1-week window for now
** And we only calculate ONCE cases reach N=10 - for stability reasons 
format pop  %14.0fc
sort iso_num mtype date 
gen growthrate = log(metric/metric[_n-1]) if iso_num==iso_num[_n-1] & mtype==mtype[_n-1] 
replace growthrate = 0 if metric<10 & mtype==1
gen doublingtime = log(2)/growthrate
sort iso_num mtype date 
gen gr100 = growthrate*100
bysort iso_num mtype: asrol gr100, stat(mean) window(date 10) gen(gr7)
bysort iso_num mtype: asrol doublingtime , stat(mean) window(date 7) gen(dt7)

** NEW CASES EACH DAY
by iso_num mtype: gen new = metric - metric[_n-1]
replace new = 0 if new==.

** Automate changing bin-width for color bins
** Do this by calulcating # needed to have XX bins
** Max anad Min across ALL countries
bysort mtype: egen maxv = max(metric)
bysort mtype: egen minv = min(metric) 
bysort mtype: egen maxgr = max(gr7)
bysort mtype: egen mingr = min(gr7) 
bysort mtype: egen maxnc = max(new)
bysort mtype: egen minnc = min(new) 

** Count: cumulative cases
gen diffv = maxv - minv 
gen diffc1 = diffv if mtype==1
egen diffc2 = min(diffc1) 
gen diffc = round(diffc2/25)
global binc = diffc 

** Count: attack rate
gen diffar1 = diffv if mtype==2
egen diffar2 = min(diffar1) 
gen diffar = diffar2/20
global binar = diffar 

** Count: cumulative deaths
gen diffd1 = diffv if mtype==3
egen diffd2 = min(diffd) 
gen diffd = round(diffd2/20)
global bind = diffd 

** Daily new events: cases
gen diffnc = maxnc - minnc 
gen diffnc1 = diffnc if mtype==1
egen diffnc2 = min(diffnc1) 
gen diffnc3 = round(diffnc2/10)
global binnc = diffnc3 

** Daily new events: deaths
gen diffnd = maxnc - minnc 
gen diffnd1 = diffnd if mtype==3
egen diffnd2 = min(diffnd1) 
gen diffnd3 = round(diffnd2/5)
global binnd = diffnd3 

** Growth rate : cases
replace gr7 = round(gr7, 1) 
gen diffgrc = maxgr - mingr 
gen diffgrc1 = diffgrc if mtype==1
egen diffgrc2 = min(diffgrc1) 
gen diffgrc3 = round(diffgrc2/10,1)
global bingrc = diffgrc3 

drop maxv minv diffv diffd diffd1 diffd2 diffc diffc1 diffc2 diffar diffar1 diffar2 diffgrc diffgrc1 diffgrc2 diffgrc3
drop maxgr mingr minnc maxnc diffnc diffnc1 diffnc2 diffnc3 diffnd diffnd1 diffnd2 diffnd3


** Automate final date on x-axis 
** Use latest date in dataset 
egen fdate1 = max(date)
global fdate = fdate1 
global fdatef : di %tdD_m date("$S_DATE", "DMY")


** New numeric running from 1 to 14 
gen corder = .
replace corder = 1 if iso_num==1        /* Anguilla */
replace corder = 2 if iso_num==3        /* Antigua */
replace corder = 3 if iso_num==4        /* Bahamas */
replace corder = 4 if iso_num==7        /* Barbados order */
replace corder = 5 if iso_num==5        /* Belize order */
replace corder = 6 if iso_num==6        /* Bermuda order */
replace corder = 7 if iso_num==30       /* British Virgin Islands */
replace corder = 8 if iso_num==9        /* Cayman islands */
replace corder = 9 if iso_num==10       /* Dominica */
replace corder = 10 if iso_num==13      /* Grenada */
replace corder = 11 if iso_num==14      /* Guyana */
replace corder = 12 if iso_num==16      /* Haiti */
replace corder = 13 if iso_num==18      /* Jamaica */
replace corder = 14 if iso_num==22      /* Montserrat */
replace corder = 15 if iso_num==19      /* St Kitts */
replace corder = 16 if iso_num==21      /* St Lucia */
replace corder = 17 if iso_num==29      /* St Vincent switched order*/
replace corder = 18 if iso_num==25      /* Suriname switched order*/
replace corder = 19 if iso_num==27      /* Trinidad switched order*/ 
replace corder = 20 if iso_num==26      /* Turks and Caicos Islands*/

/*
** -----------------------------------------
** HEATMAP -- NEW CASES
** -----------------------------------------
replace new = . if new==0
#delimit ;
    heatplot new i.corder date if mtype==1
    ,
    color(RdYlBu , reverse intensify(0.75 ))
    cuts(2 5 10 15 20 25 30 40 50 100 200)
    keylabels(all, range(1))
    p(lcolor(white) lalign(center) lw(0.05))
    discrete
    statistic(asis)
    missing(label("zero") fc(gs12) lc(gs16) lw(0.05) )

    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
    ysize(9) xsize(15)

    ylab(   1 "Anguilla"
            2 "Antigua and Barbuda" 
            3 "The Bahamas" 
            4 "Barbados"
            5 "Belize" 
            6 "Bermuda"
            7 "British Virgin Islands" 
            8 "Cayman Islands" 
            9 "Dominica"
            10 "Grenada"
            11 "Guyana"
            12 "Haiti"
            13 "Jamaica"
            14 "Montserrat" 
            15 "St Kitts and Nevis"
            16 "St Lucia"
            17 "St Vincent"
            18 "Suriname"
            19 "Trinidad and Tobago"
            20 "Turks and Caicos Islands"
    , labs(2.75) notick nogrid glc(gs16) angle(0))
    yscale(reverse fill noline range(0(1)14)) 
    ///yscale(log reverse fill noline) 
    ytitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 

    xlab(   21984 "10 Mar" 
            21994 "20 Mar" 
            22004 "30 Mar" 
            22015 "10 Apr"
            22025 "20 Apr"
            22035 "30 Apr"
            22045 "10 May"
            22055 "20 May"
            22065 "30 May"
            $fdate "$fdatef"
    , labs(2.75) nogrid glc(gs16) angle(45) format(%9.0f))
    xtitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 

    title("Daily cases by $S_DATE", pos(11) ring(1) size(3.5))

    legend(size(2.75) position(2) ring(5) colf cols(1) lc(gs16)
    region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
    sub("Daily" "Cases", size(2.75))
                    )
    name(heatmap_newcases) 
    ;
#delimit cr
graph export "`outputpath'/04_TechDocs/heatmap_newcases_$S_DATE.png", replace width(4000)




** -----------------------------------------
** HEATMAP -- CASES -- GROWTH RATE
** -----------------------------------------
replace gr7 = . if gr7==0
#delimit ;
    heatplot gr7 i.corder date if mtype==1
    ,
    color(RdYlBu , reverse intensify(0.75 ))
    cuts(1($bingrc)@max)
    ///cuts(2 4 6 8 10 12 14 16 18 20)
    keylabels(all, range(1))
    p(lcolor(white) lalign(center) lw(0.05))
    discrete
    statistic(asis)
    missing(label("zero") fc(gs12) lc(gs16) lw(0.05) )

    ///color(spmap, blues)
    ///cuts(1($bingrc)@max)
    ///keylabels(all, range(1))
    ///p(lcolor(white) lalign(center) lw(0.05))
    ///discrete
    ///statistic(asis)

    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
    ysize(9) xsize(15)

    ylab(   1 "Anguilla"
            2 "Antigua and Barbuda" 
            3 "The Bahamas" 
            4 "Barbados"
            5 "Belize" 
            6 "Bermuda"
            7 "British Virgin Islands" 
            8 "Cayman Islands" 
            9 "Dominica"
            10 "Grenada"
            11 "Guyana"
            12 "Haiti"
            13 "Jamaica"
            14 "Montserrat" 
            15 "St Kitts and Nevis"
            16 "St Lucia"
            17 "St Vincent"
            18 "Suriname"
            19 "Trinidad and Tobago"
            20 "Turks and Caicos Islands"
    , labs(2.75) notick nogrid glc(gs16) angle(0))
    yscale(reverse fill noline range(0(1)14)) 
    ///yscale(log reverse fill noline) 
    ytitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 

    xlab(   21984 "10 Mar" 
            21994 "20 Mar" 
            22004 "30 Mar" 
            22015 "10 Apr"
            22025 "20 Apr"
            22035 "30 Apr"
            22045 "10 May"
            22055 "20 May"
            22065 "30 May"
            $fdate "$fdatef"
    , labs(2.75) nogrid glc(gs16) angle(45) format(%9.0f))
    xtitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 

    title("Growth rate by $S_DATE", pos(11) ring(1) size(3.5))

    legend(size(2.75) position(2) ring(5) colf cols(1) lc(gs16)
    region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
    sub("Growth" "Rate (%)", size(2.75))
                    )
    name(heatmap_growthrate) 
    ;
#delimit cr
graph export "`outputpath'/04_TechDocs/heatmap_growthrate_$S_DATE.png", replace width(4000)



** -----------------------------------------
** HEATMAP -- CUMULATIVE CASES -- COUNT
** -----------------------------------------
replace metric = . if metric==0
#delimit ;
    heatplot metric i.corder date if mtype==1
    ,
    color(RdYlBu , reverse intensify(0.75 ))
    ///cuts(1($bingrc)@max)
    cuts(10 20 30 40 50 75 100 200 300 400 500 750 1000 2000 3000 4000 5000)
    keylabels(all, range(1))
    p(lcolor(white) lalign(center) lw(0.05))
    discrete
    statistic(asis)
    missing(label("zero") fc(gs12) lc(gs16) lw(0.05) )
    
    ///color(spmap, blues)
    ///cuts(@min($binc)@max)
    ///keylabels(all, range(1))
    ///p(lcolor(white) lalign(center) lw(0.05))
    ///discrete
    ///statistic(asis)

    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
    ysize(9) xsize(15)

    ylab(   1 "Anguilla"
            2 "Antigua and Barbuda" 
            3 "The Bahamas" 
            4 "Barbados"
            5 "Belize" 
            6 "Bermuda"
            7 "British Virgin Islands" 
            8 "Cayman Islands" 
            9 "Dominica"
            10 "Grenada"
            11 "Guyana"
            12 "Haiti"
            13 "Jamaica"
            14 "Montserrat" 
            15 "St Kitts and Nevis"
            16 "St Lucia"
            17 "St Vincent"
            18 "Suriname"
            19 "Trinidad and Tobago"
            20 "Turks and Caicos Islands"
    , labs(2.75) notick nogrid glc(gs16) angle(0))
    yscale(reverse fill noline range(0(1)14)) 
    ytitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 

    xlab(   21984 "10 Mar" 
            21994 "20 Mar" 
            22004 "30 Mar" 
            22015 "10 Apr"
            22025 "20 Apr"
            22035 "30 Apr"
            22045 "10 May"
            22055 "20 May"
            22065 "30 May"
            $fdate "$fdatef"
    , labs(2.75) nogrid glc(gs16) angle(45) format(%9.0f))
    xtitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 

    title("Cumulative cases by $S_DATE", pos(11) ring(1) size(3.5))

    legend(size(2.75) position(2) ring(4) colf cols(1) lc(gs16)
    region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
    sub("Confirmed" "Cases", size(2.75))
                    )
    name(heatmap_cases) 
    ;
#delimit cr
graph export "`outputpath'/04_TechDocs/heatmap_cases_$S_DATE.png", replace width(4000)



** -----------------------------------------
** HEATMAP -- CUMULATIVE DEATHS -- COUNT
** -----------------------------------------
#delimit ;
    heatplot metric i.corder date if mtype==3
    ,
    color(RdYlBu , reverse intensify(0.75 ))
    ///cuts(@min($bind)@max)
    cuts(5 10 15 20 25 30 35 40 45 50 60 70 80 90 100 200)
    keylabels(all, range(1))
    p(lcolor(white) lalign(center) lw(0.05))
    discrete
    statistic(asis)
    missing(label("zero") fc(gs12) lc(gs16) lw(0.05) )
    
    ///cuts(@min($bind)@max)
    ///color(spmap, reds)
    ///keylabels(all, range(1))
    ///p(lcolor(white) lalign(center) lw(0.05))
    ///discrete
    ///statistic(asis)

    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
    ysize(12) xsize(12)

    ylab(   1 "Anguilla"
            2 "Antigua and Barbuda" 
            3 "The Bahamas" 
            4 "Barbados"
            5 "Belize" 
            6 "Bermuda"
            7 "British Virgin Islands" 
            8 "Cayman Islands" 
            9 "Dominica"
            10 "Grenada"
            11 "Guyana"
            12 "Haiti"
            13 "Jamaica"
            14 "Montserrat" 
            15 "St Kitts and Nevis"
            16 "St Lucia"
            17 "St Vincent"
            18 "Suriname"
            19 "Trinidad and Tobago"
            20 "Turks and Caicos Islands"
    , labs(2.75) notick nogrid glc(gs16) angle(0))
    yscale(reverse fill noline range(0(1)14)) 
    ytitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 

    xlab(   21984 "10 Mar" 
            21994 "20 Mar" 
            22004 "30 Mar" 
            22015 "10 Apr"
            22025 "20 Apr"
            22035 "30 Apr"
            22045 "10 May"
            22055 "20 May"
            22065 "30 May"
            $fdate "$fdatef"
    , labs(2.75) nogrid glc(gs16) angle(45) format(%9.0f))
    xtitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 

    title("Cumulative deaths by $S_DATE", pos(11) ring(1) size(3.5))

    legend(size(2.75) position(2) ring(4) colf cols(1) lc(gs16)
    region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
    sub("Confirmed" "Deaths", size(2.75))
    )
    name(heatmap_deaths) 
    ;
#delimit cr 
graph export "`outputpath'/04_TechDocs/heatmap_deaths_$S_DATE.png", replace width(4000)


** -----------------------------------------
** HEATMAP -- NEW DEATHS
** -----------------------------------------
#delimit ;
    heatplot new i.corder date if mtype==3
    ,
    color(RdYlBu , reverse intensify(0.75 ))
    cuts(@min(1){@max+1})
    ///cuts(5 10 15 20 25 30 35 40 45 50 60 70 80 90 100 200)
    keylabels(all, range(1))
    p(lcolor(white) lalign(center) lw(0.05))
    discrete
    statistic(asis)
    missing(label("zero") fc(gs12) lc(gs16) lw(0.05) )
    srange(1)

    ///color(spmap, reds)
    ///cuts(@min(1){@max+1})
    ///keylabels(all, range(1))
    ///p(lcolor(white) lalign(center) lw(0.05))
    ///discrete
    ///statistic(asis)
    ///srange(1)

    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
    ysize(12) xsize(12)

    ylab(   1 "Anguilla"
            2 "Antigua and Barbuda" 
            3 "The Bahamas" 
            4 "Barbados"
            5 "Belize" 
            6 "Bermuda"
            7 "British Virgin Islands" 
            8 "Cayman Islands" 
            9 "Dominica"
            10 "Grenada"
            11 "Guyana"
            12 "Haiti"
            13 "Jamaica"
            14 "Montserrat" 
            15 "St Kitts and Nevis"
            16 "St Lucia"
            17 "St Vincent"
            18 "Suriname"
            19 "Trinidad and Tobago"
            20 "Turks and Caicos Islands"
    , labs(2.75) notick nogrid glc(gs16) angle(0))
    yscale(reverse fill noline range(0(1)14)) 
    ///yscale(log reverse fill noline) 
    ytitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 

    xlab(   21984 "10 Mar" 
            21994 "20 Mar" 
            22004 "30 Mar" 
            22015 "10 Apr"
            22025 "20 Apr"
            22035 "30 Apr"
            22045 "10 May"
            22055 "20 May"
            22065 "30 May"
            $fdate "$fdatef"
    , labs(2.75) nogrid glc(gs16) angle(45) format(%9.0f))
    xtitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 

    title("Daily deaths by $S_DATE", pos(11) ring(1) size(3.5))

    legend(size(2.75) position(2) ring(5) colf cols(1) lc(gs16)
    region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
    sub("Daily" "Deaths", size(2.75))
                    )
    name(heatmap_newdeaths) 
    ;
#delimit cr
graph export "`outputpath'/04_TechDocs/heatmap_newdeaths_$S_DATE.png", replace width(4000)




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
    putpdf table intro1(1,2)=("COVID-19 Heatmap: Daily Cases in 20 Caribbean Countries and Territories"), halign(left) linebreak font("Calibri Light", 12, 000000)
    putpdf table intro1(1,2)=("Briefing created by staff of the George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro1(1,2)=("and the Public Health Group of The Faculty of Medical Sciences, Cave Hill Campus, "), halign(left) append  
    putpdf table intro1(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro1(1,2)=("Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro1(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic   
    putpdf table intro1(1,2)=("For all our COVID-19 surveillance outputs, go to "), halign(left) append
    putpdf table intro1(1,2)=("https://tinyurl.com/uwi-covid19-surveillance "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

** PAGE 1. INTRODUCTION
    putpdf paragraph ,  font("Calibri Light", 9)
    putpdf text ("Aim of this briefing. ") , bold
    putpdf text ("On this page we present the number of confirmed daily COVID-19 cases ")
    putpdf text ("(see note 1)"), bold 
    putpdf text (" among 20 Caribbean countries and territories ") 
    putpdf text ("(see note 2)"), bold
    putpdf text (" since the start of the outbreak. ") 
    putpdf text ("We present this information as a heatmap to visually summarise the situation as of $S_DATE. ") 
    putpdf text ("The heatmap was created for two main reasons: (A) to highlight outbreak hotspots, and (B) to track locations that have seen small numbers of recent cases. ") 
    putpdf text ("An extended period with no or sporadic isolated cases might be used as one of several ") 
    putpdf text ("potential triggers needed before considering the easing of national COVID-19 control measures.")

** PAGE 1. FIGURE OF DAILY COVID-19 COUNT
    putpdf table f1 = (1,1), width(92%) border(all,nil) halign(center)
    putpdf table f1(1,1)=image("`outputpath'/04_TechDocs/heatmap_newcases_$S_DATE.png")



** PAGE 2. GROWTH CURVES
** PAGE 2. TITLE, ATTRIBUTION, DATE of CREATION
putpdf pagebreak
    putpdf table intro2 = (1,16), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil)
    putpdf table intro2(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(15)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 Heatmap: Growth Curves in 20 Caribbean Countries and Territories"), halign(left) linebreak font("Calibri Light", 12, 000000)
    putpdf table intro2(1,2)=("Briefing created by staff of the George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro2(1,2)=("and the Public Health Group of The Faculty of Medical Sciences, Cave Hill Campus, "), halign(left) append  
    putpdf table intro2(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro2(1,2)=("Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro2(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic   
    putpdf table intro2(1,2)=("For all our COVID-19 surveillance outputs, go to "), halign(left) append
    putpdf table intro2(1,2)=("https://tinyurl.com/uwi-covid19-surveillance "), halign(left) underline append linebreak 
    putpdf table intro2(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

** PAGE 2. INTRODUCTION
    putpdf paragraph ,  font("Calibri Light", 9)
    putpdf text ("Aim of this briefing. ") , bold
    putpdf text ("On this page we present growth rates for confirmed COVID-19 cases ")
    putpdf text ("(see notes 1 and 3)"), bold 
    putpdf text (" among 20 Caribbean countries and territories ") 
    putpdf text ("(see note 2)"), bold
    putpdf text (" since the start of the outbreak. ") 
    putpdf text ("We present this information as a heatmap to visually summarise the situation as of $S_DATE. ") 
    putpdf text ("The growth rate helps us to better understand ") 
    putpdf text ("whether the outbreak is worsening ") 
    putpdf text ("(an increasing or static growth rate)"), italic 
    putpdf text (" or improving ")
    putpdf text ("(a decreasing growth rate)"), italic 
    putpdf text (" in each location. ") 
    putpdf text ("An extended period with no or sporadic low growth might be used as one of several ") 
    putpdf text ("potential triggers needed before considering the easing of national COVID-19 control measures.")
    
** PAGE 2. FIGURE OF COVID-19 GROWTH RATE
    putpdf table f2 = (1,1), width(92%) border(all,nil) halign(center)
    putpdf table f2(1,1)=image("`outputpath'/04_TechDocs/heatmap_growthrate_$S_DATE.png")



** PAGE 3. CUMULATIVE CASES
** PAGE 3. TITLE, ATTRIBUTION, DATE of CREATION
putpdf pagebreak
    putpdf table intro2 = (1,16), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil)
    putpdf table intro2(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(15)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 Heatmap: Cumulative Cases in 20 Caribbean Countries and Territories"), halign(left) linebreak font("Calibri Light", 12, 000000)
    putpdf table intro2(1,2)=("Briefing created by staff of the George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro2(1,2)=("and the Public Health Group of The Faculty of Medical Sciences, Cave Hill Campus, "), halign(left) append  
    putpdf table intro2(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro2(1,2)=("Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro2(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic   
    putpdf table intro2(1,2)=("For all our COVID-19 surveillance outputs, go to "), halign(left) append
    putpdf table intro2(1,2)=("https://tinyurl.com/uwi-covid19-surveillance "), halign(left) underline append linebreak 
    putpdf table intro2(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

** PAGE 3. INTRODUCTION
    putpdf paragraph ,  font("Calibri Light", 9)
    putpdf text ("Aim of this briefing. ") , bold
    putpdf text ("We present the cumulative number of confirmed COVID-19 cases ")
    putpdf text ("(see note 1)"), bold 
    putpdf text (" among 20 Caribbean countries and territories ") 
    putpdf text ("(see note 2)"), bold
    putpdf text (" since the start of the outbreak. ") 
    putpdf text ("We use heatmaps to visually summarise the situation as of $S_DATE. ") 
    putpdf text ("The intention is to highlight outbreak hotspots."), linebreak 

** PAGE 3. FIGURE OF COVID-19 CUMULATIVE CASES
    putpdf table f2 = (1,1), width(92%) border(all,nil) halign(center)
    putpdf table f2(1,1)=image("`outputpath'/04_TechDocs/heatmap_cases_$S_DATE.png")



** PAGE 4. DEATHS
** PAGE 4. TITLE, ATTRIBUTION, DATE of CREATION
putpdf pagebreak
    putpdf table intro4 = (1,16), width(100%) halign(left)    
    putpdf table intro4(.,.), border(all, nil)
    putpdf table intro4(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro4(1,1)
    putpdf table intro4(1,2), colspan(15)
    putpdf table intro4(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro4(1,2)=("COVID-19 Heatmap: Deaths in 20 Caribbean Countries and Territories"), halign(left) linebreak font("Calibri Light", 12, 000000)
    putpdf table intro4(1,2)=("Briefing created by staff of the George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro4(1,2)=("and the Public Health Group of The Faculty of Medical Sciences, Cave Hill Campus, "), halign(left) append  
    putpdf table intro4(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro4(1,2)=("Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro4(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic   
    putpdf table intro4(1,2)=("For all our COVID-19 surveillance outputs, go to "), halign(left) append
    putpdf table intro4(1,2)=("https://tinyurl.com/uwi-covid19-surveillance "), halign(left) underline append linebreak 
    putpdf table intro4(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

** PAGE 4. INTRODUCTION
    putpdf paragraph ,  font("Calibri Light", 9)
    putpdf text ("Aim of this briefing. ") , bold
    putpdf text ("On this page we present the number of confirmed daily and cumulative COVID-19 deaths ")
    putpdf text ("(see note 1)"), bold 
    putpdf text (" among 20 Caribbean countries and territories ") 
    putpdf text ("(see note 2)"), bold
    putpdf text (" since the start of the outbreak. ") 
    putpdf text ("We present this information as a heatmap to visually summarise the situation as of $S_DATE. ") 

** PAGE 4. FIGURE OF COVID-19 DEATHS
    putpdf table f3 = (1,2), width(95%) border(all,nil) halign(center)
    putpdf table f3(1,1)=image("`outputpath'/04_TechDocs/heatmap_newdeaths_$S_DATE.png")
    putpdf table f3(1,2)=image("`outputpath'/04_TechDocs/heatmap_deaths_$S_DATE.png")

** REPORT PAGE 4 - FOOTNOTE 1. DATA REFERENCE
** REPORT PAGE 4 - FOOTNOTE 2. CARICOM COUNTRIES
** REPORT PAGE 4 - FOOTNOTE 3. GROWTH RATE
    putpdf table p3 = (3,1), width(100%) halign(center) 
    putpdf table p3(.,1), font("Calibri Light", 8) border(all,nil) bgcolor(ffffff)
    putpdf table p3(1,1)=("(NOTE 1) Data Source. "), bold halign(left)
    putpdf table p3(1,1)=("Dong E, Du H, Gardner L. An interactive web-based dashboard to track COVID-19 "), append 
    putpdf table p3(1,1)=("in real time. Lancet Infect Dis; published online Feb 19. https://doi.org/10.1016/S1473-3099(20)30120-1"), append

    putpdf table p3(2,1)=("(NOTE 2) Countries and territories included in this briefing: "), bold halign(left)
    putpdf table p3(2,1)=("Countries and territories included in this briefing: "), halign(left) append
    putpdf table p3(2,1)=("CARICOM member states: "), italic halign(left) append
    putpdf table p3(2,1)=("Antigua and Barbuda, The Bahamas, Barbados, Belize, Dominica, Grenada, Guyana, Haiti, Jamaica, "), append 
    putpdf table p3(2,1)=("St. Kitts and Nevis, St. Lucia, St. Vincent and the Grenadines, Suriname, Trinidad and Tobago."), append
    putpdf table p3(2,1)=("United Kingdom Overseas Territories (UKOTS): "), italic append
    putpdf table p3(2,1)=("Anguilla, Bermuda, British Virgin Islands, Cayman Islands, Montserrat, Turks and Caicos Islands."), append 

    putpdf table p3(3,1)=("(NOTE 3) Growth Rate.  "), bold halign(left)
    putpdf table p3(3,1)=("The heatmap on page 2 presents the growth rate among confirmed cases. "), append 
    putpdf table p3(3,1)=("Growth rate is a relative rate. To calculate the growth rate we divide the total cases on each day by the total cases the previous day,  "), append
    putpdf table p3(3,1)=("then we take the logiartithm of that value. The equation is therefore: "), append 
    putpdf table p3(3,1)=("growth rate = log(cases/cases on previous day). "), append italic
    putpdf table p3(3,1)=("A value of 1 can be interpreted as a 1% daily growth in the number of confirmed COVID-19 cases. "), append

** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    ** putpdf save "`outputpath'/05_Outputs/covid19_heatmap_version3_`date_string'", replace
    putpdf save "`syncpath'/covid19_heatmap_version4_`date_string'", replace
