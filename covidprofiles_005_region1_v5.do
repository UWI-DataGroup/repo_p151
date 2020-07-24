** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					covidprofiles_005_region1_v5.do
    //  project:				        
    //  analysts:				       	Ian HAMBLETON
    // 	date last modified	            21-JUL-2020
    //  algorithm task			        Single summary PDF of CARICOM region, by country

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
    ** ! This contains a local Windows-specific location 
    ** ! Would need changing for auto saving of PDF to online sync folder
    local outputpath "X:\The University of the West Indies\DataGroup - DG_Projects\PROJECT_p151"
    ** local parent "C:\Users\Ian Hambleton\Sync\Link_folders\COVID19 Surveillance Updates\02 regional_summaries"
    local parent "X:\The University of the West Indies\CaribData - Documents\COVID19Surveillance\PDF_Briefings\02 regional_summaries"
    cap mkdir "`parent'\\`today'
    local syncpath "X:\The University of the West Indies\CaribData - Documents\COVID19Surveillance\PDF_Briefings\02 regional_summaries\\`today'"


    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\covidprofiles_005_region1_v5", replace
** HEADER -----------------------------------------------------

** -----------------------------------------
** Pre-Load the COVID metrics --> as Global Macros
** -----------------------------------------
qui do "`logpath'\covidprofiles_003_metrics_v5"
** -----------------------------------------

** Close any open log file and open a new log file
capture log close
log using "`logpath'\covidprofiles_005_region1_v5", replace

** Labelling of the internal country numeric
#delimit ; 
label define cname_ 1 "Anguilla" 
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
                    15 "Saint Kitts and Nevis"
                    16 "Saint Lucia"
                    17 "Saint Vincent and the Grenadines"
                    18 "Suriname"
                    19 "Trinidad and Tobago"
                    20 "Turks and Caicos"
                    21 "Iceland"
                    22 "New Zealand"
                    23 "Singapore"
                    24 "South Korea"
                    25 "United Kingdom"
                    26 "United States"
                    27 "Cuba"
                    28 "Dominican Republic"
                    ;
#delimit cr 

** Attack Rate (per 1,000 --> not yet used)
gen cases_rate = (total_cases / pop) * 10000

** SMOOTHED CASES for graphic
bysort iso: asrol total_cases , stat(mean) window(date 3) gen(cases_av3)
bysort iso: asrol total_deaths , stat(mean) window(date 3) gen(deaths_av3)


** REGIONAL VALUES
rename total_cases  metric1
rename cases_rate metric2
rename total_deaths metric3

reshape long metric, i(iso_num iso date) j(mtype)
label define mtype_ 1 "cases" 2 "attack rate" 3 "deaths" 
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
                        iso=="ISL" | iso=="NZL"
gen ukot6 = 0 
replace ukot6 =1 if iso=="AIA" | iso=="BMU" | iso=="VGB" | iso=="CYM" | iso=="MSR" | iso=="TCA"

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
    gen elapsedc = _n - 1
    egen m05 = max(elapsedc)
    global m05 = m05 
restore 
** METRIC 06: Days since first reported death
preserve 
    keep if touse==1 & mtype==3 & metric>0
    collapse (sum) metric, by(date)
    gen elapsedd = _n - 1
    egen m06 = max(elapsedd)
    global m06 = m06 
restore

** UKOTS (x6)
** METRIC 03 
** DATE OF FIRST CONFIRMED CASE
preserve 
    keep if ukot6==1 & mtype==1 & metric>0 
    egen m03ukot = min(date) 
    format m03ukot %td 
    global m03ukot : disp %tdDD_Month m03
restore
** METRIC 04 
** The DATE OF FIRST CONFIRMED DEATH
preserve 
    keep if ukot6==1 & mtype==3 & metric>0 
    egen m04ukot = min(date) 
    format m04ukot %td 
    global m04ukot : disp %tdDD_Month m04
restore
** METRIC 05: Days since first reported case
preserve 
    keep if ukot6==1 & mtype==1 & metric>0
    collapse (sum) metric, by(date)
    gen elapsedcukot = _n -1
    egen m05ukot = max(elapsedc)
    global m05ukot = m05 
restore 
** METRIC 06: Days since first reported death
preserve 
    keep if ukot6==1 & mtype==3 & metric>0
    collapse (sum) metric, by(date)
    gen elapseddukot = _n -1
    egen m06ukot = max(elapsedd)
    global m06ukot = m06 
restore



