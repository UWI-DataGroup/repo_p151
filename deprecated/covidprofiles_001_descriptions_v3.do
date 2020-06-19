
** DO file descriptions
** 27-APR-2020
** Produced by: Ian R Hambleton

** VERSION 3
** ACTIVE FILES LISTED FIRST
** THEN THE DEPFRECATED FILES

** -----------------------------------------------------------------
*! DO FILE: cdema_simulation_barbados.do 
*! (ARCHIVAL MODEL)
** -----------------------------------------------------------------
** LOCAL PATH: X:\OneDrive - The University of the West Indies\repo_datagroup\repo_p151\
** GitHub PATH: :https://github.com/UWI-DataGroup/repo_p151
**
** DESCRIPTION
** Imports the 100 simulated runs of the SEIR model for Barbados
** Creates tabulation + graphics for the following metrics:
**      - # infections
**      - # people requiring acute hosiptal care
**      - # people requiring critical hospital (ICU) care 
** Model runs under 4 scenarios:
**      - un-mitigated - no policy response to infection
**      - 65% transission reduction
**      - 75% transission reduction
**      - 85% transission reduction
**      - 95% transission reduction
** DO file auto-creates a PDF report for easy updating if model tweaked
** or if similar report required for other countries 
** -----------------------------------------------------------------

** -----------------------------------------------------------------
*! DO FILE: cdema_simulation_antigua.do 
*! (ARCHIVAL MODEL)
** -----------------------------------------------------------------
** LOCAL PATH: X:\OneDrive - The University of the West Indies\repo_datagroup\repo_p151\
** GitHub PATH: :https://github.com/UWI-DataGroup/repo_p151
**
** DESCRIPTION
** Does the same as above, for ANTIGUA and BARBUDA.  
** -----------------------------------------------------------------

