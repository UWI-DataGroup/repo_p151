** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					cdema_simulation_antigua.do
    //  project:				        COVID-19 hospitalisation estimates for Barbados
    //  analysts:				       	Ian HAMBLETON
    // 	date last modified	            24-MAR-2020

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
    log using "`logpath'\cdema_simulation_antigua", replace
** HEADER -----------------------------------------------------

** Load 100 SEIR simulations from CDC modelling

tempfile run01 run02 
import excel using "`datapath'/version01/1-input/cdc_simulation_ATG_29mar2020.xlsx", clear first sheet("run01")
rename Day day 
rename Sim#, lower
save `run01' 
import excel using "`datapath'/version01/1-input/cdc_simulation_ATG_29mar2020.xlsx", clear first sheet("run02")
rename Day day 
rename Sim# Sim#, renumber(51) sort
rename Sim#, lower
save `run02' 
use `run01'
merge 1:1 day using `run02'
drop _merge 

*! VARIABLE INPUT. CHANGE FOR EACH COUNTRY 
*! ---------------------------------------
** SIZE OF ARTIFICIAL COMMUNITY POPULATION IN SEIR MODEL
** And size of Barbados population (UN WPP, 2020 estimates)
local artsize = 2748
local popsize = 97928
*! ---------------------------------------

** Upscale artifical community to BB population
forval x = 1(1)100 {
    replace sim`x' = sim`x' * (`popsize'/`artsize')
    } 

** Summarise the 100 simulations
#delimit ; 
egen case_av = rowmean(sim1 sim2 sim3 sim4 sim5 sim6 sim7 sim8 sim9 sim10
                        sim11 sim12 sim13 sim14 sim15 sim16 sim17 sim18 sim19 sim20
                        sim21 sim22 sim23 sim24 sim25 sim26 sim27 sim28 sim29 sim30
                        sim31 sim32 sim33 sim34 sim35 sim36 sim37 sim38 sim39 sim40
                        sim41 sim42 sim43 sim44 sim45 sim46 sim47 sim48 sim49 sim50
                        sim51 sim52 sim53 sim54 sim55 sim56 sim57 sim58 sim59 sim60
                        sim61 sim62 sim63 sim64 sim65 sim66 sim67 sim68 sim69 sim70
                        sim71 sim72 sim73 sim74 sim75 sim76 sim77 sim78 sim79 sim80
                        sim81 sim82 sim83 sim84 sim85 sim86 sim87 sim88 sim89 sim90
                        sim91 sim92 sim93 sim94 sim95 sim96 sim97 sim98 sim99 sim100);
egen case_p50 = rowmedian(sim1 sim2 sim3 sim4 sim5 sim6 sim7 sim8 sim9 sim10
                        sim11 sim12 sim13 sim14 sim15 sim16 sim17 sim18 sim19 sim20
                        sim21 sim22 sim23 sim24 sim25 sim26 sim27 sim28 sim29 sim30
                        sim31 sim32 sim33 sim34 sim35 sim36 sim37 sim38 sim39 sim40
                        sim41 sim42 sim43 sim44 sim45 sim46 sim47 sim48 sim49 sim50
                        sim51 sim52 sim53 sim54 sim55 sim56 sim57 sim58 sim59 sim60
                        sim61 sim62 sim63 sim64 sim65 sim66 sim67 sim68 sim69 sim70
                        sim71 sim72 sim73 sim74 sim75 sim76 sim77 sim78 sim79 sim80
                        sim81 sim82 sim83 sim84 sim85 sim86 sim87 sim88 sim89 sim90
                        sim91 sim92 sim93 sim94 sim95 sim96 sim97 sim98 sim99 sim100);
egen case_p25 = rowpctile(sim1 sim2 sim3 sim4 sim5 sim6 sim7 sim8 sim9 sim10
                        sim11 sim12 sim13 sim14 sim15 sim16 sim17 sim18 sim19 sim20
                        sim21 sim22 sim23 sim24 sim25 sim26 sim27 sim28 sim29 sim30
                        sim31 sim32 sim33 sim34 sim35 sim36 sim37 sim38 sim39 sim40
                        sim41 sim42 sim43 sim44 sim45 sim46 sim47 sim48 sim49 sim50
                        sim51 sim52 sim53 sim54 sim55 sim56 sim57 sim58 sim59 sim60
                        sim61 sim62 sim63 sim64 sim65 sim66 sim67 sim68 sim69 sim70
                        sim71 sim72 sim73 sim74 sim75 sim76 sim77 sim78 sim79 sim80
                        sim81 sim82 sim83 sim84 sim85 sim86 sim87 sim88 sim89 sim90
                        sim91 sim92 sim93 sim94 sim95 sim96 sim97 sim98 sim99 sim100), p(25);
egen case_p75 = rowpctile(sim1 sim2 sim3 sim4 sim5 sim6 sim7 sim8 sim9 sim10
                        sim11 sim12 sim13 sim14 sim15 sim16 sim17 sim18 sim19 sim20
                        sim21 sim22 sim23 sim24 sim25 sim26 sim27 sim28 sim29 sim30
                        sim31 sim32 sim33 sim34 sim35 sim36 sim37 sim38 sim39 sim40
                        sim41 sim42 sim43 sim44 sim45 sim46 sim47 sim48 sim49 sim50
                        sim51 sim52 sim53 sim54 sim55 sim56 sim57 sim58 sim59 sim60
                        sim61 sim62 sim63 sim64 sim65 sim66 sim67 sim68 sim69 sim70
                        sim71 sim72 sim73 sim74 sim75 sim76 sim77 sim78 sim79 sim80
                        sim81 sim82 sim83 sim84 sim85 sim86 sim87 sim88 sim89 sim90
                        sim91 sim92 sim93 sim94 sim95 sim96 sim97 sim98 sim99 sim100), p(75);
