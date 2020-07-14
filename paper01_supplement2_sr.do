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


** ------------------------------------------------------
** PDF - MOVEMENT DATA
** ------------------------------------------------------
    putpdf begin, pagesize(letter) font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.25cm) margin(left,0.5cm) margin(right,0.25cm)

** PAGE 1. TITLE, ATTRIBUTION, DATE of CREATION
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("Supplement. "), bold font("Calibri Light", 13, 000000)
    putpdf table intro2(1,2)=("Flowchart depicting Caribbean country inclusions."), append halign(left) linebreak font("Calibri Light", 13, 000000)
    ** putpdf table intro2(1,2)=("(Created on: $S_DATE)"), halign(left) append  font("Calibri Light", 11, 000000) 
    putpdf table intro2(1,16)=("Page 1 of 6"), halign(right)  font("Calibri Light", 11, 8c8c8c) linebreak
    putpdf table intro2(1,16)=("Created: $S_DATE"), halign(right)  font("Calibri Light", 11, 8c8c8c) append

** FIGURES - ANTIGUA, BAHAMAS, BARBADOS 
    putpdf table f2 = (1,1), width(75%) border(all,nil) halign(center)
    putpdf table f2(1,1)=image("`outputpath'/05_Outputs_Papers\01_NPIs_progressreport\Research in Globalization\Re-Submission\background\Country_Inclusion_Flowchart.png")

** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    putpdf save "`outputpath'/05_Outputs_Papers\01_NPIs_progressreport\Research in Globalization\Re-Submission\background/supplement2_covid19_flowchart_`date_string'", replace
    

