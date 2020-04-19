** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					covidprofiles_006_region1.do
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
    log using "`logpath'\covidprofiles_006_region1", replace
** HEADER -----------------------------------------------------


** -----------------------------------------
** Pre-Load the COVID metrics --> as Global Macros
** -----------------------------------------
qui do "`logpath'\covidprofiles_004_metrics"
** -----------------------------------------

** Close any open log file and open a new log file
capture log close
log using "`logpath'\covidprofiles_005_country1", replace

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

** Attack Rate (per 1,000 --> not yet used)
gen confirmed_rate = (confirmed / pop) * 10000
** "Fix" --> Early Guyana values 
replace confirmed = 4 if country==9 & date>=d(17mar2020) & date<=d(23mar2020)

** SMOOTHED CASES for graphic
by country: asrol confirmed , stat(mean) window(date 3) gen(confirmed_av3)
by country: asrol deaths , stat(mean) window(date 3) gen(deaths_av3)


** REGIONAL VALUES
rename confirmed metric1
rename confirmed_rate metric2
rename deaths metric3
rename recovered metric4
reshape long metric, i(country iso date) j(mtype)
label define mtype_ 1 "cases" 2 "attack rate" 3 "deaths" 4 "recovered"
label values mtype mtype_
keep if mtype==1 | mtype==3
sort country mtype date 

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

** SUBSETS 
gen touse = 1
replace touse = 0 if iso=="GBR" | iso=="USA" | iso=="KOR" | iso=="SGP" | iso=="DOM" | iso=="CUB"

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