#delimit cr 

** Restrict dataset to summary measures of daily infections 
keep day case_av case_p25 case_p50 case_p75 
order day case_av case_p25 case_p50 case_p75 

*! This may need updating as new probabilities of hospitalisation appear
*! Remembering though that these estimates are for the unmitigated scenario - and no country doing this now
*! For me - the symptomatic proportion is the big unknown - and can change estimates dramatically
** Down-scaling the estimates based on conditional probabilities of acute care and critical care
** Symptomatic and hospitalised proportions from
** Imperial College NPI paper:
** https://www.imperial.ac.uk/media/imperial-college/medicine/sph/ide/gida-fellowships/Imperial-College-COVID19-NPI-modelling-16-03-2020.pdf

** ACUTE CARE PROBABILITIES 
** Population proportion * symptomatic proportion * hospitalised proportion
#delimit ; 
gen phosp =  0.60 * (
            (0.149 * 0.001) +
            (0.142 * 0.003) +
            (0.152 * 0.012) +
            (0.144 * 0.032) +
            (0.142 * 0.049) +
            (0.131 * 0.102) +
            (0.082 * 0.166) +
            (0.042 * 0.243) +
            (0.017 * 0.273)
                    );
#delimit cr 
** ACUTE CARE PROBABILITIES 
** Population proportion * symptomatic proportion * hospitalised proportion * critical care proportion
#delimit ; 
gen pcrit =  0.6 * (
            (0.149 * 0.001 * 0.05) +
            (0.142 * 0.003 * 0.05) +
            (0.152 * 0.012 * 0.05) +
            (0.144 * 0.032 * 0.05) +
            (0.142 * 0.049 * 0.063) +
            (0.131 * 0.102 * 0.122) +
            (0.082 * 0.166 * 0.274) +
            (0.042 * 0.243 * 0.432) +
            (0.017 * 0.273 * 0.709)
                        );
#delimit cr 

** Smooth the median, p25 and p75 incident cases - mainly for display purposes
lpoly case_av day, at(day) gen(ninf_av) nogr
forval x = 25(25)75 {
    lpoly case_p`x' day, at(day) gen(ninf_p`x') nogr
    }

** Baseline numbers of acute and critical care = No Intervention = Un-mitigated scenario
forval x = 25(25)75 {
    gen ninf_p`x'_0 = int(ninf_p`x')
    gen nhosp_p`x'_0 = int(ninf_p`x'_0 * phosp)
    gen ncrit_p`x'_0 = int(ninf_p`x'_0 * pcrit) 
}

