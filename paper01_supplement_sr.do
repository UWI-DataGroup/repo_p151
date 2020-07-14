** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					paper01_supplement.do
    //  project:				        
    //  analysts:				       	Ian HAMBLETON
    // 	date last modified	            17-APR-2020
    //  algorithm task			        Initial cleaning of JHopkns download

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
    log using "`logpath'\paper01_supplement", replace
** HEADER -----------------------------------------------------

** -----------------------------------------
** Pre-Load the COVID metrics --> as Global Macros
** -----------------------------------------
qui do "`logpath'\paper01_04metrics"
** -----------------------------------------

** Close any open log file and open a new log file
capture log close
log using "`logpath'\paper01_supplement", replace

** Attack Rate (per 1,000 --> not yet used)
gen confirmed_rate = (confirmed / pop) * 10000
** Fix --> Single Montserrat value 
replace confirmed = 5 if confirmed==0 & iso_num==22 & date==d(01apr2020)

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
                        iso=="HKG" | iso=="ISL" | iso=="NZL"
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


** -----------------------------------------
** Use the FULL PAPER01 dataset
** -----------------------------------------
use "`datapath'\version02\2-working\paper01_acaps_sr", clear



** DATE OF FIRST CASE 
gen dofc1 = c(current_date)
gen dofc = date(dofc1, "DMY") 
format dofc %td
drop dofc1 
** Will need to add UKOTS in time
local clist = "ATG BHS BRB BLZ DOM HTI JAM TTO DEU ITA NZL SGP KOR SWE GBR VNM" 
foreach country of local clist {
    replace dofc = dofc - ${m05_`country'} + 1 if iso=="`country'"
    }

** DATE OF FIRST NPI, by COUNTRY and by NPI group
bysort iso mnpi : egen npi1 = min(donpi)
format npi1 %td

** Global macros for ALL MINIMUM and MAXIMUM dates
local clist = "ATG BHS BRB BLZ DOM HTI JAM TTO DEU ITA NZL SGP KOR SWE GBR VNM" 
foreach country of local clist {
    forval x = 1(1)3 {
        sort iso mnpi 
        gen d1 = donpi if iso=="`country'" & mnpi==`x'
        egen d2 = min(d1)
        global min_`country'`x' = d2
        egen d3 = max(d1)
        global max_`country'`x' = d3
        global dif_`country'`x'
        drop d1 d2 d3
        }
    }


** Date of Curfew
sort iso mnpi donpi 
gen docurf1 = donpi if snpi==5 & yn_npi==1
by iso : egen docurf = min(docurf1)
format docurf %td
gen curfi1 = 0
replace curfi1 = 1 if snpi==5 & yn_npi==1
by iso : egen curfi = max(curfi1)
label define curfi_ 0 "no curfew" 1 "curfew"
label values curfi curfi_ 
drop docurf1 curfi1

** Date of PARTIAL lockdown
sort iso mnpi donpi 
gen doplock1 = donpi if snpi==6 & yn_npi==1
by iso : egen doplock = min(doplock1)
format doplock %td
gen plocki1 = 0
replace plocki1 = 1 if snpi==6 & yn_npi==1
by iso : egen plocki = max(plocki1)
label define plocki_ 0 "no partial lockdown" 1 "partial lockdown"
label values plocki plocki_ 
drop doplock1 plocki1

** Date of FULL lockdown
sort iso mnpi donpi 
gen doflock1 = donpi if snpi==7 & yn_npi==1
by iso : egen doflock = min(doflock1)
format doflock %td
gen flocki1 = 0
replace flocki1 = 1 if snpi==7 & yn_npi==1
by iso : egen flocki = max(flocki1)
label define flocki_ 0 "no full lockdown" 1 "full lockdown"
label values flocki flocki_ 
drop doflock1 flocki1

*! Alter curfewi, plocki, flocki
*! Combine plocki and flocki to locki
    ** gen manual_change = 0

    ** replace       plocki = 1 if iso=="DOM" & plocki==0       /* DOM. Partial lockdown */
    ** replace doplock = d(19mar2020) if iso=="DOM" & doplock==.      
    ** replace manual_change = 1 if iso=="DOM" 

    ** replace       flocki = 1 if iso=="GUY" & flocki==0       /* GUY. Full lockdown */
    ** replace doflock = d(9apr2020) if iso=="GUY" & doflock==.      
    ** replace manual_change = 1 if iso=="GUY" 

    ** replace       plocki = 0 if iso=="NZL" & plocki==1       /* NZL. NO partial lockdown. Only FULL lockdown */
    ** replace doplock = . if iso=="NZL" & doplock<.      
    ** replace manual_change = 1 if iso=="NZL" 

*! Date corrections
    ** replace docurf = d(28mar2020) if iso=="BRB" & curfi==1 & docurf==d(3apr2020)
    ** replace doplock = d(3apr2020) if iso=="BRB" & plocki==1 & doplock==d(26mar2020)
    ** replace docurf = d(2apr2020) if iso=="BLZ" & curfi==1 & docurf==d(7apr2020)
    ** replace docurf = d(25mar2020) if iso=="GUY" & curfi==1 & docurf==d(11apr2020)
    ** replace doflock = d(25mar2020) if iso=="NZL" & flocki==1 & doflock==d(20apr2020)

** Finally - merge partial and full lockdown 
egen locki = rowmax(plocki flocki) 
egen dolock = rowmin(doplock doflock)

** CURFEW / LOCKDOWN DATES
replace doplock = doplock+1 if doplock == docurf
replace doflock = doflock+1 if doflock == docurf
replace doflock = doflock+1 if doflock == doplock

local clist = "ATG BHS BRB BLZ DOM HTI JAM TTO DEU ITA NZL SGP KOR SWE GBR VNM" 
foreach country of local clist {
        gen d1 = docurf if iso=="`country'"
        egen d2 = min(d1)
        global curfew_`country' = d2

        gen d3 = doplock if iso=="`country'"
        egen d4 = min(d3)
        global plock_`country' = d4

        gen d5 = doflock if iso=="`country'"
        egen d6 = min(d5)
        global flock_`country' = d6

        gen d7 = dolock if iso=="`country'"
        egen d8 = min(d7)
        global lock_`country' = d8

        drop d1 d2 d3 d4 d5 d6 d7 d8
        }


** -----------------------------------------------------------
** GOOGLE MOVEMENT DATA
** -----------------------------------------------------------
** BAR CHARTS - per country - long and thin
** -----------------------------------------------------------

use "`datapath'\version02\2-working\paper01_google", clear
egen movement = rowmean(orig_retail orig_grocery orig_transit orig_work)
gen home = orig_residential 

bysort iso: asrol movement , stat(mean) window(date 3) gen(movement_av3)
bysort iso: asrol home , stat(mean) window(date 3) gen(home_av3)

** Automate final date on x-axis 
** Use latest date in dataset 
egen fdate1 = max(date)
global fdate = fdate1 
global fdatef : di %tdD_m date("$S_DATE", "DMY")


** -----------------------------------------
** BAR CHART --> 
** COLORS:  NPIs                --> SFSO greens
**          MOVEMENT            --> 
**          CASES / DEATHS      -->
**
**
** colorpalette Blues
** colorpalette Oranges
** colorpalette Purples
** -----------------------------------------

local clist = "ATG BHS BRB BLZ DOM HTI JAM TTO DEU ITA NZL SGP KOR SWE GBR VNM" 
///local clist = "ATG BHS BRB" 
///local clist = "ATG" 
foreach iso of local clist {

preserve 
    keep if iso=="`iso'"
    keep if _n==1
    global country = country 
restore

#delimit ;
    graph twoway
    (bar movement date if movement>0 & iso=="`iso'", color("247 146 114")  barw(0.75))
    (bar movement date if movement<=0 & iso=="`iso'", color("151 194 221") barw(0.75))
    /// Curfew 
    (scatteri 30 ${curfew_`iso'} , msize(12) mlc(gs0%50) mfcolor("254 232 172"))
    /// Full lockdown
    (scatteri 30 ${flock_`iso'} ,msize(12) mlc(gs0%50) mfcolor("128 125 186%50"))
    /// Partial lockdown
    (scatteri 30 ${plock_`iso'} ,msize(12) mlc(gs0%50) mfcolor("241 105 19%50"))

    ,   
    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
    ysize(3) xsize(15)

    ylab(-100(40)100
    , labs(7) notick nogrid glc(gs16) angle(0))
    yscale(fill noline) 
    ytitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 

    xlab(
            21964 "19 Feb" 
            21974 "29 Feb" 
            21984 "10 Mar" 
            21994 "20 Mar" 
            22004 "30 Mar" 
            22015 "10 Apr"
            22025 "20 Apr"
            22035 "30 Apr"
            22045 "10 May"
    , labs(7) nogrid glc(gs16) angle(45) format(%9.0f))
    xtitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 
    xscale(noline) 

    title("$country", pos(11) ring(1) size(9))

    legend(size(7) position(3) ring(5) colf cols(1) lc(gs16)
    region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
    sub("", size(2.75)) order(3 5 4)
    lab(3 "Curfew")
    lab(4 "Full Lockdown")
    lab(5 "Partial Lockdown")
    )
    name(movement_`iso') 
    ;
#delimit cr
graph export "`outputpath'/04_TechDocs/movement_`iso'_paper1.png", replace width(4000)
}



** ------------------------------------------------------
** PDF - MOVEMENT DATA
** ------------------------------------------------------
    putpdf begin, pagesize(letter) landscape font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.25cm) margin(left,0.5cm) margin(right,0.25cm)

** PAGE 1. TITLE, ATTRIBUTION, DATE of CREATION
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("Supplement 1. "), bold font("Calibri Light", 13, 000000)
    putpdf table intro2(1,2)=("Changes in community movement and dates of national curfews and lockdowns among 8 Caribbean countries and 8 comparator countries."), append halign(left) linebreak font("Calibri Light", 13, 000000)
    ** putpdf table intro2(1,2)=("(Created on: $S_DATE)"), halign(left) append  font("Calibri Light", 11, 000000) 
    putpdf table intro2(1,16)=("Page 1 of 6"), halign(right)  font("Calibri Light", 11, 8c8c8c) linebreak
    putpdf table intro2(1,16)=("Created: 27-May-2020"), halign(right)  font("Calibri Light", 11, 8c8c8c) append

** FIGURES - ANTIGUA, BAHAMAS, BARBADOS 
    putpdf table f2 = (6,1), width(85%) border(all,nil) halign(center)
    putpdf table f2(1,1)=image("`outputpath'/04_TechDocs/movement_ATG_paper1.png")
    putpdf table f2(2,1)=("Country Note: "), bold font("Calibri Light", 10, 8c8c8c)
    putpdf table f2(2,1)=("Antigua and Barbuda saw its largest 1-day reduction in movement on 2-Apr-2020, on the first day of a full national lockdown."), append font("Calibri Light", 10, 8c8c8c)
    putpdf table f2(3,1)=image("`outputpath'/04_TechDocs/movement_BHS_paper1.png")
    putpdf table f2(4,1)=("Country Note: "), bold font("Calibri Light", 10, 8c8c8c)
    putpdf table f2(4,1)=("Bahamas saw larger movement reductions over the Easter weekend (10-13th Apr), and coinciding with weekends generally."), append font("Calibri Light", 10, 8c8c8c)
    putpdf table f2(5,1)=image("`outputpath'/04_TechDocs/movement_BRB_paper1.png")
    putpdf table f2(6,1)=("Country Note: "), bold font("Calibri Light", 10, 8c8c8c)
    putpdf table f2(6,1)=("Barbados saw two major reductions in movement. The first on 29-Mar-2020 coinciding with a national curfew and the second on 4-Apr-2020 coinciding with a full national lockdown."), append font("Calibri Light", 10, 8c8c8c)


** PAGE 2. FIGURES - BELIZE, DOMINICAN REPUBLIC, HAITI
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("Supplement 1. "), bold font("Calibri Light", 13, 000000)
    putpdf table intro2(1,2)=("Changes in community movement and dates of national curfews and lockdowns among 8 Caribbean countries and 8 comparator countries."), append halign(left) linebreak font("Calibri Light", 13, 000000)
    ** putpdf table intro2(1,2)=("(Created on: $S_DATE)"), halign(left) append  font("Calibri Light", 11, 000000) 
    putpdf table intro2(1,16)=("Page 2 of 6"), halign(right)  font("Calibri Light", 11, 8c8c8c) linebreak
    putpdf table intro2(1,16)=("Created: 27-May-2020"), halign(right)  font("Calibri Light", 11, 8c8c8c) append

    putpdf table f3 = (6,1), width(85%) border(all,nil) halign(center)
    putpdf table f3(1,1)=image("`outputpath'/04_TechDocs/movement_BLZ_paper1.png")
    putpdf table f3(2,1)=("Country Note: "), bold font("Calibri Light", 10, 8c8c8c)
    putpdf table f3(2,1)=("Belize saw gentle reductions over 6-days following a partial lockdown on 23-Mar-2020, and a small additional drop in mobility on 2-Apr following a national curfew order."), append font("Calibri Light", 10, 8c8c8c)
    putpdf table f3(3,1)=image("`outputpath'/04_TechDocs/movement_DOM_paper1.png")
    putpdf table f3(4,1)=("Country Note: "), bold font("Calibri Light", 10, 8c8c8c)
    putpdf table f3(4,1)=("The Dominican Republic initiated a national curfew on 20-Mar-2020, which contributed to an initialy sharp, then more gentle reduction in mobility between 19th and 27th March."), append font("Calibri Light", 10, 8c8c8c)
    putpdf table f3(5,1)=image("`outputpath'/04_TechDocs/movement_HTI_paper1.png")
    putpdf table f3(6,1)=("Country Note: "), bold font("Calibri Light", 10, 8c8c8c)
    putpdf table f3(6,1)=("Haiti initiated a national curfew and lockdown on 20-Mar-2020 and saw only modest reductions in movement."), append font("Calibri Light", 10, 8c8c8c)

** PAGE 3. FIGURES - JAMAICA, TRINIDAD, GERMANY
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("Supplement 1. "), bold font("Calibri Light", 13, 000000)
    putpdf table intro2(1,2)=("Changes in community movement and dates of national curfews and lockdowns among 8 Caribbean countries and 8 comparator countries."), append halign(left) linebreak font("Calibri Light", 13, 000000)
    ** putpdf table intro2(1,2)=("(Created on: $S_DATE)"), halign(left) append  font("Calibri Light", 11, 000000) 
    putpdf table intro2(1,16)=("Page 3 of 6"), halign(right)  font("Calibri Light", 11, 8c8c8c) linebreak
    putpdf table intro2(1,16)=("Created: 27-May-2020"), halign(right)  font("Calibri Light", 11, 8c8c8c) append

    putpdf table f3 = (6,1), width(85%) border(all,nil) halign(center)
    putpdf table f3(1,1)=image("`outputpath'/04_TechDocs/movement_JAM_paper1.png")
    putpdf table f3(2,1)=("Country Note: "), bold font("Calibri Light", 10, 8c8c8c)
    putpdf table f3(2,1)=("Jamaica implemented a curfew on 1-Apr-2020, and a regional lockdown (St Catherine parish) on 15-Apr. National-level movements were not materially affected by these interventions."), append font("Calibri Light", 10, 8c8c8c)
    putpdf table f3(3,1)=image("`outputpath'/04_TechDocs/movement_TTO_paper1.png")
    putpdf table f3(4,1)=("Country Note: "), bold font("Calibri Light", 10, 8c8c8c)
    putpdf table f3(4,1)=("Trinidad and Tobago initiated a full national "), append font("Calibri Light", 10, 8c8c8c)
    putpdf table f3(4,1)=("stay-at-home "), italic append font("Calibri Light", 10, 8c8c8c)
    putpdf table f3(4,1)=("order on 29-Mar-2020 and this coincided with a sharp and sustained drop in movement. "), linebreak append font("Calibri Light", 10, 8c8c8c)
    putpdf table f3(4,1)=("Particularly large movement reductions on 30-Mar, 10-Apr and 13-Apr were associated with national holidays."), append font("Calibri Light", 10, 8c8c8c) 
    putpdf table f3(5,1)=image("`outputpath'/04_TechDocs/movement_DEU_paper1.png")
    putpdf table f3(6,1)=("Country Note: "), bold font("Calibri Light", 10, 8c8c8c)
    putpdf table f3(6,1)=("On the 16th and 21st March 2020 Germany initiated regional measures to restrict movement (Bavaria). These coincided with a gentle reduction in national movement between 17th and 22nd March."), append font("Calibri Light", 10, 8c8c8c)

** PAGE 4. FIGURES - ITALY, NEW ZEALAND, SINGAPORE
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("Supplement 1. "), bold font("Calibri Light", 13, 000000)
    putpdf table intro2(1,2)=("Changes in community movement and dates of national curfews and lockdowns among 8 Caribbean countries and 8 comparator countries."), append halign(left) linebreak font("Calibri Light", 13, 000000)
    ** putpdf table intro2(1,2)=("(Created on: $S_DATE)"), halign(left) append  font("Calibri Light", 11, 000000) 
    putpdf table intro2(1,16)=("Page 4 of 6"), halign(right)  font("Calibri Light", 11, 8c8c8c) linebreak
    putpdf table intro2(1,16)=("Created: 27-May-2020"), halign(right)  font("Calibri Light", 11, 8c8c8c) append

    putpdf table f3 = (6,1), width(85%) border(all,nil) halign(center)
    putpdf table f3(1,1)=image("`outputpath'/04_TechDocs/movement_ITA_paper1.png")
    putpdf table f3(2,1)=("Country Note: "), bold font("Calibri Light", 10, 8c8c8c)
    putpdf table f3(2,1)=("Italy initiated a regional lockdown on 22-Feb-2020 (Lombardy, Veneto) and a national lockdown on 9-Mar. After the national lockdown there was a gentle fall in movement between 10th and 16th March."), append font("Calibri Light", 10, 8c8c8c)
    putpdf table f3(3,1)=image("`outputpath'/04_TechDocs/movement_NZL_paper1.png")
    putpdf table f3(4,1)=("Country Note: "), bold font("Calibri Light", 10, 8c8c8c)
    putpdf table f3(4,1)=("New Zealand initiated a full national lockdown on 25-Mar-2020, and saw a sharp and sustained fall in national movement."), append font("Calibri Light", 10, 8c8c8c)
    putpdf table f3(5,1)=image("`outputpath'/04_TechDocs/movement_SGP_paper1.png")
    putpdf table f3(6,1)=("Country Note: "), bold font("Calibri Light", 10, 8c8c8c)
    putpdf table f3(6,1)=("Singapore announced in early April a stringent set of preventive measures collectively called a "), append font("Calibri Light", 10, 8c8c8c)
    putpdf table f3(6,1)=("circuit breaker"), italic append font("Calibri Light", 10, 8c8c8c)
    putpdf table f3(6,1)=(". Movement fell on the day these measures were introduced."), append font("Calibri Light", 10, 8c8c8c)
    
** PAGE 5. FIGURES - SOUTH KOREA, SWEDEN, UNITED KINGDOM
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("Supplement 1. "), bold font("Calibri Light", 13, 000000)
    putpdf table intro2(1,2)=("Changes in community movement and dates of national curfews and lockdowns among 8 Caribbean countries and 8 comparator countries."), append halign(left) linebreak font("Calibri Light", 13, 000000)
    ** putpdf table intro2(1,2)=("(Created on: $S_DATE)"), halign(left) append  font("Calibri Light", 11, 000000) 
    putpdf table intro2(1,16)=("Page 5 of 6"), halign(right)  font("Calibri Light", 11, 8c8c8c) linebreak
    putpdf table intro2(1,16)=("Created: 27-May-2020"), halign(right)  font("Calibri Light", 11, 8c8c8c) append

    putpdf table f3 = (6,1), width(85%) border(all,nil) halign(center)
    putpdf table f3(1,1)=image("`outputpath'/04_TechDocs/movement_KOR_paper1.png")
    putpdf table f3(2,1)=("Country Note: "), bold font("Calibri Light", 10, 8c8c8c)
    putpdf table f3(2,1)=("South Korea implemented a partial lockdown on 22-Mar-2020 with the closure of some public facilities. Movement reductions were minimal. "), append font("Calibri Light", 10, 8c8c8c)
    putpdf table f3(2,1)=("The early onset of the outbreak in South Korea may mean that national movement was already reduced during the comparator period (Jan and Feb 2020). "), append font("Calibri Light", 10, 8c8c8c)
    putpdf table f3(3,1)=image("`outputpath'/04_TechDocs/movement_SWE_paper1.png")
    putpdf table f3(4,1)=("Country Note: "), bold font("Calibri Light", 10, 8c8c8c)
    putpdf table f3(4,1)=("Sweden has introduced very few national controls on movement. National movement reductions have been minimal."), append font("Calibri Light", 10, 8c8c8c)
    putpdf table f3(5,1)=image("`outputpath'/04_TechDocs/movement_GBR_paper1.png")
    putpdf table f3(6,1)=("Country Note: "), bold font("Calibri Light", 10, 8c8c8c)
    putpdf table f3(6,1)=("The UK initiated a partial lockdown on 16-Mar-2020, and a more formal " ), append font("Calibri Light", 10, 8c8c8c)
    putpdf table f3(6,1)=("stay-at-home"), italic append font("Calibri Light", 10, 8c8c8c) 
    putpdf table f3(6,1)=(" order on 23-Mar. National movement fell gently between 17th and 29th March."), append font("Calibri Light", 10, 8c8c8c)
    

** PAGE 6. FIGURES - VIETNAM
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("Supplement 1. "), bold font("Calibri Light", 13, 000000)
    putpdf table intro2(1,2)=("Changes in community movement and dates of national curfews and lockdowns among 8 Caribbean countries and 8 comparator countries."), append halign(left) linebreak font("Calibri Light", 13, 000000)
    ** putpdf table intro2(1,2)=("(Created on: $S_DATE)"), halign(left) append  font("Calibri Light", 11, 000000) 
    putpdf table intro2(1,16)=("Page 6 of 6"), halign(right)  font("Calibri Light", 11, 8c8c8c) linebreak
    putpdf table intro2(1,16)=("Created: 27-May-2020"), halign(right)  font("Calibri Light", 11, 8c8c8c) append

    putpdf table f3 = (12,1), width(85%) border(all,nil) halign(center)
    putpdf table f3(1,1)=image("`outputpath'/04_TechDocs/movement_VNM_paper1.png")
    putpdf table f3(2,1)=("Country Note: "), bold font("Calibri Light", 10, 8c8c8c)
    putpdf table f3(2,1)=("Vietnam introduced a partial lockdown on 13-Feb-2020 and a national lockdown on 1-Apr."), append font("Calibri Light", 10, 8c8c8c)
    putpdf table f3(2,1)=("The early onset of the outbreak in Vietnam may mean that national movement was already reduced during the comparator period (Jan and Feb 2020). "), append font("Calibri Light", 10, 8c8c8c)

** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    putpdf save "`outputpath'/05_Outputs_Papers/01_NPIs_progressreport/supplement_covid19_movement_`date_string'", replace
    

