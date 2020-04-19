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
            (bar deaths elapsed if iso=="`country'" & elapsed<=`elapsed', col("255 158 131"))
            (line confirmed_av3 elapsed if iso=="`country'" & elapsed<=`elapsed', lc("14 73 124") lw(0.4) lp("-"))
            (scat confirmed_av3 elapsed if iso=="`country'" & elapsed<=`elapsed', msize(2.5) mc("14 73 124") m(o))
            (line deaths_av3 elapsed if iso=="`country'" & elapsed<=`elapsed', lc("124 10 7") lw(0.4) lp("-"))
            (scat deaths_av3 elapsed if iso=="`country'" & elapsed<=`elapsed', msize(2.5) mc("124 10 7") m(o)

            )
            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(5) xsize(14)
            
            xlab(
            , labs(6) nogrid glc(gs16) angle(0) format(%9.0f))
            xtitle("Days since first case", size(6) margin(l=2 r=2 t=2 b=2)) 
                
            ylab(
            , labs(6) notick nogrid glc(gs16) angle(0))
            yscale(fill noline range(0(1)14)) 
            ytitle("Cumulative # of Cases", size(6) margin(l=2 r=2 t=2 b=2)) 
            
            ///title("(1) Cumulative cases in `country'", pos(11) ring(1) size(4))

            legend(off size(6) position(5) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                )
                name(bar_`country') 
                ;
        #delimit cr
        graph export "`outputpath'/04_TechDocs/bar_`country'_$S_DATE.png", replace width(6000)

** LINE CHART (LOGARITHM)
    #delimit ;
        gr twoway             
            (line confirmed elapsed if iso=="USA" & elapsed<=`elapsed', lc(green%40) lw(0.35) lp("-"))
            (line confirmed elapsed if iso=="GBR" & elapsed<=`elapsed', lc(orange%40) lw(0.35) lp("-"))
            (line confirmed elapsed if iso=="SGP" & elapsed<=`elapsed', lc(purple%40) lw(0.35) lp("-"))
            (line confirmed elapsed if iso=="`country'" & elapsed<=`elapsed', lc("14 73 124") lw(0.4) lp("-"))
            (scat confirmed elapsed if iso=="`country'" & elapsed<=`elapsed', msize(2.5) mc("14 73 124") m(o))
            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(5) xsize(14)
            
                xlab(
                    , labs(6) notick nogrid glc(gs16))
                xscale(fill noline) 
                xtitle("Days since first case", size(6) margin(l=2 r=2 t=2 b=2)) 
                
                ylab(
                ,
                labs(5) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Cumulative # of Cases", size(6) margin(l=2 r=2 t=2 b=2)) 
                yscale(log)

                legend(size(6) position(5) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                order(4 1 2 3) 
                lab(1 "USA") 
                lab(2 "UK") 
                lab(3 "Singapore") 
                lab(4 "`cname'")
                )
                name(line_`country') 
                ;
        #delimit cr
        graph export "`outputpath'/04_TechDocs/line_`country'_$S_DATE.png", replace width(6000)
        drop c3 c4 c5


** ------------------------------------------------------
** PDF COUNTRY REPORT
** ------------------------------------------------------
    putpdf begin, pagesize(letter) font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.25cm) margin(left,0.5cm) margin(right,0.25cm)

** TITLE, ATTRIBUTION, DATE of CREATION
    putpdf table intro = (1,12), width(100%) halign(left)    
    putpdf table intro(.,.), border(all, nil)
    putpdf table intro(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro(1,1)
    putpdf table intro(1,2), colspan(11)
    putpdf table intro(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro(1,2)=("COVID-19 trajectory for `cname'"), halign(left) linebreak font("Calibri Light", 12, 000000)
    putpdf table intro(1,2)=("Briefing created by staff of the George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro(1,2)=("and the Public Health Group of The Faculty of Medical Sciences, Cave Hill Campus, "), halign(left) append  
    putpdf table intro(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro(1,2)=("Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic   
    putpdf table intro(1,2)=("For all our COVID-19 surveillance outputs, go to "), halign(left) append
    putpdf table intro(1,2)=("https://tinyurl.com/uwi-covid19-surveillance "), halign(left) underline append linebreak 
    putpdf table intro(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

** INTRODUCTION
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Aim of this briefing. ") , bold
    putpdf text ("We present the cumulative number of confirmed cases and deaths ")
    putpdf text ("1"), script(super) 
    putpdf text (" from COVID-19 infection in `cname' since the start of the outbreak, which ") 
    putpdf text ("we measure as the number of days since the first confirmed case. We compare the `cname' trajectory against key comparator countries ") 
    putpdf text ("(Singapore, UK, USA), which are further along their epidemic curves. Epidemic progress is likely to vary markedly ") 
    putpdf text ("between countries, and this graphic is presented as a guide only. "), linebreak 

** TABLE: KEY SUMMARY METRICS
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

    putpdf table t1(3,2)=("${m01_`country'}"), halign(center) 
    putpdf table t1(4,2)=("${m02_`country'}"), halign(center) 
    putpdf table t1(3,3)=("${m60_`country'}"), halign(center) 
    putpdf table t1(4,3)=("${m61_`country'}"), halign(center) 
    putpdf table t1(3,4)=("${m62_`country'}"), halign(center) 
    putpdf table t1(4,4)=("${m63_`country'}"), halign(center) 
    putpdf table t1(3,5)=("${m03_`country'}"), halign(center) 
    putpdf table t1(4,5)=("${m04_`country'}"), halign(center) 
    putpdf table t1(3,6)=("${m05_`country'}"), halign(center) 
    putpdf table t1(4,6)=("${m06_`country'}"), halign(center) 

** TEXT TO ACCOMPANY FIGURE 1
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("The first graph shows the rise in the absolute numbers of cases and deaths in `cname' since the start of the outbreak. ")
    putpdf text ("It is good for assessing the extent of the COVID-19 burden, when thinking about healthcare demand for example. ")

** FIGURE 1. OF COVID-19 trajectory
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Graph."), bold
    putpdf text (" Cumulative cases and deaths in `cname' as of $S_DATE (${m05_`country'} outbreak days)"), linebreak
    putpdf table f1 = (1,1), width(76%) border(all,nil) halign(center)
    putpdf table f1(1,1)=image("`outputpath'/04_TechDocs/bar_`country'_$S_DATE.png")

** TEXT TO ACCOMPANY FIGURE 2
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("The second graph shows the number of cases on a different scale (called a logarithm scale). It shows us the ")
    putpdf text ("growth rate "), italic
    putpdf text ("over time, and is good for comparing progress against other countries. ")

** FIGURE 2. OF COVID-19 trajectory
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Graph."), bold
    putpdf text (" Cumulative cases in `cname' as of $S_DATE, with international comparisons"), linebreak
    putpdf table f2 = (1,1), width(76%) border(all,nil) halign(center)
    putpdf table f2(1,1)=image("`outputpath'/04_TechDocs/line_`country'_$S_DATE.png")

** DATA REFERENCE
    putpdf table p3 = (1,1), width(100%) halign(center) 
    putpdf table p3(1,1), font("Calibri Light", 8) border(all,nil,000000) bgcolor(ffffff)
    putpdf table p3(1,1)=("(1) Data Source. "), bold halign(left)
    putpdf table p3(1,1)=("Dong E, Du H, Gardner L. An interactive web-based dashboard to track COVID-19 "), append 
    putpdf table p3(1,1)=("in real time. Lancet Infect Dis; published online Feb 19. https://doi.org/10.1016/S1473-3099(20)30120-1"), append

** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    putpdf save "`outputpath'/05_Outputs/covid19_trajectory_`country'_version2_`date_string'", replace

}
