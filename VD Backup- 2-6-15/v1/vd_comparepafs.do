clear all

// Set to run all selected code without pausing
set more off
// Remove previous restores
cap restore, not
// Define J drive (data) for cluster (UNIX) and Windows (Windows)
if c(os) == "Unix" {
	global prefix "/home/j"
	set odbcmgr unixodbc
}
else if c(os) == "Windows" {
	global prefix "J:"
}
local dalynatversion 63 //version of the dalynator
local vdversion `dalynatversion' //version of the venn diagram
local codeversion 1 //version of the code
local medversion 1 //version of the mediation

*Derived switches
local sumdirectory "$prefix/WORK/10_gbd/01_dalynator/03_results/`dalynatversion'/summary/" //location of the summary files. Informed by dalynat version
local workdirectory "$prefix/WORK/05_risk/other/venn/Results/v`vdversion'" //location of where to spit the files, informed by vd version
*local sumdirectory "C:\Users\dccasey\Documents\newvd\sum/"
*local workdirectory "C:\Users\dccasey\Documents\newvd\work"
local dimensionsdirect "$prefix/WORK/05_risk/other/venn/dimensions/"
local codedirectory "$prefix/WORK/05_risk/other/venn/Code/" //where to look for the relevant code


use "J:\WORK\05_risk\other\venn\Results\v63_test\causeheir_USA_2010.dta", clear

reshape long mt mb, i(iso3 year age sex cause) j(risk) string

replace risk = substr(risk, 1, strlen(risk)-4)
drop if strlen(risk)>5

//do some renaming
replace risk = "_" + risk
replace risk = "_behav" if risk=="_beh"

preserve

use "$prefix/WORK/00_dimensions/03_causes/causes.dta", clear
keep if cause_version==2 & reporting==1
tempfile causetable
save `causetable', replace

restore

merge m:1 cause using `causetable', keep(3) keepusing(acause) nogen

destring age, replace

merge 1:1 iso3 year age sex acause risk using "`sumdirectory'summary_USA_2010.dta", keep(1 3) keepusing(mean_cf_yll mean_cf_death mean_cf_yld)

gen difmt = mt- mean_cf_yll
gen difdeayll = mean_cf_death - mean_cf_yll

