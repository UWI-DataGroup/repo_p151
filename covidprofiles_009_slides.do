** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					covidprofiles_009_slides.do
    //  project:				        
    //  analysts:				       	Ian HAMBLETON
    // 	date last modified	            29-APR-2020
    //  algorithm task			        SLIDES

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
    log using "`logpath'\covidprofiles_009_slides", replace
** HEADER -----------------------------------------------------



** ------------------------------------------------------
** PDF REGIONAL REPORT (COUNTS OF CONFIRMED CASES)
** ------------------------------------------------------
    putpdf begin, pagesize(letter) landscape font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.25cm) margin(left,0.5cm) margin(right,0.25cm)

** PAGE 1. DAILY CURVES
** PAGE 1. TITLE, ATTRIBUTION, DATE of CREATION
    putpdf table intro1 = (1,16), width(100%) halign(left) 
    putpdf table intro1(.,.), border(all, nil)
    putpdf table intro1(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro1(1,1)
    putpdf table intro1(1,2), colspan(15)
    putpdf table intro1(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro1(1,2)=("COVID-19 SLIDE DECK: Surveillance in 20 Caribbean Countries and Territories"), halign(left) linebreak font("Calibri Light", 12, 000000)
    putpdf table intro1(1,2)=("Slide deck created by staff of the George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro1(1,2)=("and the Public Health Group of The Faculty of Medical Sciences, Cave Hill Campus, "), halign(left) append  
    putpdf table intro1(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro1(1,2)=("Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro1(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic   
    putpdf table intro1(1,2)=("For all our COVID-19 surveillance outputs, go to "), halign(left) append
    putpdf table intro1(1,2)=("https://tinyurl.com/uwi-covid19-surveillance "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

** PAGE 1. INTRODUCTION
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("SLIDES. ") , bold
    putpdf text ("In the next few pages we have produced slides for open-access use by anyone wanting to present on COVID-19 surveillance trends in the Caribbean. ")
    putpdf text ("We start with regional overviews, and follow these overviews with country-by-country updates. ") 
    putpdf text (" 20 Caribbean countries and territories are included. The data presented ") 
    putpdf text ("are correct as of $S_DATE. ") 

** SLIDE 2. DAILY NEW CASES
** SLIDE 2. TITLE, ATTRIBUTION, DATE of CREATION
putpdf pagebreak
    putpdf table intro2 = (1,16), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(15)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("REGIONAL COVID-19 DAILY CASES"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
** SLIDE 2. FIGURE 
    putpdf table f2 = (1,1), width(100%) border(all,nil) halign(center)
    putpdf table f2(1,1)=image("`outputpath'/04_TechDocs/heatmap_newcases_$S_DATE.png")

** SLIDE 3. GROWTH CURVES
** SLIDE 3. TITLE, ATTRIBUTION, DATE of CREATION
putpdf pagebreak
    putpdf table intro2 = (1,16), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(15)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("REGIONAL COVID-19 GROWTH RATES"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
** SLIDE 3. FIGURE 
    putpdf table f2 = (1,1), width(100%) border(all,nil) halign(center)
    putpdf table f2(1,1)=image("`outputpath'/04_TechDocs/heatmap_growthrate_$S_DATE.png")

** SLIDE 4. CUMULATIVE CURVES
** SLIDE 4. TITLE, ATTRIBUTION, DATE of CREATION
putpdf pagebreak
    putpdf table intro2 = (1,16), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(15)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("REGIONAL COVID-19 CUMULATIVE CASES"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
** SLIDE 4. FIGURE 
    putpdf table f2 = (1,1), width(100%) border(all,nil) halign(center)
    putpdf table f2(1,1)=image("`outputpath'/04_TechDocs/heatmap_cases_$S_DATE.png")

** SLIDE 5. DEATHS
** SLIDE 5. TITLE, ATTRIBUTION, DATE of CREATION
putpdf pagebreak
    putpdf table intro2 = (1,16), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(15)
    putpdf table intro2(1,1)=image("`outputpath'/04_TechDocs/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("REGIONAL COVID-19 DEATHS"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
** SLIDE 5. FIGURE 
    putpdf table f2 = (1,2), width(100%) border(all,nil) halign(center)
    putpdf table f2(1,1)=image("`outputpath'/04_TechDocs/heatmap_newdeaths_$S_DATE.png")
    putpdf table f2(1,2)=image("`outputpath'/04_TechDocs/heatmap_deaths_$S_DATE.png")


** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    putpdf save "`outputpath'/05_Outputs/test_covid19_uwi_slides_`date_string'", replace
