** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					covidprofiles_008_region3_v3.do
    //  project:				        
    //  analysts:				       	Ian HAMBLETON
    // 	date last modified	            27-APR-2020
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
    log using "`logpath'\covidprofiles_008_region3_v3", replace
** HEADER -----------------------------------------------------


** -----------------------------------------
** Pre-Load the COVID metrics --> as Global Macros
** -----------------------------------------
qui do "`logpath'\covidprofiles_004_metrics_v3"
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


** COUNTRY RESTRICTION: CARICOM countries only (N=14)
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

** HEATMAP preparation - ADD ROWS
** Want symmetric / rectangular matrix of dates. So we need 
** to backfill dates foreach country to date of first 
** COVID appearance - which I think was in JAM
    fillin date iso_num 
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
bysort iso_num: egen elapsed_max = max(elapsed)


keep iso_num date pop confirmed confirmed_rate deaths recovered
** Fix Guyana 
replace confirmed = 4 if iso_num==14 & date>=d(17mar2020) & date<=d(23mar2020)
rename confirmed metric1
rename confirmed_rate metric2
rename deaths metric3
rename recovered metric4
reshape long metric, i(iso_num date) j(mtype)
label define mtype_ 1 "cases" 2 "attack rate" 3 "deaths" 4 "recovered"
label values mtype mtype_
sort iso_num mtype date 


** CARIBBEAN-WIDE SUMMARY 

** 1. Total count of cases across the Caribbean / CARICOM
** 2. Total count of deaths across the Caribbean / CARICOM
keep if mtype==1 | mtype==3
collapse (sum) metric pop, by(date mtype) 

** New daily cases and deaths
sort mtype date 
gen daily = metric - metric[_n-1] if mtype==mtype[_n-1]

** DOUBLING RATE
** Then create a rolling average 
** Using 1-week window for now
format pop  %14.0fc
gen growthrate = log(metric/metric[_n-1]) if mtype==mtype[_n-1] 
gen doublingtime = log(2)/growthrate
by mtype: asrol doublingtime , stat(mean) window(date 10) gen(dt7)

** NUMBER OF CASES and NUMBER OF DEATHS
sort mtype date 
egen tc1 = max(metric) if mtype==1 
egen tc2 = min(tc1)
egen td1 = max(metric) if mtype==3 
egen td2 = min(td1)
local ncases = tc2
local ndeaths = td2 
drop tc1 tc2 td1 td2 

** LOCAL MACRO FOR MOST RECENT DOUBLING TIME 
sort mtype date 
gen tdt1 = dt7 if mtype==1 & mtype!=mtype[_n+1]
egen tdt2 = min(tdt1)
gen tdt3 = int(tdt2)
local dt_cases = tdt3 
gen tdt4 = dt7 if mtype==3 & mtype!=mtype[_n+1]
egen tdt5 = min(tdt4)
gen tdt6 = int(tdt5)
local dt_deaths = tdt6 
drop tdt1 tdt2 tdt3 tdt4 tdt5 tdt6

dis "Cases are: " `ncases'
dis "Deaths are: " `ndeaths'
dis "Cases Doubled in: " `dt_cases'
dis "Deaths Doubled in: " `dt_deaths'

** Automate final date on x-axis 
** Use latest date in dataset 
egen fdate1 = max(date)
global fdate = fdate1 
global fdatef : di %tdD_m date("$S_DATE", "DMY")

** CARICOM SUMMARY: CASES FIRST
** 1. BAR CHART    --> CUMULATIVE CASES.
** 2. BAR CHART    --> NEW DAILY CASES.
** 3. LINE CHART   --> RATE OF DOUBLING

** 1. BAR CHART    --> CUMULATIVE CASES
        #delimit ;
        gr twoway 
            (bar metric date if mtype==1, col("160 199 233"))
            (bar metric date if mtype==3, col("233 102 80")
            
            )
            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(10) xsize(10)
            
   xlab(   21984 "10 Mar" 
            21994 "20 Mar" 
            22004 "30 Mar" 
            22015 "10 Apr"
            $fdate "$fdatef"
            , labs(3) nogrid glc(gs16) angle(45) format(%9.0f))
            xtitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 
                
            ylab(
            , labs(3) notick nogrid glc(gs16) angle(0))
            yscale(fill noline range(0(1)14)) 
            ytitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 
            
            title("(1) Cumulative cases in 14 CARICOM countries", pos(11) ring(1) size(4))

            legend(off size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                )
                name(cases_bar_01) 
                ;
        #delimit cr
        graph export "`outputpath'/04_TechDocs/cumcases_region_$S_DATE.png", replace width(4000)


