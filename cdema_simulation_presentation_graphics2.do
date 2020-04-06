** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					cdema_simulation_presentation_graphics2.do
    //  project:				        Preparing BB population data
    //  analysts:				       	Ian HAMBLETON
    // 	date last modified	            24-MAR-2020
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
    log using "`logpath'\cdema_simulation_presentation_graphics2", replace
** HEADER -----------------------------------------------------

** DATA
tempfile t1 t2 t3 t4 
import excel using "`datapath'/version01/1-input/cdc_simulation_barbados.xlsx", clear first sheet("baseline18")

** upscale to BB population (280k)
replace AVG = AVG * 103
forval x = 1(1)50 {
    replace Sim`x' = Sim`x'*103
    } 

** Summarise the 50 simulations
#delimit ; 
egen case_av = rowmean(Sim1 Sim2 Sim3 Sim4 Sim5 Sim6 Sim7 Sim8 Sim9 Sim10
                        Sim11 Sim12 Sim13 Sim14 Sim15 Sim16 Sim17 Sim18 Sim19 Sim20
                        Sim21 Sim22 Sim23 Sim24 Sim25 Sim26 Sim27 Sim28 Sim29 Sim30
                        Sim31 Sim32 Sim33 Sim34 Sim35 Sim36 Sim37 Sim38 Sim39 Sim40
                        Sim41 Sim42 Sim43 Sim44 Sim45 Sim46 Sim47 Sim48 Sim49 Sim50);
egen case_p50 = rowmedian(Sim1 Sim2 Sim3 Sim4 Sim5 Sim6 Sim7 Sim8 Sim9 Sim10
                        Sim11 Sim12 Sim13 Sim14 Sim15 Sim16 Sim17 Sim18 Sim19 Sim20
                        Sim21 Sim22 Sim23 Sim24 Sim25 Sim26 Sim27 Sim28 Sim29 Sim30
                        Sim31 Sim32 Sim33 Sim34 Sim35 Sim36 Sim37 Sim38 Sim39 Sim40
                        Sim41 Sim42 Sim43 Sim44 Sim45 Sim46 Sim47 Sim48 Sim49 Sim50);
egen case_p25 = rowpctile(Sim1 Sim2 Sim3 Sim4 Sim5 Sim6 Sim7 Sim8 Sim9 Sim10
                        Sim11 Sim12 Sim13 Sim14 Sim15 Sim16 Sim17 Sim18 Sim19 Sim20
                        Sim21 Sim22 Sim23 Sim24 Sim25 Sim26 Sim27 Sim28 Sim29 Sim30
                        Sim31 Sim32 Sim33 Sim34 Sim35 Sim36 Sim37 Sim38 Sim39 Sim40
                        Sim41 Sim42 Sim43 Sim44 Sim45 Sim46 Sim47 Sim48 Sim49 Sim50), p(25);
egen case_p75 = rowpctile(Sim1 Sim2 Sim3 Sim4 Sim5 Sim6 Sim7 Sim8 Sim9 Sim10
                        Sim11 Sim12 Sim13 Sim14 Sim15 Sim16 Sim17 Sim18 Sim19 Sim20
                        Sim21 Sim22 Sim23 Sim24 Sim25 Sim26 Sim27 Sim28 Sim29 Sim30
                        Sim31 Sim32 Sim33 Sim34 Sim35 Sim36 Sim37 Sim38 Sim39 Sim40
                        Sim41 Sim42 Sim43 Sim44 Sim45 Sim46 Sim47 Sim48 Sim49 Sim50), p(75);
#delimit cr 

** Keep days and average number of cases 
rename Day day 
keep day case_av case_p25 case_p50 case_p75 
order day case_av case_p25 case_p50 case_p75 

** Weighted proportion in hospital
** Population proportion * hospitalised proportion
#delimit ; 
gen phosp = (0.107 * 0.001) +
            (0.127 * 0.003) +
            (0.131 * 0.012) +
            (0.129 * 0.032) +
            (0.136 * 0.049) +
            (0.139 * 0.102) +
            (0.117 * 0.166) +
            (0.070 * 0.243) +
            (0.045 * 0.273);
#delimit cr 
** Weighted proportion requiring critical care
** Population proportion * hospitalised proportion * critical care proportion
#delimit ; 
gen pcrit = (0.107 * 0.001 * 0.05) +
            (0.127 * 0.003 * 0.05) +
            (0.131 * 0.012 * 0.05) +
            (0.129 * 0.032 * 0.05) +
            (0.136 * 0.049 * 0.063) +
            (0.139 * 0.102 * 0.122) +
            (0.117 * 0.166 * 0.274) +
            (0.070 * 0.243 * 0.432) +
            (0.045 * 0.273 * 0.709);
#delimit cr 

** Smooth the average incident cases
lpoly case_av day, at(day) gen(ninf_av) nogr
forval x = 25(25)75 {
    lpoly case_p`x' day, at(day) gen(ninf_p`x') nogr
    }

** Baseline = No Intervention
forval x = 25(25)75 {
    gen ninf_p`x'_0 = int(ninf_p`x')
    gen nhosp_p`x'_0 = int(ninf_p`x'_0 * phosp)
    gen ncrit_p`x'_0 = int(ninf_p`x'_0 * pcrit) 
}