** Reduction in transmission. Currently calculating between 90% and 50% transmission reduction  
** Calculate the commensurate decrease in acute care and critical care 
** We make no attempt to interpret this --> role for public health
forval y = 25(25)75 {
    local k = 1 
    forval x = 0.05(0.1)0.35 {
        gen ninf_p`y'_`k' = int(ninf_p`y'_0 * `x')
        gen nhosp_p`y'_`k' = int(ninf_p`y'_`k' * phosp)
        gen ncrit_p`y'_`k' = int(ninf_p`y'_`k' * pcrit) 
        local k = `k'+1
    }
}

** Tracking hospitalisations (ACUTE CARE)
** Average stay for uncomplicated hospitalisations = 7 days
** Cumulative admissions (CIN),Cumulative discharge (COUT), and difference between the two (CDIFF)
forval y = 25(25)75 {
    forval x = 0(1)4 {
        gen cin_p`y'_`x' = sum(nhosp_p`y'_`x')
        gen cout_p`y'_`x' = sum(nhosp_p`y'_`x'[_n-7])
        replace cout_p`y'_`x' = 0 if cout_p`y'_`x' == . 
        gen cdiff_p`y'_`x' = cin_p`y'_`x' - cout_p`y'_`x'
    }
}
** Total numbers of hospitalisations (ACUTE CARE)
preserve
    gen k = 1 
    collapse (sum) nhosp_p25_0 nhosp_p50_0 nhosp_p75_0 nhosp_p25_1 nhosp_p50_1 nhosp_p75_1  ///
                     nhosp_p25_2 nhosp_p50_2 nhosp_p75_2 nhosp_p25_3 nhosp_p50_3 nhosp_p75_3    /// 
                     nhosp_p25_4 nhosp_p50_4 nhosp_p75_4, by(k) 
    local nhosp_p25_0 = nhosp_p25_0   
    local nhosp_p50_0 = nhosp_p50_0   
    local nhosp_p75_0 = nhosp_p75_0   
    local nhosp_p25_1 = nhosp_p25_1   
    local nhosp_p50_1 = nhosp_p50_1   
    local nhosp_p75_1 = nhosp_p75_1   
    local nhosp_p25_2 = nhosp_p25_2   
    local nhosp_p50_2 = nhosp_p50_2   
    local nhosp_p75_2 = nhosp_p75_2   
    local nhosp_p25_3 = nhosp_p25_3   
    local nhosp_p50_3 = nhosp_p50_3   
    local nhosp_p75_3 = nhosp_p75_3   
    local nhosp_p25_4 = nhosp_p25_4   
    local nhosp_p50_4 = nhosp_p50_4   
    local nhosp_p75_4 = nhosp_p75_4   
restore 


** Peak hospital beds required (ACUTE CARE)
forval y = 25(25)75 {
    forval x = 0(1)4 {
        egen peakhosp_p`y'_`x' = max(cdiff_p`y'_`x')  
    }
}
local phosp_p25_0 = peakhosp_p25_0
local phosp_p50_0 = peakhosp_p50_0
local phosp_p75_0 = peakhosp_p75_0
local phosp_p25_1 = peakhosp_p25_1
local phosp_p50_1 = peakhosp_p50_1
local phosp_p75_1 = peakhosp_p75_1
local phosp_p25_2 = peakhosp_p25_2
local phosp_p50_2 = peakhosp_p50_2
local phosp_p75_2 = peakhosp_p75_2
local phosp_p25_3 = peakhosp_p25_3
local phosp_p50_3 = peakhosp_p50_3
local phosp_p75_3 = peakhosp_p75_3
local phosp_p25_4 = peakhosp_p25_4
local phosp_p50_4 = peakhosp_p50_4
local phosp_p75_4 = peakhosp_p75_4


*! Another large effect on estimates is the length of stay in critical care 
** Tracking hospitalisations (CRITICAL CARE)
** Average stay = 10 days (Probably an underestimate)
** Cumulative admissions (PIN),Cumulative discharge (POUT), and difference between the two (PDIFF)
forval y = 25(25)75 {
    forval x = 0(1)4 {
        gen pin_p`y'_`x' = sum(ncrit_p`y'_`x')
        gen pout_p`y'_`x' = sum(ncrit_p`y'_`x'[_n-10])
        replace pout_p`y'_`x' = 0 if pout_p`y'_`x' == . 
        gen pdiff_p`y'_`x' = pin_p`y'_`x' - pout_p`y'_`x'
    }
}
** SUMMARY METRIC: Total numbers of hospitalisations (ACUTE CARE)
preserve
    gen k = 1 
    collapse (sum) ncrit_p25_0 ncrit_p50_0 ncrit_p75_0 ncrit_p25_1 ncrit_p50_1 ncrit_p75_1  ///
                     ncrit_p25_2 ncrit_p50_2 ncrit_p75_2 ncrit_p25_3 ncrit_p50_3 ncrit_p75_3    ///
                     ncrit_p25_4 ncrit_p50_4 ncrit_p75_4, by(k) 
    local ncrit_p25_0 = ncrit_p25_0   
    local ncrit_p50_0 = ncrit_p50_0   
    local ncrit_p75_0 = ncrit_p75_0   
    local ncrit_p25_1 = ncrit_p25_1   
    local ncrit_p50_1 = ncrit_p50_1   
    local ncrit_p75_1 = ncrit_p75_1   
    local ncrit_p25_2 = ncrit_p25_2   
    local ncrit_p50_2 = ncrit_p50_2   
    local ncrit_p75_2 = ncrit_p75_2   
    local ncrit_p25_3 = ncrit_p25_3   
    local ncrit_p50_3 = ncrit_p50_3   
    local ncrit_p75_3 = ncrit_p75_3   
    local ncrit_p25_4 = ncrit_p25_4   
    local ncrit_p50_4 = ncrit_p50_4   
    local ncrit_p75_4 = ncrit_p75_4   
restore 

** SUMMARY METRIC: Peak hospital beds required (ACUTE CARE)
forval y = 25(25)75 {
    forval x = 0(1)4 {
        egen peakcrit_p`y'_`x' = max(pdiff_p`y'_`x')  
    }
}
local pcrit_p25_0 = peakcrit_p25_0
local pcrit_p50_0 = peakcrit_p50_0
local pcrit_p75_0 = peakcrit_p75_0
local pcrit_p25_1 = peakcrit_p25_1
local pcrit_p50_1 = peakcrit_p50_1
local pcrit_p75_1 = peakcrit_p75_1
local pcrit_p25_2 = peakcrit_p25_2
local pcrit_p50_2 = peakcrit_p50_2
local pcrit_p75_2 = peakcrit_p75_2
local pcrit_p25_3 = peakcrit_p25_3
local pcrit_p50_3 = peakcrit_p50_3
local pcrit_p75_3 = peakcrit_p75_3
local pcrit_p25_4 = peakcrit_p25_4
local pcrit_p50_4 = peakcrit_p50_4
local pcrit_p75_4 = peakcrit_p75_4


** Hospital beds (ACUTE CARE)
gen acutebeds = 240 
    #delimit ;
        gr twoway 
            ///(line acutebeds day,  lc(gs10) lw(0.35))
            (rarea cdiff_p75_1 cdiff_p25_1 day , col(green%15) lw(none))
            (rarea cdiff_p75_2 cdiff_p25_2 day , col(orange%15) lw(none))
            (rarea cdiff_p75_3 cdiff_p25_3 day , col(red%15) lw(none))
            (rarea cdiff_p75_4 cdiff_p25_4 day , col(red%30) lw(none))
            (line cdiff_p50_1 day , lc(green%50) lw(0.25) lp("-"))
            (line cdiff_p50_2 day , lc(orange%50) lw(0.25) lp("-"))
            (line cdiff_p50_3 day , lc(red%50) lw(0.25) lp("-"))
            (line cdiff_p50_4 day , lc(red%50) lw(0.25) lp("-"))
            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(7.5) xsize(10)
            
                xlab(none, labs(4) notick nogrid glc(gs16))
                ///xscale(off) 
                xscale(fill noline) 
                xtitle("Length of outbreak (months)", size(4) margin(l=2 r=2 t=2 b=2)) 
                ///xmtick(0(5)85, tl(1))
                
                ylab(0(100)300
                ,
                labs(4) nogrid glc(gs16) angle(0) format(%9.0f))
                ///yscale(off) 
                ytitle("# Acute Care Cases / Day", size(4) margin(l=2 r=2 t=2 b=2)) 
                ymtick(0(50)300)

                ///text(270 70 "# Acute beds", place(e) color(gs10))

                legend(off size(4) position(2) ring(0) bm(t=1 b=2 l=2 r=0) colf cols(1)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) 
                order(2 3 4) 
                lab(2 "90% Tx reduction") 
                lab(3 "80% Tx reduction") 
                lab(4 "70% Tx reduction") 
                )
                name(barbados_acutecare) 
                ;
        #delimit cr
graph export "`outputpath'/04_TechDocs/ATG_acutecare.png", replace width(4000)

** Hospital beds (CRITICAL CARE)
gen icubeds = 40 
    #delimit ;
        gr twoway 
            ///(line icubeds day,  lc(gs10) lw(0.35))
            (rarea pdiff_p75_1 pdiff_p25_1 day , col(green%15) lw(none))
            (rarea pdiff_p75_2 pdiff_p25_2 day , col(orange%15) lw(none))
            (rarea pdiff_p75_3 pdiff_p25_3 day , col(red%15) lw(none))
            (rarea pdiff_p75_4 pdiff_p25_4 day , col(red%30) lw(none))
            (line pdiff_p50_1 day , lc(green%50) lw(0.25) lp("-"))
            (line pdiff_p50_2 day , lc(orange%50) lw(0.25) lp("-"))
            (line pdiff_p50_3 day , lc(red%50) lw(0.25) lp("-"))
            (line pdiff_p50_4 day , lc(red%50) lw(0.25) lp("-"))
            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(7.5) xsize(10)
            
                xlab(none, notick labs(4) nogrid glc(gs16))
                ///xscale(off) 
                xscale(fill noline) 
                xtitle("Length of outbreak (months)", size(4) margin(l=2 r=2 t=2 b=2)) 
                ///xmtick(0(5)85, tl(1))
                
                ylab(0(100)300
                ,
                labs(4) nogrid glc(gs16) angle(0) format(%9.0f))
                ///yscale(off) 
                ytitle("# Critical Care Cases / Day", size(4) margin(l=2 r=2 t=2 b=2)) 
                ymtick(0(50)300)

                ///text(70 70 "# ICU beds", place(e) color(gs10))

                legend(off size(4) position(2) ring(0) bm(t=1 b=4 l=5 r=0) colf cols(1)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) 
                order(2 3 4) 
                lab(2 "90% Tx reduction") 
                lab(3 "80% Tx reduction") 
                lab(4 "70% Tx reduction") 
                )
                name(barbados_criticalcare) 
                ;
        #delimit cr
graph export "`outputpath'/04_TechDocs/ATG_criticalcare.png", replace width(4000)



** Population summaries
** --------------------------------
**                 cid | (sum) gtot
** --------------------+-----------
** Antigua and Barbuda |     97,928
**             Bahamas |    393,248
**            Barbados |    287,371
**              Belize |    397,621
**             Grenada |    112,519
**              Guyana |    786,559
**               Haiti | 11,402,533
**             Jamaica |  2,961,161
**         Saint Lucia |    183,629
**       Saint Vincent |    110,947
**            Suriname |    586,634
** Trinidad and Tobago |  1,399,491
**           Caribbean | 43,532,374
** --------------------------------

** Over 70 summaries
** --------------------------------------------
**                     |        over70i        
**                 cid |          0           1
** --------------------+-----------------------
** Antigua and Barbuda |     92,173       5,755
**             Bahamas |    374,622      18,626
**            Barbados |    254,408      32,963
**              Belize |    385,072      12,549
**             Grenada |    105,359       7,160
**              Guyana |    752,612      33,947
**               Haiti | 11,043,464     359,069
**             Jamaica |  2,782,772     178,389
**         Saint Lucia |    170,857      12,772
**       Saint Vincent |    103,838       7,109
**            Suriname |    560,100      26,534
** Trinidad and Tobago |  1,298,521     100,970
**           Caribbean | 40,442,904   3,089,470
** --------------------------------------------

*! CHANGE THESE ENTRIES FOR EACH COUNTRY FOR PDF REPORT CREATION
*! -------------------------------------------------------------
local pop = "97,928"
local over70 = "5,755" 
local acutebeds = "xx"
local icubeds = "xx"
local country = "Antigua and Barbuda"
local date = "29 March 2020"
*! -------------------------------------------------------------

*! NOTE block of code has a presentation tweak - turning NEG to POS
*! Would need altering for each country  
** Acute Care Shortfall at Peak Demand for final paragraph 
** local acute_sf_p25_1 = -1*(peakhosp_p25_1 - `acutebeds')
** local acute_sf_p75_1 = peakhosp_p75_1 - `acutebeds'
** local acute_sf_p25_2 = peakhosp_p25_2 - `acutebeds'
** local acute_sf_p75_2 = peakhosp_p75_2 - `acutebeds'
** local acute_sf_p25_3 = peakhosp_p25_3 - `acutebeds'
** local acute_sf_p75_3 = peakhosp_p75_3 - `acutebeds'
** Critical Care Shortfall at Peak Demand for final paragraph 
** local crit_sf_p25_1 = peakcrit_p25_1 - `icubeds'
** local crit_sf_p75_1 = peakcrit_p75_1 - `icubeds'
** local crit_sf_p25_2 = peakcrit_p25_2 - `icubeds'
** local crit_sf_p75_2 = peakcrit_p75_2 - `icubeds'
** local crit_sf_p25_3 = peakcrit_p25_3 - `icubeds'
** local crit_sf_p75_3 = peakcrit_p75_3 - `icubeds'


*! Check these numbers for "Ball-park" aggreement
*! If large differences - check IC methods appendix for updated assumptions 
** Checking the report numbers against IMPERIAL COLLEGE article (Report 12)
** https://www.imperial.ac.uk/media/imperial-college/medicine/sph/ide/gida-fellowships/Imperial-College-COVID19-Global-Impact-26-03-2020.pdf

** ACUTE CARE AND CRITICAL CARE
** Do nothing / 90% Tx reduction / 80% Tx reduction / 70% Tx reduction 
** p50 (p25 to p75)
program check_metrics 
args    nhosp_p25_0 nhosp_p50_0 nhosp_p75_0 nhosp_p25_1 nhosp_p50_1 nhosp_p75_1 ///
        nhosp_p25_2 nhosp_p50_2 nhosp_p75_2 nhosp_p25_3 nhosp_p50_3 nhosp_p75_3 ///
        nhosp_p25_4 nhosp_p50_4 nhosp_p75_4                                     ///
        ncrit_p25_0 ncrit_p50_0 ncrit_p75_0 ncrit_p25_1 ncrit_p50_1 ncrit_p75_1 ///
        ncrit_p25_2 ncrit_p50_2 ncrit_p75_2 ncrit_p25_3 ncrit_p50_3 ncrit_p75_3 ///
        ncrit_p25_4 ncrit_p50_4 ncrit_p75_4
    dis "Acute Care (Un-mitigated) = " `nhosp_p50_0' " (IQR " `nhosp_p25_0' " to " `nhosp_p75_0' ")", _newline(1) as result
    dis "Acute Care (95% Tx reduction) = " `nhosp_p50_1' " (IQR " `nhosp_p25_1' " to " `nhosp_p75_1' ")", _newline(1) as result
    dis "Acute Care (85% Tx reduction) = " `nhosp_p50_2' " (IQR " `nhosp_p25_2' " to " `nhosp_p75_2' ")", _newline(1) as result
    dis "Acute Care (75% Tx reduction) = " `nhosp_p50_3' " (IQR " `nhosp_p25_3' " to " `nhosp_p75_3' ")", _newline(1) as result
    dis "Acute Care (65% Tx reduction) = " `nhosp_p50_4' " (IQR " `nhosp_p25_4' " to " `nhosp_p75_4' ")", _newline(1) as result
    dis "Critical Care (Un-mitigated) = " `ncrit_p50_0' " (IQR " `ncrit_p25_0' " to " `ncrit_p75_0' ")", _newline(1) as result
    dis "Critical Care (95% Tx reduction) = " `ncrit_p50_1' " (IQR " `ncrit_p25_1' " to " `ncrit_p75_1' ")", _newline(1) as result
    dis "Critical Care (85% Tx reduction) = " `ncrit_p50_2' " (IQR " `ncrit_p25_2' " to " `ncrit_p75_2' ")", _newline(1) as result
    dis "Critical Care (75% Tx reduction) = " `ncrit_p50_3' " (IQR " `ncrit_p25_3' " to " `ncrit_p75_3' ")", _newline(1) as result
    dis "Critical Care (65% Tx reduction) = " `ncrit_p50_4' " (IQR " `ncrit_p25_4' " to " `ncrit_p75_4' ")", _newline(1) as result
end
check_metrics   `nhosp_p25_0' `nhosp_p50_0' `nhosp_p75_0' `nhosp_p25_1' `nhosp_p50_1' `nhosp_p75_1' ///
                `nhosp_p25_2' `nhosp_p50_2' `nhosp_p75_2' `nhosp_p25_3' `nhosp_p50_3' `nhosp_p75_3' ///
                `nhosp_p25_4' `nhosp_p50_4' `nhosp_p75_4'                                           ///
                `ncrit_p25_0' `ncrit_p50_0' `ncrit_p75_0' `ncrit_p25_1' `ncrit_p50_1' `ncrit_p75_1' ///
                `ncrit_p25_2' `ncrit_p50_2' `ncrit_p75_2' `ncrit_p25_3' `ncrit_p50_3' `ncrit_p75_3' ///
                `ncrit_p25_4' `ncrit_p50_4' `ncrit_p75_4' 




** ------------------------------------------------------
** PDF COUNTRY REPORT
** ------------------------------------------------------
putpdf begin, pagesize(letter) font("Calibri Light", 10) margin(top,1cm) margin(bottom,0.5cm) margin(left,1cm) margin(right,0.5cm)

** TITLE, ATTRIBUTION, DATE of CREATION
putpdf paragraph ,  font("Calibri Light", 12)
putpdf text ("COVID-19 estimates for `country'"), bold linebreak
putpdf paragraph ,  font("Calibri Light", 9)
putpdf text ("Briefing created by staff of the George Alleyne Chronic Disease Research Centre and the Public Health Group of The Faculty of Medical Sciences, Cave Hill Campus, The University of the West Indies"), linebreak
putpdf text ("Contact Ian Hambleton (ian.hambleton@cavehill.uwi.edu) for details of quantitative analyses"), font("Calibri Light", 9) linebreak italic
putpdf text ("Contact Maddy Murphy (madhuvanti.murphy@cavehill.uwi.edu) for details of national public health interventions"), font("Calibri Light", 9) italic linebreak
putpdf text ("Creation date: `date'"), font("Calibri Light", 9) bold italic linebreak

** INTRODUCTION
putpdf paragraph ,  font("Calibri Light", 10)
putpdf text ("Aim of this briefing. ") , bold
putpdf text ("We present estimates of COVID-19 infections ") 
putpdf text ("(A) requiring acute care in hospital, and ") 
putpdf text ("(B) requiring critical care. ")
putpdf text ("This focus should enable policymakers to assess country readiness in terms of resources to provide acute (hospital) and critical (ICU) care. ")
putpdf text ("The estimates presented are based on a number of important assumptions, which we present in the Technical Appendix.")

** HOSPITALISATION / ACUTE CARE
putpdf paragraph ,  font("Calibri Light", 10)
putpdf text ("Total number of COVID-19 infections requiring acute care or critical care. ") , bold
putpdf text ("`country' has a total estimated population in 2020 of `pop' people, with `over70' people aged 70 and older. ")
putpdf text ("Without any national intervention "), italic 
putpdf text ("to restrict the spread of COVID-19, we would expect between ") 
putpdf text ("`nhosp_p25_0'"), nformat(%6.0fc)
putpdf text (" and ") 
putpdf text ("`nhosp_p75_0'"), nformat(%6.0fc)
putpdf text (" infected people to need acute hospital care over the duration of the epidemic. ")
putpdf text ("Our companion briefing discusses a range of national policy responses and mechanisms for surveillance. ") 
putpdf text ("For each of these policy responses the goal is a national reduction in transmission. ")
putpdf text ("We can expect the following estimated numbers of people requiring acute care and critical care at ") 
putpdf text ("different levels of transmission reduction (see Table 1, columns 2 and 3). ") , linebreak

putpdf text (" "), linebreak

** TABLE OF HOSPITAL DEMAND
putpdf text ("Table 1. "), bold
putpdf text ("Numbers of people requiring acute care or critical care ")
putpdf text ("over the full epidemic duration "), italic
putpdf text ("given four levels of transmission reduction"), linebreak
putpdf table t1 = (5,5), width(100%) halign(center) 
putpdf table t1(.,.), font("Calibri Light", 10) 
putpdf table t1(1,1)=("Transmission reduction"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(2,1)=("Very High (up to 95%)"), halign(center) border(top) border(bottom) border(left) border(right) 
putpdf table t1(3,1)=("High (up to 85%)"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(4,1)=("Moderate (up to 75%)"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(5,1)=("Moderate (up to 65%)"), halign(center) border(top) border(bottom) border(left) border(right)

putpdf table t1(1,2)=("No. of people needing acute care"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(2,2)=("`nhosp_p25_1' to `nhosp_p75_1'"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(3,2)=("`nhosp_p25_2' to `nhosp_p75_2'"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(4,2)=("`nhosp_p25_3' to `nhosp_p75_3'"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(5,2)=("`nhosp_p25_4' to `nhosp_p75_4'"), halign(center) border(top) border(bottom) border(left) border(right)

putpdf table t1(1,3)=("No. of people needing critical care"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(2,3)=("`ncrit_p25_1' to `ncrit_p75_1'"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(3,3)=("`ncrit_p25_2' to `ncrit_p75_2'"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(4,3)=("`ncrit_p25_3' to `ncrit_p75_3'"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(5,3)=("`ncrit_p25_4' to `ncrit_p75_4'"), halign(center) border(top) border(bottom) border(left) border(right)

putpdf table t1(1,4)=("Peak demand for acute care"), halign(center) border(top) border(bottom)  border(left) border(right)
putpdf table t1(2,4)=("`phosp_p25_1' to `phosp_p75_1'"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(3,4)=("`phosp_p25_2' to `phosp_p75_2'"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(4,4)=("`phosp_p25_3' to `phosp_p75_3'"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(5,4)=("`phosp_p25_4' to `phosp_p75_4'"), halign(center) border(top) border(bottom) border(left) border(right)

putpdf table t1(1,5)=("Peak demand for critical care"), halign(center) border(top) border(bottom)  border(left) border(right)
putpdf table t1(2,5)=("`pcrit_p25_1' to `pcrit_p75_1'"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(3,5)=("`pcrit_p25_2' to `pcrit_p75_2'"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(4,5)=("`pcrit_p25_3' to `pcrit_p75_3'"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(5,5)=("`pcrit_p25_4' to `pcrit_p75_4'"), halign(center) border(top) border(bottom) border(left) border(right)

** GREY SCALE
putpdf table t1(1,.), bgcolor(ECECEC)
** Very high - green 
putpdf table t1(2,.), bgcolor(D4F0CA)
** High - orange 
putpdf table t1(3,.), bgcolor(FCDEB0)
** Moderate - red 
putpdf table t1(4,.), bgcolor(FFD6D0)
putpdf table t1(5,.), bgcolor(FFAC9F)

** TEXT ON DEMAND VERSUS SUPPLY
putpdf paragraph ,  font("Calibri Light", 10)
putpdf text ("Peak demand for acute care or critical care. ") , bold
putpdf text ("The graphs below show the possible numbers of people infected with COVID-19 who require either ")
putpdf text ("acute or critical care ")
putpdf text ("on each day "), italic 
putpdf text ("of the outbreak. ") 
/// putpdf text ("The grey horizontal lines show the available beds. ")
/// putpdf text ("In `country', only the most effective transmission reduction reduces the peak acute and critical care demand to ")
/// putpdf text ("levels manageable given the current health system bed capacity. ")
putpdf text ("See Table 1 (columns 4 and 5) above for estimated numbers of people requiring acute and critical care at peak demand. ")
putpdf text ("Our companion policy response briefing discusses options for reducing transmission ")
putpdf text ("and for developing surveillance to monitor healthcare demand. "), linebreak

** putpdf text ("Although we have assumed a 3-month epidemic, policy responses should be expected to change the ")), linebreak

** FIGURES OF HOSIPTAL DEMAND
putpdf text (" "), linebreak
putpdf text ("Figure 1."), bold
putpdf text (" Estimates of Daily Acute Care and Critical Care Demand at different levels of transmission (Tx) reduction"), linebreak
putpdf table f1 = (2,2), border(all,nil) halign(center)
putpdf table f1(1,1)=image("`outputpath'/04_TechDocs/ATG_acutecare.png")
putpdf table f1(2,1)=("(A) Acute Care Demand"), halign(center)
putpdf table f1(1,2)=image("`outputpath'/04_TechDocs/ATG_criticalcare.png")
putpdf table f1(2,2)=("(B) Critical Care Demand"), halign(center)





** TECHNICAL APPNDIX
putpdf sectionbreak
putpdf paragraph ,  font("Calibri Light", 10)
putpdf text ("Technical Appendix ") , bold
putpdf paragraph ,  font("Calibri Light", 9)
putpdf text ("Estimating Number of Infections. "), bold
putpdf text ("We used an underlying Susceptible-Exposed-Infectious-Recovered (SEIR) model to estimate the number of people infected, ")
putpdf text ("needing acute hosiptal care, and needing critical ICU care ")
putpdf text ("in the absence of any national intervention to control the spread of the virus. "), italic
putpdf text ("We drew these estimates from an artificially generated ") 
putpdf text ("population with an age-structure and household composition constructed to mimic the population of `country' (see Table A1). ")
putpdf text ("Following early reports on the COVID-19 outbreak, we used a reproduction number (R0) of 2.7. ") 
putpdf text ("Other assumptions included an incubation period of 4 days, a 33% chance of being asymptomatic given infection, ") 
putpdf text ("and 10 initial in-country infections to begin the outbreak. ")
putpdf text ("We ran 100 model simulations, taking smoothed median estimates, with percentile estimates as a ") 
putpdf text ("simple recognition of uncertainty (25th percentile, 75th percentile). "), linebreak

** TABLE OF ASSUMPTIONS BY AGE CATEGORY
putpdf text (" "), linebreak font("Calibri Light", 9)
putpdf text ("Table A1. "), bold font("Calibri Light", 9)
putpdf text ("Age structure, household composition, probability of hospitalisation, probability of critical care"), font("Calibri Light", 9) linebreak
#delimit ; 
putpdf table ta1 = (10,6), width(100%) halign(center) 
note("(1) United Nations, Department of Economic and Social Affairs, Population Division (2019). World Population Prospects 2019, Online Edition. Rev. 1") 
note("(2) Ferguson et al (2020) Impact of non-pharmaceutical interventions (NPIs) to reduce COVID-19 mortality and healthcare demand. Downloaded from: www.imperial.ac.uk/media/imperial-college/medicine/sph/ide/gida-fellowships/Imperial-College-COVID19-NPI-modelling-16-03-2020.pdf (26-Mar-2020)");
#delimit cr        
putpdf table ta1(.,.), font("Calibri Light", 8) 
putpdf table ta1(1,.), bgcolor(ECECEC)
forval x = 2(1)10 {
    putpdf table ta1(`x',1), bgcolor(ECECEC)
}
putpdf table ta1(.,4), bgcolor(ECECEC)

putpdf table ta1(1,1)=("Age Groups"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(2,1)=("0-4"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(3,1)=("5-18"), halign(center) border(top) border(bottom) border(left) border(right) 
putpdf table ta1(4,1)=("19-49"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(5,1)=("50-64"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(6,1)=("65-69"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(7,1)=("70-74"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(8,1)=("75-79"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(9,1)=("80-84"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(10,1)=("85+"), halign(center) border(top) border(bottom) border(left) border(right)

putpdf table ta1(1,2)=("Age structure (1)"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(2,2)=("7.5%"), halign(center) border(top) border(bottom) border(left) border(right) 
putpdf table ta1(3,2)=("20.1%"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(4,2)=("45.2%"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(5,2)=("17.9%"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(6,2)=("3.5%"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(7,2)=("2.6%"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(8,2)=("1.6%"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(9,2)=("0.9%"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(10,2)=("0.7%"), halign(center) border(top) border(bottom) border(left) border(right)

putpdf table ta1(1,3)=("Houehold Composition"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(2,3)=("1 person (14.0%)"), halign(center) border(top) border(bottom) border(left) border(right) 
putpdf table ta1(3,3)=("2 people (35.0%)"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(4,3)=("3 people (20.0%)"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(5,3)=("4 people (20,0%)"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(6,3)=("5 people (7.0%)"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(7,3)=("6 people (2.5%)"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(8,3)=("7 people (1.5%)"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(9,3)=(" "), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(10,3)=(" "), halign(center) border(top) border(bottom) border(left) border(right)

putpdf table ta1(1,4)=("Age Groups"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(2,4)=("0-9"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(3,4)=("10-19"), halign(center) border(top) border(bottom) border(left) border(right) 
putpdf table ta1(4,4)=("20-29"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(5,4)=("30-39"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(6,4)=("40-49"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(7,4)=("50-59"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(8,4)=("60-69"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(9,4)=("70-79"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(10,4)=("80+"), halign(center) border(top) border(bottom) border(left) border(right)

putpdf table ta1(1,5)=("Symptomatic cases requiring hospitalisation (acute care) (2)"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(2,5)=("0.1%"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(3,5)=("0.3%"), halign(center) border(top) border(bottom) border(left) border(right) 
putpdf table ta1(4,5)=("1.2%"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(5,5)=("3.2%"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(6,5)=("4.9%"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(7,5)=("10.2%"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(8,5)=("16.6%"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(9,5)=("24.3%"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(10,5)=("27.3%"), halign(center) border(top) border(bottom) border(left) border(right)

putpdf table ta1(1,6)=("Hospitalised cases requiring critical care (2)"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(2,6)=("5.0%"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(3,6)=("5.0%"), halign(center) border(top) border(bottom) border(left) border(right) 
putpdf table ta1(4,6)=("5.0%"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(5,6)=("5.0%"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(6,6)=("6.3%"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(7,6)=("12.2%"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(8,6)=("27.4%"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(9,6)=("43.2%"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta1(10,6)=("70.9%"), halign(center) border(top) border(bottom) border(left) border(right)

putpdf paragraph ,  font("Calibri Light", 9)
putpdf text ("Estimating Community Contacts. ") , bold
putpdf text ("In our model, each suscepible person is estimated to have periods of contact (mostly between 60 and 120 minutes) ") 
putpdf text ("with a given number of people in their household and in their community. ") 
putpdf text ("Specific additional community estimates were made for number and duration of contacts at work, at school, in daycare, and in long term healthcare facilities, with different patterns ")
putpdf text ("of contact on weekdays and weekends, and depending on age. These contact matrices guided the estimation of infection ") 
putpdf text ("spread through the community. An example contact matrix is presented below (Table A2), and full details are available on request."), font("Calibri Light", 9) linebreak

** MATRIX OF COMMUNITY CONTACTS (with household members during weekdays)
putpdf text (" "), linebreak font("Calibri Light", 9)
putpdf text ("Table A2. "), bold font("Calibri Light", 9)
putpdf text ("Number and duration of contacts with household members on weekdays"), font("Calibri Light", 9) linebreak
putpdf table ta2 = (6,9), width(100%) halign(center) 
putpdf table ta2(.,.), font("Calibri Light", 8) 
putpdf table ta2(1,.), bgcolor(ECECEC)
putpdf table ta2(2,.), bgcolor(ECECEC)
putpdf table ta2(.,1), bgcolor(ECECEC)

putpdf table ta2(4,2), bgcolor(ECECEC)
putpdf table ta2(5,2), bgcolor(ECECEC)
putpdf table ta2(6,2), bgcolor(ECECEC)
putpdf table ta2(4,3), bgcolor(ECECEC)
putpdf table ta2(5,3), bgcolor(ECECEC)
putpdf table ta2(6,3), bgcolor(ECECEC)

putpdf table ta2(5,4), bgcolor(ECECEC)
putpdf table ta2(6,4), bgcolor(ECECEC)
putpdf table ta2(5,5), bgcolor(ECECEC)
putpdf table ta2(6,5), bgcolor(ECECEC)

putpdf table ta2(6,6), bgcolor(ECECEC)
putpdf table ta2(6,7), bgcolor(ECECEC)

putpdf table ta2(1,1)=(" "), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(2,1)=("Age Groups"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(3,1)=("0-4 yrs"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(4,1)=("5-18 yrs"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(5,1)=("19-64 yrs"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(6,1)=("65+ yrs"), halign(center) border(top) border(bottom) border(left) border(right)

putpdf table ta2(1,2)=("0-4 years"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(2,2)=("# contacts"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(3,2)=("1"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(4,2)=(" "), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(5,2)=(" "), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(6,2)=(" "), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(2,3)=("Contact duration"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(3,3)=("120 mins"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(4,3)=(" "), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(5,3)=(" "), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(6,3)=(" "), halign(center) border(top) border(bottom) border(left) border(right)

putpdf table ta2(1,4)=("5-18 years"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(2,4)=("# contacts"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(3,4)=("1"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(4,4)=("2"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(5,4)=(" "), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(6,4)=(" "), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(2,5)=("Contact duration"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(3,5)=("60 mins"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(4,5)=("120 mins"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(5,5)=(" "), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(6,5)=(" "), halign(center) border(top) border(bottom) border(left) border(right)

putpdf table ta2(1,6)=("19-64 years"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(2,6)=("# contacts"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(3,6)=("1"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(4,6)=("1"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(5,6)=("1"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(6,6)=(" "), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(2,7)=("Contact duration"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(3,7)=("120 mins"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(4,7)=("120 mins"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(5,7)=("120 mins"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(6,7)=(" "), halign(center) border(top) border(bottom) border(left) border(right)

putpdf table ta2(1,8)=("65+ years"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(2,8)=("# contacts"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(3,8)=("1"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(4,8)=("1"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(5,8)=("1"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(6,8)=("1"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(2,9)=("Contact duration"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(3,9)=("60 mins"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(4,9)=("60 mins"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(5,9)=("120 mins"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table ta2(6,9)=("120 mins"), halign(center) border(top) border(bottom) border(left) border(right)

putpdf paragraph ,  font("Calibri Light", 9)
putpdf text ("Estimating Acute Care and Critical Care Demand. ") , bold
putpdf text ("Early COVID-19 reports have presented estimates for the proportion of infections that are expected to require acute care and critical care. ") 
putpdf text ("We present these estimates in Table A1 (columns 5 and 6), and used them to calculate the number of people expected to need ") 
putpdf text ("hospitalisation (acute care) or critical care on each day of the epidemic. We then did two things: (A) We explored the reduction ") 
putpdf text ("in acute and critical care demand at various levels of transmission reduction (up to 75%, up to 85%, up to 95%), which we broadly term ")
putpdf text ("moderate reduction, high reduction, and very high reduction, (B) We calculated the total numbers of infected people needing acute or critical care over the ")
putpdf text (" entire duration of the epidemic, and the peak demand during the epidemic. When calculating ")
putpdf text ("peak demand "), italic
putpdf text ("we anticipated a 7-day hospital stay for acute care and a 10-day hospital stay for critical care.")

** Save the PDF
putpdf save "`outputpath'/05_Outputs/covid19_report_ATG", replace
