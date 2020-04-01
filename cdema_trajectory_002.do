** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					cdema_trajectory_002.do
    //  project:				        
    //  analysts:				       	Ian HAMBLETON
    // 	date last modified	            27-MAR-2020
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
    log using "`logpath'\cdema_trajectory_002", replace
** HEADER -----------------------------------------------------

** JH time series COVD-19 data 
use "`datapath'\version01\2-working\jh_time_series", clear

** DAILY COUNT for any "COUNTRY / DATE" combination 
preserve
    keep if countryregion=="US"
    collapse (sum) confirmed deaths recovered, by(date)
    list date confirmed deaths recovered if date==date("1/26/2020", "MDY"), abbreviate(13)
restore 

** TIME SERIES - GLOBAL 
** preserve 
**     collapse (sum) confirmed deaths recovered, by(date)
**     format %8.0fc confirmed deaths recovered
**     tsset date, daily
**     generate newcases = D.confirmed
**     tsline confirmed, title(Global Confirmed COVID-19 Cases)
** restore 

** TIME SERIES - MULTIPLE COUNTRIES 1
** UK and Barbados
replace countryregion = "UK" if countryregion=="United Kingdom"

keep if inlist(countryregion, "Barbados", "Jamaica", "South Korea", "UK", "US")
collapse (sum) confirmed deaths recovered, by(date countryregion)
list date countryregion confirmed deaths recovered in -9/l, sepby(date) abbreviate(13)
encode countryregion, gen(country)
list date countryregion country in -9/l, sepby(date) abbreviate(13)
label list country
tsset country date, daily
* Add days since first reported cases
bysort country: gen elapsed = _n 
save covide19_long, replace

** Country populations
* BRB
gen pop = 287371 if country==1
* JAM
replace pop = 2961161 if country==2 
* KOR
replace pop = 51269183 if country==3
* UK
replace pop = 67886004 if country==4
* US
replace pop = 331002647 if country==5

** Rate per 1,000 (not used yet as BB rate becomes too high)
** replace confirmed = (confirmed/pop)*10000

* reshape to wide for comparisons 
keep date country pop confirmed deaths recovered
bysort country : gen elapsed = _n 
drop date 
reshape wide confirmed deaths recovered pop, i(elapsed) j(country)
list confirmed1 confirmed2 confirmed3 in -5/l, abbreviate(13)

* labelling - BARBADOS
rename confirmed1 bar_c
rename deaths1 bar_d
rename recovered1 bar_r
///rename elapsed1 bar_e
label var bar_c "Barbados cases"
label var bar_d "Barbados deaths"
label var bar_r "Barbados recovered"
///label var bar_e "Barbados elapsed"
* labelling - JAMAICA
rename confirmed2 jam_c
rename deaths2 jam_d
rename recovered2 jam_r
label var jam_c "Jamaica cases"
label var jam_d "Jamaica deaths"
label var jam_r "Jamaica recovered"
* labelling - SOUTH KOREA 
rename confirmed3 skorea_c
rename deaths3 skorea_d
rename recovered3 skorea_r
label var skorea_c "Sth Korea cases"
label var skorea_d "Sth Korea deaths"
label var skorea_r "Sth Korea recovered"
* labelling - UK
rename confirmed4 uk_c
rename deaths4 uk_d
rename recovered4 uk_r
label var uk_c "UK cases"
label var uk_d "UK deaths"
label var uk_r "UK recovered"
* labelling - USA
rename confirmed5 usa_c
rename deaths5 usa_d
rename recovered5 usa_r
label var usa_c "USA cases"
label var usa_d "USA deaths"
label var usa_r "USA recovered"

** Days since first case
local days = 20