** LOOP through N=14 CARICOM member states
local clist "ATG BHS BRB BLZ DMA GRD GUY HTI JAM KNA LCA VCT SUR TTO"
foreach country of local clist {

    ** country  = 3-character ISO name
    ** cname    = FULL country name
    ** -country- used in all loop structures
    ** -cname- used for visual display of full country name on PDF
    gen c3 = country if iso=="`country'"
    label values c3 cname_
    egen c4 = min(c3)
    label values c4 cname_
    decode c4, gen(c5)
    local cname = c5
    drop c3 c4 c5

    ** Position of value on cases x and y-axis
    global cposx_`country' = ${m05_`country'}/4
    global cposy_`country' = ${m01_`country'}/1.5
    ** Position of value on deaths x-axis
    global dposx_`country' = ${m06_`country'}/4
    global dposy_`country' = ${m02_`country'}/1.5

** 1. BAR CHART    --> CUMULATIVE CASES
        #delimit ;
        gr twoway 
            (bar metric elapsed if iso=="`country'" & elapsed<=${m05_`country'} & mtype==1, col("181 215 244"))
            (line confirmed_av3 elapsed if iso=="`country'" & elapsed<=${m05_`country'} & mtype==1, lc("14 73 124") lw(0.4) lp("-"))
            (scat confirmed_av3 elapsed if iso=="`country'" & elapsed<=${m05_`country'} & mtype==1, msize(1.5) mc("14 73 124") m(o)
            )
            ,
            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(2.5) xsize(5)
            
            xlab(0(1)${m05_`country'}
            , labs(6) nogrid glc(gs16) angle(0) format(%9.0f))
            xtitle("Days since first case", size(6) margin(l=2 r=2 t=2 b=2)) 
            xscale(off range(1(1)${m05_`country'})) 

            ylab(0(1)${m01_`country'}
            , labs(6) notick nogrid glc(gs16) angle(0))
            yscale(off) 
            ytitle("Cumulative # of Cases", size(6) margin(l=2 r=2 t=2 b=2)) 

            text(${cposy_`country'} ${cposx_`country'} "${m01_`country'}", size(25) place(e) color("14 73 124") j(left))

            legend(off size(6) position(5) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                )
                name(case_`country') 
                ;
        #delimit cr
        graph export "`outputpath'/04_TechDocs/cases_`country'_$S_DATE.png", replace width(400)


** 1. BAR CHART    --> CUMULATIVE DEATHS
        #delimit ;
        gr twoway 
            (bar metric elapsed if iso=="`country'" & elapsed<=${m05_`country'}  & mtype==3, col("255 158 131"))
            (line deaths_av3 elapsed if iso=="`country'" & elapsed<=${m05_`country'} & mtype==3, lc("124 10 7") lw(0.4) lp("-"))
            (scat deaths_av3 elapsed if iso=="`country'" & elapsed<=${m05_`country'}     & mtype==3, msize(1.5) mc("124 10 7") m(o)
            )
            ,
            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(2.5) xsize(5)
            
            xlab(0(1)${m05_`country'}
            , labs(6) nogrid glc(gs16) angle(0) format(%9.0f))
            xtitle("Days since first case", size(6) margin(l=2 r=2 t=2 b=2)) 
            xscale(off range(0(1)${m05_`country'})) 

            ylab(0(1)${m02_`country'}
            , labs(6) notick nogrid glc(gs16) angle(0))
            yscale(off range(0(1)${m02_`country'})) 
            ytitle("Cumulative # of Cases", size(6) margin(l=2 r=2 t=2 b=2)) 

            text(${dposy_`country'} ${dposx_`country'} "${m02_`country'}", size(25) place(e) color("124 10 7") j(left))

            legend(off size(6) position(5) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                )
                name(death_`country') 
                ;
        #delimit cr
        graph export "`outputpath'/04_TechDocs/deaths_`country'_$S_DATE.png", replace width(400)

** LINE CHART (LOGARITHM)
** LINE against region for other 13 CARICOM countries 
preserve
    #delimit ; 
    keep if 
        iso=="ATG" |
        iso=="BHS" |
        iso=="BRB" |
        iso=="BLZ" |
        iso=="DMA" |
        iso=="GRD" |
        iso=="GUY" |
        iso=="HTI" |
        iso=="JAM" |
        iso=="KNA" |
        iso=="LCA" |
        iso=="VCT" |
        iso=="SUR" |
        iso=="TTO";
    #delimit cr   
    gen out = 0
    replace out = 1 if iso=="`country'"

    #delimit ;
    collapse    (sum) metric_tot=metric
                (mean) metric_av=metric
                (p50) metric_p50=metric
                (p05) metric_p05=metric
                (p25) metric_p25=metric
                (p75) metric_p75=metric
                (p95) metric_p95=metric
                (min) metric_min=metric
                (max) metric_max=metric
                , by(out mtype date);
    #delimit cr 

    bysort out mtype: gen elapsed = _n

    ** SMOOTHED CASES for graphic
    sort mtype out date
    bysort mtype out: asrol metric_tot , stat(mean) window(date 7) gen(tots)
    bysort mtype out: asrol metric_p50 , stat(mean) window(date 7) gen(p50s)
    bysort mtype out: asrol metric_p05 , stat(mean) window(date 7) gen(p05s)
    bysort mtype out: asrol metric_p25 , stat(mean) window(date 7) gen(p25s)
    bysort mtype out: asrol metric_p75 , stat(mean) window(date 7) gen(p75s)
    bysort mtype out: asrol metric_p95 , stat(mean) window(date 7) gen(p95s)


    #delimit ;
        gr twoway             
            (line p50s elapsed if elapsed<=${m05_`country'}         & mtype==1 & out==0, lc("71 129 179") lw(0.4) lp("-"))
            (rarea p05s p25s elapsed if elapsed<=${m05_`country'}   & mtype==1 & out==0 , col("181 215 244%50") lw(none))
            (rarea p25s p75s elapsed if elapsed<=${m05_`country'}   & mtype==1 & out==0 , col("121 169 211%50") lw(none))
            (rarea p75s p95s elapsed if elapsed<=${m05_`country'}   & mtype==1 & out==0 , col("181 215 244%50") lw(none))

            (line tots elapsed if elapsed<=${m05_`country'}   & mtype==1 & out==1, lc("14 73 124") lw(0.4) lp("-"))
            (scat tots elapsed if elapsed<=${m05_`country'}   & mtype==1 & out==1, msize(2.5) mc("14 73 124") m(o))
            ,
            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(5) xsize(7.5)
            
                xlab(1(1)${m05_`country'}
                , 
                labs(6) notick nogrid glc(gs16))
                xscale(off  noline) 
                xtitle("Days since first case", size(6) margin(l=2 r=2 t=2 b=2)) 
                
                ylab(
                ,
                labs(5) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Cumulative # of Cases", size(6) margin(l=2 r=2 t=2 b=2)) 
                yscale(log off)

                legend(off size(6) position(5) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                )
                name(line_`country') 
                ;
        #delimit cr
        graph export "`outputpath'/04_TechDocs/spark_`country'_$S_DATE.png", replace width(4000)
restore 
}

** ------------------------------------------------------
** PDF REGIONAL REPORT (COUNTS OF CONFIRMED CASES)
** ------------------------------------------------------
    putpdf begin, pagesize(letter) font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.25cm) margin(left,0.5cm) margin(right,0.25cm)

** TITLE, ATTRIBUTION, DATE of CREATION
    putpdf table intro = (1,12), width(100%) halign(left)    
    putpdf table intro(.,.), border(all, nil)
    putpdf table intro(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro(1,1)
    putpdf table intro(1,2), colspan(11)
    putpdf table intro(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro(1,2)=("COVID-19 trajectories for 14 CARICOM countries"), halign(left) linebreak font("Calibri Light", 12, 000000)
    putpdf table intro(1,2)=("Briefing created by staff of the George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro(1,2)=("and the Public Health Group of The Faculty of Medical Sciences, Cave Hill Campus, "), halign(left) append  
    putpdf table intro(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro(1,2)=("Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic   
    putpdf table intro(1,2)=("For all our COVID-19 surveillance outputs, go to "), halign(left) append
    putpdf table intro(1,2)=("https://tinyurl.com/uwi-covid19-surveillance "), halign(left) underline append linebreak 
    putpdf table intro(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

** INTRODUCTION
    putpdf paragraph ,  font("Calibri Light", 9)
    putpdf text ("Aim of this briefing. ") , bold
    putpdf text ("We present the cumulative number of confirmed cases and deaths ")
    putpdf text ("(see note 1)"), bold 
    putpdf text (" from COVID-19 infection among CARICOM countries since the start of the outbreak (we define the outbreak length as ") 
    putpdf text ("the number of days since the first confirmed case in each country). ") 
    putpdf text ("In our first table, we summarise the situation among the 14 CARICOM member states ") 
    putpdf text ("(see note 2)"), bold
    putpdf text (" as of $S_DATE.") 
    putpdf text (" We then summarise the situation each each country visually, describing cumulative cases, cumulative deaths, ") 
    putpdf text (" and outbreak growth rates."), linebreak 

** TABLE: REGIONAL SUMMARY METRICS
    putpdf table t1 = (4,6), width(100%) halign(center)    
    putpdf table t1(1,1), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(2,1), font("Calibri Light", 12, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,1), font("Calibri Light", 12, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(4,1), font("Calibri Light", 12, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(1,2), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(2,2), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,2), font("Calibri Light", 11, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(4,2), font("Calibri Light", 11, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(1,3), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(2,3), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,3), font("Calibri Light", 11, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(4,3), font("Calibri Light", 11, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(1,4), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(2,4), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,4), font("Calibri Light", 11, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(4,4), font("Calibri Light", 11, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(1,5), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(2,5), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,5), font("Calibri Light", 11, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(4,5), font("Calibri Light", 11, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(1,6), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(2,6), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,6), font("Calibri Light", 11, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(4,6), font("Calibri Light", 11, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 

    putpdf table t1(1,2)=("Total"), halign(center) 
    putpdf table t1(1,3)=("New"), halign(center) 
    putpdf table t1(2,3)=("(1 day)"), halign(center) 
    putpdf table t1(1,4)=("New"), halign(center) 
    putpdf table t1(2,4)=("(1 week)"), halign(center) 
    putpdf table t1(1,5)=("Date of"), halign(center) 
    putpdf table t1(2,5)=("1st confirmed"), halign(center) 
    putpdf table t1(1,6)=("Days since"), halign(center) 
    putpdf table t1(2,6)=("1st confirmed"), halign(center) 
    putpdf table t1(1,1)=("Confirmed"), halign(center) 
    putpdf table t1(2,1)=("Events"), halign(center) 
    putpdf table t1(3,1)=("Cases"), halign(center) 
    putpdf table t1(4,1)=("Deaths"), halign(center)  

    putpdf table t1(3,2)=("${m01}"), halign(center) 
    putpdf table t1(4,2)=("${m02}"), halign(center) 
    putpdf table t1(3,3)=("${m60}"), halign(center) 
    putpdf table t1(4,3)=("${m61}"), halign(center) 
    putpdf table t1(3,4)=("${m62}"), halign(center) 
    putpdf table t1(4,4)=("${m63}"), halign(center) 
    putpdf table t1(3,5)=("${m03}"), halign(center) 
    putpdf table t1(4,5)=("${m04}"), halign(center) 
    putpdf table t1(3,6)=("${m05}"), halign(center) 
    putpdf table t1(4,6)=("${m06}"), halign(center) 



** TABLE PAGE 1: COUNTRY SUMMARY METRICS
    putpdf table t2 = (8,11), width(100%) halign(center)    

    putpdf table t2(1,.), font("Calibri Light", 9, 000000) border(all, nil) valign(middle) 
    putpdf table t2(2,.), font("Calibri Light", 9, 000000) border(all, nil) bgcolor(e6e6e6) valign(middle)
    putpdf table t2(3,.), font("Calibri Light", 11, 000000) border(all, nil) valign(middle)
    putpdf table t2(4,.), font("Calibri Light", 11, 000000) border(all, nil) valign(middle)
    putpdf table t2(5,.), font("Calibri Light", 11, 000000) border(all, nil) valign(middle)
    putpdf table t2(6,.), font("Calibri Light", 11, 000000) border(all, nil) valign(middle)
    putpdf table t2(7,.), font("Calibri Light", 11, 000000) border(all, nil) valign(middle)
    putpdf table t2(8,.), font("Calibri Light", 11, 000000) border(all, nil) valign(middle)
 

    putpdf table t2(.,1), font("Calibri Light", 11, 000000) halign(right)
    putpdf table t2(.,2), font("Calibri Light", 11, 000000) halign(right) 
    putpdf table t2(.,3), font("Calibri Light", 11, 000000) halign(right)
    putpdf table t2(.,4), font("Calibri Light", 12, 0e497c) halign(right)
    putpdf table t2(.,5), font("Calibri Light", 12, 0e497c) halign(right)
    putpdf table t2(.,6), font("Calibri Light", 11, 000000) halign(right)
    putpdf table t2(.,7), font("Calibri Light", 11, 000000) halign(right)
    putpdf table t2(.,8), font("Calibri Light", 12, 7c0a07) halign(right) 
    putpdf table t2(.,9), font("Calibri Light", 12, 7c0a07) halign(right)
    putpdf table t2(.,10), font("Calibri Light", 11, 000000) halign(right)
    putpdf table t2(.,11), font("Calibri Light", 11, 000000) halign(right)

    putpdf table t2(1,1), font("Calibri Light", 9, 000000) colspan(11) halign(left)
    putpdf table t2(2,1), font("Calibri Light", 10, 000000) bold halign(left)
    putpdf table t2(2,2), font("Calibri Light", 10, 0e497c) bold halign(center)
    putpdf table t2(2,3), font("Calibri Light", 10, 0e497c) bold halign(center)
    putpdf table t2(2,4), font("Calibri Light", 10, 0e497c) bold halign(center)
    putpdf table t2(2,5), font("Calibri Light", 10, 0e497c) bold halign(center)
    putpdf table t2(2,6), font("Calibri Light", 10, 7c0a07) bold halign(center)
    putpdf table t2(2,7), font("Calibri Light", 10, 7c0a07) bold halign(center)
    putpdf table t2(2,8), font("Calibri Light", 10, 7c0a07) bold halign(center)
    putpdf table t2(2,9), font("Calibri Light", 10, 7c0a07) bold halign(center)
    putpdf table t2(2,10), font("Calibri Light", 10, 0e497c) bold halign(center)
    putpdf table t2(2,11), font("Calibri Light", 10, 0e497c) bold halign(center)

    putpdf table t2(1,1)=("The Table below summarises the progression of the COVID-19 outbreak as of $S_DATE. "),  halign(left) 
    putpdf table t2(1,1)=("The first THREE colums "),  halign(left) append
    putpdf table t2(1,1)=("IN BLUE"),  halign(left) font("Calibri Light", 10, 0e497c) append underline
    putpdf table t2(1,1)=(" summarise the number of cases. The next THREE columns "),  halign(left) append
    putpdf table t2(1,1)=("IN RED"),  halign(left) font("Calibri Light", 10, 7c0a07) append underline
    putpdf table t2(1,1)=(" summarise the number of deaths. The final column "), append 
    putpdf table t2(1,1)=("IN BLUE"),  halign(left) font("Calibri Light", 10, 0e497c) append underline
    putpdf table t2(1,1)=(" describes the growth rate of the "),  halign(left) append
    putpdf table t2(1,1)=("outbreak in each country. The dark line represents the rate in the country. "),  halign(left) append
    putpdf table t2(1,1)=("The shaded region represents the range of rates in the remaining 13 CARICOM member states "),  halign(left) append 
    putpdf table t2(1,1)=("(see note 3)"), bold append
    putpdf table t2(1,1)=("."),  halign(left) append linebreak
    putpdf table t2(1,1)=(" "),  halign(left) append 

    putpdf table t2(2,1)=("Country"),  halign(left) bgcolor(e6e6e6) 
    putpdf table t2(3,1)=("Antigua"), bold halign(left)
    putpdf table t2(4,1)=("Bahamas"), bold halign(left)
    putpdf table t2(5,1)=("Barbados"), bold halign(left)
    putpdf table t2(6,1)=("Belize"), bold halign(left)
    putpdf table t2(7,1)=("Dominica"), bold halign(left)
    putpdf table t2(8,1)=("Grenada"), bold halign(left)

    putpdf table t2(2,2)=("Total cases"),  halign(center) colspan(2) bgcolor(e6e6e6) 
    putpdf table t2(3,2)=image("`outputpath'/04_TechDocs/cases_ATG_$S_DATE.png") , colspan(2)
    putpdf table t2(4,2)=image("`outputpath'/04_TechDocs/cases_BHS_$S_DATE.png") , colspan(2)
    putpdf table t2(5,2)=image("`outputpath'/04_TechDocs/cases_BRB_$S_DATE.png") , colspan(2)
    putpdf table t2(6,2)=image("`outputpath'/04_TechDocs/cases_BLZ_$S_DATE.png") , colspan(2)
    putpdf table t2(7,2)=image("`outputpath'/04_TechDocs/cases_DMA_$S_DATE.png") , colspan(2)
    putpdf table t2(8,2)=image("`outputpath'/04_TechDocs/cases_GRD_$S_DATE.png") , colspan(2)

    putpdf table t2(2,4)=("Cases in past week"),  halign(center) bgcolor(e6e6e6) 
    putpdf table t2(3,4)=(${m62_ATG}), halign(center) 
    putpdf table t2(4,4)=(${m62_BHS}), halign(center) 
    putpdf table t2(5,4)=(${m62_BRB}), halign(center) 
    putpdf table t2(6,4)=(${m62_BLZ}), halign(center) 
    putpdf table t2(7,4)=(${m62_DMA}), halign(center) 
    putpdf table t2(8,4)=(${m62_GRD}), halign(center) 

    putpdf table t2(2,5)=("Days since 1st case"),  halign(center)  bgcolor(e6e6e6) 
    putpdf table t2(3,5)=(${m05_ATG}), halign(center) 
    putpdf table t2(4,5)=(${m05_BHS}), halign(center) 
    putpdf table t2(5,5)=(${m05_BRB}), halign(center) 
    putpdf table t2(6,5)=(${m05_BLZ}), halign(center) 
    putpdf table t2(7,5)=(${m05_DMA}), halign(center) 
    putpdf table t2(8,5)=(${m05_GRD}), halign(center) 

    putpdf table t2(2,6)=("Total deaths"),  halign(center) colspan(2) bgcolor(e6e6e6) 
    putpdf table t2(3,6)=image("`outputpath'/04_TechDocs/deaths_ATG_$S_DATE.png") , colspan(2) 
    putpdf table t2(4,6)=image("`outputpath'/04_TechDocs/deaths_BHS_$S_DATE.png") , colspan(2) 
    putpdf table t2(5,6)=image("`outputpath'/04_TechDocs/deaths_BRB_$S_DATE.png") , colspan(2) 
    putpdf table t2(6,6)=image("`outputpath'/04_TechDocs/deaths_BLZ_$S_DATE.png") , colspan(2)
    putpdf table t2(7,6)=image("`outputpath'/04_TechDocs/deaths_DMA_$S_DATE.png") , colspan(2)
    putpdf table t2(8,6)=image("`outputpath'/04_TechDocs/deaths_GRD_$S_DATE.png") , colspan(2)

    putpdf table t2(2,8)=("Deaths in past week"),  halign(center)  bgcolor(e6e6e6) 
    putpdf table t2(3,8)=(${m63_ATG}), halign(center) 
    putpdf table t2(4,8)=(${m63_BHS}), halign(center) 
    putpdf table t2(5,8)=(${m63_BRB}), halign(center) 
    putpdf table t2(6,8)=(${m63_BLZ}), halign(center) 
    putpdf table t2(7,8)=(${m63_DMA}), halign(center) 
    putpdf table t2(8,8)=(${m63_GRD}), halign(center) 

    putpdf table t2(2,9)=("Days since 1st death"),  halign(center)  bgcolor(e6e6e6) 
    putpdf table t2(3,9)=(${m06_ATG}), halign(center) 
    putpdf table t2(4,9)=(${m06_BHS}), halign(center) 
    putpdf table t2(5,9)=(${m06_BRB}), halign(center) 
    putpdf table t2(6,9)=(${m06_BLZ}), halign(center) 
    putpdf table t2(7,9)=(${m06_DMA}), halign(center) 
    putpdf table t2(8,9)=(${m06_GRD}), halign(center) 

    putpdf table t2(2,10)=("CARICOM growth rates among cases"),  halign(center) colspan(2) bgcolor(e6e6e6) 
    putpdf table t2(3,10)=image("`outputpath'/04_TechDocs/spark_ATG_$S_DATE.png") , colspan(2)
    putpdf table t2(4,10)=image("`outputpath'/04_TechDocs/spark_BHS_$S_DATE.png") , colspan(2)
    putpdf table t2(5,10)=image("`outputpath'/04_TechDocs/spark_BRB_$S_DATE.png") , colspan(2)
    putpdf table t2(6,10)=image("`outputpath'/04_TechDocs/spark_BLZ_$S_DATE.png") , colspan(2)
    putpdf table t2(7,10)=image("`outputpath'/04_TechDocs/spark_DMA_$S_DATE.png") , colspan(2)
    putpdf table t2(8,10)=image("`outputpath'/04_TechDocs/spark_GRD_$S_DATE.png") , colspan(2)




** TABLE PAGE 2: COUNTRY SUMMARY METRICS
    putpdf table t2 = (9,11), width(100%) halign(center)    

    putpdf table t2(1,.), font("Calibri Light", 9, 000000) border(all, nil) bgcolor(e6e6e6) valign(middle)
    putpdf table t2(2,.), font("Calibri Light", 11, 000000) border(all, nil) valign(middle)
    putpdf table t2(3,.), font("Calibri Light", 11, 000000) border(all, nil) valign(middle)
    putpdf table t2(4,.), font("Calibri Light", 11, 000000) border(all, nil) valign(middle)
    putpdf table t2(5,.), font("Calibri Light", 11, 000000) border(all, nil) valign(middle)
    putpdf table t2(6,.), font("Calibri Light", 11, 000000) border(all, nil) valign(middle)
    putpdf table t2(7,.), font("Calibri Light", 11, 000000) border(all, nil) valign(middle)
    putpdf table t2(8,.), font("Calibri Light", 11, 000000) border(all, nil) valign(middle)
    putpdf table t2(9,.), font("Calibri Light", 11, 000000) border(all, nil) valign(middle)

    putpdf table t2(.,1), font("Calibri Light", 11, 000000) halign(right)
    putpdf table t2(.,2), font("Calibri Light", 11, 000000) halign(right) 
    putpdf table t2(.,3), font("Calibri Light", 11, 000000) halign(right)
    putpdf table t2(.,4), font("Calibri Light", 12, 0e497c) halign(right)
    putpdf table t2(.,5), font("Calibri Light", 12, 0e497c) halign(right)
    putpdf table t2(.,6), font("Calibri Light", 11, 000000) halign(right)
    putpdf table t2(.,7), font("Calibri Light", 11, 000000) halign(right)
    putpdf table t2(.,8), font("Calibri Light", 12, 7c0a07) halign(right) 
    putpdf table t2(.,9), font("Calibri Light", 12, 7c0a07) halign(right)
    putpdf table t2(.,10), font("Calibri Light", 11, 000000) halign(right)
    putpdf table t2(.,11), font("Calibri Light", 11, 000000) halign(right)

    putpdf table t2(1,1), font("Calibri Light", 10, 000000) bold halign(left)
    putpdf table t2(1,2), font("Calibri Light", 10, 0e497c) bold halign(center)
    putpdf table t2(1,3), font("Calibri Light", 10, 0e497c) bold halign(center)
    putpdf table t2(1,4), font("Calibri Light", 10, 0e497c) bold halign(center)
    putpdf table t2(1,5), font("Calibri Light", 10, 0e497c) bold halign(center)
    putpdf table t2(1,6), font("Calibri Light", 10, 7c0a07) bold halign(center)
    putpdf table t2(1,7), font("Calibri Light", 10, 7c0a07) bold halign(center)
    putpdf table t2(1,8), font("Calibri Light", 10, 7c0a07) bold halign(center)
    putpdf table t2(1,9), font("Calibri Light", 10, 7c0a07) bold halign(center)
    putpdf table t2(1,10), font("Calibri Light", 10, 0e497c) bold halign(center)
    putpdf table t2(1,11), font("Calibri Light", 10, 0e497c) bold halign(center)

    putpdf table t2(1,1)=("Country"),  halign(left) bgcolor(e6e6e6) 
    putpdf table t2(2,1)=("Guyana"), bold halign(left)
    putpdf table t2(3,1)=("Haiti"), bold halign(left)
    putpdf table t2(4,1)=("Jamaica"), bold halign(left)
    putpdf table t2(5,1)=("St.Kitts"), bold halign(left)
    putpdf table t2(6,1)=("St.Lucia"), bold halign(left)
    putpdf table t2(7,1)=("St.Vincent"), bold halign(left)
    putpdf table t2(8,1)=("Suriname"), bold halign(left)
    putpdf table t2(9,1)=("Trinidad"), bold halign(left)

    putpdf table t2(1,2)=("Total cases"),  halign(center) colspan(2) bgcolor(e6e6e6) 
    putpdf table t2(2,2)=image("`outputpath'/04_TechDocs/cases_GUY_$S_DATE.png") , colspan(2)
    putpdf table t2(3,2)=image("`outputpath'/04_TechDocs/cases_HTI_$S_DATE.png") , colspan(2)
    putpdf table t2(4,2)=image("`outputpath'/04_TechDocs/cases_JAM_$S_DATE.png") , colspan(2)
    putpdf table t2(5,2)=image("`outputpath'/04_TechDocs/cases_KNA_$S_DATE.png") , colspan(2)
    putpdf table t2(6,2)=image("`outputpath'/04_TechDocs/cases_LCA_$S_DATE.png") , colspan(2)
    putpdf table t2(7,2)=image("`outputpath'/04_TechDocs/cases_VCT_$S_DATE.png") , colspan(2)
    putpdf table t2(8,2)=image("`outputpath'/04_TechDocs/cases_SUR_$S_DATE.png") , colspan(2)
    putpdf table t2(9,2)=image("`outputpath'/04_TechDocs/cases_TTO_$S_DATE.png") , colspan(2)

    putpdf table t2(1,4)=("Cases in past week"),  halign(center) bgcolor(e6e6e6) 
    putpdf table t2(2,4)=(${m62_GUY}), halign(center) 
    putpdf table t2(3,4)=(${m62_HTI}), halign(center) 
    putpdf table t2(4,4)=(${m62_JAM}), halign(center) 
    putpdf table t2(5,4)=(${m62_KNA}), halign(center) 
    putpdf table t2(6,4)=(${m62_LCA}), halign(center) 
    putpdf table t2(7,4)=(${m62_VCT}), halign(center) 
    putpdf table t2(8,4)=(${m62_SUR}), halign(center) 
    putpdf table t2(9,4)=(${m62_TTO}), halign(center) 

    putpdf table t2(1,5)=("Days since 1st case"),  halign(center)  bgcolor(e6e6e6) 
    putpdf table t2(2,5)=(${m05_GUY}), halign(center) 
    putpdf table t2(3,5)=(${m05_HTI}), halign(center) 
    putpdf table t2(4,5)=(${m05_JAM}), halign(center) 
    putpdf table t2(5,5)=(${m05_KNA}), halign(center) 
    putpdf table t2(6,5)=(${m05_LCA}), halign(center) 
    putpdf table t2(7,5)=(${m05_VCT}), halign(center) 
    putpdf table t2(8,5)=(${m05_SUR}), halign(center) 
    putpdf table t2(9,5)=(${m05_TTO}), halign(center) 

    putpdf table t2(1,6)=("Total deaths"),  halign(center) colspan(2) bgcolor(e6e6e6) 
    putpdf table t2(2,6)=image("`outputpath'/04_TechDocs/deaths_GUY_$S_DATE.png") , colspan(2)
    putpdf table t2(3,6)=image("`outputpath'/04_TechDocs/deaths_HTI_$S_DATE.png") , colspan(2)
    putpdf table t2(4,6)=image("`outputpath'/04_TechDocs/deaths_JAM_$S_DATE.png") , colspan(2)
    putpdf table t2(5,6)=image("`outputpath'/04_TechDocs/deaths_KNA_$S_DATE.png") , colspan(2)
    putpdf table t2(6,6)=image("`outputpath'/04_TechDocs/deaths_LCA_$S_DATE.png") , colspan(2)
    putpdf table t2(7,6)=image("`outputpath'/04_TechDocs/deaths_VCT_$S_DATE.png") , colspan(2)
    putpdf table t2(8,6)=image("`outputpath'/04_TechDocs/deaths_SUR_$S_DATE.png") , colspan(2)
    putpdf table t2(9,6)=image("`outputpath'/04_TechDocs/deaths_TTO_$S_DATE.png") , colspan(2)

    putpdf table t2(1,8)=("Deaths in past week"),  halign(center)  bgcolor(e6e6e6) 
    putpdf table t2(2,8)=(${m63_GUY}), halign(center) 
    putpdf table t2(3,8)=(${m63_HTI}), halign(center) 
    putpdf table t2(4,8)=(${m63_JAM}), halign(center) 
    putpdf table t2(5,8)=(${m63_KNA}), halign(center) 
    putpdf table t2(6,8)=(${m63_LCA}), halign(center) 
    putpdf table t2(7,8)=(${m63_VCT}), halign(center) 
    putpdf table t2(8,8)=(${m63_SUR}), halign(center) 
    putpdf table t2(9,8)=(${m63_TTO}), halign(center) 

    putpdf table t2(1,9)=("Days since 1st death"),  halign(center)  bgcolor(e6e6e6) 
    putpdf table t2(2,9)=(${m06_GUY}), halign(center) 
    putpdf table t2(3,9)=(${m06_HTI}), halign(center) 
    putpdf table t2(4,9)=(${m06_JAM}), halign(center) 
    putpdf table t2(5,9)=(${m06_KNA}), halign(center) 
    putpdf table t2(6,9)=(${m06_LCA}), halign(center) 
    putpdf table t2(7,9)=(${m06_VCT}), halign(center) 
    putpdf table t2(8,9)=(${m06_SUR}), halign(center) 
    putpdf table t2(9,9)=(${m06_TTO}), halign(center) 

    putpdf table t2(1,10)=("CARICOM growth rates among cases"),  halign(center) colspan(2) bgcolor(e6e6e6) 
    putpdf table t2(2,10)=image("`outputpath'/04_TechDocs/spark_GUY_$S_DATE.png") , colspan(2)
    putpdf table t2(3,10)=image("`outputpath'/04_TechDocs/spark_HTI_$S_DATE.png") , colspan(2)
    putpdf table t2(4,10)=image("`outputpath'/04_TechDocs/spark_JAM_$S_DATE.png") , colspan(2)
    putpdf table t2(5,10)=image("`outputpath'/04_TechDocs/spark_KNA_$S_DATE.png") , colspan(2)
    putpdf table t2(6,10)=image("`outputpath'/04_TechDocs/spark_LCA_$S_DATE.png") , colspan(2)
    putpdf table t2(7,10)=image("`outputpath'/04_TechDocs/spark_VCT_$S_DATE.png") , colspan(2)
    putpdf table t2(8,10)=image("`outputpath'/04_TechDocs/spark_SUR_$S_DATE.png") , colspan(2)
    putpdf table t2(9,10)=image("`outputpath'/04_TechDocs/spark_TTO_$S_DATE.png") , colspan(2)



** FOOTNOTE 1. DATA REFERENCE
** FOOTNOTE 2. CARICOM COUNTRIES
** FOOTNOTE 3. GROWTH RATE
    putpdf table p3 = (3,1), width(100%) halign(center) 
    putpdf table p3(.,1), font("Calibri Light", 8) border(all,nil) bgcolor(ffffff)
    putpdf table p3(1,1)=("(NOTE 1) Data Source. "), bold halign(left)
    putpdf table p3(1,1)=("Dong E, Du H, Gardner L. An interactive web-based dashboard to track COVID-19 "), append 
    putpdf table p3(1,1)=("in real time. Lancet Infect Dis; published online Feb 19. https://doi.org/10.1016/S1473-3099(20)30120-1"), append
    putpdf table p3(2,1)=("(NOTE 2) CARICOM member states reported in this briefing.  "), bold halign(left)
    putpdf table p3(2,1)=("Antigua and Barbuda, The Bahamas, Barbados, Belize, Dominica, Grenada, Guyana, Haiti, Jamaica, "), append 
    putpdf table p3(2,1)=("St. Kitts and Nevis, St. Lucia, St. Vincent and the Grenadines, Suriname, Trinidad and Tobago."), append
    putpdf table p3(3,1)=("(NOTE 3) Growth Rate.  "), bold halign(left)
    putpdf table p3(3,1)=("The blue graph in the final column shows the number of cases on a different scale (called a logarithm scale). "), append 
    putpdf table p3(3,1)=("This gives us the growth rate over time, and is good for comparing progress against other countries. "), append
    putpdf table p3(3,1)=("The shaded region behind the country growth curve is the range of outbreak growth for the remaining 13 CARICOM member states. "), append
    putpdf table p3(3,1)=("This range is represented by percentiles (darker blue region represents 25th to 75th percentile, lighter blue "), append
    putpdf table p3(3,1)=("region represents 5th to 95th percntiles). all curves and regions are 7-day smoothed averages."), append

** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    putpdf save "`outputpath'/05_Outputs/covid19_trajectory_regional_version2_`date_string'", replace