** Interventions: Between 95% and 55% transmission reduction  
** Calculate the commensurate decrease in hospitalisations (acute care) and critical care 
forval y = 25(25)75 {
    local k = 1 
    forval x = 0.1(0.1)0.5 {
        gen ninf_p`y'_`k' = int(ninf_p`y'_0 * `x')
        gen nhosp_p`y'_`k' = int(ninf_p`y'_`k' * phosp)
        gen ncrit_p`y'_`k' = int(ninf_p`y'_`k' * pcrit) 
        local k = `k'+1
    }
}

** Tracking hospitalisations (ACUTE CARE)
** Average stay = 7 days
** Cumulative admissions (CIN),Cumulative discharge (COUT), and difference between the two (CDIFF)
forval y = 25(25)75 {
    forval x = 0(1)5 {
        gen cin_p`y'_`x' = sum(nhosp_p`y'_`x')
        gen cout_p`y'_`x' = sum(nhosp_p`y'_`x'[_n-7])
        replace cout_p`y'_`x' = 0 if cout_p`y'_`x' == . 
        gen cdiff_p`y'_`x' = cin_p`y'_`x' - cout_p`y'_`x'
    }
}

** SUMMARY METRIC: Total numbers of hospitalisations (ACUTE CARE)
preserve
    gen k = 1 
    collapse (sum) nhosp_p25_0 nhosp_p50_0 nhosp_p75_0 nhosp_p25_1 nhosp_p50_1 nhosp_p75_1  ///
                     nhosp_p25_2 nhosp_p50_2 nhosp_p75_2 nhosp_p25_3 nhosp_p50_3 nhosp_p75_3, by(k) 
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
restore 

** SUMMARY METRIC: Peak hospital beds required (ACUTE CARE)
forval y = 25(25)75 {
    forval x = 0(1)5 {
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


** Tracking hospitalisations (CRITICAL CARE)
** Average stay = 10 days
** Cumulative admissions (CIN),Cumulative discharge (COUT), and difference between the two (CDIFF)
forval y = 25(25)75 {
    forval x = 0(1)5 {
        gen pin_p`y'_`x' = sum(ncrit_p`y'_`x')
        gen pout_p`y'_`x' = sum(ncrit_p`y'_`x'[_n-10])
        replace pout_p`y'_`x' = 0 if pout_p`y'_`x' == . 
        gen pdiff_p`y'_`x' = pin_p`y'_`x' - pout_p`y'_`x'
    }
}

** SUMMARY METRIC: Total numbers of hospitalisations (ACUTE CARE)
preserve
    gen k = 1 
    collapse (sum) ncrit_p25_0 ncrit_p50_0 ncrit_p75_0 ncrit_p25_1 ncrit_p50_1 ncrit_p75_1 ///
                    ncrit_p25_2 ncrit_p50_2 ncrit_p75_2 ncrit_p25_3  ncrit_p50_3 ncrit_p75_3, by(k) 
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
restore 

** SUMMARY METRIC: Peak hospital beds required (ACUTE CARE)
forval y = 25(25)75 {
    forval x = 0(1)5 {
        egen peakcrit_p`y'_`x' = max(pdiff_p`y'_`x')  
    }
}
local pcrit_p25_0 = peakcrit_p25_0
local pcrit_p50_0 = peakcrit_p50_0
local pcrit_p75_0 = peakcrit_p75_0
local pcrit_p25_1 = peakcrit_p25_1
local pcrit_p50_0 = peakcrit_p50_1
local pcrit_p75_1 = peakcrit_p75_1
local pcrit_p25_2 = peakcrit_p25_2
local pcrit_p50_0 = peakcrit_p50_2
local pcrit_p75_2 = peakcrit_p75_2
local pcrit_p25_3 = peakcrit_p25_3
local pcrit_p50_0 = peakcrit_p50_3
local pcrit_p75_3 = peakcrit_p75_3


** SLIDE 3 (ACUTE CARE METRICS) 
** Do nothing (25% to 75%)
dis "25% = " `nhosp_p25_0'
dis "50% = " `nhosp_p50_0'
dis "75% = " `nhosp_p75_0'
** Tx reduction of 90%
dis "25% = " `nhosp_p25_1'
dis "50% = " `nhosp_p50_1'
dis "75% = " `nhosp_p75_1'
** Tx reduction of 80%
dis "25% = " `nhosp_p25_2'
dis "50% = " `nhosp_p50_2'
dis "75% = " `nhosp_p75_2'
** Tx reduction of 70%
dis "25% = " `nhosp_p25_3'
dis "50% = " `nhosp_p50_3'
dis "75% = " `nhosp_p75_3'

** SLIDE 4 (CRITICAL CARE METRICS) 
** Do nothing (25% to 75%)
dis "25% = " `ncrit_p25_0'
dis "50% = " `ncrit_p50_0'
dis "75% = " `ncrit_p75_0'
** Tx reduction of 90%
dis "25% = " `ncrit_p25_1'
dis "50% = " `ncrit_p50_1'
dis "75% = " `ncrit_p75_1'
** Tx reduction of 80%
dis "25% = " `ncrit_p25_2'
dis "50% = " `ncrit_p50_2'
dis "75% = " `ncrit_p75_2'
** Tx reduction of 70%
dis "25% = " `ncrit_p25_3'
dis "50% = " `ncrit_p50_3'
dis "75% = " `ncrit_p75_3'


** SLIDE 3 (ACUTE CARE METRICS) 
** Do nothing (25% to 75%)
dis "25% = " `phosp_p25_0'
dis "75% = " `phosp_p75_0'
** Tx reduction of 90%
dis "25% = " `phosp_p25_1'
dis "75% = " `phosp_p75_1'
** Tx reduction of 80%
dis "25% = " `phosp_p25_2'
dis "75% = " `phosp_p75_2'
** Tx reduction of 70%
dis "25% = " `phosp_p25_3'
dis "75% = " `phosp_p75_3'

** SLIDE 4 (CRITICAL CARE METRICS) 
** Do nothing (25% to 75%)
dis "25% = " `pcrit_p25_0'
dis "75% = " `pcrit_p75_0'
** Tx reduction of 90%
dis "25% = " `pcrit_p25_1'
dis "75% = " `pcrit_p75_1'
** Tx reduction of 80%
dis "25% = " `pcrit_p25_2'
dis "75% = " `pcrit_p75_2'
** Tx reduction of 70%
dis "25% = " `pcrit_p25_3'
dis "75% = " `pcrit_p75_3'

** Hospital beds (ACUTE CARE)
gen acutebeds = 240 

    #delimit ;
        gr twoway 
            ///(line acutebeds day,  lc(gs10) lw(0.35))
            (rarea cdiff_p75_1 cdiff_p25_1 day , col(green%15) lw(none))
            ///(rarea cdiff_p75_2 cdiff_p25_2 day , col(orange%15) lw(none))
            (rarea cdiff_p75_3 cdiff_p25_3 day , col(red%15) lw(none))
            (line cdiff_p50_1 day , lc(green%50) lw(0.25) lp("-"))
            ///(line cdiff_p50_2 day , lc(orange%50) lw(0.25) lp("-"))
            (line cdiff_p50_3 day , lc(red%50) lw(0.25) lp("-"))
            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(4) xsize(12)
            
                xlab(0(10)80, labs(4) nogrid glc(gs16))
                ///xscale(off) 
                xscale(off fill) 
                xtitle("Days from start of national outbreak", size(4) margin(l=2 r=2 t=2 b=2)) 
                xmtick(0(5)85, tl(1))
                
                ylab(0(250)1000
                ,
                labs(10) labc(gs10) nogrid notick glc(gs16) angle(0) format(%9.0f))
                yscale(off fill noline) 
                ytitle("", size(4) margin(l=2 r=2 t=2 b=2)) 
                ///ymtick(0(100)1000)

                ///text(330 60 "# Acute beds", size(10) place(e) color(gs10))

                legend(size(10) color(gs10) position(2) ring(0) bm(t=1 b=2 l=2 r=0) colf cols(1)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) 
                order(1 2) 
                lab(1 "Earlier Suppression") 
                lab(2 "Later Suppression") 
                )
                name(barbados_acutecare) 
                ;
        #delimit cr
///graph export "`outputpath'/04_TechDocs/barbados_acutecare_presentation.png", replace width(4000)





** Hospital beds (ACUTE CARE)
    #delimit ;
        gr twoway 
            ///(line acutebeds day,  lc(gs10) lw(0.35))
            (rarea cdiff_p75_1 cdiff_p25_1 day , col(green%15) lw(none))
            ///(rarea cdiff_p75_2 cdiff_p25_2 day , col(orange%15) lw(none))
            (rarea cdiff_p75_3 cdiff_p25_3 day , col(red%15) lw(none))
            (line cdiff_p50_1 day , lc(green%50) lw(0.25) lp("-"))
            ///(line cdiff_p50_2 day , lc(orange%50) lw(0.25) lp("-"))
            (line cdiff_p50_3 day , lc(red%50) lw(0.25) lp("-"))
            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(7.5) xsize(10)
            
                xlab(none, labs(4) nogrid glc(gs16))
                ///xscale(off) 
                xscale(noline fill) 
                xtitle("Days from start of national outbreak", size(4) margin(l=2 r=2 t=2 b=2)) 
                ///xmtick(0(5)85, tl(1))
                
                ylab(0(200)1000
                ,
                labs(4) labc(gs0) nogrid notick glc(gs16) angle(0) format(%9.0f))
                yscale(off fill noline) 
                ytitle("# Acute Care Cases / Day", size(4) margin(l=2 r=2 t=2 b=2)) 
                ///ymtick(0(100)1000)

                ///text(280 70 "# Acute beds", size(4) place(e) color(gs10))

                legend(size(4) position(2) ring(0) bm(t=1 b=2 l=2 r=0) colf cols(1)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) 
                order(1 2) 
                lab(1 "Earlier") 
                lab(2 "Later") 
                )
                name(final) 
                ;
        #delimit cr
