** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					paper01_10fig1.do
    //  project:				        
    //  analysts:				       	Ian HAMBLETON
    // 	date last modified	            12-MAY-2020
    //  algorithm task			        PAPER 01. Situation Analysis. Figure 1

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
    log using "`logpath'\paper01_10fig1", replace
** HEADER -----------------------------------------------------

** -----------------------------------------
** Pre-Load the COVID metrics --> as Global Macros
** -----------------------------------------
qui do "`logpath'\paper01_04metrics"
** -----------------------------------------

** Close any open log file and open a new log file
capture log close
log using "`logpath'\paper01_10fig1", replace

** Attack Rate (per 1,000 --> not yet used)
gen confirmed_rate = (confirmed / pop) * 10000

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

** CARICOM (N=14)
** METRIC 60
** Cases in past 1-day across region 
global m60car =  $m60_ATG + $m60_BHS + $m60_BRB + $m60_BLZ + $m60_DMA + $m60_GRD + $m60_GUY ///
            + $m60_HTI + $m60_JAM + $m60_KNA + $m60_LCA + $m60_VCT + $m60_SUR + $m60_TTO
** METRIC 62
** Cases in past 7-days across region 
global m62car =  $m62_ATG + $m62_BHS + $m62_BRB + $m62_BLZ + $m62_DMA + $m62_GRD + $m62_GUY ///
            + $m62_HTI + $m62_JAM + $m62_KNA + $m62_LCA + $m62_VCT + $m62_SUR + $m62_TTO

** METRIC 61
** Deaths in past 1-day across region 
global m61car =  $m61_ATG + $m61_BHS + $m61_BRB + $m61_BLZ + $m61_DMA + $m61_GRD + $m61_GUY ///
            + $m61_HTI + $m61_JAM + $m61_KNA + $m61_LCA + $m61_VCT + $m61_SUR + $m61_TTO
** METRIC 63
** Deaths in past 7-days across region 
global m63car =  $m63_ATG + $m63_BHS + $m63_BRB + $m63_BLZ + $m63_DMA + $m63_GRD + $m63_GUY ///
            + $m63_HTI + $m63_JAM + $m63_KNA + $m63_LCA + $m63_VCT + $m63_SUR + $m63_TTO

** METRIC 01 
** CURRENT CONFIRMED CASES across region
global m01car =  $m01_ATG + $m01_BHS + $m01_BRB + $m01_BLZ + $m01_DMA + $m01_GRD + $m01_GUY ///
            + $m01_HTI + $m01_JAM + $m01_KNA + $m01_LCA + $m01_VCT + $m01_SUR + $m01_TTO

** METRIC 02
** CURRENT CONFIRMED DEATHS across region
global m02car =  $m02_ATG + $m02_BHS + $m02_BRB + $m02_BLZ + $m02_DMA + $m02_GRD + $m02_GUY ///
            + $m02_HTI + $m02_JAM + $m02_KNA + $m02_LCA + $m02_VCT + $m02_SUR + $m02_TTO




** CARICOM (N=14)
** METRIC 60
** Cases in past 1-day across region 
global m60caricom =  $m60_ATG + $m60_BHS + $m60_BRB + $m60_BLZ + $m60_DMA + $m60_GRD + $m60_GUY ///
            + $m60_HTI + $m60_JAM + $m60_KNA + $m60_LCA + $m60_VCT + $m60_SUR + $m60_TTO        ///
            + $m60_AIA + $m60_BMU + $m60_VGB + $m60_CYM + $m60_MSR + $m60_TCA

** METRIC 61
** Deaths in past 1-day across region 
global m61caricom =  $m61_ATG + $m61_BHS + $m61_BRB + $m61_BLZ + $m61_DMA + $m61_GRD + $m61_GUY ///
            + $m61_HTI + $m61_JAM + $m61_KNA + $m61_LCA + $m61_VCT + $m61_SUR + $m61_TTO        ///
            + $m61_AIA + $m61_BMU + $m61_VGB + $m61_CYM + $m61_MSR + $m61_TCA
            
** METRIC 62
** Cases in past 7-days across region 
global m62caricom =  $m62_ATG + $m62_BHS + $m62_BRB + $m62_BLZ + $m62_DMA + $m62_GRD + $m62_GUY ///
            + $m62_HTI + $m62_JAM + $m62_KNA + $m62_LCA + $m62_VCT + $m62_SUR + $m62_TTO        ///
            + $m62_AIA + $m62_BMU + $m62_VGB + $m62_CYM + $m62_MSR + $m62_TCA


