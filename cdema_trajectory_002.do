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

keep if inlist(countryregion, "Barbados", "Jamaica", "Singapore", "South Korea", "UK", "US")
collapse (sum) confirmed deaths recovered, by(date countryregion)
list date countryregion confirmed deaths recovered in -9/l, sepby(date) abbreviate(13)
encode countryregion, gen(country)
list date countryregion country in -9/l, sepby(date) abbreviate(13)
label list country
tsset country date, daily
* Add days since first reported cases
bysort country: gen elapsed = _n 
save covide19_long, replace

* reshape to wide for comparisons 
keep date country confirmed deaths recovered
bysort country : gen elapsed = _n 
drop date 
reshape wide confirmed deaths recovered, i(elapsed) j(country)
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
* labelling - SINGAPORE
rename confirmed3 sgp_c
rename deaths3 sgp_d
rename recovered3 sgp_r
label var sgp_c "Singapore cases"
label var sgp_d "Singapore deaths"
label var sgp_r "Singapore recovered"
* labelling - SOUTH KOREA 
rename confirmed4 skorea_c
rename deaths4 skorea_d
rename recovered4 skorea_r
label var skorea_c "Sth Korea cases"
label var skorea_d "Sth Korea deaths"
label var skorea_r "Sth Korea recovered"
* labelling - UK
rename confirmed5 uk_c
rename deaths5 uk_d
rename recovered5 uk_r
label var uk_c "UK cases"
label var uk_d "UK deaths"
label var uk_r "UK recovered"
* labelling - USA
rename confirmed6 usa_c
rename deaths6 usa_d
rename recovered6 usa_r
label var usa_c "USA cases"
label var usa_d "USA deaths"
label var usa_r "USA recovered"

** Days since first case
local days = 34

** CHART _ DAYS SINCE FIRST CASE 
** Without Caribbean
    #delimit ;
        gr twoway 
            (line usa_c elapsed       if elapsed<=`days', lc(green) lw(0.35) lp("-"))
            (line uk_c elapsed        if elapsed<=`days', lc(blue) lw(0.35) lp("-"))
            ///(line skorea_c elapsed    if elapsed<=`days' , lc(red) lw(0.35) lp("-"))
            (line sgp_c elapsed       if elapsed<=`days' , lc(purple) lw(0.35) lp("-"))
            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(7.5) xsize(10)
            
                xlab(
                    , labs(4) notick nogrid glc(gs16))
                xscale(fill noline) 
                xtitle("Days since first case", size(4) margin(l=2 r=2 t=2 b=2)) 
                
                ylab(
                ,
                labs(4) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Cumulative Cases", size(4) margin(l=2 r=2 t=2 b=2)) 
                ymtick(0(5)40)


                legend(size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                order(1 2 3) 
                lab(1 "USA") 
                lab(2 "UK") 
                ///lab(3 "South Korea")
                lab(3 "Singapore") 
                )
                name(trajectory_001) 
                ;
        #delimit cr




** With BARBADOS
    #delimit ;
        gr twoway 
            (line usa_c elapsed       if elapsed<=`days', lc(green%20) lw(0.35) lp("-"))
            (line uk_c elapsed        if elapsed<=`days', lc(blue%20) lw(0.35) lp("-"))
            ///(line skorea_c elapsed    if elapsed<=`days' , lc(red%20) lw(0.35) lp("-"))
            (line sgp_c elapsed       if elapsed<=`days' , lc(purple%20) lw(0.35) lp("-"))
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
                
                ylab(
                ,
                labs(4) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Cumulative # of Cases", size(4) margin(l=2 r=2 t=2 b=2)) 
                ymtick(0(5)40)


                legend(size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                order(1 2 3 4) 
                lab(1 "USA") 
                lab(2 "UK") 
                ///lab(3 "South Korea")
                lab(3 "Singapore") 
                lab(4 "Jamaica") 
                )
                name(trajectory_002) 
                ;
        #delimit cr


** With BARBADOS and JAMAICA
    #delimit ;
        gr twoway 
            (line usa_c elapsed       if elapsed<=`days', lc(green%20) lw(0.35) lp("-"))
            (line uk_c elapsed        if elapsed<=`days', lc(blue%20) lw(0.35) lp("-"))
            ///(line skorea_c elapsed    if elapsed<=`days' , lc(red%20) lw(0.35) lp("-"))
            (line sgp_c elapsed       if elapsed<=`days' , lc(purple%20) lw(0.35) lp("-"))
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
                
                ylab(
                ,
                labs(4) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Cumulative # of Cases", size(4) margin(l=2 r=2 t=2 b=2)) 
                ymtick(0(5)40)


                legend(size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                order(1 2 3 4 5) 
                lab(1 "USA") 
                lab(2 "UK") 
                ///lab(3 "South Korea") 
                lab(3 "Singapore") 
                lab(4 "Jamaica") 
                lab(5 "Barbados") 
                )
                name(trajectory_003) 
                ;
        #delimit cr

** With BARBADOS only
    #delimit ;
        gr twoway 
            (line usa_c elapsed       if elapsed<=`days', lc(green%20) lw(0.35) lp("-"))
            (line uk_c elapsed        if elapsed<=`days', lc(blue%20) lw(0.35) lp("-"))
            ///(line skorea_c elapsed    if elapsed<=`days' , lc(red%20) lw(0.35) lp("-"))
            (line sgp_c elapsed       if elapsed<=`days' , lc(purple%20) lw(0.35) lp("-"))
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
                
                ylab(
                ,
                labs(4) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Cumulative # of Cases", size(4) margin(l=2 r=2 t=2 b=2)) 
                ymtick(0(5)40)


                legend(size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                order(1 2 3 4) 
                lab(1 "USA") 
                lab(2 "UK") 
                ///lab(3 "South Korea") 
                lab(3 "Singapore") 
                lab(4 "Barbados") 
                )
                name(trajectory_004) 
                ;
        #delimit cr