** 2. BAR CHART    --> NEW DAILY CASES.
        #delimit ;
        gr twoway 
            (bar daily date if mtype==1, col("160 199 233"))
            (bar daily date if mtype==3, col("233 102 80")
            
            )
            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(10) xsize(10)
            
   xlab(   21984 "10 Mar" 
            21994 "20 Mar" 
            22004 "30 Mar" 
            22015 "10 Apr"
            $fdate "$fdatef"
            , labs(3) nogrid glc(gs16) angle(45) format(%9.0f))
            xtitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 
                
            ylab(
            , labs(3) notick nogrid glc(gs16) angle(0))
            yscale(fill noline range(0(1)14)) 
            ytitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 
            
            title("(2) Daily cases in 14 CARICOM countries", pos(11) ring(1) size(4))

            legend(off size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                )
                name(cases_bar_02) 
                ;
        #delimit cr
        graph export "`outputpath'/04_TechDocs/newcases_region_$S_DATE.png", replace width(4000)

** 3. LINE CHART    --> RATE OF DOUBLING
        #delimit ;
        gr twoway 
            (line dt7 date if mtype==1, lc("23 83 135") lp("-"))
            (line dt7 date if mtype==3, lc("168 39 29") lp("-")
            )
            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(10) xsize(10)
            
    xlab(   21984 "10 Mar" 
            21994 "20 Mar" 
            22004 "30 Mar" 
            22015 "10 Apr"
            $fdate "$fdatef"
            , labs(3) nogrid glc(gs16) angle(45) format(%9.0f))
            xtitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 
                
            ylab(
            , labs(3) notick nogrid glc(gs16) angle(0))
            yscale(fill noline range(0(1)14)) 
            ytitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 
            
            title("(3) Doubling time (days) in 14 CARICOM countries", pos(11) ring(1) size(4))

            legend(off size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                )
                name(cases_dt_01) 
                ;
        #delimit cr
        graph export "`outputpath'/04_TechDocs/dt_region_$S_DATE.png", replace width(4000)


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
    putpdf table intro(1,2)=("COVID-19 Doubling Time for 14 CARICOM countries"), halign(left) linebreak font("Calibri Light", 12, 000000)
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
    putpdf text ("We present the numbers of confirmed COVID-19 cases and deaths")
    putpdf text (" (see note 1)"), bold
    putpdf text (" among 14 CARICOM countries ")
    putpdf text (" (see note 2)"), bold   
    putpdf text (" since the start of the outbreak.  ") 
    putpdf text ("In an outbreak such as this we must monitor the numbers of cases and deaths, and also the rate at which ") 
    putpdf text ("these numbers are increasing. Even if current numbers are small, a fast growth rate can quickly lead to ")
    putpdf text ("very large numbers. To report this rate of change we focus on the question: ") 
    putpdf text ("How long did it take for the number of confirmed deaths to double? "), italic
    putpdf text ("If cases go up by a fixed number over a fixed period – say, by 20 every three days – we call that “linear” growth. ") 
    putpdf text ("If instead, numbers double every three days (for example) we call that “exponential” growth. ") 
    putpdf text ("Without any national interventions for containment, we should expect near exponential growth. ") 
    putpdf text ("National policies to encourage physical distancing should encourage linear growth or better. ") 
    putpdf text ("Daily tracking of the growth rate is therefore a useful monitoring metric. ")

    putpdf text ("In a companion briefing ") 
    putpdf text ("(COVID-19 trajectories for 14 CARICOM countries,"), italic 
    putpdf text ("available at: https://tinyurl.com/uwi-covid19-surveillance) "), italic
    putpdf text (" we report the estimated growth rate for each country."), linebreak
    putpdf text (" "), linebreak
    putpdf text ("We use three graphics to explore the rate of increase of cases and deaths up to $S_DATE. ") 
    putpdf text ("(graph 1) "), italic 
    putpdf text ("Cumulative cases and deaths across the 14 CARICOM members states, ")  
    putpdf text ("(graph 2) "), italic 
    putpdf text ("Daily cases and deaths across the 14 CARICOM member states, and ")
    putpdf text ("(graph 3) "), italic 
    putpdf text ("Doubling time (in days) for cases and for deaths (1-week rolling average). ")
    putpdf text ("An increasing doubling time can be an early indication that the regional response is working."), linebreak
    putpdf text (" "), linebreak

