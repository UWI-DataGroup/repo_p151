** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					cdema_simulation_caribbean.do
    //  project:				        
    //  analysts:				       	Ian HAMBLETON
    // 	date last modified	            04-APR-2020
    //  algorithm task			        Modelling for 14 CARIBBEAN countries - using Imperial Data

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
    log using "`logpath'\cdema_simulation_caribbean", replace
** HEADER -----------------------------------------------------

** LOAD IMPERIAL MODELLING RESULTS
import excel using "`datapath'/version01/1-input/Imperial-College-COVID19-Global-unmitigated-mitigated-suppression-scenarios", sheet("CARICOM") first 
drop r0 strategy social_distance
drop if stype==1
label define stype_ 2 "at 0.2 deaths" 3 "at 1.6 deaths"
label values stype stype_ 

** Country labels
#delimit ; 
label define cid_ 1 "Antigua and Barbuda"
                    2 "The Bahamas"
                    3 "Barbados"
                    4 "Belize"
                    5 "Dominica"
                    6 "Grenada"
                    7 "Guyana"
                    8 "Haiti"
                    9 "Jamaica"
                    10 "Saint Kitts and Nevis"
                    11 "Saint Lucia"
                    12 "Saint Vincent and the Grenadines"
                    13 "Suriname"
                    14 "Trinidad and Tobago"
                    ;
#delimit cr  
label values cid cid_ 

** Adjust Dominica
local country1 "DMA KNA"
foreach clist of local country1 {
    foreach var in total_infected total_deaths total_hospital peak_hospital total_critical peak_critical {
        replace `var' = int(`var'/adjustment) if iso=="`clist'"
    }
}
replace trigger = trigger/adjustment if iso=="DMA"
replace trigger = trigger/adjustment if iso=="KNA"


** We want the various numbers held as macros for the PDF
local country "ATG BHS BRB BLZ DMA GRD GUY HTI JAM KNA LCA VCT SUR TTO"
local a=1
local b=2
foreach clist of local country {

    local `clist'_hosp_lo = total_hospital[`a']
    local `clist'_hosp_hi = total_hospital[`b']

    local `clist'_hpeak_lo = peak_hospital[`a']
    local `clist'_hpeak_hi = peak_hospital[`b']

    local `clist'_crit_lo = total_critical[`a']
    local `clist'_crit_hi = total_critical[`b']

    local `clist'_cpeak_lo = peak_critical[`a']
    local `clist'_cpeak_hi = peak_critical[`b']

    local a = `a'+2
    local b = `b'+2
}


** ------------------------------------------------------
** PDF REGIONAL REPORT (COUNTS OF CONFIRMED CASES)
** ------------------------------------------------------
    putpdf begin, pagesize(letter) font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.25cm) margin(left,0.5cm) margin(right,0.25cm)

** TITLE, ATTRIBUTION, DATE of CREATION
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Estimates of healthcare demand due to COVID-19 in 14 CARICOM countries "), bold linebreak
    putpdf paragraph ,  font("Calibri Light", 8)
    putpdf text ("Briefing created by staff of the George Alleyne Chronic Disease Research Centre ") 
    putpdf text ("and the Public Health Group of The Faculty of Medical Sciences, Cave Hill Campus, ") 
    putpdf text ("The University of the West Indies. ")
    putpdf text ("Contact Ian Hambleton (ian.hambleton@cavehill.uwi.edu) "), italic
    putpdf text ("for details of quantitative analyses. "), font("Calibri Light", 8) italic
    putpdf text ("Contact Maddy Murphy (madhuvanti.murphy@cavehill.uwi.edu) "), italic 
    putpdf text ("for details of national public health interventions and policy implications."), font("Calibri Light", 8) italic
    putpdf text ("Updated on: $S_DATE at $S_TIME"), font("Calibri Light", 8) bold italic