** LOOP through N=20 CARICOM member states and 6 UKOTS
* The CAPTURE command means that if a country does not exist
** The code will continue - and the error will be captured in the (_rc) local macro 
local clist "AIA ATG BHS BRB BLZ BMU VGB CYM DMA GRD GUY HTI JAM MSR KNA LCA VCT SUR TTO TCA"
capture {
    foreach country of local clist {
    ** This code chunk creates COUNTRY ISO CODE and COUNTRY NAME
    ** for automated use in the PDF reports.
    **      country  = 3-character ISO name
    **      cname    = FULL country name
    **      -country- used in all loop structures
    **      -cname- used for visual display of full country name on PDF
        gen c3 = iso_num if iso=="`country'"
        label values c3 cname_
        egen c4 = min(c3)
        label values c4 cname_
        decode c4, gen(c5)
        local cname = c5
        drop c3 c4 c5

        ** Position of COUNT on cases x and y-axis
        ** The divisor puts the number at a proportion of the way across the graphic 
        global cposx_`country' = ${m05_`country'}/4
        global cposy_`country' = ${m01_`country'}/1.5
        ** Position of COUNT on deaths x-axis
        global dposx_`country' = ${m06_`country'}/4
        global dposy_`country' = ${m02_`country'}/1.5

** 1. BAR CHART    --> CUMULATIVE CASES
        #delimit ;
        gr twoway 
            (bar metric elapsed if iso=="`country'" & elapsed<=${m05_`country'} & mtype==1, col("181 215 244"))
            (line cases_av3 elapsed if iso=="`country'" & elapsed<=${m05_`country'} & mtype==1, lc("14 73 124") lw(0.4) lp("-"))
            (scat cases_av3 elapsed if iso=="`country'" & elapsed<=${m05_`country'} & mtype==1, msize(1.5) mc("14 73 124") m(o)
            )
            ,
            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(2.5) xsize(5)
            
            xlab(0(1)${m05_`country'}
            , labs(6) nogrid glc(gs16) angle(0) format(%9.0f))
            xtitle("Days since first case", size(6) margin(l=2 r=2 t=2 b=2)) 
            ///xscale(off range(1(2)${m05_`country'})) 
            xscale(off) 

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
            ///xscale(off range(0(1)${m05_`country'})) 
            xscale(off) 

            ylab(0(1)${m02_`country'}
            , labs(6) notick nogrid glc(gs16) angle(0))
            yscale(off range(0(2)${m02_`country'})) 
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
    gen out = 0
    replace out = 1 if iso=="`country'"

    ** These percentile summaries allow us to create bands of color
    ** relating to regional distribution of confirmed cases (as percentiles)
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

    ** Elapsed days since first case / death
    bysort out mtype: gen elapsed = _n

    ** SMOOTHED CASES distribution percentiles for graphic
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
}
** Any error code due to a missing country is shifted to a global macros (errortrap)
** If no error, then _rc==0
** If an error exists, _rc>0 
** This was introduced on 18-Jun-2020 in response to missing TCA data 
global errortrap = _rc 

** ------------------------------------------------------
** PDF REGIONAL REPORT (COUNTS OF CONFIRMED CASES)
** ------------------------------------------------------
    putpdf begin, pagesize(letter) font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.25cm) margin(left,0.5cm) margin(right,0.25cm)

** REPORT PAGE 1 - TITLE, ATTRIBUTION, DATE of CREATION
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
    putpdf table intro(1,2)=("www.uwi.edu/covid19/surveillance "), halign(left) underline append linebreak 
    putpdf table intro(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

** REPORT PAGE 1 - INTRODUCTORY TEXT
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

** REPORT PAGE 1 - TABLE: REGIONAL SUMMARY METRICS
    putpdf table t1 = (5,6), width(100%) halign(center) 
    putpdf table t1(1,1), font("Calibri Light", 10, 000000) colspan(6) border(all, nil) 
    putpdf table t1(2,1), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,1), font("Calibri Light", 12, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,1), font("Calibri Light", 12, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,1), font("Calibri Light", 12, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,2), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,2), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(4,2), font("Calibri Light", 11, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,2), font("Calibri Light", 11, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,3), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,3), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,3), font("Calibri Light", 11, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,3), font("Calibri Light", 11, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,4), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,4), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,4), font("Calibri Light", 11, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,4), font("Calibri Light", 11, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,5), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,5), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,5), font("Calibri Light", 11, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,5), font("Calibri Light", 11, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t1(2,6), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,6), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(4,6), font("Calibri Light", 11, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t1(5,6), font("Calibri Light", 11, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 

    putpdf table t1(1,1)=("Summary for 14 CARICOM countries"), colspan(6) halign(left) 
    putpdf table t1(2,2)=("Total"), halign(center) 
    putpdf table t1(2,3)=("New"), halign(center) 
    putpdf table t1(3,3)=("(1 day)"), halign(center) 
    putpdf table t1(2,4)=("New"), halign(center) 
    putpdf table t1(3,4)=("(1 week)"), halign(center) 
    putpdf table t1(2,5)=("Date of"), halign(center) 
    putpdf table t1(3,5)=("1st confirmed"), halign(center) 
    putpdf table t1(2,6)=("Days since"), halign(center) 
    putpdf table t1(3,6)=("1st confirmed"), halign(center)

    putpdf table t1(2,1)=("Confirmed"), halign(center) 
    putpdf table t1(3,1)=("Events"), halign(center) 
    putpdf table t1(4,1)=("Cases"), halign(center) 
    putpdf table t1(5,1)=("Deaths"), halign(center)  

    putpdf table t1(4,2)=("${m01}"), halign(center) 
    putpdf table t1(5,2)=("${m02}"), halign(center) 
    putpdf table t1(4,3)=("${m60}"), halign(center) 
    putpdf table t1(5,3)=("${m61}"), halign(center) 
    putpdf table t1(4,4)=("${m62}"), halign(center) 
    putpdf table t1(5,4)=("${m63}"), halign(center) 
    putpdf table t1(4,5)=("${m03}"), halign(center) 
    putpdf table t1(5,5)=("${m04}"), halign(center) 
    putpdf table t1(4,6)=("${m05}"), halign(center) 
    putpdf table t1(5,6)=("${m06}"), halign(center) 



** REPORT PAGE 1 - TABLE: COUNTRY SUMMARY METRICS
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
    putpdf table t2(1,1)=("The shaded region represents the range of rates in the remaining countries and territories "),  halign(left) append 
    putpdf table t2(1,1)=("(see note 3)"), bold append
    putpdf table t2(1,1)=("."),  halign(left) append linebreak
    putpdf table t2(1,1)=(" "),  halign(left) append 

    putpdf table t2(2,1)=("Country"),  halign(left) bgcolor(e6e6e6) 
    putpdf table t2(3,1)=("Antigua"), bold halign(left)
    putpdf table t2(4,1)=("Bahamas"), bold halign(left)
    putpdf table t2(5,1)=("Barbados"), bold halign(left)
    putpdf table t2(6,1)=("Belize"), bold halign(left)
    putpdf table t2(7,1)=("Dominica"), bold halign(left)

    putpdf table t2(2,2)=("Total cases"),  halign(center) colspan(2) bgcolor(e6e6e6) 
    putpdf table t2(3,2)=image("`outputpath'/04_TechDocs/cases_ATG_$S_DATE.png") , colspan(2)
    putpdf table t2(4,2)=image("`outputpath'/04_TechDocs/cases_BHS_$S_DATE.png") , colspan(2)
    putpdf table t2(5,2)=image("`outputpath'/04_TechDocs/cases_BRB_$S_DATE.png") , colspan(2)
    putpdf table t2(6,2)=image("`outputpath'/04_TechDocs/cases_BLZ_$S_DATE.png") , colspan(2)
    putpdf table t2(7,2)=image("`outputpath'/04_TechDocs/cases_DMA_$S_DATE.png") , colspan(2)

    putpdf table t2(2,4)=("Cases in past week"),  halign(center) bgcolor(e6e6e6) 
    putpdf table t2(3,4)=(${m62_ATG}), halign(center) 
    putpdf table t2(4,4)=(${m62_BHS}), halign(center) 
    putpdf table t2(5,4)=(${m62_BRB}), halign(center) 
    putpdf table t2(6,4)=(${m62_BLZ}), halign(center) 
    putpdf table t2(7,4)=(${m62_DMA}), halign(center) 

    putpdf table t2(2,5)=("Days since 1st case"),  halign(center)  bgcolor(e6e6e6) 
    putpdf table t2(3,5)=(${m05_ATG}), halign(center) 
    putpdf table t2(4,5)=(${m05_BHS}), halign(center) 
    putpdf table t2(5,5)=(${m05_BRB}), halign(center) 
    putpdf table t2(6,5)=(${m05_BLZ}), halign(center) 
    putpdf table t2(7,5)=(${m05_DMA}), halign(center) 

    putpdf table t2(2,6)=("Total deaths"),  halign(center) colspan(2) bgcolor(e6e6e6) 
    putpdf table t2(3,6)=image("`outputpath'/04_TechDocs/deaths_ATG_$S_DATE.png") , colspan(2) 
    putpdf table t2(4,6)=image("`outputpath'/04_TechDocs/deaths_BHS_$S_DATE.png") , colspan(2) 
    putpdf table t2(5,6)=image("`outputpath'/04_TechDocs/deaths_BRB_$S_DATE.png") , colspan(2) 
    putpdf table t2(6,6)=image("`outputpath'/04_TechDocs/deaths_BLZ_$S_DATE.png") , colspan(2)
    putpdf table t2(7,6)=image("`outputpath'/04_TechDocs/deaths_DMA_$S_DATE.png") , colspan(2)

    putpdf table t2(2,8)=("Deaths in past week"),  halign(center)  bgcolor(e6e6e6) 
    putpdf table t2(3,8)=(${m63_ATG}), halign(center) 
    putpdf table t2(4,8)=(${m63_BHS}), halign(center) 
    putpdf table t2(5,8)=(${m63_BRB}), halign(center) 
    putpdf table t2(6,8)=(${m63_BLZ}), halign(center) 
    putpdf table t2(7,8)=(${m63_DMA}), halign(center) 

    putpdf table t2(2,9)=("Days since 1st death"),  halign(center)  bgcolor(e6e6e6) 
    putpdf table t2(3,9)=(${m06_ATG}), halign(center) 
    putpdf table t2(4,9)=(${m06_BHS}), halign(center) 
    putpdf table t2(5,9)=(${m06_BRB}), halign(center) 
    putpdf table t2(6,9)=(${m06_BLZ}), halign(center) 
    putpdf table t2(7,9)=(${m06_DMA}), halign(center) 

    putpdf table t2(2,10)=("CARICOM growth rates among cases"),  halign(center) colspan(2) bgcolor(e6e6e6) 
    putpdf table t2(3,10)=image("`outputpath'/04_TechDocs/spark_ATG_$S_DATE.png") , colspan(2)
    putpdf table t2(4,10)=image("`outputpath'/04_TechDocs/spark_BHS_$S_DATE.png") , colspan(2)
    putpdf table t2(5,10)=image("`outputpath'/04_TechDocs/spark_BRB_$S_DATE.png") , colspan(2)
    putpdf table t2(6,10)=image("`outputpath'/04_TechDocs/spark_BLZ_$S_DATE.png") , colspan(2)
    putpdf table t2(7,10)=image("`outputpath'/04_TechDocs/spark_DMA_$S_DATE.png") , colspan(2)




** REPORT PAGE 2 - TABLE: COUNTRY SUMMARY METRICS
    putpdf pagebreak 
    putpdf table t3 = (10,11), width(100%) halign(center)    

    putpdf table t3(1,.), font("Calibri Light", 9, 000000) border(all, nil) bgcolor(e6e6e6) valign(middle)
    putpdf table t3(2,.), font("Calibri Light", 9, 000000) border(all, nil) valign(middle)
    putpdf table t3(3,.), font("Calibri Light", 11, 000000) border(all, nil) valign(middle)
    putpdf table t3(4,.), font("Calibri Light", 11, 000000) border(all, nil) valign(middle)
    putpdf table t3(5,.), font("Calibri Light", 11, 000000) border(all, nil) valign(middle)
    putpdf table t3(6,.), font("Calibri Light", 11, 000000) border(all, nil) valign(middle)
    putpdf table t3(7,.), font("Calibri Light", 11, 000000) border(all, nil) valign(middle)
    putpdf table t3(8,.), font("Calibri Light", 11, 000000) border(all, nil) valign(middle)
    putpdf table t3(9,.), font("Calibri Light", 11, 000000) border(all, nil) valign(middle)
    putpdf table t3(10,.), font("Calibri Light", 11, 000000) border(all, nil) valign(middle)

    putpdf table t3(.,1), font("Calibri Light", 11, 000000) halign(right)
    putpdf table t3(.,2), font("Calibri Light", 11, 000000) halign(right) 
    putpdf table t3(.,3), font("Calibri Light", 11, 000000) halign(right)
    putpdf table t3(.,4), font("Calibri Light", 12, 0e497c) halign(right)
    putpdf table t3(.,5), font("Calibri Light", 12, 0e497c) halign(right)
    putpdf table t3(.,6), font("Calibri Light", 11, 000000) halign(right)
    putpdf table t3(.,7), font("Calibri Light", 11, 000000) halign(right)
    putpdf table t3(.,8), font("Calibri Light", 12, 7c0a07) halign(right) 
    putpdf table t3(.,9), font("Calibri Light", 12, 7c0a07) halign(right)
    putpdf table t3(.,10), font("Calibri Light", 11, 000000) halign(right)
    putpdf table t3(.,11), font("Calibri Light", 11, 000000) halign(right)

    putpdf table t3(1,1), font("Calibri Light", 10, 000000) bold halign(left)
    putpdf table t3(1,2), font("Calibri Light", 10, 0e497c) bold halign(center)
    putpdf table t3(1,3), font("Calibri Light", 10, 0e497c) bold halign(center)
    putpdf table t3(1,4), font("Calibri Light", 10, 0e497c) bold halign(center)
    putpdf table t3(1,5), font("Calibri Light", 10, 0e497c) bold halign(center)
    putpdf table t3(1,6), font("Calibri Light", 10, 7c0a07) bold halign(center)
    putpdf table t3(1,7), font("Calibri Light", 10, 7c0a07) bold halign(center)
    putpdf table t3(1,8), font("Calibri Light", 10, 7c0a07) bold halign(center)
    putpdf table t3(1,9), font("Calibri Light", 10, 7c0a07) bold halign(center)
    putpdf table t3(1,10), font("Calibri Light", 10, 0e497c) bold halign(center)
    putpdf table t3(1,11), font("Calibri Light", 10, 0e497c) bold halign(center)

    putpdf table t3(1,1)=("Country"),  halign(left) bgcolor(e6e6e6) 
    putpdf table t3(2,1)=("Grenada"), bold halign(left)
    putpdf table t3(3,1)=("Guyana"), bold halign(left)
    putpdf table t3(4,1)=("Haiti"), bold halign(left)
    putpdf table t3(5,1)=("Jamaica"), bold halign(left)
    putpdf table t3(6,1)=("St.Kitts"), bold halign(left)
    putpdf table t3(7,1)=("St.Lucia"), bold halign(left)
    putpdf table t3(8,1)=("St.Vincent"), bold halign(left)
    putpdf table t3(9,1)=("Suriname"), bold halign(left)
    putpdf table t3(10,1)=("Trinidad"), bold halign(left)

    putpdf table t3(1,2)=("Total cases"),  halign(center) colspan(2) bgcolor(e6e6e6) 
    putpdf table t3(2,2)=image("`outputpath'/04_TechDocs/cases_GRD_$S_DATE.png") , colspan(2)
    putpdf table t3(3,2)=image("`outputpath'/04_TechDocs/cases_GUY_$S_DATE.png") , colspan(2)
    putpdf table t3(4,2)=image("`outputpath'/04_TechDocs/cases_HTI_$S_DATE.png") , colspan(2)
    putpdf table t3(5,2)=image("`outputpath'/04_TechDocs/cases_JAM_$S_DATE.png") , colspan(2)
    putpdf table t3(6,2)=image("`outputpath'/04_TechDocs/cases_KNA_$S_DATE.png") , colspan(2)
    putpdf table t3(7,2)=image("`outputpath'/04_TechDocs/cases_LCA_$S_DATE.png") , colspan(2)
    putpdf table t3(8,2)=image("`outputpath'/04_TechDocs/cases_VCT_$S_DATE.png") , colspan(2)
    putpdf table t3(9,2)=image("`outputpath'/04_TechDocs/cases_SUR_$S_DATE.png") , colspan(2)
    putpdf table t3(10,2)=image("`outputpath'/04_TechDocs/cases_TTO_$S_DATE.png") , colspan(2)

    putpdf table t3(1,4)=("Cases in past week"),  halign(center) bgcolor(e6e6e6) 
    putpdf table t3(2,4)=(${m62_GRD}), halign(center) 
    putpdf table t3(3,4)=(${m62_GUY}), halign(center) 
    putpdf table t3(4,4)=(${m62_HTI}), halign(center) 
    putpdf table t3(5,4)=(${m62_JAM}), halign(center) 
    putpdf table t3(6,4)=(${m62_KNA}), halign(center) 
    putpdf table t3(7,4)=(${m62_LCA}), halign(center) 
    putpdf table t3(8,4)=(${m62_VCT}), halign(center) 
    putpdf table t3(9,4)=(${m62_SUR}), halign(center) 
    putpdf table t3(10,4)=(${m62_TTO}), halign(center) 

    putpdf table t3(1,5)=("Days since 1st case"),  halign(center)  bgcolor(e6e6e6) 
    putpdf table t3(2,5)=(${m05_GRD}), halign(center) 
    putpdf table t3(3,5)=(${m05_GUY}), halign(center) 
    putpdf table t3(4,5)=(${m05_HTI}), halign(center) 
    putpdf table t3(5,5)=(${m05_JAM}), halign(center) 
    putpdf table t3(6,5)=(${m05_KNA}), halign(center) 
    putpdf table t3(7,5)=(${m05_LCA}), halign(center) 
    putpdf table t3(8,5)=(${m05_VCT}), halign(center) 
    putpdf table t3(9,5)=(${m05_SUR}), halign(center) 
    putpdf table t3(10,5)=(${m05_TTO}), halign(center) 

    putpdf table t3(1,6)=("Total deaths"),  halign(center) colspan(2) bgcolor(e6e6e6) 
    putpdf table t3(2,6)=image("`outputpath'/04_TechDocs/deaths_GRD_$S_DATE.png") , colspan(2)
    putpdf table t3(3,6)=image("`outputpath'/04_TechDocs/deaths_GUY_$S_DATE.png") , colspan(2)
    putpdf table t3(4,6)=image("`outputpath'/04_TechDocs/deaths_HTI_$S_DATE.png") , colspan(2)
    putpdf table t3(5,6)=image("`outputpath'/04_TechDocs/deaths_JAM_$S_DATE.png") , colspan(2)
    putpdf table t3(6,6)=image("`outputpath'/04_TechDocs/deaths_KNA_$S_DATE.png") , colspan(2)
    putpdf table t3(7,6)=image("`outputpath'/04_TechDocs/deaths_LCA_$S_DATE.png") , colspan(2)
    putpdf table t3(8,6)=image("`outputpath'/04_TechDocs/deaths_VCT_$S_DATE.png") , colspan(2)
    putpdf table t3(9,6)=image("`outputpath'/04_TechDocs/deaths_SUR_$S_DATE.png") , colspan(2)
    putpdf table t3(10,6)=image("`outputpath'/04_TechDocs/deaths_TTO_$S_DATE.png") , colspan(2)

    putpdf table t3(1,8)=("Deaths in past week"),  halign(center)  bgcolor(e6e6e6) 
    putpdf table t3(2,8)=(${m63_GRD}), halign(center) 
    putpdf table t3(3,8)=(${m63_GUY}), halign(center) 
    putpdf table t3(4,8)=(${m63_HTI}), halign(center) 
    putpdf table t3(5,8)=(${m63_JAM}), halign(center) 
    putpdf table t3(6,8)=(${m63_KNA}), halign(center) 
    putpdf table t3(7,8)=(${m63_LCA}), halign(center) 
    putpdf table t3(8,8)=(${m63_VCT}), halign(center) 
    putpdf table t3(9,8)=(${m63_SUR}), halign(center) 
    putpdf table t3(10,8)=(${m63_TTO}), halign(center) 

    putpdf table t3(1,9)=("Days since 1st death"),  halign(center)  bgcolor(e6e6e6) 
    putpdf table t3(2,9)=(${m06_GRD}), halign(center) 
    putpdf table t3(3,9)=(${m06_GUY}), halign(center) 
    putpdf table t3(4,9)=(${m06_HTI}), halign(center) 
    putpdf table t3(5,9)=(${m06_JAM}), halign(center) 
    putpdf table t3(6,9)=(${m06_KNA}), halign(center) 
    putpdf table t3(7,9)=(${m06_LCA}), halign(center) 
    putpdf table t3(8,9)=(${m06_VCT}), halign(center) 
    putpdf table t3(9,9)=(${m06_SUR}), halign(center) 
    putpdf table t3(10,9)=(${m06_TTO}), halign(center) 

    putpdf table t3(1,10)=("CARICOM growth rates among cases"),  halign(center) colspan(2) bgcolor(e6e6e6) 
    putpdf table t3(2,10)=image("`outputpath'/04_TechDocs/spark_GRD_$S_DATE.png") , colspan(2)
    putpdf table t3(3,10)=image("`outputpath'/04_TechDocs/spark_GUY_$S_DATE.png") , colspan(2)
    putpdf table t3(4,10)=image("`outputpath'/04_TechDocs/spark_HTI_$S_DATE.png") , colspan(2)
    putpdf table t3(5,10)=image("`outputpath'/04_TechDocs/spark_JAM_$S_DATE.png") , colspan(2)
    putpdf table t3(6,10)=image("`outputpath'/04_TechDocs/spark_KNA_$S_DATE.png") , colspan(2)
    putpdf table t3(7,10)=image("`outputpath'/04_TechDocs/spark_LCA_$S_DATE.png") , colspan(2)
    putpdf table t3(8,10)=image("`outputpath'/04_TechDocs/spark_VCT_$S_DATE.png") , colspan(2)
    putpdf table t3(9,10)=image("`outputpath'/04_TechDocs/spark_SUR_$S_DATE.png") , colspan(2)
    putpdf table t3(10,10)=image("`outputpath'/04_TechDocs/spark_TTO_$S_DATE.png") , colspan(2)



** REPORT PAGE 3 - THE UKOTS
    putpdf pagebreak 

** REPORT PAGE 3 - TITLE, ATTRIBUTION, DATE of CREATION
    putpdf table intro2 = (1,12), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil)
    putpdf table intro2(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(11)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 trajectories for 6 United Kingdom Overseas Territories (UKOTS)"), halign(left) linebreak font("Calibri Light", 12, 000000)
    putpdf table intro2(1,2)=("Briefing created by staff of the George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro2(1,2)=("and the Public Health Group of The Faculty of Medical Sciences, Cave Hill Campus, "), halign(left) append  
    putpdf table intro2(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro2(1,2)=("Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro2(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic   
    putpdf table intro2(1,2)=("For all our COVID-19 surveillance outputs, go to "), halign(left) append
    putpdf table intro2(1,2)=("www.uwi.edu/covid19/surveillance "), halign(left) underline append linebreak 
    putpdf table intro2(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

** REPORT PAGE 3 - INTRODUCTORY TEXT
    putpdf paragraph ,  font("Calibri Light", 9)
    putpdf text ("Aim of this briefing. ") , bold
    putpdf text ("We present the cumulative number of confirmed cases and deaths ")
    putpdf text ("(see note 1)"), bold 
    putpdf text (" from COVID-19 infection among the Caribbean UKOTS since the start of the outbreak (we define the outbreak length as ") 
    putpdf text ("the number of days since the first confirmed case in each country). ") 
    putpdf text ("In our first table, we summarise the situation among the UKOTS ") 
    putpdf text ("(see note 2)"), bold
    putpdf text (" as of $S_DATE.") 
    putpdf text (" We then summarise the situation each each country visually, describing cumulative cases, cumulative deaths, ") 
    putpdf text (" and outbreak growth rates."), linebreak 

** REPORT PAGE 3 - TABLE: REGIONAL SUMMARY METRICS
    putpdf table t4 = (5,6), width(100%) halign(center)
    putpdf table t4(1,1), font("Calibri Light", 10, 000000) colspan(6) border(all, nil) 
    putpdf table t4(2,1), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t4(3,1), font("Calibri Light", 12, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t4(4,1), font("Calibri Light", 12, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t4(5,1), font("Calibri Light", 12, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t4(2,2), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t4(3,2), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t4(4,2), font("Calibri Light", 11, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t4(5,2), font("Calibri Light", 11, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t4(2,3), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t4(3,3), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t4(4,3), font("Calibri Light", 11, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t4(5,3), font("Calibri Light", 11, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t4(2,4), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t4(3,4), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t4(4,4), font("Calibri Light", 11, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t4(5,4), font("Calibri Light", 11, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t4(2,5), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t4(3,5), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t4(4,5), font("Calibri Light", 11, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t4(5,5), font("Calibri Light", 11, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 
    putpdf table t4(2,6), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t4(3,6), font("Calibri Light", 11, 000000) border(left,single,ffffff) border(right,single,ffffff) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t4(4,6), font("Calibri Light", 11, 0e497c) border(all,single,ffffff) bgcolor(b5d7f4) 
    putpdf table t4(5,6), font("Calibri Light", 11, 7c0a07) border(all,single,ffffff) bgcolor(ff9e83) 

    putpdf table t4(1,1)=("Summary for six United Kingdom Overseas Territies (UKOTS)"), colspan(6) halign(left) 
    putpdf table t4(2,2)=("Total"), halign(center) 
    putpdf table t4(2,3)=("New"), halign(center) 
    putpdf table t4(3,3)=("(1 day)"), halign(center) 
    putpdf table t4(2,4)=("New"), halign(center) 
    putpdf table t4(3,4)=("(1 week)"), halign(center) 
    putpdf table t4(2,5)=("Date of"), halign(center) 
    putpdf table t4(3,5)=("1st confirmed"), halign(center) 
    putpdf table t4(2,6)=("Days since"), halign(center) 
    putpdf table t4(3,6)=("1st confirmed"), halign(center) 
    putpdf table t4(2,1)=("Confirmed"), halign(center) 
    putpdf table t4(3,1)=("Events"), halign(center) 
    putpdf table t4(4,1)=("Cases"), halign(center) 
    putpdf table t4(5,1)=("Deaths"), halign(center)  

    putpdf table t4(4,2)=("${m01ukot}"), halign(center) 
    putpdf table t4(5,2)=("${m02ukot}"), halign(center) 
    putpdf table t4(4,3)=("${m60ukot}"), halign(center) 
    putpdf table t4(5,3)=("${m61ukot}"), halign(center) 
    putpdf table t4(4,4)=("${m62ukot}"), halign(center) 
    putpdf table t4(5,4)=("${m63ukot}"), halign(center) 
    putpdf table t4(4,5)=("${m03ukot}"), halign(center) 
    putpdf table t4(5,5)=("${m04ukot}"), halign(center) 
    putpdf table t4(4,6)=("${m05ukot}"), halign(center) 
    putpdf table t4(5,6)=("${m06ukot}"), halign(center) 

** REPORT PAGE 3 - TABLE: COUNTRY SUMMARY METRICS
    putpdf table t5 = (8,11), width(90%) halign(center)    

    putpdf table t5(1,.), font("Calibri Light", 9, 000000) border(all, nil) valign(middle) 
    putpdf table t5(2,.), font("Calibri Light", 9, 000000) border(all, nil) bgcolor(e6e6e6) valign(middle)
    putpdf table t5(3,.), font("Calibri Light", 11, 000000) border(all, nil) valign(middle)
    putpdf table t5(4,.), font("Calibri Light", 11, 000000) border(all, nil) valign(middle)
    putpdf table t5(5,.), font("Calibri Light", 11, 000000) border(all, nil) valign(middle)
    putpdf table t5(6,.), font("Calibri Light", 11, 000000) border(all, nil) valign(middle)
    putpdf table t5(7,.), font("Calibri Light", 11, 000000) border(all, nil) valign(middle)
    putpdf table t5(8,.), font("Calibri Light", 11, 000000) border(all, nil) valign(middle)

    putpdf table t5(.,1), font("Calibri Light", 10, 000000) halign(right)
    putpdf table t5(.,2), font("Calibri Light", 11, 000000) halign(right) 
    putpdf table t5(.,3), font("Calibri Light", 11, 000000) halign(right)
    putpdf table t5(.,4), font("Calibri Light", 12, 0e497c) halign(right)
    putpdf table t5(.,5), font("Calibri Light", 12, 0e497c) halign(right)
    putpdf table t5(.,6), font("Calibri Light", 11, 000000) halign(right)
    putpdf table t5(.,7), font("Calibri Light", 11, 000000) halign(right)
    putpdf table t5(.,8), font("Calibri Light", 12, 7c0a07) halign(right) 
    putpdf table t5(.,9), font("Calibri Light", 12, 7c0a07) halign(right)
    putpdf table t5(.,10), font("Calibri Light", 11, 000000) halign(right)
    putpdf table t5(.,11), font("Calibri Light", 11, 000000) halign(right)

    putpdf table t5(1,1), font("Calibri Light", 9, 000000) colspan(11) halign(left)
    putpdf table t5(2,1), font("Calibri Light", 10, 000000) bold halign(left)
    putpdf table t5(2,2), font("Calibri Light", 10, 0e497c) bold halign(center)
    putpdf table t5(2,3), font("Calibri Light", 10, 0e497c) bold halign(center)
    putpdf table t5(2,4), font("Calibri Light", 10, 0e497c) bold halign(center)
    putpdf table t5(2,5), font("Calibri Light", 10, 0e497c) bold halign(center)
    putpdf table t5(2,6), font("Calibri Light", 10, 7c0a07) bold halign(center)
    putpdf table t5(2,7), font("Calibri Light", 10, 7c0a07) bold halign(center)
    putpdf table t5(2,8), font("Calibri Light", 10, 7c0a07) bold halign(center)
    putpdf table t5(2,9), font("Calibri Light", 10, 7c0a07) bold halign(center)
    putpdf table t5(2,10), font("Calibri Light", 10, 0e497c) bold halign(center)
    putpdf table t5(2,11), font("Calibri Light", 10, 0e497c) bold halign(center)

    putpdf table t5(1,1)=("The Table below summarises the progression of the COVID-19 outbreak as of $S_DATE. "),  halign(left) 
    putpdf table t5(1,1)=("The first THREE colums "),  halign(left) append
    putpdf table t5(1,1)=("IN BLUE"),  halign(left) font("Calibri Light", 10, 0e497c) append underline
    putpdf table t5(1,1)=(" summarise the number of cases. The next THREE columns "),  halign(left) append
    putpdf table t5(1,1)=("IN RED"),  halign(left) font("Calibri Light", 10, 7c0a07) append underline
    putpdf table t5(1,1)=(" summarise the number of deaths. The final column "), append 
    putpdf table t5(1,1)=("IN BLUE"),  halign(left) font("Calibri Light", 10, 0e497c) append underline
    putpdf table t5(1,1)=(" describes the growth rate of the "),  halign(left) append
    putpdf table t5(1,1)=("outbreak in each country. The dark line represents the rate in the country. "),  halign(left) append
    putpdf table t5(1,1)=("The shaded region represents the range of rates in the remaining countries and territories "),  halign(left) append 
    putpdf table t5(1,1)=("(see note 3)"), bold append
    putpdf table t5(1,1)=("."),  halign(left) append linebreak
    putpdf table t5(1,1)=(" "),  halign(left) append 
    
    putpdf table t5(2,1)=("Country"),  halign(left) bgcolor(e6e6e6) 
    putpdf table t5(3,1)=("Anguilla"), bold halign(left)
    putpdf table t5(4,1)=("Bermuda"), bold halign(left)
    putpdf table t5(5,1)=("British Virgin Islands"), bold halign(left)
    putpdf table t5(6,1)=("Cayman Islands"), bold halign(left)
    putpdf table t5(7,1)=("Mont- serrat"), bold halign(left)
    if $errortrap == 0 {
        putpdf table t5(8,1)=("Turks and Caicos Islands"), bold halign(left)
        }

    putpdf table t5(2,2)=("Total cases"),  halign(center) colspan(2) bgcolor(e6e6e6) 
    putpdf table t5(3,2)=image("`outputpath'/04_TechDocs/cases_AIA_$S_DATE.png") , colspan(2)
    putpdf table t5(4,2)=image("`outputpath'/04_TechDocs/cases_BMU_$S_DATE.png") , colspan(2)
    putpdf table t5(5,2)=image("`outputpath'/04_TechDocs/cases_VGB_$S_DATE.png") , colspan(2)
    putpdf table t5(6,2)=image("`outputpath'/04_TechDocs/cases_CYM_$S_DATE.png") , colspan(2)
    putpdf table t5(7,2)=image("`outputpath'/04_TechDocs/cases_MSR_$S_DATE.png") , colspan(2)
    if $errortrap == 0 {
        putpdf table t5(8,2)=image("`outputpath'/04_TechDocs/cases_TCA_$S_DATE.png") , colspan(2)
        }

    putpdf table t5(2,4)=("Cases in past week"),  halign(center) bgcolor(e6e6e6) 
    putpdf table t5(3,4)=(${m62_AIA}), halign(center) 
    putpdf table t5(4,4)=(${m62_BMU}), halign(center) 
    putpdf table t5(5,4)=(${m62_VGB}), halign(center) 
    putpdf table t5(6,4)=(${m62_CYM}), halign(center) 
    putpdf table t5(7,4)=(${m62_MSR}), halign(center) 
    if $errortrap == 0 {
        putpdf table t5(8,4)=(${m62_TCA}), halign(center) 
    }

    putpdf table t5(2,5)=("Days since 1st case"),  halign(center)  bgcolor(e6e6e6) 
    putpdf table t5(3,5)=(${m05_AIA}), halign(center) 
    putpdf table t5(4,5)=(${m05_BMU}), halign(center) 
    putpdf table t5(5,5)=(${m05_VGB}), halign(center) 
    putpdf table t5(6,5)=(${m05_CYM}), halign(center) 
    putpdf table t5(7,5)=(${m05_MSR}), halign(center) 
    if $errortrap == 0 {
        putpdf table t5(8,5)=(${m05_TCA}), halign(center) 
    }

    putpdf table t5(2,6)=("Total deaths"),  halign(center) colspan(2) bgcolor(e6e6e6) 
    putpdf table t5(3,6)=image("`outputpath'/04_TechDocs/deaths_AIA_$S_DATE.png") , colspan(2)
    putpdf table t5(4,6)=image("`outputpath'/04_TechDocs/deaths_BMU_$S_DATE.png") , colspan(2)
    putpdf table t5(5,6)=image("`outputpath'/04_TechDocs/deaths_VGB_$S_DATE.png") , colspan(2)
    putpdf table t5(6,6)=image("`outputpath'/04_TechDocs/deaths_CYM_$S_DATE.png") , colspan(2)
    putpdf table t5(7,6)=image("`outputpath'/04_TechDocs/deaths_MSR_$S_DATE.png") , colspan(2)
    if $errortrap == 0 {
        putpdf table t5(8,6)=image("`outputpath'/04_TechDocs/deaths_TCA_$S_DATE.png") , colspan(2)
    }

    putpdf table t5(2,8)=("Deaths in past week"),  halign(center)  bgcolor(e6e6e6) 
    putpdf table t5(3,8)=(${m63_AIA}), halign(center) 
    putpdf table t5(4,8)=(${m63_BMU}), halign(center) 
    putpdf table t5(5,8)=(${m63_VGB}), halign(center) 
    putpdf table t5(6,8)=(${m63_CYM}), halign(center) 
    putpdf table t5(7,8)=(${m63_MSR}), halign(center) 
    if $errortrap == 0 {
        putpdf table t5(8,8)=(${m63_TCA}), halign(center) 
    }

    putpdf table t5(2,9)=("Days since 1st death"),  halign(center)  bgcolor(e6e6e6) 
    putpdf table t5(3,9)=(${m06_AIA}), halign(center) 
    putpdf table t5(4,9)=(${m06_BMU}), halign(center) 
    putpdf table t5(5,9)=(${m06_VGB}), halign(center) 
    putpdf table t5(6,9)=(${m06_CYM}), halign(center) 
    putpdf table t5(7,9)=(${m06_MSR}), halign(center) 
    if $errortrap == 0 {
        putpdf table t5(8,9)=(${m06_TCA}), halign(center) 
    }

    putpdf table t5(2,10)=("CARICOM growth rates among cases"),  halign(center) colspan(2) bgcolor(e6e6e6) 
    putpdf table t5(3,10)=image("`outputpath'/04_TechDocs/spark_AIA_$S_DATE.png") , colspan(2)
    putpdf table t5(4,10)=image("`outputpath'/04_TechDocs/spark_BMU_$S_DATE.png") , colspan(2)
    putpdf table t5(5,10)=image("`outputpath'/04_TechDocs/spark_VGB_$S_DATE.png") , colspan(2)
    putpdf table t5(6,10)=image("`outputpath'/04_TechDocs/spark_CYM_$S_DATE.png") , colspan(2)
    putpdf table t5(7,10)=image("`outputpath'/04_TechDocs/spark_MSR_$S_DATE.png") , colspan(2)
    if $errortrap == 0 {
        putpdf table t5(8,10)=image("`outputpath'/04_TechDocs/spark_TCA_$S_DATE.png") , colspan(2)
    }



** REPORT PAGE 4 - FOOTNOTE 1. DATA REFERENCE
** REPORT PAGE 4 - FOOTNOTE 2. CARICOM COUNTRIES
** REPORT PAGE 4 - FOOTNOTE 3. GROWTH RATE
    putpdf pagebreak 
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
    putpdf table p3(3,1)=("The blue graph in the final column shows the number of cases on a different scale (called a logarithm scale). "), append 
    putpdf table p3(3,1)=("This gives us the growth rate over time, and is good for comparing progress against other countries. "), append
    putpdf table p3(3,1)=("The shaded region behind the country growth curve is the range of outbreak growth for"), append 
    putpdf table p3(3,1)=("the remaining"), append italic 
    putpdf table p3(3,1)=("countries and territories. "), append
    putpdf table p3(3,1)=("There are 14 CARICOM member states and 6 UKOTS included in this briefing, so this shaded region includes 19 countries."), append
    putpdf table p3(3,1)=("This range is represented by percentiles (darker blue region represents 25th to 75th percentile, lighter blue "), append
    putpdf table p3(3,1)=("region represents 5th to 95th percntiles). All curves and regions are 7-day smoothed averages."), append

** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    ** putpdf save "`outputpath'/05_Outputs/covid19_trajectory_regional_version3_`date_string'", replace
    putpdf save "`syncpath'/`date_string' Regional Briefing ", replace


