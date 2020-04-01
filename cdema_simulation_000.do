
** DO file descriptions
** Verion 1.0.0
** 30-MAR-2020
** Produced by: Ian R Hambleton

** -----------------------------------------------------------------
*! DO FILE: cdema_simulation_barbados.do
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
** -----------------------------------------------------------------
** LOCAL PATH: X:\OneDrive - The University of the West Indies\repo_datagroup\repo_p151\
** GitHub PATH: :https://github.com/UWI-DataGroup/repo_p151
**
** DESCRIPTION
** Does the same as above, for ANTIGUA and BARBUDA.  
** -----------------------------------------------------------------

** -----------------------------------------------------------------
*! DO FILE: cdema_simulation_001.do
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
** -----------------------------------------------------------------
** LOCAL PATH: X:\OneDrive - The University of the West Indies\repo_datagroup\repo_p151\
** GitHub PATH: :https://github.com/UWI-DataGroup/repo_p151
**
** DESCRIPTION
** Prepare example CONFIRMED CASES briefing
** Extract data for THREE comparator countries: Sth Korea, UK, US
** And we compare each Caribbean country against these comparators
**
** We calculate the number of elapsed days since start of outbreak
** defined as the first reported CONFIRMED case.
**
** We then simply plot cumulative cases for all countries over this 
** period of elapsed time
** -----------------------------------------------------------------

** -----------------------------------------------------------------
*! OTHER CODE
** -----------------------------------------------------------------
** -----------------------------------------------------------------
*! DO FILE: cdema_simulation_presentation_graphics.do
** -----------------------------------------------------------------
** LOCAL PATH: X:\OneDrive - The University of the West Indies\repo_datagroup\repo_p151\
** GitHub PATH: :https://github.com/UWI-DataGroup/repo_p151
**
** DESCRIPTION
** Produces PPTX-friendly graphics for presentation #1 to CDEMA / CARPHA
** on 26-MAR-2020 
** -----------------------------------------------------------------