** INTRODUCTION
    putpdf paragraph ,  font("Calibri Light", 9)
    putpdf text ("The estimates we provide in this briefing. ") , bold
    putpdf text ("We present modelled estimates") 
    putpdf text (" 1"), script(super) 
    putpdf text (" of healthcare demand during the current COVID-19 epidemic for 14 CARICOM member states. ")
    putpdf text (" We provide four sets of estimates: "), linebreak 
    putpdf paragraph, font("Calibri Light", 9) indent(left, 1cm)
    putpdf text ("(1) The number of people needing acute (hospital) care over the duration of the epidemic") , linebreak
    putpdf text ("(2) The number of people needing critical (intensive) care over the duration of the epidemic") , linebreak
    putpdf text ("(3) The number of people needing acute care at peak demand") , linebreak
    putpdf text ("(4) The number of people needing critical care at peak demand") , linebreak
    putpdf paragraph ,  font("Calibri Light", 9)
    putpdf text ("These estimates assume a national strategy of COVID-19 suppression.  "), bold
    putpdf text ("Many CARICOM countries have already implemented ") 
    putpdf text ("suppression "), italic 
    putpdf text ("strategies to encourage wide-scale intensive social-distancing. ")
    putpdf text ("These estimates assume a 75% reduction in interpersonal contact. ")
    putpdf text ("By delaying the spread of COVID-19 in this way, ") 
    putpdf text ("countries can reduce the surge in demand for healthcare ") 
    putpdf text ("(known as flattening the curve), ") 
    putpdf text ("allowing healthcare systems to better cope with demand and minimise deaths.")

** SUPPRESSION TRIGGERS
    putpdf paragraph ,  font("Calibri Light", 9)
    putpdf text ("How to use these estimates. "), bold
    putpdf text ("For each country, we offer a range (") 
    putpdf text ("low ") , font("Calibri Light", 9, 00802b)
    putpdf text ("to ") 
    putpdf text ("high"), font("Calibri Light", 9, cc0000)
    putpdf text (") of people that will need acute care, critical care, and so on. ") 
    putpdf text ("This estimate range is based on ") 
    putpdf text ("when "), bold 
    putpdf text ("a country implements suppression strategies (earlier or later). ")
    putpdf text ("In column 2 of the Table we list the trigger for starting suppression. It is based on the number of deaths. ")
    putpdf text ("If a country has implemented ") 
    putpdf text ("early suppression ") , font("Calibri Light", 9, 00802b)
    putpdf text ("it could anticipate estimates nearer the ") 
    putpdf text ("green number"), font("Calibri Light", 9, 00802b)
    putpdf text (". If a country has implemented ") 
    putpdf text ("later suppression ") , font("Calibri Light", 9, cc0000)
    putpdf text ("it should anticipate estimates nearer the ") 
    putpdf text ("red number"), font("Calibri Light", 9, cc0000)
    putpdf text (".")    
    
** NOTE ON SURVEILLANCE
    putpdf paragraph ,  font("Calibri Light", 9)
    putpdf text ("Now we must test. Now we must monitor. ") , bold
    putpdf text ("Testing and monitoring are now critical to the success in managing this outbreak. ") 
    putpdf text ("Widescale testing allows countries to identify and isolate infected citizens. ") 
    putpdf text ("Daily surveillance for new cases and new deaths allows countries to assess whether the national response is working. ") 
    putpdf text ("Daily surveillance of new hospitalisations allows countries to closely monitor healthcare capacity. ") 

** NOTE ON PREDICTIONS
    putpdf paragraph ,  font("Calibri Light", 9)
    putpdf text ("These estimates are for guidance only. ") , bold
    putpdf text ("These estimates are based on many assumptions, and represent a ") 
    putpdf text ("best guess "), italic 
    putpdf text ("of the future, given one specific scenario. ") 
    putpdf text ("The actual size of the healthcare burden will be determined by the actions that ") 
    putpdf text ("governments and countries take in the coming weeks, and the ") 
    putpdf text ("behaviour changes that occur as a result of those actions.")