** METRIC 63
** Deaths in past 7-days across region 
global m63caricom =  $m63_ATG + $m63_BHS + $m63_BRB + $m63_BLZ + $m63_DMA + $m63_GRD + $m63_GUY ///
            + $m63_HTI + $m63_JAM + $m63_KNA + $m63_LCA + $m63_VCT + $m63_SUR + $m63_TTO        ///
            + $m63_AIA + $m63_BMU + $m63_VGB + $m63_CYM + $m63_MSR + $m63_TCA

** METRIC 01 
** CURRENT CONFIRMED CASES across region
global m01caricom =  $m01_ATG + $m01_BHS + $m01_BRB + $m01_BLZ + $m01_DMA + $m01_GRD + $m01_GUY ///
            + $m01_HTI + $m01_JAM + $m01_KNA + $m01_LCA + $m01_VCT + $m01_SUR + $m01_TTO        ///
            + $m01_AIA + $m01_BMU + $m01_VGB + $m01_CYM + $m01_MSR + $m01_TCA

** METRIC 02
** CURRENT CONFIRMED DEATHS across region
global m02caricom =  $m02_ATG + $m02_BHS + $m02_BRB + $m02_BLZ + $m02_DMA + $m02_GRD + $m02_GUY ///
            + $m02_HTI + $m02_JAM + $m02_KNA + $m02_LCA + $m02_VCT + $m02_SUR + $m02_TTO        ///
            + $m02_AIA + $m02_BMU + $m02_VGB + $m02_CYM + $m02_MSR + $m02_TCA




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



** DOM REP + CUBA
** METRIC 60
** Cases in past 1-day across region 
global m60other =  $m60_CUB + $m60_DOM
** METRIC 62
** Cases in past 7-days across region 
global m62other =  $m62_CUB + $m62_DOM 

** METRIC 61
** Deaths in past 1-day across region 
global m61other =  $m61_CUB + $m61_DOM 

** METRIC 63
** Deaths in past 7-days across region 
global m63other =  $m63_CUB + $m63_DOM 

** METRIC 01 
** CURRENT CONFIRMED CASES across region
global m01other =  $m01_CUB + $m01_DOM

** METRIC 02
** CURRENT CONFIRMED DEATHS across region
global m02other = $m02_CUB + $m02_DOM



** CARICOM + UKOTS + CAR_OTHER
** METRIC 60
** Cases in past 1-day across region 
global m60 =  $m60_ATG + $m60_BHS + $m60_BRB + $m60_BLZ + $m60_DMA + $m60_GRD + $m60_GUY ///
            + $m60_HTI + $m60_JAM + $m60_KNA + $m60_LCA + $m60_VCT + $m60_SUR + $m60_TTO ///
            + $m60_AIA + $m60_BMU + $m60_VGB + $m60_CYM + $m60_MSR + $m60_TCA ///
            + $m60_CUB + $m60_DOM 

** METRIC 62
** Cases in past 7-days across region 
global m62 =  $m62_ATG + $m62_BHS + $m62_BRB + $m62_BLZ + $m62_DMA + $m62_GRD + $m62_GUY ///
            + $m62_HTI + $m62_JAM + $m62_KNA + $m62_LCA + $m62_VCT + $m62_SUR + $m62_TTO ///
            + $m62_AIA + $m62_BMU + $m62_VGB + $m62_CYM + $m62_MSR + $m62_TCA  ///
            + $m62_CUB + $m62_DOM 

** METRIC 61
** Deaths in past 1-day across region 
global m61 =  $m61_ATG + $m61_BHS + $m61_BRB + $m61_BLZ + $m61_DMA + $m61_GRD + $m61_GUY ///
            + $m61_HTI + $m61_JAM + $m61_KNA + $m61_LCA + $m61_VCT + $m61_SUR + $m61_TTO ///
            + $m61_AIA + $m61_BMU + $m61_VGB + $m61_CYM + $m61_MSR + $m61_TCA  ///
            + $m61_CUB + $m61_DOM 

