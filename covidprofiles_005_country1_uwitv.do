** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					covidprofiles_005_country1.do
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


** Scroll through multiple identical graphics
** They vary only by Caribbean country

** BY Country: Elapased time in days from first case
bysort country: egen elapsed_max = max(elapsed)

** SAVE THE FILE FOR REGIONAL WORK 
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    save "`datapath'\version01\2-working\jh_time_series_`date_string'", replace

** SMOOTHED CASES for graphic
by country: asrol confirmed , stat(mean) window(date 3) gen(confirmed_av3)
by country: asrol deaths , stat(mean) window(date 3) gen(deaths_av3)

** LOOP through N=14 CARICOM member states
local clist "ATG BHS BRB BLZ DMA GRD GUY HTI JAM KNA LCA VCT SUR TTO"
local clist "BHS JAM"

foreach country of local clist {

    ** country  = 3-character ISO name
    ** cname    = FULL country name
    ** -country- used in all loop structures
    ** -cname- used for visual display of full country name on PDF
    gen el_`country'1 = elapsed_max if iso=="`country'"
    egen el_`country'2 = min(el_`country'1) 
    local elapsed = el_`country'2
    gen c3 = country if iso=="`country'"
    label values c3 cname_
    egen c4 = min(c3)
    label values c4 cname_
    decode c4, gen(c5)
    local cname = c5



** GRAPHIC: CASES + DEATHS (Bar with line overlay)
        #delimit ;
        gr twoway 
            (bar confirmed elapsed if iso=="`country'" & elapsed<=`elapsed', col("181 215 244"))
            ///(bar deaths elapsed if iso=="`country'" & elapsed<=`elapsed', col("255 158 131"))
            (line confirmed_av3 elapsed if iso=="`country'" & elapsed<=`elapsed', lc("14 73 124") lw(0.5) lp("-"))
            (scat confirmed_av3 elapsed if iso=="`country'" & elapsed<=`elapsed', msize(2.5) mc("14 73 124") m(o)
            ///(line deaths_av3 elapsed if iso=="`country'" & elapsed<=`elapsed', lc("124 10 7") lw(0.5) lp("-"))
            ///(scat deaths_av3 elapsed if iso=="`country'" & elapsed<=`elapsed', msize(2.5) mc("124 10 7") m(o)

            )
            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(5) xsize(17)
            
            xlab(
            , labs(8) nogrid glc(gs16) angle(0) format(%9.0f))
            xtitle("Days since first case", size(8) margin(l=2 r=2 t=2 b=2)) 
            xscale(fill noline) 
                
            ylab(
            , labs(8) notick nogrid glc(gs16) angle(0))
            yscale(fill noline) 
            ytitle("Cases", size(8) margin(l=2 r=2 t=2 b=2)) 
            
            legend(off size(8) position(5) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                )
                name(bar1_`country') 
                ;
        #delimit cr



** GRAPHIC: CASES + DEATHS (Bar with line overlay)
        #delimit ;
        gr twoway 
            (bar confirmed elapsed if iso=="`country'" & elapsed<=`elapsed', col("181 215 244"))
            (bar deaths elapsed if iso=="`country'" & elapsed<=`elapsed', col("255 158 131"))
            (line confirmed_av3 elapsed if iso=="`country'" & elapsed<=`elapsed', lc("14 73 124") lw(0.5) lp("-"))
            (scat confirmed_av3 elapsed if iso=="`country'" & elapsed<=`elapsed', msize(2.5) mc("14 73 124") m(o))
            (line deaths_av3 elapsed if iso=="`country'" & elapsed<=`elapsed', lc("124 10 7") lw(0.5) lp("-"))
            (scat deaths_av3 elapsed if iso=="`country'" & elapsed<=`elapsed', msize(2.5) mc("124 10 7") m(o)

            )
            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(5) xsize(17)
            
            xlab(
            , labs(8) nogrid glc(gs16) angle(0) format(%9.0f))
            xtitle("Days since first case", size(8) margin(l=2 r=2 t=2 b=2)) 
            xscale(fill noline) 
                
            ylab(
            , labs(8) notick nogrid glc(gs16) angle(0))
            yscale(fill noline) 
            ytitle("Cases", size(8) margin(l=2 r=2 t=2 b=2)) 
            
            ///title("(1) Cumulative cases in `country'", pos(11) ring(1) size(4))

            legend(off size(8) position(5) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                )
                name(bar2_`country') 
                ;
        #delimit cr

** LINE CHART (LOGARITHM)
    #delimit ;
        gr twoway             
            (line confirmed elapsed if iso=="USA" & elapsed<=`elapsed', lc(green) lw(0.5) lp("-"))
            (line confirmed elapsed if iso=="GBR" & elapsed<=`elapsed', lc(orange) lw(0.5) lp("-"))
            (line confirmed elapsed if iso=="SGP" & elapsed<=`elapsed', lc(purple) lw(0.5) lp("-"))
            ///(line confirmed elapsed if iso=="`country'" & elapsed<=`elapsed', lc("14 73 124") lw(0.6) lp("-"))
            ///(scat confirmed elapsed if iso=="`country'" & elapsed<=`elapsed', msize(2.5) mc("14 73 124") m(o))
            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(5) xsize(17)
            
                xlab(
                    , labs(8) notick nogrid glc(gs16))
                xscale(fill noline) 
                xtitle("Days since first case", size(8) margin(l=2 r=2 t=2 b=2)) 
                
                ylab(
                ,
                labs(8) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Cases", size(8) margin(l=2 r=2 t=2 b=2)) 
                yscale(log fill off)

                legend(size(8) position(5) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                order(4 1 2 3) 
                lab(1 "USA") 
                lab(2 "UK") 
                lab(3 "Singapore") 
                lab(4 "`cname'")
                )
                name(line1_`country') 
                ;
        #delimit cr

** LINE CHART (LOGARITHM)
    #delimit ;
        gr twoway             
            (line confirmed elapsed if iso=="USA" & elapsed<=`elapsed', lc(green%25) lw(0.5) lp("-"))
            (line confirmed elapsed if iso=="GBR" & elapsed<=`elapsed', lc(orange%25) lw(0.5) lp("-"))
            (line confirmed elapsed if iso=="SGP" & elapsed<=`elapsed', lc(purple%25) lw(0.5) lp("-"))
            (line confirmed elapsed if iso=="`country'" & elapsed<=`elapsed', lc("14 73 124") lw(0.6) lp("-"))
            (scat confirmed elapsed if iso=="`country'" & elapsed<=`elapsed', msize(2.5) mc("14 73 124") m(o))
            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(5) xsize(17)
            
                xlab(
                    , labs(8) notick nogrid glc(gs16))
                xscale(fill noline) 
                xtitle("Days since first case", size(8) margin(l=2 r=2 t=2 b=2)) 
                
                ylab(
                ,
                labs(8) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Cases", size(8) margin(l=2 r=2 t=2 b=2)) 
                yscale(log fill off)

                legend(size(8) position(5) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                order(4 1 2 3) 
                lab(1 "USA") 
                lab(2 "UK") 
                lab(3 "Singapore") 
                lab(4 "`cname'")
                )
                name(line2_`country') 
                ;
        #delimit cr
     



** LINE CHART (LOGARITHM)
    #delimit ;
        gr twoway             
            (line confirmed elapsed if iso=="USA" & elapsed<=`elapsed', lc(green) lw(0.5) lp("-"))
            (line confirmed elapsed if iso=="GBR" & elapsed<=`elapsed', lc(orange) lw(0.5) lp("-"))
            (line confirmed elapsed if iso=="SGP" & elapsed<=`elapsed', lc(purple) lw(0.5) lp("-"))
            ///(line confirmed elapsed if iso=="`country'" & elapsed<=`elapsed', lc("14 73 124") lw(0.6) lp("-"))
            ///(scat confirmed elapsed if iso=="`country'" & elapsed<=`elapsed', msize(2.5) mc("14 73 124") m(o))
            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(5) xsize(12)
            
                xlab(
                    , labs(6) notick nogrid glc(gs16))
                xscale(fill noline) 
                xtitle("Days since first case", size(6) margin(l=2 r=2 t=2 b=2)) 
                
                ylab(
                ,
                labs(6) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Cases", size(6) margin(l=2 r=2 t=2 b=2)) 
                yscale(log off)

                legend(size(6) position(5) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                order(4 1 2 3) 
                lab(1 "USA") 
                lab(2 "UK") 
                lab(3 "Singapore") 
                lab(4 "`cname'")
                )
                name(line3_`country') 
                ;
        #delimit cr

** LINE CHART (LOGARITHM)
    #delimit ;
        gr twoway             
            (line confirmed elapsed if iso=="USA" & elapsed<=`elapsed', lc(green%25) lw(0.5) lp("-"))
            (line confirmed elapsed if iso=="GBR" & elapsed<=`elapsed', lc(orange%25) lw(0.5) lp("-"))
            (line confirmed elapsed if iso=="SGP" & elapsed<=`elapsed', lc(purple%25) lw(0.5) lp("-"))
            (line confirmed elapsed if iso=="`country'" & elapsed<=`elapsed', lc("14 73 124") lw(0.6) lp("-"))
            (scat confirmed elapsed if iso=="`country'" & elapsed<=`elapsed', msize(2.5) mc("14 73 124") m(o))
            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(5) xsize(12)
            
                xlab(
                    , labs(6) notick nogrid glc(gs16))
                xscale(fill noline) 
                xtitle("Days since first case", size(6) margin(l=2 r=2 t=2 b=2)) 
                
                ylab(
                ,
                labs(6) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Cases", size(6) margin(l=2 r=2 t=2 b=2)) 
                yscale(log off)

                legend(size(6) position(5) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                order(4 1 2 3) 
                lab(1 "USA") 
                lab(2 "UK") 
                lab(3 "Singapore") 
                lab(4 "`cname'")
                )
                name(line4_`country') 
                ;
        #delimit cr
     
        drop c3 c4 c5
}