** TABLE: KEY SUMMARY METRICS
    putpdf table t1 = (2,3), width(75%) halign(center) 
    putpdf table t1(1,1), font("Calibri Light", 13, ffffff) border(all,single,ffffff) bgcolor(215d92) 
    putpdf table t1(2,1), font("Calibri Light", 13, ffffff) border(all,single,ffffff) bgcolor(bd392b) 
    putpdf table t1(1,2), font("Calibri Light", 13, 000000) border(all,nil) 
    putpdf table t1(2,2), font("Calibri Light", 13, 000000) border(all,nil) 
    putpdf table t1(1,3), font("Calibri Light", 13, 000000) border(all,nil) 
    putpdf table t1(2,3), font("Calibri Light", 13, 000000) border(all,nil) 
    putpdf table t1(1,1)=("Confirmed Cases"), halign(center) 
    putpdf table t1(2,1)=("Confirmed Deaths"), halign(center)  
    putpdf table t1(1,2)=("`ncases'"), halign(center) 
    putpdf table t1(2,2)=("`ndeaths'"), halign(center) 
    putpdf table t1(1,3)=("Doubled in: `dt_cases' Days"), halign(center) 
    putpdf table t1(2,3)=("Doubled in: `dt_deaths' Days"), halign(center) 

** FIGURES OF REGIONAL COVID-19 COUNT trajectories
    putpdf table f1 = (1,3), width(100%) border(all,nil) halign(center)
    putpdf table f1(1,1)=image("`outputpath'/04_TechDocs/cumcases_region_$S_DATE.png")
    putpdf table f1(1,2)=image("`outputpath'/04_TechDocs/newcases_region_$S_DATE.png")
    putpdf table f1(1,3)=image("`outputpath'/04_TechDocs/dt_region_$S_DATE.png")

** FINAL WORD ON FUTURE COUNTRY-LEVEL COUNTS
    putpdf paragraph ,  font("Calibri Light", 9)
    putpdf text ("Country-Level estimates of doubling rate. "), bold 
    putpdf text ("As of $S_DATE, the numbers of confirmed cases and deaths in individual countries remains thankfully low. ")
    putpdf text ("We will begin reporting the doubling rate for individual countries as the need arises. ")

** CASE IDENTIFICATION BIAS
    putpdf paragraph ,  font("Calibri Light", 9)
    putpdf text ("Case identification affects the doubling time for confirmed cases. "), bold 
    putpdf text ("The doubling time for confirmed cases is heavily influenced by the extent of testing in individual countries. ")
    putpdf text ("For this reason, a doubling time produced using confirmed cases should be interpreted cautiously. ")

** FOOTNOTE 1. DATA REFERENCE
** FOOTNOTE 2. CARICOM COUNTRIES
    putpdf table p3 = (2,1), width(100%) halign(center) 
    putpdf table p3(.,1), font("Calibri Light", 8) border(all,nil,000000) bgcolor(ffffff)
    putpdf table p3(1,1)=("(NOTE 1) Data Source. "), bold halign(left)
    putpdf table p3(1,1)=("Dong E, Du H, Gardner L. An interactive web-based dashboard to track COVID-19 "), append 
    putpdf table p3(1,1)=("in real time. Lancet Infect Dis; published online Feb 19. https://doi.org/10.1016/S1473-3099(20)30120-1"), append
    putpdf table p3(2,1)=("(NOTE 2) CARICOM member states reported in this briefing.  "), bold halign(left)
    putpdf table p3(2,1)=("Antigua and Barbuda, The Bahamas, Barbados, Belize, Dominica, Grenada, Guyana, Haiti, Jamaica, "), append 
    putpdf table p3(2,1)=("St. Kitts and Nevis, St. Lucia, St. Vincent and the Grenadines, Suriname, Trinidad and Tobago."), append

** Save the PDF
    local c_date = c(current_date)
    local c_time = c(current_time)
    local c_time_date = "`c_date'"+"_" +"`c_time'"
    local time_string = subinstr("`c_time_date'", ":", "_", .)
    local time_string = subinstr("`time_string'", " ", "", .)
    ///putpdf save "`outputpath'/05_Outputs/covid19_trajectory_caricom_heatmap_`time_string'", replace
    putpdf save "`outputpath'/05_Outputs/covid19_doublingtime_version3_`c_date'", replace