** METRIC 63
** Deaths in past 7-days across region 
global m63 =  $m63_ATG + $m63_BHS + $m63_BRB + $m63_BLZ + $m63_DMA + $m63_GRD + $m63_GUY ///
            + $m63_HTI + $m63_JAM + $m63_KNA + $m63_LCA + $m63_VCT + $m63_SUR + $m63_TTO ///
            + $m63_AIA + $m63_BMU + $m63_VGB + $m63_CYM + $m63_MSR + $m63_TCA  ///
            + $m63_CUB + $m63_DOM 

** METRIC 01 
** CURRENT CONFIRMED CASES across region
global m01 =  $m01_ATG + $m01_BHS + $m01_BRB + $m01_BLZ + $m01_DMA + $m01_GRD + $m01_GUY ///
            + $m01_HTI + $m01_JAM + $m01_KNA + $m01_LCA + $m01_VCT + $m01_SUR + $m01_TTO ///
            + $m01_AIA + $m01_BMU + $m01_VGB + $m01_CYM + $m01_MSR + $m01_TCA  /// 
            + $m01_CUB + $m01_DOM 

** METRIC 02
** CURRENT CONFIRMED DEATHS across region
global m02 =  $m02_ATG + $m02_BHS + $m02_BRB + $m02_BLZ + $m02_DMA + $m02_GRD + $m02_GUY ///
            + $m02_HTI + $m02_JAM + $m02_KNA + $m02_LCA + $m02_VCT + $m02_SUR + $m02_TTO ///
            + $m02_AIA + $m02_BMU + $m02_VGB + $m02_CYM + $m02_MSR + $m02_TCA  /// 
            + $m02_CUB + $m02_DOM 


** SUBSETS 
gen touse = 1
replace touse = 0 if    iso=="GBR" | iso=="FJI" | iso=="KOR" | iso=="SGP"  | ///
                        iso=="VNM" | iso=="NZL" | iso=="ITA" | iso=="DEU"
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


** ----------------------------------------------
** FIGURE 1 and TABLE 1
** ----------------------------------------------

** COUNTRY RESTRICTION: CARICOM + UKOTS + CUB + DOM (N=22)
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
        iso=="CUB" |
        iso=="DMA" |
        iso=="DOM" |
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
        iso=="TCA" ;
#delimit cr   


** CARIBBEAN-WIDE SUMMARY 

** 1. Total count of cases across the Caribbean / CARICOM
** 2. Total count of deaths across the Caribbean / CARICOM
keep if mtype==1 | mtype==3

** COUNTRY GROUPINGS 

** CARICOM versus OTHER
gen ctype1 = 1
replace ctype1 = 2 if iso=="DOM" | iso=="CUB"

** CARICOM vs CUBA vs DOM REP
gen ctype2 = 1
replace ctype2 = 2 if iso=="CUB" 
replace ctype2 = 3 if iso=="DOM" 

** ALL vs DOM REP
gen ctype = 1
replace ctype = 2 if iso=="DOM"

collapse (sum) metric pop, by(date mtype ctype2) 
rename ctype2 ctype 
drop pop
reshape wide metric , i(date mtype) j(ctype)


** New daily cases and deaths
sort mtype date 
gen daily1 = metric1 - metric1[_n-1] if mtype==mtype[_n-1]
gen daily2 = metric2 - metric2[_n-1] if mtype==mtype[_n-1]
gen daily3 = metric3 - metric3[_n-1] if mtype==mtype[_n-1]

** NUMBER OF CARICOM CASES and NUMBER OF DEATHS
sort mtype date 
egen tc1 = max(metric1) if mtype==1 
egen tc2 = min(tc1)
egen td1 = max(metric1) if mtype==3 
egen td2 = min(td1)
local ncases = tc2
local ndeaths = td2 
drop tc1 tc2 td1 td2 

dis "Cases are: " `ncases'
dis "Deaths are: " `ndeaths'


** Creating 0 totals
foreach var in metric1 metric2 metric2 daily1 daily2 daily3 {
    replace `var' = 0 if `var' == .
}