** CHART _ DAYS SINCE FIRST CASE 
** Without Caribbean
    #delimit ;
        gr twoway 
            (line usa_c elapsed       if elapsed<=`days', lc(green) lw(0.35) lp("-"))
            (line uk_c elapsed        if elapsed<=`days', lc(blue) lw(0.35) lp("-"))
            (line skorea_c elapsed    if elapsed<=`days' , lc(red) lw(0.35) lp("-"))
            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(7.5) xsize(10)
            
                xlab(
                    , labs(4) notick nogrid glc(gs16))
                xscale(fill noline) 
                xtitle("Days since first case", size(4) margin(l=2 r=2 t=2 b=2)) 
                
                ylab(0(10)40
                ,
                labs(4) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Cumulative Cases", size(4) margin(l=2 r=2 t=2 b=2)) 
                ymtick(0(5)40)


                legend(size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                order(1 2 3) 
                lab(1 "USA") 
                lab(2 "UK") 
                lab(3 "South Korea") 
                )
                name(trajectory_001) 
                ;
        #delimit cr
graph export "`outputpath'/04_TechDocs/trajectory_001.png", replace width(4000)




** With BARBADOS
    #delimit ;
        gr twoway 
            (line usa_c elapsed       if elapsed<=`days', lc(green%20) lw(0.35) lp("-"))
            (line uk_c elapsed        if elapsed<=`days', lc(blue%20) lw(0.35) lp("-"))
            (line skorea_c elapsed    if elapsed<=`days' , lc(red%20) lw(0.35) lp("-"))
           (line jam_c elapsed       if elapsed<=`days', lc(gs0) lw(0.35) lp("-"))
            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(7.5) xsize(10)
            
                xlab(
                    , labs(4) notick nogrid glc(gs16))
                xscale(fill noline) 
                xtitle("Days since first case", size(4) margin(l=2 r=2 t=2 b=2)) 
                
                ylab(0(10)40
                ,
                labs(4) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Cumulative # of Cases", size(4) margin(l=2 r=2 t=2 b=2)) 
                ymtick(0(5)40)


                legend(size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                order(1 2 3 4) 
                lab(1 "USA") 
                lab(2 "UK") 
                lab(3 "South Korea") 
                lab(4 "Jamaica") 
                )
                name(trajectory_002) 
                ;
        #delimit cr
graph export "`outputpath'/04_TechDocs/trajectory_002.png", replace width(4000)


** With BARBADOS and JAMAICA
    #delimit ;
        gr twoway 
            (line usa_c elapsed       if elapsed<=`days', lc(green%20) lw(0.35) lp("-"))
            (line uk_c elapsed        if elapsed<=`days', lc(blue%20) lw(0.35) lp("-"))
            (line skorea_c elapsed    if elapsed<=`days' , lc(red%20) lw(0.35) lp("-"))
           (line jam_c elapsed       if elapsed<=`days', lc(gs0%20) lw(0.35) lp("-"))
           (line bar_c elapsed       if elapsed<=`days', lc(gs0) lw(0.35) lp("-"))
            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(7.5) xsize(10)
            
                xlab(
                    , labs(4) notick nogrid glc(gs16))
                xscale(fill noline) 
                xtitle("Days since first case", size(4) margin(l=2 r=2 t=2 b=2)) 
                
                ylab(0(10)40
                ,
                labs(4) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Cumulative # of Cases", size(4) margin(l=2 r=2 t=2 b=2)) 
                ymtick(0(5)40)


                legend(size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                order(1 2 3 4 5) 
                lab(1 "USA") 
                lab(2 "UK") 
                lab(3 "South Korea") 
                lab(4 "Jamaica") 
                lab(5 "Barbados") 
                )
                name(trajectory_003) 
                ;
        #delimit cr
graph export "`outputpath'/04_TechDocs/trajectory_003.png", replace width(4000)


** Days since first Barbados case
local days_bb = 15

** With BARBADOS only
    #delimit ;
        gr twoway 
            (line usa_c elapsed       if elapsed<=`days_bb', lc(green%20) lw(0.35) lp("-"))
            (line uk_c elapsed        if elapsed<=`days_bb', lc(blue%20) lw(0.35) lp("-"))
            (line skorea_c elapsed    if elapsed<=`days_bb' , lc(red%20) lw(0.35) lp("-"))
           (line bar_c elapsed       if elapsed<=`days_bb', lc(gs0) lw(0.35) lp("-"))
            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(7.5) xsize(10)
            
                xlab(
                    , labs(4) notick nogrid glc(gs16))
                xscale(fill noline) 
                xtitle("Days since first case", size(4) margin(l=2 r=2 t=2 b=2)) 
                
                ylab(0(10)40
                ,
                labs(4) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Cumulative # of Cases", size(4) margin(l=2 r=2 t=2 b=2)) 
                ymtick(0(5)40)


                legend(size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                order(1 2 3 4 5) 
                lab(1 "USA") 
                lab(2 "UK") 
                lab(3 "South Korea") 
                lab(4 "Barbados") 
                )
                name(trajectory_004) 
                ;
        #delimit cr
graph export "`outputpath'/04_TechDocs/trajectory_004.png", replace width(4000)


*! CHANGE THESE ENTRIES FOR EACH COUNTRY FOR PDF REPORT CREATION
*! -------------------------------------------------------------
local pop = "287,371"
local over70 = "32,963" 
local acutebeds = 240
local icubeds = 40
local country = "Barbados"
local date = "30 March 2020"
*! -------------------------------------------------------------


** ------------------------------------------------------
** PDF COUNTRY REPORT
** ------------------------------------------------------
putpdf begin, pagesize(letter) font("Calibri Light", 10) margin(top,1cm) margin(bottom,0.5cm) margin(left,1cm) margin(right,0.5cm)

** TITLE, ATTRIBUTION, DATE of CREATION
putpdf paragraph ,  font("Calibri Light", 12)
putpdf text ("COVID-19 trajectory for `country'"), bold linebreak
putpdf paragraph ,  font("Calibri Light", 9)
putpdf text ("Briefing created by staff of the George Alleyne Chronic Disease Research Centre and the Public Health Group of The Faculty of Medical Sciences, Cave Hill Campus, The University of the West Indies"), linebreak
putpdf text ("Contact Ian Hambleton (ian.hambleton@cavehill.uwi.edu) for details of quantitative analyses"), font("Calibri Light", 9) linebreak italic
putpdf text ("Contact Maddy Murphy (madhuvanti.murphy@cavehill.uwi.edu) for details of national public health interventions"), font("Calibri Light", 9) italic linebreak
putpdf text ("Creation date: `date'"), font("Calibri Light", 9) bold italic linebreak

** INTRODUCTION
putpdf paragraph ,  font("Calibri Light", 10)
putpdf text ("Aim of this briefing. ") , bold
putpdf text ("We present the cumulative number of confirmed cases of COVID-19 infection in Barbados since the start of the outbreak, which ") 
putpdf text ("we measure as the number of days since the first confirmed case. We compare the Barbados trajectory with selected countries ") 
putpdf text ("further along the epidemic curve. This allows us to assess progress in reducing COVID-19 transmission ") 
putpdf text ("compared to interventions in other countries. Epidemic progress is likely to vary markedly between countries, ") 
putpdf text ("and this graphic is presented as a guide only. "), linebreak 

** FIGURE OF COVID-19 trajectory
putpdf text (" "), linebreak
putpdf text ("Figure."), bold
putpdf text (" Cumulative cases in `country' as of `date'"), linebreak
putpdf table f1 = (1,2), border(all,nil) halign(center)
putpdf table f1(1,1)=image("`outputpath'/04_TechDocs/trajectory_004.png")
putpdf table f1(1,2)=(" "), halign(center)  

** Save the PDF
putpdf save "`outputpath'/05_Outputs/covid19_trajectory_BRB", replace