** TABLE OF HOSPITAL DEMAND
putpdf paragraph ,  font("Calibri Light", 9)
putpdf text ("Table. "), bold
putpdf text ("Numbers of people requiring acute care or critical care ")
putpdf text ("over the full epidemic duration "), italic
putpdf text ("and at ")
putpdf text ("peak demand "), italic
putpdf text ("given national suppression strategies"), linebreak
putpdf table t1 = (15,5), width(100%) halign(center) 
putpdf table t1(.,.), font("Calibri Light", 9)
putpdf table t1(1,1)=("COUNTRY"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(1,2)=("No. of people needing acute care"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(1,3)=("No. of people needing critical care"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(1,4)=("Peak demand for acute care"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(1,5)=("Peak demand for critical care"), halign(center) border(top) border(bottom) border(left) border(right)

** COL 1: COUNTRY NAMES
putpdf table t1(2,1)=("Antigua and Barbuda"), halign(center) border(top) border(bottom) border(left) border(right) 
putpdf table t1(3,1)=("The Bahamas"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(4,1)=("Barbados"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(5,1)=("Belize"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(6,1)=("Dominica"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(7,1)=("Grenada"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(8,1)=("Guyana"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(9,1)=("Haiti"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(10,1)=("Jamaica"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(11,1)=("St Kitts and Nevis"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(12,1)=("St Lucia"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(13,1)=("St Vincent"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(14,1)=("Suriname"), halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(15,1)=("Trinidad and Tobago"), halign(center) border(top) border(bottom) border(left) border(right)


/// COL 2: HOSPITAL DEMAND
putpdf table t1(2,2)=("`ATG_hosp_lo' ") , font("Calibri Light", 9, 00802b)  nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(2,2)=(" to ") , append
putpdf table t1(2,2)=("`ATG_hosp_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

putpdf table t1(3,2)=("`BHS_hosp_lo' ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(3,2)=(" to ") , append
putpdf table t1(3,2)=("`BHS_hosp_hi' "), font("Calibri Light", 9, cc0000) nformat(%5.0fc) append

putpdf table t1(4,2)=("`BRB_hosp_lo' ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(4,2)=(" to ") , append
putpdf table t1(4,2)=("`BRB_hosp_hi' "), font("Calibri Light", 9, cc0000) nformat(%5.0fc) append 

putpdf table t1(5,2)=("`BLZ_hosp_lo' ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(5,2)=(" to ") , append
putpdf table t1(5,2)=("`BLZ_hosp_hi' "), font("Calibri Light", 9, cc0000) nformat(%5.0fc) append 

putpdf table t1(6,2)=("`DMA_hosp_lo' ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(6,2)=(" to ") , append
putpdf table t1(6,2)=("`DMA_hosp_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

putpdf table t1(7,2)=("`GRD_hosp_lo' ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(7,2)=(" to ") , append
putpdf table t1(7,2)=("`GRD_hosp_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

putpdf table t1(8,2)=("`GUY_hosp_lo' ") , font("Calibri Light", 9, 00802b) nformat(%5.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(8,2)=(" to ") , append
putpdf table t1(8,2)=("`GUY_hosp_hi' "), font("Calibri Light", 9, cc0000) nformat(%5.0fc) append 

putpdf table t1(9,2)=("`HTI_hosp_lo' ") , font("Calibri Light", 9, 00802b) nformat(%6.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(9,2)=(" to ") , append
putpdf table t1(9,2)=("`HTI_hosp_hi' "), font("Calibri Light", 9, cc0000) nformat(%6.0fc) append 

putpdf table t1(10,2)=("`JAM_hosp_lo' ") , font("Calibri Light", 9, 00802b) nformat(%5.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(10,2)=(" to ") , append
putpdf table t1(10,2)=("`JAM_hosp_hi' "), font("Calibri Light", 9, cc0000) nformat(%6.0fc) append 

putpdf table t1(11,2)=("`KNA_hosp_lo' ") , font("Calibri Light", 9, 00802b) nformat(%2.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(11,2)=(" to ") , append
putpdf table t1(11,2)=("`KNA_hosp_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

putpdf table t1(12,2)=("`LCA_hosp_lo' ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(12,2)=(" to ") , append
putpdf table t1(12,2)=("`LCA_hosp_hi' "), font("Calibri Light", 9, cc0000) nformat(%5.0fc) append 

putpdf table t1(13,2)=("`VCT_hosp_lo' ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(13,2)=(" to ") , append
putpdf table t1(13,2)=("`VCT_hosp_hi' "), font("Calibri Light", 9, cc0000) nformat(%5.0fc) append 

putpdf table t1(14,2)=("`SUR_hosp_lo' ") , font("Calibri Light", 9, 00802b) nformat(%5.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(14,2)=(" to ") , append
putpdf table t1(14,2)=("`SUR_hosp_hi' "), font("Calibri Light", 9, cc0000) nformat(%5.0fc) append 

putpdf table t1(15,2)=("`TTO_hosp_lo' ") , font("Calibri Light", 9, 00802b) nformat(%5.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(15,2)=(" to ") , append
putpdf table t1(15,2)=("`TTO_hosp_hi' "), font("Calibri Light", 9, cc0000) nformat(%6.0fc) append 


/// COL 3: CRITICAL CARE DEMAND
putpdf table t1(2,3)=("`ATG_crit_lo' ") , font("Calibri Light", 9, 00802b) nformat(%2.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(2,3)=(" to ") , append
putpdf table t1(2,3)=("`ATG_crit_hi' "), font("Calibri Light", 9, cc0000) nformat(%2.0fc) append 

putpdf table t1(3,3)=("`BHS_crit_lo' ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(3,3)=(" to ") , append
putpdf table t1(3,3)=("`BHS_crit_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

putpdf table t1(4,3)=("`BRB_crit_lo' ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(4,3)=(" to ") , append
putpdf table t1(4,3)=("`BRB_crit_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

putpdf table t1(5,3)=("`BLZ_crit_lo' ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(5,3)=(" to ") , append
putpdf table t1(5,3)=("`BLZ_crit_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

putpdf table t1(6,3)=("`DMA_crit_lo' ") , font("Calibri Light", 9, 00802b) nformat(%2.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(6,3)=(" to ") , append
putpdf table t1(6,3)=("`DMA_crit_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

putpdf table t1(7,3)=("`GRD_crit_lo' ") ,font("Calibri Light", 9, 00802b)  nformat(%2.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(7,3)=(" to ") , append
putpdf table t1(7,3)=("`GRD_crit_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

putpdf table t1(8,3)=("`GUY_crit_lo' ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(8,3)=(" to ") , append
putpdf table t1(8,3)=("`GUY_crit_hi' "), font("Calibri Light", 9, cc0000) nformat(%5.0fc) append 

putpdf table t1(9,3)=("`HTI_crit_lo' ") , font("Calibri Light", 9, 00802b) nformat(%5.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(9,3)=(" to ") , append
putpdf table t1(9,3)=("`HTI_crit_hi' "), font("Calibri Light", 9, cc0000) nformat(%6.0fc) append 

putpdf table t1(10,3)=("`JAM_crit_lo' ") , font("Calibri Light", 9, 00802b) nformat(%5.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(10,3)=(" to ") , append
putpdf table t1(10,3)=("`JAM_crit_hi' "), font("Calibri Light", 9, cc0000) nformat(%5.0fc) append 

putpdf table t1(11,3)=("`KNA_crit_lo' ") , font("Calibri Light", 9, 00802b) nformat(%2.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(11,3)=(" to ") , append
putpdf table t1(11,3)=("`KNA_crit_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

putpdf table t1(12,3)=("`LCA_crit_lo' ") , font("Calibri Light", 9, 00802b) nformat(%2.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(12,3)=(" to ") , append
putpdf table t1(12,3)=("`LCA_crit_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

putpdf table t1(13,3)=("`VCT_crit_lo' ") , font("Calibri Light", 9, 00802b) nformat(%2.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(13,3)=(" to ") , append
putpdf table t1(13,3)=("`VCT_crit_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

putpdf table t1(14,3)=("`SUR_crit_lo' ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(14,3)=(" to ") , append
putpdf table t1(14,3)=("`SUR_crit_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

putpdf table t1(15,3)=("`TTO_crit_lo' ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(15,3)=(" to ") , append
putpdf table t1(15,3)=("`TTO_crit_hi' "), font("Calibri Light", 9, cc0000) nformat(%5.0fc) append 


/// COL 4: ACUTE PEAK DEMAND
putpdf table t1(2,4)=("`ATG_hpeak_lo' ") , font("Calibri Light", 9, 00802b) nformat(%2.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(2,4)=(" to ") , append
putpdf table t1(2,4)=("`ATG_hpeak_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

putpdf table t1(3,4)=("`BHS_hpeak_lo' ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(3,4)=(" to ") , append
putpdf table t1(3,4)=("`BHS_hpeak_hi' "), font("Calibri Light", 9, cc0000) nformat(%5.0fc) append 

putpdf table t1(4,4)=("`BRB_hpeak_lo' ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(4,4)=(" to ") , append
putpdf table t1(4,4)=("`BRB_hpeak_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

putpdf table t1(5,4)=("`BLZ_hpeak_lo' ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(5,4)=(" to ") , append
putpdf table t1(5,4)=("`BLZ_hpeak_hi' "), font("Calibri Light", 9, cc0000) nformat(%5.0fc) append 

putpdf table t1(6,4)=("`DMA_hpeak_lo' ") , font("Calibri Light", 9, 00802b) nformat(%2.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(6,4)=(" to ") , append
putpdf table t1(6,4)=("`DMA_hpeak_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

putpdf table t1(7,4)=("`GRD_hpeak_lo' ") , font("Calibri Light", 9, 00802b) nformat(%2.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(7,4)=(" to ") , append
putpdf table t1(7,4)=("`GRD_hpeak_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

putpdf table t1(8,4)=("`GUY_hpeak_lo' ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(8,4)=(" to ") , append
putpdf table t1(8,4)=("`GUY_hpeak_hi' "), font("Calibri Light", 9, cc0000) nformat(%5.0fc) append 

putpdf table t1(9,4)=("`HTI_hpeak_lo' ") , font("Calibri Light", 9, 00802b) nformat(%5.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(9,4)=(" to ") , append
putpdf table t1(9,4)=("`HTI_hpeak_hi' "), font("Calibri Light", 9, cc0000) nformat(%6.0fc) append 

putpdf table t1(10,4)=("`JAM_hpeak_lo' ") , font("Calibri Light", 9, 00802b) nformat(%5.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(10,4)=(" to ") , append
putpdf table t1(10,4)=("`JAM_hpeak_hi' "), font("Calibri Light", 9, cc0000) nformat(%5.0fc) append 

putpdf table t1(11,4)=("`KNA_hpeak_lo' ") , font("Calibri Light", 9, 00802b) nformat(%2.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(11,4)=(" to ") , append
putpdf table t1(11,4)=("`KNA_hpeak_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

putpdf table t1(12,4)=("`LCA_hpeak_lo' ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(12,4)=(" to ") , append
putpdf table t1(12,4)=("`LCA_hpeak_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

putpdf table t1(13,4)=("`VCT_hpeak_lo' ") , font("Calibri Light", 9, 00802b) nformat(%2.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(13,4)=(" to ") , append
putpdf table t1(13,4)=("`VCT_hpeak_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

putpdf table t1(14,4)=("`SUR_hpeak_lo' ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(14,4)=(" to ") , append
putpdf table t1(14,4)=("`SUR_hpeak_hi' "), font("Calibri Light", 9, cc0000) nformat(%5.0fc) append 

putpdf table t1(15,4)=("`TTO_hpeak_lo' ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(15,4)=(" to ") , append
putpdf table t1(15,4)=("`TTO_hpeak_hi' "), font("Calibri Light", 9, cc0000) nformat(%5.0fc) append 


/// COL 5: CRITICAL PEAK DEMAND
putpdf table t1(2,5)=("`ATG_cpeak_lo' ") , font("Calibri Light", 9, 00802b) nformat(%1.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(2,5)=(" to ") , append
putpdf table t1(2,5)=("`ATG_cpeak_hi' "), font("Calibri Light", 9, cc0000) nformat(%2.0fc) append 

putpdf table t1(3,5)=("`BHS_cpeak_lo' ") , font("Calibri Light", 9, 00802b) nformat(%2.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(3,5)=(" to ") , append
putpdf table t1(3,5)=("`BHS_cpeak_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

putpdf table t1(4,5)=("`BRB_cpeak_lo' ") , font("Calibri Light", 9, 00802b) nformat(%2.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(4,5)=(" to ") , append
putpdf table t1(4,5)=("`BRB_cpeak_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

putpdf table t1(5,5)=("`BLZ_cpeak_lo' ") , font("Calibri Light", 9, 00802b) nformat(%2.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(5,5)=(" to ") , append
putpdf table t1(5,5)=("`BLZ_cpeak_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

putpdf table t1(6,5)=("`DMA_cpeak_lo' ") , font("Calibri Light", 9, 00802b) nformat(%1.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(6,5)=(" to ") , append
putpdf table t1(6,5)=("`DMA_cpeak_hi' "), font("Calibri Light", 9, cc0000) nformat(%2.0fc) append 

putpdf table t1(7,5)=("`GRD_cpeak_lo' ") , font("Calibri Light", 9, 00802b) nformat(%2.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(7,5)=(" to ") , append
putpdf table t1(7,5)=("`GRD_cpeak_hi' "), font("Calibri Light", 9, cc0000) nformat(%2.0fc) append 

putpdf table t1(8,5)=("`GUY_cpeak_lo' ") , font("Calibri Light", 9, 00802b) nformat(%2.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(8,5)=(" to ") , append
putpdf table t1(8,5)=("`GUY_cpeak_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

putpdf table t1(9,5)=("`HTI_cpeak_lo' ") , font("Calibri Light", 9, 00802b) nformat(%5.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(9,5)=(" to ") , append
putpdf table t1(9,5)=("`HTI_cpeak_hi' "), font("Calibri Light", 9, cc0000) nformat(%5.0fc) append 

putpdf table t1(10,5)=("`JAM_cpeak_lo' ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(10,5)=(" to ") , append
putpdf table t1(10,5)=("`JAM_cpeak_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

putpdf table t1(11,5)=("`KNA_cpeak_lo' ") , font("Calibri Light", 9, 00802b) nformat(%1.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(11,5)=(" to ") , append
putpdf table t1(11,5)=("`KNA_cpeak_hi' "), font("Calibri Light", 9, cc0000) nformat(%2.0fc) append 

putpdf table t1(12,5)=("`LCA_cpeak_lo' ") , font("Calibri Light", 9, 00802b) nformat(%2.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(12,5)=(" to ") , append
putpdf table t1(12,5)=("`LCA_cpeak_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

putpdf table t1(13,5)=("`VCT_cpeak_lo' ") , font("Calibri Light", 9, 00802b) nformat(%2.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(13,5)=(" to ") , append
putpdf table t1(13,5)=("`VCT_cpeak_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

putpdf table t1(14,5)=("`SUR_cpeak_lo' ") , font("Calibri Light", 9, 00802b) nformat(%2.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(14,5)=(" to ") , append
putpdf table t1(14,5)=("`SUR_cpeak_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

putpdf table t1(15,5)=("`TTO_cpeak_lo' ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(15,5)=(" to ") , append
putpdf table t1(15,5)=("`TTO_cpeak_hi' "), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

** ADD COL 2: TRIGGER VALUES
putpdf table t1(.,1), addcols(1)
putpdf table t1(1,2), bgcolor(cccccc) font("Calibri Light", 9)
putpdf table t1(1,2)=("Trigger Value (# deaths)"), halign(center) border(left)  

** ATG
putpdf table t1(2,2)=("Earlier (0) ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(2,2)=(" / ") , append
putpdf table t1(2,2)=("Later (2)"), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

** BHS 
putpdf table t1(3,2)=("Earlier (1) ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(3,2)=(" / ") , append
putpdf table t1(3,2)=("Later (6)"), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

** BRB
putpdf table t1(4,2)=("Earlier (1) ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(4,2)=(" / ") , append
putpdf table t1(4,2)=("Later (5)"), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

** BLZ 
putpdf table t1(5,2)=("Earlier (1) ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(5,2)=(" / ") , append
putpdf table t1(5,2)=("Later (6)"), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

** DMA 
putpdf table t1(6,2)=("Earlier (0) ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(6,2)=(" / ") , append
putpdf table t1(6,2)=("Later (1)"), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

** GRD 
putpdf table t1(7,2)=("Earlier (0) ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(7,2)=(" / ") , append
putpdf table t1(7,2)=("Later (2)"), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

** GUY 
putpdf table t1(8,2)=("Earlier (2) ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(8,2)=(" / ") , append
putpdf table t1(8,2)=("Later (13)"), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

** HTI 
putpdf table t1(9,2)=("Earlier (23) ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(9,2)=(" / ") , append
putpdf table t1(9,2)=("Later (182)"), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

** JAM 
putpdf table t1(10,2)=("Earlier (6) ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(10,2)=(" / ") , append
putpdf table t1(10,2)=("Later (47)"), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

** KNA 
putpdf table t1(11,2)=("Earlier (0) ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(11,2)=(" / ") , append
putpdf table t1(11,2)=("Later (1)"), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

** SLA 
putpdf table t1(12,2)=("Earlier (0) ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(12,2)=(" / ") , append
putpdf table t1(12,2)=("Later (3)"), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

** VCT 
putpdf table t1(13,2)=("Earlier (0) ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(13,2)=(" / ") , append
putpdf table t1(13,2)=("Later (2)"), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

** SUR 
putpdf table t1(14,2)=("Earlier (1) ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(14,2)=(" / ") , append
putpdf table t1(14,2)=("Later (9)"), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

** TTO 
putpdf table t1(15,2)=("Earlier (3) ") , font("Calibri Light", 9, 00802b) nformat(%3.0fc) halign(center) border(top) border(bottom) border(left) border(right)
putpdf table t1(15,2)=(" / ") , append
putpdf table t1(15,2)=("Later (22)"), font("Calibri Light", 9, cc0000) nformat(%3.0fc) append 

** GREY SCALE
putpdf table t1(1,.), bgcolor(cccccc)
putpdf table t1(.,1), bgcolor(cccccc)

** ADD ROWS 16 and 17: TRIGGER LEGEND
putpdf table t1(15,.), addrows(2)
putpdf table t1(16,1), bgcolor(29a329) font("Calibri Light", 8) 
putpdf table t1(17,1), bgcolor(ff704d) font("Calibri Light", 8) 
putpdf table t1(16,2)=("Suppression triggered when death rate reaches 0.2 deaths per 100,000 per week"), font("Calibri Light", 8) colspan(5) halign(left) border(left) 
putpdf table t1(17,2)=("Suppression triggered when death rate reaches 1.6 deaths per 100,000 per week"), font("Calibri Light", 8) colspan(5) halign(left) border(left) 

** DATA REFERENCE
    putpdf table p3 = (1,1), width(100%) halign(center) 
    putpdf table p3(1,1), font("Calibri Light", 8) border(all,nil,000000) bgcolor(ffffff)
    putpdf table p3(1,1)=("(1) Data Source. "), bold halign(left)
    putpdf table p3(1,1)=("Walker PGT, Whittaker C. Report 12 - The global impact of COVID-19 and strategies for mitigation and suppression. "), append 
    putpdf table p3(1,1)=("Available at: http://www.imperial.ac.uk/mrc-global-infectious-disease-analysis/covid-19/"), append

** Save the PDF
    local c_date = c(current_date)
    local c_time = c(current_time)
    local c_time_date = "`c_date'"+"_" +"`c_time'"
    local time_string = subinstr("`c_time_date'", ":", "_", .)
    local time_string = subinstr("`time_string'", " ", "", .)
    putpdf save "`outputpath'/05_Outputs/covid19_modelling_caricom_`time_string'", replace
///    putpdf save "`outputpath'/05_Outputs/covid19_models_caricom", replace