** Stacking Cuba onto CARICOM and Dom Rep onto Cuba 
replace metric2 = metric1 + metric2 
replace metric3 = metric2 + metric3 
replace daily2 = daily1 + daily2 
replace daily3 = daily2 + daily3 

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
            (bar metric3 date if mtype==1 , lc(gs0) lw(0.05) fc("101 104 176"))
            (bar metric2 date if mtype==1 , lc(gs0) lw(0.05) fc("151 194 221"))
            (bar metric1 date if mtype==1 , lc(gs0) lw(0.05) fc("232 246 250"))            
            (bar metric3 date if mtype==3 , lc(gs0) lw(0.05) fc("188 64 92"))
            (bar metric2 date if mtype==3 , lc(gs0) lw(0.05) fc("247 146 114"))
            (bar metric1 date if mtype==3 , lc(gs0) lw(0.05) fc("254 232 172")          
            )
            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(16) xsize(10)
            
   xlab(  
            21974 "29 Feb" 
            21984 "10 Mar" 
            21994 "20 Mar" 
            22004 "30 Mar" 
            22015 "10 Apr"
            22025 "20 Apr"
            22035 "30 Apr"
            22045 "10 May"
            $fdate "$fdatef"
            , labs(3.5) nogrid glc(gs16) angle(45) format(%9.0f))
            xtitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 
                
            ylab(0 2000 "2,000" 4000 "4,000" 6000 "6,000" 8000 "8,000" 10000 "10,000" 12000 "12,000" 14000 "14,000" 16000 "16,000" 18000 "18000"
            , labs(3.5) notick nogrid glc(gs16) angle(0))
            yscale(fill noline range(0(1)14)) 
            ytitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 
            
            title("(A) Cumulative cases in 22 Caribbean SIDS", pos(11) ring(1) size(4) color(gs0))

            legend(size(3.5) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                order(1 2 3 4 5 6) 
                lab(1 "Cases: Dom Rep")
                lab(2 "Cases: Cuba")
                lab(3 "Cases: CARICOM")
                lab(4 "Deaths: Dom Rep")
                lab(5 "Deaths: Cuba")
                lab(6 "Deaths: CARICOM")
                )
                name(cases_bar_01) 
                ;
        #delimit cr
        graph export "`outputpath'/04_TechDocs/figure1A_$S_DATE.png", replace width(4000)


** 2. BAR CHART    --> NEW DAILY CASES.
        #delimit ;
        gr twoway 
            (bar daily3 date if mtype==1 , lc(gs0) lw(0.05) fc("101 104 176"))
            (bar daily2 date if mtype==1 , lc(gs0) lw(0.05) fc("151 194 221"))
            (bar daily1 date if mtype==1 , lc(gs0) lw(0.05) fc("232 246 250"))           
            (bar daily3 date if mtype==3 , lc(gs0) lw(0.05) fc("188 64 92"))
            (bar daily2 date if mtype==3 , lc(gs0) lw(0.05) fc("247 146 114"))
            (bar daily1 date if mtype==3 , lc(gs0) lw(0.05) fc("254 232 172")    
            
            )
            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(16) xsize(10)
            
   xlab(
            21974 "29 Feb" 
            21984 "10 Mar" 
            21994 "20 Mar" 
            22004 "30 Mar" 
            22015 "10 Apr"
            22025 "20 Apr"
            22035 "30 Apr" 
            22045 "10 May"
            $fdate "$fdatef"
            , labs(3.5) nogrid glc(gs16) angle(45) format(%9.0f))
            xtitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 
                
            ylab(
            , labs(3.5) notick nogrid glc(gs16) angle(0))
            yscale(fill noline range(0(1)14)) 
            ytitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 
            
            title("(B) Daily cases in 22 Caribbean SIDS", pos(11) ring(1) size(4) color(gs0))

            legend(off size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                )
                name(cases_bar_02) 
                ;
        #delimit cr
        graph export "`outputpath'/04_TechDocs/figure1B_$S_DATE.png", replace width(8000)

** Save to PDF file
    putpdf begin, pagesize(letter) landscape font("Calibri", 10) margin(top,1cm) margin(bottom,0.5cm) margin(left,1cm) margin(right,1cm)

    ** Figure 1 Title 
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure 1. ") , bold
    putpdf text ("Numbers of confirmed cases and confirmed deaths from COVID‐19 in 22 Caribbean countries and territories up to 27 May 2020")

    putpdf table fig1 = (1,2), width(90%) halign(left)    
    putpdf table fig1(.,.), border(all, nil) valign(center)
    putpdf table fig1(1,1) = image("`outputpath'/04_TechDocs/figure1A_$S_DATE.png")
    putpdf table fig1(1,2) = image("`outputpath'/04_TechDocs/figure1B_$S_DATE.png")
** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    putpdf save "X:\The University of the West Indies\DataGroup - DG_Projects\PROJECT_p151\05_Outputs_Papers\01_NPIs_progressreport\Figure1_`date_string'", replace