** -----------------------------------------------------------------
*! DO FILE: cdema_simulation_001.do 
*! (ARCHIVAL MODEL PREPARATION)
** -----------------------------------------------------------------
** LOCAL PATH: X:\OneDrive - The University of the West Indies\repo_datagroup\repo_p151\
** GitHub PATH: :https://github.com/UWI-DataGroup/repo_p151
**
** DESCRIPTION
** Load UN WPP (2019) population data downloaded from:
**      --> https://population.un.org/wpp/Download/Standard/Population/
** Create THREE different age groupings for:
**      --> SEIR model (CDC). 9 age groups
**      --> Imperial College COVID-19 paper (Report #9). 9 age groups
**      --> COVI-19 resource modelling in R (not used). 7 age groups  
** Save Stata file:
**      --> population_001
** -----------------------------------------------------------------

** -----------------------------------------------------------------
*! DO FILE: cdema_simulation_002.do 
*! (ARCHIVAL MODEL PREPARATION)
** -----------------------------------------------------------------
** LOCAL PATH: X:\OneDrive - The University of the West Indies\repo_datagroup\repo_p151\
** GitHub PATH: :https://github.com/UWI-DataGroup/repo_p151
**
** DESCRIPTION
** Tabulate total populations (for estimate report) 
** Tabulate over-70 population (for estimate report) 
** Tabulate population size by age groups creaed in cdema_simulation_001
** We use these stratifications in:
**      --> Our estimates modelling (SEIR model)
**      --> Our Stata coding, preparing the estimates reporting 
** -----------------------------------------------------------------

** -----------------------------------------------------------------
*! DO FILE: cdema_trajectory_001.do 
*! LOAD THE DAILY JHOPKINS DATA
** -----------------------------------------------------------------
** LOCAL PATH: X:\OneDrive - The University of the West Indies\repo_datagroup\repo_p151\
** GitHub PATH: :https://github.com/UWI-DataGroup/repo_p151
**
** DESCRIPTION
** Read the daily COVID-19 dataset update from Johns Hopkins
**      --> https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/
** Including some basic dataset tweaks to account for changes in JH
** dataset format over time. DO file can take a while as it accesses the internet, 
** so save the file for further data management in next DO file.  
** -----------------------------------------------------------------


** -----------------------------------------------------------------
*! DO FILE: cdema_trajectory_002.do 
*! (ARCHIVAL DO FILE)
** -----------------------------------------------------------------
** LOCAL PATH: X:\OneDrive - The University of the West Indies\repo_datagroup\repo_p151\
** GitHub PATH: :https://github.com/UWI-DataGroup/repo_p151
**
** 
** EXAMPLE CODING USING BARBADOS
** FOR FINAL VERSION USING ALL 14 CARICOM MEMBERS - SEE cdema_trajectory_003.do
** DESCRIPTION
** Prepare example CONFIRMED CASES briefing
** Extract data for FOUR comparator countries: Singapore, Sth Korea, UK, US
** And we compare each Caribbean country against these comparators
**
** We calculate the number of elapsed days since start of outbreak
** defined as the first reported CONFIRMED case.
**
** We then simply plot cumulative cases for all countries over this 
** period of elapsed time
** -----------------------------------------------------------------


** -----------------------------------------------------------------
*! DO FILE: cdema_trajectory_003.do
*! COUNTRY SPECIFIC DAILY BRIEFING
** -----------------------------------------------------------------
** LOCAL PATH: X:\OneDrive - The University of the West Indies\repo_datagroup\repo_p151\
** GitHub PATH: :https://github.com/UWI-DataGroup/repo_p151
**
** 
** DESCRIPTION
** Prepare example CONFIRMED CASES briefing
** Extract data for FOUR comparator countries: Singapore, Sth Korea, UK, US
** And we compare each of the 14 CARISOM member states against these comparators
**
** We calculate the number of elapsed days since start of outbreak
** defined as the first reported CONFIRMED case.
**
** We then simply plot cumulative cases for all countries over this 
** period of elapsed time
** -----------------------------------------------------------------


** -----------------------------------------------------------------
*! DO FILE: cdema_trajectory_004.do
*! REGIONAL SUMMARY OF NUMBER OF CONFIRMED CASES
** -----------------------------------------------------------------
** LOCAL PATH: X:\OneDrive - The University of the West Indies\repo_datagroup\repo_p151\
** GitHub PATH: :https://github.com/UWI-DataGroup/repo_p151
**
** 
** DESCRIPTION
** Prepare example CONFIRMED CASES briefing
** Extract data for FOUR comparator countries: Singapore, Sth Korea, UK, US
** And we compare each of the 14 CARISOM member states against these comparators
**
** We calculate the number of elapsed days since start of outbreak
** defined as the first reported CONFIRMED case.
**
** We then simply plot cumulative cases for all countries over this 
** period of elapsed time
** -----------------------------------------------------------------



** -----------------------------------------------------------------
*! DO FILE: cdema_trajectory_005.do
*! HEATMAP. COUNTRIES on Y. DAYS on X. COLOR CODE
*! ACCORDING TO ABSOLUTE SIZE OF OUTBREAK IN EACH COUNTRY.
*! CUMULATIVE CONFIRMED CASES
** -----------------------------------------------------------------
** LOCAL PATH: X:\OneDrive - The University of the West Indies\repo_datagroup\repo_p151\
** GitHub PATH: :https://github.com/UWI-DataGroup/repo_p151
**
** 
** DESCRIPTION
** Prepare HEATMAP visualising the CONFIRMED CASES and CONFIRMED DEATHS
** The idea is to provide an immediate visual summary of hotspots
** -----------------------------------------------------------------



** -----------------------------------------------------------------
*! DO FILE: cdema_trajectory_006.do
*! TABULAR GRAPHICS BY COUNTRY SHOWING GROWING BAR CHARTS OF 
*! CUMULATIVE CONFIRMED CASES
*! USE THE "DOUBLING" METRIC
** -----------------------------------------------------------------
** LOCAL PATH: X:\OneDrive - The University of the West Indies\repo_datagroup\repo_p151\
** GitHub PATH: :https://github.com/UWI-DataGroup/repo_p151
**
** CARICOM summary data
** PLOT of CUMULATIVE CARICOM cases (probably line chart)
** Include population variable in dataset 
** Calculate # new cases EACH DAY
** Calculate RATE OF DOUBLING for each day
**
** Perhaps a Table of doubling rate for each of the 14 members, along with SPARK barcharts
** Perhaps include rate of doubling in some KEY successful countries
** -----------------------------------------------------------------


** -----------------------------------------------------------------
*! DO FILE: cdema_trajectory_xxx.do
*! TABULAR GRAPHICS BY COUNTRY SHOWING GROWING BAR CHARTS OF 
*! CUMULATIVE CONFIRMED CASES
*! USE THE "DOUBLING" METRIC
** -----------------------------------------------------------------


** -----------------------------------------------------------------
*! DO FILE: cdema_trajectory_xxx.do
*! ATTACK RATE - SIMILAR TO THE REGIONAL BRIEFING 
*! cdema_trajectory_004.do
** -----------------------------------------------------------------


** -----------------------------------------------------------------
*! DO FILE: cdema_trajectory_xxx.do
*! ATTACK RATE - SIMILAR TO THE REGIONAL BRIEFING 
*! cdema_trajectory_004.do
** -----------------------------------------------------------------



** -----------------------------------------------------------------
*! OTHER CODE
** -----------------------------------------------------------------
** -----------------------------------------------------------------
*! DO FILE: 
*! cdema_simulation_presentation_graphics.do
*! cdema_simulation_presentation_graphics2.do
*! cdema_trajectory_004_presentation.do
*! cdema_trajectory_006_presentation.do
** -----------------------------------------------------------------
** LOCAL PATH: X:\OneDrive - The University of the West Indies\repo_datagroup\repo_p151\
** GitHub PATH: :https://github.com/UWI-DataGroup/repo_p151
**
** DESCRIPTION
** Produces PPTX-friendly graphics for various presentations to CDEMA, COHSOD, and Heads of Government
** up to and including 15-APR-2020 
** -----------------------------------------------------------------







** 17 APRIL 2020
** RE-WRITE FOR COMPLETE AUTOMATION

** -----------------------------------------------------------------
*! DO FILE: covidprofiles_002_jhopkins.do 
*! LOAD THE DAILY JHOPKINS DATA
** -----------------------------------------------------------------
** LOCAL PATH: X:\OneDrive - The University of the West Indies\repo_datagroup\repo_p151\
** GitHub PATH: :https://github.com/UWI-DataGroup/repo_p151
**
** DESCRIPTION
** Read the daily COVID-19 dataset update from Johns Hopkins
**      --> https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/
** Including some basic dataset tweaks to account for changes in JH
** dataset format over time. DO file can take a while as it accesses the internet, 
** so save the file for further data management in next DO file.  
** -----------------------------------------------------------------


** -----------------------------------------------------------------
*! DO FILE: covidprofiles_003_initialprep.do 
*! COUNTRY SPECIFIC DAILY BRIEFING
** -----------------------------------------------------------------
** LOCAL PATH: X:\OneDrive - The University of the West Indies\repo_datagroup\repo_p151\
** GitHub PATH: :https://github.com/UWI-DataGroup/repo_p151
**
** 
** DESCRIPTION
** Initia preparation of JHopkins downoad.
** Involves some cleaning, then country restrictions.
**
** And this includes the morning check for updates to cases since the 7pm JHopkins release
** -----------------------------------------------------------------

