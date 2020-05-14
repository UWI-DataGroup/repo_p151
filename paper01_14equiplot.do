** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					paper01_14fig5.do
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
    log using "`logpath'\paper01_14fig5", replace
** HEADER -----------------------------------------------------

** -----------------------------------------
** Pre-Load the COVID metrics --> as Global Macros
** -----------------------------------------
qui do "`logpath'\paper01_04metrics"
** -----------------------------------------

** Close any open log file and open a new log file
capture log close
log using "`logpath'\paper01_14fig5", replace

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
use "`datapath'\version02\2-working\paper01_acaps", clear
drop if logtype==2

** Group 1. Control movement into country
**       1  "Additional health/documents requirements upon arrival"
**       2  "Border checks"
**       3  "Border closure"
**       4  "Complete border closure"
**       5  "Checkpoints within the country"
**       6  "International flights suspension"
**       8  "Visa restrictions"
**       14 "Health screenings in airports"

** Group 2. Control movement in country
**       7  "Domestic travel restrictions"
**       9  "Curfews"
**       32 "Partial lockdown"
**       33 "Full lockdown"

** Group 3. Control of gatherings 
**       28 "Limit public gatherings"
**       29 "Public services closure"
**       31 "Schools closure"

** Group 4. Control of infection
**       10 "Surveillance and monitoring"
**       11 "Awareness campaigns"
**       12 "Isolation and quarantine policies"
**       17 "Mass population testing"
gen npi_order = .

** additional health docs, border checks, visa restrictions, health screening
replace npi_order = 1 if imeasure==1 | imeasure==2 | imeasure==8 | imeasure==14       
replace npi_order = 2 if imeasure==3        /* border closure */
replace npi_order = 3 if imeasure==6        /* int'l flight suspension */

** Chckpoints and mobility restrictions
replace npi_order = 5 if imeasure==5 | imeasure==7
replace npi_order = 6 if imeasure==9        /* curfews */
replace npi_order = 7 if imeasure==32       /* partial lockdown */
replace npi_order = 8 if imeasure==33       /* full lockdown */

replace npi_order = 10 if imeasure==28       /* limit public gatherings */
replace npi_order = 11 if imeasure==29       /* public services closure */
replace npi_order = 12 if imeasure==31       /* school closure */

replace npi_order = 14 if imeasure==10       /* surv / monitoring */
replace npi_order = 15 if imeasure==11       /* awareness campaigns */
replace npi_order = 16 if imeasure==12       /* isolation / quarantine */
replace npi_order = 17 if imeasure==17       /* mass population testing */


** DATE OF FIRST CASE 
gen dofc1 = c(current_date)
gen dofc = date(dofc1, "DMY") 
format dofc %td
drop dofc1 
** Will need to add UKOTS in time
local clist = "ATG BHS BRB BLZ CUB DMA DOM GRD GUY HTI JAM KNA LCA VCT SUR TTO DEU ISL ITA NZL SGP KOR SWE GBR VNM" 
foreach country of local clist {
    replace dofc = dofc - ${m05_`country'} + 1 if iso=="`country'"
    }

** DATE OF FIRST NPI, by COUNTRY and by NPI group
bysort iso sidcon : egen npi1 = min(donpi)
format npi1 %td

** Global macros for ALL MINIMUM and MAXIMUM dates
local clist = "ATG BHS BRB BLZ CUB DMA DOM GRD GUY HTI JAM KNA LCA VCT SUR TTO DEU ISL ITA NZL SGP KOR SWE GBR VNM" 
foreach country of local clist {
    forval x = 1(1)3 {
        sort iso sidcon 
        gen d1 = donpi if iso=="`country'" & sidcon==`x'
        egen d2 = min(d1)
        global min_`country'`x' = d2
        egen d3 = max(d1)
        global max_`country'`x' = d3
        global dif_`country'`x'
        drop d1 d2 d3
        }
    }

** CURFEW / PARTIAL LOCKDOWN / FULL LOCKDOWN DATES
replace doplock = doplock+1 if doplock == docurf
replace doflock = doflock+1 if doflock == docurf
replace doflock = doflock+1 if doflock == doplock

local clist = "ATG BHS BRB BLZ CUB DMA DOM GRD GUY HTI JAM KNA LCA VCT SUR TTO DEU ISL ITA NZL SGP KOR SWE GBR VNM" 
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

        drop d1 d2 d3 d4 d5 d6
        }


** 13-MAY-2020
    ** New numeric running from 1 to 16 (CARICOM + CUB + DOM) 
    ** IN the end, this will run from 1-22, with the inclusion of the 6 UKOTS
    **
    ** From 17-25 is the 9 additional comparator countries
    gen corder = .
    ** Caribbean
    replace corder = 1 if iso=="ATG"
    replace corder = 2 if iso=="BHS"       
    replace corder = 3 if iso=="BRB"      
    replace corder = 4 if iso=="BLZ"       
    replace corder = 5 if iso=="CUB"       
    replace corder = 6 if iso=="DMA"       
    replace corder = 7 if iso=="DOM"       
    replace corder = 8 if iso=="GRD"       
    replace corder = 9 if iso=="GUY"      
    replace corder = 10 if iso=="HTI"      
    replace corder = 11 if iso=="JAM"      
    replace corder = 12 if iso=="KNA"      
    replace corder = 13 if iso=="LCA"      
    replace corder = 14 if iso=="VCT"      
    replace corder = 15 if iso=="SUR"     
    replace corder = 16 if iso=="TTO"     
    ** comparators
    replace corder = 18 if iso=="DEU"      /* Germany*/
    replace corder = 19 if iso=="ISL"      /* Iceland*/
    replace corder = 20 if iso=="ITA"      /* Italy */
    replace corder = 21 if iso=="NZL"      /* New Zealand */
    replace corder = 22 if iso=="SGP"      /* Singapore */
    replace corder = 23 if iso=="KOR"      /* South Korea */
    replace corder = 24 if iso=="SWE"      /* Sweden */
    replace corder = 25 if iso=="GBR"      /* United Kingdom*/
    replace corder = 26 if iso=="VNM"      /* Vietnam */

** Automate final date on x-axis 
** Use latest date in dataset 
egen fdate1 = max(donpi)
global fdate = fdate1 
global fdatef : di %tdD_m date("$S_DATE", "DMY")

** EQUIPLOT 
** CURFEW AND LOCKDOWN TIMINGS
** colorpalette sfso, purple
** colorpalette sfso, blue
** colorpalette sfso, turquoise

** Min Date
egen dmin = rowmin(docurf doplock doflock)
egen dmax = rowmax(docurf doplock doflock)

#delimit ;
	gr twoway
		/// Line between min and max
		(rspike dmin dmax corder , hor lc(gs12) lw(0.35))
		/// Partial Lockdown
		(sc corder doplock ,             msize(3.5) m(o) mlc(gs0) mfc("191 100 166") mlw(0.1))
		/// Curfew
		(sc corder docurf , 			    msize(3.5) m(o) mlc(gs0%25) mfc("132 151 207%25") mlw(0.1))
		/// Full lockdown
		(sc corder doflock  , 				msize(3.5) m(o) mlc(gs0%50) mfc("149 198 195%50") mlw(0.1))
		,
            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            ysize(8) xsize(6)

			xlab(
            21974 "29 Feb" 
            21989 "15 Mar" 
            22004 "30 Mar" 
            22020 "15 Apr"
            22035 "30 Apr"
                , labs(3) tlc(gs0) labc(gs0) nogrid glc(gs16))
			xscale(fill range(`range') lc(gs0))
			xtitle("", size(3) color(gs0) margin(l=2 r=2 t=5 b=2))
			///xmtick(0(5)50, tlc(gs0))

			ylab(
                1 "Antigua and Barbuda" 
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
                12 "St Kitts and Nevis"
                13 "St Lucia"
                14 "St Vincent"
                15 "Suriname"
                16 "Trinidad and Tobago"
                18 "Germany"
                19 "Iceland"
                20 "Italy"
                21 "New Zealand"
                22 "Singapore"
                23 "South Korea"
                24 "Sweden"
                25 "United Kingdom"
                26 "Vietnam"
			,
			valuelabel labc(gs0) labs(3) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(noline lw(vthin) reverse range(0(1)13))
			ytitle("", size(3) margin(l=2 r=5 t=2 b=2))

			///text(7 0 "Men", place(e) color(gs0) size(3.5))
			///text(0 0 "Women", place(e) color(gs0) size(3.5))
			///subtitle("(A) Caribbean", pos(11) size(3.5))

			legend(size(3) position(12) ring(1) bm(t=1 b=4 l=5 r=0) colf cols(1)
			region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2))
			order(2 3 4)
			lab(3 "curfew")
			lab(2 "partial lockdown")
			lab(4 "full lockdown")
            )
            name(equiplot)
            ;
#delimit cr











