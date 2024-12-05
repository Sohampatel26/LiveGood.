clear all
set more off
set maxvar 10000

**************************************************
*Title: H_LASI_long
*Summary: converts data from the LASI to create the Harmonized LASI
*Version: A.3
*Authors: Sandy Chien, Codi Young, Drystan Phillips, Jenny Wilkens, Yuxuan Wang, Alden Gross, Erik Meijer, Marco Angrisani, & Jinkook Lee
*Date Published: April 2023
**************************************************

***define folder locations***
local restricted "||restricted_lasi_data_folder||"
local public "||public_lasi_data_folder||"
local output "||save_to_folder||"

***define restricted files***
*Wave 1 files
global wave_1_lang "`restricted'/lasi_lang_3.dta"
global wave_1_community "`restricted'/Community/lasi_comm.dta"
global wave_1_raw_ind "`restricted'/lasi_ind2_all.dta"
global wave_1_raw_cv "`restricted'/lasi_cv2_all.dta"
global wave_1_raw_hh "`restricted'/lasi_hh2_all.dta"
global wave_1_in_imput "`restricted'/Imputation/LASI_IN_imputation_all.dta"
global wave_1_ad_imput "`restricted'/Imputation/LASI_AD_imputation_all.dta"
global wave_1_co_imput "`restricted'/Imputation/LASI_CO_imputation_all.dta"
global wave_1_hi_imput "`restricted'/Imputation/LASI_HI_imputation_all.dta"
global wave_1_hc_imput "`restricted'/Imputation/LASI_HC_imputation_all.dta"
global wave_1_fs_imput "`restricted'/Imputation/LASI_FS_imputation_all.dta"
global wave_1_we_imput "`restricted'/Imputation/LASI_WE_imputation_all.dta"
global wave_1_cog_imput "`restricted'/Cog_Imputation/lasi-cognition-finalized.dta"
global wave_1_weights "`restricted'/lasi_weights.dta"
global wave_1_factor "`restricted'/Factor Score/lasi_factorscore_04_17_2023.dta"
global school_1971 "`restricted'/71data.dta"

***define public files***
*Wave 1 files
global wave_1_ind_bm "`public'/lasi_w1b_ind_bm.dta"
global wave_1_hh "`public'/lasi_w1b_hh.dta"
global wave_1_cv "`public'/lasi_w1b_cv.dta"

***define programs***
*generate spouse variables
* There is one program to generate spouse variables

***spouse
***this is a program that creates spouse variables from respondnet information
***
*** the program is called as follows
***		spouse varname, result(result) wave(wave)
***			where:
***				varname - name of respondent variable
***				result 	- name of spouse variable, must be generated before program
***				wave		-	number of the wave
capture program drop spouse
program define spouse
syntax varname, result(varname) wave(integer) [coupleid(varname)]
	if "`coupleid'" == "" {
		local coupleid h`wave'coupid
	}
	replace `result' = .u if !inlist(r`wave'mstat, 1,3) & h`wave'cpl == 0
	replace `result' = .v if inlist(r`wave'mstat, 1,3) & h`wave'cpl == 0
	bysort `coupleid': replace `result' = `varlist'[_n+1] if `coupleid'==`coupleid'[_n+1] & !missing(`coupleid') & inw`wave' == 1 & `varlist'[_n+1] != .
	bysort `coupleid': replace `result' = `varlist'[_n-1] if `coupleid'==`coupleid'[_n-1] & !missing(`coupleid') & inw`wave' == 1 & `varlist'[_n-1] != .
end



*create special missing codes
capture program drop h_wy_level 
program define h_wy_level, rclass
syntax varname [, HRS ELSA SHARE JSTAR CHARLS LASI KLOSA MHAS TILDA CRELES wy(string) asset income ]
    local l = substr("`varlist'",1,1)
    local ll = substr("`varlist'",1,2)
    local lll = substr("`varlist'",1,3)
    if "`ll'" == "hh" {
        local l = substr("`varlist'",1,2)
    }
    if "`lll'" == "inw" {
        local l = substr("`varlist'",1,3)
    }
    if "`l'" == "inw" {
        local t = substr("`varlist'",4,1)
        if "`t'"=="0"|"`t'"=="1"|"`t'"=="2"|"`t'"=="3"|"`t'"=="4"|"`t'"=="5"|"`t'"=="6"|"`t'"=="7"|"`t'"=="8"|"`t'"=="9" {
            local time wave
            local w = substr("`varlist'",4,1)
        	local tt = substr("`varlist'",5,1)
        	if "`tt'"=="0"|"`tt'"=="1"|"`tt'"=="2"|"`tt'"=="3"|"`tt'"=="4"|"`tt'"=="5"|"`tt'"=="6"|"`tt'"=="7"|"`tt'"=="8"|"`tt'"=="9" {
        	    local w = substr("`varlist'",4,2)
        	    local ttt = substr("`varlist'",6,1)
        	    if "`ttt'"=="0"|"`ttt'"=="1"|"`ttt'"=="2"|"`ttt'"=="3"|"`ttt'"=="4"|"`ttt'"=="5"|"`ttt'"=="6"|"`ttt'"=="7"|"`ttt'"=="8"|"`ttt'"=="9" {
        	        local w
        	        local y = substr("`varlist'",4,4)
        	        local time year
        	    }
        	}
    	}
    }
    else if "`l'" == "hh" {
        local t = substr("`varlist'",3,1)
        if "`t'"=="0"|"`t'"=="1"|"`t'"=="2"|"`t'"=="3"|"`t'"=="4"|"`t'"=="5"|"`t'"=="6"|"`t'"=="7"|"`t'"=="8"|"`t'"=="9" {
            local time wave
            local w = substr("`varlist'",3,1)
        	local tt = substr("`varlist'",4,1)
        	if "`tt'"=="0"|"`tt'"=="1"|"`tt'"=="2"|"`tt'"=="3"|"`tt'"=="4"|"`tt'"=="5"|"`tt'"=="6"|"`tt'"=="7"|"`tt'"=="8"|"`tt'"=="9" {
        	    local w = substr("`varlist'",3,2)
        	    local ttt = substr("`varlist'",5,1)
        	    if "`ttt'"=="0"|"`ttt'"=="1"|"`ttt'"=="2"|"`ttt'"=="3"|"`ttt'"=="4"|"`ttt'"=="5"|"`ttt'"=="6"|"`ttt'"=="7"|"`ttt'"=="8"|"`ttt'"=="9" {
        	        local w
        	        local y = substr("`varlist'",3,4)
        	        local time year
        	    }
        	}
    	}
    }
    else {
        local t = substr("`varlist'",2,1)
        if "`t'"=="0"|"`t'"=="1"|"`t'"=="2"|"`t'"=="3"|"`t'"=="4"|"`t'"=="5"|"`t'"=="6"|"`t'"=="7"|"`t'"=="8"|"`t'"=="9" {
            local time wave
            local w = substr("`varlist'",2,1)
        	local tt = substr("`varlist'",3,1)
        	if "`tt'"=="0"|"`tt'"=="1"|"`tt'"=="2"|"`tt'"=="3"|"`tt'"=="4"|"`tt'"=="5"|"`tt'"=="6"|"`tt'"=="7"|"`tt'"=="8"|"`tt'"=="9" {
        	    local w = substr("`varlist'",2,2)
        	    local ttt = substr("`varlist'",4,1)
        	    if "`ttt'"=="0"|"`ttt'"=="1"|"`ttt'"=="2"|"`ttt'"=="3"|"`ttt'"=="4"|"`ttt'"=="5"|"`ttt'"=="6"|"`ttt'"=="7"|"`ttt'"=="8"|"`ttt'"=="9" {
        	        local w
        	        local y = substr("`varlist'",2,4)
        	        local time year
        	    }
        	}
    	}
    }       
    
	return local level "`l'"
	
	if "`w'" == "" & "`y'" == "" {
	    if "`wy'"=="0"|"`wy'"=="1"|"`wy'"=="2"|"`wy'"=="3"|"`wy'"=="4"|"`wy'"=="5"|"`wy'"=="6"|"`wy'"=="7"|"`wy'"=="8"|"`wy'"=="9" | ///
	        "`wy'"=="10"|"`wy'"=="11"|"`wy'"=="12"|"`wy'"=="13"|"`wy'"=="14"|"`wy'"=="15"|"`wy'"=="16"|"`wy'"=="17"|"`wy'"=="18"|"`wy'"=="19" {
		    local w `wy'
		}
		else {
		    local y `wy'
		}
		local time panel
	}
	local studies `hrs' `elsa' `share' `jstar' `charls' `lasi' `klosa' `mhas' `tilda'
	local n_studies : word count `studies'
	if "`w'"=="0"|"`w'"=="1"|"`w'"=="2"|"`w'"=="3"|"`w'"=="4"|"`w'"=="5"|"`w'"=="6"|"`w'"=="7"|"`w'"=="8"|"`w'"=="9" | ///
	        "`w'"=="10"|"`w'"=="11"|"`w'"=="12"|"`w'"=="13"|"`w'"=="14"|"`w'"=="15"|"`w'"=="16"|"`w'"=="17"|"`w'"=="18"|"`w'"=="19" {
		if `n_studies' > 1 {
			di "can only specify one study"
			exit 198
		}
		else if "`hrs'" == "hrs" {
			local y = 1992 + ((`w'-1)*2)
		}
		else if "`elsa'" == "elsa" {
			local y = 2002 + ((`w'-1)*2)
		}
		else if "`share'" == "share" {
			local y = 2004 + ((`w'-1)*2)
		}
		else if "`jstar'" == "jstar" {
			local y = 2006 + ((`w'-1)*2)
		}
		else if "`charls'" == "charls" {
			local y = 2010 + ((`w'-1)*2)
		}
		else if "`lasi'" == "lasi" {
			local y = 2012 + ((`w'-1)*2)
		}
		else if "`klosa'" == "klosa" {
			local y = 2006 + ((`w'-1)*2)
		}
		else if "`mhas'" == "mhas" {
		    if `w' == 1 | `w' == 2 {
			    local y = 2000 + ((`w'-1)*2)
			}
			else {
			    local y = 2012 + ((`w'-1)*2)
			}
		}
		else if "`tilda'" == "tilda" {
			local y = 2010 + ((`w'-1)*2)
		}
		else if "`creles'" == "creles" {
		    if `w' == 1 | `w' == 2 | `w' == 3 {
			    local y = 2004 + ((`w'-1)*2)
			}
			else {
			    local y = 2010 + ((`w'-1)*2)
			}
		}
		return local wy `w'
	}
	else if "`y'" != "" {
		if `n_studies' > 1 {
			di "can only specify one study"
			exit 198
		}
		else if "`hrs'" == "hrs" {
			local w = ((`y'-1992)/2)+1
		}
		else if "`elsa'" == "elsa" {
			local w = ((`y'-2002)/2)+1
		}
		else if "`share'" == "share" {
			local w = ((`y'-2004)/2)+1
		}
		else if "`jstar'" == "jstar" {
			local w = ((`y'-2006)/2)+1
		}
		else if "`charls'" == "charls" {
			local w = ((`y'-2010)/2)+1
		}
		else if "`lasi'" == "lasi" {
			local w = ((`y'-2012)/2)+1
		}
		else if "`klosa'" == "klosa" {
			local w = ((`y'-2006)/2)+1
		}
		else if "`mhas'" == "mhas" {
		    if `y' == 2000 | `y' == 2002 {
			    local w = ((`y'-2000)/2)+1
			}
			else {
			    local w = ((`y'-2012)/2)+1
			}
		}
		else if "`tilda'" == "tilda" {
			local w = ((`y'-2010)/2)+1
		}
		else if "`creles'" == "creles" {
		    if `y' == 2004 | `y' == 2006 | `y' == 2008 {
			    local w = ((`y'-2004)/2)+1
			}
			else {
			    local w = ((`y'-2010)/2)+1
			}
		}
		return local wy `y'
	}
	
	if "`asset'" == "asset" {
	    if "`hrs'" == "hrs" {
			local fin_time this_year 
		}
		else if "`elsa'" == "elsa" {
			local fin_time this_year 
		}
		else if "`share'" == "share" {
			local fin_time this_year 
		}
		else if "`jstar'" == "jstar" {
			local fin_time this_year 
		}
		else if "`charls'" == "charls" {
			local fin_time this_year
		}
		else if "`lasi'" == "lasi" {
			local fin_time this_year 
		}
		else if "`klosa'" == "klosa" {
			local fin_time this_year 
		}
		else if "`mhas'" == "mhas" {
			local fin_time this_year 
		}
		else if "`tilda'" == "tilda" {
			local fin_time this_year 
		}
		else if "`creles'" == "creles" {
			local fin_time this_year 
		}
	}
	else if "`income'" == "income" {
	    if "`hrs'" == "hrs" {
	        if `w' == 1 {
	            local fin_time sp_year
	            local fin_sp_year = 1991
	        }
	        else if `w' == 2 {
	            local fin_time mixed
	            local fin_sp_year = 1993
	        }
	        else {
	            local fin_time last_year
			}
		}
		else if "`elsa'" == "elsa" {
			local fin_time this_year 
		}
		else if "`share'" == "share" {
			local fin_time last_year
		}
		else if "`jstar'" == "jstar" {
			local fin_time last_year
		}
		else if "`charls'" == "charls" {
			local fin_time last_year
		}
		else if "`lasi'" == "lasi" {
			local fin_time this_year
		}
		else if "`klosa'" == "klosa" {
			local fin_time last_year
		}
		else if "`mhas'" == "mhas" {
			local fin_time unknown
		}
		else if "`tilda'" == "tilda" {
			local fin_time unknown
		}
		else if "`creles'" == "creles" {
			local fin_time unknown
		}
	}
	
	return local wave `w'
	return local year `y'
	return local time `time'
	return local fin_time `fin_time'
	return local fin_sp_year `fin_sp_year'
end
***missing_H
***this is a program that creates special missing codes for RAND Harmonized variables
***
*** the program is called as follows
***		missing_H varlist, result(result)
***			where:
***				varlist - list of variables which should influence missing codes
***				result 	- name of harmonized variable, must be generated before program
***				[if] and [in] allow limitation of the program to a subsample using an if or in statement, both are optional
capture program drop missing_H
program define missing_H
syntax varlist [if] [in], result(varname)

marksample touse, novarlist // process if and in statements

quietly {
	foreach v of varlist `varlist' {
		replace `result' = .m if `v' == .m & mi(`result') & !inlist(`result',.d,.r) & (`touse') // this is the lowest category
	}
	foreach v of varlist `varlist' {
		replace `result' = .d if `v' == .d & mi(`result') & `result'!=.r & (`touse')
	}
	foreach v of varlist `varlist' {
		replace `result' = .r if `v' == .r & mi(`result') & (`touse')
	}
}
end

***missing_lasi
***this is a program that creates speical missing codes for CHARLS Wave 1 variables
***
*** the program is called as follows
***		missing_c varlist [if] [in], result(result)
***			where:
***				varlist - list of variables which should influnce missing codes
***				result 	- name of variable, must be generated before program
***				[if] and [in] allow limitation of the program to a subsample using an if or in statement, both are optional
capture program drop missing_lasi
program define missing_lasi
syntax varlist [if] [in], result(varname) [wave(string)]

    
    marksample touse, novarlist // process if and in statements
    if "`wave'" == "" {
        h_wy_level `result'
        local w `r(wave)'
        local time `r(time)'
    }
    else {
        local w `wave'
    }
       
        
    
    quietly {
    	if "`time'" == "wave" | "`wave'" != "" {
            foreach v of varlist `varlist' {
        		replace `result' = .m if inlist(`v',.,.e,.m) & !inlist(`result',.d,.r) & inw`w' == 1 & (`touse') // this is the lowest category
        	}
        }
    	foreach v of varlist `varlist' {
    		replace `result' = .d if `v' == .d & `result'!=.r & (`touse')
    	}
    	foreach v of varlist `varlist' {
    		replace `result' = .r if `v' == .r & (`touse')
    	}
    }
end

***missing_lasi_co
***this is a program that creates speical missing codes for CHARLS Wave 1 community variables
***
*** the program is called as follows
***		missing_lasi_co varlist [if] [in], result(result)
***			where:
***				varlist - list of variables which should influnce missing codes
***				result 	- name of variable, must be generated before program
***				[if] and [in] allow limitation of the program to a subsample using an if or in statement, both are optional
capture program drop missing_lasi_co
program define missing_lasi_co
syntax varlist [if] [in], result(varname) [wave(string)]

    
    marksample touse, novarlist // process if and in statements
    if "`wave'" == "" {
        h_wy_level `result'
        local w `r(wave)'
        local time `r(time)'
    }
    else {
        local w `wave'
    }
       
        
    
    quietly {
    	if "`time'" == "wave" | "`wave'" != "" {
            foreach v of varlist `varlist' {
        		replace `result' = .m if inw`w' == 1 & (`touse') // this is the lowest category
        	}
        }
    	foreach v of varlist `varlist' {
    		replace `result' = .d if `v' == 998 & `result'!=.r & (`touse')
    	}
    	foreach v of varlist `varlist' {
    		replace `result' = .r if `v' == 997 & (`touse')
    	}
    }
end

*create ownership flag variables
capture program drop ownership_flag
program define ownership_flag
syntax varlist [if] [in], result(varname)

marksample touse, novarlist // process if and in statements

quietly {
	foreach v of varlist `varlist' {
		replace `result' = 0 if `v' == 0  & (`touse') // this is the lowest category
		}
	foreach v of varlist `varlist' {
		replace `result' = 1 if `v' == 1 & (`touse')
		}
	foreach v of varlist `varlist' {
		replace `result' = . if `v' == . & (`touse')
		}
	}

end


*combine imputation flag variables
***combine_h_asset_flag
***this is program that combines imputation flags from multiple asset imputation flag variables.
***			this flag program assumes that categories are and will remain:
***				1. continuous value
***				2. complete bracket
***				3. incomplete bracket
***				5. no value/bracket
***				6. no asset
***				7. dk ownership

***
*** the program is called as follows
***		combine_h_asset_flag varlist [if] [in], result(varname)
***			where:
***				varlist - list of the multiple asset imputation flag variables to be combined
***				result - the name of the desired combined flag variable which must be pre-generated
***				[if] and [in] allow limitation of the program to a subsample using an if or in statement, both are optional
capture program drop combine_h_asset_flag
program define combine_h_asset_flag, byable(onecall)
syntax varlist [if] [in], result(varname)

marksample touse, novarlist // process if and in statements

if "`_byvars'" == "" {
    quietly {
    	foreach v of varlist `varlist' {
    		replace `result' = 6 if `v' == 6  & (`touse') // this is the lowest category
    	}
    	foreach v of varlist `varlist' {
    		replace `result' = 1 if `v' == 1 & (`touse')
    	}
    	foreach v of varlist `varlist' {
    		replace `result' = 2 if `v' == 2 & (`touse')
    	}
    	foreach v of varlist `varlist' {
    		replace `result' = 3 if `v' == 3 & (`touse') 
    	}
    	foreach v of varlist `varlist' {
    		replace `result' = 5 if `v' == 5 & (`touse') 
    	}
    	foreach v of varlist `varlist' {
    		replace `result' = 7 if `v' == 7 & (`touse') 
    	}
    	foreach v of varlist `varlist' {
    		replace `result' = 8 if `v' == 8 & (`touse') 
    	}
        foreach v of varlist `varlist' {
    		replace `result' = -1 if `v' == -1 & (`touse') 
    	}
    	foreach v of varlist `varlist' {
    		replace `result' = -2 if `v' == -2 & (`touse') 
    	}
	}
}
else {
    quietly {
        foreach v in 6 1 2 3 5 7 8 -1 -2 {
            tempvar any totany
            egen `any' = anymatch(`varlist') if `touse', values(`v')
            bysort `_byvars': egen `totany' = total(`any')
            replace `result' = `v' if `totany' > 0
        }
    }
}
end

***combine_h_inc_flag
***this is program that combines imputation flags from multiple income imputation flag variables.
***			this flag program assumes that categories are and will remain:
***				1. continuous value
***				2. complete bracket
***				3. incomplete bracket
***				5. no value/bracket
***				6. no income
***				7. dk

***
*** the program is called as follows
***		combine_h_inc_flag varlist [if] [in], result(varname)
***			where:
***				varlist - list of the multiple income imputation flag variables to be combined
***				result - the name of the desired combined flag variable which must be pre-generated
***				[if] and [in] allow limitation of the program to a subsample using an if or in statement, both are optional
capture program drop combine_h_inc_flag
program define combine_h_inc_flag, byable(onecall)
syntax varlist [if] [in], result(varname)

marksample touse, novarlist // process if and in statements

if "`_byvars'" == "" {
    quietly {
    	foreach v of varlist `varlist' {
    		replace `result' = 6 if `v' == 6  & (`touse') // this is the lowest category
    	}
    	foreach v of varlist `varlist' {
    		replace `result' = 1 if `v' == 1 & (`touse')
    	}
    	foreach v of varlist `varlist' {
    		replace `result' = 2 if `v' == 2 & (`touse')
    	}
    	foreach v of varlist `varlist' {
    		replace `result' = 3 if `v' == 3 & (`touse') 
    	}
    	foreach v of varlist `varlist' {
    		replace `result' = 5 if `v' == 5 & (`touse') 
    	}
    	foreach v of varlist `varlist' {
    		replace `result' = 7 if `v' == 7 & (`touse') 
    	}
    	foreach v of varlist `varlist' {
    		replace `result' = 8 if `v' == 8 & (`touse') 
    	}
        foreach v of varlist `varlist' {
    		replace `result' = -1 if `v' == -1 & (`touse') 
    	}
    	foreach v of varlist `varlist' {
    		replace `result' = -2 if `v' == -2 & (`touse') 
    	}
	}
}
else {
    quietly {
        foreach v in 6 1 2 3 5 7 8 -1 -2 {
            tempvar any totany
            egen `any' = anymatch(`varlist') if `touse', values(`v')
            bysort `_byvars': egen `totany' = total(`any')
            replace `result' = `v' if `totany' > 0
        }
    }
}
end

*copy values to other household memember
* There is one program to copy values to all other household respondents

***copy_household_values
***this is a program that creates spouse variables from respondnet information
***
*** the program is called as follows
***		copy_household_values varname, wave(wave)
***			where:
***				varname - name of variable which contains a household value 
***				wave		-	number of the wave
capture program drop copy_household_values
program define copy_household_values
syntax varname, wave(integer) 
    qui forvalues i = 1 / 7 {
    	bysort hhid: replace `varlist' = `varlist'[_n+`i'] if hhid==hhid[_n+`i'] & !missing(hhid) & mi(`varlist') & !mi(`varlist'[_n+`i']) & inw`wave' == 1
    	bysort hhid: replace `varlist' = `varlist'[_n-`i'] if hhid==hhid[_n-`i'] & !missing(hhid) & mi(`varlist') & !mi(`varlist'[_n-`i']) & inw`wave' == 1
    }
end



***Prepare Raw Data***
tempfile school_1971_
use "$school_1971"

gen state=.
replace state=28 if state1 ==1
replace state=18 if state2 ==1
replace state=10 if state3 ==1
replace state=24 if state4 ==1
replace state=6 if state5 ==1
replace state=2 if state6 ==1
replace state=1 if state7 ==1
replace state=29 if state8 ==1
replace state=32 if state9 ==1
replace state=23 if state10 ==1
replace state=27 if state11 ==1
replace state=21 if state12 ==1
replace state=3 if state13 ==1
replace state=8 if state14 ==1
replace state=33 if state15 ==1
replace state=9 if state16 ==1
replace state=19 if state17 ==1

foreach j in "dist" "st" {
egen tot_vill_`j' = sum(nvill), by (`j'code)
    foreach v in primary middle high {
        egen tot_`v'_`j' = sum(`v'), by (`j'code)
        gen `v'_access_`j'= (tot_`v'_`j'/tot_vill_`j')*100
        replace `v'_access_`j'=round(`v'_access_`j', .001)
    }
}

gen school_distid = string(state) + "_" + distname
keep school_distid ///
     primary_access_dist middle_access_dist high_access_dist ///
     primary_access_st   middle_access_st   high_access_st
     
save `school_1971_', replace
global school_1971_ `school_1971_'
clear

********************************************************************************************************************
********************************************************************************************************************
***load full set of LASI responses***
***load wave 1 indivudal data
use prim_key hhid hhorder using "$wave_1_ind_bm" 
replace hhorder = real(substr(prim_key,14,2)) if hhorder != real(substr(prim_key,14,2)) /*correct any hhorder values which do not match last two digits of prim_key*/
gen inddata = 1

***merge with wave 1 houseold data
merge m:1 hhid using "$wave_1_hh", keepusing(hhid) 
replace prim_key = hhid + "_" + string(_n) if mi(prim_key)
recode _merge (1=0) (2/3=1), gen(hhdata)
drop _merge

***merge with wave 1 cv data
merge m:1 hhid using "$wave_1_cv", keepusing(hhid cv003_? cv003_1? cv003_2?) 
drop if _merge==2 /*drop if only in CV, no need to include CV only cases*/
recode _merge (1=0) (2/3=1), gen(cvdata)
drop _merge
egen data = rownonmiss(cv003_? cv003_1? cv003_2?)
replace cvdata = 0 if data == 0
drop data cv003_? cv003_1? cv003_2?

********************************************************************************************************************
********************************************************************************************************************


*yesno
label define yesno2 ///
   0 "0.no" ///
   1 "1.yes" ///
   .i ".i:invalid" /// 
   .e ".e:error" ///
   .m ".m:missing" ///
   .p ".p:proxy" ///
   .s ".s:skipped" ///
   .d ".d:dk" ///
   .r ".r:refuse" ///
   .u ".u:unmar" ///
   .v ".v:sp nr" ///
   .k ".k:no kids" ///
   .n ".n:not applicable" ///
   .a ".a:age less than 50" ///
   .w ".w:not working" ///
   .g ".g:no grandchildren", replace
 
*whether in wave
label define inw ///
   0 "0.nonresp" ///
   1 "1.resp,alive" 

*flag birth year
label define fbdate ///
    0 "0.no dispute" ///
    1 "1.dispute, last report used" 

*interview status
label define wstat ///
   0 "0.inap." ///
   1 "1.resp, alive"  ///
   4 "4.nr, alive" ///
   5 "5.nr, died this wv" ///
   6 "6.nr, died prev wv" ///
   7 "7.nr, dropped from samp" ///
   9 "9.nr, dk if alive or died"

***whether proxy interview***
label define proxy ///
   0 "0.not proxy" ///
   1 "1.proxy" 

*whether couple household
label define cpl ///
   0 "0.not coupled" ///
   1 "1.coupled" 

*gender
label define genderf ///
   1 "1.man"  ///
   2 "2.woman" ///
   3 "3.transgender" 
	
label define mstat ///
	1 "1.married" ///
	2 "2.married, sp abs"  ///
	3 "3.partnered" ///
	4 "4.separated" ///
	5 "5.divorced" ///
	7 "7.widowed" ///
	8 "8.never married" 
 
label define mpart /// 
 0 "0.no" ///
 1 "1.yes" ///
 .s ".s:skip" 
 
label define rabplace ///
	 1 "1.Jammu & Kashmir" ///
	 2 "2.Himachal Pradesh" ///
	 3 "3.Punjab" ///
	 4 "4.Chandigarh" ///
	 5 "5.Uttarakhand" ///
	 6 "6.Haryana" ///
	 7 "7.Delhi" ///
	 8 "8.Rajasthan" ///
	 9 "9.Uttar Pradesh" ///
	 10 "10.Bihar" ///
	 11 "11.Sikkim" ///
	 12 "12.Arunachal" ///
	 13 "13.Nagaland" ///
	 14 "14.Manipur " ///
	 15 "15.Mizoram" ///
	 16 "16.Tripura" ///
	 17 "17.Meghalaya" ///
	 18 "18.Assam" ///
	 19 "19.West Bengal" ///
	 20 "20.Jharkhand" ///
	 21 "21.Odisha" ///
	 22 "22.Chhatisgarh" ///
	 23 "23.Madhya Pradesh" ///
	 24 "24.Gujarat" ///
	 25 "25.Daman & Diu " ///
	 26 "26.Dadra & Nagar Haveli" ///
	 27 "27.Maharashtra" ///
	 28 "28.Andhra Pradesh" ///
	 29 "29.Karnataka" ///
	 30 "30.Goa" ///
	 31 "31.Lakshadweep" ///
	 32 "32.Kerala" ///
	 33 "33.Tamil Nadu" ///
	 34 "34.Puducherry" ///
	 35 "35.Andaman & Nicobar" ///
	 36 "36.Telangana" ///
	 37 "37.Abroad" 

label define incountry ///
	0 "0.out of country" ///
	1 "1.in country"

label define rabcountry /// 
           1 "1.Afghanistan" ///
           2 "2.Albania" ///
           3 "3.Algeria" ///
           4 "4.Andorra" ///
           5 "5.Angola" ///
           6 "6.Antigua and Barbuda" ///
           7 "7.Argentina" ///
           8 "8.Armenia" ///
           9 "9.Australia" ///
          10 "10.Austria" ///
          11 "11.Azerbaijan" ///
          12 "12.Bahamas" ///
          13 "13.Bahrain" ///
          14 "14.Bangladesh" ///
          15 "15.Barbados" ///
          16 "16.Belarus" ///
          17 "17.Belgium" ///
          18 "18.Belize" ///
          19 "19.Benin" ///
          20 "20.Bhutan" ///
          21 "21.Bolivia" ///
          22 "22.Bosnia and Herzegovina" ///
          23 "23.Botswana" ///
          24 "24.Brazil" ///
          25 "25.Brunei" ///
          26 "26.Bulgaria" ///
          27 "27.Burkina Faso" ///
          28 "28.Burma/Myanmar" ///
          29 "29.Burundi" ///
          30 "30.Cambodia" ///
          31 "31.Cameroon" ///
          32 "32.Canada" ///
          33 "33.Cape Verde" ///
          34 "34.Central African Republic" ///
          35 "35.Chad" ///
          36 "36.Chile" ///
          37 "37.China" ///
          38 "38.Colombia" ///
          39 "39.Comoros" ///
          40 "40.Congo" ///
          41 "41.Congo" ///
          42 "42.Costa Rica" ///
          43 "43.Cote dIvoire/Ivory Coast" ///
          44 "44.Croatia" ///
          45 "45.Cuba" ///
          46 "46.Cyprus" ///
          47 "47.Czech Republic" ///
          48 "48.Denmark" ///
          49 "49.Djibouti" ///
          50 "50.Dominica" ///
          51 "51.Dominican Republic" ///
          52 "52.East Timor" ///
          53 "53.Ecuador" ///
          54 "54.Egypt" ///
          55 "55.El Salvador" ///
          56 "56.Equatorial Guinea" ///
          57 "57.Eritrea" ///
          58 "58.Estonia" ///
          59 "59.Ethiopia" ///
          60 "60.Fiji" ///
          61 "61.Finland" ///
          62 "62.France" ///
          63 "63.Gabon" ///
          64 "64.Gambia" ///
          65 "65.Georgia" ///
          66 "66.Germany" ///
          67 "67.Ghana" ///
          68 "68.Greece" ///
          69 "69.Grenada" ///
          70 "70.Guatemala" ///
          71 "71.Guinea" ///
          72 "72.Guinea-Bissau" ///
          73 "73.Guyana" ///
          74 "74.Haiti" ///
          75 "75.Honduras" ///
          76 "76.Hungary" ///
          77 "77.Iceland" ///
          78 "78.India" ///
          79 "79.Indonesia" ///
          80 "80.Iran" ///
          81 "81.Iraq" ///
          82 "82.Ireland" ///
          83 "83.Israel" ///
          84 "84.Italy" ///
          85 "85.Jamaica" ///
          86 "86.Japan" ///
          87 "87.Jordan" ///
          88 "88.Kazakhstan" ///
          89 "89.Kenya" ///
          90 "90.Kiribati" ///
          91 "91.Korea, North" ///
          92 "92.Korea, South" ///
          93 "93.Kuwait" ///
          94 "94.Kyrgyzstan" ///
          95 "95.Laos" ///
          96 "96.Latvia" ///
          97 "97.Lebanon" ///
          98 "98.Lesotho" ///
          99 "99.Liberia" ///
         100 "100.Libya" ///
         101 "101.Liechtenstein" ///
         102 "102.Lithuania" ///
         103 "103.Luxembourg" ///
         104 "104.Macedonia" ///
         105 "105.Madagascar" ///
         106 "106.Malawi" ///
         107 "107.Malaysia" ///
         108 "108.Maldives" ///
         109 "109.Mali" ///
         110 "110.Malta" ///
         111 "111.Marshall Islands" ///
         112 "112.Mauritania" ///
         113 "113.Mauritius" ///
         114 "114.Mexico" ///
         115 "115.Micronesia" ///
         116 "116.Moldova" ///
         117 "117.Monaco" ///
         118 "118.Mongolia" ///
         119 "119.Montenegro" ///
         120 "120.Morocco" ///
         121 "121.Mozambique" ///
         122 "122.Namibia" ///
         123 "123.Nauru" ///
         124 "124.Nepal" ///
         125 "125.Netherlands" ///
         126 "126.New Zealand" ///
         127 "127.Nicaragua" ///
         128 "128.Niger" ///
         129 "129.Nigeria" ///
         130 "130.Norway" ///
         131 "131.Oman" ///
         132 "132.Pakistan" ///
         133 "133.Palau" ///
         134 "134.Panama" ///
         135 "135.Papua New Guinea" ///
         136 "136.Paraguay" ///
         137 "137.Peru" ///
         138 "138.Philippines" ///
         139 "139.Poland" ///
         140 "140.Portugal" ///
         141 "141.Qatar (Doha) (AS)" ///
         142 "142.Romania" ///
         143 "143.Russian Federation" ///
         144 "144.Rwanda" ///
         145 "145.Saint Kitts and Nevis" ///
         146 "146.Saint Lucia" ///
         147 "147.Saint Vincent and the Grenadines" ///
         148 "148.Samoa" ///
         149 "149.San Marino" ///
         150 "150.Sao Tome and Principe" ///
         151 "151.Saudi Arabia" ///
         152 "152.Senegal" ///
         153 "153.Serbia" ///
         154 "154.Seychelles" ///
         155 "155.Sierra Leone" ///
         156 "156.Singapore" ///
         157 "157.Slovakia" ///
         158 "158.Slovenia" ///
         159 "159.Solomon Islands" ///
         160 "160.Somalia" ///
         161 "161.South Africa" ///
         162 "162.South Sudan" ///
         163 "163.Spain" ///
         164 "164.Sri Lanka" ///
         165 "165.Sudan" ///
         166 "166.Suriname" ///
         167 "167.Swaziland" ///
         168 "168.Sweden" ///
         169 "169.Switzerland" ///
         170 "170.Syria" ///
         171 "171.Tajikistan" ///
         172 "172.Tanzania" ///
         173 "173.Thailand" ///
         174 "174.Togo" ///
         175 "175.Tonga" ///
         176 "176.Trinidad and Tobago" ///
         177 "177.Tunisia" ///
         178 "178.Turkey" ///
         179 "179.Turkmenistan" ///
         180 "180.Tuvalu" ///
         181 "181.Uganda" ///
         182 "182.Ukraine" ///
         183 "183.United Arab Emirates" ///
         184 "184.United Kingdom" ///
         185 "185.United States" ///
         186 "186.Uruguay" ///
         187 "187.Uzbekistan" ///
         188 "188.Vanuatu" ///
         189 "189.Vatican City" ///
         190 "190.Venezuela" ///
         191 "191.Vietnam" ///
         192 "192.Yemen" ///
         193 "193.Zambia" ///
         194 "194.Zimbabwe" ///
 	 .o ".o:abroad" 
 
 
label define reli ///
 1 "1.none" ///
 2 "2.hindu" ///
 3 "3.muslim" ///
 4 "4.christan" ///
 5 "5.sikh" ///
 6 "6.buddhist/neo-buddhist" ///
 7 "7.jain" ///
 8 "8.jewish" ///
 9 "9.parsi/zoroastrian" /// 
 10 "10.other" 
 
label define caste ///
   1 "1.scheduled caste" ///
   2 "2.scheduled tribe"  ///
   3 "3.other backward class(obc)"  ///
   4 "4.no caste or other caste"  

label define livreg ///
 1 "1.rural village" ///
 0 "0.urban community" 

label define raeduc_l /// 
 1 "1.less than primary school(standard 1-4)" ///
 2 "2.primary school(standard 5-7)" ///
 3 "3.middle school(standard 8-9)" ///
 4 "4.secondary school(standard 10-11)" ///
 5 "5.higher secondary(standard 12)" ///
 6 "6.diploma and certificate" ///
 7 "7.graduate degree(ba,bs)" ///
 8 "8.post-graduate degree(ma,ms,phd)" ///
 9 "9.professional course/degree(mbbs,md,mba)" ///
 0 "0:never attended school" 
 
*education general categories
label define educl ///
	1 "1.less than lower secondary" ///
	2 "2.upper secondary & vocational training" ///
	3 "3.tertiary" 
 
***language used***
label define lang ///
    1 "1.English" ///
    2 "2.Hindi" ///
    3 "3.Kannada" ///
    4 "4.Konkani" ///
    5 "5.Malayalam" ///
    6 "6.Gujarati" ///
    7 "7.Tamil" ///
    8 "8.Punjabi" ///
    9 "9.Manipuri" ///
    10 "10.Mizo" ///
    11 "11.Urdu" ///
    12 "12.Nepali" ///
    13 "13.Garo" ///
    14 "14.Khasi" ///
    15 "15.Bengali" ///
    16 "16.Assamese" ///
    17 "17.Odiya" ///
    18 "18.Marathi" ///
    19 "19.Telugu" 
	 
***modules***
label define modules ///
	1 "1.all 8 modules completed" ///
	2 "2.4-7 modules completed" ///
	3 "3.1-3 modules completed" ///
	4 "4.0 modules completed"

***literacy***
label define lit /// 
	0 "0.illiterate" /// 
	1 "1.literate" 	  
 


*set wave number
local wv=1

******************************************************************************************************************************************

***merge with individual file***
local demog_w1_ind rproxy dm003 dm004_year dm004_month dm005 dm006 ///
                   dm021 dm006 dm007 dm008 dm009 dm010 dm012 dm013 dm013_other ///
                   dm016 dm017_country dm017_state dm022 dm023 dm028_totalmarriage dm029_year ///
                   dm019_state dm019_district ///
                   we001 ht002 mh004 mh101 hb101 hc102 fs201 sw201a hc002s1 fs213 fs101_1 fs102_1 ///
                   bm0*
merge 1:1 prim_key using  "$wave_1_ind_bm", keepusing(`demog_w1_ind') nogen

***merge with raw individual file***
local demog_w1_raw_ind dm024_?_ begintime endtime fs101_spouse_namehh_1_
merge 1:1 prim_key using  "$wave_1_raw_ind", keepusing(`demog_w1_raw_ind') nogen

***merge with household data
local demog_w1_hh he001 he022 co001 co306 ad002 ad912 in001 in905 hi002a hi011
merge m:1 hhid using "$wave_1_hh", keepusing(`demog_w1_hh') nogen

***merge with cv file***
local demog_1_cv cv028 cv029 cv003_* cv008_* cv009_* cv010_* cv013_?_* 
merge m:1 hhid using "$wave_1_cv", keepusing(`demog_1_cv') 
drop if _merge == 2
drop _merge

***merge with raw cv file***
local demog_1_raw_cv begintime_cv endtime_cv urbanrural stateid
merge m:1 hhid using "$wave_1_raw_cv", keepusing(`demog_1_raw_cv') 
drop if _merge == 2
drop _merge

***merge with language file***
merge 1:1 prim_key using "$wave_1_lang", keepusing(language_mode) 
recode _merge (1=0) (2/3=1), gen(langdata)
drop if _merge == 2
drop _merge

***merge with weights file***
local demog_w1_weight lasi_ind_weight lasi_hh_weight lasi_bio_weight
merge 1:1 prim_key using "$wave_1_weights", keepusing(`demog_w1_weight') nogen


******************************************************************************************************************************************

*********************************************************************
***Wave Status***
*********************************************************************

***wave status: response indicator
gen inw`wv'=0
*replace inw`wv'=1 if inddata == 1 & cvdata == 1 & inrange(r`wv'indmodc,1,8)
*replace inw`wv'=1 if inddata == 1 & cvdata == 1 
replace inw`wv'=1 if inddata==1
label variable inw`wv' "inw`wv':In wave `wv'" 
label values inw`wv' yesno2


*********************************************************************
***Physical Measures Module***
*********************************************************************
     
***wave status: response indicator for BM****
*wave status: physical measures
gen inw`wv'pm=.
replace inw`wv'pm = 0 if inw`wv'==1
foreach var of varlist bm0* {
    replace inw`wv'pm=1 if !mi(`var')
}
label variable inw`wv'pm "inw`wv'pm:In w`wv' physical measure module" 
label values inw`wv'pm yesno2


*********************************************************************
***Identifiers***
*********************************************************************

***household person number - character
gen pnc=substr(prim_key,-2,2)
gen falsekey = strpos(prim_key,"_")
replace pnc = "" if falsekey > 0
label variable pnc "pnc:person ID (char)"
drop falsekey

***household person number - numeric
destring pnc, gen(pn)
label variable pn "pn:person ID (num)"

*********************************************************************
***Number of Household Respondents***
*********************************************************************

***number of household respondents
egen hh1hhresp = sum(inw1==1) if inw1==1, by(hhid)
label variable hh`wv'hhresp "hh`wv'hhresp:w`wv' # core respondents in household"

*********************************************************************
***Spouse Identifiers/Couple Identifier***
*********************************************************************
*spouse id from DM024
gen sp_dm_prim_key = ""
forvalues s = 1 / 6 {
    qui replace sp_dm_prim_key = substr(hhid,1,13) + string(dm024_`s'_,"%02.0f") if mi(sp_dm_prim_key) & inrange(dm024_`s'_,1,23) & dm024_`s'_ != hhorder
}

*spouse's spouse id from DM024
gen s_sp_dm_prim_key = ""
forvalues i = 1/23 {
    qui bysort hhid: replace s_sp_dm_prim_key = sp_dm_prim_key[_n-`i'] if prim_key[_n-`i'] == sp_dm_prim_key & mi(s_sp_dm_prim_key) & !mi(sp_dm_prim_key[_n-`i'])
    qui bysort hhid: replace s_sp_dm_prim_key = sp_dm_prim_key[_n+`i'] if prim_key[_n+`i'] == sp_dm_prim_key & mi(s_sp_dm_prim_key) & !mi(sp_dm_prim_key[_n+`i'])
}

*further clean spouse id from DM024
forvalues i = 1/23 {
    qui bysort hhid: replace sp_dm_prim_key = prim_key[_n-`i'] if mi(sp_dm_prim_key) & dm021 == 1 & sp_dm_prim_key[_n-`i'] == prim_key 
    qui bysort hhid: replace sp_dm_prim_key = prim_key[_n+`i'] if mi(sp_dm_prim_key) & dm021 == 1 & sp_dm_prim_key[_n+`i'] == prim_key 
}

gen dm_disagree = prim_key != s_sp_dm_prim_key & !mi(s_sp_dm_prim_key) if !mi(sp_dm_prim_key)
gen dm_missing = 0 if !mi(sp_dm_prim_key)
forvalues i = 1/23 {
    qui bysort hhid: replace dm_missing = 1 if mi(sp_dm_prim_key[_n-`i']) & prim_key[_n-`i'] == sp_dm_prim_key & !mi(sp_dm_prim_key)
    qui bysort hhid: replace dm_missing = 1 if mi(sp_dm_prim_key[_n+`i']) & prim_key[_n+`i'] == sp_dm_prim_key & !mi(sp_dm_prim_key)
}
gen dm_confirmed = 0  if !mi(sp_dm_prim_key)
forvalues i = 1/23 {
    qui bysort hhid: replace dm_confirmed = 1 if sp_dm_prim_key[_n-`i'] == prim_key & prim_key[_n-`i'] == sp_dm_prim_key
    qui bysort hhid: replace dm_confirmed = 1 if sp_dm_prim_key[_n+`i'] == prim_key & prim_key[_n+`i'] == sp_dm_prim_key
}
tab1 dm_disagree dm_missing dm_confirmed

*spouse id from CV013
gen sp_cv_pn = .
forvalues i = 1/35 {
    forvalues s = 1 / 4 { 
        qui replace sp_cv_pn = cv013_`s'_`i' if mi(sp_cv_pn) & inrange(cv013_`s'_`i',1,34) & hhorder == `i' & cv013_`s'_`i' != hhorder
    }
}

*spouse's spouse id from CV013
gen s_sp_cv_pn = .
forvalues i = 1/35 {
    forvalues s = 1 / 4 { 
       qui replace s_sp_cv_pn = cv013_`s'_`i' if mi(s_sp_cv_pn) & inrange(cv013_`s'_`i',1,34) & sp_cv_pn == `i'
    }
}

gen sp_cv_prim_key = substr(hhid,1,13) + string(sp_cv_pn,"%02.0f") if !mi(sp_cv_pn)
gen s_sp_cv_prim_key = substr(hhid,1,13) + string(s_sp_cv_pn,"%02.0f") if !mi(s_sp_cv_pn)

drop sp_cv_pn s_sp_cv_pn

*further clean spouse id from CV013
forvalues i = 1/23 {
    qui bysort hhid: replace sp_cv_prim_key = prim_key[_n-`i'] if mi(sp_cv_prim_key) & dm021 == 1 & sp_cv_prim_key[_n-`i'] == prim_key 
    qui bysort hhid: replace sp_cv_prim_key = prim_key[_n+`i'] if mi(sp_cv_prim_key) & dm021 == 1 & sp_cv_prim_key[_n+`i'] == prim_key 
}

gen cv_disagree = prim_key != s_sp_cv_prim_key & !mi(s_sp_cv_prim_key) if !mi(sp_cv_prim_key)
gen cv_missing = mi(s_sp_cv_prim_key) if !mi(sp_cv_prim_key)
gen cv_confirmed = 0  if !mi(sp_cv_prim_key)
forvalues i = 1/23 {
    qui bysort hhid: replace cv_confirmed = 1 if sp_cv_prim_key[_n-`i'] == prim_key & prim_key[_n-`i'] == sp_cv_prim_key
    qui bysort hhid: replace cv_confirmed = 1 if sp_cv_prim_key[_n+`i'] == prim_key & prim_key[_n+`i'] == sp_cv_prim_key
}
tab1 cv_disagree cv_missing cv_confirmed

*cleaned spouse id
gen sp_prim_key = ""
replace sp_prim_key = sp_dm_prim_key if dm_confirmed == 1
replace sp_prim_key = sp_cv_prim_key if cv_confirmed == 1 & mi(sp_prim_key)
replace sp_prim_key = sp_dm_prim_key if dm_missing == 0 & dm_disagree == 0 & mi(sp_prim_key)
replace sp_prim_key = sp_cv_prim_key if cv_missing == 0 & cv_disagree == 0 & mi(sp_prim_key)
replace sp_prim_key = sp_dm_prim_key if dm_missing == 1 & dm_disagree == 0 & mi(sp_prim_key)
replace sp_prim_key = sp_cv_prim_key if cv_missing == 1 & cv_disagree == 0 & mi(sp_prim_key) 

*spouse's cleaned spouse id
gen s_sp_prim_key = ""
forvalues i = 1/23 {
    qui bysort hhid: replace s_sp_prim_key = sp_prim_key[_n-`i'] if prim_key[_n-`i'] == sp_prim_key & mi(s_sp_prim_key) & !mi(sp_prim_key[_n-`i'])
    qui bysort hhid: replace s_sp_prim_key = sp_prim_key[_n+`i'] if prim_key[_n+`i'] == sp_prim_key & mi(s_sp_prim_key) & !mi(sp_prim_key[_n+`i'])
}

gen disagree = prim_key != s_sp_prim_key & !mi(s_sp_prim_key) if !mi(sp_prim_key)
gen missing = 0 if !mi(sp_prim_key)
forvalues i = 1/23 {
    qui bysort hhid: replace missing = 1 if mi(sp_prim_key[_n-`i']) & prim_key[_n-`i'] == sp_prim_key & !mi(sp_prim_key)
    qui bysort hhid: replace missing = 1 if mi(sp_prim_key[_n+`i']) & prim_key[_n+`i'] == sp_prim_key & !mi(sp_prim_key)
}
gen confirmed = 0  if !mi(sp_prim_key)
forvalues i = 1/23 {
    qui bysort hhid: replace confirmed = 1 if sp_prim_key[_n-`i'] == prim_key & prim_key[_n-`i'] == sp_prim_key
    qui bysort hhid: replace confirmed = 1 if sp_prim_key[_n+`i'] == prim_key & prim_key[_n+`i'] == sp_prim_key
}
tab1 disagree missing confirmed

*further clean spouse id
forvalues i = 1/23 {
    bysort hhid: replace sp_prim_key = "" if disagree == 1 & confirmed == 0 & confirmed[_n-`i'] == 1 & prim_key[_n-`i'] == sp_prim_key
    bysort hhid: replace sp_prim_key = "" if disagree == 1 & confirmed == 0 & confirmed[_n+`i'] == 1 & prim_key[_n+`i'] == sp_prim_key
}
replace sp_prim_key = "" if missing == 1 & mi(sp_cv_prim_key)

drop sp_dm_prim_key s_sp_dm_prim_key dm_disagree dm_missing dm_confirmed
drop sp_cv_prim_key s_sp_cv_prim_key cv_disagree cv_missing cv_confirmed
drop s_sp_prim_key disagree missing confirmed

***couple identifier
gen hh_coup= ""
qui levelsof pn , local(pns)
foreach r of local pns {
	forvalues i=1/23 {
		bysort hhid: replace hh_coup = "`r'"+"`i'" if prim_key == sp_prim_key[_n-`i'] & pn == `r' 
	    bysort hhid: replace hh_coup = "`r'"+"`i'" if hh_coup[_n+`i'] == "`r'"+"`i'" 
	}
}

replace hh_coup = string(_n) if hh_coup == ""
egen h`wv'coupid = group(hhid hh_coup) 
label variable h`wv'coupid "h`wv'coupid:w`wv' couple id (num)"

***spouse identifiers 
gen s`wv'prim_key = ustrtrim(sp_prim_key)
replace s`wv'prim_key = "0" if mi(s`wv'prim_key) & inw`wv' == 1
label variable s`wv'prim_key "s`wv'prim_key:w`wv' spouse prim_key (char)"

***id of first spouse
gen raspid1 = s`wv'prim_key if s`wv'prim_key != "0"
label variable raspid1 "raspid1:prim_key of 1st spouse"

***indicator of number of spouses
gen r`wv'mltsps = .
replace r`wv'mltsps = .m if inw`wv' == 1
replace r`wv'mltsps = 0 if inlist(dm021,1,2,3,4,5,6,7)
replace r`wv'mltsps = 1 if dm022 == 1
replace r`wv'mltsps = dm023 if inrange(dm023,1,6)
label variable r`wv'mltsps "r`wv'mltsps:w`wv' R Number of spouses"

drop sp_prim_key hh_coup

*********************************************************************
***Whether Coupled Household ***
*********************************************************************
***whether coupled
bysort h`wv'coupid: gen h`wv'cpl = _N if inw`wv'==1
recode h`wv'cpl (1=0) (2=1)
label variable h`wv'cpl "h`wv'cpl:w`wv' whether coupled"
label values h`wv'cpl cpl

*********************************************************************
***Current Marital Status, with implied partnership***
*********************************************************************
***current marital status w/ partnership
gen r`wv'mstat=.
missing_lasi dm021, result(r`wv'mstat)
replace r`wv'mstat=1 if dm021== 1
replace r`wv'mstat=4 if dm021== 4
replace r`wv'mstat=5 if inlist(dm021,3,5)
replace r`wv'mstat=7 if dm021== 2
replace r`wv'mstat=8 if dm021== 7
replace r`wv'mstat=3 if dm021==6 | (inlist(dm021,2,3,4,5,6,7,.r,.) & s`wv'prim_key != "0" & !mi(s`wv'prim_key))
label variable r`wv'mstat "r`wv'mstat:w`wv' r marital status w/partners, filled"
label values r`wv'mstat mstat

replace r`wv'mstat = 7 if (prim_key == "124156805460103" & missing(r`wv'mstat))
replace r`wv'mstat = 7 if (prim_key == "127179500380101" & missing(r`wv'mstat))
replace r`wv'mstat = 7 if (prim_key == "128243800130101" & missing(r`wv'mstat))
replace r`wv'mstat = 1 if (prim_key == "131204800390103" & missing(r`wv'mstat))
replace r`wv'mstat = 7 if (prim_key == "132213802060101" & missing(r`wv'mstat))


*spouse 
gen s`wv'mstat=.	
spouse r`wv'mstat, result(s`wv'mstat) wave(1)
label variable s`wv'mstat "s`wv'mstat:w`wv' s marital status w/partners, filled"
label values  s`wv'mstat mstat

*********************************************************************
***Interview Status***
*********************************************************************
  
***interview status
gen r`wv'iwstat=0
replace r`wv'iwstat=1 if inw1==1
label variable r`wv'iwstat "r`wv'iwstat:w`wv' r Interview status"
label values r`wv'iwstat wstat

*spouse 
gen s`wv'iwstat=.
spouse r`wv'iwstat, result(s`wv'iwstat) wave(`wv')
label variable s`wv'iwstat "s`wv'iwstat:w`wv' s Interview status" 
label values s`wv'iwstat wstat

*********************************************************************
***whether proxy interview***
*********************************************************************

***respondent proxy indicator
gen r`wv'proxy =.m if inw`wv' == 1
replace r`wv'proxy = 0 if rproxy ==0
replace r`wv'proxy = 1 if rproxy ==1
replace r`wv'proxy = 0 if mi(rproxy)
label variable r`wv'proxy "r`wv'proxy:w`wv' r whether proxy interview"
label values r`wv'proxy proxy

***spouse proxy indicator
gen s`wv'proxy =.
spouse r`wv'proxy, result(s`wv'proxy) wave(`wv')
label variable s`wv'proxy "s`wv'proxy:w`wv' s whether proxy interview"
label values s`wv'proxy proxy

*********************************************************************
***Individual Weights***
*********************************************************************

***individual-level post-stratification weights
gen r`wv'wtresp = lasi_ind_weight
label variable r`wv'wtresp "r`wv'wtresp:w`wv' r person-level post-stratified analysis weight"

*spouse
gen s`wv'wtresp=.
spouse r`wv'wtresp, result(s`wv'wtresp) wave(`wv')
label variable s`wv'wtresp "s`wv'wtresp:w`wv' s person-level post-stratified analysis weight"


*********************************************************************
***HH Weights***
*********************************************************************

***household-level post-stratification weights
gen hh`wv'wthh = lasi_hh_weight
label variable hh`wv'wthh "hh`wv'wthh:w`wv' household-level post-stratified analysis weight"
 

*********************************************************************
***Biomarker Weights***
*********************************************************************

***individual-level biomarker weights
gen r`wv'nwtresp = lasi_bio_weight
replace r`wv'nwtresp = .m if inw`wv'pm==0
label variable r`wv'nwtresp "r`wv'nwtresp:w`wv' r person-level biomarker weight"

*spouse
gen s`wv'nwtresp=.
spouse r`wv'nwtresp, result(s`wv'nwtresp) wave(`wv')
label variable s`wv'nwtresp "s`wv'nwtresp:w`wv' s person-level biomarker weight"

*********************************************************************
***Housing and Financial Respondents***
*********************************************************************
   
***whether housing respondent
gen r`wv'hhr=.
replace r`wv'hhr=0 if inw`wv' == 1
replace r`wv'hhr=1 if cv028 == pn & !mi(cv028)
label variable r`wv'hhr  "r`wv'hhr:w`wv' r whether housing resp"
label values r`wv'hhr yesno2

*spouse  
gen s`wv'hhr=.
spouse r`wv'hhr, result(s`wv'hhr) wave(`wv')
label variable s`wv'hhr "s`wv'hhr:w`wv' s whether housing resp" 
label values s`wv'hhr yesno2

*other household respondent
bysort hhid: egen hhrindata = total(r`wv'hhr)
gen hh`wv'ohhr = .
replace hh`wv'ohhr = 0 if hhrindata == 1 | (mi(cv028) & inw`wv' == 1)
replace hh`wv'ohhr = 1 if hhrindata == 0 & !mi(cv028)
label variable hh`wv'ohhr  "hh`wv'ohhr:w`wv' hh whether other housing resp"
label values hh`wv'ohhr yesno2

***any housing respondent
gen hh`wv'anyhhr=.
replace hh`wv'anyhhr=0 if hhrindata == 0 & hh`wv'ohhr == 0
replace hh`wv'anyhhr=1 if hhrindata == 1 | hh`wv'ohhr == 1
label variable hh`wv'anyhhr "hh`wv'anyhhr:w`wv' any housing resp in hh"
label values hh`wv'anyhhr yesno2

drop hhrindata

***whether financial respondent 
gen r`wv'finr=.
replace r`wv'finr=0 if inw`wv' == 1
replace r`wv'finr=1 if cv029 == pn & !mi(cv029)
label variable r`wv'finr  "r`wv'finr:w`wv' r whether financial resp"
label values r`wv'finr yesno2

*spouse
gen s`wv'finr=.
spouse r`wv'finr, result(s`wv'finr) wave(`wv')
label variable s`wv'finr "s`wv'finr:w`wv' s whether financial resp" 
label values s`wv'finr yesno2

*other financial respondent
bysort hhid: egen finrrindata = total(r`wv'finr)
gen  hh`wv'ofinr=.
replace hh`wv'ofinr = 0 if finrrindata == 1 | (mi(cv029) & inw`wv' == 1)
replace hh`wv'ofinr = 1 if finrrindata == 0 & !mi(cv029)
label variable hh`wv'ofinr  "hh`wv'ofinr:w`wv' hh whether other financial resp"
label values hh`wv'ofinr yesno2

***any financial respondent
gen hh`wv'anyfinr=.
replace hh`wv'anyfinr=0 if finrrindata == 0 & hh`wv'ofinr == 0
replace hh`wv'anyfinr=1 if finrrindata == 1 | hh`wv'ofinr == 1
label variable hh`wv'anyfinr "hh`wv'anyfinr:w`wv' any financial resp in hh"
label values hh`wv'anyfinr yesno2

drop finrrindata

*********************************************************************
***Interview Date***
*********************************************************************

***interview year
gen r`wv'iwy=real(substr(begintime,1,4))
replace r`wv'iwy=real(substr(endtime,1,4)) if r`wv'iwy == 2012 //fixing one obs
replace r`wv'iwy=real(substr(begintime_cv,1,4)) if mi(r`wv'iwy)
label variable r`wv'iwy  "r`wv'iwy:w`wv' r year of interview"

*spouse
gen s`wv'iwy=.
spouse r`wv'iwy, result(s`wv'iwy) wave(`wv')
label variable s`wv'iwy "s`wv'iwy:w`wv' s year of interview" 

***interview month
gen r`wv'iwm=real(substr(begintime,6,2))
replace r`wv'iwm=real(substr(begintime_cv,6,2)) if mi(r`wv'iwm)
label variable r`wv'iwm  "r`wv'iwm:w`wv' r month of interview"

*spouse 
gen s`wv'iwm=.
spouse r`wv'iwm, result(s`wv'iwm) wave(`wv')
label variable s`wv'iwm "s`wv'iwm:w`wv' s month of interview" 

*********************************************************************
***Birth Date***
*********************************************************************
***self-reproted birth year
gen rabyearsr=.
missing_lasi dm004_year, result(rabyearsr) wave(`wv') 
replace rabyearsr=dm004_year if inrange(dm004_year,1902,2000)
label variable rabyearsr "rabyearsr: r birth year, self-reported"

***birth month
gen rabmonth=.
missing_lasi dm004_month, result(rabmonth) wave(`wv') 
replace rabmonth=dm004_month if inrange(dm004_month,1,12)
label variable rabmonth "rabmonth: r birth month"

*spouse
gen s`wv'bmonth=.
spouse rabmonth, result(s`wv'bmonth) wave(`wv')
label variable s`wv'bmonth "s`wv'bmonth:w`wv' s birth month" 

*********************************************************************
***Age at Interview***
*********************************************************************
***self-reported age at interview
gen r`wv'ageysr=.
missing_lasi dm005, result(r`wv'ageysr) wave(`wv')
replace r`wv'ageysr=dm005 if inrange(dm005,18,116)
label variable r`wv'ageysr "r`wv'ageysr:w`wv' r age (years) at ivw, self-reported"

*********************************************************************
***Gender***
*********************************************************************

***gender
gen ragender=.
missing_lasi dm003, result(ragender) wave(`wv')
replace ragender=dm003 if inrange(dm003,1,3)
label variable ragender "ragender: r gender"
label values ragender genderf

*spouse 
gen s`wv'gender=.
spouse ragender, result(s`wv'gender) wave(`wv')
label variable s`wv'gender "s`wv'gender:w`wv' s gender" 
label values s`wv'gender genderf

*********************************************************************
***Education: Categorical Summary***
*********************************************************************

***highest level of education
gen raeduc_l=.
missing_lasi dm006 dm008, result(raeduc_l) wave(`wv')
replace raeduc_l= 0 if dm006== 2 
replace raeduc_l= dm008 if inrange(dm008,1,9)
label variable raeduc_l "raeduc_l: r highest level of education"
label values raeduc_l raeduc_l

*spouse 
gen s`wv'educ_l=.
spouse raeduc_l, result(s`wv'educ_l) wave(`wv')
replace s`wv'educ_l = 0 if fs101_1 == 2 & mi(s`wv'educ_l)
replace s`wv'educ_l = fs102_1 if inrange(fs102_1,1,9) & mi(s`wv'educ_l)
qui levelsof fs101_spouse_namehh_1_, local(hhpids)
foreach hhpid of local hhpids {
    replace s`wv'educ_l = 0 if cv008_`hhpid' == 2 & fs101_spouse_namehh_1_ == `hhpid' & mi(s`wv'educ_l)
    replace s`wv'educ_l = cv010_`hhpid' if inrange(cv010_`hhpid',1,9) & fs101_spouse_namehh_1_ == `hhpid' & mi(s`wv'educ_l)
}
forvalues p = 1/35 {
    replace s`wv'educ_l = 0 if cv008_`p' == 2 & cv003_`p' == 2 & hhorder == 1 & mi(s`wv'educ_l)
    replace s`wv'educ_l = cv010_`p' if inrange(cv010_`p',1,9) & cv003_`p' == 2 & hhorder == 1 & mi(s`wv'educ_l)
}
recode s`wv'educ_l (.v=.m)
label variable s`wv'educ_l "s`wv'educ_l:w`wv' s highest level of education"
label values s`wv'educ_l raeduc_l

***education: harmonized levels
gen raeducl=.
missing_lasi dm006 dm008, result(raeducl) wave(`wv')
replace raeducl=1 if dm006== 2
replace raeducl=1 if inlist(dm008,1,2)
replace raeducl=2 if inlist(dm008,3,4,5,6)
replace raeducl=3 if inlist(dm008,7,8,9)
label variable raeducl "raeducl: r harmonized education category"  
label values raeducl educl 

*spouse
gen s`wv'educl=.
spouse raeducl, result(s`wv'educl) wave(`wv')
replace s`wv'educl=1 if fs101_1 == 2 & mi(s`wv'educl)
replace s`wv'educl=1 if inlist(fs102_1,1,2) & mi(s`wv'educl)
replace s`wv'educl=2 if inlist(fs102_1,3,4,5,6) & mi(s`wv'educl)
replace s`wv'educl=3 if inlist(fs102_1,7,8,9) & mi(s`wv'educl)
qui levelsof fs101_spouse_namehh_1_, local(hhpids)
foreach hhpid of local hhpids {
    replace s`wv'educl = 1 if cv008_`hhpid' == 2 & fs101_spouse_namehh_1_ == `hhpid' & mi(s`wv'educl)
    replace s`wv'educl = 1 if inlist(cv010_`hhpid',1,2) & fs101_spouse_namehh_1_ == `hhpid' & mi(s`wv'educl)
    replace s`wv'educl = 2 if inlist(cv010_`hhpid',3,4,5,6) & fs101_spouse_namehh_1_ == `hhpid' & mi(s`wv'educl)
    replace s`wv'educl = 3 if inlist(cv010_`hhpid',7,8,9) & fs101_spouse_namehh_1_ == `hhpid' & mi(s`wv'educl)
}
forvalues p = 1/35 {
    replace s`wv'educl = 1 if cv008_`p' == 2 & cv003_`p' == 2 & hhorder == 1 & mi(s`wv'educl)
    replace s`wv'educl = 1 if inlist(cv010_`p',1,2) & cv003_`p' == 2 & hhorder == 1 & mi(s`wv'educl)
    replace s`wv'educl = 2 if inlist(cv010_`p',3,4,5,6) & cv003_`p' == 2 & hhorder == 1 & mi(s`wv'educl)
    replace s`wv'educl = 3 if inlist(cv010_`p',7,8,9) & cv003_`p' == 2 & hhorder == 1 & mi(s`wv'educl)
}
recode s`wv'educl (.v=.m)
label variable s`wv'educl "s`wv'educl:w`wv' s harmonized education category"
label values s`wv'educl educl

*********************************************************************
***Years of Education***
*********************************************************************
***education: years of education
gen raedyrs=.
missing_lasi dm006 dm007, result(raedyrs) wave(`wv')
replace raedyrs=0 if dm006== 2
replace raedyrs=dm007 if inrange(dm007,1,26)
forvalues p = 1/35 {
    replace raedyrs = 0 if cv008_`p' == 2 & `p' == hhorder & mi(raedyrs)
    replace raedyrs = cv009_`p' if inrange(cv009_`p',1,28) & `p' == hhorder & mi(raedyrs)
}
label variable raedyrs "raedyrs: r years of education"

*spouse
gen s`wv'edyrs=.
spouse raedyrs, result(s`wv'edyrs) wave(`wv')
qui levelsof fs101_spouse_namehh_1_, local(hhpids)
foreach hhpid of local hhpids {
    replace s`wv'edyrs = 0 if cv008_`hhpid' == 2 & fs101_spouse_namehh_1_ == `hhpid' & mi(s`wv'edyrs)
    replace s`wv'edyrs = cv009_`hhpid' if inrange(cv009_`hhpid',1,28) & fs101_spouse_namehh_1_ == `hhpid' & mi(s`wv'edyrs)
}
forvalues p = 1/35 {
    replace s`wv'edyrs = 0 if cv008_`p' == 2 & cv003_`p' == 2 & hhorder == 1 & mi(s`wv'edyrs)
    replace s`wv'edyrs = cv009_`p' if inrange(cv009_`p',1,28) & cv003_`p' == 2 & hhorder == 1 & mi(s`wv'edyrs)
}
label variable s`wv'edyrs "s`wv'edyrs:w`wv' s years of education"

***update education
replace raeduc_l = 0 if (raedyrs == 0 & missing(raeduc_l))
replace raeduc_l = 1 if (raedyrs == 1 & missing(raeduc_l))

replace raeducl  = 1 if (raedyrs == 0 & missing(raeducl))
replace raeducl  = 1 if (raedyrs == 1 & missing(raeducl))

replace raedyrs = 0 if (prim_key == "119115900070301")

********************************************************************
***Literacy***
********************************************************************

recode dm009 (1 2 3=1 "1.literate") (4=0 "0.illiterate"), gen(raliterate)
replace raliterate=1 if dm006==1 & dm007 > 5 & dm007 < .
replace raliterate=.m if raliterate==.
label variable raliterate "raliterate:w`wv' r literacy"

* spouse
gen s`wv'literate=.
spouse raliterate, result(s`wv'literate) wave(`wv')
label variable s`wv'literate "s`wv'literate:w`wv' s literacy"
label values s`wv'literate lit

*********************************************************************
***Access to Schooling***
*********************************************************************

***merge with contexutal schooling file***
recode dm019_state (5=9) (20=10) (22=23) (36=28)

gen distname = ""
replace distname= "Baramula" if dm019_district == 1
replace distname= "Srinagar" if dm019_district == 2
replace distname= "Ladakh" if dm019_district == 3
replace distname= "Ladakh" if dm019_district == 4
replace distname= "Punch" if dm019_district == 5
replace distname= "Rajauri" if dm019_district == 6
replace distname= "Kathua" if dm019_district == 7
replace distname= "Baramula" if dm019_district == 8
replace distname= "Baramula" if dm019_district == 9
replace distname= "Srinagar" if dm019_district == 10
replace distname= "Srinagar" if dm019_district == 11
replace distname= "Anantnag" if dm019_district == 12
replace distname= "Anantnag" if dm019_district == 13
replace distname= "Anantnag" if dm019_district == 14
replace distname= "Anantnag" if dm019_district == 15
replace distname= "Doda" if dm019_district == 16
replace distname= "Doda" if dm019_district == 17
replace distname= "Doda" if dm019_district == 18
replace distname= "Udhampur" if dm019_district == 19
replace distname= "Udhampur" if dm019_district == 20
replace distname= "Jammu" if dm019_district == 21
replace distname= "Jammu" if dm019_district == 22
replace distname= "Chamba" if dm019_district == 23
replace distname= " Kangra" if dm019_district == 24
replace distname= "Lahul and Spiti" if dm019_district == 25
replace distname= "Kulu" if dm019_district == 26
replace distname= "Mandi" if dm019_district == 27
replace distname= " Kangra" if dm019_district == 28
replace distname= " Kangra" if dm019_district == 29
replace distname= "Bilaspur" if dm019_district == 30
replace distname= "Simla" if dm019_district == 31
replace distname= "Sirmaur" if dm019_district == 32
replace distname= "Simla" if dm019_district == 33
replace distname= "Kinnaur" if dm019_district == 34
replace distname= "Gurdaspur" if dm019_district == 35
replace distname= "Kapurthala" if dm019_district == 36
replace distname= "Jalandhar" if dm019_district == 37
replace distname= "Hoshiarpur" if dm019_district == 38
replace distname= "Jalandhar" if dm019_district == 39
replace distname= "Patiala" if dm019_district == 40
replace distname= "Ludhiana" if dm019_district == 41
replace distname= "Faridkot" if dm019_district == 42
replace distname= "Firozpur" if dm019_district == 43
replace distname= "Firozpur" if dm019_district == 44
replace distname= "Firozpur" if dm019_district == 45
replace distname= "Bhatinda" if dm019_district == 46
replace distname= "Bhatinda" if dm019_district == 47
replace distname= "Patiala" if dm019_district == 48
replace distname= "Amritsar" if dm019_district == 49
replace distname= "Amritsar" if dm019_district == 50
replace distname= "Rupnagar" if dm019_district == 51
replace distname= "Rupnagar" if dm019_district == 52
replace distname= "Sangrur" if dm019_district == 53
replace distname= "Sangrur" if dm019_district == 54

replace distname= "Uttar Kashi" if dm019_district == 56
replace distname= "Chamoli" if dm019_district == 57
replace distname= "Chamoli" if dm019_district == 58
replace distname= "Tehri Garwhal" if dm019_district == 59
replace distname= "Dehra Dun" if dm019_district == 60
replace distname= "Garwhal" if dm019_district == 61
replace distname= "Pithorgarh" if dm019_district == 62
replace distname= "Almora" if dm019_district == 63
replace distname= "Almora" if dm019_district == 64
replace distname= "Pithorgarh" if dm019_district == 65
replace distname= "Naini Tal" if dm019_district == 66
replace distname= "Naini Tal" if dm019_district == 67
replace distname= "Saharanpur" if dm019_district == 68
replace distname= "Ambala" if dm019_district == 69
replace distname= "Ambala" if dm019_district == 70
replace distname= "Ambala" if dm019_district == 71
replace distname= "Karnal" if dm019_district == 72
replace distname= "Karnal" if dm019_district == 73
replace distname= "Karnal" if dm019_district == 74
replace distname= "Karnal" if dm019_district == 75
replace distname= "Rohtak" if dm019_district == 76
replace distname= "Jind" if dm019_district == 77
replace distname= "Hisar" if dm019_district == 78
replace distname= "Hisar" if dm019_district == 79
replace distname= "Hisar" if dm019_district == 80
replace distname= "Hisar" if dm019_district == 81
replace distname= "Rohtak" if dm019_district == 82
replace distname= "Rohtak" if dm019_district == 83
replace distname= "Mahendragarh" if dm019_district == 84
replace distname= "Mahendragarh" if dm019_district == 85
replace distname= "Gurgaon" if dm019_district == 86
replace distname= "Gurgaon" if dm019_district == 87
replace distname= "Gurgaon" if dm019_district == 88
replace distname= "Gurgaon" if dm019_district == 89

replace distname= "Ganganagar" if dm019_district == 99
replace distname= "Ganganagar" if dm019_district == 100
replace distname= "Bikaner" if dm019_district == 101
replace distname= "Churu" if dm019_district == 102
replace distname= "Jhunjhunun" if dm019_district == 103
replace distname= "Alwar" if dm019_district == 104
replace distname= "Bharatpur" if dm019_district == 105
replace distname= "Bharatpur" if dm019_district == 106
replace distname= "Sawai Madhopur" if dm019_district == 107
replace distname= "Sawai Madhopur" if dm019_district == 108
replace distname= "Jaipur" if dm019_district == 109
replace distname= "Jaipur" if dm019_district == 110
replace distname= "Sikar" if dm019_district == 111
replace distname= "Nagaur" if dm019_district == 112
replace distname= "Jodhpur" if dm019_district == 113
replace distname= "Jaisalmer" if dm019_district == 114
replace distname= "Barmer" if dm019_district == 115
replace distname= "Jalor" if dm019_district == 116
replace distname= "Sirohi" if dm019_district == 117
replace distname= "Pali" if dm019_district == 118
replace distname= "Ajmer" if dm019_district == 119
replace distname= "Tonk" if dm019_district == 120
replace distname= "Bundi" if dm019_district == 121
replace distname= "Bhilwara" if dm019_district == 122
replace distname= "Udaipur" if dm019_district == 123
replace distname= "Dungarpur" if dm019_district == 124
replace distname= "Banswara" if dm019_district == 125
replace distname= "Chittaugarh" if dm019_district == 126
replace distname= "Kota" if dm019_district == 127
replace distname= "Kota" if dm019_district == 128
replace distname= "Jhalawar" if dm019_district == 129
replace distname= "Udaipur" if dm019_district == 130
replace distname= "Pratapgarh" if dm019_district == 131
replace distname= "Saharanpur" if dm019_district == 132
replace distname= "Muzaffarnagar" if dm019_district == 133
replace distname= "Bijnor" if dm019_district == 134
replace distname= "Moradabad" if dm019_district == 135
replace distname= "Rampur" if dm019_district == 136
replace distname= "Moradabad" if dm019_district == 137
replace distname= "Meerut" if dm019_district == 138
replace distname= "Meerut" if dm019_district == 139
replace distname= "Meerut" if dm019_district == 140
replace distname= "Meerut" if dm019_district == 141
replace distname= "Bulandshahr" if dm019_district == 142
replace distname= "Aligarh" if dm019_district == 143
replace distname= "Aligarh" if dm019_district == 144
replace distname= "Mathura" if dm019_district == 145
replace distname= "Agra" if dm019_district == 146
replace distname= "Mainpuri" if dm019_district == 147
replace distname= "Mainpuri" if dm019_district == 148
replace distname= "Budaun" if dm019_district == 149
replace distname= "Bareilly" if dm019_district == 150
replace distname= "Pilibhit" if dm019_district == 151
replace distname= "Shahjahhanpur" if dm019_district == 152
replace distname= "Kheri" if dm019_district == 153
replace distname= "Sitapur" if dm019_district == 154
replace distname= "Hardoi" if dm019_district == 155
replace distname= "Unnao" if dm019_district == 156
replace distname= "Lucknow" if dm019_district == 157
replace distname= "Rai Bareli" if dm019_district == 158
replace distname= "Farrukhabad" if dm019_district == 159
replace distname= "Farrukhabad" if dm019_district == 160
replace distname= "Etawah" if dm019_district == 161
replace distname= "Etawah" if dm019_district == 162
replace distname= "Kanpur" if dm019_district == 163
replace distname= "Kanpur" if dm019_district == 164
replace distname= "Jalaun" if dm019_district == 165
replace distname= "Jhansi" if dm019_district == 166
replace distname= "Jhansi" if dm019_district == 167
replace distname= "Hamirpur" if dm019_district == 168
replace distname= "Hamirpur" if dm019_district == 169
replace distname= "Banda" if dm019_district == 170
replace distname= "Banda" if dm019_district == 171
replace distname= "Fatehpur" if dm019_district == 172
replace distname= "Pratapgarh" if dm019_district == 173
replace distname= "Allahabad" if dm019_district == 174
replace distname= "Allahabad" if dm019_district == 175
replace distname= "Bara Banki" if dm019_district == 176
replace distname= "Faizabad" if dm019_district == 177
replace distname= "Faizabad" if dm019_district == 178
replace distname= "Sultanpur" if dm019_district == 179
replace distname= "Bahraich" if dm019_district == 180
replace distname= "Bahraich" if dm019_district == 181
replace distname= "Gonda" if dm019_district == 182
replace distname= "Gonda" if dm019_district == 183
replace distname= "Basti" if dm019_district == 184
replace distname= "Basti" if dm019_district == 185
replace distname= "Basti" if dm019_district == 186
replace distname= "Gorakhpur" if dm019_district == 187
replace distname= "Gorakhpur" if dm019_district == 188
replace distname= "Deoria" if dm019_district == 189
replace distname= "Deoria" if dm019_district == 190
replace distname= "Azamgarh" if dm019_district == 191
replace distname= "Azamgarh" if dm019_district == 192
replace distname= "Ballia" if dm019_district == 193
replace distname= "Jaunpur" if dm019_district == 194
replace distname= "Ghazipur" if dm019_district == 195
replace distname= "Varanasi" if dm019_district == 196
replace distname= "Varanasi" if dm019_district == 197
replace distname= "Varanasi" if dm019_district == 198
replace distname= "Mirzapur" if dm019_district == 199
replace distname= "Mirzapur" if dm019_district == 200
replace distname= "Etah" if dm019_district == 201
replace distname= "Etah" if dm019_district == 202
replace distname= "Champaran" if dm019_district == 203
replace distname= "Champaran" if dm019_district == 204
replace distname= "Muzaffarpur" if dm019_district == 205
replace distname= "Muzaffarpur" if dm019_district == 206
replace distname= "Darbhanga" if dm019_district == 207
replace distname= "Saharsa" if dm019_district == 208
replace distname= "Purnia" if dm019_district == 209
replace distname= "Purnia" if dm019_district == 210
replace distname= "Purnia" if dm019_district == 211
replace distname= "Purnia" if dm019_district == 212
replace distname= "Saharsa" if dm019_district == 213
replace distname= "Saharsa" if dm019_district == 214
replace distname= "Darbhanga" if dm019_district == 215
replace distname= "Muzaffarpur" if dm019_district == 216
replace distname= "Saran" if dm019_district == 217
replace distname= "Saran" if dm019_district == 218
replace distname= "Saran" if dm019_district == 219
replace distname= "Muzaffarpur" if dm019_district == 220
replace distname= "Darbhanga" if dm019_district == 221
replace distname= "Munger" if dm019_district == 222
replace distname= "Munger" if dm019_district == 223
replace distname= "Bhagalpur" if dm019_district == 224
replace distname= "Bhagalpur" if dm019_district == 225
replace distname= "Munger" if dm019_district == 226
replace distname= "Munger" if dm019_district == 227
replace distname= "Munger" if dm019_district == 228
replace distname= "Patna" if dm019_district == 229
replace distname= "Patna" if dm019_district == 230
replace distname= "Shahbad" if dm019_district == 231
replace distname= "Shahbad" if dm019_district == 232
replace distname= "Shahbad" if dm019_district == 233
replace distname= "Shahbad" if dm019_district == 234
replace distname= "Gaya" if dm019_district == 235
replace distname= "Gaya" if dm019_district == 236
replace distname= "Gaya" if dm019_district == 237
replace distname= "Munger" if dm019_district == 238
replace distname= "Gaya" if dm019_district == 239
replace distname= "Gaya" if dm019_district == 240

gen school_distid = string(dm019_state) + "_" + distname if !mi(distname)

merge m:1 school_distid using "$school_1971_"
drop if _merge == 2
drop _merge

***1971 census access to schooling: primary school
gen raeduprim=.
missing_lasi primary_access_dist, result(raeduprim) wave(`wv')
replace raeduprim=primary_access_dist
label variable raeduprim "raeduprim: r 1971 census district access to primary school"

*spouse
gen s`wv'eduprim=.
spouse raeduprim, result(s`wv'eduprim) wave(`wv')
label variable s`wv'eduprim "s`wv'eduprim:w`wv' s 1971 census district access to primary school"

***1971 census access to schooling: middle school
gen raedumid=.
missing_lasi middle_access_dist, result(raedumid) wave(`wv')
replace raedumid=middle_access_dist
label variable raedumid "raedumid: r 1971 census district access to middle school"

*spouse
gen s`wv'edumid=.
spouse raedumid, result(s`wv'edumid) wave(`wv')
label variable s`wv'edumid "s`wv'edumid:w`wv' s 1971 census district access to middle school"

***1971 census access to schooling: high school
gen raeduhigh=.
missing_lasi high_access_dist, result(raeduhigh) wave(`wv')
replace raeduhigh=high_access_dist 
label variable raeduhigh "raeduhigh: r 1971 census district access to high school"

*spouse
gen s`wv'eduhigh=.
spouse raeduhigh, result(s`wv'eduhigh) wave(`wv')
label variable s`wv'eduhigh "s`wv'eduhigh:w`wv' s 1971 census district access to high school"

drop primary_access_dist middle_access_dist high_access_dist ///
     primary_access_st   middle_access_st   high_access_st ///
     distname school_distid
     
*********************************************************************
***Current Marital Status, without implied partnership***
*********************************************************************
  
***current marital status
gen r`wv'mstath=.
missing_lasi dm021, result(r`wv'mstath) wave(`wv')
replace r`wv'mstath=1 if dm021==1
replace r`wv'mstath=7 if dm021==2
replace r`wv'mstath=5 if inlist(dm021,3,5)
replace r`wv'mstath=4 if dm021==4
replace r`wv'mstath=8 if dm021==7
replace r`wv'mstath=3 if dm021==6
label variable r`wv'mstath "r`wv'mstath:w`wv' r marital status, self-reported"
label values r`wv'mstath mstat

*spouse 
gen s`wv'mstath=.
spouse r`wv'mstath, result(s`wv'mstath) wave(`wv')
label variable s`wv'mstath "s`wv'mstath:w`wv' s marital status, self-reported" 
label values s`wv'mstath mstat

*********************************************************************
***Never Married***
*********************************************************************

***never married 
gen r`wv'mnev=.
missing_lasi dm021, result(r`wv'mnev)
replace r`wv'mnev=0 if inlist(dm021,1,2,3,4,5,6)
replace r`wv'mnev=1 if dm021==7
label variable  r`wv'mnev "r`wv'mnev:w`wv' r never married"
label values r`wv'mnev yesno2

*spouse 
gen s`wv'mnev=.
spouse r`wv'mnev, result(s`wv'mnev) wave(`wv')
label variable s`wv'mnev "s`wv'mnev:w`wv' s never married" 
label val s`wv'mnev yesno2

*********************************************************************
***Number of Marriages***
*********************************************************************

***number of marriages
***one record has 27 recode to .m
gen r`wv'mrct=.
missing_lasi dm028_totalmarriage dm021, result(r`wv'mrct) wave(`wv')
replace r`wv'mrct= 0 if dm021==7
replace r`wv'mrct=dm028_totalmarriage if inrange(dm028_totalmarriage,1,7)
replace r`wv'mrct=.m if dm028_totalmarriage==27
label variable r`wv'mrct "r`wv'mrct:w`wv' r # marriages"

*spouse 
gen s`wv'mrct=.
spouse r`wv'mrct, result(s`wv'mrct) wave(`wv')
label variable s`wv'mrct "s`wv'mrct:w`wv' s # marriages"

*********************************************************************
***Length of Current Marriage***
*********************************************************************
***length of current marriage
gen r`wv'mcurln=.
missing_lasi dm029_year r`wv'mstath, result(r`wv'mcurln) wave(`wv')
replace r`wv'mcurln=.u if inlist(r`wv'mstath,5,7,8)
replace r`wv'mcurln=.d if dm029_year== 9998
replace r`wv'mcurln=r`wv'iwy - dm029_year if inlist(r`wv'mstath,1,2,4) & inrange(dm029_year,1850,2019)
replace r`wv'mcurln=.i if r`wv'mcurln>r`wv'ageysr & inrange(r`wv'mcurln,0,200) & inrange(r`wv'ageysr,0,200)
label variable r`wv'mcurln "r`wv'mcurln:w`wv' r length of current marriage"

*spouse
gen s`wv'mcurln=.
spouse r`wv'mcurln, result(s`wv'mcurln) wave(`wv')
label variable s`wv'mcurln "s`wv'mcurln:w`wv' s length of current marriage"
 
*********************************************************************
***Caste in India***
*********************************************************************

gen r`wv'caste=.
replace r`wv'caste=.m if (dm012== . | dm013== .) & inw`wv'== 1     
replace r`wv'caste=.d if inlist(dm012,.d,4) | dm013== .d
replace r`wv'caste=.r if dm012== .r | dm013== .r                      
replace r`wv'caste=1 if dm012== 1 | dm013== 1 | inlist(dm013_other,"bagdi kumar","balmiki","rai sikh","rajsikh","rai","Majbi sikh") | ///
							         inlist(dm013_other,"mAJBI sIKH","majbi sikh","harijan","harIJAN" ,"Harijan")
replace r`wv'caste=2 if dm012== 2 | dm013== 2 | inlist(dm013_other,"ADIVAsI","adivashi","adivasi" )
replace r`wv'caste=3 if dm013== 3 | inlist(dm013_other,"Lamani","chimpa","chippa" )
replace r`wv'caste=4 if dm012== 3 | dm013== 4 | dm013== 5  
label variable r`wv'caste "r`wv'caste: r caste system"
label value r`wv'caste caste

*spouse
gen s`wv'caste=.
spouse r`wv'caste, result(s`wv'caste) wave(`wv')
label variable s`wv'caste "s`wv'caste:w`wv' s caste system"
label value s`wv'caste caste

*********************************************************************
***Religion***
*********************************************************************

***religion
gen r`wv'relig_l=.
missing_lasi dm010, result(r`wv'relig_l) wave(`wv')
replace r`wv'relig_l=dm010 if inrange(dm010,1,10)
label variable r`wv'relig_l "r`wv'relig_l:w`wv' r religion"
label value r`wv'relig_l reli

*spouse
gen s`wv'relig_l=.
spouse r`wv'relig_l, result(s`wv'relig_l) wave(`wv')
label variable s`wv'relig_l "s`wv'relig_l:w`wv' s religion"
label value s`wv'relig_l reli

*********************************************************************
***Place of Birth: state***
*********************************************************************

***birth place- state
gen rabplace=.
missing_lasi dm016 dm017_country dm017_state, result(rabplace) wave(`wv')
replace rabplace=37 if inrange(dm017_country,1,76) | inrange(dm017_country,79,186)
replace rabplace=dm017_state if inrange(dm017_state,1,36) & !mi(dm017_state)
replace rabplace=stateid if mi(rabplace) & dm016==9993
label variable rabplace "rabplace: r place of birth (state)"
label values rabplace rabplace

*spouse
gen s`wv'bplace=.
spouse rabplace, result(s`wv'bplace) wave(`wv')
label variable s`wv'bplace "s`wv'bplace:w`wv' s place of birth (state)"
label values s`wv'bplace rabplace


*********************************************************************
***Interviewed in Country of Birth:***
*********************************************************************

***Country place
gen rabcountry=.
missing_lasi dm016 dm017_country , result(rabcountry) wave(`wv')
replace rabcountry=0 if inrange(dm017_country,1,186) 
replace rabcountry=1 if dm016==9993 | dm017_country==78
label variable rabcountry "rabcountry: r born in country of interview"
label values rabcountry incountry

*spouse
gen s`wv'bcountry=.
spouse rabcountry, result(s`wv'bcountry) wave(`wv')
label variable s`wv'bcountry "s`wv'bcountry:w`wv' s born in country of interview"
label values s`wv'bcountry incountry

*********************************************************************
***Country of Birth:***
*********************************************************************

***Country place
gen rabcountry_l=.
missing_lasi dm016 dm017_country , result(rabcountry_l) wave(`wv')
replace rabcountry_l=78 if dm016==9993
replace rabcountry_l=dm017_country if inrange(dm017_country,1,186) 

label variable rabcountry_l "rabcountry_l: r country of birth"
label values rabcountry_l rabcountry

*spouse
gen s`wv'bcountry_l=.
spouse rabcountry_l, result(s`wv'bcountry_l) wave(`wv')
label variable s`wv'bcountry_l "s`wv'bcountry_l:w`wv' s country of birth"
label values s`wv'bcountry_l rabcountry

*********************************************************************
***Live in Urban or Rural Area 1=rural 2=urban***
*********************************************************************
***urban/rural
gen hh`wv'rural=.
replace hh`wv'rural = 1 if urbanrural == 1
replace hh`wv'rural = 0 if urbanrural == 2
label variable hh`wv'rural "hh`wv'rural:w`wv' lives in rural or urban area" 
label values hh`wv'rural livreg

*********************************************************************
***State in India***
*********************************************************************
***interview state
gen hh`wv'state=.
replace hh`wv'state = stateid
label variable hh`wv'state "hh`wv'state:w`wv' interview state"
label values hh`wv'state rabplace

*********************************************************************
***Interview Language***
*********************************************************************

***language of interview
gen r`wv'lang_l=.
replace r`wv'lang_l = .m if inw`wv' == 1
replace r`wv'lang_l=language_mode if inrange(language_mode,1,19)
label var r`wv'lang_l "r`wv'lang_l:w`wv' r language of interview" 
label values r`wv'lang_l lang

*spouse
gen s`wv'lang_l=.
spouse r`wv'lang_l, result(s`wv'lang_l) wave(`wv')
label var s`wv'lang_l "s`wv'lang_l:w`wv' s language of interview" 
label values s`wv'lang_l lang


***************************************
drop langdata 


***drop LASI wave 1 indivudal file raw variables***
drop `demog_w1_ind'

***drop LASI Wave 1 raw indivudal file raw variables***
drop `demog_w1_raw_ind'

***drop LASI wave 1 household file raw variables***
drop `demog_w1_hh'

***drop wave 1 cover screen file raw variales***
drop `demog_1_cv'

***drop wave 1 raw cover screen file raw variales***
drop `demog_1_raw_cv'

***drop wave 1 language file raw variales***
drop language_mode

***drop education variables***
*drop `school_w1_core' 

***drop LASI wave 1 weights***
drop `demog_w1_weight'



***merge with coverscreen file***
local demog_add_cv cv006_? cv006_1? cv006_2? cv006_3?

merge m:1 hhid using "$wave_1_cv", keepusing(`demog_add_cv') 
drop if _merge==2
drop _merge 

***cover screen age
gen r1ageycv = .
ds cv006_? cv006_1? cv006_2? cv006_3?
local count :  word count `r(varlist)'
forvalues hm = 1 / `count' {
    replace r1ageycv = cv006_`hm' if hhorder == `hm' & inrange(cv006_`hm',0,116)
}

***age based on birth year
gen r1ageyby = r1iwy - rabyearsr

***difference between self-reproted age and self-reported birth year
gen r1agediff1 = r1ageysr - r1ageyby
replace r1agediff1 = 0 if r1agediff1 == -1
replace r1agediff1 = abs(r1agediff1)

***difference between self-reproted age and coverscreen age
gen r1agediff2 = r1ageysr - r1ageycv
replace r1agediff2 = abs(r1agediff2)

***difference between coverscreen age and self-reproted birth year
gen r1agediff3 = r1ageycv - r1ageyby 
replace r1agediff3 = 0 if r1agediff3 == -1
replace r1agediff3 = abs(r1agediff3)

egen numberages = rownonmiss(r1ageysr r1ageyby r1ageycv)

egen r1agediffmin = rowmin(r1agediff1 r1agediff2 r1agediff3) 
egen r1agediffmax = rowmax(r1agediff1 r1agediff2 r1agediff3) 

gen r1agewagree = .
replace r1agewagree = 3 if r1agediffmin == r1agediff3 & !mi(r1agediffmin)
replace r1agewagree = 2 if r1agediffmin == r1agediff2 & !mi(r1agediffmin)
replace r1agewagree = 1 if r1agediffmin == r1agediff1 & !mi(r1agediffmin)

***wave 1 respondent age at interview, cleaned
gen r1agey = .
replace r1agey = r1ageysr if inlist(r1agewagree,1,2) & numberages == 3
replace r1agey = r1ageycv if r1agewagree == 3 & numberages == 3
replace r1agey = r1ageysr if r1agediffmin == 0 & numberages == 2
replace r1agey = r1ageycv if r1agediffmin == 0 & numberages == 2 & mi(r1agey) 
replace r1agey = r1ageyby if r1agediffmin == 0 & numberages == 2 & mi(r1agey) 
replace r1agey = r1ageysr if r1agediffmin > 0 & numberages == 2 & mi(r1agey) 
replace r1agey = r1ageycv if r1agediffmin > 0 & numberages == 2 & mi(r1agey) 
replace r1agey = r1ageyby if r1agediffmin > 0  & numberages == 2 & mi(r1agey) 
replace r1agey = r1ageysr if mi(r1agediffmin) & mi(r1agey) 
replace r1agey = r1ageycv if mi(r1agediffmin) & mi(r1agey) 
replace r1agey = r1ageyby if mi(r1agediffmin) & mi(r1agey) 
replace r1agey = r1ageysr 
label variable r1agey "r1agey:w1 r age (years) at ivw"

***wave 1 spouse age at interview, cleaned
gen s1agey=.
spouse r1agey, result(s1agey) wave(1)
label variable s1agey "s1agey:w1 s age (years) at ivw" 

***wave 1 respondent age at interview source flag
gen r1fagey = .
replace r1fagey = 1 if inlist(r1agewagree,1,2) & numberages == 3
replace r1fagey = 2 if r1agewagree == 3 & numberages == 3
replace r1fagey = 1 if r1agediffmin == 0 & numberages == 2
replace r1fagey = 2 if r1agediffmin == 0 & numberages == 2 & mi(r1fagey) 
replace r1fagey = 3 if r1agediffmin == 0 & numberages == 2 & mi(r1fagey) 
replace r1fagey = 1 if r1agediffmin > 0 & numberages == 2 & mi(r1fagey) & !mi(r1ageysr)
replace r1fagey = 2 if r1agediffmin > 0 & numberages == 2 & mi(r1fagey) & !mi(r1ageycv)
replace r1fagey = 3 if r1agediffmin > 0 & numberages == 2 & mi(r1fagey) & !mi(r1ageyby)
replace r1fagey = 1 if mi(r1agediffmin) & mi(r1fagey) & !mi(r1ageysr)
replace r1fagey = 2 if mi(r1agediffmin) & mi(r1fagey) & !mi(r1ageycv)
replace r1fagey = 3 if mi(r1agediffmin) & mi(r1fagey) & !mi(r1ageyby)
label variable r1fagey "r1fagey:w1 flag r age (years) at ivw"

label define agesource 1 "self report age" 2 "coverscreen age" 3 "self report birth year"
label values r1fagey agesource


***birth year, cleaned***
gen rabyear = .
replace rabyear = rabyearsr if (r1fagey == 1 & r1agediff1 == 0) | (r1fagey == 2 & r1agediff3 == 0) | r1fagey == 3 
replace rabyear = r1iwy - r1ageysr if r1fagey == 1 & r1agediff1 > 0
replace rabyear = r1iwy - r1ageycv if r1fagey == 2 & r1agediff3 > 0
replace rabyear = rabyearsr 
label variable rabyear "rabyear: r birth year"

gen s1byear=.
spouse rabyear, result(s1byear) wave(1)
label variable s1byear "s1byear:w1 s birth year" 

drop r1ageycv r1ageyby r1agediff? r1agediffmin r1agediffmax r1agewagree r1fagey numberages 

**drop demog wave 1 cover screen file raw variables 
drop `demog_add_cv'

**urban/rural for household and invidual imputations
gen hh1rural_i = hh1rural
tab hh1rural_i if inw1==1,m

**gender for indivudal imputations
gen ragender_i = ragender

tab ragender_i hh1rural_i if inw1==1,m col

**age catagory for indivudal imputations
egen r1agecat_i = cut(r1agey), at(10,50,60,70,199) icode
tab r1agecat_i hh1rural_i if inw1==1,m col

**age catagory for household imputations
merge m:1 hhid using "$wave_1_cv", keepusing(cv006_* cv029)
drop if _merge==2
drop _merge
ds cv006_*
local count : word count `r(varlist)'

gen hh1agey = .
forvalues p = 1 / `count' {
    replace hh1agey = cv006_`p' if cv029 == `p'
}

egen hh1maxagey = rowmax (cv006_*)
egen hh1rmaxagey = max(r1agey), by(hhid)

replace hh1agey = hh1maxagey if mi(hh1agey)
replace hh1agey = hh1rmaxagey if mi(hh1agey)

drop cv006_* cv029
drop hh1maxagey hh1rmaxagey

egen hh1agecat_i = cut(hh1agey), at(10,40,50,60,199) icode
tab hh1agecat_i if inw1==1,m
drop hh1agey

egen onemem = tag(hhid)
tab hh1agecat_i hh1rural_i if inw1==1 & onemem==1,m col
drop onemem

drop r1ageysr rabyearsr



*self-report of health
label define health ///
   1 "1.Excellent"  ///
   2 "2.Very good" ///
   3 "3.Good" ///
   4 "4.Fair" ///
   5 "5.Poor" ///
   .m ".m:Missing" ///
   .s ".s:Skipped" ///
   .d ".d:DK" ///
   .p ".p:Proxy" ///
   .r ".r:Refuse" ///
   .u ".u:Unmar" ///
   .v ".v:Sp Nr" 
  
*self-report of health question position
label define health_pos ///
	1 "1.beginning of module" ///
	2 "2.end of module" ///
	.m ".m:Missing" ///
	 .s ".s:Skipped" ///
  .d ".d:DK" ///
  .r ".r:Refuse" ///
  .u ".u:Unmar" ///
  .v ".v:Sp Nr" 
 
*self-report of health alternative scale
label define health_alt ///
   1 "1.Very good"  ///
   2 "2.Good" ///
   3 "3.Fair" ///
   4 "4.Poor" ///
   5 "5.Very Poor" ///
   .m ".m:Missing" ///
   .s ".s:Skipped" ///
   .p ".p:Proxy" ///
   .d ".d:DK" ///
   .r ".r:Refuse" ///
   .u ".u:Unmar" ///
   .v ".v:Sp Nr" 
   
*self-report of health alternative scale
label define change ///  
   1 "1.Better"  ///
   3 "3.Same" ///
   5 "5.Worse" ///
   .e ".e:Error" ///
   .m ".m:Missing" ///
   .p ".p:Proxy" ///
   .s ".s:Skipped,no prv IW" ///
   .d ".d:DK" ///
   .r ".r:Refuse" ///
   .u ".u:Unmar" ///
   .v ".v:Sp Nr" 

label define vgactx_c ///
    0 "0.no" ///
    1 "1.yes" ///
    .d ".d:DK" ///
    .r ".r:RF" ///
    .s ".s:skip"
    
label define docf                ///
	0 "0.No missing info"                   ///
	1 "1.Missing Public Clinic"            ///
	2 "2.Missing Doctor"                  ///
	3 "3.Missing Public Clinic and Dr"   ///   

*label values
label define premium   ///
	.n ".n:Covered under Medical Aid"      ///
	1 "1.Paid by R"            ///
	2 "2.Paid by S"           ///
	3 "3.Paid by Other"   
   
*Whether health limits work
label define limits ///
   0 "0.Not limited"  ///
   1 "1.Limited, but not severely" /// 
   2 "2.Severely limited" ///
   .s ".s:Skipped" ///
   .m ".m:Missing" ///
   .d ".d:DK" ///
   .r ".r:Refuse" ///
   .u ".u:Unmar" ///
   .v ".v:Sp Nr" 
   
*whether health limits work
label define hlthlm ///
   0 "0.No"  ///
   1 "1.Yes" ///
   .m ".m:Missing" ///
   .w ".w:Not working" ///
   .d ".d:DK" ///
   .r ".r:Refuse" ///
   .u ".u:Unmar" ///
   .v ".v:Sp Nr" ///
   .o ".o:Too old to work"
   
*Some difficulty with ADLs and IADLs
label define diff ///
   0 "0.No"  ///
   1 "1.Yes" ///
   .e ".e:Error" ///
   .m ".m:Missing" ///
   .w ".w:Not working" ///
   .p ".p:Proxy" ///
   .s ".s:Skipped (gender)" ///
   .d ".d:DK" ///
   .r ".r:Refuse" ///
   .u ".u:Unmar" ///
   .v ".v:Sp Nr" ///
   .a ".a:Age less than 50"
      
*ADL summary
label define adla_c  ///
   .s ".s:skip"

*IADL summary
label define iadla_c ///
 .m ".m:missing"
 
*IADL summary 0-5
label define iadlza_c ///
  .m ".m:oth missing"


*Physical activity
label define activity ///
   1 "1.everyday" ///
   2 "2.more than once a week"  ///
   3 "3.once a week"  ///
   4 "4.one to three times a month"  ///
   5 "5.hardly ever or never" ///
   .m ".m:Missing" ///
   .d ".d:DK" ///
   .r ".r:Refuse" ///
   .u ".u:Unmar" ///
   .v ".v:Sp Nr" 
   
   
*Days per week drinks
label define drinkx ///
	 0 "0.None" /// 
   1 "1.Less than once a month"  /// 
   2 "2.One to three days per month" /// 
   3 "3.One to four days per week" /// 
   4 "4.Five or more days per week" ///
	 .m ".m:Missing" ///
   .d ".d:DK" ///
   .r ".r:Refuse" ///
   .u ".u:Unmar" ///
   .v ".v:Sp Nr"
   
*Whether smokes
label define smokes ///
	0 "0.No" ///
	1 "1.Yes" ///
   .m ".m:Missing" ///
   .d ".d:DK" ///
   .r ".r:Refuse" ///
   .u ".u:Unmar" ///
   .v ".v:Sp Nr" 


label define doctor /// 
    0 "0.no" ///
    1 "1.yes" ///
    .m ".m:oth missing" ///
    .d ".d:DK" ///
    .r ".r:RF" ///
    .p ".p:Proxy" ///
    .x ".x:does not have condition" ///
    .s ".s:Skipped" ///
    .u ".u:Unmar" ///
    .v ".v:Sp Nr" ///
    .t ".t:meds, two conditions" /// 
    .g ".g:not asked-gender" 


label define fallslp ///
		1 "1.Frequently (5 or more nights/week)" ///
		2 "2.Occasionally (3-4 nights/week)" ///
		3 "3.Rarely or Never (0-2 nights/week)" ///
		.m ".m:Missing" ///
		.d ".d:DK" ///
		.r ".r:Refuse" ///
		.u ".u:Unmar" ///
    .v ".v:Sp Nr" 

label define drinking ///
		0 "0.no" ///
		1 "1.yes" ///
		.m ".m:Missing" ///
		.d ".d:DK" ///
		.r ".r:Refuse" ///
		.u ".u:Unmar" ///
		.v ".v:SP Nr" ///
		.n ".n:never drank" ///
		.x ".x:has not had >=5 drinks"

label define bingedrink ///
		 0 "0.None or less than once a month" ///
		 1 "1.One to three days per month" ///
		 2 "2.One to four days per week" ///
		 3 "3.Five or more days per week" ///
		 4 "4.Daily" ///
		 .m ".m:Missing" ///
		 .d ".d:DK" ///
		 .r ".r:Refuse" ///
		 .u ".u:Unmar" ///
		 .v ".v:SP Nr"
 
label define doctoraids /// 
    0 "0.no" ///
    1 "1.yes" ///
    .m ".m:oth missing" ///
    .d ".d:DK" ///
    .r ".r:RF" ///
    .s ".s:Skipped" ///
    .u ".u:Unmar" ///
    .v ".v:Sp Nr" 

label define painfrq ///
	1 "1.Frequently (5 or more days per week)" /// 
	2 "2.Occasionally (3-4 days per week)" /// 
	3 "3.Rarely (1-2 days per week)" /// 
	.m ".m:Missing" ///
	.d ".d:DK" ///
	.r ".r:Refuse" ///
	.x ".x:does not have condition" ///
	.u ".u:Unmar" ///
   .v ".v:Sp Nr" 

*set wave number
local wv=1

***merge with  data***
local health_w1_ind	ht001_a ht001_b ht002 ht002b_age ht002b_year ht002c ht003 ht003b_age ht003b_year ht003c /// 
					ht003d ht004 ht004b_age ht004b_year ht004fs1 ht004fs2 ht004fs3 ht004fs4 ht004fs5 ht004fs6 ///
					ht005 ht005b_age ht005b_year ht005ds1 ht005ds2 ht005ds3 ht005ds4 ///
					ht006 ht006a ht006b_age ht006b_year ht006d_age ht006d_year ht006fs3 ht006fs4 ht006g ht006h /// 
					ht007 ht007b_age ht007b_year ht007c ht008 ht008c_age ht008c_year ht008e_age ht008e_year ht008f ht008as1 ///
					ht008as2 ht008as3 ht008as4 ht008a_other ht009 ht009as1 ht009as2 ht009as3 ht009as4 ht009as5 ///
					ht009c_age ht009c_year ht009d ht009e ht010 ht010b_age ht010b_year ht010c ht010d ht011s1 ht011s2 ht011s3 ///
					ht012s2 ht012s3 ht014 ht015 ht017s1 ht017s2 ht017s3 ht017s4 ht017s5 ht017s6 ht018 ht018_other ///
					ht019 ht020 ht021 ht024s2 ht024s3 ht024s4 ///
					ht024s6 ht025 ht101 ht102 ht102as7 ht103 ht103a ht103b ht203 ht204 ht205 ///
					ht207 ht211s1 ht211s7 ht219 ht220 ht221 ht211s2 ht222 ht223 ht225 ht226 ///
					ht227s1 ht227s4 ht228 ht229s1 ht229s2 ht229s3 ht229s4 ht229s5 ht229s6 ht229s7 /// 
					ht229s8 ht229s9 ht229s10 ht236_month ht236_year ht239 ht241 ht242 ht300 ht301 ht302 ht303 ///
					ht304 ht305 ht306 ht307 ht308 ht309 ht310 ht311 mh126 ht241 ///
					ht242 ht401 ht402 ht403 ht404 ht405 ht406 ht407 ht408 ht409 ///
					ht410 ht411 ht412 ht413 ht414 ht415 ht416 ht417 hb211 hb213 ///
					hb215 hb001 hb002_age hb002_year hb002_yearsago hb003 hb003_a hb004 /// 
					hb005_age hb005_year hb005_yearsago hb006 hb011_age hb011_year hb011_yearsago hb101 hb103 hb105 hb106 ///
					hb107 hb108 hb109 hb110 we001 we004 we005 ht211s1 ht211s7 dm003 
merge 1:1 prim_key using "$wave_1_ind_bm", keepusing(`health_w1_ind') nogen


*********************************************************************
***Self-Report of Health***
*********************************************************************

***self-reported health
gen r`wv'shlt=.
missing_lasi ht001_a, result(r`wv'shlt) wave(`wv')
replace r`wv'shlt=1 if ht001_a==1 
replace r`wv'shlt=2 if ht001_a==2 
replace r`wv'shlt=3 if ht001_a==3
replace r`wv'shlt=4 if ht001_a==4
replace r`wv'shlt=5 if ht001_a==5 
label variable r`wv'shlt "r`wv'shlt:w`wv' r self-report of health"
label values r`wv'shlt health
*spouse  
gen s`wv'shlt=.
spouse r`wv'shlt, result(s`wv'shlt) wave(`wv')
label variable s`wv'shlt "s`wv'shlt:w`wv' s self-report of health"
label values s`wv'shlt health

***self-reported health, alternative scale 
gen r`wv'shlta=.
missing_lasi ht001_b, result(r`wv'shlta) wave(`wv')
replace r`wv'shlta=1 if ht001_b==1 
replace r`wv'shlta=2 if ht001_b==2 
replace r`wv'shlta=3 if ht001_b==3 
replace r`wv'shlta=4 if ht001_b==4 
replace r`wv'shlta=5 if ht001_b==5 
label variable r`wv'shlta "r`wv'shlta:w`wv' r self-report of health alt"
label values r`wv'shlta health_alt
*spouse 
gen s`wv'shlta=.
spouse r`wv'shlta, result(s`wv'shlta) wave(`wv')
label variable s`wv'shlta "s`wv'shlta:w`wv' s self-report of health alt"
label values s`wv'shlta health_alt


*********************************************************************
***Whether Health Limits Work***
*********************************************************************

***whether health limits work
gen r`wv'hlthlm=.
missing_lasi ht300 we004 we005, result(r`wv'hlthlm) wave(`wv')
replace r`wv'hlthlm=.m if we004==.e | we005==.e
replace r`wv'hlthlm=.w if we001==2 | we004==2 | inrange(we005,2,5) 
replace r`wv'hlthlm=.o if ht300==3
replace r`wv'hlthlm=0 if ht300==2
replace r`wv'hlthlm=1 if ht300==1
label variable r`wv'hlthlm "r`wv'hlthlm:w`wv' r health problems limit work"
label values r`wv'hlthlm hlthlm
*spouse  
gen s`wv'hlthlm=.
spouse r`wv'hlthlm , result(s`wv'hlthlm) wave(`wv')
label variable s`wv'hlthlm "s`wv'hlthlm:w`wv' s health problems limit work"
label values s`wv'hlthlm hlthlm


*********************************************************************
***Activities of Daily Living (ADLs)***
*********************************************************************

***some diff-Walk across room
gen r`wv'walkra=.
missing_lasi ht402, result(r`wv'walkra) wave(`wv')
replace r`wv'walkra=0 if ht402==2
replace r`wv'walkra=1 if ht402==1
label variable r`wv'walkra "r`wv'walkra:w`wv' r some diff-Walking across room"
label values r`wv'walkra diff
*spouse 
gen s`wv'walkra=.
spouse r`wv'walkra, result(s`wv'walkra) wave(`wv')
label variable s`wv'walkra "s`wv'walkra:w`wv' s some diff-Walking across room" 
label values s`wv'walkra diff

***some difficulty dressing
gen r`wv'dressa=.
missing_lasi ht401, result(r`wv'dressa) wave(`wv')
replace r`wv'dressa=0 if ht401==2 
replace r`wv'dressa=1 if ht401==1 
label variable r`wv'dressa "r`wv'dressa:w`wv' r some diff-Dressing"
label values r`wv'dressa diff
*spouse
gen s`wv'dressa=.
spouse r`wv'dressa, result(s`wv'dressa) wave(`wv')
label variable s`wv'dressa "s`wv'dressa:w`wv' s some diff-Dressing" 
label values s`wv'dressa diff

***some difficulty bathing, shower
gen r`wv'batha=.
missing_lasi ht403, result(r`wv'batha) wave(`wv')
replace r`wv'batha=0 if ht403==2 
replace r`wv'batha=1 if ht403==1 
label variable r`wv'batha "r`wv'batha:w`wv' r some diff-Bathing, shower"
label values r`wv'batha diff
*spouse
gen s`wv'batha=.
spouse r`wv'batha, result(s`wv'batha) wave(`wv')
label variable s`wv'batha "s`wv'batha:w`wv' s some diff-Bathing, shower" 
label values s`wv'batha diff

***some difficulty eating
gen r`wv'eata=.
missing_lasi ht404, result(r`wv'eata) wave(`wv')
replace r`wv'eata=0 if ht404==2 
replace r`wv'eata=1 if ht404==1 
label variable r`wv'eata "r`wv'eata:w`wv' r some diff-Eating"
label values r`wv'eata diff
*spouse 
gen s`wv'eata=.
spouse r`wv'eata, result(s`wv'eata) wave(`wv')
label variable s`wv'eata "s`wv'eata:w`wv' s some diff-Eating" 
label values s`wv'eata diff

***some difficulty getting in/out of bed
gen r`wv'beda=.
missing_lasi ht405, result(r`wv'beda) wave(`wv')
replace r`wv'beda=0 if ht405==2 
replace r`wv'beda=1 if ht405==1 
label variable r`wv'beda "r`wv'beda:w`wv' r some diff-Getting in/out bed"
label values r`wv'beda diff
*spouse 
gen s`wv'beda=.
spouse r`wv'beda, result(s`wv'beda) wave(`wv')
label variable s`wv'beda "s`wv'beda:w`wv' s some diff-Getting in/out bed" 
label values s`wv'beda diff

***some difficulty using the toilet
gen r`wv'toilta=.
missing_lasi ht406, result(r`wv'toilta) wave(`wv')
replace r`wv'toilta=0 if ht406==2 
replace r`wv'toilta=1 if ht406==1 
label variable r`wv'toilta "r`wv'toilta:w`wv' r some diff-Using the toilet"
label values r`wv'toilta diff
*spouse 
gen s`wv'toilta=.
spouse r`wv'toilta, result(s`wv'toilta) wave(`wv')
label variable s`wv'toilta "s`wv'toilta:w`wv' s some diff-Using the toilet"
label values s`wv'toilta diff


*********************************************************************
***Instrumental Activities of Daily Living (IADLs)***
*********************************************************************

***some difficulty using a telephone
gen r`wv'phonea=.
missing_lasi ht409, result(r`wv'phonea) wave(`wv')
replace r`wv'phonea=0 if ht409==2 
replace r`wv'phonea=1 if ht409==1 
label variable r`wv'phonea "r`wv'phonea:w`wv' r some diff-Using telephone"
label values r`wv'phonea diff
*spouse
gen s`wv'phonea=.
spouse r`wv'phonea, result(s`wv'phonea) wave(`wv')
label variable s`wv'phonea "s`wv'phonea:w`wv' s some diff-Using telephone" 
label values s`wv'phonea diff

***some difficulty taking medications
gen r`wv'medsa=.
missing_lasi ht410, result(r`wv'medsa) wave(`wv')
replace r`wv'medsa=0 if ht410==2 
replace r`wv'medsa=1 if ht410==1 
label variable r`wv'medsa "r`wv'medsa:w`wv' r some diff-Taking medications"
label values r`wv'medsa diff
*spouse
gen s`wv'medsa=.
spouse r`wv'medsa, result(s`wv'medsa) wave(`wv')
label variable s`wv'medsa "s`wv'medsa:w`wv' s some diff-Taking medications" 
label values s`wv'medsa diff

***some difficulty managing money
gen r`wv'moneya=.
missing_lasi ht412, result(r`wv'moneya) wave(`wv')
replace r`wv'moneya=0 if ht412==2 
replace r`wv'moneya=1 if ht412==1 
label variable r`wv'moneya "r`wv'moneya:w`wv' r some diff-Managing money"
label values r`wv'moneya diff
*spouse 
gen s`wv'moneya=.
spouse r`wv'moneya, result(s`wv'moneya) wave(`wv')
label variable s`wv'moneya "s`wv'moneya:w`wv' s some diff-Managing money" 
label values s`wv'moneya diff

***some difficulty shopping for groceries
gen r`wv'shopa=.
missing_lasi ht408, result(r`wv'shopa) wave(`wv')
replace r`wv'shopa=0 if ht408==2 
replace r`wv'shopa=1 if ht408==1 
label variable r`wv'shopa "r`wv'shopa:w`wv' r some diff-Shopping for groceries"
label values r`wv'shopa diff
*spouse 
gen s`wv'shopa=.
spouse r`wv'shopa, result(s`wv'shopa) wave(`wv')
label variable s`wv'shopa "s`wv'shopa:w`wv' s some diff-Shopping for groceries" 
label values s`wv'shopa diff

***some difficulty preparing a hot meal
gen r`wv'mealsa=.
missing_lasi ht407, result(r`wv'mealsa) wave(`wv')
replace r`wv'mealsa=0 if ht407==2
replace r`wv'mealsa=1 if ht407==1 
label variable r`wv'mealsa "r`wv'mealsa:w`wv' r some diff-Preparing hot meal"
label values r`wv'mealsa diff
*spouse 
gen s`wv'mealsa=.
spouse r`wv'mealsa, result(s`wv'mealsa) wave(`wv')
label variable s`wv'mealsa "s`wv'mealsa:w`wv' s some diff-Preparing hot meal" 
label values s`wv'mealsa diff

***some difficulty getting around
gen r`wv'geta=.
missing_lasi ht413, result(r`wv'geta) wave(`wv')
replace r`wv'geta=0 if ht413==2 
replace r`wv'geta=1 if ht413==1 
label variable r`wv'geta "r`wv'geta:w`wv' r some diff-Getting around"
label values r`wv'geta diff
*spouse 
gen s`wv'geta=.
spouse r`wv'geta, result(s`wv'geta) wave(`wv')
label variable s`wv'geta "s`wv'geta:w`wv' s some diff-Getting around" 
label values s`wv'geta diff

***some difficulty doing work around the house or garden
gen r`wv'housewka=.
missing_lasi ht411, result(r`wv'housewka) wave(`wv')
replace r`wv'housewka=0 if ht411==2 
replace r`wv'housewka=1 if ht411==1 
label variable r`wv'housewka "r`wv'housewka:w`wv' r some diff-Doing work around house or garden"
label values r`wv'housewka diff
*spouse 
gen s`wv'housewka=.
spouse r`wv'housewka, result(s`wv'housewka) wave(`wv')
label variable s`wv'housewka "s`wv'housewka:w`wv' s some diff-Doing work around house or garden" 
label values s`wv'housewka diff


*********************************************************************
***Other Functional Limitations***
*********************************************************************

***walking for 100 yard
gen r`wv'walk100a=.
missing_lasi ht303, result(r`wv'walk100a) wave(`wv')
replace r`wv'walk100a=0 if ht303==2
replace r`wv'walk100a=1 if ht303==1
label variable r`wv'walk100a "r`wv'walk100a:w`wv' r some diff-Walk 100y"
label values r`wv'walk100a diff
*spouse 
gen s`wv'walk100a=.
spouse r`wv'walk100a, result(s`wv'walk100a) wave(`wv')
label variable s`wv'walk100a "s`wv'walk100a:w`wv' s some diff-Walk 100y"
label values s`wv'walk100a diff

***difficulty sitting for 2 hours
gen r`wv'sita=.
missing_lasi ht304, result(r`wv'sita) wave(`wv')
replace r`wv'sita=0 if ht304==2
replace r`wv'sita=1 if ht304==1
label variable r`wv'sita "r`wv'sita:w`wv' r some diff-Sit for 2 hours"
label values r`wv'sita diff
*spouse
gen s`wv'sita=.
spouse r`wv'sita, result(s`wv'sita) wave(`wv')
label variable s`wv'sita "s`wv'sita:w`wv' s some diff-Sit for 2 hours"
label values s`wv'sita diff

***difficulty getting up from a chair
gen r`wv'chaira=.
missing_lasi ht305, result(r`wv'chaira) wave(`wv')
replace r`wv'chaira=0 if ht305==2
replace r`wv'chaira=1 if ht305==1
label variable r`wv'chaira "r`wv'chaira:w`wv' r some diff-Get up fr chair"
label values r`wv'chaira diff
*spouse 
gen s`wv'chaira=.
spouse r`wv'chaira, result(s`wv'chaira) wave(`wv')
label variable s`wv'chaira "s`wv'chaira:w`wv' s some diff-Get up fr chair"
label values s`wv'chaira diff

***difficulty climbing one flight of stairs
gen r`wv'clim1a=.
missing_lasi ht306, result(r`wv'clim1a) wave(`wv')
replace r`wv'clim1a=0 if ht306==2
replace r`wv'clim1a=1 if ht306==1
label variable r`wv'clim1a "r`wv'clim1a:w`wv' r some diff-Clmb 1 flt str"
label values r`wv'clim1a diff
*spouse
gen s`wv'clim1a=.
spouse r`wv'clim1a, result(s`wv'clim1a) wave(`wv')
label variable s`wv'clim1a "s`wv'clim1a:w`wv' s some diff-Clmb 1 flt str"
label values s`wv'clim1a diff

***difficulty stooping/keeling/crouching
gen r`wv'stoopa=.
missing_lasi ht307, result(r`wv'stoopa) wave(`wv')
replace r`wv'stoopa=0 if ht307==2
replace r`wv'stoopa=1 if ht307==1
label variable r`wv'stoopa "r`wv'stoopa:w`wv' r some diff-Stoop/kneel/crch"
label values r`wv'stoopa diff
*spouse
gen s`wv'stoopa=.
spouse r`wv'stoopa, result(s`wv'stoopa) wave(`wv')
label variable s`wv'stoopa "s`wv'stoopa:w`wv' s some diff-Stoop/kneel/crch"
label values s`wv'stoopa diff

***difficulty in lifting/carry 10 jin
gen r`wv'lifta=.
missing_lasi ht310, result(r`wv'lifta) wave(`wv')
replace r`wv'lifta=0 if ht310==2
replace r`wv'lifta=1 if ht310==1
label variable r`wv'lifta "r`wv'lifta:w`wv' r diff-Lift/carry 5 kilos"
label values r`wv'lifta diff
*spouse difficulty lifting 10 jin
gen s`wv'lifta=.
spouse r`wv'lifta, result(s`wv'lifta) wave(`wv')
label variable s`wv'lifta "s`wv'lifta:w`wv' s diff-Lift/carry 5 kilos"
label values s`wv'lifta diff

***difficulty in picking up a coin
gen r`wv'dimea=.
missing_lasi ht311, result(r`wv'dimea) wave(`wv')
replace r`wv'dimea=0 if ht311==2
replace r`wv'dimea=1 if ht311==1
label variable r`wv'dimea "r`wv'dimea:w`wv' r diff-Pick up a coin"
label values r`wv'dimea diff
*spouse 
gen s`wv'dimea=.
spouse r`wv'dimea, result(s`wv'dimea) wave(`wv')
label variable s`wv'dimea "s`wv'dimea:w`wv' s diff-Pick up a coin"
label values s`wv'dimea diff

***difficulty reaching/extending arms up
gen r`wv'armsa=.
missing_lasi ht308, result(r`wv'armsa) wave(`wv')
replace r`wv'armsa=0 if ht308==2
replace r`wv'armsa=1 if ht308==1
label variable r`wv'armsa "r`wv'armsa:w`wv' r some diff-Rch/xtnd arms up"
label values r`wv'armsa diff
*spouse 
gen s`wv'armsa=.
spouse r`wv'armsa, result(s`wv'armsa) wave(`wv')
label variable s`wv'armsa "s`wv'armsa:w`wv' s some diff-Rch/xtnd arms up"
label values s`wv'armsa diff

***difficulty pushing/pulling a large object
gen r`wv'pusha=.
missing_lasi ht309, result(r`wv'pusha) wave(`wv')
replace r`wv'pusha=0 if ht309==2
replace r`wv'pusha=1 if ht309==1
label variable r`wv'pusha "r`wv'pusha:w`wv' r some diff-Push/pull lg obj"
label values r`wv'pusha diff
*spouse 
gen s`wv'pusha=.
spouse r`wv'pusha, result(s`wv'pusha) wave(`wv')
label variable s`wv'pusha "s`wv'pusha:w`wv' s some diff-Push/pull lg obj"
label values s`wv'pusha diff


*********************************************************************
***ADL Summary***
*********************************************************************

***5 item ADL number of missings
egen r`wv'adlam=rowmiss(r`wv'walkra r`wv'batha r`wv'dressa r`wv'eata r`wv'beda) if inw`wv'==1
label variable r`wv'adlam "r`wv'adlam:w`wv' r missings in Some Diff-ADLs:Wallace summary /0-5"
*spouse
gen s`wv'adlam=.
spouse r`wv'adlam, result(s`wv'adlam) wave(`wv')
label variable s`wv'adlam "s`wv'adlam:w`wv' s missings in Some Diff-ADLs:Wallace summary /0-5" 

***ADL Wallace summary 0-5
egen r`wv'adla=rowtotal(r`wv'batha r`wv'dressa r`wv'eata r`wv'beda r`wv'walkra) if inrange(r`wv'adlam,0,4),m
replace r`wv'adla=.m if r`wv'adlam == 5 
label variable r`wv'adla "r`wv'adla:w1 r Some Diff-ADLs:Wallace /0-5"
*spouse 
gen s`wv'adla=.
spouse r`wv'adla, result(s`wv'adla) wave(`wv')
label variable s`wv'adla "s`wv'adla:w`wv' s Some Diff-ADLs:Wallace /0-5" 

***Any Diff-ADL Wallace Summary 0-5
gen r`wv'adlaa=.
replace r`wv'adlaa=.m if r`wv'adla==.m
replace r`wv'adlaa=.d if r`wv'adla==.d
replace r`wv'adlaa=.r if r`wv'adla==.r
replace r`wv'adlaa=0 if r`wv'adla==0
replace r`wv'adlaa=1 if inrange(r`wv'adla,1,5)
label variable r`wv'adlaa "r`wv'adlaa:w`wv' whether r has Any Diff-ADLs:Wallace: 5-item"
label values r`wv'adlaa diff
*Spouse
gen s`wv'adlaa=.
spouse r`wv'adlaa, result(s`wv'adlaa) wave(`wv')
label variable s`wv'adlaa "s`wv'adlaa:w`wv' whether s has Any Diff-ADLs:Wallace: 5-item"
label values s`wv'adlaa diff

***3 item ADL number of missings
egen r`wv'adlwam=rowmiss(r`wv'batha r`wv'dressa r`wv'eata) if inw`wv'==1
label variable r`wv'adlwam "r`wv'adlwam:w`wv' r missings in Some Diff-ADLs:Wallace /0-3"
*spouse 
gen s`wv'adlwam=.
spouse r`wv'adlwam, result(s`wv'adlwam) wave(`wv')
label variable s`wv'adlwam "s`wv'adlwam:w`wv' s missings in Some Diff-ADLs:Wallace /0-3" 

***ADL summary 0-3
egen r`wv'adlwa=rowtotal(r`wv'batha r`wv'dressa r`wv'eata) if inrange(r`wv'adlwam,0,2),m
replace r`wv'adlwa=.m if r`wv'adlwam == 3
label variable r`wv'adlwa "r`wv'adlwa:w1 r Some Diff-ADLs:Wallace /0-3"
*spouse 
gen s`wv'adlwa=.
spouse r`wv'adlwa, result(s`wv'adlwa) wave(`wv')
label variable s`wv'adlwa "s`wv'adlwa:w`wv' s Some Diff-ADLs:Wallace /0-3" 

***Any Diff in ADL Wallace Summary 0-3
gen r`wv'adlwaa = .
replace r`wv'adlwaa=.m if r`wv'adlwa==.m
replace r`wv'adlwaa=.d if r`wv'adlwa==.d
replace r`wv'adlwaa=.r if r`wv'adlwa==.r
replace r`wv'adlwaa=0 if r`wv'adlwa==0
replace r`wv'adlwaa=1 if inrange(r`wv'adlwa,1,3)
label variable r`wv'adlwaa "r`wv'adlwaa:w`wv' whether r has Any Diff-ADLs:Wallace: 3-item"
label values r`wv'adlwaa diff
*spouse
gen s`wv'adlwaa=.
spouse r`wv'adlwaa, result(s`wv'adlwaa) wave(`wv')
label variable s`wv'adlwaa "s`wv'adlwaa:w`wv' whether s has Any Diff-ADLs:Wallace: 3-item"
label values s`wv'adlwaa diff

***5-Item ADL number of missings
egen r`wv'adlfivem=rowmiss(r`wv'batha r`wv'dressa r`wv'eata r`wv'beda r`wv'toilta) if inw`wv'==1
label variable r`wv'adlfivem "r`wv'adlfivem:w`wv' r missings in Some Diff-ADLs:5-item alt/0-5"
*Spouse
gen s`wv'adlfivem=.
spouse r`wv'adlfivem, result(s`wv'adlfivem) wave(`wv')
label variable s`wv'adlfivem "s`wv'adlfivem:w`wv' s missings in Some Diff-ADLs:5-item alt/0-5"

***5-Item ADL Summary 0-5
egen r`wv'adlfive=rowtotal(r`wv'batha r`wv'dressa r`wv'eata r`wv'beda r`wv'toilta) if inrange(r`wv'adlfivem,0,4),m
replace r`wv'adlfive=.m if r`wv'adlfivem==5
label variable r`wv'adlfive "r`wv'adlfive:w`wv' r Some Diff-ADLs:5-item alt/0-5"
*spouse
gen s`wv'adlfive=.
spouse r`wv'adlfive, result(s`wv'adlfive) wave(`wv')
label variable s`wv'adlfive "s`wv'adlfive:w`wv' s Some Diff-ADLs:5-item alt/0-5"

***Any Diff-5-item ADL Summary 0-5
gen r`wv'adlfivea=.
replace r`wv'adlfivea=.m if r`wv'adlfive==.m
replace r`wv'adlfivea=.d if r`wv'adlfive==.d
replace r`wv'adlfivea=.r if r`wv'adlfive==.r
replace r`wv'adlfivea=0 if r`wv'adlfive==0
replace r`wv'adlfivea=1 if inrange(r`wv'adlfive,1,5)
label variable r`wv'adlfivea "r`wv'adlfivea:w`wv' whether r has Any Diff-ADLs:5-item alt"
label values r`wv'adlfivea diff
*spouse
gen s`wv'adlfivea=.
spouse r`wv'adlfivea, result(s`wv'adlfivea) wave(`wv')
label variable s`wv'adlfivea "s`wv'adlfivea:w`wv' whether s has Any Diff-ADLs:5-item alt"
label values s`wv'adlfivea diff

***6-Item ADL Summary 0-6 number of missings
egen r`wv'adltot6m=rowmiss(r`wv'batha r`wv'dressa r`wv'eata r`wv'beda r`wv'toilta r`wv'walkra) if inw`wv'==1
label variable r`wv'adltot6m "r`wv'adltot6m:w`wv' r missings in Some Diff-ADLs:Total /0-6"
*Spouse
gen s`wv'adltot6m=.
spouse r`wv'adltot6m, result(s`wv'adltot6m) wave(`wv')
label variable s`wv'adltot6m "s`wv'adltot6m:w`wv' s missings in Some Diff-ADLs:Total /0-6"

***6-Item ADL Summary 0-6
egen r`wv'adltot6=rowtotal(r`wv'batha r`wv'dressa r`wv'eata r`wv'beda r`wv'toilta r`wv'walkra) if inrange(r`wv'adltot6m,0,5),m
replace r`wv'adltot6=.m if r`wv'adltot6m==6
label variable r`wv'adltot6 "r`wv'adltot6:w`wv' r Some Diff-ADLs:Total /0-6"
*spouse
gen s`wv'adltot6=.
spouse r`wv'adltot6, result(s`wv'adltot6) wave(`wv')
label variable s`wv'adltot6 "s`wv'adltot6:w`wv' s Some Diff-ADLs:Total /0-6"

***Any Diff-6-item ADL Summary 0-6
gen r`wv'adltot6a=.
replace r`wv'adltot6a=.m if r`wv'adltot6==.m
replace r`wv'adltot6a=.d if r`wv'adltot6==.d
replace r`wv'adltot6a=.r if r`wv'adltot6==.r
replace r`wv'adltot6a=0 if r`wv'adltot6==0
replace r`wv'adltot6a=1 if inrange(r`wv'adltot6,1,6)
label variable r`wv'adltot6a "r`wv'adltot6a:w`wv' whether r has Any Diff-ADLs:Total"
label values r`wv'adltot6a diff
*Spouse
gen s`wv'adltot6a=.
spouse r`wv'adltot6a, result(s`wv'adltot6a) wave(`wv')
label variable s`wv'adltot6a "s`wv'adltot6a:w`wv' whether s has Any Diff-ADLs:Total"
label values s`wv'adltot6a diff


*********************************************************************
***IADL Summary***
*********************************************************************

***5 item IADL number of missings
egen r`wv'iadlzam=rowmiss(r`wv'phonea r`wv'moneya r`wv'medsa r`wv'shopa r`wv'mealsa) if inw`wv'==1
label variable r`wv'iadlzam "r`wv'iadlzam:w`wv' r Missings in Some Diff-IADLs: /0-5"  
*spouse
gen s`wv'iadlzam=.
spouse r`wv'iadlzam , result(s`wv'iadlzam) wave(`wv')
label variable s`wv'iadlzam  "s`wv'iadlzam:w`wv' s Missings in Some Diff-IADLs: /0-5" 

***IADLs summary 0-5
egen r`wv'iadlza=rowtotal(r`wv'phonea r`wv'moneya r`wv'medsa r`wv'shopa r`wv'mealsa) if inrange(r`wv'iadlzam,0,4),m
replace r`wv'iadlza=.m if r`wv'iadlzam == 5
label variable r`wv'iadlza "r`wv'iadlza:w`wv' r Some Diff-IADLs /0-5"
*spouse 
gen s`wv'iadlza=.
spouse r`wv'iadlza, result(s`wv'iadlza) wave(`wv')
label variable s`wv'iadlza "s`wv'iadlza:w`wv' s Some Diff-IADLs /0-5" 

***Any Diff-IADLs 0-5
gen r`wv'iadlzaa=.
replace r`wv'iadlzaa=.m if r`wv'iadlza==.m
replace r`wv'iadlzaa=0 if r`wv'iadlza==0
replace r`wv'iadlzaa=1 if inrange(r`wv'iadlza,1,5)
label variable r`wv'iadlzaa "r`wv'iadlzaa:w`wv' whether r has Any Diff-IADLs: 5-item"
label values r`wv'iadlzaa diff
*Spouse
gen s`wv'iadlzaa=.
spouse r`wv'iadlzaa, result(s`wv'iadlzaa) wave(`wv')
label variable s`wv'iadlzaa "s`wv'iadlzaa:w`wv' whether s has Any Diff-IADLs: 5-item"
label values s`wv'iadlzaa diff

***3 item IADL number of missings
egen r`wv'iadlam=rowmiss(r`wv'phonea r`wv'moneya r`wv'medsa) if inw`wv'==1 
label variable r`wv'iadlam "r`wv'iadlam:w`wv' r Missings in Some Diff-IADLs: /0-3"  
*spouse
gen s`wv'iadlam=.
spouse r`wv'iadlam, result(s`wv'iadlam) wave(`wv')
label variable s`wv'iadlam "s`wv'iadlam:w`wv' s Missings in Some Diff-IADLs: /0-3" 

***IADLs summary 0-3
egen r`wv'iadla=rowtotal(r`wv'phonea r`wv'moneya r`wv'medsa) if inrange(r`wv'iadlam,0,2),m
replace r`wv'iadla=.m if r`wv'iadlam == 3
label variable r`wv'iadla "r`wv'iadla:w`wv' r Some Diff-IADLs /0-3"
*spouse 
gen s`wv'iadla=.
spouse r`wv'iadla, result(s`wv'iadla) wave(`wv')
label variable s`wv'iadla "s`wv'iadla:w`wv' s Some Diff-IADLs /0-3" 

***Any Diff-IADL 0-3
gen r`wv'iadlaa=.
replace r`wv'iadlaa=.m if r`wv'iadla==.m
replace r`wv'iadlaa=0 if r`wv'iadla==0
replace r`wv'iadlaa=1 if inrange(r`wv'iadla,1,3)
label variable r`wv'iadlaa "r`wv'iadlaa:w`wv' whether r has Any Diff-IADLs: 3-item"
label values r`wv'iadlaa diff
*Spouse
gen s`wv'iadlaa=.
spouse r`wv'iadlaa, result(s`wv'iadlaa) wave(`wv')
label variable s`wv'iadlaa "s`wv'iadlaa:w`wv' whether s has Any Diff-IADLs: 3-item"
label values s`wv'iadlaa diff

***4-item IADL number of missings
egen r`wv'iadlfourm=rowmiss(r`wv'moneya r`wv'medsa r`wv'shopa r`wv'mealsa) if inw`wv'==1
label variable r`wv'iadlfourm "r`wv'iadlfourm:w`wv' r Missings in Some Diff-IADLs: /0-4"
*Spouse
gen s`wv'iadlfourm=.
spouse r`wv'iadlfourm, result(s`wv'iadlfourm) wave(`wv')
label variable s`wv'iadlfourm "s`wv'iadlfourm:w`wv' s Missings in Some Diff-IADLs: /0-4"

***IADLs Summary 0-4
egen r`wv'iadlfour=rowtotal(r`wv'moneya r`wv'medsa r`wv'shopa r`wv'mealsa) if inrange(r`wv'iadlfourm,0,3),m
replace r`wv'iadlfour=.m if r`wv'iadlfourm==4
label variable r`wv'iadlfour "r`wv'iadlfour:w`wv' r Some Diff-IADLs /0-4"
*Spouse
gen s`wv'iadlfour=.
spouse r`wv'iadlfour, result(s`wv'iadlfour) wave(`wv')
label variable s`wv'iadlfour "s`wv'iadlfour:w`wv' s Some Diff-IADLs /0-4"

***Any Diff-IADL 0-4
gen r`wv'iadlfoura=.
replace r`wv'iadlfoura=.m if r`wv'iadlfour==.m
replace r`wv'iadlfoura=0 if r`wv'iadlfour==0
replace r`wv'iadlfoura=1 if inrange(r`wv'iadlfour,1,4)
label variable r`wv'iadlfoura "r`wv'iadlfoura:w`wv' whether r has Any Diff-IADLs: 4-item"
label values r`wv'iadlfoura diff
*Spouse
gen s`wv'iadlfoura=.
spouse r`wv'iadlfoura, result(s`wv'iadlfoura) wave(`wv')
label variable s`wv'iadlfoura "s`wv'iadlfoura:w`wv' whether s has Any Diff-IADLs: 4-item"
label values s`wv'iadlfoura diff

***7-item IADL number of missing
egen r`wv'iadltotm_l=rowmiss(r`wv'moneya r`wv'medsa r`wv'shopa r`wv'mealsa r`wv'phonea r`wv'geta r`wv'housewka) if inw`wv'==1
label variable r`wv'iadltotm_l "r`wv'iadltotm_l:w`wv' r Missings in Some Diff-IADLs:Total /0-7"
*Spouse
gen s`wv'iadltotm_l=.
spouse r`wv'iadltotm_l, result(s`wv'iadltotm_l) wave(`wv')
label variable s`wv'iadltotm_l "s`wv'iadltotm_l:w`wv' s Missings in Some Diff-IADLs:Total /0-7"

***IADL Summary 0-7
egen r`wv'iadltot_l=rowtotal(r`wv'moneya r`wv'medsa r`wv'shopa r`wv'mealsa r`wv'phonea r`wv'geta r`wv'housewka) if inrange(r`wv'iadltotm_l,0,6),m
replace r`wv'iadltot_l=.m if r`wv'iadltotm_l==7
label variable r`wv'iadltot_l "r`wv'iadltot_l:w`wv' r Some Diff-IADLs:Total /0-7"
*Spouse
gen s`wv'iadltot_l=.
spouse r`wv'iadltot_l, result(s`wv'iadltot_l) wave(`wv')
label variable s`wv'iadltot_l "s`wv'iadltot_l:w`wv' s Some Diff-IADLs:Total /0-7"

***Any Diff-IADL 0-7
gen r`wv'iadltota_l=.
replace r`wv'iadltota_l=.m if r`wv'iadltot_l==.m
replace r`wv'iadltota_l=0 if r`wv'iadltot_l==0
replace r`wv'iadltota_l=1 if inrange(r`wv'iadltot_l,1,7)
label variable r`wv'iadltota_l "r`wv'iadltota_l:w`wv' whether r has Any Diff-IADLs:Total"
label values r`wv'iadltota_l diff
*Spouse
gen s`wv'iadltota_l=.
spouse r`wv'iadltota_l, result(s`wv'iadltota_l) wave(`wv')
label variable s`wv'iadltota_l "s`wv'iadltota_l:w`wv' whether s has Any Diff-IADLs:Total"
label values s`wv'iadltota_l diff


*********************************************************************
***Other Summary Indices***
*********************************************************************

***mobility summary missings 0-3
egen r`wv'mobilcm=rowmiss(r`wv'walk100a r`wv'walkra r`wv'clim1a) if inw`wv'==1
label variable r`wv'mobilcm "r`wv'mobilcm:w`wv' r Missings in Some Diff-Mobility /0-3"
*spouse
gen s`wv'mobilcm=.
spouse r`wv'mobilcm, result(s`wv'mobilcm) wave(`wv')
label variable s`wv'mobilcm "s`wv'mobilcm:w`wv' s Missings in Some Diff-Mobility /0-3"

***mobility summary 0-3
egen r`wv'mobilc=rowtotal(r`wv'walk100a r`wv'walkra r`wv'clim1a) if inrange(r`wv'mobilcm,0,2),m
replace r`wv'mobilc=.m if r`wv'mobilcm == 3
label variable r`wv'mobilc "r`wv'mobilc:w`wv' r Some Diff-Mobility /0-3"
*spouse 
gen s`wv'mobilc=.
spouse r`wv'mobilc, result(s`wv'mobilc) wave(`wv')
label variable s`wv'mobilc "s`wv'mobilc:w`wv' s Some Diff-Mobility /0-3"

***Any Difficulty-Mobility 0-3
gen r`wv'mobilca=.
replace r`wv'mobilca=.m if r`wv'mobilc==.m
replace r`wv'mobilca=0 if r`wv'mobilc==0
replace r`wv'mobilca=1 if inrange(r`wv'mobilc,1,3)
label variable r`wv'mobilca "r`wv'mobilca:w`wv' whether r has Any Diff-Mobility: 3-item"
label values r`wv'mobilca diff
*Spouse
gen s`wv'mobilca=.
spouse r`wv'mobilca, result(s`wv'mobilca) wave(`wv')
label variable s`wv'mobilca "s`wv'mobilca:w`wv' whether s has Any Diff-Mobility: 3-item"
label values s`wv'mobilca diff

***mobility summary 0-7 missings
egen r`wv'mobilsevm_l=rowmiss(r`wv'walk100a r`wv'clim1a r`wv'chaira r`wv'stoopa r`wv'armsa r`wv'lifta r`wv'dimea) if inw`wv'==1
label variable r`wv'mobilsevm_l "r`wv'mobilsevm_l:w`wv' r Missings in Some Diff-Mobility /0-7"
*Spouse
gen s`wv'mobilsevm_l=.
spouse r`wv'mobilsevm_l, result(s`wv'mobilsevm_l) wave(`wv')
label variable s`wv'mobilsevm_l "s`wv'mobilsevm_l:w`wv' s Missings in Some Diff-Mobility /0-7"

***mobility summary 0-7
egen r`wv'mobilsev_l=rowtotal(r`wv'walk100a r`wv'clim1a r`wv'chaira r`wv'stoopa r`wv'armsa r`wv'lifta r`wv'dimea) if inrange(r`wv'mobilsevm_l,0,6),m
replace r`wv'mobilsev_l=.m if r`wv'mobilsevm_l==7
label variable r`wv'mobilsev_l "r`wv'mobilsev_l:w`wv' r Some Diff-Mobility /0-7"
*spouse
gen s`wv'mobilsev_l=.
spouse r`wv'mobilsev_l, result(s`wv'mobilsev_l) wave(`wv')
label variable s`wv'mobilsev_l "s`wv'mobilsev_l:w`wv' s Some Diff-Mobility /0-7"

***Any Diff-Mobility 0-7
gen r`wv'mobilseva_l=.
replace r`wv'mobilseva_l=.m if r`wv'mobilsev_l==.m
replace r`wv'mobilseva_l=0 if r`wv'mobilsev_l==0
replace r`wv'mobilseva_l=1 if inrange(r`wv'mobilsev_l,1,7)
label variable r`wv'mobilseva_l "r`wv'mobilseva_l:w`wv' whether r has Any Diff-Mobility: 7-item"
label values r`wv'mobilseva_l diff
*spouse
gen s`wv'mobilseva_l=.
spouse r`wv'mobilseva_l, result(s`wv'mobilseva_l) wave(`wv')
label variable s`wv'mobilseva_l "s`wv'mobilseva_l:w`wv' whether s has Any Diff-Mobility: 7-item"
label values s`wv'mobilseva_l diff

***large muscle summary missings
egen r`wv'lgmusam=rowmiss(r`wv'sita r`wv'chaira r`wv'stoopa r`wv'pusha) if inw`wv'==1
label variable r`wv'lgmusam "r`wv'lgmusam:w`wv' r Missings in Some Diff-Large muscle /0-4"
*spouse 
gen s`wv'lgmusam=.
spouse r`wv'lgmusam, result(s`wv'lgmusam) wave(`wv')
label variable s`wv'lgmusam "s`wv'lgmusam:w`wv' s Missings in Some Diff-Large muscle /0-4"

***large muscle summary
egen r`wv'lgmusa=rowtotal(r`wv'sita r`wv'chaira r`wv'stoopa r`wv'pusha) if inrange(r`wv'lgmusam,0,3),m
replace r`wv'lgmusa=.m if r`wv'lgmusam == 4 & (r`wv'sita==.m | r`wv'chaira==.m | r`wv'stoopa==.m | r`wv'pusha==.m)
replace r`wv'lgmusa=.d if r`wv'lgmusam == 4 & (r`wv'sita==.d | r`wv'chaira==.d | r`wv'stoopa==.d | r`wv'pusha==.d)
label variable r`wv'lgmusa "r`wv'lgmusa:w`wv' r Some Diff-Large muscle /0-4"
*spouse
gen s`wv'lgmusa=.
spouse r`wv'lgmusa, result(s`wv'lgmusa) wave(`wv')
label variable s`wv'lgmusa "s`wv'lgmusa:w`wv' s Some Diff-Large muscle /0-4"

***Any Diff - large muscle summary 0-4
gen r`wv'lgmusaa=.
replace r`wv'lgmusaa=.m if r`wv'lgmusa==.m
replace r`wv'lgmusaa=.d if r`wv'lgmusa==.d
replace r`wv'lgmusaa=0 if r`wv'lgmusa==0
replace r`wv'lgmusaa=1 if inrange(r`wv'lgmusa,1,4)
label variable r`wv'lgmusaa "r`wv'lgmusaa:w`wv' whether r has Any Diff-Large muscle: 4-item"
label values r`wv'lgmusaa diff
*spouse
gen s`wv'lgmusaa=.
spouse r`wv'lgmusaa, result(s`wv'lgmusaa) wave(`wv')
label variable s`wv'lgmusaa "s`wv'lgmusaa:w`wv' whether s has Any Diff-Large muscle: 4-item"
label values s`wv'lgmusaa diff

***Gross muscle summary missings
egen r`wv'grossam=rowmiss(r`wv'walk100a r`wv'walkra r`wv'clim1a r`wv'beda r`wv'batha) if inw`wv'==1
label variable r`wv'grossam "r`wv'grossam:w`wv' r Missings in Some Diff-Wk,rn,clmb,bd,bth /0-5"
*spouse
gen s`wv'grossam=.
spouse r`wv'grossam, result(s`wv'grossam) wave(`wv')
label variable s`wv'grossam "s`wv'grossam:w`wv' s Missings in Some Diff-Wk,rn,clmb,bd,bth /0-5"

***gross muscle summary
egen r`wv'grossa=rowtotal(r`wv'walk100a r`wv'walkra r`wv'clim1a r`wv'beda r`wv'batha) if inrange(r`wv'grossam,0,4),m
replace r`wv'grossa=.m if r`wv'grossam == 5
label variable r`wv'grossa "r`wv'grossa:w`wv' r Some Diff-Wk,rn,clmb,bd,bth /0-5"
*spouse 
gen s`wv'grossa=.
spouse r`wv'grossa, result(s`wv'grossa) wave(`wv')
label variable s`wv'grossa "s`wv'grossa:w`wv' s Some Diff-Wk,rn,clmb,bd,bth /0-5"

***Any diff - gross muscle summary 0-5
gen r`wv'grossaa=.
replace r`wv'grossaa=.m if r`wv'grossa==.m
replace r`wv'grossaa=0 if r`wv'grossa==0
replace r`wv'grossaa=1 if inrange(r`wv'grossa,1,5)
label variable r`wv'grossaa "r`wv'grossaa:w`wv' whether r has Any Diff-Wk,rn,clmb,bd,bth"
label values r`wv'grossaa diff
*spouse
gen s`wv'grossaa=.
spouse r`wv'grossaa, result(s`wv'grossaa) wave(`wv')
label variable s`wv'grossaa "s`wv'grossaa:w`wv' whether s has Any Diff-Wk,rn,clmb,bd,bth"
label values s`wv'grossaa diff

***Fine muscle summary missings
egen r`wv'fineam=rowmiss(r`wv'dimea r`wv'eata r`wv'dressa) if inw`wv'==1
label variable r`wv'fineam "r`wv'fineam:w`wv' r Missings in Some Diff-Dime,eat,dress /0-3"
*spouse 
gen s`wv'fineam=.
spouse r`wv'fineam, result(s`wv'fineam) wave(`wv')
label variable s`wv'fineam "s`wv'fineam:w`wv' s Missings in Some Diff-Dime,eat,dress /0-3"

***fine muscle summary
egen r`wv'finea=rowtotal(r`wv'dimea r`wv'eata r`wv'dressa) if inrange(r`wv'fineam,0,2),m
replace r`wv'finea=.m if r`wv'fineam == 3
label variable r`wv'finea "r`wv'finea:w`wv' r Some Diff-Dime,eat,dress /0-3"
*spouse 
gen s`wv'finea=.
spouse r`wv'finea, result(s`wv'finea) wave(`wv')
label variable s`wv'finea "s`wv'finea:w`wv' s Some Diff-Dime,eat,dress /0-3"

***Any diff - Fine muscle summary 0-3
gen r`wv'fineaa=.
replace r`wv'fineaa=.m if r`wv'finea==.m
replace r`wv'fineaa=0 if r`wv'finea==0
replace r`wv'fineaa=1 if inrange(r`wv'finea,1,3)
label variable r`wv'fineaa "r`wv'fineaa:w`wv' whether r has Any Diff-Dime,eat,dress"
label values r`wv'fineaa diff
*spouse
gen s`wv'fineaa=.
spouse r`wv'fineaa, result(s`wv'fineaa) wave(`wv')
label variable s`wv'fineaa "s`wv'fineaa:w`wv' whether s has Any Diff-Dime,eat,dress"
label values s`wv'fineaa diff

***Lower mobility summary missings
egen r`wv'lowermobm_l=rowmiss(r`wv'walk100a r`wv'clim1a r`wv'chaira r`wv'stoopa) if inw`wv'==1
label variable r`wv'lowermobm_l "r`wv'lowermobm_l:w`wv' r Missings in Some Diff-Lower Mobility /0-4"
*spouse
gen s`wv'lowermobm_l=.
spouse r`wv'lowermobm_l, result(s`wv'lowermobm_l) wave(`wv')
label variable s`wv'lowermobm_l "s`wv'lowermobm_l:w`wv' s Missings in Some Diff-Lower Mobility /0-4"

***lower mobility summary 0-4
egen r`wv'lowermob_l=rowtotal(r`wv'walk100a r`wv'clim1a r`wv'chaira r`wv'stoopa) if inrange(r`wv'lowermobm_l,0,3),m
replace r`wv'lowermob_l=.m if r`wv'lowermobm_l==4
label variable r`wv'lowermob_l "r`wv'lowermob_l:w`wv' r Some Diff-Lower Mobility /0-4"
*spouse
gen s`wv'lowermob_l=.
spouse r`wv'lowermob_l, result(s`wv'lowermob_l) wave(`wv')
label variable s`wv'lowermob_l "s`wv'lowermob_l:w`wv' s Some Diff-Lower Mobility /0-4"

***Any  diff - Lower mobility summary 0-4
gen r`wv'lowermoba_l=.
replace r`wv'lowermoba_l=.m if r`wv'lowermob_l==.m
replace r`wv'lowermoba_l=0 if r`wv'lowermob_l==0
replace r`wv'lowermoba_l=1 if inrange(r`wv'lowermob_l,1,4)
label variable r`wv'lowermoba_l "r`wv'lowermoba_l:w`wv' whether r has Any Diff-Lower Mobility: 4-item"
label values r`wv'lowermoba_l diff
*spouse
gen s`wv'lowermoba_l=.
spouse r`wv'lowermoba_l, result(s`wv'lowermoba_l) wave(`wv')
label variable s`wv'lowermoba_l "s`wv'lowermoba_l:w`wv' whether s has Any Diff-Lower Mobility: 4-item"
label values s`wv'lowermoba_l diff

***Upper mobility summary missings
egen r`wv'uppermobm=rowmiss(r`wv'armsa r`wv'lifta r`wv'dimea) if inw`wv'==1
label variable r`wv'uppermobm "r`wv'uppermobm:w`wv' r Missings in Some Diff-Upper Mobility /0-3"
*spouse
gen s`wv'uppermobm=.
spouse r`wv'uppermobm, result(s`wv'uppermobm) wave(`wv')
label variable s`wv'uppermobm "s`wv'uppermobm:w`wv' s Missings in Some Diff-Upper Mobility /0-3"

***upper mobility summary 0-3
egen r`wv'uppermob=rowtotal(r`wv'armsa r`wv'lifta r`wv'dimea) if inrange(r`wv'uppermobm,0,2),m
replace r`wv'uppermob=.m if r`wv'uppermobm==3
label variable r`wv'uppermob "r`wv'uppermob:w`wv' r Some Diff-Upper Mobility /0-3"
*spouse
gen s`wv'uppermob=.
spouse r`wv'uppermob, result(s`wv'uppermob) wave(`wv')
label variable s`wv'uppermob "s`wv'uppermob:w`wv' s Some Diff-Upper Mobility /0-3"

***Any diff - upper mobility 0-3
gen r`wv'uppermoba=.
replace r`wv'uppermoba=.m if r`wv'uppermob==.m
replace r`wv'uppermoba=0 if r`wv'uppermob==0
replace r`wv'uppermoba=1 if inrange(r`wv'uppermob,1,3)
label variable r`wv'uppermoba "r`wv'uppermoba:w`wv' whether r has Any Diff-Lower Mobility: 3-item"
label values r`wv'uppermoba diff
*spouse
gen s`wv'uppermoba=.
spouse r`wv'uppermoba, result(s`wv'uppermoba) wave(`wv')
label variable s`wv'uppermoba "s`wv'uppermoba:w`wv' whether s has Any Diff-Lower Mobility: 3-item"
label values s`wv'uppermoba diff

***8-item mobility summary***
*respondent 8-item mobility summary
egen r`wv'nagi8m = rowmiss(r`wv'walk100a r`wv'sita r`wv'chaira r`wv'stoopa r`wv'armsa r`wv'pusha r`wv'lifta r`wv'dimea) if inw`wv'==1
egen r`wv'nagi8 = rowtotal(r`wv'walk100a r`wv'sita r`wv'chaira r`wv'stoopa r`wv'armsa r`wv'pusha r`wv'lifta r`wv'dimea) if inrange(r`wv'nagi8m,0,7),m
replace r`wv'nagi8 = .m if (r`wv'walk100a==.m | r`wv'sita==.m | r`wv'chaira==.m | r`wv'stoopa==.m | r`wv'armsa==.m | r`wv'pusha==.m | r`wv'lifta==.m | r`wv'dimea==.m) & r`wv'nagi8==.  
replace r`wv'nagi8 = .d if (r`wv'walk100a==.d | r`wv'sita==.d | r`wv'chaira==.d | r`wv'stoopa==.d | r`wv'armsa==.d | r`wv'pusha==.d | r`wv'lifta==.d | r`wv'dimea==.d) & r`wv'nagi8==.  
replace r`wv'nagi8 = .r if (r`wv'walk100a==.r | r`wv'sita==.r | r`wv'chaira==.r | r`wv'stoopa==.r | r`wv'armsa==.r | r`wv'pusha==.r | r`wv'lifta==.r | r`wv'dimea==.r) & r`wv'nagi8==.  
*replace r`wv'nagi8 = .s if (r`wv'walk100a==.s | r`wv'sita==.s | r`wv'chaira==.s | r`wv'stoopa==.s | r`wv'armsa==.s | r`wv'pusha==.s | r`wv'lifta==.s | r`wv'dimea==.s) & r`wv'nagi8==.  
*replace r`wv'nagi8 = .q if (r`wv'walk100a==.q | r`wv'sita==.q | r`wv'chaira==.q | r`wv'stoopa==.q | r`wv'armsa==.q | r`wv'pusha==.q | r`wv'lifta==.q | r`wv'dimea==.q) & r`wv'nagi8==.  
*replace r`wv'nagi8 = .x if (r`wv'walk100a==.x | r`wv'sita==.x | r`wv'chaira==.x | r`wv'stoopa==.x | r`wv'armsa==.x | r`wv'pusha==.x | r`wv'lifta==.x | r`wv'dimea==.x) & r`wv'nagi8==.  
label variable r`wv'nagi8m "r`wv'nagi8m:w`wv' r some difficulty-missings in 8-item NAGI score"
label variable r`wv'nagi8 "r`wv'nagi8:w`wv' r some difficulty-NAGI score 0-8"

gen r`wv'nagi8a = .
missing_lasi r`wv'nagi8, result(r`wv'nagi8a) wave(`wv')
replace r`wv'nagi8a = 0 if r`wv'nagi8==0
replace r`wv'nagi8a = 1 if inrange(r`wv'nagi8,1,8)
label variable r`wv'nagi8a "r`wv'nagi8a:w`wv' whether r has any diff-8 item NAGI score"
label values r`wv'nagi8a diff

*spouse 8-item mobility summary
egen s`wv'nagi8m = rowmiss(s`wv'walk100a s`wv'sita s`wv'chaira s`wv'stoopa s`wv'armsa s`wv'pusha s`wv'lifta s`wv'dimea) if inw`wv'==1
egen s`wv'nagi8 = rowtotal(s`wv'walk100a s`wv'sita s`wv'chaira s`wv'stoopa s`wv'armsa s`wv'pusha s`wv'lifta s`wv'dimea) if inrange(s`wv'nagi8m,0,7),m
replace s`wv'nagi8 = .u if (s`wv'walk100a==.u | s`wv'sita==.u | s`wv'chaira==.u | s`wv'stoopa==.u | s`wv'armsa==.u | s`wv'pusha==.u | s`wv'lifta==.u | s`wv'dimea==.u) & s`wv'nagi8==.
replace s`wv'nagi8 = .v if (s`wv'walk100a==.v | s`wv'sita==.v | s`wv'chaira==.v | s`wv'stoopa==.v | s`wv'armsa==.v | s`wv'pusha==.v | s`wv'lifta==.v | s`wv'dimea==.v) & s`wv'nagi8==.
replace s`wv'nagi8 = .m if (s`wv'walk100a==.m | s`wv'sita==.m | s`wv'chaira==.m | s`wv'stoopa==.m | s`wv'armsa==.m | s`wv'pusha==.m | s`wv'lifta==.m | s`wv'dimea==.m) & s`wv'nagi8==.  
replace s`wv'nagi8 = .d if (s`wv'walk100a==.d | s`wv'sita==.d | s`wv'chaira==.d | s`wv'stoopa==.d | s`wv'armsa==.d | s`wv'pusha==.d | s`wv'lifta==.d | s`wv'dimea==.d) & s`wv'nagi8==.  
replace s`wv'nagi8 = .r if (s`wv'walk100a==.r | s`wv'sita==.r | s`wv'chaira==.r | s`wv'stoopa==.r | s`wv'armsa==.r | s`wv'pusha==.r | s`wv'lifta==.r | s`wv'dimea==.r) & s`wv'nagi8==.  
*replace s`wv'nagi8 = .s if (s`wv'walk100a==.s | s`wv'sita==.s | s`wv'chaira==.s | s`wv'stoopa==.s | s`wv'armsa==.s | s`wv'pusha==.s | s`wv'lifta==.s | s`wv'dimea==.s) & s`wv'nagi8==.  
*replace s`wv'nagi8 = .q if (s`wv'walk100a==.q | s`wv'sita==.q | s`wv'chaira==.q | s`wv'stoopa==.q | s`wv'armsa==.q | s`wv'pusha==.q | s`wv'lifta==.q | s`wv'dimea==.q) & s`wv'nagi8==.  
*replace s`wv'nagi8 = .x if (s`wv'walk100a==.x | s`wv'sita==.x | s`wv'chaira==.x | s`wv'stoopa==.x | s`wv'armsa==.x | s`wv'pusha==.x | s`wv'lifta==.x | s`wv'dimea==.x) & s`wv'nagi8==.  
label variable s`wv'nagi8m "s`wv'nagi8m:w`wv' s some difficulty-missings in 8-item NAGI score"
label variable s`wv'nagi8 "s`wv'nagi8:w`wv' s some difficulty-NAGI score 0-8"

gen s`wv'nagi8a = .
spouse r`wv'nagi8a, result(s`wv'nagi8a) wave(`wv')
label variable s`wv'nagi8a "s`wv'nagi8a:w`wv' whether s has any diff-8 item NAGI score"
label values s`wv'nagi8a diff

*********************************************************************
***Doctor Diagnosed Health Problems***
*********************************************************************

***ever have high blood pressure
gen r`wv'hibpe=.
missing_lasi ht002, result(r`wv'hibpe) wave(`wv')
replace r`wv'hibpe=0 if ht002==2
replace r`wv'hibpe=1 if ht002==1
label variable r`wv'hibpe "r`wv'hibpe:w`wv' r ever had high blood pressure"
label values r`wv'hibpe doctor
*spouse 
gen s`wv'hibpe=.
spouse r`wv'hibpe, result(s`wv'hibpe) wave(`wv')
label variable s`wv'hibpe "s`wv'hibpe:w`wv' s ever had high blood pressure"
label values s`wv'hibpe doctor

***ever have diabetes
gen r`wv'diabe=.
missing_lasi ht003, result(r`wv'diabe) wave(`wv')
replace r`wv'diabe=0 if ht003==2
replace r`wv'diabe=1 if ht003==1
label variable r`wv'diabe "r`wv'diabe:w`wv' r ever had diabetes"
label values r`wv'diabe doctor
*spouse 
gen s`wv'diabe=.
spouse r`wv'diabe , result(s`wv'diabe) wave(`wv')
label variable s`wv'diabe "s`wv'diabe:w`wv' s ever had diabetes"
label values s`wv'diabe doctor

***ever have cancer
gen r`wv'cancre=.
missing_lasi ht004, result(r`wv'cancre) wave(`wv')
replace r`wv'cancre=0 if ht004==2
replace r`wv'cancre=1 if ht004==1
label variable r`wv'cancre "r`wv'cancre:w`wv' r ever had cancer"
label values r`wv'cancre doctor
*spouse 
gen s`wv'cancre=.
spouse r`wv'cancre , result(s`wv'cancre) wave(`wv')
label variable s`wv'cancre "s`wv'cancre:w`wv' s ever had cancer"
label values s`wv'cancre doctor

***ever have lung disease
gen r`wv'lunge=.
missing_lasi ht005 ht005ds1 ht005ds2 ht005ds4, result(r`wv'lunge) wave(`wv')
*replace r`wv'lunge=0 if ht005==2
*replace r`wv'lunge=1 if ht005==1
replace r`wv'lunge=0 if ht005==2 | (ht005==1 & (ht005ds1==0 | ht005ds2==0 | ht005ds4==0))
replace r`wv'lunge=1 if ht005==1 & (ht005ds1==1 | ht005ds2==1 | ht005ds4==1)
label variable r`wv'lunge "r`wv'lunge:w`wv' r ever had lung disease"
label values r`wv'lunge doctor
*spouse 
gen s`wv'lunge=.
spouse r`wv'lunge , result(s`wv'lunge) wave(`wv')
label variable s`wv'lunge "s`wv'lunge:w`wv' s ever had lung disease"
label values s`wv'lunge doctor

***ever have heart problem
gen r`wv'hearte=.
missing_lasi ht006, result(r`wv'hearte) wave(`wv')
replace r`wv'hearte=0 if ht006==2
replace r`wv'hearte=1 if ht006==1
label variable r`wv'hearte "r`wv'hearte:w`wv' r ever had heart problem"
label values r`wv'hearte doctor
*spouse
gen s`wv'hearte=.
spouse r`wv'hearte , result(s`wv'hearte) wave(`wv')
label variable s`wv'hearte "s`wv'hearte:w`wv' s ever had heart problem"
label values s`wv'hearte doctor

***ever have stroke
gen r`wv'stroke=.
missing_lasi ht007, result(r`wv'stroke) wave(`wv')
replace r`wv'stroke=0 if ht007==2
replace r`wv'stroke=1 if ht007==1
label variable r`wv'stroke "r`wv'stroke:w`wv' r ever had stroke"
label values r`wv'stroke doctor
*spouse 
gen s`wv'stroke=.
spouse r`wv'stroke , result(s`wv'stroke) wave(`wv')
label variable s`wv'stroke "s`wv'stroke:w`wv' s ever had stroke"
label values s`wv'stroke doctor

***ever have arthritis
gen r`wv'arthre=.
missing_lasi ht008 ht008as1 ht008as2, result(r`wv'arthre) wave(`wv')
replace r`wv'arthre=0 if ht008==2 | (ht008==1 & (ht008as1==0 | ht008as2==0))
replace r`wv'arthre=1 if ht008==1 & (ht008as1==1 | ht008as2==1)
label variable r`wv'arthre "r`wv'arthre:w`wv' r ever had arthritis"
label values r`wv'arthre doctor
*spouse 
gen s`wv'arthre=.
spouse r`wv'arthre , result(s`wv'arthre) wave(`wv')
label variable s`wv'arthre "s`wv'arthre:w`wv' s ever had arthritis"
label values s`wv'arthre doctor

***ever have psychological disease
gen r`wv'psyche=.
missing_lasi ht009 ht009as1 ht009as3, result(r`wv'psyche) wave(`wv')
replace r`wv'psyche=0 if ht009==2 | (ht009==1 & (ht009as1==0 | ht009as3==0))
replace r`wv'psyche=1 if ht009==1 & (ht009as1==1 | ht009as3==1)
label variable r`wv'psyche "r`wv'psyche:w`wv' r ever had psych problem"
label values r`wv'psyche doctor
*spouse
gen s`wv'psyche=.
spouse r`wv'psyche , result(s`wv'psyche) wave(`wv')
label variable s`wv'psyche "s`wv'psyche:w`wv' s ever had psych problem"
label values s`wv'psyche doctor

***ever have alzheimer's/dementia disease
gen r`wv'alzdeme=.
missing_lasi ht009 ht009as2, result(r`wv'alzdeme) wave(`wv')
replace r`wv'alzdeme=0 if ht009==2 | (ht009==1 & ht009as2==0)
replace r`wv'alzdeme=1 if ht009==1 & ht009as2==1
label variable r`wv'alzdeme "r`wv'alzdeme:w`wv' r ever had alzheimers/dementia"
label values r`wv'alzdeme doctor
*spouse
gen s`wv'alzdeme=.
spouse r`wv'alzdeme, result(s`wv'alzdeme) wave(`wv')
label variable s`wv'alzdeme "s`wv'alzdeme:w`wv' s ever had alzheimers/dementia"
label values s`wv'alzdeme doctor

***ever have high cholesterol
gen r`wv'hchole=.
missing_lasi ht010, result(r`wv'hchole) wave(`wv')
replace r`wv'hchole=0 if ht010==2
replace r`wv'hchole=1 if ht010==1
label variable r`wv'hchole "r`wv'hchole:w`wv' r ever had high cholesterol"
label values r`wv'hchole doctor
*spouse 
gen s`wv'hchole=.
spouse r`wv'hchole , result(s`wv'hchole) wave(`wv')
label variable s`wv'hchole "s`wv'hchole:w`wv' s ever had high cholesterol"
label values s`wv'hchole doctor


*********************************************************************
***Health Behaviors: Preventive Behaviors***
*********************************************************************

***ever had mammogram
gen r`wv'mammog=.
missing_lasi dm003 ht242, result(r`wv'mammog) wave(`wv')
replace r`wv'mammog=.s if inlist(dm003,1,3) & inw`wv'==1
replace r`wv'mammog=0 if ht242==2
replace r`wv'mammog=1 if ht242==1
label variable r`wv'mammog "r`wv'mammog:w`wv' r prev mammogram in the last 2 years"
label values r`wv'mammog diff
*spouse 
gen s`wv'mammog=.
spouse r`wv'mammog , result(s`wv'mammog) wave(`wv')
label variable s`wv'mammog "s`wv'mammog:w`wv' s prev mammogram in the last 2 years"
label values s`wv'mammog diff

***ever have a pap smear test
gen r`wv'papsm=.
missing_lasi dm003 ht241, result(r`wv'papsm) wave(`wv')
replace r`wv'papsm=.s if inlist(dm003,1,3) & inw`wv'==1
replace r`wv'papsm=0 if ht241==2
replace r`wv'papsm=1 if ht241==1
label variable r`wv'papsm "r`wv'papsm:w`wv' r prev PAP smear test in the last 2 years"
label values r`wv'papsm diff
*spouse
gen s`wv'papsm=.
spouse r`wv'papsm , result(s`wv'papsm) wave(`wv')
label variable s`wv'papsm "s`wv'papsm:w`wv' s prev PAP smear test in the last 2 years"
label values s`wv'papsm diff

***ever have flu shot
gen r`wv'flushte=.
missing_lasi ht211s1 ht211s7, result(r`wv'flushte) wave(`wv')
replace r`wv'flushte=0 if ht211s1==0 | ht211s7==1
replace r`wv'flushte=1 if ht211s1==1
label variable r`wv'flushte "r`wv'flushte:w`wv' r ever received flu shot"
label values r`wv'flushte diff
*spouse 
gen s`wv'flushte=.
spouse r`wv'flushte , result(s`wv'flushte) wave(`wv')
label variable s`wv'flushte "s`wv'flushte:w`wv' s ever received flu shot"
label values s`wv'flushte diff

***had blood test for cholesterol in past 2 years
gen r`wv'cholst=.
missing_lasi ht010d, result(r`wv'cholst) wave(`wv')
replace r`wv'cholst=0 if ht010d==2
replace r`wv'cholst=1 if ht010d==1
label variable r`wv'cholst "r`wv'cholst:w`wv' r prev cholesterol blood test in the last 2 years"
label values r`wv'cholst diff
*spouse
gen s`wv'cholst=.
spouse r`wv'cholst, result(s`wv'cholst) wave(`wv')
label variable s`wv'cholst "s`wv'cholst:w`wv' s prev cholesterol blood test in the last 2 years"
label values s`wv'cholst diff

***ever have pneumococccal vaccine
gen r`wv'pneushte=.
missing_lasi ht211s2 ht211s7, result(r`wv'pneushte) wave(`wv')
replace r`wv'pneushte=0 if ht211s2==0 | ht211s7==1
replace r`wv'pneushte=1 if ht211s2==1
label variable r`wv'pneushte "r`wv'pneushte:w`wv' r ever received pneumococcal vaccine"
label values r`wv'pneushte diff
*spouse
gen s`wv'pneushte=.
spouse r`wv'pneushte, result(s`wv'pneushte) wave(`wv')
label variable s`wv'pneushte "s`wv'pneushte:w`wv' s ever received pneumococcal vaccine"
label values s`wv'pneushte diff


*********************************************************************
***Health Behaviors: Physical Activity or Exercise***
*********************************************************************

***vigorous physical activity frequency
gen r`wv'vgactx=.
missing_lasi hb211, result(r`wv'vgactx) wave(`wv')
replace r`wv'vgactx=hb211 if inrange(hb211,1,5)
label variable r`wv'vgactx "r`wv'vgactx:w`wv' r frequency of vigorous physical activity"
label values r`wv'vgactx activity
*spouse 
gen s`wv'vgactx=.
spouse r`wv'vgactx , result(s`wv'vgactx) wave(`wv')
label variable s`wv'vgactx "s`wv'vgactx:w`wv' s frequency of vigorous physical activity"
label values s`wv'vgactx activity

***moderate physical activity
gen r`wv'mdactx=.
missing_lasi hb213, result(r`wv'mdactx) wave(`wv')
replace r`wv'mdactx=hb213 if inrange(hb213,1,5)
label variable r`wv'mdactx "r`wv'mdactx:w`wv' r frequency of moderate physical activity"
label values r`wv'mdactx activity
*spouse 
gen s`wv'mdactx=.
spouse r`wv'mdactx , result(s`wv'mdactx) wave(`wv')
label variable s`wv'mdactx "s`wv'mdactx:w`wv' s frequency of moderate physical activity"
label values s`wv'mdactx activity

***yoga/meditation
gen r`wv'yogax=.
missing_lasi hb215, result(r`wv'yogax) wave(`wv')
replace r`wv'yogax=hb215 if inrange(hb215,1,5)
label variable r`wv'yogax "r`wv'yogax:w`wv' r frequency of yoga/meditation"
label values r`wv'yogax activity
*spouse 
gen s`wv'yogax=.
spouse r`wv'yogax , result(s`wv'yogax) wave(`wv')
label variable s`wv'yogax "s`wv'yogax:w`wv' s frequency of yoga/meditation"
label values s`wv'yogax activity


*********************************************************************
***Health Behaviors: Drinking***
*********************************************************************

***Ever drink alcohol
gen r`wv'drinkev=.
missing_lasi hb101, result(r`wv'drinkev) wave(`wv')
replace r`wv'drinkev=0 if hb101==2
replace r`wv'drinkev=1 if hb101==1
label variable r`wv'drinkev "r`wv'drinkev:w`wv' r ever drank any alcohol"
label values r`wv'drinkev doctor
*spouse
gen s`wv'drinkev=.
spouse r`wv'drinkev, result(s`wv'drinkev) wave(`wv')
label variable s`wv'drinkev "s`wv'drinkev:w`wv' s ever drank any alcohol"
label values s`wv'drinkev doctor

***drink alcohol last 3 months
gen r`wv'drink3m=.
missing_lasi r`wv'drinkev hb103, result(r`wv'drink3m) wave(`wv')
replace r`wv'drink3m = .m if hb103 == 5
replace r`wv'drink3m=0 if r`wv'drinkev==0 | hb103==0
replace r`wv'drink3m=1 if inrange(hb103,1,4)
label variable r`wv'drink3m "r`wv'drink3m:w`wv' r drinks any alcohol last 3 months"
label values r`wv'drink3m doctor
*spouse 
gen s`wv'drink3m=.
spouse r`wv'drink3m, result(s`wv'drink3m) wave(`wv')
label variable s`wv'drink3m "s`wv'drink3m:w`wv' s drinks any alcohol last 3 months"
label values s`wv'drink3m doctor

***Drinking Frequency
gen r`wv'drinkx_l=. 
missing_lasi hb103 r`wv'drinkev, result(r`wv'drinkx_l) wave(`wv')
replace r`wv'drinkx_l = .m if hb103 == 5
replace r`wv'drinkx_l=0 if r`wv'drinkev==0 | hb103==0
replace r`wv'drinkx_l=hb103 if inrange(hb103,1,4)
label variable r`wv'drinkx_l "r`wv'drinkx_l:w`wv' r frequency of drinking in the past 3 months"
label values r`wv'drinkx_l drinkx
*spouse 
gen s`wv'drinkx_l=.
spouse r`wv'drinkx_l, result(s`wv'drinkx_l) wave(`wv')
label variable s`wv'drinkx_l "s`wv'drinkx_l:w`wv' s frequency of drinking in the past 3 months"
label values s`wv'drinkx_l drinkx

***Drinking Amount
*gen r`wv'drinkn_l=. 
*missing_lasi hb103 r`wv'drink hb105, result(r`wv'drinkn_l) wave(`wv')
*replace r`wv'drinkn_l=0 if r`wv'drink==0 | hb103==0
*replace r`wv'drinkn_l=hb105 if inrange(hb105,0,99)
*label variable r`wv'drinkn_l "r`wv'drinkn_l:w`wv' r # drinks/day"
**spouse drinking amount
*gen s`wv'drinkn_l=.
*spouse r`wv'drinkn_l, result(s`wv'drinkn_l) wave(`wv')
*label variable s`wv'drinkn_l "s`wv'drinkn_l:w`wv' s # drinks/day"

****Number of drinks in past 3 months 
*gen r`wv'drinkn3m=.
*missing_lasi hb103 r`wv'drink hb105, result(r`wv'drinkn3m) wave(`wv')
*replace r`wv'drinkn3m=0 if r`wv'drink==0 | hb103==0
*replace r`wv'drinkn3m=hb105 if !mi(hb105) & inrange(hb105,0,400000)
*label variable r`wv'drinkn3m "r`wv'drinkn3m:w`wv' r # drinks/3 months"
**spouse number of drinks in past 3 months
*gen s`wv'drinkn3m=.
*spouse r`wv'drinkn3m, result(s`wv'drinkn3m) wave(`wv')
*label variable s`wv'drinkn3m "s`wv'drinkn3m:w`wv' s # drinks/3 months" 


*********************************************************************
***Health Behaviors: Smoking (Cigarettes)***
*********************************************************************

***smoke ever
gen r`wv'smokev=.
missing_lasi hb001 hb003, result(r`wv'smokev) wave(`wv')
replace r`wv'smokev=0 if hb001==2 | hb003==2
replace r`wv'smokev=1 if hb001==1 & inlist(hb003,1,3)
label variable r`wv'smokev "r`wv'smokev:w`wv' r ever smoked"
label values r`wv'smokev smokes
*spouse 
gen s`wv'smokev=.
spouse r`wv'smokev, result(s`wv'smokev) wave(`wv')
label variable s`wv'smokev "s`wv'smokev:w`wv' s ever smoked"
label values s`wv'smokev smokes

***smoking now
gen r`wv'smoken=.
missing_lasi hb003_a hb001 hb003, result(r`wv'smoken) wave(`wv')
replace r`wv'smoken=0 if hb001==2 | hb003==2 | hb003_a==2
replace r`wv'smoken=1 if hb003_a==1
label variable r`wv'smoken "r`wv'smoken:w`wv' r smokes now"
label values r`wv'smoken diff
*spouse 
gen s`wv'smoken=.
spouse r`wv'smoken, result(s`wv'smoken) wave(`wv')
label variable s`wv'smoken "s`wv'smoken:w`wv' s smokes now"
label values s`wv'smoken diff

***smoking frequency
gen r`wv'smokef=.
missing_lasi hb004 hb003_a hb001 hb003, result(r`wv'smokef) wave(`wv')
replace r`wv'smokef=.m if hb004==.e
replace r`wv'smokef=0 if r`wv'smokev==0 | r`wv'smoken==0 
replace r`wv'smokef=hb004 if inrange(hb004,0,144)
label variable r`wv'smokef "r`wv'smokef:w`wv' r # cigarettes/bidis/cigars/cheroot per day"
*spouse 
gen s`wv'smokef=.
spouse r`wv'smokef, result(s`wv'smokef) wave(`wv')
label variable s`wv'smokef "s`wv'smokef:w`wv' s # cigarettes/bidis/cigars/cheroot per day"

***ever consumed smokeless tobacco
gen r`wv'otbccv=.
missing_lasi hb001 hb003, result(r`wv'otbccv) wave(`wv')
replace r`wv'otbccv=0 if hb001==2 | hb003==1
replace r`wv'otbccv=1 if hb001==1 & inlist(hb003,2,3)
label variable r`wv'otbccv "r`wv'otbccv:w`wv' r ever used smokeless tobacco"
label values r`wv'otbccv smokes
*spouse 
gen s`wv'otbccv=.
spouse r`wv'otbccv, result(s`wv'otbccv) wave(`wv')
label variable s`wv'otbccv "s`wv'otbccv:w`wv' s ever used smokeless tobacco"
label values s`wv'otbccv smokes

***consumes smokeless tobacco now 
gen r`wv'otbccn=.
missing_lasi hb001 hb003 hb006, result(r`wv'otbccn) wave(`wv')
replace r`wv'otbccn=0 if hb001==2 | hb003==1 | hb006==2
replace r`wv'otbccn=1 if hb001==1 & inlist(hb003,2,3) & hb006==1
label variable r`wv'otbccn "r`wv'otbccn:w`wv' r uses smokeless tobacco"
label values r`wv'otbccn smokes
*spouse 
gen s`wv'otbccn=.
spouse r`wv'otbccn, result(s`wv'otbccn) wave(`wv')
label variable s`wv'otbccn "s`wv'otbccn:w`wv' s uses smokeless tobacco"
label values s`wv'otbccn smokes

***age started smoking 
gen r`wv'strtsmok=.
missing_lasi hb002_age hb002_year hb002_yearsago r`wv'smokev, result(r`wv'strtsmok) wave(`wv')
replace r`wv'strtsmok = .n if r`wv'smokev==0 //did not ever smoke
replace r`wv'strtsmok = hb002_age if inrange(hb002_age,5,90) & r`wv'smokev==1 
replace r`wv'strtsmok = hb002_year - rabyear if inrange(hb002_year,1949,2018) & r`wv'smokev==1 & !mi(rabyear) & mi(r`wv'strtsmok)
replace r`wv'strtsmok = r`wv'agey - hb002_yearsago if inrange(hb002_yearsago,0,70) & r`wv'smokev==1 & !mi(r`wv'agey) & mi(r`wv'strtsmok)
replace r`wv'strtsmok = .i if r`wv'strtsmok < 1 
label variable r`wv'strtsmok "r`wv'strtsmok:w`wv' r age started smoking"
*spouse
gen s`wv'strtsmok=.
spouse r`wv'strtsmok, result(s`wv'strtsmok) wave(`wv')
label variable s`wv'strtsmok "s`wv'strtsmok:w`wv' s age started smoking"

***age started smokeless tobacco
gen r`wv'strtotbcc=.
missing_lasi hb002_age hb002_year hb002_yearsago r`wv'otbccv, result(r`wv'strtotbcc) wave(`wv')
replace r`wv'strtotbcc = .n if r`wv'otbccv==0
replace r`wv'strtotbcc = hb002_age if inrange(hb002_age,5,90) & r`wv'otbccv==1
replace r`wv'strtotbcc = hb002_year - rabyear if inrange(hb002_year,1949,2018) & r`wv'otbccv==1 & !mi(rabyear) & mi(r`wv'strtotbcc)
replace r`wv'strtotbcc = r`wv'agey - hb002_yearsago if inrange(hb002_yearsago,0,70) & r`wv'otbccv==1 & !mi(r`wv'agey) & mi(r`wv'strtotbcc)
replace r`wv'strtotbcc = .i if r`wv'strtotbcc < 1
label variable r`wv'strtotbcc "r`wv'strtotbcc:w`wv' r age started smokeless tobacco"
*spouse
gen s`wv'strtotbcc=.
spouse r`wv'strtotbcc, result(s`wv'strtotbcc) wave(`wv')
label variable s`wv'strtotbcc "s`wv'strtotbcc:w`wv' s age started smokeless tobacco"

***age quit smoking
gen r`wv'quitsmok=.
missing_lasi hb005_age hb005_year hb005_yearsago r`wv'smokev r`wv'smoken, result(r`wv'quitsmok) wave(`wv')
replace r`wv'quitsmok = .n if r`wv'smokev==0 //never smoked
replace r`wv'quitsmok = .c if r`wv'smoken==1 //currently smoking
replace r`wv'quitsmok = hb005_age if inrange(hb005_age,7,96) 
replace r`wv'quitsmok = hb005_year - rabyear if inrange(hb005_year,1961,2019) & !mi(rabyear) & mi(r`wv'quitsmok)
replace r`wv'quitsmok = r`wv'agey - hb005_yearsago if inrange(hb005_yearsago,1,50) & !mi(r`wv'agey) & mi(r`wv'quitsmok)
replace r`wv'quitsmok = .i if r`wv'quitsmok < 1
label variable r`wv'quitsmok "r`wv'quitsmok:w`wv' r age quit smoking"
*spouse
gen s`wv'quitsmok=.
spouse r`wv'quitsmok, result(s`wv'quitsmok) wave(`wv')
label variable s`wv'quitsmok "s`wv'quitsmok:w`wv' s age quit smoking"

***age quit smokeless tobacco
gen r`wv'quitotbcc=.
missing_lasi hb011_age hb011_year hb011_yearsago r`wv'otbccv r`wv'otbccn, result(r`wv'quitotbcc) wave(`wv')
replace r`wv'quitotbcc = .n if r`wv'otbccv==0
replace r`wv'quitotbcc = .c if r`wv'otbccn==1 
replace r`wv'quitotbcc = hb011_age if inrange(hb011_age,0,95)
replace r`wv'quitotbcc = hb011_year - rabyear if inrange(hb011_year,1965,2018) & !mi(rabyear) & mi(r`wv'quitotbcc)
replace r`wv'quitotbcc = r`wv'agey - hb011_yearsago if inrange(hb011_yearsago,0,40) & !mi(r`wv'agey) & mi(r`wv'quitotbcc)
replace r`wv'quitotbcc = .i if r`wv'quitotbcc < 1
label variable r`wv'quitotbcc "r`wv'quitotbcc:w`wv' r age quit smokeless tobacco"
*spouse
gen s`wv'quitotbcc=.
spouse r`wv'quitotbcc, result(s`wv'quitotbcc) wave(`wv')
label variable s`wv'quitotbcc "s`wv'quitotbcc:w`wv' s age quit smokeless tobacco"



*********************************************************************
***Whether receive treatment or medication for disease*** 
*********************************************************************

***taking medication for high blood pressure
gen r`wv'rxhibp=.
missing_lasi ht002c r`wv'hibpe, result(r`wv'rxhibp) wave(`wv')
replace r`wv'rxhibp=0 if r`wv'hibpe==0 | (r`wv'hibpe==1 & ht002c==2)
replace r`wv'rxhibp=1 if r`wv'hibpe==1 & ht002c==1
label variable r`wv'rxhibp "r`wv'rxhibp:w`wv' r takes meds for high blood pressure"
label values r`wv'rxhibp doctor
*spouse
gen s`wv'rxhibp=.
spouse r`wv'rxhibp, result(s`wv'rxhibp) wave(`wv')
label variable s`wv'rxhibp "s`wv'rxhibp:w`wv' s takes meds for high blood pressure"
label values s`wv'rxhibp doctor

***taking oral medication for diabetes
gen r`wv'rxdiabo=.
missing_lasi ht003c r`wv'diabe, result(r`wv'rxdiabo) wave(`wv')
replace r`wv'rxdiabo=0 if r`wv'diabe==0 | (r`wv'diabe==1 & ht003c==2)
replace r`wv'rxdiabo=1 if r`wv'diabe==1 & ht003c==1
label variable r`wv'rxdiabo "r`wv'rxdiabo:w`wv' r takes oral meds for diabetes"
label values r`wv'rxdiabo doctor
*spouse
gen s`wv'rxdiabo=.
spouse r`wv'rxdiabo, result(s`wv'rxdiabo) wave(`wv')
label variable s`wv'rxdiabo "s`wv'rxdiabo:w`wv' s takes oral meds for diabetes"
label values s`wv'rxdiabo doctor

***taking insulin for diabetes
gen r`wv'rxdiabi=.
missing_lasi ht003d r`wv'diabe, result(r`wv'rxdiabi) wave(`wv')
replace r`wv'rxdiabi=0 if r`wv'diabe==0 | (r`wv'diabe==1 & ht003d==2)
replace r`wv'rxdiabi=1 if r`wv'diabe==1 & ht003d==1
label variable r`wv'rxdiabi "r`wv'rxdiabi:w`wv' r takes insulin for diabetes"
label values r`wv'rxdiabi doctor
*spouse
gen s`wv'rxdiabi=.
spouse r`wv'rxdiabi, result(s`wv'rxdiabi) wave(`wv')
label variable s`wv'rxdiabi "s`wv'rxdiabi:w`wv' s takes insulin for diabetes"
label values s`wv'rxdiabi doctor

***taking any medication for diabetes
gen r`wv'rxdiab=.
missing_lasi r`wv'rxdiabo r`wv'rxdiabi, result(r`wv'rxdiab) wave(`wv')
replace r`wv'rxdiab=0 if r`wv'rxdiabo==0 | r`wv'rxdiabi==0
replace r`wv'rxdiab=1 if r`wv'rxdiabo==1 | r`wv'rxdiabi==1
label variable r`wv'rxdiab "r`wv'rxdiab:w`wv' r takes meds for diabetes"
label values r`wv'rxdiab doctor
*spouse 
gen s`wv'rxdiab=.
spouse r`wv'rxdiab, result(s`wv'rxdiab) wave(`wv')
label variable s`wv'rxdiab "s`wv'rxdiab:w`wv' s takes meds for diabetes"
label values s`wv'rxdiab doctor

***types of cancer treatments
*cancer treatment: chemo
gen r`wv'cncrchem=.
missing_lasi ht004fs1 ht004fs6 r`wv'cancre, result(r`wv'cncrchem) wave(`wv')
replace r`wv'cncrchem=0 if r`wv'cancre==0 | (r`wv'cancre==1 & (ht004fs1==0 | ht004fs6==1))
replace r`wv'cncrchem=1 if r`wv'cancre==1 & ht004fs1==1
label variable r`wv'cncrchem "r`wv'cncrchem:w`wv' r chemotherapy cancer treatment"
label values r`wv'cncrchem doctor
*spouse
gen s`wv'cncrchem=.
spouse r`wv'cncrchem, result(s`wv'cncrchem) wave(`wv')
label variable s`wv'cncrchem "s`wv'cncrchem:w`wv' s chemotherapy cancer treatment"
label values s`wv'cncrchem doctor

*cancer treatment: surgery
gen r`wv'cncrsurg=.
missing_lasi ht004fs2 ht004fs6 r`wv'cancre, result(r`wv'cncrsurg) wave(`wv')
replace r`wv'cncrsurg=0 if r`wv'cancre==0 | (r`wv'cancre==1 & (ht004fs2==0 | ht004fs6==1))
replace r`wv'cncrsurg=1 if r`wv'cancre==1 & ht004fs2==1
label variable r`wv'cncrsurg "r`wv'cncrsurg:w`wv' r surgery cancer treatment"
label values r`wv'cncrsurg doctor
*spouse
gen s`wv'cncrsurg=.
spouse r`wv'cncrsurg, result(s`wv'cncrsurg) wave(`wv')
label variable s`wv'cncrsurg "s`wv'cncrsurg:w`wv' s surgery cancer treatment"
label values s`wv'cncrsurg doctor

*cancer treatment: radiation
gen r`wv'cncrradn=.
missing_lasi ht004fs3 ht004fs6 r`wv'cancre, result(r`wv'cncrradn) wave(`wv')
replace r`wv'cncrradn=0 if r`wv'cancre==0 | (r`wv'cancre==1 & (ht004fs3==0 | ht004fs6==1))
replace r`wv'cncrradn=1 if r`wv'cancre==1 & ht004fs3==1
label variable r`wv'cncrradn "r`wv'cncrradn:w`wv' r radiation cancer treatment"
label values r`wv'cncrradn doctor
*spouse
gen s`wv'cncrradn=.
spouse r`wv'cncrradn, result(s`wv'cncrradn) wave(`wv')
label variable s`wv'cncrradn "s`wv'cncrradn:w`wv' s radiation cancer treatment"
label values s`wv'cncrradn doctor

*cancer treatment: other
gen r`wv'cncrothr=.
missing_lasi ht004fs5 ht004fs6 r`wv'cancre, result(r`wv'cncrothr) wave(`wv')
replace r`wv'cncrothr=0 if r`wv'cancre==0 | (r`wv'cancre==1 & (ht004fs5==0 | ht004fs6==1))
replace r`wv'cncrothr=1 if r`wv'cancre==1 & ht004fs5==1
label variable r`wv'cncrothr "r`wv'cncrothr:w`wv' r other cancer treatment"
label values r`wv'cncrothr doctor
*spouse 
gen s`wv'cncrothr=.
spouse r`wv'cncrothr, result(s`wv'cncrothr) wave(`wv')
label variable s`wv'cncrothr "s`wv'cncrothr:w`wv' s other cancer treatment"
label values s`wv'cncrothr doctor

*cancer treatment: medication
gen r`wv'cncrmeds=.
missing_lasi ht004fs4 ht004fs6 r`wv'cancre, result(r`wv'cncrmeds) wave(`wv')
replace r`wv'cncrmeds=0 if r`wv'cancre==0 | (r`wv'cancre==1 & (ht004fs4==0 | ht004fs6==1))
replace r`wv'cncrmeds=1 if r`wv'cancre==1 & ht004fs4==1
label variable r`wv'cncrmeds "r`wv'cncrmeds:w`wv' r medication cancer treatment"
label values r`wv'cncrmeds doctor
*spouse
gen s`wv'cncrmeds=.
spouse r`wv'cncrmeds, result(s`wv'cncrmeds) wave(`wv')
label variable s`wv'cncrmeds "s`wv'cncrmeds:w`wv' s medication cancer treatment"
label values s`wv'cncrmeds doctor

***taking medication for lung disease - NOT AVAILABLE
*raw var asks about receiving physical or respiratory therapy, not medication

***taking medication for heart disease
gen r`wv'rxheart=. 
missing_lasi ht006h r`wv'hearte, result(r`wv'rxheart) wave(`wv')
replace r`wv'rxheart=0 if r`wv'hearte==0 | (r`wv'hearte==1 & ht006h==2)
replace r`wv'rxheart=1 if r`wv'hearte==1 & ht006h==1
label variable r`wv'rxheart "r`wv'rxheart:w`wv' r takes meds for heart problems"
label values r`wv'rxheart doctor
*spouse
gen s`wv'rxheart=.
spouse r`wv'rxheart, result(s`wv'rxheart) wave(`wv')
label variable s`wv'rxheart "s`wv'rxheart:w`wv' s takes meds for heart problems"
label values s`wv'rxheart doctor

***taking medication for stroke 
gen r`wv'rxstrok=.
missing_lasi ht007c r`wv'stroke, result(r`wv'rxstrok) wave(`wv')
replace r`wv'rxstrok=0 if r`wv'stroke==0 | (r`wv'stroke==1 & ht007c==2)
replace r`wv'rxstrok=1 if r`wv'stroke==1 & ht007c==1
label variable r`wv'rxstrok "r`wv'rxstrok:w`wv' r takes meds for stroke"
label values r`wv'rxstrok doctor
*spouse
gen s`wv'rxstrok=.
spouse r`wv'rxstrok, result(s`wv'rxstrok) wave(`wv')
label variable s`wv'rxstrok "s`wv'rxstrok:w`wv' s takes meds for stroke"
label values s`wv'rxstrok doctor

***taking medication for osteoporosis
gen r`wv'rxosteo=.
missing_lasi ht008f ht008 ht008as1 ht008as2 ht008as3, result(r`wv'rxosteo) wave(`wv')
replace r`wv'rxosteo=.t if ht008==1 & ht008as3==1 & (ht008as1==1 | ht008as2==1 | ht008as4==1) & ht008f==1
replace r`wv'rxosteo=0 if ht008==2 | (ht008==1 & (ht008as3==0 | ht008f==2))
replace r`wv'rxosteo=1 if ht008==1 & ht008as3==1 & ht008f==1 & ht008as1==0 & ht008as2==0 & ht008as4==0
label variable r`wv'rxosteo "r`wv'rxosteo:w`wv' r takes meds for osteoporosis"
label values r`wv'rxosteo doctor
*spouse
gen s`wv'rxosteo=.
spouse r`wv'rxosteo, result(s`wv'rxosteo) wave(`wv')
label variable s`wv'rxosteo "s`wv'rxosteo:w`wv' s takes meds for osteoporosis"
label values s`wv'rxosteo doctor

***taking medication for arthritis/rheumatism
gen r`wv'rxarthr=.
missing_lasi ht008f ht008 ht008as1 ht008as2 ht008as3, result(r`wv'rxarthr) wave(`wv')
replace r`wv'rxarthr=.t if ht008==1 & (ht008as1==1 | ht008as2==1) & (ht008as3==1 | ht008as4==1) & ht008f==1
replace r`wv'rxarthr=0 if ht008==2 | (ht008==1 & (ht008as1==0 | ht008as2==0 | ht008f==2))
replace r`wv'rxarthr=1 if ht008==1 & (ht008as1==1 | ht008as2==1) & ht008f==1 & ht008as3==0 & ht008as4==0
label variable r`wv'rxarthr "r`wv'rxarthr:w`wv' r takes meds for arthritis/rheumatism"
label values r`wv'rxarthr doctor
*spouse
gen s`wv'rxarthr=.
spouse r`wv'rxarthr, result(s`wv'rxarthr) wave(`wv')
label variable s`wv'rxarthr "s`wv'rxarthr:w`wv' s takes meds for arthritis/rheumatism"
label values s`wv'rxarthr doctor

***taking medication for psychiatric problem
*code as r`wv'rxpsych, not r`wv'rxdepres bc this is any psychiatric probs
gen r`wv'rxpsych=.
missing_lasi ht009e ht009 ht009as1 ht009as2 ht009as3, result(r`wv'rxpsych) wave(`wv')
replace r`wv'rxpsych=.t if ht009==1 & (ht009as1==1 | ht009as3==1) & (ht009as2==1 | ht009as4==1 | ht009as5==1) & ht009e==1
replace r`wv'rxpsych=0 if ht009==2 | (ht009==1 & (ht009as1==0 | ht009as3==0 | ht009e==2))
replace r`wv'rxpsych=1 if ht009==1 & (ht009as1==1 | ht009as3==1) & ht009e==1 & ht009as2==0 & ht009as4==0 & ht009as5==0
label variable r`wv'rxpsych "r`wv'rxpsych:w`wv' r takes meds for psychiatric problems"
label values r`wv'rxpsych doctor
*spouse
gen s`wv'rxpsych=.
spouse r`wv'rxpsych, result(s`wv'rxpsych) wave(`wv')
label variable s`wv'rxpsych "s`wv'rxpsych:w`wv' s takes meds for psychiatric problems"
label values s`wv'rxpsych doctor

***receiving treatment for psychiatric problems
gen r`wv'trpsych=.
missing_lasi ht009d ht009 ht009as1 ht009as2 ht009as3, result(r`wv'trpsych) wave(`wv')
replace r`wv'trpsych=.t if ht009==1 & (ht009as1==1 | ht009as3==1) & (ht009as2==1 | ht009as4==1 | ht009as5==1) & ht009d==1
replace r`wv'trpsych=0 if ht009==2 | (ht009==1 & (ht009as1==0 | ht009as3==0 | ht009d==2))
replace r`wv'trpsych=1 if ht009==1 & (ht009as1==1 | ht009as3==1) & ht009d==1 & ht009as2==0 & ht009as4==0 & ht009as5==0
label variable r`wv'trpsych "r`wv'trpsych:w`wv' r receives psychological treatment"
label values r`wv'trpsych doctor
*spouse
gen s`wv'trpsych=.
spouse r`wv'trpsych, result(s`wv'trpsych) wave(`wv')
label variable s`wv'trpsych "s`wv'trpsych:w`wv' s receives psychological treatment"
label values s`wv'trpsych doctor

***taking medication for alzheimer's/dementia
gen r`wv'rxalzdem=.
missing_lasi ht009e ht009 ht009as1 ht009as2 ht009as3, result(r`wv'rxalzdem) wave(`wv')
replace r`wv'rxalzdem=.t if ht009==1 & ht009as2==1 & (ht009as1==1 | ht009as3==1 | ht009as4==1 | ht009as5==1) & ht009e==1
replace r`wv'rxalzdem=0 if ht009==2 | (ht009==1 & (ht009as2==0 | ht009e==2))
replace r`wv'rxalzdem=1 if ht009==1 & ht009as2==1 & ht009e==1 & ht009as1==0 & ht009as3==0 & ht009as4==0 & ht009as5==0
label variable r`wv'rxalzdem "r`wv'rxalzdem:w`wv' r takes meds for alzheimers/dementia"
label values r`wv'rxalzdem doctor
*spouse
gen s`wv'rxalzdem=.
spouse r`wv'rxalzdem, result(s`wv'rxalzdem) wave(`wv')
label variable s`wv'rxalzdem "s`wv'rxalzdem:w`wv' s takes meds for alzheimers/dementia"
label values s`wv'rxalzdem doctor

***receiving treatment for alzheimer's/dementia
gen r`wv'tralzdem=.
missing_lasi ht009d ht009 ht009as1 ht009as2 ht009as3, result(r`wv'tralzdem) wave(`wv')
replace r`wv'tralzdem=.t if ht009==1 & ht009as2==1 & (ht009as1==1 | ht009as3==1 | ht009as4==1 | ht009as5==1) & ht009d==1
replace r`wv'tralzdem=0 if ht009==2 | (ht009==1 & (ht009as2==0 | ht009d==2))
replace r`wv'tralzdem=1 if ht009==1 & ht009as2==1 & ht009d==1 & ht009as1==0 & ht009as3==0 & ht009as4==0 & ht009as5==0
label variable r`wv'tralzdem "r`wv'tralzdem:w`wv' r receives treatment for alzheimers/dementia"
label values r`wv'tralzdem doctor
*spouse
gen s`wv'tralzdem=.
spouse r`wv'tralzdem, result(s`wv'tralzdem) wave(`wv')
label variable s`wv'tralzdem "s`wv'tralzdem:w`wv' s receives treatment for alzheimers/dementia"
label values s`wv'tralzdem doctor

***taking medication for high cholesterol
gen r`wv'rxhchol=.
missing_lasi ht010c r`wv'hchole, result(r`wv'rxhchol) wave(`wv')
replace r`wv'rxhchol=0 if r`wv'hchole==0 | (r`wv'hchole==1 & ht010c==2)
replace r`wv'rxhchol=1 if r`wv'hchole==1 & ht010c==1
label variable r`wv'rxhchol "r`wv'rxhchol:w`wv' r takes meds for high cholesterol"
label values r`wv'rxhchol doctor
*spouse
gen s`wv'rxhchol=.
spouse r`wv'rxhchol, result(s`wv'rxhchol) wave(`wv')
label variable s`wv'rxhchol "s`wv'rxhchol:w`wv' s takes meds for high cholesterol"
label values s`wv'rxhchol doctor


***********************************************************************
***Sleep***
***********************************************************************
***Trouble falling asleep
gen r`wv'fallslp=.
missing_lasi ht219, result(r`wv'fallslp) wave(`wv')
replace r`wv'fallslp=1 if ht219==4
replace r`wv'fallslp=2 if ht219==3
replace r`wv'fallslp=3 if inlist(ht219,1,2)
label variable r`wv'fallslp "r`wv'fallslp:w`wv' r trouble falling asleep"
label values r`wv'fallslp fallslp
*spouse
gen s`wv'fallslp=.
spouse r`wv'fallslp, result(s`wv'fallslp) wave(`wv')
label variable s`wv'fallslp "s`wv'fallslp:w`wv' s trouble falling asleep"
label values s`wv'fallslp fallslp

***Waking up during night
gen r`wv'wakent=.
missing_lasi ht220, result(r`wv'wakent) wave(`wv')
replace r`wv'wakent=1 if ht220==4
replace r`wv'wakent=2 if ht220==3
replace r`wv'wakent=3 if inlist(ht220,1,2)
label variable r`wv'wakent "r`wv'wakent:w`wv' r waking up during night"
label values r`wv'wakent fallslp
*spouse
gen s`wv'wakent=.
spouse r`wv'wakent, result(s`wv'wakent) wave(`wv')
label variable s`wv'wakent "s`wv'wakent:w`wv' s waking up during night"
label values s`wv'wakent fallslp

***Waking up too early***
gen r`wv'wakeup=.
missing_lasi ht221, result(r`wv'wakeup) wave(`wv')
replace r`wv'wakeup=1 if ht221==4
replace r`wv'wakeup=2 if ht221==3
replace r`wv'wakeup=3 if inlist(ht221,1,2)
label variable r`wv'wakeup "r`wv'wakeup:w`wv' r waking up too early"
label values r`wv'wakeup fallslp
*spouse
gen s`wv'wakeup=.
spouse r`wv'wakeup, result(s`wv'wakeup) wave(`wv')
label variable s`wv'wakeup "s`wv'wakeup:w`wv' s waking up too early"
label values s`wv'wakeup fallslp

***Feels rested when wake up - NOT AVAILABLE

***Feeling UNRESTED during the day
gen r`wv'unrstd=.
missing_lasi ht222, result(r`wv'unrstd) wave(`wv')
replace r`wv'unrstd=1 if ht222==4
replace r`wv'unrstd=2 if ht222==3
replace r`wv'unrstd=3 if inlist(ht222,1,2)
label variable r`wv'unrstd "r`wv'unrstd:w`wv' r feels unrested during day"
label values r`wv'unrstd fallslp
*spouse
gen s`wv'unrstd=.
spouse r`wv'unrstd, result(s`wv'unrstd) wave(`wv')
label variable s`wv'unrstd "s`wv'unrstd:w`wv' r feels unrested during day"
label values s`wv'unrstd fallslp

***taking medication to sleep
gen r`wv'rxslp=.
missing_lasi ht223, result(r`wv'rxslp) wave(`wv')
replace r`wv'rxslp=0 if ht223==2
replace r`wv'rxslp=1 if ht223==1
label variable r`wv'rxslp "r`wv'rxslp:w`wv' r takes meds to sleep"
label values r`wv'rxslp doctor
*spouse
gen s`wv'rxslp=.
spouse r`wv'rxslp, result(s`wv'rxslp) wave(`wv')
label variable s`wv'rxslp "s`wv'rxslp:w`wv' s takes meds to sleep"
label values s`wv'rxslp doctor


***********************************************************************
***Pain***
***********************************************************************
***Frequent problems with pain
gen r`wv'painfr=.
missing_lasi ht225, result(r`wv'painfr) wave(`wv')
replace r`wv'painfr=0 if ht225==2
replace r`wv'painfr=1 if ht225==1
label variable r`wv'painfr "r`wv'painfr:w`wv' r frequent problems with pain"
label values r`wv'painfr doctor
*Spouse
gen s`wv'painfr=.
spouse r`wv'painfr, result(s`wv'painfr) wave(`wv')
label variable s`wv'painfr "s`wv'painfr:w`wv' s frequent problems with pain"
label values s`wv'painfr doctor

***Pain interferes with normal activities
gen r`wv'paina=.
missing_lasi ht225 ht228, result(r`wv'paina) wave(`wv')
replace r`wv'paina=.x if ht225==2 //does not have condition
replace r`wv'paina=0 if ht228==2
replace r`wv'paina=1 if ht228==1
label variable r`wv'paina "r`wv'paina:w`wv' r pain interferes with normal activities"
label values r`wv'paina doctor
*Spouse
gen s`wv'paina=.
spouse r`wv'paina, result(s`wv'paina) wave(`wv')
label variable s`wv'paina "s`wv'paina:w`wv' s pain interferes with normal activities"
label values s`wv'paina doctor

***taking medication for pain
*ht227s1 (analgesics, oral/injectable), ht227s2 (therapy), ht227s3 (local/external application ie ointment)
gen r`wv'rxpain=.
missing_lasi ht227s1 ht225 ht227s4, result(r`wv'rxpain) wave(`wv')
replace r`wv'rxpain=0 if ht225==2 | (ht225==1 & (ht227s1==0 | ht227s4==1))
replace r`wv'rxpain=1 if ht225==1 & ht227s1==1
label variable r`wv'rxpain "r`wv'rxpain:w`wv' r takes meds for pain"
label values r`wv'rxpain doctor
*spouse
gen s`wv'rxpain=.
spouse r`wv'rxpain, result(s`wv'rxpain) wave(`wv')
label variable s`wv'rxpain "s`wv'rxpain:w`wv' s takes meds for pain"
label values s`wv'rxpain doctor

***Pain frequency
*NOTE: there is n=1 where ht225==2 but answered ht226. ht226 should be asked only if ht225==1
gen r`wv'painfrq=.
missing_lasi ht225 ht226, result(r`wv'painfrq) wave(`wv')
replace r`wv'painfrq=.x if ht225==2
replace r`wv'painfrq=1 if ht225==1 & ht226==3 //frequently (5 or more days per week)
replace r`wv'painfrq=2 if ht225==1 & ht226==2 //occasionally (3-4 day sper week)
replace r`wv'painfrq=3 if ht225==1 & ht226==1 //rarely (1-2 days per week)
label variable r`wv'painfrq "r`wv'painfrq:w`wv' r frequency experiences pain"
label values r`wv'painfrq painfrq
*spouse
gen s`wv'painfrq=.
spouse r`wv'painfrq, result(s`wv'painfrq) wave(`wv')
label variable s`wv'painfrq "s`wv'painfrq:w`wv' s frequency experiences pain"
label values s`wv'painfrq painfrq


**************************************************************************
***Additional ever diagnosed conditions***
**************************************************************************
***Diagnosed with asthma
gen r`wv'asthmae=.
missing_lasi ht005 ht005ds3, result(r`wv'asthmae) wave(`wv')
replace r`wv'asthmae=0 if ht005==2 | (ht005==1 & ht005ds3==0)
replace r`wv'asthmae=1 if ht005==1 & ht005ds3==1
label variable r`wv'asthmae "r`wv'asthmae:w`wv' r ever had asthma"
label values r`wv'asthmae doctor
*spouse
gen s`wv'asthmae=.
spouse r`wv'asthmae, result(s`wv'asthmae) wave(`wv')
label variable s`wv'asthmae "s`wv'asthmae:w`wv' s ever had asthma"
label values s`wv'asthmae doctor

***Diagnosed with congestive heart failure
gen r`wv'conhrtfe=.
missing_lasi ht006 ht006fs4, result(r`wv'conhrtfe) wave(`wv')
replace r`wv'conhrtfe=0 if ht006==2 | (ht006==1 & ht006fs4==0)
replace r`wv'conhrtfe=1 if ht006==1 & ht006fs4==1
label variable r`wv'conhrtfe "r`wv'conhrtfe:w`wv' r ever had congestive heart failure"
label values r`wv'conhrtfe doctor
*spouse
gen s`wv'conhrtfe=.
spouse r`wv'conhrtfe, result(s`wv'conhrtfe) wave(`wv')
label variable s`wv'conhrtfe "s`wv'conhrtfe:w`wv' s ever had congestive heart failure"
label values s`wv'conhrtfe doctor

***Doctor diagnosis: Ever diagnosed osteoporosis
gen r`wv'osteoe=.
missing_lasi ht008 ht008as3, result(r`wv'osteoe) wave(`wv')
replace r`wv'osteoe=0 if ht008==2 | (ht008==1 & ht008as3==0)
replace r`wv'osteoe=1 if ht008==1 & ht008as3==1
label variable r`wv'osteoe "r`wv'osteoe:w`wv' r ever had osteoporosis"
label values r`wv'osteoe doctor
*spouse
gen s`wv'osteoe=.
spouse r`wv'osteoe, result(s`wv'osteoe) wave(`wv')
label variable s`wv'osteoe "s`wv'osteoe:w`wv' s ever had osteoporosis"
label values s`wv'osteoe doctor
 
***Ever diagnosed thyroid disorder
gen r`wv'thyroide=.
missing_lasi ht011s1, result(r`wv'thyroide) wave(`wv')
replace r`wv'thyroide=0 if ht011s1==0
replace r`wv'thyroide=1 if ht011s1==1
label variable r`wv'thyroide "r`wv'thyroide:w`wv' r ever had thyroid disorder"
label values r`wv'thyroide doctor
*spouse
gen s`wv'thyroide=.
spouse r`wv'thyroide, result(s`wv'thyroide) wave(`wv')
label variable s`wv'thyroide "s`wv'thyroide:w`wv' s ever had thyroid disorder"
label values s`wv'thyroide doctor

***Ever diagnosed gastrointestinal problems
gen r`wv'gstroine=.
missing_lasi ht011s2, result(r`wv'gstroine) wave(`wv')
replace r`wv'gstroine=0 if ht011s2==0
replace r`wv'gstroine=1 if ht011s2==1
label variable r`wv'gstroine "r`wv'gstroine:w`wv' r ever had gastrointestinal problems"
label values r`wv'gstroine doctor
*spouse
gen s`wv'gstroine=.
spouse r`wv'gstroine, result(s`wv'gstroine) wave(`wv')
label variable s`wv'gstroine "s`wv'gstroine:w`wv' s ever had gastrointestinal problems"
label values s`wv'gstroine doctor

***Ever diagnosed skin diseases
gen r`wv'skindise=.
missing_lasi ht011s3, result(r`wv'skindise) wave(`wv')
replace r`wv'skindise=0 if ht011s3==0
replace r`wv'skindise=1 if ht011s3==1
label variable r`wv'skindise "r`wv'skindise:w`wv' r ever had skin diseases"
label values r`wv'skindise doctor
*spouse
gen s`wv'skindise=.
spouse r`wv'skindise, result(s`wv'skindise) wave(`wv')
label variable s`wv'skindise "s`wv'skindise:w`wv' s ever had skin diseases"
label values s`wv'skindise doctor

***Ever had kidney stones
gen r`wv'kidstne=.
missing_lasi ht012s3, result(r`wv'kidstne) wave(`wv')
replace r`wv'kidstne=0 if ht012s3==0
replace r`wv'kidstne=1 if ht012s3==1
label variable r`wv'kidstne "r`wv'kidstne:w`wv' r ever had kidney stones"
label values r`wv'kidstne doctor
*spouse
gen s`wv'kidstne=.
spouse r`wv'kidstne, result(s`wv'kidstne) wave(`wv')
label variable s`wv'kidstne "s`wv'kidstne:w`wv' s ever had kidney stones"
label values s`wv'kidstne doctor

***Diagnosed with Presbyopia
gen r`wv'prsbype=.
missing_lasi ht017s1 ht015, result(r`wv'prsbype) wave(`wv')
replace r`wv'prsbype=0 if ht015==2 | (ht015==1 & ht017s1==0)
replace r`wv'prsbype=1 if ht015==1 & ht017s1==1
label variable r`wv'prsbype "r`wv'prsbype:w`wv' r ever had presbyopia"
label values r`wv'prsbype doctor
*spouse
gen s`wv'prsbype=.
spouse r`wv'prsbype, result(s`wv'prsbype) wave(`wv')
label variable s`wv'prsbype "s`wv'prsbype:w`wv' s ever had presbyopia"
label values s`wv'prsbype doctor

***Diagnosed with cataracts
gen r`wv'catracte=.
missing_lasi ht017s2 ht015, result(r`wv'catracte) wave(`wv')
replace r`wv'catracte=0 if ht015==2 | (ht015==1 & ht017s2==0)
replace r`wv'catracte=1 if ht015==1 & ht017s2==1
label variable r`wv'catracte "r`wv'catracte:w`wv' r ever had cataracts"
label values r`wv'catracte doctor
*spouse
gen s`wv'catracte=.
spouse r`wv'catracte, result(s`wv'catracte) wave(`wv')
label variable s`wv'catracte "s`wv'catracte:w`wv' s ever had cataracts"
label values s`wv'catracte doctor

***Diagnosed with glaucoma
*Different from treated for glaucoma (r`wv'glaucoma)
gen r`wv'glaucome=.
missing_lasi ht017s3 ht015, result(r`wv'glaucome) wave(`wv')
replace r`wv'glaucome=0 if ht015==2 | (ht015==1 & ht017s3==0)
replace r`wv'glaucome=1 if ht015==1 & ht017s3==1
label variable r`wv'glaucome "r`wv'glaucome:w`wv' r ever had glaucoma"
label values r`wv'glaucome doctor
*spouse
gen s`wv'glaucome=.
spouse r`wv'glaucome, result(s`wv'glaucome) wave(`wv')
label variable s`wv'glaucome "s`wv'glaucome:w`wv' s ever had glaucoma"
label values s`wv'glaucome doctor

***Diagnosed with myopia
gen r`wv'myopiae=.
missing_lasi ht017s4 ht015, result(r`wv'myopiae) wave(`wv')
replace r`wv'myopiae=0 if ht015==2 | (ht015==1 & ht017s4==0)
replace r`wv'myopiae=1 if ht015==1 & ht017s4==1
label variable r`wv'myopiae "r`wv'myopiae:w`wv' r ever had myopia"
label values r`wv'myopiae doctor
*spouse
gen s`wv'myopiae=.
spouse r`wv'myopiae, result(s`wv'myopiae) wave(`wv')
label variable s`wv'myopiae "s`wv'myopiae:w`wv' s ever had myopia"
label values s`wv'myopiae doctor

***Diagnosed with hypermetropia
gen r`wv'hyprmtpe=.
missing_lasi ht017s5 ht015, result(r`wv'hyprmtpe) wave(`wv')
replace r`wv'hyprmtpe=0 if ht015==2 | (ht015==1 & ht017s5==0)
replace r`wv'hyprmtpe=1 if ht015==1 & ht017s5==1
label variable r`wv'hyprmtpe "r`wv'hyprmtpe:w`wv' r ever had hypermetropia"
label values r`wv'hyprmtpe doctor
*spouse
gen s`wv'hyprmtpe=.
spouse r`wv'hyprmtpe, result(s`wv'hyprmtpe) wave(`wv')
label variable s`wv'hyprmtpe "s`wv'hyprmtpe:w`wv' s ever had hypermetropia"
label values s`wv'hyprmtpe doctor

***Ever had cataract surgery - NOT AVAILABLE

***Ever been diagnosed: Dental Cavity / Dental Caries
gen r`wv'dntlcvte=.
missing_lasi ht024s6, result(r`wv'dntlcvte) wave(`wv')
replace r`wv'dntlcvte=0 if ht024s6==0
replace r`wv'dntlcvte=1 if ht024s6==1
label variable r`wv'dntlcvte "r`wv'dntlcvte:w`wv' r ever had dental cavities/dental caries"
label values r`wv'dntlcvte doctor
*spouse
gen s`wv'dntlcvte=.
spouse r`wv'dntlcvte, result(s`wv'dntlcvte) wave(`wv')
label variable s`wv'dntlcvte "s`wv'dntlcvte:w`wv' s ever had dental cavities/dental caries"
label values s`wv'dntlcvte doctor

***Ever been diagnosed with peridontal disease (bleeding gums, swelling gums, ulcers lasting more than 2 weeks)
gen r`wv'perdntle=.
missing_lasi ht024s2 ht024s3 ht024s4, result(r`wv'perdntle) wave(`wv')
replace r`wv'perdntle=0 if ht024s2==0 | ht024s3==0 | ht024s4==0
replace r`wv'perdntle=1 if ht024s2==1 | ht024s3==1 | ht024s4==1
label variable r`wv'perdntle "r`wv'perdntle:w`wv' r ever had periodontal disease"
label values r`wv'perdntle doctor
*spouse
gen s`wv'perdntle=.
spouse r`wv'perdntle, result(s`wv'perdntle) wave(`wv')
label variable s`wv'perdntle "s`wv'perdntle:w`wv' s ever had periodontal disease"
label values s`wv'perdntle doctor

***ever had heart attack
gen r`wv'hrtatte=.
missing_lasi ht006a r`wv'hearte, result(r`wv'hrtatte) wave(`wv')
replace r`wv'hrtatte=0 if r`wv'hearte==0 | (r`wv'hearte==1 & ht006a==2)
replace r`wv'hrtatte=1 if r`wv'hearte==1 & ht006a==1
label variable r`wv'hrtatte "r`wv'hrtatte:w`wv' r ever had heart attack"
label values r`wv'hrtatte doctor
*spouse
gen s`wv'hrtatte=.
spouse r`wv'hrtatte, result(s`wv'hrtatte) wave(`wv')
label variable s`wv'hrtatte "s`wv'hrtatte:w`wv' s ever had heart attack"
label values s`wv'hrtatte doctor

***ever had abnormal heart rhythm
gen r`wv'hrtrhme=.
missing_lasi ht006fs3 r`wv'hearte, result(r`wv'hrtrhme) wave(`wv')
replace r`wv'hrtrhme=0 if r`wv'hearte==0 | (r`wv'hearte==1 & ht006fs3==0)
replace r`wv'hrtrhme=1 if r`wv'hearte==1 & ht006fs3==1
label variable r`wv'hrtrhme "r`wv'hrtrhme:w`wv' r ever had abnormal heart rhythm"
label values r`wv'hrtrhme doctor
*spouse
gen s`wv'hrtrhme=.
spouse r`wv'hrtrhme, result(s`wv'hrtrhme) wave(`wv')
label variable s`wv'hrtrhme "s`wv'hrtrhme:w`wv' s ever had abnormal heart rhythm"
label values s`wv'hrtrhme doctor


******************************************************************
***Diagnosed last 2 years***
******************************************************************
***Heart attack - diagnosed last two years
gen r`wv'hrtatt=.
missing_lasi ht006g r`wv'hrtatte, result(r`wv'hrtatt) wave(`wv')
replace r`wv'hrtatt=0 if r`wv'hrtatte==0 | (r`wv'hrtatte==1 & ht006g==2)
replace r`wv'hrtatt=0 if (r`wv'agey - ht006b_age > 2) & mi(ht006g) & !mi(r`wv'agey) & !mi(ht006b_age)
replace r`wv'hrtatt=1 if r`wv'hrtatte==1 & ht006g==1
replace r`wv'hrtatt=1 if (r`wv'agey - ht006b_age <= 2) & mi(ht006g) & !mi(r`wv'agey) & !mi(ht006b_age)
label variable r`wv'hrtatt "r`wv'hrtatt:w`wv' r had heart attack last 2 years"
label values r`wv'hrtatt doctor
*spouse
gen s`wv'hrtatt=.
spouse r`wv'hrtatt, result(s`wv'hrtatt) wave(`wv')
label variable s`wv'hrtatt "s`wv'hrtatt:w`wv' s had heart attack last 2 years"
label values s`wv'hrtatt doctor


******************************************************************
***Age when diagnosed***
******************************************************************
***Age first diagnosed with hibp
gen radiaghibp=.
missing_lasi ht002b_age ht002b_year r`wv'hibpe, result(radiaghibp) wave(`wv')
replace radiaghibp = .x if r`wv'hibpe==0
replace radiaghibp = ht002b_age if inrange(ht002b_age,5,93)
replace radiaghibp = ht002b_year - rabyear if inrange(ht002b_year,1959,2021) & !mi(rabyear)
replace radiaghibp = .i if (radiaghibp > r`wv'agey) & !mi(radiaghibp)
label variable radiaghibp "radiaghibp: r age first diagnosed with high blood pressure"
*spouse
gen s`wv'diaghibp=.
spouse radiaghibp, result(s`wv'diaghibp) wave(`wv')
label variable s`wv'diaghibp "s`wv'diaghibp:w`wv' s age first diagnosed with high blood pressure"

***Age first diagnosed with diabetes
gen radiagdiab=.
missing_lasi ht003b_age ht003b_year r`wv'diabe , result(radiagdiab) wave(`wv')
replace radiagdiab = .x if r`wv'diabe==0
replace radiagdiab = ht003b_age if inrange(ht003b_age,6,85)
replace radiagdiab = ht003b_year - rabyear if inrange(ht003b_year,1957,2021) & !mi(rabyear)
replace radiagdiab = .i if (radiagdiab > r`wv'agey) & !mi(radiagdiab)
label variable radiagdiab "radiagdiab: r age first diagnosed with diabetes"
*spouse
gen s`wv'diagdiab=.
spouse radiagdiab, result(s`wv'diagdiab) wave(`wv')
label variable s`wv'diagdiab "s`wv'diagdiab:w`wv' s age first diagnosed with diabetes"

***Age first diagnosed with cancer
gen radiagcancr=.
missing_lasi ht004b_age ht004b_year r`wv'cancre, result(radiagcancr) wave(`wv')
replace radiagcancr = .x if r`wv'cancre==0
replace radiagcancr = ht004b_age if inrange(ht004b_age,20,72)
replace radiagcancr = ht004b_year - rabyear if inrange(ht004b_year,1970,2019) & !mi(rabyear)
replace radiagcancr = .i if (radiagcancr > r`wv'agey) & !mi(radiagcancr)
label variable radiagcancr "radiagcancr: r age first diagnosed with cancer"
*spouse
gen s`wv'diagcancr=.
spouse radiagcancr, result(s`wv'diagcancr) wave(`wv')
label variable s`wv'diagcancr "s`wv'diagcancr:w`wv' s age first diagnosed with cancer"

***Age first diagnosed with lung disease (includes asthma)
gen radiagresp=.
missing_lasi ht005b_age ht005b_year r`wv'lunge r`wv'asthmae, result(radiagresp) wave(`wv')
replace radiagresp = .x if r`wv'lunge==0 | r`wv'asthmae==0
replace radiagresp = ht005b_age if inrange(ht005b_age,1,85)
replace radiagresp = ht005b_year - rabyear if inrange(ht005b_year,1948,2021) & !mi(rabyear)
replace radiagresp = .i if (radiagresp > r`wv'agey) & !mi(radiagresp)
label variable radiagresp "radiagresp: r age first diagnosed with lung disease or asthma"
*spouse
gen s`wv'diagresp=.
spouse radiagresp, result(s`wv'diagresp) wave(`wv')
label variable s`wv'diagresp "s`wv'diagresp:w`wv' s age first diagnosed with lung disease or asthma"

***Age first diagnosed with first heart attack
gen rafrhrtatt=.
missing_lasi ht006b_age ht006b_year r`wv'hrtatte, result(rafrhrtatt) wave(`wv')
replace rafrhrtatt = .x if r`wv'hrtatte==0
replace rafrhrtatt = ht006b_age if inrange(ht006b_age,25,80)
replace rafrhrtatt = ht006b_year - rabyear if inrange(ht006b_year,1983,2020) & !mi(rabyear)
replace rafrhrtatt = .i if (rafrhrtatt > r`wv'agey) & !mi(rafrhrtatt)
label variable rafrhrtatt "rafrhrtatt: r age first diagnosed with first heart attack"
*spouse
gen s`wv'frhrtatt=.
spouse rafrhrtatt, result(s`wv'frhrtatt) wave(`wv')
label variable s`wv'frhrtatt "s`wv'frhrtatt:w`wv' s age first diagnosed with first heart attack"

***Age first diagnosed with heart problem
gen radiagheart=.
missing_lasi ht006d_age ht006d_year r`wv'hearte, result(radiagheart) wave(`wv')
replace radiagheart = .x if r`wv'hearte==0 
replace radiagheart = rafrhrtatt if !mi(rafrhrtatt)
replace radiagheart = ht006d_age if inrange(ht006d_age,1,85)
replace radiagheart = ht006d_year - rabyear if inrange(ht006d_year,1956,2021) & !mi(rabyear)
replace radiagheart = .i if (radiagheart > r`wv'agey) & !mi(radiagheart)
label variable radiagheart "radiagheart: r age first diagnosed with heart problem"
*spouse
gen s`wv'diagheart=.
spouse radiagheart, result(s`wv'diagheart) wave(`wv')
label variable s`wv'diagheart "s`wv'diagheart:w`wv' s age first diagnosed with heart problem"

***Age first diagnosed with stroke
gen radiagstrok=.
missing_lasi ht007b_age ht007b_year r`wv'stroke, result(radiagstrok) wave(`wv')
replace radiagstrok = .x if r`wv'stroke==0
replace radiagstrok = ht007b_age if inrange(ht007b_age,29,79)
replace radiagstrok = ht007b_year - rabyear if inrange(ht007b_year,1980,2019) & !mi(rabyear)
replace radiagstrok = .i if (radiagstrok > r`wv'agey) & !mi(radiagstrok)
label variable radiagstrok "radiagstrok: r age first diagnosed with stroke"
*spouse
gen s`wv'diagstrok=.
spouse radiagstrok, result(s`wv'diagstrok) wave(`wv')
label variable s`wv'diagstrok "s`wv'diagstrok:w`wv' s age first diagnosed with stroke"

***Age first diagnosed with arthritis
gen radiagarthr=.
missing_lasi ht008c_age ht008c_year r`wv'arthre, result(radiagarthr) wave(`wv')
replace radiagarthr = .x if r`wv'arthre==0
replace radiagarthr = ht008c_age if inrange(ht008c_age,10,89)
replace radiagarthr = ht008c_year - rabyear if inrange(ht008c_year,1950,2021) & !mi(rabyear)
replace radiagarthr = .i if (radiagarthr > r`wv'agey) & !mi(radiagarthr)
label variable radiagarthr "radiagarthr: r age first diagnosed with arthritis"
*spouse
gen s`wv'diagarthr=.
spouse radiagarthr, result(s`wv'diagarthr) wave(`wv')
label variable s`wv'diagarthr "s`wv'diagarthr:w`wv' s age first diagnosed with arthritis"

***Age first diagnosed with osteoporosis
gen radiagosteo=.
missing_lasi ht008e_age ht008e_year r`wv'osteoe, result(radiagosteo) wave(`wv')
replace radiagosteo = .x if r`wv'osteoe==0
replace radiagosteo = ht008e_age if inrange(ht008e_age,30,84)
replace radiagosteo = ht008e_year - rabyear if inrange(ht008e_year,1960,2020) & !mi(rabyear)
replace radiagosteo = .i if (radiagosteo > r`wv'agey) & !mi(radiagosteo)
label variable radiagosteo "radiagosteo: r age first diagnosed with osteoporosis"
*spouse
gen s`wv'diagosteo=.
spouse radiagosteo, result(s`wv'diagosteo) wave(`wv')
label variable s`wv'diagosteo "s`wv'diagosteo:w`wv' s age first diagnosed with osteoporosis"

***Age first diagnosed with psychiatric problems
*Note: one question asked for all neurological & psychiatric conditons. Look at how rxpsych is coded
gen radiagpsych=.
missing_lasi ht009c_age ht009c_year r`wv'psyche, result(radiagpsych) wave(`wv')
replace radiagpsych = .x if r`wv'psyche==0
replace radiagpsych = .t if ht009==1 & (ht009as1==1 | ht009as3==1) & (ht009as2==1 | ht009as4==1 | ht009as5==1) 
*& (!mi(ht009c_age) | !mi(ht009c_year))
replace radiagpsych = ht009c_age if inrange(ht009c_age,0,80) & (ht009==1 & (ht009as1==1 | ht009as3==1)) & ht009as2==0 & ht009as4==0 & ht009as5==0
replace radiagpsych = ht009c_year - rabyear if inrange(ht009c_year,1956,2019) & (ht009==1 & (ht009as1==1 | ht009as3==1)) & ht009as2==0 & ht009as4==0 & ht009as5==0 & !mi(rabyear)
replace radiagpsych = .i if (radiagpsych > r`wv'agey) & !mi(radiagpsych)
label variable radiagpsych "radiagpsych: r age first diagnosed with psychiatric problem"
*spouse
gen s`wv'diagpsych=.
spouse radiagpsych, result(s`wv'diagpsych) wave(`wv')
label variable s`wv'diagpsych "s`wv'diagpsych:w`wv' s age first diagnosed with psychiatric problem"

***Age first diagnosed with alzheimer's 
*Note: one question asked for all neurological & psychiatric conditions. Look at how rxalzdem is coded 
gen radiagalzdem=.
missing_lasi ht009c_age ht009c_year r`wv'alzdeme, result(radiagalzdem) wave(`wv')
replace radiagalzdem = .x if r`wv'alzdeme==0
replace radiagalzdem = .t if ht009==1 & ht009as2==1 & (ht009as1==1 | ht009as3==1 | ht009as4==1 | ht009as5==1) 
*& (!mi(ht009c_age) | !mi(ht009c_year))
replace radiagalzdem = ht009c_age if inrange(ht009c_age,0,80) & (ht009==1 & ht009as2==1) & ht009as1==0 & ht009as3==0 & ht009as4==0 & ht009as5==0
replace radiagalzdem = ht009c_year - rabyear if inrange(ht009c_year,1956,2019) & (ht009==1 & ht009as2==1) & ht009as1==0 & ht009as3==0 & ht009as4==0 & ht009as5==0 & !mi(rabyear)
replace radiagalzdem = .i if (radiagalzdem > r`wv'agey) & !mi(radiagalzdem)
label variable radiagalzdem "radiagalzdem: r age first diagnosed with alzheimer's/dementia"
*spouse
gen s`wv'diagalzdem=.
spouse radiagalzdem, result(s`wv'diagalzdem) wave(`wv')
label variable s`wv'diagalzdem "s`wv'diagalzdem:w`wv' s age first diagnosed with alzheimer's/dementia"

***Age first diagnosed with high cholesterol
gen radiaghchol=.
missing_lasi ht010b_age ht010b_year r`wv'hchole, result(radiaghchol) wave(`wv')
replace radiaghchol = .x if r`wv'hchole==0
replace radiaghchol = ht010b_age if inrange(ht010b_age,30,79)
replace radiaghchol = ht010b_year - rabyear if inrange(ht010b_year,1978,2019) & !mi(rabyear)
replace radiaghchol = .i if (radiaghchol > r`wv'agey) & !mi(radiaghchol)
label variable radiaghchol "radiaghchol: r age first diagnosed with high cholesterol"
*spouse
gen s`wv'diaghchol=.
spouse radiaghchol, result(s`wv'diaghchol) wave(`wv')
label variable s`wv'diaghchol "s`wv'diaghchol:w`wv' s age first diagnosed with high cholesterol"


******************************************************************
***Incontinence***
******************************************************************
***Whether any urinary incontinence
*Questionnaire asks "ever been diagnosed with"; differs from HRS
gen r`wv'urinae=.
missing_lasi ht012s2, result(r`wv'urinae) wave(`wv')
replace r`wv'urinae=0 if ht012s2==0
replace r`wv'urinae=1 if ht012s2==1
label variable r`wv'urinae "r`wv'urinae:w`wv' r ever diagnosed with urinary incontinence"
label values r`wv'urinae doctor
*spouse
gen s`wv'urinae=.
spouse r`wv'urinae, result(s`wv'urinae) wave(`wv')
label variable s`wv'urinae "s`wv'urinae:w`wv' s ever diagnosed with urinary incontinence"
label values s`wv'urinae doctor

***Ever leak urine when coughing/sneezing/laughing/lifting heavy objects
*r`wv'urincgh in HRS & ELSA: 1.most of the time, 2.some of the time, 3.rarely/never
*In LASI, responses are yes or no
gen r`wv'urincgh_l=.
missing_lasi ht014, result(r`wv'urincgh_l) wave(`wv')
replace r`wv'urincgh_l=0 if ht014==2
replace r`wv'urincgh_l=1 if ht014==1
label variable r`wv'urincgh_l "r`wv'urincgh_l:w`wv' r leaks urine when coughing"
label values r`wv'urincgh_l doctor
*spouse
gen s`wv'urincgh_l=.
spouse r`wv'urincgh_l, result(s`wv'urincgh_l) wave(`wv')
label variable s`wv'urincgh_l "s`wv'urincgh_l:w`wv' s leaks urine when coughing"
label values s`wv'urincgh_l doctor


*******************************************************************
***Eyesight***
*******************************************************************
***Self-rated eyesight - NOT AVAILABLE

***Self-rated distance eyesight
*Categories differ from HRS & ELSA: Alternative scheme used (V good to V poor)
gen r`wv'dsighta=.
missing_lasi ht019, result(r`wv'dsighta) wave(`wv')
replace r`wv'dsighta=ht019 if inrange(ht019,1,5)
label variable r`wv'dsighta "r`wv'dsighta:w`wv' r self-rated distance eyesight"
label values r`wv'dsighta health_alt
*spouse
gen s`wv'dsighta=.
spouse r`wv'dsighta, result(s`wv'dsighta) wave(`wv')
label variable s`wv'dsighta "s`wv'dsighta:w`wv' s self-rated distance eyesight"
label values s`wv'dsighta health_alt

***Self-rated near eyesight
gen r`wv'nsighta=.
missing_lasi ht020, result(r`wv'nsighta) wave(`wv')
replace r`wv'nsighta=ht020 if inrange(ht020,1,5)
label variable r`wv'nsighta "r`wv'nsighta:w`wv' r self-rated near eyesight"
label values r`wv'nsighta health_alt
*spouse
gen s`wv'nsighta=.
spouse r`wv'nsighta, result(s`wv'nsighta) wave(`wv')
label variable s`wv'nsighta "s`wv'nsighta:w`wv' s self-rated near eyesight"
label values s`wv'nsighta health_alt

***Wear spectacles/contact lenses
*Code those who were not asked (responded no to ht414) as 0
gen r`wv'glasses=.
missing_lasi ht416, result(r`wv'glasses) wave(`wv')
replace r`wv'glasses=0 if ht414==2 | ht416==2
replace r`wv'glasses=1 if ht416==1
label variable r`wv'glasses "r`wv'glasses:w`wv' r wears spectacles/contact lenses"
label values r`wv'glasses doctoraids
*Spouse
gen s`wv'glasses=.
spouse r`wv'glasses, result(s`wv'glasses) wave(`wv')
label variable s`wv'glasses "s`wv'glasses:w`wv' s wears spectacles/contact lenses"
label values s`wv'glasses doctoraids

***Ever had cataract surgey
*create intermediate variable for cataract responses in ht018_other
*NOTE: some who answer "no" to ht018 responded with "CATARACT" or "cataract" to ht018_other 
gen catrct=.
replace catrct=.m if inlist(ht018_other,".e","",".")
replace catrct=.d if ht018_other==".d"
replace catrct=0 if catrct==. & inw`wv'==1
replace catrct=1 if ht018_other=="CATARACT" | ht018_other=="cataract"

gen r`wv'catrcte=.
missing_lasi catrct r`wv'catracte, result(r`wv'catrcte) wave(`wv')
replace r`wv'catrcte = .x if r`wv'catracte==0
replace r`wv'catrcte = 0 if r`wv'catracte==1 & catrct==0
replace r`wv'catrcte = 1 if r`wv'catracte==1 & catrct==1
label variable r`wv'catrcte "r`wv'catrcte:w`wv' r ever had cataract surgery"
label values r`wv'catrcte doctor
*spouse
gen s`wv'catrcte=.
spouse r`wv'catrcte, result(s`wv'catrcte) wave(`wv')
label variable s`wv'catrcte "s`wv'catrcte:w`wv' s ever had cataract surgery"
label values s`wv'catrcte doctor

drop catrct

***Ever had glaucoma surgery
*create intermediate variable for glaucoma responses in ht018_other
gen glauc=.
replace glauc=.m if inlist(ht018_other,".e","",".")
replace glauc=.d if ht018_other==".d"
replace glauc=0 if glauc==. & inw`wv'==1
replace glauc=1 if ht018_other=="glaucoma"

gen r`wv'glaucoma=.
missing_lasi glauc r`wv'glaucome, result(r`wv'glaucoma) wave(`wv')
replace r`wv'glaucoma = .x if r`wv'glaucome==0
replace r`wv'glaucoma = 0 if r`wv'glaucome==1 & glauc==0
replace r`wv'glaucoma = 1 if r`wv'glaucome==1 & glauc==1
label variable r`wv'glaucoma "r`wv'glaucoma:w`wv' r treated for glaucoma"
label values r`wv'glaucoma doctor
*spouse
gen s`wv'glaucoma=.
spouse r`wv'glaucoma, result(s`wv'glaucoma) wave(`wv')
label variable s`wv'glaucoma "s`wv'glaucoma:w`wv' s treated for glaucoma"
label values s`wv'glaucoma doctor

drop glauc 


*************************************************************************
***Hearing***
*************************************************************************
***Rate hearing - NOT AVAILABLE

***Wear hearing aid
*Code those who were not asked (responded no to ht414) as 0
gen r`wv'hearaid=.
missing_lasi ht415, result(r`wv'hearaid) wave(`wv')
replace r`wv'hearaid=0 if ht414==2 | ht415==2
replace r`wv'hearaid=1 if ht415==1
label variable r`wv'hearaid "r`wv'hearaid:w`wv' r wears hearing aid"
label values r`wv'hearaid doctoraids
*Spouse
gen s`wv'hearaid=.
spouse r`wv'hearaid, result(s`wv'hearaid) wave(`wv')
label variable s`wv'hearaid "s`wv'hearaid:w`wv' s wears hearing aid"
label values s`wv'hearaid doctoraids

***Ever been diagnosed with hearing or ear-related problem/condition - LASI only
gen r`wv'hearcnde=.
missing_lasi ht021, result(r`wv'hearcnde) wave(`wv')
replace r`wv'hearcnde=0 if ht021==2
replace r`wv'hearcnde=1 if ht021==1
label variable r`wv'hearcnde "r`wv'hearcnde:w`wv' r ever had hearing/ear-related problem/condition"
label values r`wv'hearcnde doctor
*spouse
gen s`wv'hearcnde=.
spouse r`wv'hearcnde, result(s`wv'hearcnde) wave(`wv')
label variable s`wv'hearcnde "s`wv'hearcnde:w`wv' s ever had hearing/ear-related problem/condition"
label values s`wv'hearcnde doctor


*************************************************************************
***Dental / Oral Health***
*************************************************************************
***Self report dental health - NOT AVAILABLE

***Lost all natural teeth 
*ELSA: No if both natural teeth + dentures or only natural; Yes if no natural teeth/dentures only or neither natural or dentures
gen r`wv'noteeth=.
missing_lasi ht025, result(r`wv'noteeth) wave(`wv')
replace r`wv'noteeth=0 if inrange(ht025,2,3)
replace r`wv'noteeth=1 if ht025==1
label variable r`wv'noteeth "r`wv'noteeth:w`wv' r lost all teeth"
label values r`wv'noteeth doctor
*spouse
gen s`wv'noteeth=.
spouse r`wv'noteeth, result(s`wv'noteeth) wave(`wv')
label variable s`wv'noteeth "s`wv'noteeth:w`wv' s lost all teeth"
label values s`wv'noteeth doctor

***Wear dentures 
*Code those who were not asked (responded no to ht414) as 0
gen r`wv'denture=.
missing_lasi ht417, result(r`wv'denture) wave(`wv')
replace r`wv'denture=0 if ht414==2 | ht417==2
replace r`wv'denture=1 if ht417==1
label variable r`wv'denture "r`wv'denture:w`wv' r wears dentures"
label values r`wv'denture doctoraids
*spouse
gen s`wv'denture=.
spouse r`wv'denture, result(s`wv'denture) wave(`wv')
label variable s`wv'denture "s`wv'denture:w`wv' s wears dentures"
label values s`wv'denture doctoraids


*********************************************************************
***Injury/Falls***
*********************************************************************
***Whether fallen down in last 2 years
*Ask only if ht102as7 (falls) does not equal to 1; coded as .s
gen r`wv'fall=.
missing_lasi ht101 ht102as7 ht103, result(r`wv'fall) wave(`wv')
*replace r`wv'fall=.s if ht102as7==1
replace r`wv'fall=0 if ht103==2
replace r`wv'fall=1 if ht103==1 | (ht101==1 & ht102as7==1)
label variable r`wv'fall "r`wv'fall:w`wv' r fallen down last 2 years"
label values r`wv'fall doctor
*spouse
gen s`wv'fall=.
spouse r`wv'fall, result(s`wv'fall) wave(`wv')
label variable s`wv'fall "s`wv'fall:w`wv' s fallen down last 2 years"
label values s`wv'fall doctor

***Whether injured from fall
*ht103b is asked only if ht102as7==1 or ht103==1; coded as .s
gen r`wv'fallinj=.
missing_lasi ht101 ht102 ht103b ht103 ht102as7, result(r`wv'fallinj) wave(`wv')
*replace r`wv'fallinj=.s if ht102as7==1 | ht103==2
*replace r`wv'fallinj=0 if ht103b==2 | (ht103b==1 & (ht102as7==0 | ht103==2))
*replace r`wv'fallinj=1 if ht103b==1 & (ht102as7==1 | ht103==1)
replace r`wv'fallinj=.x if ht103==2
replace r`wv'fallinj=0 if (ht103b==2 & ht103==1) | (ht101==1 & ht102as7==1 & (ht102==2 | ht103b==2))
replace r`wv'fallinj=1 if (ht103b==1 & ht103==1) | (ht101==1 & ht102as7==1 & (ht102==1 | ht103b==1))
label variable r`wv'fallinj "r`wv'fallinj:w`wv' r injured from fall"
label values r`wv'fallinj doctor

*spouse
gen s`wv'fallinj=.
spouse r`wv'fallinj, result(s`wv'fallinj) wave(`wv')
label variable s`wv'fallinj "s`wv'fallinj:w`wv' s injured from fall"
label values s`wv'fallinj doctor

***Number of falls
*Ask if ht102as7 (falls)=1 or ht103==1
gen r`wv'fallnum=.
missing_lasi ht102as7 ht103 ht103a, result(r`wv'fallnum) wave(`wv')
replace r`wv'fallnum=0 if ht102as7==0 | ht103==2 //represents no falls
replace r`wv'fallnum=ht103a if (ht102as7==1 | ht103==1) & inrange(ht103a,1,30) 
label variable r`wv'fallnum "r`wv'fallnum:w`wv' r number of falls"
*spouse
gen s`wv'fallnum=.
spouse r`wv'fallnum, result(s`wv'fallnum) wave(`wv')
label variable s`wv'fallnum "s`wv'fallnum:w`wv' s number of falls"

***Whether ever had hip fracture - NOT AVAILABLE
* LASI has general question on "Ever fractured any bones/joints in past 2 years"

******************************************************************
***Diseases endemic to India*** - LASI Only
******************************************************************
***Past 2 years: Malaria
gen r`wv'malaria=.
missing_lasi ht203, result(r`wv'malaria) wave(`wv')
replace r`wv'malaria=0 if ht203==2
replace r`wv'malaria=1 if ht203==1
label variable r`wv'malaria "r`wv'malaria:w`wv' r had malaria last 2 years"
label values r`wv'malaria doctor
*spouse
gen s`wv'malaria=.
spouse r`wv'malaria, result(s`wv'malaria) wave(`wv')
label variable s`wv'malaria "s`wv'malaria:w`wv' s had malaria last 2 years"
label values s`wv'malaria doctor

***Past 2 years: Diarrhea/gastroenteritis
gen r`wv'diarrh=.
missing_lasi ht204, result(r`wv'diarrh) wave(`wv')
replace r`wv'diarrh=0 if ht204==2
replace r`wv'diarrh=1 if ht204==1
label variable r`wv'diarrh "r`wv'diarrh:w`wv' r had diarrhea/gastroenteritis last 2 years"
label values r`wv'diarrh doctor
*spouse
gen s`wv'diarrh=.
spouse r`wv'diarrh, result(s`wv'diarrh) wave(`wv')
label variable s`wv'diarrh "s`wv'diarrh:w`wv' s had diarrhea/gastroenteritis last 2 years"
label values s`wv'diarrh doctor

***Past 2 years: Typhoid
gen r`wv'typhoid=.
missing_lasi ht205, result(r`wv'typhoid) wave(`wv')
replace r`wv'typhoid=0 if ht205==2
replace r`wv'typhoid=1 if ht205==1
label variable r`wv'typhoid "r`wv'typhoid:w`wv' r had typhoid last 2 years"
label values r`wv'typhoid doctor
*spouse
gen s`wv'typhoid=.
spouse r`wv'typhoid, result(s`wv'typhoid) wave(`wv')
label variable s`wv'typhoid "s`wv'typhoid:w`wv' s had typhoid last 2 years"
label values s`wv'typhoid doctor

***Past 2 years: Anemia
gen r`wv'anemia=.
missing_lasi ht207, result(r`wv'anemia) wave(`wv')
replace r`wv'anemia=0 if ht207==2
replace r`wv'anemia=1 if ht207==1
label variable r`wv'anemia "r`wv'anemia:w`wv' r had anemia last 2 years"
label values r`wv'anemia doctor
*spouse 
gen s`wv'anemia=.
spouse r`wv'anemia, result(s`wv'anemia) wave(`wv')
label variable s`wv'anemia "s`wv'anemia:w`wv' s had anemia last 2 years"
label values s`wv'anemia doctor


***********************************************************************
***Drinking Habits***
***********************************************************************
***Whether binge drinks***
*NOTE: HRS considers >=4 drinks on one occassion as binge drinking
*LASI, in this case, considers >=5 drinks on one occassion
gen r`wv'drinkb=.
missing_lasi hb103 hb106 r`wv'drinkev, result(r`wv'drinkb) wave(`wv')
replace r`wv'drinkb=0 if r`wv'drinkev==0 | hb103==0
replace r`wv'drinkb=0 if hb106==0
replace r`wv'drinkb=1 if inrange(hb106,1,5) 
label variable r`wv'drinkb "r`wv'drinkb:w`wv' r ever binge drinks"
label values r`wv'drinkb doctor
*spouse
gen s`wv'drinkb=.
spouse r`wv'drinkb, result(s`wv'drinkb) wave(`wv')
label variable s`wv'drinkb "s`wv'drinkb:w`wv' s ever binge drinks"
label values s`wv'drinkb doctor

***Frequency of binge drinks***
*HRS: Number of days; LASI: Frequency 
gen r`wv'bingedcat=.
missing_lasi hb103 hb106 r`wv'drinkev, result(r`wv'bingedcat) wave(`wv')
replace r`wv'bingedcat=0 if r`wv'drinkev==0 | hb103==0
replace r`wv'bingedcat=0 if inlist(hb106,0,1)
replace r`wv'bingedcat=1 if hb106==2
replace r`wv'bingedcat=2 if hb106==3
replace r`wv'bingedcat=3 if hb106==4
replace r`wv'bingedcat=4 if hb106==5
label variable r`wv'bingedcat "r`wv'bingedcat:w`wv' r frequency of binge drinking in the past 3 months"
label values r`wv'bingedcat bingedrink
*Spouse
gen s`wv'bingedcat=.
spouse r`wv'bingedcat, result(s`wv'bingedcat) wave(`wv')
label variable s`wv'bingedcat "s`wv'bingedcat:w`wv' s frequency of binge drinking in the past 3 months"
label values s`wv'bingedcat bingedrink

*HRS has a .n:does not drink for all drinking habit variables
*Create .n:does not drink and .x:did not drink >=5 drinks on one occassion

***Questions below are asked ONLY if R answered hb106 (had >=5 drinks on one occasion) as > 0.none

***Feels should cut down on drinking
gen r`wv'drinkcut=.
missing_lasi hb106 hb107 r`wv'drinkev r`wv'drink3m, result(r`wv'drinkcut) wave(`wv')
replace r`wv'drinkcut=.n if r`wv'drinkev==0 | r`wv'drink3m==0
replace r`wv'drinkcut=.x if hb106==0
replace r`wv'drinkcut=0 if hb107==2
replace r`wv'drinkcut=1 if hb107==1
label variable r`wv'drinkcut "r`wv'drinkcut:w`wv' r feels should cut down on drinking"
label values r`wv'drinkcut drinking
*Spouse
gen s`wv'drinkcut=.
spouse r`wv'drinkcut, result(s`wv'drinkcut) wave(`wv')
label variable s`wv'drinkcut "s`wv'drinkcut:w`wv' s feels should cut down on drinking"
label values s`wv'drinkcut drinking

***Others criticize your drinking
gen r`wv'drinkcr=.
missing_lasi hb106 hb108 r`wv'drinkev r`wv'drink3m, result(r`wv'drinkcr) wave(`wv')
replace r`wv'drinkcr=.n if r`wv'drinkev==0 | r`wv'drink3m==0
replace r`wv'drinkcr=.x if hb106==0
replace r`wv'drinkcr=0 if hb108==2
replace r`wv'drinkcr=1 if hb108==1
label variable r`wv'drinkcr "r`wv'drinkcr:w`wv' r others criticize your drinking"
label values r`wv'drinkcr drinking
*Spouse
gen s`wv'drinkcr=.
spouse r`wv'drinkcr, result(s`wv'drinkcr) wave(`wv')
label variable s`wv'drinkcr "s`wv'drinkcr:w`wv' s others criticize your drinking"
label values s`wv'drinkcr drinking

***Feels bad about drinking
gen r`wv'drinkbd=.
missing_lasi hb106 hb109 r`wv'drinkev r`wv'drink3m, result(r`wv'drinkbd) wave(`wv')
replace r`wv'drinkbd=.n if r`wv'drinkev==0 | r`wv'drink3m==0
replace r`wv'drinkbd=.x if hb106==0
replace r`wv'drinkbd=0 if hb109==2
replace r`wv'drinkbd=1 if hb109==1
label variable r`wv'drinkbd "r`wv'drinkbd:w`wv' r feels bad about drinking"
label values r`wv'drinkbd drinking
*Spouse
gen s`wv'drinkbd=.
spouse r`wv'drinkbd, result(s`wv'drinkbd) wave(`wv')
label variable s`wv'drinkbd "s`wv'drinkbd:w`wv' s feels bad about drinking"
label values s`wv'drinkbd drinking

***Takes drink for nerves in morning
gen r`wv'drinknr=.
missing_lasi hb106 hb110 r`wv'drinkev r`wv'drink3m, result(r`wv'drinknr) wave(`wv')
replace r`wv'drinknr=.n if r`wv'drinkev==0 | r`wv'drink3m==0
replace r`wv'drinknr=.x if hb106==0
replace r`wv'drinknr=0 if hb110==2
replace r`wv'drinknr=1 if hb110==1
label variable r`wv'drinknr "r`wv'drinknr:w`wv' r takes drink for nerve in am"
label values r`wv'drinknr drinking
*Spouse
gen s`wv'drinknr=.
spouse r`wv'drinknr, result(s`wv'drinknr) wave(`wv')
label variable s`wv'drinknr "s`wv'drinknr:w`wv' s takes drink for nerve in am"
label values s`wv'drinknr drinking

***CAGE Summary
*Respondent cage missings
egen r`wv'cagem = rowmiss(r`wv'drinkcut r`wv'drinkcr r`wv'drinkbd r`wv'drinknr) if inw`wv'==1
label variable r`wv'cagem "r`wv'cagem:w`wv' r cage missings"

*Respondent cage summary
egen r`wv'cage = rowtotal(r`wv'drinkcut r`wv'drinkcr r`wv'drinkbd r`wv'drinknr) if inrange(r`wv'cagem,0,3),m
replace r`wv'cage = .m if r`wv'cagem == 4 & (r`wv'drinkcut==.m | r`wv'drinkcr==.m | r`wv'drinkbd==.m | r`wv'drinknr==.m) 
replace r`wv'cage = .d if r`wv'cagem == 4 & (r`wv'drinkcut==.d | r`wv'drinkcr==.d | r`wv'drinkbd==.d | r`wv'drinknr==.d)
replace r`wv'cage = .r if r`wv'cagem == 4 & (r`wv'drinkcut==.r | r`wv'drinkcr==.r | r`wv'drinkbd==.r | r`wv'drinknr==.r) 
replace r`wv'cage = .n if r`wv'cagem == 4 & (r`wv'drinkcut==.n | r`wv'drinkcr==.n | r`wv'drinkbd==.n | r`wv'drinknr==.n) 
replace r`wv'cage = .x if r`wv'cagem == 4 & (r`wv'drinkcut==.x | r`wv'drinkcr==.x | r`wv'drinkbd==.x | r`wv'drinknr==.x)
label variable r`wv'cage "r`wv'cage:w`wv' r cage summary"

*Spouse cage missings
gen s`wv'cagem=.
spouse r`wv'cagem, result(s`wv'cagem) wave(`wv')
label variable s`wv'cagem "s`wv'cagem:w`wv' s cage missings"

*Spouse cage summary
gen s`wv'cage=.
spouse r`wv'cage, result(s`wv'cage) wave(`wv')
label variable s`wv'cage "s`wv'cage:w`wv' s cage summary"


***********************************************************************
***Persistent health problems***
***********************************************************************
***Persistent swelling in feet
gen r`wv'swell=.
missing_lasi ht229s2 ht229s10, result(r`wv'swell) wave(`wv')
replace r`wv'swell=0 if ht229s2==0 | ht229s10==1 //swelling = no or if none=yes
replace r`wv'swell=1 if ht229s2==1
label variable r`wv'swell "r`wv'swell:w`wv' r persistent swelling in feet/ankles"
label values r`wv'swell doctor
*spouse
gen s`wv'swell=.
spouse r`wv'swell, result(s`wv'swell) wave(`wv')
label variable s`wv'swell "s`wv'swell:w`wv' s persistent swelling in feet/ankles"
label values s`wv'swell doctor

***Persistent short of breath while awake
gen r`wv'breath=.
missing_lasi ht229s3 ht229s10, result(r`wv'breath) wave(`wv')
replace r`wv'breath=0 if ht229s3==0 | ht229s10==1
replace r`wv'breath=1 if ht229s3==1
label variable r`wv'breath "r`wv'breath:w`wv' r short of breath while awake"
label values r`wv'breath doctor 
*spouse
gen s`wv'breath=.
spouse r`wv'breath, result(s`wv'breath) wave(`wv')
label variable s`wv'breath "s`wv'breath:w`wv' s short of breath while awake"
label values s`wv'breath doctor

***Persistent dizziness or light headedness
gen r`wv'dizzy=.
missing_lasi ht229s4 ht229s10, result(r`wv'dizzy) wave(`wv')
replace r`wv'dizzy=0 if ht229s4==0 | ht229s10==1
replace r`wv'dizzy=1 if ht229s4==1
label variable r`wv'dizzy "r`wv'dizzy:w`wv' r persistent dizziness"
label values r`wv'dizzy doctor
*spouse
gen s`wv'dizzy=.
spouse r`wv'dizzy, result(s`wv'dizzy) wave(`wv')
label variable s`wv'dizzy "s`wv'dizzy:w`wv' s persistent dizziness"
label values s`wv'dizzy doctor

***Persistent backpain
gen r`wv'backp=.
missing_lasi ht229s5 ht229s10, result(r`wv'backp) wave(`wv')
replace r`wv'backp=0 if ht229s5==0 | ht229s10==1
replace r`wv'backp=1 if ht229s5==1
label variable r`wv'backp "r`wv'backp:w`wv' r back pain"
label values r`wv'backp doctor
*spouse
gen s`wv'backp=.
spouse r`wv'backp, result(s`wv'backp) wave(`wv')
label variable s`wv'backp "s`wv'backp:w`wv' s back pain"
label values s`wv'backp doctor

***Persistent headache
gen r`wv'headache=.
missing_lasi ht229s6 ht229s10, result(r`wv'headache) wave(`wv')
replace r`wv'headache=0 if ht229s6==0 | ht229s10==1
replace r`wv'headache=1 if ht229s6==1
label variable r`wv'headache "r`wv'headache:w`wv' r persistent headaches"
label values r`wv'headache doctor
*spouse
gen s`wv'headache=.
spouse r`wv'headache, result(s`wv'headache) wave(`wv')
label variable s`wv'headache "s`wv'headache:w`wv' s persistent headaches"
label values s`wv'headache doctor

***Severe fatigue or exhaustion
gen r`wv'fatigue=.
missing_lasi ht229s7 ht229s10, result(r`wv'fatigue) wave(`wv')
replace r`wv'fatigue=0 if ht229s7==0 | ht229s10==1
replace r`wv'fatigue=1 if ht229s7==1
label variable r`wv'fatigue "r`wv'fatigue:w`wv' r severe fatigue"
label values r`wv'fatigue doctor
*spouse
gen s`wv'fatigue=.
spouse r`wv'fatigue, result(s`wv'fatigue) wave(`wv')
label variable s`wv'fatigue "s`wv'fatigue:w`wv' s severe fatigue"
label values s`wv'fatigue doctor

***Wheezing or whistling sound from chest
gen r`wv'wheeze=.
missing_lasi ht229s8 ht229s10, result(r`wv'wheeze) wave(`wv')
replace r`wv'wheeze=0 if ht229s8==0 | ht229s10==1
replace r`wv'wheeze=1 if ht229s8==1
label variable r`wv'wheeze "r`wv'wheeze:w`wv' r persistent wheezing"
label values r`wv'wheeze doctor
*spouse
gen s`wv'wheeze=.
spouse r`wv'wheeze, result(s`wv'wheeze) wave(`wv')
label variable s`wv'wheeze "s`wv'wheeze:w`wv' s persistent wheezing"
label values s`wv'wheeze doctor

***Pain or stiffness in joints
gen r`wv'jointp=.
missing_lasi ht229s1 ht229s10, result(r`wv'jointp) wave(`wv')
replace r`wv'jointp=0 if ht229s1==0 | ht229s10==1
replace r`wv'jointp=1 if ht229s1==1
label variable r`wv'jointp "r`wv'jointp:w`wv' r joint pain or stiffness"
label values r`wv'jointp doctor
*spouse 
gen s`wv'jointp=.
spouse r`wv'jointp, result(s`wv'jointp) wave(`wv')
label variable s`wv'jointp "s`wv'jointp:w`wv' s joint pain or stiffness"
label values s`wv'jointp doctor
 
***Cough with or without phlegm
gen r`wv'cough=.
missing_lasi ht229s9 ht229s10, result(r`wv'cough) wave(`wv')
replace r`wv'cough=0 if ht229s9==0 | ht229s10==1
replace r`wv'cough=1 if ht229s9==1
label variable r`wv'cough "r`wv'cough:w`wv' r cough with or without phlegm"
label values r`wv'cough doctor
*spouse
gen s`wv'cough=.
spouse r`wv'cough, result(s`wv'cough) wave(`wv')
label variable s`wv'cough "s`wv'cough:w`wv' s cough with or without phlegm"
label values s`wv'cough doctor


***********************************************************************
***Women's health***
***********************************************************************
***Ever had hysterectomy
gen r`wv'hystere=.
missing_lasi ht239 dm003, result(r`wv'hystere) wave(`wv')
replace r`wv'hystere = .g if inlist(dm003,1,3) & inw`wv'==1 //if male
replace r`wv'hystere = 0 if ht239==2
replace r`wv'hystere = 1 if ht239==1
label variable r`wv'hystere "r`wv'hystere:w`wv' r ever had hysterectomy"
label values r`wv'hystere doctor 
*spouse
gen s`wv'hystere=.
spouse r`wv'hystere, result(s`wv'hystere) wave(`wv')
label variable s`wv'hystere "s`wv'hystere:w`wv' s ever had hysterectomy"
label values s`wv'hystere doctor

***Age of last menstrual cycle 
gen r`wv'lstmnspd_l=.
missing_lasi ht236_year rabyear dm003, result(r`wv'lstmnspd_l) wave(`wv')
replace r`wv'lstmnspd_l = .g if inlist(dm003,1,3) & inw`wv'==1 //if male 
replace r`wv'lstmnspd_l = ht236_year - rabyear if inrange(ht236_year,1931,2021) & !mi(rabyear)
replace r`wv'lstmnspd_l = .i if (r`wv'lstmnspd_l > r`wv'agey) & !mi(r`wv'lstmnspd_l)
replace r`wv'lstmnspd_l = .i if r`wv'lstmnspd_l < 1
label variable r`wv'lstmnspd_l "r`wv'lstmnspd_l:w`wv' r age of most recent menstrual cycle"
*spouse
gen s`wv'lstmnspd_l=.
spouse r`wv'lstmnspd_l, result(s`wv'lstmnspd_l) wave(`wv')
label variable s`wv'lstmnspd_l "s`wv'lstmnspd_l:w`wv' s age of most recent menstrual cycle" 


***************************************


***drop LAsI  file raw variables***
drop `health_w1_ind' 


*Cognitive imputation flag
label define imputedf 0 "0.Not imputed" ///
	                  1 "1.Imputed:Dont know" ///
	                  2 "2.Imputed:Missing" ///
	                  3 "3.Imputed:Not Assessed" ///
					  4 "4.Imputed:Refused" ///
					  5 "5.Imputed:Not in phase/wave" /// 
					  6 "6.Imputed:Cannot Count" ///
					  7 "7.Imputed:No score" ///
					  8 "8.Imputed:Bad image" ///
					  9 "9.Imputed:Error" ///
					  10 "10.Imputed:Cannot read/write" ///
					  11 "11.Imputed:Skipped" ///
					  12 "12.Imputed:Not interviewed" ///
					  13 "13.Left Missing:Proxy" ///
					  14 "14.Left Missing:Cannot read/write" ///
					  .v ".v:SP NR" ///
		              .u ".u:Unmar"  , modify
	
***JORM IQCODE***
label define ijsca ///
	1 "1.Much improved" ///
	2 "2.A bit improved" ///
	3 "3.Not much change" ///
	4 "4.A bit worse" ///
	5 "5.Much worse" ///
	.m ".m:Missing" ///
	.d  ".d:DK" ///
	.p ".p:non-proxy interview" ///
	.u ".u:Unmar" 
	
	
***yes no***
label define yesnocog ///
   0 "0.no"  ///
   1 "1.yes" ///
   .r ".r:Refuse" ///
	 .m ".m:Missing" ///
	 .d ".d:DK" ///
	 .p ".p:Proxy" ///
	 .u ".u:Unmar" 

***frequency***
label define frequencycog ///
	1 "1.never" ///
	2 "2.a few times" ///
	3 "3.most or all of the time" ///
	.p ".p:proxy"

***daywnaming2***
label define daywnaming2 /// 
	0 "0.incorrect" /// 
	1 "1.correct" /// 
	.p ".p:proxy" /// 
	.u ".u:Unmar" /// 
	.v ".v:SP NR" /// 

***reading2***
label define reading2 /// 
	0 "0.did not read or complete" /// 
	1 "1.read and completed" /// 
	.l ".l:illiterate" /// 
	.p ".p:proxy" /// 
	.u ".u:Unmar" /// 
	.v ".v:SP NR" 

***writing2***
label define writing2 /// 
	0 "0.could not write sentence" /// 
	1 "1.wrote sentence" /// 
	.l ".l:illiterate" /// 
	.p ".p:proxy" /// 
	.u ".u:Unmar" /// 
	.v ".v:SP NR" 		

***action2***
label define action2 /// 
	0 "0.none" /// 
	1 "1.one of the tasks" /// 
	2 "2.two of the tasks" /// 
	3 "3.all of the tasks" /// 
	.p ".p:proxy" /// 
	.u ".u:Unmar" /// 
	.v ".v:SP NR" 	

***clock2***
label define clock2 /// 
	0 "0.no aspects correct" /// 
	1 "1.only one aspect correct" /// 
	2 "2.only two aspects correct" /// 
	3 "3.all aspects correct" /// 
	.p ".p:Proxy" /// 
	.u ".u:Unmar" /// 
	.v ".v:SP NR" 	

***bwcount2***
label define bwcount2 /// 
	0 "0.incorrect" /// 
	1 "1.correct" /// 
	.p ".p:Proxy" /// 
	.u ".u:Unmar" /// 
	.v ".v:SP NR" 	
							 


*set wave number
local wv=1

***merge with imputed cognition file
merge 1:1 prim_key using "$wave_1_cog_imput", nogen

***merge with factor score file
merge 1:1 prim_key using "$wave_1_factor", nogen

***merge with demog file***
local cog_w1_ind mh104 mh105 mh106 mh107 mh108 mh109 mh110 mh111 mh112 mh113 mh114 mh115 mh116 mh117 mh118 mh119 ///
                 mh057 mh058 mh126 rproxy
 
merge 1:1 prim_key using  "$wave_1_ind_bm", keepusing(`cog_w1_ind') nogen


*define imputed flag variables
local f_vars f_r1mo f_r1dy f_r1yr f_r1dw  ///
			 f_r1place f_r1address f_r1city f_r1dist ///
			 f_r1imrc f_r1dlrc ///
			 f_r1ser7 f_r1object1 f_r1object2 ///
			 f_r1read f_r1execu f_r1senten f_r1draw f_r1drawcl ///
			 f_r1verbf f_r1verbf_inc f_r1bwc20 f_r1bwc100 ///
			 f_r1compu1 f_r1compu2  

foreach var in `f_vars' {
    replace `var'=0 if `var'==1
    replace `var'=1 if `var'==.d
    replace `var'=2 if `var'==.m
    replace `var'=3 if `var'==.n
    replace `var'=4 if `var'==.r
    replace `var'=5 if `var'==.x
    replace `var'=6 if `var'==.c
    replace `var'=7 if `var'==.z
    replace `var'=8 if `var'==.b
    replace `var'=9 if `var'==.e
    replace `var'=10 if `var'==.c
    replace `var'=11 if `var'==.s
    replace `var'=12 if `var'==.h
    replace `var'=13 if `var'==.p
    replace `var'=14 if `var'==.l
    label values `var' imputedf
    local varstr = substr("`var'",3,.)
    rename `var' `=subinstr("`varstr'","`wv'","`wv'f",1)'_l
    
}

***Date naming***
*respondent
label values r`wv'dy daywnaming2

*spouse value
gen s`wv'dy=.
spouse r`wv'dy, result(s`wv'dy) wave(`wv')
label variable s`wv'dy "s`wv'dy:w`wv' s cognition date naming-day of month"
label values s`wv'dy daywnaming2

*respondent flag
label variable r`wv'fdy_l "r`wv'fdy_l:w`wv' impflag: r cognition date naming-day of month"

*spouse flag
gen s`wv'fdy_l=.
spouse r`wv'fdy_l, result(s`wv'fdy_l) wave(`wv')
label variable s`wv'fdy_l "s`wv'fdy_l:w`wv' impflag: s cognition date naming-day of month"
label values s`wv'fdy_l imputedf

*respondent
label values r`wv'mo daywnaming2

*spouse value
gen s`wv'mo=.
spouse r`wv'mo, result(s`wv'mo) wave(`wv')
label variable s`wv'mo "s`wv'mo:w`wv' s cognition date naming-month"
label values s`wv'mo daywnaming2

*respondent flag
label variable r`wv'fmo_l "r`wv'fmo_l:w`wv' impflag: r cognition date naming-month"

*spouse flag
gen s`wv'fmo_l=.
spouse r`wv'fmo_l, result(s`wv'fmo_l) wave(`wv')
label variable s`wv'fmo_l "s`wv'fmo_l:w`wv' impflag: s cognition date naming-month"
label values s`wv'fmo_l imputedf

*respondent
label values r`wv'yr daywnaming2

*spouse value
gen s`wv'yr=.
spouse r`wv'yr, result(s`wv'yr) wave(`wv')
label variable s`wv'yr "s`wv'yr:w`wv' s cognition date naming-year"
label values s`wv'yr daywnaming2

*respondent flag
label variable r`wv'fyr_l "r`wv'fyr_l:w`wv' impflag: r cognition date naming-year"

*spouse flag
gen s`wv'fyr_l=.
spouse r`wv'fyr_l, result(s`wv'fyr_l) wave(`wv')
label variable s`wv'fyr_l "s`wv'fyr_l:w`wv' impflag: s cognition date naming-year"
label values s`wv'fyr_l imputedf

*respondent
label values r`wv'dw daywnaming2

*spouse value
gen s`wv'dw=.
spouse r`wv'dw, result(s`wv'dw) wave(`wv')
label variable s`wv'dw "s`wv'dw:w`wv' s cognition date naming-day of week"
label values s`wv'dw daywnaming2

*respondent flag
label variable r`wv'fdw_l "r`wv'fdw_l:w`wv' impflag: r cognition date naming-day of week"

*spouse flag
gen s`wv'fdw_l=.
spouse r`wv'fdw_l, result(s`wv'fdw_l) wave(`wv')
label variable s`wv'fdw_l "s`wv'fdw_l:w`wv' impflag: s cognition date naming-day of week"
label values s`wv'fdw_l imputedf

****cognition orient- time
gen r`wv'orient=r`wv'yr + r`wv'dy + r`wv'dw + r`wv'mo  
replace r`wv'orient = .p if r`wv'yr == .p | r`wv'dy == .p | r`wv'dw == .p | r`wv'mo  == .p
label variable r`wv'orient "r`wv'orient:w`wv' r cognition orientation to time(0-4)"

*spouse 
gen s`wv'orient=.
spouse r`wv'orient, result(s`wv'orient) wave(`wv')
label variable s`wv'orient "s`wv'orient:w`wv' s cognition orientation to time(0-4)"

***Place naming***
*respondent
label values r`wv'place daywnaming2

*spouse value
gen s`wv'place=.
spouse r`wv'place, result(s`wv'place) wave(`wv')
label variable s`wv'place "s`wv'place:w`wv' s cognition place naming"
label values s`wv'place daywnaming2

*respondent flag
label variable r`wv'fplace_l "r`wv'fplace_l:w`wv' impflag: r cognition place naming"

*spouse flag
gen s`wv'fplace_l=.
spouse r`wv'fplace_l, result(s`wv'fplace_l) wave(`wv')
label variable s`wv'fplace_l "s`wv'fplace_l:w`wv' impflag: s cognition place naming"
label values s`wv'fplace_l imputedf

*respondent
label values r`wv'city daywnaming2

*spouse value
gen s`wv'city=.
spouse r`wv'city, result(s`wv'city) wave(`wv')
label variable s`wv'city "s`wv'city:w`wv' s cognition city naming"
label values s`wv'city daywnaming2

*respondent flag
label variable r`wv'fcity_l "r`wv'fcity_l:w`wv' impflag: r cognition city naming"

*spouse flag
gen s`wv'fcity_l=.
spouse r`wv'fcity_l, result(s`wv'fcity_l) wave(`wv')
label variable s`wv'fcity_l "s`wv'fcity_l:w`wv' impflag: s cognition city naming"
label values s`wv'fcity_l imputedf

*respondent
label values r`wv'address daywnaming2

*spouse value
gen s`wv'address=.
spouse r`wv'address, result(s`wv'address) wave(`wv')
label variable s`wv'address "s`wv'address:w`wv' s cognition street naming"
label values s`wv'address daywnaming2

*respondent flag
label variable r`wv'faddress_l "r`wv'faddress_l:w`wv' impflag: r cognition street naming"

*spouse flag
gen s`wv'faddress_l=.
spouse r`wv'faddress_l, result(s`wv'faddress_l) wave(`wv')
label variable s`wv'faddress_l "s`wv'faddress_l:w`wv' impflag: s cognition street naming"
label values s`wv'faddress_l imputedf

*respondent
label values r`wv'dist daywnaming2

*spouse value
gen s`wv'dist=.
spouse r`wv'dist, result(s`wv'dist) wave(`wv')
label variable s`wv'dist "s`wv'dist:w`wv' s cognition district naming"
label values s`wv'dist daywnaming2

*respondent flag
label variable r`wv'fdist_l "r`wv'fdist_l:w`wv' impflag: r cognition district naming"

*spouse flag
gen s`wv'fdist_l=.
spouse r`wv'fdist_l, result(s`wv'fdist_l) wave(`wv')
label variable s`wv'fdist_l "s`wv'fdist_l:w`wv' impflag: s cognition district naming"
label values s`wv'fdist_l imputedf

***cognition orient- place
gen r`wv'orientp=r`wv'city + r`wv'place + r`wv'dist + r`wv'address
replace r`wv'orientp = .p if r`wv'city == .p | r`wv'place == .p | r`wv'dist == .p | r`wv'address  == .p
label variable r`wv'orientp "r`wv'orientp:w`wv' r cognition orientation to place(0-4)"

*spouse 
gen s`wv'orientp=.
spouse r`wv'orientp, result(s`wv'orientp) wave(`wv')
label variable s`wv'orientp "s`wv'orientp:w`wv' s cognition orientation to place(0-4)"

***Word recall***

*spouse value
gen s`wv'imrc=.
spouse r`wv'imrc, result(s`wv'imrc) wave(`wv')
label variable s`wv'imrc "s`wv'imrc:w`wv' s immediate word recall"

*respondent flag
label variable r`wv'fimrc_l "r`wv'fimrc_l:w`wv' impflag: r immediate word recall"

*spouse flag
gen s`wv'fimrc_l=.
spouse r`wv'fimrc_l, result(s`wv'fimrc_l) wave(`wv')
label variable s`wv'fimrc_l "s`wv'fimrc_l:w`wv' impflag: s immediate word recall"
label values s`wv'fimrc_l imputedf

*spouse value
gen s`wv'dlrc=.
spouse r`wv'dlrc, result(s`wv'dlrc) wave(`wv')
label variable s`wv'dlrc "s`wv'dlrc:w`wv' s delayed word recall"

*respondent flag
label variable r`wv'fdlrc_l "r`wv'fdlrc_l:w`wv' impflag: r delayed word recall"

*spouse flag
gen s`wv'fdlrc_l=.
spouse r`wv'fdlrc_l, result(s`wv'fdlrc_l) wave(`wv')
label variable s`wv'fdlrc_l "s`wv'fdlrc_l:w`wv' impflag: s delayed word recall"
label values s`wv'fdlrc_l imputedf

***recall summary score
*respondent
gen r`wv'tr20 = r`wv'imrc + r`wv'dlrc 
replace r`wv'tr20 = .p if r`wv'imrc == .p | r`wv'dlrc == .p 
label variable r`wv'tr20 "r`wv'tr20:w`wv' r word recall summary score"

*spouse 
gen s`wv'tr20=.
spouse r`wv'tr20, result(s`wv'tr20) wave(`wv')
label variable s`wv'tr20 "s`wv'tr20:w`wv' s word recall summary score"

***Serial 7's***

*spouse value
gen s`wv'ser7=.
spouse r`wv'ser7, result(s`wv'ser7) wave(`wv')
label variable s`wv'ser7 "s`wv'ser7:w`wv' s serial 7s"

*respondent flag
label variable r`wv'fser7_l "r`wv'fser7_l:w`wv' impflag: r serial 7s"

*spouse flag
gen s`wv'fser7_l=.
spouse r`wv'fser7_l, result(s`wv'fser7_l) wave(`wv')
label variable s`wv'fser7_l "s`wv'fser7_l:w`wv' impflag: s serial 7s"
label value s`wv'fser7_l imputedf

***Object naming***
*respondent
label values r`wv'object1 daywnaming2

*spouse value
gen s`wv'object1=.
spouse r`wv'object1, result(s`wv'object1) wave(1)
label variable s`wv'object1 "s`wv'object1:w`wv' s named first object"
label value s`wv'object1 daywnaming2 

*respondent flag
label variable r`wv'fobject1_l "r`wv'fobject1_l:w`wv' impflag: r named first object"

*spouse flag
gen s`wv'fobject1_l=.
spouse r`wv'fobject1_l, result(s`wv'fobject1_l) wave(1)
label variable s`wv'fobject1_l "s`wv'fobject1_l:w`wv' impflag: s named first object"
label value s`wv'fobject1_l  imputedf

*respondent
label values r`wv'object2 daywnaming2

*spouse value
gen s`wv'object2=.
spouse r`wv'object2, result(s`wv'object2) wave(`wv')
label variable s`wv'object2 "s`wv'object2:w`wv' s named second object"
label value s`wv'object2 daywnaming2 

*respondent flag
label variable r`wv'fobject2_l "r`wv'fobject2_l:w`wv' impflag: r named second object"

*spouse flag
gen s`wv'fobject2_l=.
spouse r`wv'fobject2_l, result(s`wv'fobject2_l) wave(1)
label variable s`wv'fobject2_l "s`wv'fobject2_l:w`wv' impflag: s named second object"
label value s`wv'fobject2_l  imputedf

**Total: Object naming
*respondent
gen r`wv'object = r`wv'object1 + r`wv'object2
replace r`wv'object = .p if r`wv'object1 == .p | r`wv'object2 == .p 
label variable r`wv'object "r`wv'object:w`wv' r total object naming(0-2)"

*spouse 
gen s`wv'object=.
spouse r`wv'object, result(s`wv'object) wave(`wv')
label variable s`wv'object "s`wv'object:w`wv' s total object naming(0-2)"

***Task completion***
*respondent
label values r`wv'read reading2

*spouse value
gen s`wv'read=.
spouse r`wv'read, result(s`wv'read) wave(`wv')
label variable s`wv'read "s`wv'read:w`wv' s able to read and close eyes"
label value s`wv'read reading2

*respondent flag
label variable r`wv'fread_l "r`wv'fread_l:w`wv' impflag: r able to read and close eyes"

*spouse flag
gen s`wv'fread_l=.
spouse r`wv'fread_l, result(s`wv'fread_l) wave(`wv')
label variable s`wv'fread_l "s`wv'fread_l:w`wv' impflag: s able to read and close eyes"
label value s`wv'fread_l  imputedf

*respondent
label values r`wv'senten writing2

*spouse value
gen s`wv'senten=.
spouse r`wv'senten, result(s`wv'senten) wave(`wv')
label variable s`wv'senten "s`wv'senten:w`wv' s able to write a sentence"
label values s`wv'senten writing2

*respondent flag
label variable r`wv'fsenten_l "r`wv'fsenten_l:w`wv' impflag: r able to write a sentence"

*spouse flag
gen s`wv'fsenten_l=.
spouse r`wv'fsenten_l, result(s`wv'fsenten_l) wave(`wv')
label variable s`wv'fsenten_l "s`wv'fsenten_l:w`wv' impflag: s able to write a sentence"
label values s`wv'fsenten_l imputedf

*respondent
label values r`wv'execu action2

*spouse value
gen s`wv'execu=.
spouse r`wv'execu, result(s`wv'execu) wave(`wv')
label variable s`wv'execu "s`wv'execu:w`wv' s able to do 3-stage task (folding paper)"
label values s`wv'execu action2

*respondent flag
label variable r`wv'fexecu_l "r`wv'fexecu_l:w`wv' impflag: r able to do 3-stage task (folding paper)"

*spouse flag
gen s`wv'fexecu_l=.
spouse r`wv'fexecu_l, result(s`wv'fexecu_l) wave(`wv')
label variable s`wv'fexecu_l "s`wv'fexecu_l:w`wv' impflag: s able to do 3-stage task (folding paper)"
label values s`wv'fexecu_l imputedf

***Picture drawing***
*respondent
label values r`wv'draw daywnaming2

*spouse value
gen s`wv'draw=.
spouse r`wv'draw, result(s`wv'draw) wave(`wv')
label variable s`wv'draw "s`wv'draw:w`wv' s able to draw overlapped pentagons"
label values s`wv'draw daywnaming2

*respondent flag
label variable r`wv'fdraw_l "r`wv'fdraw_l:w`wv' impflag: r able to draw overlapped pentagons"

*spouse flag
gen s`wv'fdraw_l=.
spouse r`wv'fdraw_l, result(s`wv'fdraw_l) wave(`wv')
label variable s`wv'fdraw_l "s`wv'fdraw_l:w`wv' impflag: s able to draw overlapped pentagons"
label values s`wv'fdraw_l imputedf

*respondent
label values r`wv'drawcl clock2

*spouse value
gen s`wv'drawcl=.
spouse r`wv'drawcl, result(s`wv'drawcl) wave(`wv')
label variable s`wv'drawcl "s`wv'drawcl:w`wv' s cognition able to draw a clock"
label value s`wv'drawcl clock2

*respondent flag
label variable r`wv'fdrawcl_l "r`wv'fdrawcl_l:w`wv' impflag: r cognition able to draw a clock"

*spouse flag
gen s`wv'fdrawcl_l=.
spouse r`wv'fdrawcl_l, result(s`wv'fdrawcl_l) wave(`wv')
label variable s`wv'fdrawcl_l "s`wv'fdrawcl_l:w`wv' impflag: s cognition able to draw a clock"
label value s`wv'fdrawcl_l imputedf

***Animal naming***

*spouse value
gen s`wv'verbf=.
spouse r`wv'verbf, result(s`wv'verbf) wave(`wv')
label variable s`wv'verbf "s`wv'verbf:w`wv' s verbal fluency:animal naming-correct"

*respondent flag
label variable r`wv'fverbf_l "r`wv'fverbf_l:w`wv' impflag: r verbal fluency:animal naming-correct"

*spouse flag
gen s`wv'fverbf_l=.
spouse r`wv'fverbf_l, result(s`wv'fverbf_l) wave(`wv')
label variable s`wv'fverbf_l "s`wv'fverbf_l:w`wv' impflag: s verbal fluency:animal naming-correct"
label value s`wv'fverbf_l imputedf

*respondent value
rename r`wv'verbf_inc r`wv'verbfi
label variable r`wv'verbfi "r`wv'verbfi:w`wv' r verbal fluency:animal naming-incorrect"

*spouse value
gen s`wv'verbfi=.
spouse r`wv'verbfi, result(s`wv'verbfi) wave(`wv')
label variable s`wv'verbfi "s`wv'verbfi:w`wv' s verbal fluency:animal naming-incorrect"

*respondent flag
rename r`wv'fverbf_inc_l r`wv'fverbfi_l
label variable r`wv'fverbfi_l "r`wv'fverbfi_l:w`wv' impflag: r verbal fluency:animal naming-incorrect"

*spouse flag
gen s`wv'fverbfi_l=.
spouse r`wv'fverbfi_l, result(s`wv'fverbfi_l) wave(`wv')
label variable s`wv'fverbfi_l "s`wv'fverbfi_l:w`wv' impflag: s verbal fluency:animal naming-incorrect"
label value s`wv'fverbfi_l imputedf

***Backwards counting***
*respondent
rename r`wv'bwc20 r`wv'bwc20a
label variable r`wv'bwc20a "r`wv'bwc20a:w`wv' r counting backward from 20"
label values r`wv'bwc20a bwcount2

*spouse value
gen s`wv'bwc20a=.
spouse r`wv'bwc20a, result(s`wv'bwc20a) wave(`wv')
label variable s`wv'bwc20a "s`wv'bwc20a:w`wv' s counting backward from 20"
label value s`wv'bwc20a bwcount2 

*respondent flag
rename r`wv'fbwc20_l r`wv'fbwc20a_l
label variable r`wv'fbwc20a_l "r`wv'fbwc20a_l:w`wv' impflag: r counting backward from 20"

*spouse flag
gen s`wv'fbwc20a_l=.
spouse r`wv'fbwc20a_l, result(s`wv'fbwc20a_l) wave(`wv')
label variable s`wv'fbwc20a_l "s`wv'fbwc20a_l:w`wv' impflag: s counting backward from 20"
label value s`wv'fbwc20a_l  imputedf

*respondent
rename r`wv'bwc100 r`wv'bwc100a
label variable r`wv'bwc100a "r`wv'bwc100a:w`wv' r counting backward from 100"
label values r`wv'bwc100a bwcount2

*spouse value
gen s`wv'bwc100a=.
spouse r`wv'bwc100a, result(s`wv'bwc100a) wave(`wv')
label variable s`wv'bwc100a "s`wv'bwc100a:w`wv' s counting backward from 100"
label value s`wv'bwc100a bwcount2 

*respondent flag
rename r`wv'fbwc100_l r`wv'fbwc100a_l
label variable r`wv'fbwc100a_l "r`wv'fbwc100a_l:w`wv' impflag: r counting backward from 100"

*spouse flag
gen s`wv'fbwc100a_l=.
spouse r`wv'fbwc100a_l, result(s`wv'fbwc100a_l) wave(`wv')
label variable s`wv'fbwc100a_l "s`wv'fbwc100a_l:w`wv' impflag: s counting backward from 100"
label value s`wv'fbwc100a_l imputedf

***Computation***
*respondent
label values r`wv'compu1 daywnaming2

*spouse value
gen s`wv'compu1=.
spouse r`wv'compu1, result(s`wv'compu1) wave(`wv')
label variable s`wv'compu1 "s`wv'compu1:w`wv' s able to do computation 1"
label value s`wv'compu1 daywnaming2

*respondent flag
label variable r`wv'fcompu1_l "r`wv'fcompu1_l:w`wv' impflag: r able to do computation 1"

*spouse flag
gen s`wv'fcompu1_l=.
spouse r`wv'fcompu1_l, result(s`wv'fcompu1_l) wave(`wv')
label variable s`wv'fcompu1_l "s`wv'fcompu1_l:w`wv' impflag: s able to do computation 1"
label value s`wv'fcompu1_l imputedf

*respondent
label value r`wv'compu2 daywnaming2

*spouse value
gen s`wv'compu2=.
spouse r`wv'compu2, result(s`wv'compu2) wave(`wv')
label variable s`wv'compu2 "s`wv'compu2:w`wv' s able to do computation 2"
label value s`wv'compu2 daywnaming2

*respondent flag
label variable r`wv'fcompu2_l "r`wv'fcompu2_l:w`wv' impflag: r able to do computation 2"

*spouse flag
gen s`wv'fcompu2_l=.
spouse r`wv'fcompu2_l, result(s`wv'fcompu2_l) wave(`wv')
label variable s`wv'fcompu2_l "s`wv'fcompu2_l:w`wv' impflag: s able to do computation 2"
label value s`wv'fcompu2_l imputedf

***computation score summary
gen r`wv'compu = r`wv'compu1 + r`wv'compu2
replace r`wv'compu = .p if r`wv'compu1 == .p | r`wv'compu2 == .p
label variable r`wv'compu "r`wv'compu:w`wv' r computation total"

*spouse 
gen s`wv'compu=.
spouse r`wv'compu, result(s`wv'compu) wave(`wv')
label variable s`wv'compu "s`wv'compu:w`wv' s computation total"

***JORM IQCODE Test***

gen _iq1=.
replace _iq1=mh104

gen _iq2=.
replace _iq2=mh105

gen _iq3=.
replace _iq3=mh106

gen _iq4=.
replace _iq4=mh107

gen _iq5=.
replace _iq5=mh108

gen _iq6=.
replace _iq6=mh109

gen _iq7=.
replace _iq7=mh110

gen _iq8=.
replace _iq8=mh111

gen _iq9=.
replace _iq9=mh112

gen _iq10=.
replace _iq10=mh113

gen _iq11=.
replace _iq11=mh114

gen _iq12=.
replace _iq12=mh115

gen _iq13=.
replace _iq13=mh116

gen _iq14=.
replace _iq14=mh117

gen _iq15=.
replace _iq15=mh118

gen _iq16=.
replace _iq16=mh119

*respondent
forvalues i=1/16 {
	gen r`wv'ciqscore`i'=_iq`i' if inrange(_iq`i',1,5)
	replace r`wv'ciqscore`i'=.m if mi(r`wv'ciqscore`i') & _iq`i'==.
	replace r`wv'ciqscore`i'=.p if rproxy!=1
	replace r`wv'ciqscore`i'=.d if mi(r`wv'ciqscore`i') & _iq`i'==.d
	replace r`wv'ciqscore`i'=.r if mi(r`wv'ciqscore`i') & _iq`i'==.r
	label values r`wv'ciqscore`i' ijsca 
}

label variable r`wv'ciqscore1 "r`wv'ciqscore1:w`wv' JORM family/friend details"
label variable r`wv'ciqscore2 "r`wv'ciqscore2:w`wv' JORM recent events"
label variable r`wv'ciqscore3 "r`wv'ciqscore3:w`wv' JORM recent conversations"
label variable r`wv'ciqscore4 "r`wv'ciqscore4:w`wv' JORM address and telephone number"
label variable r`wv'ciqscore5 "r`wv'ciqscore5:w`wv' JORM day and month"
label variable r`wv'ciqscore6 "r`wv'ciqscore6:w`wv' JORM where things are usually kept"
label variable r`wv'ciqscore7 "r`wv'ciqscore7:w`wv' JORM where to find things"
label variable r`wv'ciqscore8 "r`wv'ciqscore8:w`wv' JORM work familiar machines"
label variable r`wv'ciqscore9 "r`wv'ciqscore9:w`wv' JORM new gadget or machine"
label variable r`wv'ciqscore10 "r`wv'ciqscore10:w`wv' JORM new things in general"
label variable r`wv'ciqscore11 "r`wv'ciqscore11:w`wv' JORM story in a book or on TV"
label variable r`wv'ciqscore12 "r`wv'ciqscore12:w`wv' JORM making decisions on everyday matters"
label variable r`wv'ciqscore13 "r`wv'ciqscore13:w`wv' JORM handling money for shopping"
label variable r`wv'ciqscore14 "r`wv'ciqscore14:w`wv' JORM handling financial matters"
label variable r`wv'ciqscore15 "r`wv'ciqscore15:w`wv' JORM handling other everyday arithmetic problems"
label variable r`wv'ciqscore16 "r`wv'ciqscore16:w`wv' JORM reason things through"

*Spouse
forvalues i=1/16 {
	gen s`wv'ciqscore`i'=.
	spouse r`wv'ciqscore`i', result(s`wv'ciqscore`i') wave(`wv')
	label values s`wv'ciqscore`i' ijsca 
}

label variable s`wv'ciqscore1 "s`wv'ciqscore1:w`wv' JORM family/friend details"
label variable s`wv'ciqscore2 "s`wv'ciqscore2:w`wv' JORM recent events"
label variable s`wv'ciqscore3 "s`wv'ciqscore3:w`wv' JORM recent conversations"
label variable s`wv'ciqscore4 "s`wv'ciqscore4:w`wv' JORM address and telephone number"
label variable s`wv'ciqscore5 "s`wv'ciqscore5:w`wv' JORM day and month"
label variable s`wv'ciqscore6 "s`wv'ciqscore6:w`wv' JORM where things are usually kept"
label variable s`wv'ciqscore7 "s`wv'ciqscore7:w`wv' JORM where to find things"
label variable s`wv'ciqscore8 "s`wv'ciqscore8:w`wv' JORM work familiar machines"
label variable s`wv'ciqscore9 "s`wv'ciqscore9:w`wv' JORM new gadget or machine"
label variable s`wv'ciqscore10 "s`wv'ciqscore10:w`wv' JORM new things in general"
label variable s`wv'ciqscore11 "s`wv'ciqscore11:w`wv' JORM story in a book or on TV"
label variable s`wv'ciqscore12 "s`wv'ciqscore12:w`wv' JORM making decisions on everyday matters"
label variable s`wv'ciqscore13 "s`wv'ciqscore13:w`wv' JORM handling money for shopping"
label variable s`wv'ciqscore14 "s`wv'ciqscore14:w`wv' JORM handling financial matters"
label variable s`wv'ciqscore15 "s`wv'ciqscore15:w`wv' JORM handling other everyday arithmetic problems"
label variable s`wv'ciqscore16 "s`wv'ciqscore16:w`wv' JORM reason things through"

***JORM average score
egen r`wv'cjormscore=rowmean(r`wv'ciqscore1-r`wv'ciqscore16)
replace r`wv'cjormscore=round(r`wv'cjormscore,.001)
replace r`wv'cjormscore=.m if r`wv'cjormscore==. & (r`wv'ciqscore1==.m & r`wv'ciqscore2==.m & r`wv'ciqscore3==.m & r`wv'ciqscore4==.m & r`wv'ciqscore5==.m & r`wv'ciqscore6==.m & r`wv'ciqscore7==.m & r`wv'ciqscore8==.m & r`wv'ciqscore9==.m & r`wv'ciqscore10==.m & r`wv'ciqscore11==.m & r`wv'ciqscore12==.m & r`wv'ciqscore13==.m & r`wv'ciqscore14==.m & r`wv'ciqscore15==.m & r`wv'ciqscore16==.m)
replace r`wv'cjormscore=.d if r`wv'cjormscore==. & (r`wv'ciqscore1==.d & r`wv'ciqscore2==.d & r`wv'ciqscore3==.d & r`wv'ciqscore4==.d & r`wv'ciqscore5==.d & r`wv'ciqscore6==.d & r`wv'ciqscore7==.d & r`wv'ciqscore8==.d & r`wv'ciqscore9==.d & r`wv'ciqscore10==.d & r`wv'ciqscore11==.d & r`wv'ciqscore12==.d & r`wv'ciqscore13==.d & r`wv'ciqscore14==.d & r`wv'ciqscore15==.d & r`wv'ciqscore16==.d)
replace r`wv'cjormscore=.p if r`wv'cjormscore==. & (r`wv'ciqscore1==.p & r`wv'ciqscore2==.p & r`wv'ciqscore3==.p & r`wv'ciqscore4==.p & r`wv'ciqscore5==.p & r`wv'ciqscore6==.p & r`wv'ciqscore7==.p & r`wv'ciqscore8==.p & r`wv'ciqscore9==.p & r`wv'ciqscore10==.p & r`wv'ciqscore11==.p & r`wv'ciqscore12==.p & r`wv'ciqscore13==.p & r`wv'ciqscore14==.p & r`wv'ciqscore15==.p & r`wv'ciqscore16==.p)
label variable r`wv'cjormscore "r`wv'cjormscore:w`wv' JORM average score"

*Spouse
gen s`wv'cjormscore=.
spouse r`wv'cjormscore, result(s`wv'cjormscore) wave(`wv')
label variable s`wv'cjormscore "s`wv'cjormscore:w`wv' JORM average score"

drop _iq* 

*********************************************************************
***Cognition Testing Conditions***
*********************************************************************

***Any interruptions during cognition testing
gen r`wv'coginter=.
missing_lasi mh057, result(r`wv'coginter) wave(`wv')
replace r`wv'coginter=.m if mh057==3
replace r`wv'coginter=.p if inlist(mh126,1,2,3)
replace r`wv'coginter=0 if mh057==2
replace r`wv'coginter=1 if mh057==1
label variable r`wv'coginter "r`wv'coginter:w`wv' r any interruptions during cognition testing"
label values r`wv'coginter yesnocog
*spouse 
gen s`wv'coginter=.
spouse r`wv'coginter, result(s`wv'coginter) wave(`wv')
label variable s`wv'coginter "s`wv'coginter:w`wv' s any interruptions during cognition testing"
label values s`wv'coginter yesnocog

***Frequency received assistance during cognition testing
gen r`wv'cogassist=.
missing_lasi mh058, result(r`wv'cogassist) wave(`wv')
replace r`wv'cogassist=.p if inlist(mh126,1,2,3)
replace r`wv'cogassist=mh058 if inrange(mh058,1,3)
label variable r`wv'cogassist "r`wv'cogassist:w`wv' r freq of assistance during cog testing"
label values r`wv'cogassist frequencycog
*spouse 
gen s`wv'cogassist=.
spouse r`wv'cogassist, result(s`wv'cogassist) wave(`wv')
label variable s`wv'cogassist "s`wv'cogassist:w`wv' s freq of assistance during cog testing"
label values s`wv'cogassist frequencycog


*********************************************************************
***Factor Score***
*********************************************************************
rename fgcp r`wv'fgcp
replace r`wv'fgcp = .p if inlist(mh126,1,2,3)
label variable r`wv'fgcp "r`wv'fgcp:w`wv' r factor analysis: general cognitive factor score"

*spouse
gen s`wv'fgcp = .
spouse r`wv'fgcp, result(s`wv'fgcp) wave(`wv')
label variable s`wv'fgcp "s`wv'fgcp:w`wv' s factor analysis: general cognitive factor score"


***************************************


***drop LAsI wave 1 file raw variables***
drop `cog_w1_ind' 






label define momdec      ///
 .f ".f:Dispersed"         ///
 0 "0.no"                ///
 1 "1.yes" 	 ///
 .s ".s=skip" 

label define daddec      ///
 .f ".f:Dispersed"         ///
 0 "0.no"                ///
 1 "1.yes" 	 ///
 .s ".s=skip" 

***Living Arrangement ***   
label define live ///
   1 "1.Lives alone" ///
   2 "2.Lives with spouse only" ///
   3 "3.Lives with children only" ///
   4 "4.Lives with spouse/children" ///
   5 "5.Lives with other hh members" ///
   .r ".r:Refuse" ///
	 .m ".m:Missing" ///
	 .n ".n:n/a" ///
	 .d ".d:DK" ///
	 .s ".s:skipped" ///
	 .p ".p:Proxy" ///
	 .u ".u:Unmar"  

***yes no for family
label define yesnofam ///
   0 "0.no" ///
   1 "1.yes" ///
   .i ".i:invalid" /// 
   .e ".e:error" ///
   .m ".m:missing" ///
   .p ".p:proxy" ///
   .s ".s:skipped" ///
   .d ".d:dk" ///
   .r ".r:refuse" ///
   .u ".u:unmar" ///
   .v ".v:sp nr" ///
   .k ".k:no kids" ///
   .n ".n:not applicable" ///
   .a ".a:age less than 50" ///
   .w ".w:not working" ///
   .g ".g:no grandchildren"
   
***transfers flag
label define trflag ///
   -1 "-1.not imputed, missing neighbors" ///
   -2 "-2.not imputed, missing covariates" ///
   1 "1.continuous value" ///
   2 "2.complete bracket" ///
   3 "3.incomplete bracket" ///
   5 "5.no value/bracket" ///
   6 "6.no transfer" ///
   7 "7.dk transfer" ///
   8 "8.module not answered", replace
	
***frequency
label define freqfam ///
	1 "1.daily" ///
	2 "2.several times a week" ///
	3 "3.once a week" ///
	4 "4.several times a month" ///
	5 "5.at least once a month" ///
	6 "6.rarely/once in a year" ///
	7 "7.never/not relevant"
	
   


*set wave number
local wv=1

***merge with data
local family_w1_ind dm021 dm022 dm023 dm025_? ///
fs201 fs201? fs201_total fs202 fs215 fs213 fs214 ///
												fs301 fs302 fs303 fs304 fs306 fs308 fs310 fs311 fs312 fs313 fs315 fs317 ///
												fs319 fs321_1 fs321_2 fs321_3 fs321_4  ///
												fs324 fs326 fs327 fs501 fs503 fs508 fs510 ///
												fs203_* fs203a_* fs204_* fs401 fs402s* fs404 fs405s* fs210_* 
merge 1:1 prim_key using "$wave_1_ind_bm", keepusing(`family_w1_ind') nogen

***merge with raw indivdual data
local family_w1_in2 fs322_1 fs322_2 fs322_3 fs322_4 fs310_namehh fs301_namehh  
merge 1:1 prim_key using "$wave_1_raw_ind", keepusing(`family_w1_in2') nogen


***merge with wave 1 fs imputations
local family_w1_fsi fs403_i fs403_i_f fs406_i fs406_i_f   
merge 1:1 prim_key using "$wave_1_fs_imput", keepusing(`family_w1_fsi') nogen


***merge with cover screen data
local family_w1_cv cv001 cv003_* cv005_* cv006_* cv008_* cv010_*
merge m:1 hhid using "$wave_1_cv", keepusing(`family_w1_cv')
drop if _merge==2
drop _merge 

*********************************************************************
***Number of People Living in the Household***
*********************************************************************

***# people living in the household
egen hhmem_cv=anycount(cv003_*), values(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16)

gen hh`wv'hhres = .m if inw`wv' == 1
missing_lasi cv001 cv003_? cv003_1? cv003_2? cv003_3? hh`wv'hhresp, result(hh`wv'hhres) wave(`wv')
replace hh`wv'hhres = cv001 if !mi(cv001)
replace hh`wv'hhres = hhmem_cv if hhmem_cv > hh`wv'hhres & !mi(hhmem_cv)
replace hh`wv'hhres = hh`wv'hhresp if hh`wv'hhresp > hh`wv'hhres & !mi(hh`wv'hhresp) & !mi(hh`wv'hhres)
label variable hh`wv'hhres "hh`wv'hhres:w`wv' number of people living in this household"

drop hhmem_cv

*********************************************************************
***Number of Living Children and Grandchildren***
*********************************************************************
*#kids in fs module
gen fskid = 0
forvalues c = 1/21 {
    capture confirm variable fs203a_`c'
    if !_rc {
	    replace fskid = fskid + 1 if fs203_`c'==1 | (fs203_`c'==2 & fs203a_`c'==1)
	}
	else {
	    replace fskid = fskid + 1 if fs203_`c'==1 
	}
}

*# kids in hh from coverscreen
egen cvkid=anycount(cv003_*) if hhorder == 1, values(3 4)

***number of living children 
gen r`wv'child =.
missing_lasi fs201 cv003_? cv003_1? cv003_2? cv003_3? fs203_? fs203_1? fs203_2? fs203a_? fs203a_1?, result(r`wv'child) wave(`wv')
replace r`wv'child = fs201 if inrange(fs201,0,20)
replace r`wv'child = fskid if (fskid > r`wv'child | mi(r`wv'child)) & inrange(fskid,1,20)
replace r`wv'child = cvkid if cvkid > r`wv'child & !mi(r`wv'child) & inrange(cvkid,1,20)
label variable r`wv'child "r`wv'child:w`wv' r number of living children"

*spouse
gen s`wv'child =.
spouse r`wv'child, result(s`wv'child) wave(`wv')
label variable s`wv'child "s`wv'child:w`wv' s number of living children"

****number of living grandchildren 
*# grandkids in hh from coverscreen
egen cvgkid=anycount(cv003_*) if hhorder == 1, values(6)

gen r`wv'grchild =.
missing_lasi fs213 fs214, result(r`wv'grchild) wave(`wv')
replace r`wv'grchild = 0 if fs213 == 2
replace r`wv'grchild = fs214 if inrange(fs214,1,50)
replace r`wv'grchild = cvgkid if cvgkid > r`wv'grchild & !mi(r`wv'grchild) & inrange(cvgkid,1,50)
label variable r`wv'grchild "r`wv'grchild:w`wv' r number of living grandchildren"

*spouse
gen s`wv'grchild =.
spouse r`wv'grchild, result(s`wv'grchild) wave(`wv')
label variable s`wv'grchild "s`wv'grchild:w`wv' s number of living grandchildren"

*********************************************************************
***Number of Deceased Children***
*********************************************************************
*#kids out hh and alive in fs module
gen fskiddc = 0
forvalues c = 1/19 {
	replace fskiddc = fskiddc + 1 if fs203_`c'==2 & fs203a_`c'==2
}

***number of deceased children
gen r`wv'dchild =.
missing_lasi fs202, result(r`wv'dchild) wave(`wv')
replace r`wv'dchild = fs202 if inrange(fs202,0,11)
replace r`wv'dchild = fskiddc if (fskiddc > r`wv'dchild | mi(fskiddc)) & inrange(fskiddc,0,20)
label variable r`wv'dchild "r`wv'dchild:w`wv' r total number of deceased children"

*spouse
gen s`wv'dchild =.
spouse r`wv'dchild, result(s`wv'dchild) wave(`wv')
label variable s`wv'dchild "s`wv'dchild:w`wv' s total number of deceased children"

*********************************************************************
***Number of Living Siblings***
*********************************************************************
***Number of living older brothers  
gen r`wv'livob = .
missing_lasi fs319 fs321_1, result(r`wv'livob) wave(`wv')
replace r`wv'livob = 0 if fs319 == 1
replace r`wv'livob = fs321_1 if inrange(fs321_1,0,10)
label variable r`wv'livob "r`wv'livob:w`wv' r Number of living older brothers"

*spouse  
gen s`wv'livob = .
spouse r`wv'livob, result(s`wv'livob) wave(`wv')
label variable s`wv'livob	"s`wv'livob:w`wv' s Number of living older brothers"

***number of living younger brothers
gen r`wv'livyb = .
missing_lasi fs319 fs321_3, result(r`wv'livyb) wave(`wv')
replace r`wv'livyb = 0 if fs319 == 1
replace r`wv'livyb = fs321_3 if inrange(fs321_3,0,10) 
label variable r`wv'livyb "r`wv'livyb:w`wv' r Number of living younger brothers"

*spouse 
gen s`wv'livyb = .
spouse r`wv'livyb, result(s`wv'livyb) wave(`wv')
label variable s`wv'livyb	"s`wv'livyb:w`wv' s Number of living younger brothers"

***number of living brothers
gen r`wv'livbro=.
missing_lasi r`wv'livob r`wv'livyb, result(r`wv'livbro) wave(`wv')
replace r`wv'livbro = .m if r`wv'livob==.m | r`wv'livyb==.m
replace r`wv'livbro= r`wv'livob + r`wv'livyb if !mi(r`wv'livob) & !mi(r`wv'livyb)
label variable r`wv'livbro "r`wv'livbro:w`wv' r Number of living brothers"

*spouse
gen s`wv'livbro=.
spouse r`wv'livbro, result(s`wv'livbro) wave(`wv')
label variable s`wv'livbro "s`wv'livbro:w`wv' s Number of living brothers"

***number of living older sisters
gen r`wv'livos = .
missing_lasi fs319 fs322_1 , result(r`wv'livos) wave(`wv')
replace r`wv'livos = .m if fs322_1==.e
replace r`wv'livos = 0 if fs319 == 1
replace r`wv'livos = fs322_1 if inrange(fs322_1,0,10) 
label variable r`wv'livos "r`wv'livos:w`wv' r Number of living older sisters"

*spouse 
gen s`wv'livos = .
spouse r`wv'livos, result(s`wv'livos) wave(`wv')
label variable s`wv'livos "s`wv'livos:w`wv' s Number of living older sisters"

***number of living younger sisters
gen r`wv'livys = .
missing_lasi fs319 fs322_3 , result(r`wv'livys) wave(`wv')
replace r`wv'livys = 0 if fs319 == 1
replace r`wv'livys = fs322_3 if inrange(fs322_3,0,10) 
label variable r`wv'livys "r`wv'livys:w`wv' r Number of living younger sisters"

*spouse 
gen s`wv'livys = .
spouse r`wv'livys, result(s`wv'livys) wave(`wv')
label variable s`wv'livys "s`wv'livys:w`wv' s Number of living younger sisters"

***number of living sisters
gen r`wv'livsis=.
missing_lasi r`wv'livos r`wv'livys, result(r`wv'livsis) wave(`wv')
replace r`wv'livsis = .m if r`wv'livos==.m | r`wv'livys==.m
replace r`wv'livsis= r`wv'livos + r`wv'livys if !mi(r`wv'livos) & !mi(r`wv'livys)
label variable r`wv'livsis "r`wv'livsis:w`wv' r Number of living sisters"

*spouse 
gen s`wv'livsis=.
spouse r`wv'livsis, result(s`wv'livsis) wave(`wv')
label variable s`wv'livsis "s`wv'livsis:w`wv' s Number of living sisters"

***number of living siblings
gen r`wv'livsib=.
missing_lasi r`wv'livsis r`wv'livbro, result(r`wv'livsib) wave(`wv')
replace r`wv'livsib = .m if r`wv'livsis==.m | r`wv'livbro==.m
replace r`wv'livsib= r`wv'livsis + r`wv'livbro if !mi(r`wv'livsis) & !mi(r`wv'livbro)
label variable r`wv'livsib "r`wv'livsib:w`wv' r Number of living siblings"

*spouse  
gen s`wv'livsib=.
spouse r`wv'livsib, result(s`wv'livsib) wave(`wv')
label variable s`wv'livsib "s`wv'livsib:w`wv' s Number of living siblings"

drop r`wv'livob r`wv'livyb r`wv'livos r`wv'livys s`wv'livob s`wv'livyb s`wv'livos s`wv'livys

*********************************************************************
***Number of Deceased Siblings***
*********************************************************************
***number of deceased older brothers
gen r`wv'decob=.
missing_lasi fs319 fs321_2 , result(r`wv'decob) wave(`wv')
replace r`wv'decob = 0 if fs319 == 1
replace r`wv'decob = fs321_2 if inrange(fs321_2,0,10)
label variable r`wv'decob "r`wv'decob:w`wv' r Number of deceased older brothers"

*spouse  
gen s`wv'decob=.
spouse r`wv'decob, result(s`wv'decob) wave(`wv')
label variable s`wv'decob "s`wv'decob:w`wv' s numbers of deceased older brothers"

***number of deceased younger brothers
gen r`wv'decyb=.
missing_lasi fs319 fs321_4 , result(r`wv'decyb) wave(`wv')
replace r`wv'decyb = 0 if fs319 == 1
replace r`wv'decyb = fs321_4 if inrange(fs321_4,0,10)
label variable r`wv'decyb "r`wv'decyb:w`wv' r Number of deceased younger brothers"

*spouse 
gen s`wv'decyb=.
spouse r`wv'decyb, result(s`wv'decyb) wave(`wv')
label variable s`wv'decyb "s`wv'decyb:w`wv' s Number of deceased younger brothers"

***number of deceased brothers
gen r`wv'decbro=.
missing_lasi r`wv'decob r`wv'decyb, result(r`wv'decbro) wave(`wv')
replace r`wv'decbro = .m if r`wv'decob==.m | r`wv'decyb==.m
replace r`wv'decbro= r`wv'decob + r`wv'decyb if !mi(r`wv'decob) & !mi(r`wv'decyb)
label variable r`wv'decbro "r`wv'decbro:w`wv' r Number of deceased brothers"

*spouse
gen s`wv'decbro=.
spouse r`wv'decbro, result(s`wv'decbro) wave(`wv')
label variable s`wv'decbro "s`wv'decbro:w`wv' s Number of deceased brothers"

***number of deceased older sisters
gen r`wv'decos=.
missing_lasi fs319 fs322_2 , result(r`wv'decos) wave(`wv')
replace r`wv'decos= 0 if fs319 == 1
replace r`wv'decos= fs322_2 if inrange(fs322_2,0,10) 
label variable r`wv'decos "r`wv'decos:w`wv' r Number of deceased older sisters"

*spouse
gen s`wv'decos=.
spouse r`wv'decos, result(s`wv'decos) wave(`wv')
label variable s`wv'decos "s`wv'decos:w`wv' s Number of deceased older sisters"

***number of deceased younger sisters
gen r`wv'decys=.
missing_lasi fs319 fs322_4 , result(r`wv'decys) wave(`wv')
replace r`wv'decys= 0 if fs319 == 1
replace r`wv'decys= fs322_4 if inrange(fs322_4,0,10) 
label variable r`wv'decys "r`wv'decys:w`wv' r Number of deceased younger sisters"

*spouse  
gen s`wv'decys=.
spouse r`wv'decys, result(s`wv'decys) wave(`wv')
label variable s`wv'decys "s`wv'decys:w`wv' s Number of deceased younger sisters"

***number of deceased sisters
gen r`wv'decsis=.
missing_lasi r`wv'decos r`wv'decys, result(r`wv'decsis) wave(`wv')
replace r`wv'decsis = .m if r`wv'decos==.m | r`wv'decys==.m
replace r`wv'decsis= r`wv'decos + r`wv'decys if !mi(r`wv'decos) & !mi(r`wv'decys)
label variable r`wv'decsis "r`wv'decsis:w`wv' r Number of deceased sisters"

*spouse  
gen s`wv'decsis=.
spouse r`wv'decsis, result(s`wv'decsis) wave(`wv')
label variable s`wv'decsis "s`wv'decsis:w`wv' s Number of deceased sisters"

***number of deceased siblings
gen r`wv'decsib=.
missing_lasi r`wv'decsis r`wv'decbro, result(r`wv'decsib) wave(`wv')
replace r`wv'decsib = .m if r`wv'decsis==.m | r`wv'decbro==.m
replace r`wv'decsib=r`wv'decsis + r`wv'decbro if !mi(r`wv'decsis) & !mi(r`wv'decbro)
label variable r`wv'decsib "r`wv'decsib:w`wv' r Number of deceased siblings"

*spouse  
gen s`wv'decsib=.
spouse r`wv'decsib, result(s`wv'decsib) wave(`wv')
label variable s`wv'decsib "s`wv'decsib:w`wv' s Number of deceased siblings"

drop r`wv'decob r`wv'decyb r`wv'decos r`wv'decys s`wv'decob s`wv'decyb s`wv'decos s`wv'decys

*********************************************************************
***Parental Mortality***
*********************************************************************
***mother alive
gen r`wv'momliv = . 
missing_lasi fs310 fs311, result(r`wv'momliv) wave(`wv')
replace r`wv'momliv = 0 if fs311 == 2
replace r`wv'momliv = 1 if fs310 == 1 | fs311 == 1 
forvalues p = 1/35 {
    replace r`wv'momliv = 1 if cv003_`p' == 7 & cv005_`p' == 2 & hhorder == 1
}
label variable r`wv'momliv "r`wv'momliv:w`wv' r mother alive"
label values r`wv'momliv yesnofam

*spouse mother
gen s`wv'momliv =.
spouse r`wv'momliv, result(s`wv'momliv) wave(`wv')
label variable s`wv'momliv "s`wv'momliv:w`wv' s mother alive"
label values s`wv'momliv yesnofam

***father alive
gen r`wv'dadliv = . 
missing_lasi fs301 fs302, result(r`wv'dadliv) wave(`wv')
replace r`wv'dadliv = 0 if fs302 == 2
replace r`wv'dadliv = 1 if fs301 == 1 | fs302 == 1 
forvalues p = 1/35 {
    replace r`wv'dadliv = 1 if cv003_`p' == 7 & cv005_`p' == 1 & hhorder == 1
}
label variable r`wv'dadliv "r`wv'dadliv:w`wv' r father alive"
label values r`wv'dadliv yesnofam

*spouse 
gen s`wv'dadliv =.
spouse r`wv'dadliv, result(s`wv'dadliv) wave(`wv')
label variable s`wv'dadliv "s`wv'dadliv:w`wv' s father alive"
label values s`wv'dadliv yesnofam

***number of living parents 
gen r`wv'livpar = .
missing_lasi r`wv'momliv r`wv'dadliv, result(r`wv'livpar) wave(`wv')
replace r`wv'livpar = .m if r`wv'momliv==.m | r`wv'dadliv==.m
replace r`wv'livpar = 0 if !missing(r`wv'momliv) & !missing(r`wv'dadliv)
replace r`wv'livpar = r`wv'livpar + 1 if r`wv'momliv == 1 & !mi(r`wv'dadliv)
replace r`wv'livpar = r`wv'livpar + 1 if r`wv'dadliv == 1 & !mi(r`wv'momliv)
label var r`wv'livpar	"r`wv'livpar:w`wv' r # of living parents"

*spouse  
gen s`wv'livpar = .
spouse r`wv'livpar, result(s`wv'livpar) wave(`wv')
label var s`wv'livpar	"s`wv'livpar:w`wv' s # of living parents"

***mother's current age or age at death
gen r`wv'momage =.
missing_lasi fs310 fs311 fs312 fs313, result(r`wv'momage) wave(`wv')
replace r`wv'momage = .i if fs313 == 0
replace r`wv'momage = fs312 if r`wv'momliv == 1 & inrange(fs312,35,120)
replace r`wv'momage = fs313 if r`wv'momliv == 0 & inrange(fs313,1,120)
qui levelsof fs310_namehh, local(hhpids)
foreach hhpid of local hhpids {
    replace r`wv'momage = cv006_`hhpid' if inrange(cv006_`hhpid',1,116) & fs310_namehh == `hhpid'
}
forvalues p = 1/35 {
    replace r`wv'momage = cv006_`p' if inrange(cv006_`p',1,116) & cv003_`p' == 7 & cv005_`p' == 2 & hhorder == 1
}
label variable r`wv'momage "r`wv'momage:w`wv' r mother age current/at death"

*spouse 
gen s`wv'momage =.
spouse r`wv'momage, result(s`wv'momage) wave(`wv')
label variable s`wv'momage "s`wv'momage:w`wv' s mother age current/at death"

***father's current age or age at death 
gen r`wv'dadage =.
missing_lasi fs301 fs302 fs303 fs304, result(r`wv'dadage) wave(`wv')
replace r`wv'dadage = .i if fs304 == 0
replace r`wv'dadage = fs303 if r`wv'dadliv == 1 & inrange(fs303,1,120)
replace r`wv'dadage = fs304 if r`wv'dadliv == 0 & inrange(fs304,1,120)
qui levelsof fs301_namehh, local(hhpids)
foreach hhpid of local hhpids {
    replace r`wv'dadage = cv006_`hhpid' if inrange(cv006_`hhpid',1,116) & fs301_namehh == `hhpid'
}
forvalues p = 1/35 {
    replace r`wv'dadage = cv006_`p' if inrange(cv006_`p',1,116) & cv003_`p' == 7 & cv005_`p' == 1 & hhorder == 1
}
label variable r`wv'dadage "r`wv'dadage:w`wv' r father age current/at death"

*spouse  
gen s`wv'dadage =.
spouse r`wv'dadage, result(s`wv'dadage) wave(`wv')
label variable s`wv'dadage "s`wv'dadage:w`wv' s father age current/at death"

*********************************************************************
***Parents' Education***
*********************************************************************
***mother's education
gen rameduc_l = .
missing_lasi fs315 fs317, result(rameduc_l) wave(`wv')
replace rameduc_l = 0 if fs315==2 
replace rameduc_l = fs317 if inrange(fs317,1,9)
qui levelsof fs310_namehh, local(hhpids)
foreach hhpid of local hhpids {
    replace rameduc_l = 0 if cv008_`hhpid' == 2 & fs310_namehh == `hhpid' & mi(rameduc_l)
    replace rameduc_l = cv010_`hhpid' if inrange(cv010_`hhpid',1,9) & fs310_namehh == `hhpid' & mi(rameduc_l)
}
forvalues p = 1/35 {
    replace rameduc_l = 0 if cv008_`p' == 2 & cv003_`p' == 7 & cv005_`p' == 2 & hhorder == 1 & mi(rameduc_l)
    replace rameduc_l = cv010_`p' if inrange(cv010_`p',1,9) & cv003_`p' == 7 & cv005_`p' == 2 & hhorder == 1 & mi(rameduc_l)
}
label variable rameduc_l "rameduc_l:r mother's education"
label values rameduc_l raeduc_l

*spouse  
gen s`wv'meduc_l = .
spouse rameduc_l, result(s`wv'meduc_l) wave(`wv')
label variable s`wv'meduc_l "s`wv'meduc_l:w`wv' s mother's education"
label values s`wv'meduc_l raeduc_l

***mother's education - harmonized
gen ramomeducl=.
missing_lasi fs315 fs317, result(ramomeducl) wave(`wv')
replace ramomeducl=1 if fs315==2
replace ramomeducl=1 if inlist(fs317,1,2)
replace ramomeducl=2 if inlist(fs317,3,4,5,6)
replace ramomeducl=3 if inlist(fs317,7,8,9)
qui levelsof fs310_namehh, local(hhpids)
foreach hhpid of local hhpids {
		replace ramomeducl=1 if cv008_`hhpid' == 2 & fs310_namehh == `hhpid' & mi(ramomeducl)
		replace ramomeducl=1 if inlist(cv010_`hhpid',1,2) & fs310_namehh == `hhpid' & mi(ramomeducl)
		replace ramomeducl=2 if inlist(cv010_`hhpid',3,4,5,6) & fs310_namehh == `hhpid' & mi(ramomeducl)
		replace ramomeducl=3 if inlist(cv010_`hhpid',7,8,9) & fs310_namehh == `hhpid' & mi(ramomeducl)
}
forvalues p = 1/35 {
		replace ramomeducl=1 if cv008_`p' == 2 & cv003_`p' == 7 & cv005_`p' == 2 & hhorder == 1 & mi(ramomeducl)
		replace ramomeducl=1 if inlist(cv010_`p',1,2) & cv003_`p' == 7 & cv005_`p' == 2 & hhorder == 1 & mi(ramomeducl)
		replace ramomeducl=2 if inlist(cv010_`p',3,4,5,6) & cv003_`p' == 7 & cv005_`p' == 2 & hhorder == 1 & mi(ramomeducl)
		replace ramomeducl=3 if inlist(cv010_`p',7,8,9) & cv003_`p' == 7 & cv005_`p' == 2 & hhorder == 1 & mi(ramomeducl)
}
label variable ramomeducl "ramomeducl:r mother harmonized education level"
label values ramomeducl educl

*spouse
gen s`wv'momeducl=.
spouse ramomeducl, result(s`wv'momeducl) wave(`wv')
label variable s`wv'momeducl "s`wv'momeducl:w`wv' s mother harmonized education level"
label values s`wv'momeducl educl

***father's education
gen rafeduc_l = .
missing_lasi fs306 fs308, result(rafeduc_l) wave(`wv')
replace rafeduc_l = 0 if fs306==2 
replace rafeduc_l = fs308 if inrange(fs308,1,9)
qui levelsof fs301_namehh, local(hhpids)
foreach hhpid of local hhpids {
    replace rafeduc_l = 0 if cv008_`hhpid' == 2 & fs301_namehh == `hhpid' & mi(rafeduc_l)
    replace rafeduc_l = cv010_`hhpid' if inrange(cv010_`hhpid',1,9) & fs301_namehh == `hhpid' & mi(rafeduc_l)
}
forvalues p = 1/35 {
    replace rafeduc_l = 0 if cv008_`p' == 2 & cv003_`p' == 7 & cv005_`p' == 1 & hhorder == 1 & mi(rafeduc_l)
    replace rafeduc_l = cv010_`p' if inrange(cv010_`p',1,9) & cv003_`p' == 7 & cv005_`p' == 1 & hhorder == 1 & mi(rafeduc_l)
}
label variable rafeduc_l "rafeduc_l:r father's education"
label values rafeduc_l raeduc_l

*spouse 
gen s`wv'feduc_l = .
spouse rafeduc_l, result(s`wv'feduc_l) wave(`wv')
label variable s`wv'feduc_l "s`wv'feduc_l:w`wv' s father's education"
label values s`wv'feduc_l raeduc_l

***father's education - harmonized
gen radadeducl=.
missing_lasi fs306 fs308, result(radadeducl) wave(`wv')
replace radadeducl=1 if fs306==2
replace radadeducl=1 if inlist(fs308,1,2)
replace radadeducl=2 if inlist(fs308,3,4,5,6)
replace radadeducl=3 if inlist(fs308,7,8,9)
qui levelsof fs301_namehh, local(hhpids)
foreach hhpid of local hhpids {
	replace radadeducl=1 if cv008_`hhpid' == 2 & fs301_namehh == `hhpid' & mi(radadeducl)
	replace radadeducl=1 if inlist(cv010_`hhpid',1,2) & fs301_namehh == `hhpid' & mi(radadeducl)
	replace radadeducl=2 if inlist(cv010_`hhpid',3,4,5,6) & fs301_namehh == `hhpid' & mi(radadeducl)
	replace radadeducl=3 if inlist(cv010_`hhpid',7,8,9) & fs301_namehh == `hhpid' & mi(radadeducl)
}
forvalues p = 1/35 {
	replace radadeducl=1 if cv008_`p' == 2 & cv003_`p' == 7 & cv005_`p' == 1 & hhorder == 1 & mi(radadeducl)
	replace radadeducl=1 if inlist(cv010_`p',1,2) & cv003_`p' == 7 & cv005_`p' == 1 & hhorder == 1 & mi(radadeducl)
	replace radadeducl=2 if inlist(cv010_`p',3,4,5,6) & cv003_`p' == 7 & cv005_`p' == 1 & hhorder == 1 & mi(radadeducl)
	replace radadeducl=3 if inlist(cv010_`p',7,8,9) & cv003_`p' == 7 & cv005_`p' == 1 & hhorder == 1 & mi(radadeducl)
}
label variable radadeducl "radadeducl:r father harmonized education level"
label values radadeducl educl

*spouse
gen s`wv'dadeducl=.
spouse radadeducl, result(s`wv'dadeducl) wave(`wv')
label variable s`wv'dadeducl "s`wv'dadeducl:w`wv' s father harmonized education level"
label values s`wv'dadeducl educl


*********************************************************************
***Whether Any Child Co-Resides with Respondent***
*********************************************************************
*#kids co-residing fs module
gen fskidin = 0
forvalues c = 1/21 {
    replace fskidin = fskid + 1 if fs203_`c'==1 
}

***any co-residing children
gen r`wv'coresd = .
missing_lasi r`wv'child, result(r`wv'coresd) wave(`wv')
replace r`wv'coresd = .k if r`wv'child==0
replace r`wv'coresd = 0 if inrange(r`wv'child,1,20) 
replace r`wv'coresd = 1 if (inrange(cvkid,1,20) | inrange(fskidin,1,20))
label variable r`wv'coresd "r`wv'coresd:w`wv' r any child co-resides with r"
label values r`wv'coresd yesnofam

*spouse
gen s`wv'coresd = . 
spouse r`wv'coresd, result(s`wv'coresd) wave(`wv')
label variable s`wv'coresd "s`wv'coresd:w`wv' s any child co-resides with s"
label values s`wv'coresd yesnofam

*********************************************************************
***Whether a Child Lives Nearby***
*********************************************************************
*#kids out hh and alive in fs module
gen fskidnr = 0
forvalues c = 1/19 {
	replace fskidnr = fskidnr + 1 if fs203_`c'==2 & fs203a_`c'==1 & fs210_`c'==1
}
replace fskidnr = . if inw`wv'==0

***any child lives near
gen r`wv'lvnear = .
missing_lasi r`wv'child r`wv'coresd fs210_? fs210_1?, result(r`wv'lvnear) wave(`wv')
replace r`wv'lvnear = .k if r`wv'child==0
replace r`wv'lvnear = 0 if inrange(r`wv'child,1,20)
replace r`wv'lvnear = 1 if r`wv'coresd==1 | inrange(fskidnr,1,20)
label variable r`wv'lvnear "r`wv'lvnear:w`wv' r any child lives nearby"
label values r`wv'lvnear yesnofam

*spouse
gen s`wv'lvnear = .
spouse r`wv'lvnear, result(s`wv'lvnear) wave(`wv')
label variable s`wv'lvnear "s`wv'lvnear:w`wv' s any child lives nearby"
label values s`wv'lvnear yesnofam

*********************************************************************
***Living arrangement***
*********************************************************************
*number of spouses in the house
gen spsin = .
replace spsin = 0 if inrange(dm021,2,7)
forvalues s = 1/6 {
	replace spsin = 0 if inlist(dm025_`s',1,2)
}
forvalues s = 1/6 {
	replace spsin = spsin + 1 if dm025_`s'==1
}

*number of children in the house
egen kidsin = rowmax(cvkid fskidin)
 
*number of others in the house
gen othsin = hh`wv'hhres - 1 - spsin - kidsin
replace othsin = 0 if inrange(othsin,-10,-1)

***living arrangement
gen r`wv'lvwith = . 
missing_lasi hh`wv'hhres dm025_? fs203_? fs203_1? fs203_2?, result(r`wv'lvwith) wave(`wv')
replace r`wv'lvwith = 1 if hh`wv'hhres==1 & hh`wv'hhresp==1
replace r`wv'lvwith = 2 if inrange(spsin,1,4) & r`wv'coresd==0 & othsin==0
replace r`wv'lvwith = 3 if spsin==0 & r`wv'coresd==1 & othsin==0
replace r`wv'lvwith = 4 if inrange(spsin,1,4) & r`wv'coresd==1 & othsin==0
replace r`wv'lvwith = 5 if inrange(othsin,1,35)
label variable r`wv'lvwith "r`wv'lvwith:w`wv' r living arrangement"
label values r`wv'lvwith live

*spouse
gen s`wv'lvwith=.
spouse r`wv'lvwith, result(s`wv'lvwith) wave(`wv')
label variable s`wv'lvwith "s`wv'lvwith:w`wv' s living arrangement"
label values s`wv'lvwith live

drop cvkid fskidin fskid cvgkid kidsin fskiddc fskidnr spsin othsin

*********************************************************************
***Financial Transfers Received***
*********************************************************************

***transfers from kids/grandkids
gen r`wv'fcany = .
missing_lasi fs401 fs402s2 fs402s3 fs402s4 fs402s5 fs402s6, result(r`wv'fcany) wave(`wv')
replace r`wv'fcany = 0 if fs401==2 | fs402s2==0 | fs402s3==0 | fs402s4==0 | fs402s5==0 | fs402s6==0
replace r`wv'fcany = 1 if fs402s2==1 | fs402s3==1 | fs402s4==1 | fs402s5==1 | fs402s6==1
label variable r`wv'fcany "r`wv'fcany:w`wv' r any transfers from children/grandchildren"
label values r`wv'fcany yesnofam

*spouse
gen s`wv'fcany = .
spouse r`wv'fcany, result(s`wv'fcany) wave(`wv')
label variable s`wv'fcany "s`wv'fcany:w`wv' s any transfers from children/grandchildren"
label values s`wv'fcany yesnofam

***transfers from parents
gen r`wv'fpany = .
missing_lasi fs401 fs402s7 fs402s8, result(r`wv'fpany) wave(`wv')
replace r`wv'fpany = 0 if fs401==2 | fs402s7==0 | fs402s8==0
replace r`wv'fpany = 1 if fs402s7==1 | fs402s8==1 
label variable r`wv'fpany "r`wv'fpany:w`wv' r any transfers from parents"
label values r`wv'fpany yesnofam

*spouse
gen s`wv'fpany = .
spouse r`wv'fpany, result(s`wv'fpany) wave(`wv')
label variable s`wv'fpany "s`wv'fpany:w`wv' s any transfers from parents"
label values s`wv'fpany yesnofam

***transfers from others
gen r`wv'foany = .
missing_lasi fs401 fs402s9 fs402s10 fs402s11 fs402s12 fs402s13 fs402s14, result(r`wv'foany) wave(`wv')
replace r`wv'foany = 0 if fs401==2 | fs402s9==0 | fs402s10==0 | fs402s11==0 | fs402s12==0 | fs402s13==0 | fs402s14==0
replace r`wv'foany = 1 if fs402s9==1 | fs402s10==1 | fs402s11==1 | fs402s12==1 | fs402s13==1 | fs402s14==1
label variable r`wv'foany "r`wv'foany:w`wv' r any transfers from others"
label values r`wv'foany yesnofam

*spouse
gen s`wv'foany = .
spouse r`wv'foany, result(s`wv'foany) wave(`wv')
label variable s`wv'foany "s`wv'foany:w`wv' s any transfers from others"
label values s`wv'foany yesnofam

*********************************************************************
***Financial Transfers Received***
*********************************************************************

***transfers to kids/grandkids
gen r`wv'tcany = .
missing_lasi fs404 fs405s2 fs405s3 fs405s4 fs405s5 fs405s6, result(r`wv'tcany) wave(`wv')
replace r`wv'tcany = 0 if fs404==2 | fs405s2==0 | fs405s3==0 | fs405s4==0 | fs405s5==0 | fs405s6==0
replace r`wv'tcany = 1 if fs405s2==1 | fs405s3==1 | fs405s4==1 | fs405s5==1 | fs405s6==1
label variable r`wv'tcany "r`wv'tcany:w`wv' r any transfers to children/grandchildren"
label values r`wv'tcany yesnofam

*spouse
gen s`wv'tcany = .
spouse r`wv'tcany, result(s`wv'tcany) wave(`wv')
label variable s`wv'tcany "s`wv'tcany:w`wv' s any transfers to children/grandchildren"
label values s`wv'tcany yesnofam

***transfers to parents
gen r`wv'tpany = .
missing_lasi fs404 fs405s7 fs405s8, result(r`wv'tpany) wave(`wv')
replace r`wv'tpany = 0 if fs404==2 | fs405s7==0 | fs405s8==0
replace r`wv'tpany = 1 if fs405s7==1 | fs405s8==1 
label variable r`wv'tpany "r`wv'tpany:w`wv' r any transfers to parents"
label values r`wv'tpany yesnofam

*spouse
gen s`wv'tpany = .
spouse r`wv'tpany, result(s`wv'tpany) wave(`wv')
label variable s`wv'tpany "s`wv'tpany:w`wv' s any transfers to parents"
label values s`wv'tpany yesnofam

***transfers to others
gen r`wv'toany = .
missing_lasi fs404 fs405s9 fs405s10 fs405s11 fs405s12 fs405s13 fs405s14 fs405s15, result(r`wv'toany) wave(`wv')
replace r`wv'toany = 0 if fs404==2 | fs405s9==0 | fs405s10==0 | fs405s11==0 | fs405s12==0 | fs405s13==0 | fs405s14==0 | fs405s15==0
replace r`wv'toany = 1 if fs405s9==1 | fs405s10==1 | fs405s11==1 | fs405s12==1 | fs405s13==1 | fs405s14==1 | fs405s15==1
label variable r`wv'toany "r`wv'toany:w`wv' r any transfers to others"
label values r`wv'toany yesnofam

*spouse
gen s`wv'toany = .
spouse r`wv'toany, result(s`wv'toany) wave(`wv')
label variable s`wv'toany "s`wv'toany:w`wv' s any transfers to others"
label values s`wv'toany yesnofam

*********************************************************************
***Total Family Financial Transfers***
*********************************************************************

***total transfers received
gen r`wv'frec = .
missing_lasi fs403_i, result(r`wv'frec) wave(`wv')
replace r`wv'frec = fs403_i if inrange(fs403_i,0,10000000)
label variable r`wv'frec "r`wv'frec:w`wv' r total amount of transfers received"

*spouse
gen s`wv'frec = .
spouse r`wv'frec, result(s`wv'frec) wave(`wv')
label variable s`wv'frec "s`wv'frec:w`wv' s total amount of transfers received"

*total transfers received flag
gen r`wv'ffrec = .
replace r`wv'ffrec = fs403_i_f if inrange(fs403_i_f,-2,8)
label variable r`wv'ffrec "r`wv'ffrec:w`wv' r flag total amount of transfers received"
label values r`wv'ffrec trflag

*spouse
gen s`wv'ffrec = .
spouse r`wv'ffrec, result(s`wv'ffrec) wave(`wv')
label variable s`wv'ffrec "s`wv'ffrec:w`wv' s flag total amount of transfers received"
label values s`wv'ffrec trflag

***total transfers given
gen r`wv'tgiv = .
missing_lasi fs406_i, result(r`wv'tgiv) wave(`wv')
replace r`wv'tgiv = fs406_i if inrange(fs406_i,0,10000000)
label variable r`wv'tgiv "r`wv'tgiv:w`wv' r total amount of transfers given"

*spouse
gen s`wv'tgiv = .
spouse r`wv'tgiv, result(s`wv'tgiv) wave(`wv')
label variable s`wv'tgiv "s`wv'tgiv:w`wv' s total amount of transfers given"

*total transfers given flag
gen r`wv'ftgiv = .
replace r`wv'ftgiv = fs406_i_f if inrange(fs406_i_f,-2,8)
label variable r`wv'ftgiv "r`wv'ftgiv:w`wv' r flag total amount of transfers given"
label values r`wv'ftgiv trflag

*spouse
gen s`wv'ftgiv = .
spouse r`wv'ftgiv, result(s`wv'ftgiv) wave(`wv')
label variable s`wv'ftgiv "s`wv'ftgiv:w`wv' s flag total amount of transfers given"
label values s`wv'ftgiv trflag

***net value of financial transfers
gen r`wv'ftot = .
missing_lasi r`wv'frec r`wv'tgiv, result(r`wv'ftot) wave(`wv')
replace r`wv'ftot = r`wv'frec - r`wv'tgiv if !mi(r`wv'frec) & !mi(r`wv'tgiv)
label variable r`wv'ftot "r`wv'ftot:w`wv' r net value of financial transfers"

*spouse
gen s`wv'ftot = .
spouse r`wv'ftot, result(s`wv'ftot) wave(`wv')
label variable s`wv'ftot "s`wv'ftot:w`wv' s net value of financial transfers"

*net value of financial transfers flag
gen r`wv'fftot = .
combine_h_inc_flag r`wv'ffrec r`wv'ftgiv, result(r`wv'fftot)
label variable r`wv'fftot "r`wv'fftot:w`wv' r flag net value of financial transfers"
label values r`wv'fftot trflag

*spouse
gen s`wv'fftot = .
spouse r`wv'fftot, result(s`wv'fftot) wave(`wv')
label variable s`wv'fftot "s`wv'fftot:w`wv' s flag net value of financial transfers"
label values s`wv'fftot trflag


**********************************************************************
*Social Contact/Activities
**********************************************************************
***meet with friends in person weekly
gen r`wv'fcntf = .
missing_lasi fs324 fs326, result(r`wv'fcntf) wave(`wv')
replace r`wv'fcntf = 0 if fs324==2 | inlist(fs326,3,4,5)
replace r`wv'fcntf = 1 if inlist(fs326,1,2)
label variable r`wv'fcntf "r`wv'fcntf:w`wv' r any weekly contact w/ friend in person"
label values r`wv'fcntf yesnofam

*spouse 
gen s`wv'fcntf = .
spouse r`wv'fcntf, result(s`wv'fcntf) wave(`wv')
label variable s`wv'fcntf "s`wv'fcntf:w`wv' s any weekly contact w/ friend in person"
label values s`wv'fcntf yesnofam

***phone/email friends weekly
gen r`wv'fcntpm = .
missing_lasi fs324 fs327, result(r`wv'fcntpm) wave(`wv')
replace r`wv'fcntpm = 0 if fs324==2 | inlist(fs327,3,4,5)
replace r`wv'fcntpm = 1 if inlist(fs327,1,2)
label variable r`wv'fcntpm "r`wv'fcntpm:w`wv' r any weekly contact w/ friend phone/mail/email"
label values r`wv'fcntpm yesnofam

*spouse
gen s`wv'fcntpm = .
spouse r`wv'fcntpm, result(s`wv'fcntpm) wave(`wv')
label variable s`wv'fcntpm "s`wv'fcntpm:w`wv' s any weekly contact w/ friend phone/mail/email"
label values s`wv'fcntpm yesnofam

***any contact friend weekly
gen r`wv'fcnt = .
missing_lasi fs324 fs326 fs327, result(r`wv'fcnt) wave(`wv')
replace r`wv'fcnt = 0 if fs324==2 | inlist(fs326,3,4,5) | inlist(fs327,3,4,5)
replace r`wv'fcnt = 1 if inlist(fs326,1,2) | inlist(fs327,1,2)
label variable r`wv'fcnt "r`wv'fcnt:w`wv' r any weekly contact w/ friend in person/phone/mail/email"
label values r`wv'fcnt yesnofam

*spouse 
gen s`wv'fcnt = .
spouse r`wv'fcnt, result(s`wv'fcnt) wave(`wv')
label variable s`wv'fcnt "s`wv'fcnt:w`wv' s any weekly contact w/ friend in person/phone/mail/email"
label values s`wv'fcnt yesnofam

***weekly visit with relatives/friends
gen r`wv'rfcntf = .
missing_lasi fs508, result(r`wv'rfcntf) wave(`wv')
replace r`wv'rfcntf = 0 if inlist(fs508,4,5,6,7)
replace r`wv'rfcntf = 1 if inlist(fs508,1,2,3)
label variable r`wv'rfcntf "r`wv'rfcntf:w`wv' r any weekly contact with relative/friend in person"
label values r`wv'rfcntf yesnofam

*spouse 
gen s`wv'rfcntf = .
spouse r`wv'rfcntf, result(s`wv'rfcntf) wave(`wv')
label variable s`wv'rfcntf "s`wv'rfcntf:w`wv' s any weekly contact with relative/friend in person"
label values s`wv'rfcntf yesnofam

***any yearly social activities
gen r`wv'socyr = .
missing_lasi fs501 fs503, result(r`wv'socyr) wave(`wv')
replace r`wv'socyr = 0 if fs501==2 | fs503==6
replace r`wv'socyr = 1 if inrange(fs503,1,5)
label variable r`wv'socyr "r`wv'socyr:w`wv' r participates in social activities yearly"
label values r`wv'socyr yesnofam

*spouse 
gen s`wv'socyr = .
spouse r`wv'socyr, result(s`wv'socyr) wave(`wv')
label variable s`wv'socyr "s`wv'socyr:w`wv' s participates in social activities yearly"
label values s`wv'socyr yesnofam

***any weekly social activities
gen r`wv'socwk = .
missing_lasi fs501 fs503, result(r`wv'socwk) wave(`wv')
replace r`wv'socwk = 0 if fs501==2 | inlist(fs503,3,4,5,6)
replace r`wv'socwk = 1 if inlist(fs503,1,2)
label variable r`wv'socwk "r`wv'socwk:w`wv' r participates in social activities weekly"
label values r`wv'socwk yesnofam

*spouse
gen s`wv'socwk = .
spouse r`wv'socwk, result(s`wv'socwk) wave(`wv')
label variable s`wv'socwk "s`wv'socwk:w`wv' s participates in social activities weekly"
label values s`wv'socwk yesnofam

***any weekly religious activities
gen r`wv'relgwk = .
missing_lasi fs510, result(r`wv'relgwk) wave(`wv')
replace r`wv'relgwk = 0 if inlist(fs510,4,5,6,7)
replace r`wv'relgwk = 1 if inlist(fs510,1,2,3)
label variable r`wv'relgwk "r`wv'relgwk:w`wv' r participates in religious functions weekly"
label values r`wv'relgwk yesnofam

*spouse 
gen s`wv'relgwk = .
spouse r`wv'relgwk, result(s`wv'relgwk) wave(`wv')
label variable s`wv'relgwk "s`wv'relgwk:w`wv' s participates in religious functions weekly"
label values s`wv'relgwk yesnofam

***frequency religious activities
gen r`wv'socrelg_l = .
missing_lasi fs510, result(r`wv'socrelg_l) wave(`wv')
replace r`wv'socrelg_l = fs510 if inrange(fs510,1,7)
label variable r`wv'socrelg_l "r`wv'socrelg_l:w`wv' r freq participates in religious functions"
label values r`wv'socrelg_l freqfam

*spouse 
gen s`wv'socrelg_l = .
spouse r`wv'socrelg_l, result(s`wv'socrelg_l) wave(`wv')
label variable s`wv'socrelg_l "s`wv'socrelg_l:w`wv' s freq participates in religious functions"
label values s`wv'socrelg_l freqfam



****drop family core raw variables***
drop `family_w1_ind'
drop `family_w1_in2'

*****drop family imputed fs raw variables***

drop `family_w1_fsi'


****drop family cv variables***
drop `family_w1_cv'





*household size for imputations
egen hh1hhres_i = cut(hh1hhres), at(1,3,5,6,8,99) icode
tab hh1hhres_i if inw1==1,m

egen onemem = tag(hhid)
tab hh1hhres_i hh1rural_i if inw1==1 & onemem==1,m col
drop onemem




label define yesnoh ///
   0 "0.no" ///
   1 "1.yes" ///
   .i ".i:invalid" /// 
   .e ".e:error" ///
   .m ".m:missing" ///
   .p ".p:proxy" ///
   .s ".s:skipped" ///
   .d ".d:dk" ///
   .r ".r:refuse" ///
   .u ".u:unmar" ///
   .v ".v:sp nr" ///
   .k ".k:no kids" ///
   .n ".n:not applicable" ///
   .a ".a:age less than 50" ///
   .w ".w:not working" ///
   .g ".g:no grandchildren"
   
   


*set wave number
local wv=1

***merge with household data
local housing_w1_hh stateid he001 he002 he004 he004a he005 he006 he007 he008 he013 he013a he013a_unit_0 he014 ///
																 he018 he019a he019b he019c he019d he024 															 
merge m:1 hhid using "$wave_1_hh", keepusing(`housing_w1_hh') nogen

*********************************************************************************************
*Households having separate bedrooms
gen hh`wv'bedsep=.
missing_lasi he001 he002, result(hh`wv'bedsep) wave(`wv')
replace hh`wv'bedsep=0 if he001==1 | (he001>1 & he002==0)
replace hh`wv'bedsep=1 if he001>1 & he002>0 & !mi(he002)
label variable hh`wv'bedsep "hh`wv'bedsep:w`wv' whether hh has separate bedroom(s)"
label values hh`wv'bedsep yesnoh

*Households having improved sanitation
gen hh`wv'sanitat=.
missing_lasi he004 he004a he005, result(hh`wv'sanitat) wave(`wv')
replace hh`wv'sanitat=0 if inlist(he004,4,5) | (he004==1 & he004a==4) | he005==1
replace hh`wv'sanitat=1 if (he004==1 & inlist(he004a,1,2,3) & he005 == 2) | (inlist(he004,2,3) & he005 == 2)
label variable hh`wv'sanitat "hh`wv'sanitat:w`wv' whether hh has improved sanitation"
label values hh`wv'sanitat yesnoh


*Households with improved drinking water source - same as in national report
gen hh`wv'drksrc=.
missing_lasi he006 , result(hh`wv'drksrc) wave(`wv')
replace hh`wv'drksrc=0 if inrange(he006,7,11) 
replace hh`wv'drksrc=1 if inrange(he006,1,6)
label variable hh`wv'drksrc "hh`wv'drksrc:w`wv' whether hh has improved drinking water source"
label values hh`wv'drksrc yesnoh

*Households with water facility inside dwelling/own yard
gen hh`wv'waterhm=.
missing_lasi he006 he007, result(hh`wv'waterhm) wave(`wv')
replace hh`wv'waterhm=0 if he006==6 | he006==10 | he007==3 
replace hh`wv'waterhm=1 if inlist(he007,1,2) 
label variable hh`wv'waterhm "hh`wv'waterhm:w`wv' whether hh has facility inside dwelling/own yard"
label values hh`wv'waterhm yesnoh

*Households with electricity
gen hh`wv'electr=.
missing_lasi he013, result(hh`wv'electr) wave(`wv')
replace hh`wv'electr=0 if he013==2
replace hh`wv'electr=1 if he013==1
label variable hh`wv'electr "hh`wv'electr:w`wv' whether hh has electricity"
label values hh`wv'electr yesnoh

*Mean hours of electricity available (per day)
gen hh`wv'electrhr=.
missing_lasi he013 he013a he013a_unit_0, result(hh`wv'electrhr) wave(`wv')
replace hh`wv'electrhr=0 if he013==2
replace hh`wv'electrhr=he013a if he013a_unit_0==1 & !mi(he013a)
replace hh`wv'electrhr=he013a/7 if he013a_unit_0==2 & !mi(he013a)
label variable hh`wv'electrhr "hh`wv'electrhr:w`wv' hrs of electricity available (per day)"

*Households using clean cooking fuel
gen hh`wv'clncook=.
missing_lasi he014, result(hh`wv'clncook) wave(`wv')
replace hh`wv'clncook=0 if inlist(he014,3,5,6,7,8,9,10) 
replace hh`wv'clncook=1 if inlist(he014,1,2,4)
label variable hh`wv'clncook "hh`wv'clncook:w`wv' whether hh using clean cooking fuel"
label values hh`wv'clncook yesnoh

*Households exposed to indoor pollution
gen hh`wv'indrplltn=.
missing_lasi he018 he019a he019b he019c he019d, result(hh`wv'indrplltn) wave(`wv')
replace hh`wv'indrplltn=0 if he018==2 | he019a==6 | he019b==6 | he019c==6 | he019d==6 
replace hh`wv'indrplltn=1 if he018==1 | inrange(he019a,1,5) |  inrange(he019b,1,5) | inrange(he019c,1,5) | inrange(he019d,1,5)
label variable hh`wv'indrplltn "hh`wv'indrplltn:w`wv' whether hh exposed to indoor pollution"
label values hh`wv'indrplltn yesnoh

*Pucca house
gen hh`wv'pucca=.
missing_lasi he024, result(hh`wv'pucca) wave(`wv')
replace hh`wv'pucca=0 if inlist(he024,2,3) 
replace hh`wv'pucca=1 if he024==1 
label variable hh`wv'pucca "hh`wv'pucca:w`wv' whether hh has pucca house"
label values hh`wv'pucca yesnoh

*Burn incense, mosquito coil, fast card inside home
gen hh`wv'incense=.
missing_lasi he019a he019b he019d, result(hh`wv'incense) wave(`wv')
replace hh`wv'incense=0 if inrange(he019a,5,6) | inrange(he019b,5,6) | inrange(he019d,5,6)
replace hh`wv'incense=1 if inrange(he019a,1,4) | inrange(he019b,1,4) | inrange(he019d,1,4)
label variable hh`wv'incense "hh`wv'incense:w`wv' whether hh use incense/mosquito coil/fast card inside home"
label values hh`wv'incense yesnoh


****drop housing core raw variables***
drop `housing_w1_hh'





***Medical expenditure flag
label define medexpendflag ///
   -1 "-1.not imputed, missing neighbors" ///
   -2 "-2.not imputed, missing covariates" ///
   1 "1.continuous value" ///
   2 "2.complete bracket" ///
   3 "3.incomplete bracket" ///
   5 "5.no value/bracket" ///
   6 "6.no expenditure" ///
   7 "7.dk expenditure" ///
   8 "8.module not answered"
      
***yes no label for insurance
label define yesnoins ///
		0 "0.no" ///
		1 "1.yes" /// 
   .i ".i:invalid" /// 
   .e ".e:error" ///
   .m ".m:missing" ///
   .p ".p:proxy" ///
   .s ".s:skipped" ///
   .d ".d:dk" ///
   .r ".r:refuse" ///
   .u ".u:unmar" ///
   .v ".v:sp nr", replace
   


*set wave number
local wv=1

***merge with demog file***
local ins_w1 hc002 hc003 hc102 hc103 hc104 hc202 hc203 ///
 		hc002s* hc003s* hc103s* hc104s* hc206* hc302 ///
 		
merge 1:1 prim_key using  "$wave_1_ind_bm", keepusing(`ins_w1') nogen

*merge with wave 1 hc impuations 		
local ins_w1_hci hc107_i hc107_i_f ///
                hc210a_1_1_i hc210a_1_1_i_f ///
                hc210a_2_1_i hc210a_2_1_i_f ///
                hc210a_3_1_i hc210a_3_1_i_f ///
                hc210a_4_1_i hc210a_4_1_i_f ///
                hc210a_5_1_i hc210a_5_1_i_f ///
                hc210a_6_1_i hc210a_6_1_i_f ///
                hc210a_7_1_i hc210a_7_1_i_f ///
                hc210a_8_1_i hc210a_8_1_i_f ///
                hc210a_9_1_i hc210a_9_1_i_f ///
                hc210a_10_1_i hc210a_10_1_i_f ///
                hc210a_1_2_i hc210a_1_2_i_f ///
                hc210a_2_2_i hc210a_2_2_i_f /// 
                hc210a_3_2_i hc210a_3_2_i_f ///
                hc210a_4_2_i hc210a_4_2_i_f ///
                hc210a_5_2_i hc210a_5_2_i_f ///
                hc210a_6_2_i hc210a_6_2_i_f ///
                hc210a_7_2_i hc210a_7_2_i_f ///
                hc210a_8_2_i hc210a_8_2_i_f ///
                hc210a_9_2_i hc210a_9_2_i_f ///
                hc210a_10_2_i hc210a_10_2_i_f ///
                hc210a_1_3_i hc210a_1_3_i_f ///
                hc210a_2_3_i hc210a_2_3_i_f ///
                hc210a_3_3_i hc210a_3_3_i_f ///
                hc210a_4_3_i hc210a_4_3_i_f ///
                hc210a_5_3_i hc210a_5_3_i_f ///
                hc210a_6_3_i hc210a_6_3_i_f ///
                hc210a_7_3_i hc210a_7_3_i_f ///
                hc210a_8_3_i hc210a_8_3_i_f ///
                hc210a_9_3_i hc210a_9_3_i_f ///
                hc210a_10_3_i hc210a_10_3_i_f ///
                hc210a_1_4_i hc210a_1_4_i_f /// 
                hc210a_2_4_i hc210a_2_4_i_f ///
                hc210a_3_4_i hc210a_3_4_i_f /// 
                hc210a_4_4_i hc210a_4_4_i_f /// 
                hc210a_5_4_i hc210a_5_4_i_f /// 
                hc210a_6_4_i hc210a_6_4_i_f /// 
                hc210a_7_4_i hc210a_7_4_i_f /// 
                hc210a_8_4_i hc210a_8_4_i_f /// 
                hc210a_9_4_i hc210a_9_4_i_f /// 
                hc210a_10_4_i hc210a_10_4_i_f ///
                hc325_i hc325_i_f ///
                hc327_i hc327_i_f

merge 1:1 prim_key using "$wave_1_hc_imput", keepusing(`ins_w1_hci') nogen

*********************************************************************
***Health Care Utilization: Hospital***
*********************************************************************
*make integer version for missing values
gen hc002_int="0"
replace hc002_int=hc002 if inlist(hc002, ".", ".d", ".r")
destring hc002_int, replace

***Hospital Stay in Previous Year
gen r`wv'hosp1y=.
missing_lasi hc002_int hc202, result(r`wv'hosp1y) wave(`wv')
replace r`wv'hosp1y=0 if (hc002s2 == 0 & hc002s3 == 0 & hc002s4 == 0 & hc002s5 == 0 & hc002s6 == 0 & hc002s7 == 0 & hc002s8 == 0 & hc002s9 == 0 & hc002s10 == 0) | hc202==0
replace r`wv'hosp1y=1 if inrange(hc202,1,24)
label variable r`wv'hosp1y "r`wv'hosp1y:w`wv' r hospital stay, prv year"
label values r`wv'hosp1y yesnoins

*spouse 
gen s`wv'hosp1y=.
spouse r`wv'hosp1y, result(s`wv'hosp1y) wave(`wv')
label variable s`wv'hosp1y "s`wv'hosp1y:w`wv' s hospital stay, prv year"
label values s`wv'hosp1y yesnoins

***Number of Hospital Stays in Previous Year
gen r`wv'hsptim1y=.
missing_lasi hc002_int hc202, result(r`wv'hsptim1y) wave(`wv')
replace r`wv'hsptim1y=0 if (hc002s2 == 0 & hc002s3 == 0 & hc002s4 == 0 & hc002s5 == 0 & hc002s6 == 0 & hc002s7 == 0 & hc002s8 == 0 & hc002s9 == 0 & hc002s10 == 0) | hc202==0
replace r`wv'hsptim1y=hc202 if inrange(hc202,1,24)
label variable r`wv'hsptim1y "r`wv'hsptim1y:w`wv' r # hospital stays, prv year"

*spouse
gen s`wv'hsptim1y=.
spouse r`wv'hsptim1y, result(s`wv'hsptim1y) wave(`wv')
label variable s`wv'hsptim1y "s`wv'hsptim1y:w`wv' s # hospital stays, prv year"

***Number of Nights in Hospital in Previous Year
gen r`wv'hspnit1y=.
missing_lasi hc002_int hc202 hc203, result(r`wv'hspnit1y) wave(`wv')
replace r`wv'hspnit1y=0 if r`wv'hsptim1y==0 | hc203==0
replace r`wv'hspnit1y=hc203 if inrange(hc203,1,200)
label variable r`wv'hspnit1y "r`wv'hspnit1y:w`wv' r # nights in hospital, prv year"

*spouse 
gen s`wv'hspnit1y=.
spouse r`wv'hspnit1y, result(s`wv'hspnit1y) wave(`wv')
label variable s`wv'hspnit1y "s`wv'hspnit1y:w`wv' s # nights in hospital, prv year"

drop hc002_int


*********************************************************************
***Medical Care Utilization: Doctor Visit***
*********************************************************************
***doctor visits in previous year
gen r`wv'doctor1y=.
missing_lasi hc003s1 hc003s4 hc003s5 hc003s6, result(r`wv'doctor1y) wave(`wv')
replace r`wv'doctor1y=0 if (hc003s1 == 0 & hc003s4 == 0 & hc003s5 == 0 & hc003s6 == 0)
replace r`wv'doctor1y=1 if hc003s1 == 1 | hc003s4 == 1 | hc003s5 == 1 | hc003s6 == 1
label variable r`wv'doctor1y "r`wv'doctor1y:w`wv' r doctor visit, prv year"
label values r`wv'doctor1y yesnoins

*spouse
gen s`wv'doctor1y=.
spouse r`wv'doctor1y, result(s`wv'doctor1y) wave(`wv')
label variable s`wv'doctor1y "s`wv'doctor1y:w`wv' s doctor visit, prv year"
label values s`wv'doctor1y yesnoins

*********************************************************************
***Medical Care Utilization: Traditional Medicine Visit***
*********************************************************************

***traditional medicine visits in previous year
gen r`wv'trdmed1y=.
missing_lasi hc003s2 hc003s7, result(r`wv'trdmed1y) wave(`wv')
replace r`wv'trdmed1y=0 if (hc003s2 == 0 & hc003s7 == 0)
replace r`wv'trdmed1y=1 if hc003s2 == 1 | hc003s7 == 1
label variable r`wv'trdmed1y "r`wv'trdmed1y:w`wv' r traditional medicine visit, prv year"
label values r`wv'trdmed1y yesnoins

*spouse 
gen s`wv'trdmed1y=.
spouse r`wv'trdmed1y, result(s`wv'trdmed1y) wave(`wv')
label variable s`wv'trdmed1y "s`wv'trdmed1y:w`wv' s traditional medicine visit, prv year"
label values s`wv'trdmed1y yesnoins

*********************************************************************
***Medical Care Utilization: Dental Visit***
*********************************************************************

***dental visits in previous year
gen r`wv'dentst1y=.
missing_lasi hc003s3, result(r`wv'dentst1y) wave(`wv')
replace r`wv'dentst1y=0 if hc003s3==0
replace r`wv'dentst1y=1 if hc003s3==1 
label variable r`wv'dentst1y "r`wv'dentst1y:w`wv' r dental visit, prv year"
label values r`wv'dentst1y yesnoins

*spouse 
gen s`wv'dentst1y=.
spouse r`wv'dentst1y, result(s`wv'dentst1y) wave(`wv')
label variable s`wv'dentst1y "s`wv'dentst1y:w`wv' s dental visit, prv year"
label values s`wv'dentst1y yesnoins

*********************************************************************
***Medical Care Utilization: Medical Visit***
*********************************************************************
***Medical Visit in Previous Year 
*make integer version for missing values
gen hc003_int="0"
replace hc003_int=hc003 if inlist(hc003, ".", ".d", ".r")
destring hc003_int, replace

***medical visit in previous year
gen r`wv'medvst1y=.
missing_lasi hc003_int hc302, result(r`wv'medvst1y) wave(`wv')
replace r`wv'medvst1y=0 if (hc003s1 == 0 & hc003s2 == 0 & hc003s3 == 0 & hc003s4 == 0 & hc003s5 == 0 & hc003s6 == 0 & hc003s7 == 0 & hc003s8 == 0) | hc302==0
replace r`wv'medvst1y=1 if inrange(hc302,1,65)
label variable r`wv'medvst1y "r`wv'medvst1y:w`wv' r medical visit, prv year"
label values r`wv'medvst1y yesnoins

*spouse
gen s`wv'medvst1y=.
spouse r`wv'medvst1y, result(s`wv'medvst1y) wave(`wv')
label variable s`wv'medvst1y "s`wv'medvst1y:w`wv' s medical visit, prv year"
label values s`wv'medvst1y yesnoins

***Number Medical Visits in Previous Year
gen r`wv'mdvtim1y=.
missing_lasi hc003_int hc302, result(r`wv'mdvtim1y) wave(`wv')
replace r`wv'mdvtim1y=0 if(hc003s1 == 0 & hc003s2 == 0 & hc003s3 == 0 & hc003s4 == 0 & hc003s5 == 0 & hc003s6 == 0 & hc003s7 == 0 & hc003s8 == 0) | hc302==0
replace r`wv'mdvtim1y=hc302 if inrange(hc302,1,65)
label variable r`wv'mdvtim1y "r`wv'mdvtim1y:w`wv' r # medical visits, prv year"

*spouse 
gen s`wv'mdvtim1y=.
spouse r`wv'mdvtim1y, result(s`wv'mdvtim1y) wave(`wv')
label variable s`wv'mdvtim1y "s`wv'mdvtim1y:w`wv' s # medical visits, prv year"

drop hc003_int

*********************************************************************
***Health Insurance: Covered by Government Health Insurance Program***
*********************************************************************

***Covered by Government Insurance Plan 
egen hc103_n1=anymatch(hc103s1 hc103s2 hc103s3 hc103s4 hc103s5), values(1)	// public (central gov (CGHS), employees state insurance scheme (ESIS), rashtriya swasthya bima yojana (RSBY), other central gov HI schemes, state health gov HI schemes)
egen hc103_n2=anymatch(hc103s7 hc103s8), values(1) // employer (medical reimbursement from an employer, HI through an employer)
egen hc103_n3=anymatch(hc103s6 hc103s9 hc103s10), values(1) // other (community/coop HI, privately purchased commercial HI, others)

*make integer version for missing values
gen hc103_int="0"
replace hc103_int=hc103 if inlist(hc103, ".", ".d", ".r")
destring hc103_int, replace

***covered by government insurance plan
gen r`wv'higov=. 
missing_lasi hc102 hc103_int, result(r`wv'higov) wave(`wv')
replace r`wv'higov=0 if hc102==2 | (hc103s1 == 0 & hc103s2 == 0 & hc103s3 == 0 & hc103s4 == 0 & hc103s5 == 0) 
replace r`wv'higov=1 if hc103_n1==1
label variable r`wv'higov "r`wv'higov:w`wv' r covered by gov plan"
label values r`wv'higov yesnoins

*spouse 
gen s`wv'higov=.
spouse r`wv'higov, result(s`wv'higov) wave(`wv')
label variable s`wv'higov "s`wv'higov:w`wv' s covered by gov plan"
label values s`wv'higov yesnoins


*********************************************************************
***Health Insurance: Covered by Employer***
*********************************************************************

***covered by employer health insurance plan
gen r`wv'covr=.
missing_lasi hc102 hc103_int, result(r`wv'covr) wave(`wv')
replace r`wv'covr=0 if hc102==2 | (hc103s7 == 0 & hc103s8 == 0)
replace r`wv'covr=1 if hc103_n2==1
label variable r`wv'covr "r`wv'covr:w`wv' r covered by employer plan"
label values r`wv'covr yesnoins

*spouse 
gen s`wv'covr=.
spouse r`wv'covr, result(s`wv'covr) wave(`wv')
label variable s`wv'covr "s`wv'covr:w`wv' s covered by employer plan"
label values s`wv'covr yesnoins


*********************************************************************
***Health Insurance: Covered by Other Insurance***
*********************************************************************

***covered by other health insurance plan
gen r`wv'hiothp=.
missing_lasi hc102 hc103_int, result(r`wv'hiothp) wave(`wv')
replace r`wv'hiothp=0 if hc102==2 | (hc103s6 == 0 & hc103s9 == 0 & hc103s10 == 0) 
replace r`wv'hiothp=1 if hc103_n3==1
label variable r`wv'hiothp "r`wv'hiothp:w`wv' r covered by other ins"
label values r`wv'hiothp yesnoins

*spouse 
gen s`wv'hiothp=.
spouse r`wv'hiothp, result(s`wv'hiothp) wave(`wv')
label variable s`wv'hiothp "s`wv'hiothp:w`wv' s covered by other ins"
label values s`wv'hiothp yesnoins

drop hc103_int hc103_n1 hc103_n2 hc103_n3


*********************************************************************
***Health Insurance: Covered by Dental Insurance***
*********************************************************************

egen hc104_n1=anymatch(hc104s1 hc104s2 hc104s3 hc104s4 hc104s6 hc104s7 hc104s8), values(1)

*make integer version for missing values
gen hc104_int="0"
replace hc104_int=hc104 if inlist(hc104, ".", ".d", ".r")
destring hc104_int, replace

***Covered by Dental Insurance 
gen r`wv'hident=.
missing_lasi hc102 hc104_int, result(r`wv'hident) wave(`wv')
replace r`wv'hident=0 if hc102==2
replace r`wv'hident=0 if (hc102==1 & hc104_n1==1) | hc104s5==0
replace r`wv'hident=1 if hc104s5==1
label variable r`wv'hident "r`wv'hident:w`wv' r covered by dental ins"
label values r`wv'hident yesnoins

*spouse 
gen s`wv'hident=.
spouse r`wv'hident, result(s`wv'hident) wave(`wv')
label variable s`wv'hident "s`wv'hident:w`wv' s covered by dental ins"
label values s`wv'hident yesnoins


*********************************************************************
***Health Insurance: Drug Expenses Covered***
*********************************************************************

egen hc104_n2=anymatch(hc104s1 hc104s2 hc104s3 hc104s5 hc104s6 hc104s7 hc104s8), values(1)

***Covered by Drug Expenses 
gen r`wv'hidrug=.
missing_lasi hc102 hc104_int, result(r`wv'hidrug) wave(`wv')
replace r`wv'hidrug=0 if hc102==2
replace r`wv'hidrug=0 if (hc102==1 & hc104_n2==1) | hc104s4==0
replace r`wv'hidrug=1 if hc104s4==1
label variable r`wv'hidrug "r`wv'hidrug:w`wv' r drug expenses covered"
label values r`wv'hidrug yesnoins

*spouse  
gen s`wv'hidrug=.
spouse r`wv'hidrug, result(s`wv'hidrug) wave(`wv')
label variable s`wv'hidrug "s`wv'hidrug:w`wv' s drug expenses covered"
label values s`wv'hidrug yesnoins

drop hc104_int hc104_n1 hc104_n2


*********************************************************************
***Medical Care Utilization: Premium***
*********************************************************************

***Premium Amount
*gen r`wv'prmm1y=.
*missing_lasi hc102 hc107, result(r`wv'prmm1y) wave(`wv')
*replace r`wv'prmm1y=0 if hc102==2
*replace r`wv'prmm1y=hc107 if inrange(hc107,0,500000)
*label variable r`wv'prmm1y "r`wv'prmm1y:w`wv' r premium amount, prv year"

gen r`wv'prmm1y=.
replace r`wv'prmm1y = hc107_i
label variable r`wv'prmm1y "r`wv'prmm1y:w`wv' r premium amount (imputed), prv year"

*spouse 
gen s`wv'prmm1y=.
spouse r`wv'prmm1y, result(s`wv'prmm1y) wave(`wv')
label variable s`wv'prmm1y "s`wv'prmm1y:w`wv' s premium amount, prv year"

***Premium Amount Imputation Flag
gen r`wv'prmmf1y=.
replace r`wv'prmmf1y = hc107_i_f
label variable r`wv'prmmf1y "r`wv'prmmf1y:w`wv' imput flag r premium amount, prv year"
label values r`wv'prmmf1y medexpendflag

*spouse
gen s`wv'prmmf1y=.
spouse r`wv'prmmf1y, result(s`wv'prmmf1y) wave(`wv')
label variable s`wv'prmmf1y "s`wv'prmmf1y:w`wv' imput flag s premium amount, prv year"
label values s`wv'prmmf1y medexpendflag


*********************************************************************
***Medical Expenditures: Hospitalization***
*********************************************************************
***Out of Pocket Hospital Expenditures Last Year 
gen r`wv'oophos1y = hc210a_1_1_i + hc210a_2_1_i  + hc210a_3_1_i + hc210a_4_1_i + hc210a_5_1_i + hc210a_6_1_i + hc210a_7_1_i + hc210a_8_1_i + hc210a_9_1_i + hc210a_10_1_i + ///
                    hc210a_1_2_i + hc210a_2_2_i  + hc210a_3_2_i + hc210a_4_2_i + hc210a_5_2_i + hc210a_6_2_i + hc210a_7_2_i + hc210a_8_2_i + hc210a_9_2_i + hc210a_10_2_i + ///
                    hc210a_1_3_i + hc210a_2_3_i  + hc210a_3_3_i + hc210a_4_3_i + hc210a_5_3_i + hc210a_6_3_i + hc210a_7_3_i + hc210a_8_3_i + hc210a_9_3_i + hc210a_10_3_i + ///
                    hc210a_1_4_i + hc210a_2_4_i  + hc210a_3_4_i + hc210a_4_4_i + hc210a_5_4_i + hc210a_6_4_i + hc210a_7_4_i + hc210a_8_4_i + hc210a_9_4_i + hc210a_10_4_i
replace r`wv'oophos1y = .m if r`wv'oophos1y==. & inw`wv'==1
label variable r`wv'oophos1y "r`wv'oophos1y:w`wv' r hospitalization oop expenditure, prv year"

***oop hospital expenditure last year imputation flag
gen r`wv'oophosf1y=.
combine_h_inc_flag hc210a_1_1_i_f hc210a_2_1_i_f  hc210a_3_1_i_f hc210a_4_1_i_f hc210a_5_1_i_f hc210a_6_1_i_f hc210a_7_1_i_f hc210a_8_1_i_f hc210a_9_1_i_f hc210a_10_1_i_f ///
                    hc210a_1_2_i_f hc210a_2_2_i_f  hc210a_3_2_i_f hc210a_4_2_i_f hc210a_5_2_i_f hc210a_6_2_i_f hc210a_7_2_i_f hc210a_8_2_i_f hc210a_9_2_i_f hc210a_10_2_i_f ///
                    hc210a_1_3_i_f hc210a_2_3_i_f  hc210a_3_3_i_f hc210a_4_3_i_f hc210a_5_3_i_f hc210a_6_3_i_f hc210a_7_3_i_f hc210a_8_3_i_f hc210a_9_3_i_f hc210a_10_3_i_f ///
                    hc210a_1_4_i_f hc210a_2_4_i_f  hc210a_3_4_i_f hc210a_4_4_i_f hc210a_5_4_i_f hc210a_6_4_i_f hc210a_7_4_i_f hc210a_8_4_i_f hc210a_9_4_i_f hc210a_10_4_i_f, ///
                    result(r`wv'oophosf1y)
label variable r`wv'oophosf1y "r`wv'oophosf1y:w`wv' imput flag r hospitalization oop expenditure, prv year"
label values r`wv'oophosf1y medexpendflag

*spouse  
gen s`wv'oophos1y=.
spouse r`wv'oophos1y, result(s`wv'oophos1y) wave(`wv')
label variable s`wv'oophos1y "s`wv'oophos1y:w`wv' s hospitalization oop expenditure, prv year"

*spouse  
gen s`wv'oophosf1y=.
spouse r`wv'oophosf1y, result(s`wv'oophosf1y) wave(`wv')
label variable s`wv'oophosf1y "s`wv'oophosf1y:w`wv' imput flag s hospitalization oop expenditure, prv year"
label values s`wv'oophosf1y medexpendflag

*********************************************************************
***Medical Expenditures: outpatient medical visits***
*********************************************************************
**value of outpatient medical visits
*respondent
gen r`wv'oopdoc1y = hc325_i
label variable r`wv'oopdoc1y "r`wv'oopdoc1y:w`wv' r oop outpatient expenditures, prv year"

*spouse  
gen s`wv'oopdoc1y=.
spouse r`wv'oopdoc1y, result(s`wv'oopdoc1y) wave(`wv')
label variable s`wv'oopdoc1y "s`wv'oopdoc1y:w`wv' s oop outpatient expenditures, prv year"

**impuation flag of outpatient medical visits
*respondent
gen r`wv'oopdocf1y = hc325_i_f
label variable r`wv'oopdocf1y "r`wv'oopdocf1y:w`wv' imput flag r oop outpatient expenditures, prv year"
label values r`wv'oopdocf1y medexpendflag

*spouse
gen s`wv'oopdocf1y=.
spouse r`wv'oopdocf1y, result(s`wv'oopdocf1y) wave(`wv')
label variable s`wv'oopdocf1y "s`wv'oopdocf1y:w`wv' imput flag s oop outpatient expenditures, prv year"
label values s`wv'oopdocf1y medexpendflag

*********************************************************************
***Medical Expenditures: medications/health supplements***
*********************************************************************
**value of medications/health supplements (without consulting healthcare provider)
*respondent
gen r`wv'oopsupl1y = hc327_i
label variable r`wv'oopsupl1y "r`wv'oopsupl1y:w`wv' r oop medication/health supplements expenditures, prv year"

*spouse  
gen s`wv'oopsupl1y=.
spouse r`wv'oopsupl1y, result(s`wv'oopsupl1y) wave(`wv')
label variable s`wv'oopsupl1y "s`wv'oopsupl1y:w`wv' s oop medication/health supplements expenditures, prv year"

**imputation flag of medications/health supplements
*respondent
gen r`wv'oopsuplf1y = hc327_i_f
label variable r`wv'oopsuplf1y "r`wv'oopsuplf1y:w`wv' imput flag r oop medication/health supplements expenditures, prv year"
label values r`wv'oopsuplf1y medexpendflag

*spouse
gen s`wv'oopsuplf1y=.
spouse r`wv'oopsuplf1y, result(s`wv'oopsuplf1y) wave(`wv')
label variable s`wv'oopsuplf1y "s`wv'oopsuplf1y:w`wv' imput flag s oop medication/health supplements expenditures, prv year"
label values s`wv'oopsuplf1y medexpendflag

*********************************************************************
***Medical Expenditures: Total OOP***
*********************************************************************
**total value of all oop expenditures
*respondent
gen r`wv'oopmd1y_l = r`wv'oophos1y + r`wv'oopdoc1y + r`wv'oopsupl1y
replace r`wv'oopmd1y_l = .m if r`wv'oopmd1y_l==. & inw`wv'==1
label variable r`wv'oopmd1y_l "r`wv'oopmd1y_l:w`wv' r total oop expenditures, prv  year"

*spouse
gen s`wv'oopmd1y_l=.
spouse r`wv'oopmd1y_l, result(s`wv'oopmd1y_l) wave(`wv')
label variable s`wv'oopmd1y_l "s`wv'oopmd1y_l:w`wv' s total oop expenditures, prv year"

**imputation flag for total oop expenditures
*respondent
gen r`wv'oopmdf1y_l = .
combine_h_inc_flag r`wv'oophosf1y r`wv'oopdocf1y r`wv'oopsuplf1y, result(r`wv'oopmdf1y_l)
label variable r`wv'oopmdf1y_l "r`wv'oopmdf1y_l:w`wv' imput flag r total oop expenditures, prv year"
label values r`wv'oopmdf1y_l medexpendflag

*spouse
gen s`wv'oopmdf1y_l=.
spouse r`wv'oopmdf1y_l, result(s`wv'oopmdf1y_l) wave(`wv')
label variable s`wv'oopmdf1y_l "s`wv'oopmdf1y_l:w`wv' imput flag s total oop expenditures, prv year"
label values s`wv'oopmdf1y_l medexpendflag


*****************************************************


***drop LASI wave 1 file raw variables***
drop `ins_w1'

***drop LASI wave 1 HC impuation raw variables
drop `ins_w1_hci'

***Asset flag
label define assflag ///
   -1 "-1.not imputed, missing neighbors" ///
   -2 "-2.not imputed, missing covariates" ///
   1 "1.continuous value" ///
   2 "2.complete bracket" ///
   3 "3.incomplete bracket" ///
   5 "5.no value/bracket" ///
   6 "6.no asset" ///
   7 "7.dk ownership" ///
   8 "8.module not answered", replace

******************************************************************************************


* set wave number
local wv=1

***merge with AD impuation data
local asset_w1_ad_imput ad103_i ad103_i_f ///
                        ad203_i ad203_i_f ///
                        ad209_i ad209_i_f ///
                        ad303_i ad303_i_f ///
                        ad306_i ad306_i_f ///
                        ad404a_i ad404a_i_f ///
                        ad404b_i ad404b_i_f ///
                        ad502_i ad502_i_f ///
                        ad506_i ad506_i_f ///
                        ad601_i ad601_i_f ///
                        ad702_i ad702_i_f ///
                        ad706_i ad706_i_f ///
                        ad802_i ad802_i_f ///
                        ad907_1__i ad907_1__i_f ///
                        ad907_2__i ad907_2__i_f ///
                        ad907_3__i ad907_3__i_f ///
                        ad908a_i ad908a_i_f  

merge m:1 hhid using "$wave_1_ad_imput", keepusing(`asset_w1_ad_imput') nogen

*****************************************************
***Security deposit paid to rent current residence
* wave 1 security deposit paid to rent current residence
* value of asset
gen hh`wv'ahsdp = ad103_i
label variable hh`wv'ahsdp "hh`wv'ahsdp:w`wv' assets: value of security deposits paid (current residence)"


* asset flag
gen hh`wv'afhsdp = ad103_i_f
label variable hh`wv'afhsdp "hh`wv'afhsdp:w`wv' impflag: value of security deposits paid (current residence)"
label values hh`wv'afhsdp assflag

*****************************************************
***Present market value of current residence, if owned
* wave 1 present marked value of current residence
* value of asset
gen hh`wv'ahous = ad203_i
replace hh`wv'ahous = .m if hh`wv'ahous==. & inw`wv'==1
label variable hh`wv'ahous "hh`wv'ahous:w`wv' assets: value of primary residence"

* asset flag
gen hh`wv'afhous = ad203_i_f
label variable hh`wv'afhous "hh`wv'afhous:w`wv' impflag: value of primary residence"
label values hh`wv'afhous assflag

*****************************************************
***Security deposit received, current residence
* wave 1 security deposit received, current residence
* value of asset
gen hh`wv'ahsdr = ad209_i
label variable hh`wv'ahsdr "hh`wv'ahsdr:w`wv' assets: value of security deposits received (current residence)"

* asset flag
gen hh`wv'afhsdr = ad209_i_f
label variable hh`wv'afhsdr "hh`wv'afhsdr:w`wv' impflag: value of security deposits received (current residence)"
label values hh`wv'afhsdr assflag

*****************************************************
***Other real estate
* wave 1 other real estate
* value of asset
gen hh`wv'arles = ad303_i
replace hh`wv'arles = .m if hh`wv'arles==. & inw`wv'==1
label variable hh`wv'arles "hh`wv'arles:w`wv' assets: value of other real estate (not primary residence)"

* asset flag
gen hh`wv'afrles = ad303_i_f
label variable hh`wv'afrles "hh`wv'afrles:w`wv' impflag: value of other real estate (not primary residence)"
label values hh`wv'afrles assflag

*****************************************************
***Security deposit received, other real estate
* wave 1 security deposit received, other real estate
* value of asset
gen hh`wv'aosdr = ad306_i
label variable hh`wv'aosdr "hh`wv'aosdr:w`wv' assets: value of security deposits received (not primary residence)"

* asset flag
gen hh`wv'afosdr = ad306_i_f
label variable hh`wv'afosdr "hh`wv'afosdr:w`wv' impflag: value of security deposits received (not primary residence)"
label values hh`wv'afosdr assflag

*****************************************************
***Cultivated and non-cultivated land
* wave 1 cultivated and non-cultivated land
*value of asset
gen hh`wv'aland = ad404a_i + ad404b_i
replace hh`wv'aland = .m if hh`wv'aland==. & inw`wv'==1
label variable hh`wv'aland "hh`wv'aland:w`wv' assets: value of cultivated and non-cultivated land"

* asset flag
gen hh`wv'afland = .
combine_h_asset_flag ad404a_i_f ad404b_i_f, result(hh`wv'afland)
label variable hh`wv'afland "hh`wv'afland:w`wv' impflag: value of cultivated and non-cultivated land"
label values hh`wv'afland assflag

*****************************************************
***Agricultural equipment
* wave 1 agricultural equipment
* value of asset
gen hh`wv'afixc = ad502_i
replace hh`wv'afixc = .m if hh`wv'afixc==. & inw`wv'==1
label variable hh`wv'afixc "hh`wv'afixc:w`wv' assets: value of agricultural equipment"

* asset flag
gen hh`wv'affixc = ad502_i_f
label variable hh`wv'affixc "hh`wv'affixc:w`wv' impflag: value of agricultural equipment"
label values hh`wv'affixc assflag

*****************************************************
***livestock
* wave 1 livestock
* value of asset
gen hh`wv'aagri = ad506_i
label variable hh`wv'aagri "hh`wv'aagri:w`wv' assets: value of livestock"

* asset flag
gen hh`wv'afagri = ad506_i_f
label variable hh`wv'afagri "hh`wv'afagri:w`wv' impflag: value of livestock"
label values hh`wv'afagri assflag

*****************************************************
***Businesses
* wave 1 businesses
* value of asset
gen hh`wv'absns = ad601_i
replace hh`wv'absns = .m if hh`wv'absns==. & inw`wv'==1
label variable hh`wv'absns "hh`wv'absns:w`wv' assets: value of businesses"

* asset flag
gen hh`wv'afbsns = ad601_i_f
label variable hh`wv'afbsns "hh`wv'afbsns:w`wv' impflag: value of businesses"
label values hh`wv'afbsns assflag

*****************************************************
***Personal Loans to others
* wave 1 personal loans to others
* value of asset
gen hh`wv'alend = ad702_i
label variable hh`wv'alend "hh`wv'alend:w`wv' assets: value of personal loans lent"

* asset flag
gen hh`wv'aflend = ad702_i_f
label variable hh`wv'aflend "hh`wv'aflend:w`wv' impflag: value of personal loans lent"
label values hh`wv'aflend assflag

*****************************************************
***Household durables and valuables
* wave 1 household durables and valuables
* value of asset
gen hh`wv'adurbl = ad706_i
label variable hh`wv'adurbl "hh`wv'adurbl:w`wv' assets: value of durable assets"

* asset flag
gen hh`wv'afdurbl = ad706_i_f
label variable hh`wv'afdurbl "hh`wv'afdurbl:w`wv' impflag: value of durable assets"
label values hh`wv'afdurbl assflag

*****************************************************
***Financial assets
* wave 1 financial assets
* value of asset
gen hh`wv'atotf = ad802_i
label variable hh`wv'atotf "hh`wv'atotf:w`wv' assets: total value of financial assets"

* asset flag
gen hh`wv'aftotf = ad802_i_f
label variable hh`wv'aftotf "hh`wv'aftotf:w`wv' impflag: total value of financial assets"
label values hh`wv'aftotf assflag

*****************************************************
***Total debt
* wave 1 total debt
*value of asset
gen hh`wv'adebt = ad907_1__i + ad907_2__i + ad907_3__i + ad908a_i 
replace hh`wv'adebt = .m if hh`wv'adebt==. & inw`wv'==1
label variable hh`wv'adebt "hh`wv'adebt:w`wv' assets: total value of debts"

* asset flag
gen hh`wv'afdebt =.
combine_h_asset_flag ad907_1__i_f ad907_2__i_f ad907_3__i_f ad908a_i_f, result(hh`wv'afdebt) 
label variable hh`wv'afdebt "hh`wv'afdebt:w`wv' impflag: total value of debts"
label values hh`wv'afdebt assflag

*****************************************************
***Total household wealth
* wave 1 total household wealth
* value of assets
gen hh`wv'atotb = 	(hh`wv'ahsdp + hh`wv'ahous + hh`wv'arles + ///
					hh`wv'aland + hh`wv'afixc + hh`wv'aagri + ///
					hh`wv'absns + hh`wv'alend + hh`wv'adurbl + hh`wv'atotf) - ///
					(hh`wv'aosdr + hh`wv'adebt + hh`wv'ahsdr)
replace hh`wv'atotb = .m if hh`wv'atotb==. & inw`wv'==1
label variable hh`wv'atotb "hh`wv'atotb:w`wv' assets: total of all assets inc."

* asset flag
gen hh`wv'aftotb = .
combine_h_asset_flag 	hh`wv'afhsdp hh`wv'afhous hh`wv'afrles hh`wv'afland ///
						hh`wv'affixc hh`wv'afagri hh`wv'afbsns hh`wv'aflend ///
						hh`wv'afdurbl hh`wv'aftotf hh`wv'afosdr hh`wv'afdebt ///
						hh`wv'afhsdr, result(hh`wv'aftotb)
label variable hh`wv'aftotb "hh`wv'aftotb:w`wv' impflag: total of all assets inc."
label values hh`wv'aftotb assflag

*****************************************************


****drop AD impuation raw variables***
drop `asset_w1_ad_imput'


***Income flag
label define incflag ///
   -1 "-1.not imputed, missing neighbors" ///
   -2 "-2.not imputed, missing covariates" ///
   1 "1.continuous value" ///
   2 "2.complete bracket" ///
   3 "3.incomplete bracket" ///
   5 "5.no value/bracket" ///
   6 "6.no receipt" ///
   7 "7.dk receipt" ///
   8 "8.module not answered", replace
   
***Compsumption flag
label define comflag ///
   -1 "-1.not imputed, missing neighbors" ///
   -2 "-2.not imputed, missing covariates" ///
   1 "1.continuous value" ///
   2 "2.complete bracket" ///
   3 "3.incomplete bracket" ///
   5 "5.no value/bracket" ///
   6 "6.no consumption" ///
   7 "7.dk consumption" ///
   8 "8.module not answered", replace
   
***Poverty line
label define poverty ///
   1 "1.At/below international poverty line" ///
   0 "0.Above international poverty line"   

******************************************************************************************


* set wave number
local wv=1

***merge with IN impuation data
local income_w1_in_imput in304_*_1_i in304_*_1_i_f ///
                         in304_*_2_i in304_*_2_i_f ///
                         in304_*_3_i in304_*_3_i_f ///
                         in304_*_4_i in304_*_4_i_f ///
                         in304_*_5_i in304_*_5_i_f ///
                         in304_*_6_i in304_*_6_i_f ///
                         in103a_i in103b_i in103c_i in103d_i in103e_i ///
                         in104a_i in104b_i in104c_i in104d_i in104e_i ///
                         in107_i ///
                         in108_i ///
                         in204_1_i in205_1_i ///
                         in204_2_i in205_2_i ///
                         in204_3_i in205_3_i ///
                         in204_4_i in205_4_i ///
                         in204_5_i in205_5_i ///
                         in204_6_i in205_6_i ///
                         in204_7_i in205_7_i ///
                         in204_8_i in205_8_i ///
                         in204_9_i in205_9_i ///
                         in204_10_i in205_10_i ///
                         in204_11_i in205_11_i ///
                         in204_12_i in205_12_i ///
                         in103a_i_f in103b_i_f in103c_i_f in103d_i_f in103e_i_f ///
                         in104a_i_f in104b_i_f in104c_i_f in104d_i_f in104e_i_f ///
                         in107_i_f ///
                         in108_i_f ///
                         in204_1_i_f in205_1_i_f ///
                         in204_2_i_f in205_2_i_f ///
                         in204_3_i_f in205_3_i_f ///
                         in204_4_i_f in205_4_i_f ///
                         in204_5_i_f in205_5_i_f ///
                         in204_6_i_f in205_6_i_f ///
                         in204_7_i_f in205_7_i_f ///
                         in204_8_i_f in205_8_i_f ///
                         in204_9_i_f in205_9_i_f ///
                         in204_10_i_f in205_10_i_f ///
                         in204_11_i_f in205_11_i_f ///
                         in204_12_i_f in205_12_i_f ///  
                         in402a_*_i in402a_*_i_f ///
                         in402b_*_i in402b_*_i_f ///
                         in402c_*_i in402c_*_i_f ///
                         in402d_*_i in402d_*_i_f ///
                         in402e_*_i in402e_*_i_f ///
                         in702a_i in702a_i_f ///
                         in702b_i in702b_i_f ///
                         in702c_i in702c_i_f ///
                         in702d_i in702d_i_f ///
                         in702e_i in702e_i_f ///
                         in702f_i in702f_i_f ///
                         in702g_i in702g_i_f ///
                         in702h_i in702h_i_f ///
                         in702i_i in702i_i_f ///
                         in702j_i in702j_i_f ///
                         in702k_i in702k_i_f ///
                         in702l_i in702l_i_f ///
                         in702m_i in702m_i_f ///
                         in504_1_i in504_1_i_f ///
                         in504_2_i in504_2_i_f ///
                         in504_3_i in504_3_i_f ///
                         in504_4_i in504_4_i_f ///
                         in504_5_i in504_5_i_f ///
                         in504_6_i in504_6_i_f ///
                         in504_7_i in504_7_i_f ///
                         in504_8_i in504_8_i_f ///
                         in504_9_i in504_9_i_f ///
                         in504_10_i in504_10_i_f ///
                         in504_11_i in504_11_i_f ///
                         in504_12_i in504_12_i_f ///
                         in504_13_i in504_13_i_f ///
                         in504_14_i in504_14_i_f ///
                         in504_15_i in504_15_i_f ///
                         in507a_i in507a_i_f ///
                         in507b_i in507b_i_f ///
                         in602_i in602_i_f

merge m:1 hhid using "$wave_1_in_imput", keepusing(`income_w1_in_imput') nogen

***merge with AD impuation data
local income_w1_ad_imput ad207_i ad305_i ad407a_i ad407b_i ad504_i ad508_i ///
                         ad207_i_f ad305_i_f ad407a_i_f ad407b_i_f ad504_i_f ad508_i_f ///
                         ad704_i ad803_i ///
                         ad704_i_f ad803_i_f

merge m:1 hhid using "$wave_1_ad_imput", keepusing(`income_w1_ad_imput') nogen

***merge with CO impuation data
local income_w1_co_imput co002a_i co002a_i_f ///
                         co002b_i co002b_i_f ///
                         co002c_i co002c_i_f ///
                         co002d_i co002d_i_f ///
                         co002e_i co002e_i_f ///
                         co002f_i co002f_i_f ///
                         co002g_i co002g_i_f ///
                         co002h_i co002h_i_f ///
                         co002i_i co002i_i_f ///
                         co002j_i co002j_i_f ///
                         co101_i co101_i_f ///
                         co102_i co102_i_f ///
                         co103_i co103_i_f ///
                         co104_i co104_i_f ///
                         co105_i co105_i_f ///
                         co106_i co106_i_f ///
                         co107_i co107_i_f ///
                         co108_i co108_i_f ///
                         co109_i co109_i_f ///
                         co110_i co110_i_f ///
                         co111_i co111_i_f ///
                         co202_i co202_i_f ///
                         co203_i co203_i_f ///
                         co204_i co204_i_f ///
                         co205_i co205_i_f ///
                         co206_i co206_i_f ///
                         co209_i co209_i_f ///
                         co210_i co210_i_f ///
                         co211_i co211_i_f ///
                         co212_i co212_i_f ///
                         co213_i co213_i_f ///
                         co214_i co214_i_f ///
                         co215_i co215_i_f ///
                         co216_i co216_i_f

merge m:1 hhid using "$wave_1_co_imput", keepusing(`income_w1_co_imput') nogen

*****************************************************
* Respondent level income from earnings
*****************************************************
gen r`wv'iearn = .
forvalues hhm = 1 / 35 {
    replace r`wv'iearn = in304_`hhm'_1_i + in304_`hhm'_2_i + in304_`hhm'_3_i + in304_`hhm'_4_i + in304_`hhm'_5_i + in304_`hhm'_6_i if hhorder == `hhm'
}
replace r`wv'iearn = .m if r`wv'iearn==. & inw`wv'==1
label variable r`wv'iearn "r`wv'iearn:w`wv' income: r income from earnings"

gen s`wv'iearn =.
spouse r`wv'iearn, result(s`wv'iearn) wave(`wv')
label variable s`wv'iearn "s`wv'iearn:w`wv' income: s income from earnings"

gen r`wv'ifearn = .
forvalues hhm = 1 / 35 {
    combine_h_inc_flag in304_`hhm'_1_i_f in304_`hhm'_2_i_f in304_`hhm'_3_i_f in304_`hhm'_4_i_f in304_`hhm'_5_i_f in304_`hhm'_6_i_f if hhorder == `hhm', result(r`wv'ifearn)
}
label variable r`wv'ifearn "r`wv'ifearn:w`wv' impflag: r income from earnings"
label values r`wv'ifearn incflag

gen s`wv'ifearn = .
spouse r`wv'ifearn, result(s`wv'ifearn) wave(`wv')
label variable s`wv'ifearn "s`wv'ifearn:w`wv' impflag: s income from earnings"
label values s`wv'ifearn incflag

*****************************************************
* Household level income from earnings
*****************************************************
gen hh`wv'iearn = 0 if inw`wv' == 1
forvalues hhm = 1 / 35 {
    replace hh`wv'iearn = hh`wv'iearn + in304_`hhm'_1_i + in304_`hhm'_2_i + in304_`hhm'_3_i + in304_`hhm'_4_i + in304_`hhm'_5_i + in304_`hhm'_6_i if !mi(in304_`hhm'_1_i_f)
}
replace hh`wv'iearn = .m if hh`wv'iearn==. & inw`wv'==1
label variable hh`wv'iearn "hh`wv'iearn:w`wv' income: hhold income from earnings"

gen hh`wv'ifearn = .
combine_h_inc_flag in304_*_1_i_f in304_*_2_i_f in304_*_3_i_f in304_*_4_i_f in304_*_5_i_f in304_*_6_i_f, result(hh`wv'ifearn)
label variable hh`wv'ifearn "hh`wv'ifearn:w`wv' impflag: hhold income from earnings"
label values hh`wv'ifearn incflag 

*****************************************************
* Capital Income: Business Income
*****************************************************
gen hh`wv'isemp = in103a_i + in103b_i + in103c_i + in103d_i + in103e_i ///
                - in104a_i - in104b_i - in104c_i - in104d_i - in104e_i ///
                + in107_i ///
                - in108_i ///
                + in204_1_i - in205_1_i ///
                + in204_2_i - in205_2_i ///
                + in204_3_i - in205_3_i ///
                + in204_4_i - in205_4_i ///
                + in204_5_i - in205_5_i ///
                + in204_6_i - in205_6_i ///
                + in204_7_i - in205_7_i ///
                + in204_8_i - in205_8_i ///
                + in204_9_i - in205_9_i ///
                + in204_10_i - in205_10_i ///
                + in204_11_i - in205_11_i ///
                + in204_12_i - in205_12_i 
replace hh`wv'isemp = .m if hh`wv'isemp==. & inw`wv'==1
label variable hh`wv'isemp "hh`wv'isemp:w`wv' income: hhold earnings from business income"

gen hh`wv'ifsemp = .
combine_h_inc_flag in103a_i_f in103b_i_f in103c_i_f in103d_i_f in103e_i_f ///
                   in104a_i_f in104b_i_f in104c_i_f in104d_i_f in104e_i_f ///
                   in107_i_f ///
                   in108_i_f ///
                   in204_*_i_f in205_*_i_f, result(hh`wv'ifsemp)                   
label variable hh`wv'ifsemp "hh`wv'ifsemp:w`wv' impflag: hhold earnings from business income"
label values hh`wv'ifsemp incflag

*****************************************************
* Capital Income: Rental Income
*****************************************************
gen hh`wv'irent = ad207_i + ad305_i + ad407a_i + ad407b_i + ad504_i + ad508_i
replace hh`wv'irent = .m if hh`wv'irent==. & inw`wv'==1
label variable hh`wv'irent "hh`wv'irent:w`wv' income: hhold rental income"

gen hh`wv'ifrent = .
combine_h_inc_flag ad207_i_f ad305_i_f ad407a_i_f ad407b_i_f ad504_i_f ad508_i_f, result(hh`wv'ifrent)                    
label variable hh`wv'ifrent "hh`wv'ifrent:w`wv' impflag: hhold rental income"
label values hh`wv'ifrent incflag

*****************************************************
* Capital Income: Interest Income
*****************************************************
gen hh`wv'itrest = ad704_i + ad803_i
replace hh`wv'itrest = .m if hh`wv'itrest==. & inw`wv'==1
label variable hh`wv'itrest "hh`wv'itrest:w`wv' income: hhold interest income"

gen hh`wv'iftrest = .
combine_h_inc_flag ad704_i_f ad803_i_f, result(hh`wv'iftrest)
label variable hh`wv'iftrest "hh`wv'iftrest:w`wv' impflag: hhold interest income"
label values hh`wv'iftrest incflag

*****************************************************
* Capital Income: Total
*****************************************************
* Total Capital Income value
gen hh`wv'icap = hh`wv'isemp + hh`wv'irent + hh`wv'itrest
replace hh`wv'icap = .m if hh`wv'icap==. & inw`wv'==1
label variable hh`wv'icap "hh`wv'icap:w`wv' income: hhold total capital income"

* Total Capital Income flag
gen hh`wv'ifcap = .
combine_h_inc_flag hh`wv'ifsemp hh`wv'ifrent hh`wv'iftrest, result(hh`wv'ifcap)
label variable hh`wv'ifcap "hh`wv'ifcap:w`wv' impflag: hhold total capital income"
label values hh`wv'ifcap incflag

*****************************************************
* Respondent level income from private pensions
*****************************************************
* wave 1 respondent income from private pensions
gen r`wv'ipena =.
forvalues hhm = 1 / 35 {
    replace r`wv'ipena = in402c_`hhm'_i + in402d_`hhm'_i if hhorder == `hhm'
}
replace r`wv'ipena = .m if r`wv'ipena==. & inw`wv'==1
label variable r`wv'ipena "r`wv'ipena:w`wv' income: r income from private pensions"

gen s`wv'ipena =.
spouse r`wv'ipena, result(s`wv'ipena) wave(`wv')
label variable s`wv'ipena "s`wv'ipena:w`wv' income: s income from private pensions"

* wave 1 respondent income from private pensions flag
gen r`wv'ifpena = .
forvalues hhm = 1 / 35 {
    combine_h_inc_flag in402c_`hhm'_i_f in402d_`hhm'_i_f if hhorder == `hhm', result(r`wv'ifpena)
}
label variable r`wv'ifpena "r`wv'ifpena:w`wv' impflag: r income from private pensions"
label values r`wv'ifpena incflag

gen s`wv'ifpena = .
spouse r`wv'ifpena, result(s`wv'ifpena) wave(`wv')
label variable s`wv'ifpena "s`wv'ifpena:w`wv' impflag: s income from private pensions"
label values s`wv'ifpena incflag

*****************************************************
* Household level income from private pensions
*****************************************************
* wave 1 household income from private pensions
gen hh`wv'ipena = 0 if inw`wv' == 1
forvalues hhm = 1 / 35 {
    replace hh`wv'ipena = hh`wv'ipena + in402c_`hhm'_i + in402d_`hhm'_i if !mi(in402c_`hhm'_i_f)
}
replace hh`wv'ipena = .m if hh`wv'ipena==. & inw`wv'==1
label variable hh`wv'ipena "hh`wv'ipena:w`wv' income: hhold income from private pensions"

* wave 1 household income from private pensions flag
gen hh`wv'ifpena = .
combine_h_inc_flag in402c_*_i_f in402d_*_i_f, result(hh`wv'ifpena)
label variable hh`wv'ifpena "hh`wv'ifpena:w`wv' impflag: hhold income from private pensions"
label values hh`wv'ifpena incflag

*****************************************************
* Respondent level income from public pensions
*****************************************************
* wave 1 respondent income from public pensions
gen r`wv'ipubpen = .
forvalues hhm = 1 / 35 {
    replace r`wv'ipubpen = in402a_`hhm'_i + in402b_`hhm'_i if hhorder == `hhm'
}
replace r`wv'ipubpen = .m if r`wv'ipubpen==. & inw`wv'==1
label variable r`wv'ipubpen "r`wv'ipubpen:w`wv' income: r income from public pensions"

gen s`wv'ipubpen =.
spouse r`wv'ipubpen, result(s`wv'ipubpen) wave(`wv')
label variable s`wv'ipubpen "s`wv'ipubpen:w`wv' income: s income from public pensions"

* wave 1 respondent income from public pensions flag
gen r`wv'ifpubpen = .
forvalues hhm = 1 / 35 {
    combine_h_inc_flag in402a_`hhm'_i_f in402b_`hhm'_i_f if hhorder == `hhm', result(r`wv'ifpubpen)
}
label variable r`wv'ifpubpen "r`wv'ifpubpen:w`wv' impflag: r income from public pensions"
label values r`wv'ifpubpen incflag

gen s`wv'ifpubpen = .
spouse r`wv'ifpubpen, result(s`wv'ifpubpen) wave(`wv')
label variable s`wv'ifpubpen "s`wv'ifpubpen:w`wv' impflag: s income from public pensions"
label values s`wv'ifpubpen incflag

*****************************************************
* Household level income from public pensions
*****************************************************
* wave 1 household income from public pensions
gen hh`wv'ipubpen = 0 if inw`wv' == 1
forvalues hhm = 1 / 35 {
    replace hh`wv'ipubpen = hh`wv'ipubpen + in402a_`hhm'_i + in402b_`hhm'_i if !mi(in402a_`hhm'_i_f)
}
replace hh`wv'ipubpen = .m if hh`wv'ipubpen==. & inw`wv'==1
label variable hh`wv'ipubpen "hh`wv'ipubpen:w`wv' income: hhold income from public pensions"

* wave 1 household income from public pensions flag
gen hh`wv'ifpubpen = .
combine_h_inc_flag in402a_*_i_f in402b_*_i_f, result(hh`wv'ifpubpen)
label variable hh`wv'ifpubpen "hh`wv'ifpubpen:w`wv' impflag: hhold income from public pensions"
label values hh`wv'ifpubpen incflag

*****************************************************
* Respondent level income from other pensions
*****************************************************
* wave 1 respondent income from other pensions
gen r`wv'ipeno = .
forvalues hhm = 1 / 35 {
    replace r`wv'ipeno = in402e_`hhm'_i if hhorder == `hhm'
}
replace r`wv'ipeno = .m if r`wv'ipeno==. & inw`wv'==1
label variable r`wv'ipeno "r`wv'ipeno:w`wv' income: r income from other pensions"

gen s`wv'ipeno =.
spouse r`wv'ipeno, result(s`wv'ipeno) wave(`wv')
label variable s`wv'ipeno "s`wv'ipeno:w`wv' income: s income from other pensions"

* wave 1 respondent income from other pensions flag
gen r`wv'ifpeno = .
forvalues hhm = 1 / 35 {
    combine_h_inc_flag in402e_`hhm'_i_f if hhorder == `hhm', result(r`wv'ifpeno)
}
label variable r`wv'ifpeno "r`wv'ifpeno:w`wv' impflag: r income from other pensions"
label values r`wv'ifpeno incflag

gen s`wv'ifpeno = .
spouse r`wv'ifpeno, result(s`wv'ifpeno) wave(`wv')
label variable s`wv'ifpeno "s`wv'ifpeno:w`wv' impflag: s income from other pensions"
label values s`wv'ifpeno incflag

*****************************************************
* Household level income from other pensions
*****************************************************
* wave 1 household income from other pensions
gen hh`wv'ipeno = 0 if inw`wv' == 1
forvalues hhm = 1 / 35 {
    replace hh`wv'ipeno = hh`wv'ipeno + in402e_`hhm'_i if !mi(in402e_`hhm'_i_f)
}
replace hh`wv'ipeno = .m if hh`wv'ipeno==. & inw`wv'==1
label variable hh`wv'ipeno "hh`wv'ipeno:w`wv' income: hhold income from other pensions"

* wave 1 household income from other pensions flag
gen hh`wv'ifpeno = .
combine_h_inc_flag in402e_*_i_f, result(hh`wv'ifpeno)
label variable hh`wv'ifpeno "hh`wv'ifpeno:w`wv' impflag: hhold income from other pensions"
label values hh`wv'ifpeno incflag

*****************************************************
* Respondent level income from all pensions
*****************************************************
gen r`wv'ipen = r`wv'ipena + r`wv'ipubpen + r`wv'ipeno
replace r`wv'ipen = .m if r`wv'ipen==. & inw`wv'==1
label variable r`wv'ipen "r`wv'ipen:w`wv' income: r income from all pensions"

gen s`wv'ipen =.
spouse r`wv'ipen, result(s`wv'ipen) wave(`wv')
label variable s`wv'ipen "s`wv'ipen:w`wv' income: s income from all pensions"

gen r`wv'ifpen = .
combine_h_inc_flag r`wv'ifpena r`wv'ifpubpen r`wv'ifpeno, result(r`wv'ifpen)
label variable r`wv'ifpen "r`wv'ifpen:w`wv' incflag: r income from all pensions"
label values r`wv'ifpen incflag

gen s`wv'ifpen = .
spouse r`wv'ifpen, result(s`wv'ifpen) wave(`wv')
label variable s`wv'ifpen "s`wv'ifpen:w`wv' incflag: s income from all pensions"
label values s`wv'ifpen incflag

*****************************************************
* Household level income from all pensions
*****************************************************
gen hh`wv'ipen = hh`wv'ipena + hh`wv'ipubpen + hh`wv'ipeno
replace hh`wv'ipen = .m if hh`wv'ipen==. & inw`wv'==1
label variable hh`wv'ipen "hh`wv'ipen:w`wv' income: hhold income from all pensions"

gen hh`wv'ifpen = .
combine_h_inc_flag hh`wv'ifpena hh`wv'ifpubpen hh`wv'ifpeno, result(hh`wv'ifpen)
label variable hh`wv'ifpen "hh`wv'ifpen:w`wv' incflag: hhold income from all pensions"
label values hh`wv'ifpen incflag

*****************************************************
* Other government transfers
*****************************************************
gen hh`wv'igxfr = in702a_i + in702b_i + in702c_i + in702d_i + in702e_i + in702f_i + in702g_i + in702h_i + in702i_i + in702j_i + in702k_i + in702l_i + in702m_i
replace hh`wv'igxfr = .m if hh`wv'igxfr==. & inw`wv'==1
label variable hh`wv'igxfr "hh`wv'igxfr:w`wv' income: hhold other government transfer income"

gen hh`wv'ifgxfr = .
combine_h_inc_flag in702a_i_f in702b_i in702c_i in702d_i in702e_i in702f_i in702g_i in702h_i in702i_i in702j_i in702k_i in702l_i in702m_i, result(hh`wv'ifgxfr)
label variable hh`wv'ifgxfr "hh`wv'ifgxfr:w`wv' impflag: hhold other government transfer income"
label values hh`wv'ifgxfr incflag

*****************************************************
* Household support - private transfers
*****************************************************
gen hh`wv'ipxfr = in504_1_i + in504_2_i + in504_3_i + in504_4_i + in504_5_i + ///
                  in504_6_i + in504_7_i + in504_8_i + in504_9_i + in504_10_i + ///
                  in504_11_i + in504_12_i + in504_13_i + in504_14_i + in504_15_i + ///
                  in507a_i + in507b_i 
replace hh`wv'ipxfr = .m if hh`wv'ipxfr==. & inw`wv'==1
label variable hh`wv'ipxfr "hh`wv'ipxfr:w`wv' income: hhold support - private transfers"

gen hh`wv'ifpxfr = .
combine_h_inc_flag in504_1_i_f in504_2_i_f in504_3_i_f in504_4_i_f in504_5_i_f ///
                   in504_6_i_f in504_7_i_f in504_8_i_f in504_9_i_f in504_10_i_f ///
                   in504_11_i_f in504_12_i_f in504_13_i_f in504_14_i_f in504_15_i_f ///
                   in507a_i_f in507b_i_f, result(hh`wv'ifpxfr)
label variable hh`wv'ifpxfr "hh`wv'ifpxfr:w`wv' impflag: hhold support - private transfers"
label values hh`wv'ifpxfr incflag

*****************************************************
* Other income
*****************************************************
gen hh`wv'iothr = in602_i
label variable hh`wv'iothr "hh`wv'iothr:w`wv' income: hhold other income"

gen hh`wv'ifothr = in602_i_f
label variable hh`wv'ifothr "hh`wv'ifothr:w`wv' impflag: hhold other income"
label values hh`wv'ifothr incflag

*****************************************************
* Total Income
*****************************************************
* add up total income
gen hh`wv'itot = 	hh`wv'iearn + hh`wv'ipen + hh`wv'icap  + ///
                    hh`wv'igxfr + hh`wv'iothr + hh`wv'ipxfr
replace hh`wv'itot = .m if hh`wv'itot==. & inw`wv'==1
label variable hh`wv'itot "hh`wv'itot:w`wv' income: hhold total household income"

* combine income flags
gen hh`wv'iftot = .
combine_h_inc_flag  hh`wv'ifearn hh`wv'ifpen hh`wv'ifcap hh`wv'ifgxfr ///
                    hh`wv'ifothr hh`wv'ifpxfr, result(hh`wv'iftot)
label variable hh`wv'iftot "hh`wv'iftot:w`wv' incflag: hhold total household income"
label values hh`wv'iftot incflag

*****************************************************
*** Consumption ***
*****************************************************
* Food Consumption
*****************************************************
gen hh`wv'cfood1w = co002a_i + co002b_i + co002c_i + co002d_i + co002e_i + co002f_i + co002g_i + co002h_i + co002i_i + co002j_i
replace hh`wv'cfood1w = .m if hh`wv'cfood1w==. & inw`wv'==1
label variable hh`wv'cfood1w "hh`wv'cfood1w:w`wv' consumption: hhold weekly food consumption"

gen hh`wv'cffood1w = .
combine_h_inc_flag co002a_i_f co002b_i_f co002c_i_f co002d_i_f co002e_i_f co002f_i_f co002g_i_f co002h_i_f co002i_i_f co002j_i_f, result(hh`wv'cffood1w)
label variable hh`wv'cffood1w "hh`wv'cffood1w:w`wv' impflag: hhold weekly food consumption"
label values hh`wv'cffood1w comflag 

*****************************************************
* Regularly Recurring Non-food expenditures
*****************************************************
gen hh`wv'cnf1m = co101_i + co102_i + co103_i + co104_i + co105_i + co106_i + co107_i
label variable hh`wv'cnf1m "hh`wv'cnf1m:w`wv' consumption: hhold total regular non-food expenditures last 30 days"

gen hh`wv'cfnf1m = .
combine_h_inc_flag co101_i_f co102_i_f co103_i_f co104_i_f co105_i_f co106_i_f co107_i_f, result(hh`wv'cfnf1m)
label variable hh`wv'cfnf1m "hh`wv'cfnf1m:w`wv' impflag: hhold total regular non-food expenditures last 30 days"
label values hh`wv'cfnf1m comflag

*****************************************************
* Outpatient Health Care Expenses
*****************************************************
gen hh`wv'cohc1m = co108_i + co109_i + co110_i + co111_i
label variable hh`wv'cohc1m "hh`wv'cohc1m:w`wv' consumption: hhold total outpatient health care expenses last 30 days"

gen hh`wv'cfohc1m = .
combine_h_inc_flag co108_i_f co109_i_f co110_i_f co111_i_f, result(hh`wv'cfohc1m)
label variable hh`wv'cfohc1m "hh`wv'cfohc1m:w`wv' impflag: hhold total outpatient health care expenses last 30 days"
label values hh`wv'cfohc1m comflag

*****************************************************
* Inpatient Health Care Expenses
*****************************************************
gen hh`wv'cihc1y = co202_i + co203_i + co204_i + co205_i + co206_i
label variable hh`wv'cihc1y "hh`wv'cihc1y:w`wv' consumption: hhold total inpatient health care expenses last 12 months"

gen hh`wv'cfihc1y = .
combine_h_inc_flag co202_i_f co203_i_f co204_i_f co205_i_f co206_i_f, result(hh`wv'cfihc1y)
label variable hh`wv'cfihc1y "hh`wv'cfihc1y:w`wv' impflag: hhold total inpatient health care expenses last 12 months"
label values hh`wv'cfihc1y comflag

*****************************************************
* Non-regular Non-food Expenditures
*****************************************************
gen hh`wv'cnf1y = co209_i + co210_i + co211_i + co212_i + co213_i + co214_i + co215_i + co216_i
label variable hh`wv'cnf1y "hh`wv'cnf1y:w`wv' consumption: hhold total non-regular, non-food expenditures last 12 months"

gen hh`wv'cfnf1y = .
combine_h_inc_flag co209_i_f co210_i_f co211_i_f co212_i_f co213_i_f co214_i_f co215_i_f co216_i_f, result(hh`wv'cfnf1y)
label variable hh`wv'cfnf1y "hh`wv'cfnf1y:w`wv' implfag: hhold total non-regular, non-food expenditures last 12 months"
label values hh`wv'cfnf1y comflag

*****************************************************
* Household Consumption
*****************************************************
***Total household consumption
**Total household consumption (annual)
gen hh`wv'ctot = hh`wv'cfood1w*52 + hh`wv'cnf1m*12 + hh`wv'cohc1m*12 + hh`wv'cihc1y + hh`wv'cnf1y
replace hh`wv'ctot = .m if hh`wv'ctot==. & inw`wv'==1
label variable hh`wv'ctot "hh`wv'ctot:w`wv' consumption: hhold yearly total consumption"

* consumption flag
gen hh`wv'cftot = .
combine_h_inc_flag hh`wv'cffood1w hh`wv'cfnf1m hh`wv'cfohc1m hh`wv'cfihc1y hh`wv'cfnf1y, result(hh`wv'cftot)
label variable hh`wv'cftot "hh`wv'cftot:w`wv' impflag: hhold yearly total consumption"
label values hh`wv'cftot comflag

*****************************************************
* Household Consumption Per Capita
*****************************************************
***per capita hh consumption
gen hh`wv'cperc=hh`wv'ctot/hh`wv'hhres
replace hh`wv'cperc = .m if hh`wv'cperc==. & inw`wv'==1
label variable hh`wv'cperc "hh`wv'cperc:w`wv' consumption: hhold yearly total consumption per capita"

* consumption flag
gen hh`wv'cfperc = hh`wv'cftot
label variable hh`wv'cfperc "hh`wv'cfperc:w`wv' impflag: hhold yearly total consumption per capita"
label values hh`wv'cfperc comflag

*********************************************************

*****************************************************
* Indicator of poverty
*****************************************************
***household indicator of poverty
local india_2011_ppp = 15.5
local india_2017_ppp = 20.6
local india_2018_ppp = 20.9
local india_2019_ppp = 21.1
local india_2020_ppp = 22.0
local india_2021_ppp = 23.1

tempvar adjust_consumption
gen `adjust_consumption' = .
forvalues y = 2017 / 2021 {
    replace `adjust_consumption' = (hh`wv'cperc/365)/`india_`y'_ppp'*(`india_2011_ppp'/`india_`y'_ppp') if r1iwy == `y'
}
gen hh`wv'poverty = .m if inw`wv' == 1
replace hh`wv'poverty = 0 if `adjust_consumption' > 1.90 & !mi(`adjust_consumption')
replace hh`wv'poverty = 1 if `adjust_consumption' <= 1.90 & !mi(`adjust_consumption')
label variable hh`wv'poverty "hh1poverty:w`wv' hhold at international poverty line"
label values hh`wv'poverty poverty


****drop IN impuation raw variables***
drop `income_w1_in_imput'

****drop AD impuation raw variables***
drop `income_w1_ad_imput'

****drop CO impuation raw variables***
drop `income_w1_co_imput'


***Labor Force Status***
label define labor ///
	1 "1.wage/salary worker" ///
	2 "2.paid family worker" ///
	3 "3.non-agri self-employed" ///
	4 "4.farm/fishery/forestry (own/family)" ///
	5 "5.agricultural laborer" ///
	6 "6.unemployed and looking for job" ///
	7 "7.disabled" ///
	8 "8.homemaker" ///
	9 "9.other" ///
	10 "10.never worked" /// 
	.d ".d:DK" ///
	.r ".r:Refuse" ///
	.m ".m:Missing" 
	
***Simplified Labor Force Status***
label define slabor ///
	1 "1.employed" ///
	2 "2.self-employed" ///
	3 "3.unemployed" ///
	4 "4.homemaker" ///
	5 "5.other" ///
	.d ".d:DK" ///
	.r ".r:Refuse" ///
	.m ".m:Missing" 	
	
***whether in a labor force status
label define lbfyesno ///
    0 "0.no" ///
    1 "1.yes" ///
    .x ".x:Not in the labor force"	///
    .d ".d:DK" ///
    .r ".r:Refuse" ///
    .m ".m:Missing" ///
    .w ".w:not working" /// 
    .n ".n:not wage worker"

***Current Job Requires...***
label define jphys ///
	1 "1.all or almost all of the time" ///
	2 "2.most of the time" ///
	3 "3.sometimes" ///
	4 "4.none of the time or almost never" ///
	.w ".w:not working" ///
	.d ".d:DK" ///
	.r ".r:Refuse" ///
	.m ".m:Missing" 
	
***Occupation Code for Current Job***
label define occup ///
	1 "1.legislators, senior officials and managers" ///
	2 "2.professionals" ///
	3 "3.technicians and associate professionals" ///
	4 "4.clerks" ///
	5 "5.service workers and shop and market sales workers" ///
	6 "6.skilled agricultural and fishery workers" ///
	7 "7.craft and related trade workers" ///
	8 "8.plant and machine operators and assemblers" ///
	9 "9.elementary occupations" ///
	10 "10.workers not classified anywhere" ///
	11 "11.other" ///
	.w ".w:not working" ///
	.d ".d:DK" ///
	.r ".r:Refuse" ///
	.m ".m:Missing" 
	
***Industry Code for Current Job***
label define industry ///
	1 "1.agriculture, forestry, and fishing" ///
	2 "2.mining and quarrying" ///
	3 "3.manufacturing" ///
	4 "4.electricity, gas, steam, or air conditioning supply" ///
	5 "5.water supply: sewage, waste management and remediation activities" ///
	6 "6.construction" ///
	7 "7.wholesale and retail trade" ///
	8 "8.transportation and storage" ///
	9 "9.accommodation and food service activities" ///
	10 "10.information and communication" ///
	11 "11.financial and insurance activities" ///
	12 "12.real estate activities" ///
	13 "13.professional, scientific, and technical activities" ///
	14 "14.administrative and support service activities" ///
	15 "15.public administration and defense; compulsory social security" ///
	16 "16.education" ///
	17 "17.human health and social work activities" ///
	18 "18.art, entertainment, and recreation" ///
	19 "19.other service activities" ///
	20 "20.activities of households as employers: undifferentiated goods/services-producing activities of households for own use" ///
	21 "21.activities of extraterritorial organizations and bodies" ///
	22 "22.other" ///
	.w ".w:not working" ///
	.d ".d:DK" ///
	.r ".r:Refuse" ///
	.m ".m:Missing" 
	
***Wage flag
label define empflag ///
   -1 "-1.not imputed, missing neighbors" ///
   -2 "-2.not imputed, missing covariates" ///
   1 "1.continuous value" ///
   2 "2.complete bracket" ///
   3 "3.incomplete bracket" ///
   5 "5.no value/bracket" ///
   6 "6.no receipt" ///
   7 "7.dk receipt"	///
   8 "8.module not answered"
   
***Yes/No, never employed 
label define empyesno ///
	0 "0.no" ///
	1 "1.yes" ///
	.n ".n:never worked" ///
	.d ".d:DK" ///
	.r ".r:Refuse" ///
	.m ".m:Missing" ///
	.s ".s:skipped" ///
	.w ".w:not working" 
	
***Looking for part-time or full-time job
label define pftime ///
	1 "1.part-time work" ///
	2 "2.full-time work" ///
	3 "3.either" ///
	.m ".m:Missing" ///
	.r ".r:Refuse" ///
	.d ".d:DK" ///
	.n ".n:never worked" ///
	.l ".l:not looking for work" ///
	.w ".w:not working"
	
***Looking for same or different work
label define worksd ///
	1 "1.same as now" ///
	2 "2.different" ///
	3 "3.does not matter" ///
	.m ".m:Missing" ///
	.r ".r:Refuse" ///
	.d ".d:DK" ///
	.n ".n:never worked" ///
	.l ".l:not looking for work" ///
	.w ".w:not working"
	
***Looking for job in area or move
label define workarea ///
	1 "1.jobs in this area" ///
	2 "2.jobs in other specific area" ///
	3 "3.anywhere" ///
	.m ".m:Missing" ///
	.r ".r:Refuse" ///
	.d ".d:DK" ///
	.n ".n:never worked" ///
	.l ".l:not looking for work" ///
	.w ".w:not working"
	
***Looking for part-time or full-time job
label define unpftime ///
	1 "1.part-time work" ///
	2 "2.full-time work" ///
	3 "3.either" ///
	.m ".m:Missing" ///
	.r ".r:Refuse" ///
	.d ".d:DK" ///
	.n ".n:never worked" ///
	.l ".l:not looking for work" ///
	.w ".w:working"
	
***Looking for same or different work
label define unworksd ///
	1 "1.same as now" ///
	2 "2.different" ///
	3 "3.does not matter" ///
	.m ".m:Missing" ///
	.r ".r:Refuse" ///
	.d ".d:DK" ///
	.n ".n:never worked" ///
	.l ".l:not looking for work" ///
	.w ".w:working"
	
***Looking for job in area or move
label define unworkarea ///
	1 "1.jobs in this area" ///
	2 "2.jobs in other specific area" ///
	3 "3.anywhere" ///
	.m ".m:Missing" ///
	.r ".r:Refuse" ///
	.d ".d:DK" ///
	.n ".n:never worked" ///
	.l ".l:not looking for work" ///
	.w ".w:working"
	
		



*set wave number
local wv=1

***merge with file***
local employ_w1_ind we001 we003 we004 we005 we014 we012 we012a we012b we013 we013a we014 ///
		we015 we015a we016 we016_mainjob we017 we018 we019 we026 ///
		we023 we024_month we024_year we027_main we027_other we027_sub ///
		we028a we028b we028c we028d we028e we028f we028g we028h we028i we101 we102 we103 we110 we114 we114a /// 
		we201 we204s1 we204s2 we204s3 we205 we206 we301 we302 dm005 we420 fs103_1
		
merge 1:1 prim_key using  "$wave_1_ind_bm", keepusing(`employ_w1_ind') nogen

***merge with wave 1 we impuations files
local employ_w1_wei we020_i we020_i_f /// 
		            we021_i we021_i_f 
		
merge 1:1 prim_key using  "$wave_1_we_imput", keepusing(`employ_w1_wei') nogen

**************************************************
***Working***
*whether currently working (includes unpaid workers)
gen r`wv'worka = .
missing_lasi we001 we004 we005, result(r`wv'worka) wave(`wv')
replace r`wv'worka = 0 if inlist(we004,.e,2) | we001 == 2
replace r`wv'worka = 1 if we004 == 1 | we005 == 1
label variable r`wv'worka "r`wv'worka:w`wv' whether r works"
label values r`wv'worka lbfyesno

*spouse
gen s`wv'worka = .
spouse r`wv'worka, result(s`wv'worka) wave(`wv')
label variable s`wv'worka "s`wv'worka:w`wv' whether s works"
label values s`wv'worka lbfyesno

***Working for Pay***
*whether currently working for pay
gen r`wv'work = .
missing_lasi we001 we004 we005 we012 we012a we012b we013 we014 we015 we015a we016_mainjob, result(r`wv'work) wave(`wv')
replace r`wv'work = 0 if inlist(we004,.e,2) | we001==2 | we012b==4 | we014==2
replace r`wv'work = 1 if we012a==1 | inlist(we012b,1,2,3) | we013==1 | we014==1 | inlist(we015a,1,2,3)
label variable r`wv'work "r`wv'work:w`wv' whether r works for pay"
label values r`wv'work lbfyesno

*spouse
gen s`wv'work = .
spouse r`wv'work, result(s`wv'work) wave(`wv')
label variable s`wv'work "s`wv'work:w`wv' whether s works for pay"
label values s`wv'work lbfyesno

***Works at 2nd Job***
*wave 1 respondent works at 2nd job
gen r`wv'work2 = .
missing_lasi we001 we004 we017, result(r`wv'work2) wave(`wv')
replace r`wv'work2 = 0 if we017 == 0 | inlist(we004,.e,2) | we001 == 2
replace r`wv'work2 = 1 if inrange(we017,1,10)
label variable r`wv'work2 "r`wv'work2:w`wv' r works at 2nd job"
label values r`wv'work2 lbfyesno

**wave 1 spouse works at 2nd job
gen s`wv'work2 = .
spouse r`wv'work2, result(s`wv'work2) wave(`wv')
label variable s`wv'work2 "s`wv'work2:w`wv' s works at 2nd job"
label values s`wv'work2 lbfyesno

***Number of secondary-jobs
gen r`wv'njobs2 = .
missing_lasi we017, result(r`wv'njobs2) wave(`wv')
replace r`wv'njobs2 = 0 if r`wv'work2 == 0
replace r`wv'njobs2 = we017 if inrange(we017,1,10)
label variable r`wv'njobs2 "r`wv'njobs2:w`wv' r number of secondary jobs"

**wave 1 spouse number of secondary jobs
gen s`wv'njobs2 = .
spouse r`wv'njobs2, result(s`wv'njobs2) wave(`wv')
label variable s`wv'njobs2 "s`wv'njobs2:w`wv' s number of secondary jobs"

**************************************************
***Whether Self-Employed***
*wave 1 respondent whether self-employed
gen r`wv'slfemp = .
missing_lasi we016_mainjob r`wv'worka, result(r`wv'slfemp) wave(`wv')
replace r`wv'slfemp = .w if r`wv'worka == 0 
replace r`wv'slfemp = 0 if inlist(we016_mainjob,1,2,5,6)
replace r`wv'slfemp = 1 if inlist(we016_mainjob,3,4)
label variable r`wv'slfemp "r`wv'slfemp:w`wv' r whether self-employed"
label values r`wv'slfemp lbfyesno

*wave 1 spouse whether self-employed
gen s`wv'slfemp = .
spouse r`wv'slfemp, result(s`wv'slfemp) wave(`wv')
label variable s`wv'slfemp "s`wv'slfemp:w`wv' s whether self-employed"
label values s`wv'slfemp lbfyesno

**************************************************
***Labor Force Status***
*wave 1 respondent labor force status
* LASI specific rWlbrf variable: rWlbrf_l
gen r`wv'lbrf_l = .
missing_lasi we001 we005 we016_mainjob we201, result(r`wv'lbrf_l) wave(`wv')
replace r`wv'lbrf_l = 10 if inlist(we016_mainjob,.,.e) & we001 == 2
replace r`wv'lbrf_l = 9 if inlist(we016_mainjob,.,.e) & we005 == 5
replace r`wv'lbrf_l = 8 if inlist(we016_mainjob,.,.e) & we005 == 4
replace r`wv'lbrf_l = 7 if inlist(we016_mainjob,.,.e) & we005 == 3
replace r`wv'lbrf_l = 6 if (inlist(we016_mainjob,.,.e) & we005 == 2) | (we004==2 & we201==1)
replace r`wv'lbrf_l = 5 if we016_mainjob==2
replace r`wv'lbrf_l = 4 if we016_mainjob==1
replace r`wv'lbrf_l = 3 if inlist(we016_mainjob,3,4)
replace r`wv'lbrf_l = 2 if we016_mainjob==6
replace r`wv'lbrf_l = 1 if we016_mainjob==5
label variable r`wv'lbrf_l "r`wv'lbrf_l:w`wv' r labor force status"
label values r`wv'lbrf_l labor

*wave 1 spouse labor force status
gen s`wv'lbrf_l = .
spouse r`wv'lbrf_l, result(s`wv'lbrf_l) wave(`wv')
label variable s`wv'lbrf_l "s`wv'lbrf_l:w`wv' s labor force status"
label values s`wv'lbrf_l labor

*wave 1 respondent simplified labor force status
gen r`wv'lbrfs_l = .
missing_H r`wv'lbrf_l, result(r`wv'lbrfs_l) 
replace r`wv'lbrfs_l = 1 if r`wv'lbrf_l == 1
replace r`wv'lbrfs_l = 2 if inlist(r`wv'lbrf_l,2,3,4,5) 
replace r`wv'lbrfs_l = 3 if r`wv'lbrf_l == 6
replace r`wv'lbrfs_l = 4 if r`wv'lbrf_l == 8
replace r`wv'lbrfs_l = 5 if inlist(r`wv'lbrf_l,7,9,10) 
label variable r`wv'lbrfs_l "r`wv'lbrfs_l:w`wv' r simple labor force status"
label values r`wv'lbrfs_l slabor

*wave 1 spouse simplified labor force status
gen s`wv'lbrfs_l = .
spouse r`wv'lbrfs_l, result(s`wv'lbrfs_l) wave(`wv')
replace s`wv'lbrfs_l = 1 if fs103_1 == 1
replace s`wv'lbrfs_l = 2 if fs103_1 == 2
replace s`wv'lbrfs_l = 3 if fs103_1 == 3
replace s`wv'lbrfs_l = 4 if fs103_1 == 4
replace s`wv'lbrfs_l = 5 if inlist(fs103_1,5,6)
recode s`wv'lbrfs_l (.v=.m)
label variable s`wv'lbrfs_l "s`wv'lbrfs_l:w`wv' s simple labor force status"
label values s`wv'lbrfs_l slabor

**************************************************
***Whether in Labor Force***
*wave 1 respondent whether in labor force
gen r`wv'inlbrf = .
missing_H r`wv'lbrf_l, result(r`wv'inlbrf) 
replace r`wv'inlbrf = 0 if inlist(r`wv'lbrfs_l,4,5)
replace r`wv'inlbrf = 1 if inlist(r`wv'lbrfs_l,1,2,3)
label variable r`wv'inlbrf "r`wv'inlbrf:w`wv' r =1 if in the labor force"
label values r`wv'inlbrf lbfyesno

*wave 1 spouse whether in labor force
gen s`wv'inlbrf = .
spouse r`wv'inlbrf, result(s`wv'inlbrf) wave(`wv')
replace s`wv'inlbrf = 0 if inlist(s`wv'lbrfs_l,4,5) & mi(s`wv'inlbrf)
replace s`wv'inlbrf = 1 if inlist(s`wv'lbrfs_l,1,2,3) & mi(s`wv'inlbrf)
recode s`wv'inlbrf (.v=.m)
label variable s`wv'inlbrf "s`wv'inlbrf:w`wv' s =1 if in the labor force"
label values s`wv'inlbrf lbfyesno

**************************************************
***Whether Unemployed***
*wave 1 respondent whether unemployed
gen r`wv'unemp = .
missing_H r`wv'lbrf_l, result(r`wv'unemp) 
replace r`wv'unemp = .x if inlist(r`wv'lbrfs_l,4,5)
replace r`wv'unemp = 0 if inlist(r`wv'lbrfs_l,1,2)
replace r`wv'unemp = 1 if r`wv'lbrfs_l == 3
label variable r`wv'unemp "r`wv'unemp:w`wv' r =1 if unemployed"
label values r`wv'unemp lbfyesno

*wave 1 spouse whether unemployed
gen s`wv'unemp = .
spouse r`wv'unemp, result(s`wv'unemp) wave(`wv')
replace s`wv'unemp = .x if inlist(s`wv'lbrfs_l,4,5) & mi(s`wv'unemp)
replace s`wv'unemp = 0 if inlist(s`wv'lbrfs_l,1,2) & mi(s`wv'unemp)
replace s`wv'unemp = 1 if s`wv'lbrfs_l == 3 & mi(s`wv'unemp)
recode s`wv'unemp (.v=.m)
label variable s`wv'unemp "s`wv'unemp:w`wv' s =1 if unemployed"
label values s`wv'unemp lbfyesno

**************************************************
***Hours Worked/Week Main Job***
*wave 1 respondent hours worked/week main job
gen r`wv'jhours = .
missing_lasi we018 r`wv'worka, result(r`wv'jhours) wave(`wv')
replace r`wv'jhours = .w if r`wv'worka == 0
replace r`wv'jhours = we018 if inrange(we018,0,168)
label variable r`wv'jhours "r`wv'jhours:w`wv' r hours worked/week main job"

*wave 1 spouse hours worked/week main job
gen s`wv'jhours = .
spouse r`wv'jhours, result(s`wv'jhours) wave(`wv')
label variable s`wv'jhours "s`wv'jhours:w`wv' s hours worked/week main job"

***Hours Worked/Week 2nd Job***
*wave 1 respondent hours worked/week 2nd job
gen r`wv'jhour2 = .
missing_lasi we019 r`wv'work2, result(r`wv'jhour2) wave(`wv')
replace r`wv'jhour2 = .w if r`wv'work2 == 0
replace r`wv'jhour2 = we019 if inrange(we019,0,168)
label variable r`wv'jhour2 "r`wv'jhour2:w`wv' r hours worked/week 2nd job"

*wave 1 spouse hours worked/week 2nd job
gen s`wv'jhour2 = .
spouse r`wv'jhour2, result(s`wv'jhour2) wave(`wv')
label variable s`wv'jhour2 "s`wv'jhour2:w`wv' s hours worked/week 2nd job"

***Total hours worked/week***
*wave 1 respondent total hours worked/week
egen total = rowtotal(r`wv'jhours r`wv'jhour2) if inw`wv'==1,m

gen r`wv'jhourtot = .
missing_lasi r`wv'jhours r`wv'jhour2 r`wv'worka, result(r`wv'jhourtot) wave(`wv')
replace r`wv'jhourtot = .w if r`wv'worka==0
replace r`wv'jhourtot = total if inrange(total,0,336)
label variable r`wv'jhourtot "r`wv'jhourtot:w`wv' r total hours worked/week"

*wave 1 spouse total hours worked/week
gen s`wv'jhourtot = .
spouse r`wv'jhourtot, result(s`wv'jhourtot) wave(`wv')
label variable s`wv'jhourtot "s`wv'jhourtot:w`wv' s total hours worked/week"

drop total

**************************************************
***Weeks Worked/Year Main Job***
*wave 1 respondent weeks worked/year main job
gen r`wv'jweeks_l = .
missing_lasi we026 r`wv'worka, result(r`wv'jweeks_l) wave(`wv')
replace r`wv'jweeks_l = .w if r`wv'worka == 0
replace r`wv'jweeks_l = round(we026*4.3333) if inrange(we026,0,12)
label variable r`wv'jweeks_l "r`wv'jweeks_l:w`wv' r weeks worked/year main job"

*wave 1 spouse weeks worked/year main job
gen s`wv'jweeks_l = .
spouse r`wv'jweeks_l, result(s`wv'jweeks_l) wave(`wv')
label variable s`wv'jweeks_l "s`wv'jweeks_l:w`wv' s weeks worked/year main job"

**************************************************
***Wage Rate-Weekly Main Job***
*wave 1 respondent wage rate-weekly main job
gen r`wv'wgiwk = we020_i
label variable r`wv'wgiwk "r`wv'wgiwk:w`wv' r wage rate-wkly main job"

**wave 1 respondent wage rate-weekly main job imputation flag
gen r`wv'wgfwk = we020_i_f
label variable r`wv'wgfwk "r`wv'wgfwk:w`wv' r impflag:wage rate-wkly main job"
label values r`wv'wgfwk empflag

*wave 1 spouse wage rate-weekly main job
gen s`wv'wgiwk = .
spouse r`wv'wgiwk, result(s`wv'wgiwk) wave(`wv')
label variable s`wv'wgiwk "s`wv'wgiwk:w`wv' s wage rate-wkly main job"

*wave 1 spouse wage rate-weekly main job imputation flag
gen s`wv'wgfwk = .
spouse r`wv'wgfwk, result(s`wv'wgfwk) wave(`wv')
label variable s`wv'wgfwk "s`wv'wgfwk:w`wv' s impflag:wage rate-wkly main job"
label values s`wv'wgfwk empflag

***Wage Rate-Weekly 2nd Job***
*wave 1 respondent wage rate-weekly 2nd job
gen r`wv'wgiwk2 = we021_i 
label variable r`wv'wgiwk2 "r`wv'wgiwk2:w`wv' r wage rate-wkly 2nd job"

**wave 1 respondent wage rate-weekly 2nd job imputation flag
gen r`wv'wgfwk2 = we021_i_f
label variable r`wv'wgfwk2 "r`wv'wgfwk2:w`wv' r impflag:wage rate-wkly 2nd job"
label values r`wv'wgfwk2 empflag

*wave 1 spouse wage rate-weekly 2nd job
gen s`wv'wgiwk2 = .
spouse r`wv'wgiwk2, result(s`wv'wgiwk2) wave(`wv')
label variable s`wv'wgiwk2 "s`wv'wgiwk2:w`wv' s wage rate-wkly 2nd job"

*wave 1 spouse wage rate-weekly 2nd job imputation flag
gen s`wv'wgfwk2 = .
spouse r`wv'wgfwk2, result(s`wv'wgfwk2) wave(`wv')
label variable s`wv'wgfwk2 "s`wv'wgfwk2:w`wv' s impflag:wage rate-wkly 2nd job"
label values s`wv'wgfwk2 empflag

**************************************************
***Current Job Requires Lots of Physical Effort***
*wave 1 respondent current job requires lots of physical effort
gen r`wv'jphys = .
missing_lasi we028a r`wv'worka, result(r`wv'jphys) wave(`wv')
replace r`wv'jphys = .w if r`wv'worka == 0
replace r`wv'jphys = we028a if inrange(we028a,1,4)
label variable r`wv'jphys "r`wv'jphys:w`wv' r cur job req lots phys effort"
label values r`wv'jphys jphys

*wave 1 spouse current job requires lots of physical effort
gen s`wv'jphys = .
spouse r`wv'jphys, result(s`wv'jphys) wave(`wv')
label variable s`wv'jphys "s`wv'jphys:w`wv' s cur job req lots phys effort"
label values s`wv'jphys jphys

**************************************************
***Current Job Requires Lifting Heavy Loads***
*wave 1 respondent current job requires lifting heavy loads
gen r`wv'jlift = .
missing_lasi we028b r`wv'worka, result(r`wv'jlift) wave(`wv')
replace r`wv'jlift = .w if r`wv'worka == 0
replace r`wv'jlift = we028b if inrange(we028b,1,4)
label variable r`wv'jlift "r`wv'jlift:w`wv' r cur job req lift heavy loads"
label values r`wv'jlift jphys

*wave 1 spouse current job requires lifting heavy loads
gen s`wv'jlift = .
spouse r`wv'jlift, result(s`wv'jlift) wave(`wv')
label variable s`wv'jlift "s`wv'jlift:w`wv' s cur job req lift heavy loads"
label values s`wv'jlift jphys


**************************************************
***Current Job Requires Stooping, Kneeling, or Crouching***
*wave 1 respondent current job requires stooping
gen r`wv'jstoop = .
missing_lasi we028c r`wv'worka, result(r`wv'jstoop) wave(`wv')
replace r`wv'jstoop = .w if r`wv'worka == 0
replace r`wv'jstoop = we028c if inrange(we028c,1,4)
label variable r`wv'jstoop "r`wv'jstoop:w`wv' r cur job req stoop/kneel/crouch"
label values r`wv'jstoop jphys

*wave 1 spouse current job requires stooping, kneeling, or crouching
gen s`wv'jstoop = .
spouse r`wv'jstoop, result(s`wv'jstoop) wave(`wv')
label variable s`wv'jstoop "s`wv'jstoop:w`wv' s cur job req stoop/kneel/crouch"
label values s`wv'jstoop jphys


**************************************************
***Current Job Requires Good Eyesight***
*wave 1 respondent current job requires good eyesight
gen r`wv'jsight = .
missing_lasi we028d r`wv'worka, result(r`wv'jsight) wave(`wv')
replace r`wv'jsight = .w if r`wv'worka == 0
replace r`wv'jsight = we028d if inrange(we028d,1,4)
label variable r`wv'jsight "r`wv'jsight:w`wv' r cur job req good eyesight"
label values r`wv'jsight jphys

*wave 1 spouse current job requires good eyesight
gen s`wv'jsight = .
spouse r`wv'jsight, result(s`wv'jsight) wave(`wv')
label variable s`wv'jsight "s`wv'jsight:w`wv' s cur job req good eyesight"
label values s`wv'jsight jphys


**************************************************
***Current Job Requires Intense Concentration  
*wave 1 respondent current job requires intense concentration/attention
gen r`wv'jconcntrb=.
missing_lasi we028e r`wv'worka, result(r`wv'jconcntrb) wave(`wv')
replace r`wv'jconcntrb = .w if r`wv'worka == 0
replace r`wv'jconcntrb = we028e if inrange(we028e,1,4)
label variable r`wv'jconcntrb "r`wv'jconcntrb:w`wv' r freq cur job concentration"
label values r`wv'jconcntrb jphys

*wave 1 spouse current job requires intense concentration/attention
gen s`wv'jconcntrb=.
spouse r`wv'jconcntrb, result(s`wv'jconcntrb) wave(`wv')
label variable s`wv'jconcntrb "s`wv'jconcntrb:w`wv' s freq cur job concentration"
label values s`wv'jconcntrb jphys


**************************************************
***Current job requires dealing with people
*wave 1 respondent current job requires dealing with people
gen r`wv'jdealpplb=.
missing_lasi we028f r`wv'worka, result(r`wv'jdealpplb) wave(`wv')
replace r`wv'jdealpplb = .w if r`wv'worka==0
replace r`wv'jdealpplb=we028f if inrange(we028f,1,4)
label variable r`wv'jdealpplb "r`wv'jdealpplb:w`wv' r freq cur job dealing with people"
label values r`wv'jdealpplb jphys

*wave 1 spouse current job requires dealing with people
gen s`wv'jdealpplb=.
spouse r`wv'jdealpplb, result(s`wv'jdealpplb) wave(`wv')
label variable s`wv'jdealpplb "s`wv'jdealpplb:w`wv' s freq cur job dealing with people"
label values s`wv'jdealpplb jphys 


**************************************************
***Current job requires being around burning material, exhaust, smoke - LASI only
*wave 1 respondent current job requires being around burning material, exhaust, smoke
gen r`wv'jsmoka=.
missing_lasi we028g r`wv'worka, result(r`wv'jsmoka) wave(`wv')
replace r`wv'jsmoka = .w if r`wv'worka==0
replace r`wv'jsmoka=we028g if inrange(we028g,1,4)
label variable r`wv'jsmoka "r`wv'jsmoka:w`wv' r freq cur job around burning material/exhaust/smoke"
label values r`wv'jsmoka jphys

*wave 1 spouse current job requires being around burning material, exhaust, smoke
gen s`wv'jsmoka=.
spouse r`wv'jsmoka, result(s`wv'jsmoka) wave(`wv')
label variable s`wv'jsmoka "s`wv'jsmoka:w`wv' s freq cur job around burning material/exhaust/smoke"
label values s`wv'jsmoka jphys


**************************************************
***Current job close to chemicals/pesticides/herbicides
*wave 1 respondent 
gen r`wv'jchema=.
missing_lasi we028h r`wv'worka, result(r`wv'jchema) wave(`wv')
replace r`wv'jchema=.w if r`wv'worka==0
replace r`wv'jchema=we028h if inrange(we028h,1,4)
label variable r`wv'jchema "r`wv'jchema:w`wv' r freq cur job close to chemicals/pesticides/herbicides"
label values r`wv'jchema jphys

*wave 1 spouse
gen s`wv'jchema=.
spouse r`wv'jchema, result(s`wv'jchema) wave(`wv')
label variable s`wv'jchema "s`wv'jchema:w`wv' s freq cur job close to chemicals/pesticides/herbicides"
label values s`wv'jchema jphys


**************************************************
***Current job close to noxious odor
*wave 1 respondent
gen r`wv'jodora=.
missing_lasi we028i r`wv'worka, result(r`wv'jodora) wave(`wv')
replace r`wv'jodora=.w if r`wv'worka==0
replace r`wv'jodora=we028i if inrange(we028i,1,4)
label variable r`wv'jodora "r`wv'jodora:w`wv' r freq cur job close to noxious odor"
label values r`wv'jodora jphys

*wave 1 spouse
gen s`wv'jodora=.
spouse r`wv'jodora, result(s`wv'jodora) wave(`wv')
label variable s`wv'jodora "s`wv'jodora:w`wv' s freq cur job close to noxious odor"
label values s`wv'jodora jphys


***Employed by government sector
*wave 1 respondent
gen r`wv'jgovtemp = .
missing_lasi we101 we016_mainjob r`wv'worka, result(r`wv'jgovtemp) wave(`wv')
replace r`wv'jgovtemp = .w if r`wv'worka==0
replace r`wv'jgovtemp = .n if inlist(we016_mainjob,1,2,3,4,6)
replace r`wv'jgovtemp = 0 if inrange(we101,2,6)
replace r`wv'jgovtemp = 1 if we101==1
label variable r`wv'jgovtemp "r`wv'jgovtemp:w`wv' r employed by government sector"
label values r`wv'jgovtemp lbfyesno

*wave 1 spouse
gen s`wv'jgovtemp = .
spouse r`wv'jgovtemp, result(s`wv'jgovtemp) wave(`wv')
label variable s`wv'jgovtemp "s`wv'jgovtemp:w`wv' s employed by government sector"
label values s`wv'jgovtemp lbfyesno

***Whether supervise others
*wave 1 respondent
gen r`wv'jsprvs = .
missing_lasi we110 we016_mainjob r`wv'worka, result(r`wv'jsprvs) wave(`wv')
replace r`wv'jsprvs = .w if r`wv'worka==0
replace r`wv'jsprvs = .n if inlist(we016_mainjob,1,2,3,4,6)
replace r`wv'jsprvs = 0 if we110==0
replace r`wv'jsprvs = 1 if inrange(we110,1,5000)
label variable r`wv'jsprvs "r`wv'jsprvs:w`wv' whether r supervises others"
label values r`wv'jsprvs lbfyesno

*wave 1 spouse
gen s`wv'jsprvs = .
spouse r`wv'jsprvs, result(s`wv'jsprvs) wave(`wv')
label variable s`wv'jsprvs "s`wv'jsprvs:w`wv' whether s supervises others"
label values s`wv'jsprvs lbfyesno

**************************************************
***Years of Tenure on Current Main Job***
*wave 1 respondent years of tenure on current main job
gen r`wv'jcten = .
missing_lasi we024_month we024_year dm005 r`wv'worka, result(r`wv'jcten) wave(`wv')
replace r`wv'jcten = .w if r`wv'worka == 0
replace r`wv'jcten = we024_month/12 if inrange(we024_month,0,600)
replace r`wv'jcten = we024_year if inrange(we024_year,0,100) & (we024_year < dm005) & inrange(dm005,18,116)
replace r`wv'jcten = .i if (we024_year >= dm005 & !mi(we024_year) & !mi(dm005)) | ((we024_month/12) >= dm005 & !mi(we024_month) & !mi(dm005))
label variable r`wv'jcten "r`wv'jcten:w`wv' r current job tenure"

*wave 1 spouse years of tenure on current main job
gen s`wv'jcten = .
spouse r`wv'jcten, result(s`wv'jcten) wave(`wv')
label variable s`wv'jcten "s`wv'jcten:w`wv' s current job tenure"


**************************************************
***Occupation Code for Current Main Job***
*wave 1 respondent occupation code for current main job
gen r`wv'jcocc_l = .
missing_lasi we027_main r`wv'worka, result(r`wv'jcocc_l) wave(`wv')
replace r`wv'jcocc_l = .w if r`wv'worka == 0
replace r`wv'jcocc_l = we027_main if inrange(we027_main,1,11)
label variable r`wv'jcocc_l "r`wv'jcocc_l:w`wv' r current job occupation"
label values r`wv'jcocc_l occup

*wave 1 spouse occupation code for current main job
gen s`wv'jcocc_l = .
spouse r`wv'jcocc_l, result(s`wv'jcocc_l) wave(`wv')
label variable s`wv'jcocc_l "s`wv'jcocc_l:w`wv' s current job occupation"
label values s`wv'jcocc_l occup

**************************************************
***Industry Code for Current Main Job***
*wave 1 respondent industry code for current main job
gen r`wv'jcind_l = .
missing_lasi we023 r`wv'worka, result(r`wv'jcind_l) wave(`wv')
replace r`wv'jcind_l = .w if r`wv'worka == 0
replace r`wv'jcind_l = we023 if inrange(we023,1,22)
label variable r`wv'jcind_l "r`wv'jcind_l:w`wv' r current job industry"
label values r`wv'jcind_l industry

*wave 1 spouse industry code for current main job
gen s`wv'jcind_l = .
spouse r`wv'jcind_l, result(s`wv'jcind_l) wave(`wv')
label variable s`wv'jcind_l "s`wv'jcind_l:w`wv' s current job industry"
label values s`wv'jcind_l industry


**************************************************
***Firm Size for Current Main Job***
* impute firm size if interval range given = mean of interval range (e.g. less than 6 = 3, 6 to 10 = 8, 10 to 20 = 15, 20 or more = 20)
gen firm_size_empl = .
replace firm_size_empl = 3 if we103 == 1
replace firm_size_empl = 8 if we103 == 2
replace firm_size_empl = 15 if we103 == 3
replace firm_size_empl = 20 if we103 == 4
replace firm_size_empl = . if we103 == 5
*mean of interval range +1 for self-employed
gen firm_size_own = .
replace firm_size_own = 4 if we114a == 1
replace firm_size_own = 9 if we114a == 2
replace firm_size_own = 16 if we114a == 3
replace firm_size_own = 21 if we114a == 4
replace firm_size_own = . if we114a == 5

*wave 1 respondent size of firm or business for current main job
gen r`wv'fsize = .
missing_lasi we016_mainjob we102 we103 we114 we114a r`wv'worka, result(r`wv'fsize) wave(`wv')
replace r`wv'fsize = .w if r`wv'worka == 0
replace r`wv'fsize = .s if inlist(we016_mainjob,2,4,6)
replace r`wv'fsize = we102 if we016_mainjob == 5 & inrange(we102,1,2000)
replace r`wv'fsize = 1 if we016_mainjob == 5 & we102 == 0
replace r`wv'fsize = firm_size_empl if we016_mainjob == 5 & mi(r`wv'fsize) & firm_size_empl != .
replace r`wv'fsize = we114 + 1 if (we016_mainjob == 1 | we016_mainjob == 3) & inrange(we114,0,250)
replace r`wv'fsize = firm_size_own if (we016_mainjob == 1 | we016_mainjob == 3) & mi(r`wv'fsize) & firm_size_own != .
label variable r`wv'fsize "r`wv'fsize:w`wv' r size of firm or business"

*wave 1 spouse size of firm or business for current main job
gen s`wv'fsize = .
spouse r`wv'fsize, result(s`wv'fsize) wave(`wv')
label variable s`wv'fsize "s`wv'fsize:w`wv' s size of firm or business"

*wave 1 respondent size of firm or business for current main job imputed or not
gen r`wv'ffsize = .
missing_lasi r`wv'fsize, result(r`wv'ffsize) wave(`wv')
replace r`wv'ffsize = .w if r`wv'worka==0
replace r`wv'ffsize = .s if inlist(we016_mainjob,2,4,6)
replace r`wv'ffsize = 0 if (mi(firm_size_empl) & mi(firm_size_own)) & !mi(r`wv'fsize)
replace r`wv'ffsize = 1 if !mi(firm_size_empl) | !mi(firm_size_own)
label variable r`wv'ffsize "r`wv'ffsize:w`wv' r size of firm or business based on interval"
label values r`wv'ffsize empyesno

*wave 1 spouse size of firm or business for current main job imputed or not
gen s`wv'ffsize = .
spouse r`wv'ffsize, result(s`wv'ffsize) wave(`wv')
label variable s`wv'ffsize "s`wv'ffsize:w`wv' s size of firm or business based on interval"
label values s`wv'ffsize empyesno

drop firm_size_empl firm_size_own


**************************************************
***Year and month last job ended***
*wave 1 respondent year last worked/not working
gen r`wv'jlasty = .
missing_lasi we001 we004 we301, result(r`wv'jlasty) wave(`wv')
replace r`wv'jlasty = .n if we001 == 2
replace r`wv'jlasty = .w if we004 == 1
replace r`wv'jlasty = .i if we301 <= rabyear & !mi(we301) & !mi(rabyear)
replace r`wv'jlasty = we301 if inrange(we301,1900,2021) & we301 > rabyear & !mi(rabyear)
label variable r`wv'jlasty "r`wv'jlasty:w`wv' r year last worked"

*wave 1 respondent month last worked/not working
gen r`wv'jlastm = .
missing_lasi we001 we004 we302, result(r`wv'jlastm) wave(`wv')
replace r`wv'jlastm = .n if we001 == 2
replace r`wv'jlastm = .w if we004 == 1
replace r`wv'jlastm = we302 if inrange(we302,1,12)
label variable r`wv'jlastm "r`wv'jlastm:w`wv' r month last worked"

*wave 1 spouse year last worked/not working
gen s`wv'jlasty = .
spouse r`wv'jlasty, result(s`wv'jlasty) wave(`wv')
label variable s`wv'jlasty "s`wv'jlasty:w`wv' s year last worked"

*wave 1 spouse month last worked/not working
gen s`wv'jlastm = .
spouse r`wv'jlastm, result(s`wv'jlastm) wave(`wv')
label variable s`wv'jlastm "s`wv'jlastm:w`wv' s month last worked"


**************************************************
***Job search variables 
*wave 1 respondent currently looking for a new job (working)
gen r`wv'looknwk=.
missing_lasi we001 we004 we005 we201, result(r`wv'looknwk) wave(`wv')
replace r`wv'looknwk=.n if we001==2 
replace r`wv'looknwk=.w if we004==2 & inlist(we005,2,3,4,5)
replace r`wv'looknwk=0 if we201==2 & (we004==1 | we005==1)
replace r`wv'looknwk=1 if we201==1 & (we004==1 | we005==1)
label variable r`wv'looknwk "r`wv'looknwk:w`wv' r looking for a new job (if working)"
label values r`wv'looknwk empyesno 

*wave 1 spouse
gen s`wv'looknwk=.
spouse r`wv'looknwk, result(s`wv'looknwk) wave(`wv')
label variable s`wv'looknwk "s`wv'looknwk:w`wv' s looking for a new job (if working)"
label values s`wv'looknwk empyesno 


*wave 1 respondent looking for part-time or full-time job (asked to those currently looking for new job)
*we201-we208 only asked if we001==1; we204 asked only if we201==1
gen r`wv'looknwkpf=.
missing_lasi we001 we004 we005 we201 we205, result(r`wv'looknwkpf) wave(`wv') 
replace r`wv'looknwkpf=.n if we001==2 
replace r`wv'looknwkpf=.w if we004==2 & inlist(we005,2,3,4,5)
replace r`wv'looknwkpf=.l if we201==2 & (we004==1 | we005==1)
replace r`wv'looknwkpf=we205 if inrange(we205,1,3) & we201==1 & (we004==1 | we005==1)
label variable r`wv'looknwkpf "r`wv'looknwkpf:w`wv' r looking for new part-time or full-time job (if working)"
label values r`wv'looknwkpf pftime

*wave 1 spouse
gen s`wv'looknwkpf=.
spouse r`wv'looknwkpf, result(s`wv'looknwkpf) wave(`wv')
label variable s`wv'looknwkpf "s`wv'looknwkpf:w`wv' s looking for new part-time or full-time job (if working)"
label values s`wv'looknwkpf pftime


*wave 1 respondent looking for same or different work
gen r`wv'looknwksd=.
missing_lasi we001 we004 we005 we201 we206, result(r`wv'looknwksd) wave(`wv') 
replace r`wv'looknwksd=.n if we001==2 
replace r`wv'looknwksd=.w if we004==2 & inlist(we005,2,3,4,5)
replace r`wv'looknwksd=.l if we201==2 & (we004==1 | we005==1)
replace r`wv'looknwksd=we206 if inrange(we206,1,3) & we201==1 & (we004==1 | we005==1)
label variable r`wv'looknwksd "r`wv'looknwksd:w`wv' r looking for same or different work (if working)"
label values r`wv'looknwksd worksd

*wave 1 spouse
gen s`wv'looknwksd=.
spouse r`wv'looknwksd, result(s`wv'looknwksd) wave(`wv')
label variable s`wv'looknwksd "s`wv'looknwksd:w`wv' s looking for same or different work (if working)"
label values s`wv'looknwksd worksd 


*wave 1 respondent looking for jobs in area or move
gen r`wv'looknarea=.
missing_lasi we001 we004 we005 we201 we204s1 we204s2 we204s3, result(r`wv'looknarea) wave(`wv')
replace r`wv'looknarea=.n if we001==2 //has not ever worked in last 3 months
replace r`wv'looknarea=.w if we004==2 & inlist(we005,2,3,4,5)
replace r`wv'looknarea=.l if we201==2 & (we004==1 | we005==1)
replace r`wv'looknarea=1 if we204s1==1 & we201==1 & (we004==1 | we005==1)
replace r`wv'looknarea=2 if we204s2==1 & we201==1 & (we004==1 | we005==1)
replace r`wv'looknarea=3 if we204s3==1 & we201==1 & (we004==1 | we005==1)
label variable r`wv'looknarea "r`wv'looknarea:w`wv' r looking for job in area or move (if working)"
label values r`wv'looknarea workarea  

*wave 1 spouse 
gen s`wv'looknarea=.
spouse r`wv'looknarea, result(s`wv'looknarea) wave(`wv')
label variable s`wv'looknarea "s`wv'looknarea:w`wv' s looking for job in area or move (if working)"
label values s`wv'looknarea workarea 

***Job search variables 
*wave 1 respondent looking for part-time or full-time job (if not working)
*we201-we208 only asked if we001==1; we204 asked only if we201==1
gen r`wv'lookwrkpf=.
missing_lasi we001 we004 we005 we201 we205, result(r`wv'lookwrkpf) wave(`wv') 
replace r`wv'lookwrkpf=.n if we001==2 
replace r`wv'lookwrkpf=.w if we004==1 | we005==1 
replace r`wv'lookwrkpf=.l if we201==2 & we004==2 & inlist(we005,2,3,4,5)
replace r`wv'lookwrkpf=we205 if inrange(we205,1,3) & we201==1 & we004==2 & inlist(we005,2,3,4,5)
label variable r`wv'lookwrkpf "r`wv'lookwrkpf:w`wv' r looking for part-time or full-time job (if not working)"
label values r`wv'lookwrkpf unpftime

*wave 1 spouse
gen s`wv'lookwrkpf=.
spouse r`wv'lookwrkpf, result(s`wv'lookwrkpf) wave(`wv')
label variable s`wv'lookwrkpf "s`wv'lookwrkpf:w`wv' s looking for part-time or full-time job (if not working)"
label values s`wv'lookwrkpf unpftime


*wave 1 respondent looking for same or different work (if not working)
gen r`wv'lookwrksd=.
missing_lasi we001 we201 we206, result(r`wv'lookwrksd) wave(`wv') 
replace r`wv'lookwrksd=.n if we001==2 
replace r`wv'lookwrksd=.w if we004==1 | we005==1
replace r`wv'lookwrksd=.l if we201==2 & we004==2 & inlist(we005,2,3,4,5)
replace r`wv'lookwrksd=we206 if inrange(we206,1,3) & we201==1 & we004==2 & inlist(we005,2,3,4,5)
label variable r`wv'lookwrksd "r`wv'lookwrksd:w`wv' r looking for same or different work (if not working)"
label values r`wv'lookwrksd unworksd

*wave 1 spouse
gen s`wv'lookwrksd=.
spouse r`wv'lookwrksd, result(s`wv'lookwrksd) wave(`wv')
label variable s`wv'lookwrksd "s`wv'lookwrksd:w`wv' s looking for same or different work (if not working)"
label values s`wv'lookwrksd unworksd 


*wave 1 respondent looking for jobs in area or move (if not working)
gen r`wv'lookarea=.
missing_lasi we001 we201 we204s1 we204s2 we204s3, result(r`wv'lookarea) wave(`wv')
replace r`wv'lookarea=.n if we001==2 
replace r`wv'lookarea=.w if we004==1 | we005==1
replace r`wv'lookarea=.l if we201==2 & we004==2 & inlist(we005,2,3,4,5)
replace r`wv'lookarea=1 if we204s1==1 & we201==1 & we004==2 & inlist(we005,2,3,4,5)
replace r`wv'lookarea=2 if we204s2==1 & we201==1 & we004==2 & inlist(we005,2,3,4,5)
replace r`wv'lookarea=3 if we204s3==1 & we201==1  & we004==2 & inlist(we005,2,3,4,5)
label variable r`wv'lookarea "r`wv'lookarea:w`wv' r looking for job in area or move (if not working)"
label values r`wv'lookarea unworkarea  

*wave 1 spouse 
gen s`wv'lookarea=.
spouse r`wv'lookarea, result(s`wv'lookarea) wave(`wv')
label variable s`wv'lookarea "s`wv'lookarea:w`wv' s looking for job in area or move (if not working)"
label values s`wv'lookarea unworkarea 

************************************************** 


***drop LASI wave 1 file raw variables***
drop `employ_w1_ind'

***drop LASI Wave Wave 1 WE impuations file raw variables***
drop `employ_w1_wei'

label define yesnox ///
	0 "0.No" ///
	1 "1.Yes" ///
	.e ".e " ///
	.x ".x:No Condition-Skipped" ///
	.m ".m:Missing" ///
	.d ".d:Don't Know" ///
	.r ".r:Refuse" ///
	.s ".s:Skipped" ///
	.n ".n:never worked"


*set wave number
local wv=1

***merge with main file***
local ret_w1_ind we001 dm004_year we004 we005 we301 we302 we303 we315 /// 
         we401_age we401_years we401_keepworking* ///
		 we402 we402_a we403 we404 we405 we406 we407 we408 we409 we410* 
		   
merge 1:1 prim_key using "$wave_1_ind_bm", keepusing(`ret_w1_ind') nogen

*********************************************************************
***Whether considers self retired***
*********************************************************************

***Whether considers self retired 
gen r`wv'sayret_l=.
missing_lasi we001 we402 we315,result(r`wv'sayret_l) wave(`wv')
replace r`wv'sayret_l=0 if we001==2 //never worked
replace r`wv'sayret_l=0 if we001 ==1 
replace r`wv'sayret_l=1 if we315==11 | we402==1 
label variable r`wv'sayret_l "r`wv'sayret_l:w`wv' whether r considers self retired"
label values r`wv'sayret_l yesnox

*spouse  
gen s`wv'sayret_l=.
spouse r`wv'sayret_l, result(s`wv'sayret_l) wave(`wv')
label variable s`wv'sayret_l "s`wv'sayret_l:w`wv' whether s considers self retired"
label values s`wv'sayret_l yesnox

*********************************************************************
***Whether officially retired from organized sector of employment***
*********************************************************************

***Whether officially retired from organized sector of employment 
gen r`wv'fret_l=.
missing_lasi we001 we402,result(r`wv'fret_l) wave(`wv')
replace r`wv'fret_l=0 if we001==2 //never worked
replace r`wv'fret_l=0 if we402==2 
replace r`wv'fret_l=1 if we402==1 
label variable r`wv'fret_l "r`wv'fret_l:w`wv' whether r retired from organized sector"
label values r`wv'fret_l yesnox

*spouse
gen s`wv'fret_l=.
spouse r`wv'fret_l, result(s`wv'fret_l) wave(`wv')
label variable s`wv'fret_l "s`wv'fret_l:w`wv' whether s retired from organized sector"
label values s`wv'fret_l yesnox


*********************************************************************
***Month and Year Retired***
*********************************************************************

***Month Retired 
gen r`wv'retmon=.
missing_lasi we001 we402 we403 we405 we315 we302,result(r`wv'retmon) wave(`wv')
replace r`wv'retmon = .n if r`wv'sayret_l==0
replace r`wv'retmon=we405 if we403==2 & inrange(we405,1,12)
replace r`wv'retmon= we302 if we315==11 & !mi(we302) & mi(r`wv'retmon)
label variable r`wv'retmon "r`wv'retmon:w`wv' month r retired, if formally retired"

*spouse
gen s`wv'retmon=.
spouse r`wv'retmon, result(s`wv'retmon) wave(`wv')
label variable s`wv'retmon "s`wv'retmon:w`wv' month s retired, if formally retired"

***Year Retired 
gen r`wv'retyr=.
missing_lasi we001 we402 we403 we404 we315 we302,result(r`wv'retyr) wave(`wv')
replace r`wv'retyr = .n if r`wv'sayret_l==0
replace r`wv'retyr=we404 if we403==2 & inrange(we404,1900,2020)
replace r`wv'retyr= we301 if we315==11 & !mi(we301) & mi(r`wv'retyr)
replace r`wv'retyr=.i if we404 < rabyear & inrange(we404,1900,2020) & inrange(rabyear,1900,2017)
label variable r`wv'retyr "r`wv'retyr:w`wv' year r retired, if formally retired"

*spouse
gen s`wv'retyr=.
spouse r`wv'retyr, result(s`wv'retyr) wave(`wv')
label variable s`wv'retyr "s`wv'retyr:w`wv' year s retired, if formally retired"


***Year Planned to Stop work 
destring (we401_keepworkings1), replace

gen r`wv'rplnya=.
missing_lasi we001 we004 we005 we401_age we401_years we401_keepworkings1 ,result(r`wv'rplnya) wave(`wv')
replace r`wv'rplnya=.m if (we401_age==.e | we401_years==.e | we401_keepworkings1==.e )
replace r`wv'rplnya=.w if we001==2  // never worked
replace r`wv'rplnya=.w if (we004!=1 | we005!=1) & !inlist(r`wv'rplnya,.d,.r,.w) & !mi(we001) //not working
replace r`wv'rplnya=.w if r`wv'sayret_l==1 //already retired
replace r`wv'rplnya=.n if we401_keepworkings1==1  //plans to keep working 
replace r`wv'rplnya= we401_age + rabyear if inrange(we401_age,1,101) 
replace r`wv'rplnya=(we401_years + r`wv'iwy) if inrange(we401_years,1,90) 
replace r`wv'rplnya=r`wv'iwy if we401_age==0 | we401_years==0
replace r`wv'rplnya=.i if we401_age<r`wv'agey | (r`wv'rplnya < r`wv'iwy & inrange(r`wv'rplnya,1900,2110))
label variable r`wv'rplnya "r`wv'rplnya:w`wv' year r plans to stop working"

*spouse 
gen s`wv'rplnya=.
spouse r`wv'rplnya, result(s`wv'rplnya) wave(`wv')
label variable s`wv'rplnya "s`wv'rplnya:w`wv' year s plans to stop working"


*************************************************
***drop wave 1 file raw variables
drop `ret_w1_ind'

   
***Pension income flag
label define penflag ///
   -1 "-1.not imputed, missing neighbors" ///
   -2 "-2.not imputed, missing covariates" ///
   1 "1.continuous value" ///
   2 "2.complete bracket" ///
   3 "3.incomplete bracket" ///
   5 "5.no value/bracket" ///
   6 "6.no receipt" ///
   7 "7.dk receipt" ///
   8 "8.module not answered" ///
   .m ".m:Missing" /// 
   .n ".n:No pension" ///
   .x ".x:never worked/not working"
   
***Pension yes no
label define yesnopen /// 
	 0 "0.No" /// 
	 1 "1.Yes" /// 
	 .d ".d:DK" /// 
	 .m ".m:Missing" /// 
	 .r ".r:Refuse" /// 
	 .u ".u:Unmar" /// 
	 .v ".v:SP NR" /// 
	 .w ".w:Not working" 
	    


*set wave number
local wv=1

***merge with demog file***
local pen_w1_ind sw201a sw201b sw202a sw202b sw202c sw202d sw202e ///
     we001 we004 we005 we316a we316b we402 ///
     we412 we412as? ///
     we420 

merge 1:1 prim_key using "$wave_1_ind_bm", keepusing(`pen_w1_ind') nogen

***merge with wave 1 we impuations files
local pen_w1_wei we413a_i we413a_i_f ///
     we413b_i we413b_i_f ///
     we413c_i we413c_i_f ///
     we413d_i we413d_i_f ///
     we413e_i we413e_i_f ///
     we413f_i we413f_i_f ///
		
merge 1:1 prim_key using  "$wave_1_we_imput", keepusing(`pen_w1_wei') nogen

*****************************************************
***Whether Receives Public Pensions***
*wave 1 respondent whether receives public pensions
***SW and WE sections
gen r`wv'pubpen = .
missing_lasi we001 we004 we402 we412 we412as1 we412as2 sw202?, result(r`wv'pubpen) wave(`wv')
replace r`wv'pubpen = 0 if r`wv'agey < 60 | (r`wv'agey >= 60 & (sw202a == 2 | sw202b == 2 | sw202c == 2 | sw202d == 2 | sw202e == 2)) 
replace r`wv'pubpen = 0 if we004 == 2 | we001 == 2 | (we001 == 1 & we402 == 2) | inlist(we412,2,3)
replace r`wv'pubpen = 0 if we001 == 1 & we402==1 & we412as1 == 0 & we412as2 == 0
replace r`wv'pubpen = 1 if (r`wv'agey >= 60 & (sw202a == 1 | sw202b == 1 | sw202c == 1 | sw202d == 1 | sw202e == 1)) | ///
														(we001 ==1 & we402 == 1 & (we412as1 == 1 | we412as2 == 1))
label variable r`wv'pubpen "r`wv'pubpen:w`wv' r receives public pension"
label values r`wv'pubpen yesnopen

**wave 1 spouse whether receives public pensions
gen s`wv'pubpen = .
spouse r`wv'pubpen, result(s`wv'pubpen) wave(`wv')
label variable s`wv'pubpen "s`wv'pubpen:w`wv' s receives public pension"
label values s`wv'pubpen yesnopen

*****************************************************
***Currently Receiving Private/Occupational Pension***
*wave 1 respondent currently receiving private/occupational pension income
gen r`wv'peninc = .
missing_lasi we001 we402 we412 we412as3 we412as4 we412as5 we412as6, result(r`wv'peninc) wave(`wv')
replace r`wv'peninc = 0 if we001 == 2 | (we001 == 1 & we402 == 2) | inlist(we412,2,3)
replace r`wv'peninc = 0 if we001 == 1 & we402==1 & we412as3 == 0 & we412as4 == 0 & we412as5 == 0 & we412as6 == 0
replace r`wv'peninc = 1 if we001 == 1 & we402 == 1 & we412==1 & (we412as3 == 1 | we412as4 == 1 | we412as5 == 1 | we412as6 == 1)
label variable r`wv'peninc "r`wv'peninc:w`wv' r receives private/occupational pension"
label values r`wv'peninc yesnopen

**wave 1 spouse current receiving private/occupational pension income
gen s`wv'peninc = .
spouse r`wv'peninc, result(s`wv'peninc) wave(`wv')
label variable s`wv'peninc "s`wv'peninc:w`wv' s receives private/occupational pension"
label values s`wv'peninc yesnopen

*****************************************************
***Has any pension from current job***
*wave 1 respondent has any pension from current job
gen r`wv'jcpen = .
missing_lasi we001 we004 we316a we402, result(r`wv'jcpen) wave(`wv')
replace r`wv'jcpen = .w if we001 == 2 | (we001 == 1 & we004 == 2) | we402 == 1
replace r`wv'jcpen = 0 if (we316a == 2 | we316b == 2) & we402 == 2
replace r`wv'jcpen = 1 if (we316a == 1 | we316b == 1) & we004 == 1 & we402 == 2
label variable r`wv'jcpen "r`wv'jcpen:w`wv' r any pension from current job"
label values r`wv'jcpen yesnopen

**wave 1 spouse whether current job provides pension
gen s`wv'jcpen = .
spouse r`wv'jcpen, result(s`wv'jcpen) wave(`wv')
label variable s`wv'jcpen "s`wv'jcpen:w`wv' s any pension from current job"
label values s`wv'jcpen yesnopen

*****************************************************
***public pension income per month
gen r`wv'pubpeni = .
replace r`wv'pubpeni = .m if inw`wv' == 1
replace r`wv'pubpeni = .x if we001==2 | we402==2 //never worked or not currently working
replace r`wv'pubpeni = .n if inlist(we412,2,3)
replace r`wv'pubpeni = we413a_i + we413b_i if we412 == 1
label variable r`wv'pubpeni "r`wv'pubpeni:w`wv' r public pension inc received monthly"

**wave 1 spouse
gen s`wv'pubpeni = .
spouse r`wv'pubpeni, result(s`wv'pubpeni) wave(`wv')
label variable s`wv'pubpeni "s`wv'pubpeni:w`wv' s public pension inc received monthly"

gen r`wv'fpubpeni = .
replace r`wv'fpubpeni = .m if inw`wv' == 1
replace r`wv'fpubpeni = .x if we001==2 | we402==2 //never worked or not currently working
replace r`wv'fpubpeni = .n if inlist(we412,2,3)
combine_h_inc_flag we413a_i_f we413b_i_f if we412 == 1, result(r`wv'fpubpeni)
label variable r`wv'fpubpeni "r`wv'fpubpeni:w`wv' impflag r public pension inc received monthly"
label values r`wv'fpubpeni penflag

**wave 1 spouse
gen s`wv'fpubpeni = .
spouse r`wv'fpubpeni, result(s`wv'fpubpeni) wave(`wv')
label variable s`wv'fpubpeni "s`wv'fpubpeni:w`wv' impflag s public pension inc received monthly"
label values s`wv'fpubpeni penflag 

*****************************************************
***private pension income per month
gen r`wv'penai = .
replace r`wv'penai = .m if inw`wv' == 1
replace r`wv'penai = .x if we001==2 | we402==2 //never worked or not currently working
replace r`wv'penai = .n if inlist(we412,2,3)
replace r`wv'penai = we413c_i + we413d_i + we413e_i + we413f_i if we412 == 1
replace r`wv'penai = .m if r`wv'penai==. & inw`wv'==1
label variable r`wv'penai "r`wv'penai:w`wv' r private pension inc received monthly"

**wave 1 spouse
gen s`wv'penai = .
spouse r`wv'penai, result(s`wv'penai) wave(`wv')
label variable s`wv'penai "s`wv'penai:w`wv' s private pension inc received monthly"

gen r`wv'fpenai = .
replace r`wv'fpenai = .m if inw`wv' == 1
replace r`wv'fpenai = .x if we001==2 | we402==2 //never worked or not currently working
replace r`wv'fpenai = .n if inlist(we412,2,3)
combine_h_inc_flag we413c_i_f we413d_i_f we413e_i_f we413f_i_f if we412 == 1, result(r`wv'fpenai)
label variable r`wv'fpenai "r`wv'fpenai:w`wv' impflag r private pension inc received monthly"
label values r`wv'fpenai penflag

**wave 1 spouse
gen s`wv'fpenai = .
spouse r`wv'fpenai, result(s`wv'fpenai) wave(`wv')
label variable s`wv'fpenai "s`wv'fpenai:w`wv' impflag s private pension inc received monthly"
label values s`wv'fpenai penflag 

*****************************************************
***total pension income per month
gen r`wv'peni = r`wv'pubpeni + r`wv'penai
replace r`wv'peni = .x if r`wv'pubpeni==.x | r`wv'penai==.x
replace r`wv'peni = .n if r`wv'pubpeni==.n | r`wv'penai==.n
replace r`wv'peni = .m if r`wv'peni==. & inw`wv'==1
label variable r`wv'peni "r`wv'peni:w`wv' r total pension inc received monthly"

**wave 1 spouse
gen s`wv'peni = .
spouse r`wv'peni, result(s`wv'peni) wave(`wv')
label variable s`wv'peni "s`wv'peni:w`wv' s total pension inc received monthly"

gen r`wv'fpeni = .
combine_h_inc_flag r`wv'fpubpeni r`wv'fpenai, result(r`wv'fpeni)
replace r`wv'fpeni = .x if r`wv'fpubpeni==.x | r`wv'fpenai==.x
replace r`wv'fpeni = .n if r`wv'fpubpeni==.n | r`wv'fpenai==.n
replace r`wv'fpeni = .m if r`wv'fpeni==. & inw`wv'==1
label variable r`wv'fpeni "r`wv'fpeni:w`wv' impflag r total pension inc received monthly"
label values r`wv'fpeni penflag 

**wave 1 spouse
gen s`wv'fpeni = .
spouse r`wv'fpeni, result(s`wv'fpeni) wave(`wv')
label variable s`wv'fpeni "s`wv'fpeni:w`wv' impflag s total pension inc received monthly"
label values s`wv'fpeni penflag 

*****************************************************


***drop wave 1 file raw variables***
drop `pen_w1_ind' 

***drop LASI wave 1 WE impuation raw variables
drop `pen_w1_wei'

   
label define post ///
   1 "1.standing" ///
   2 "2.sitting" ///
   3 "3.lying down" ///
   .e ".e:Error" ///
   .m ".m:Missing" ///
   .s ".s:Not in Physical Measure" ///
   .p ".p:Proxy" ///
   .n ".n:Not willing/able" ///
   .d ".d:DK" ///
   .r ".r:Refuse" 

label define right ///
   1 "1.left arm" ///
   2 "2.right arm" ///
   .e ".e:Error" ///
   .s ".s:Not in Physical Measure" ///
   .m ".m:Missing" ///
   .p ".p:Proxy" ///
   .n ".n:Not willing/able" ///
   .d ".d:DK" ///
   .r ".r:Refuse" 
   
label define hand ///
   1 "1.Right hand" ///
   2 "2.Left hand" ///
   3 "3.Both hands equally dominant" ///
   .s ".s:Not in Physical Measure" ///
   .r ".r:Refuse" ///
	 .m ".m:Missing" ///
	 .n ".n:Not willing/able" ///
	 .d ".d:Don't Know" 

label define blnc ///
   1 "1.No semi/no s-b-s" ///
   2 "2.No semi/yes s-b-s" ///
   3 "3.Yes semi/no full" ///
   4 "4.Yes semi/yes full" ///
   .s ".s:Not in Physical Measure" ///
   .r ".r:Refuse" ///
	 .m ".m:Missing" ///
	 .n ".n:Not willing/able" ///
	 .x ".x:Tried but was unable"	///
	 .d ".d:Don't Know"
	 
label define compli ///
	1 "1.fully compliant" ///
	2 "2.prevented from being fully compliant" ///
	3 "3.not fully compliant" ///
	.s ".s:not in physical measure" ///
	.n ".n:Not willing/able" ///
	.d ".d:DK" ///
	.m ".m:Missing" ///
	.r ".r:Refuse"
	
label define effort ///
	1 "1.full effort" ///
	2 "2.prevented from giving full effort" ///
	3 "3.did not appear to give full effort" ///
	.s ".s:not in physical measure" ///
	.n ".n:Not willing/able" 
	
label define floor ///
	1 "1.wood/tile/linoleum" ///
	2 "2.concrete" /// 
	3 "3.kutchha/mud" ///
	.s ".s:not in physical measure" ///
	.n ".n:Not willing/able"

label define yesnon ///
	0 "0.no" ///
	1 "1.yes" /// 
	.s ".s:Not in physical measure" ///
	.n ".n:Not willing/able" ///
	.m ".m:Missing" ///
	.r ".r:Refuse" ///
	.d ".d:DK" ///
	.t ".t:not tested"
	
label define aids ///
	1 "1.none" ///
	2 "2.walking stick or cane" ///
	3 "3.elbow crutches" ///
	4 "4.walking frame" ///
	5 "5.other" ///
	.s ".s:Not in physical measure" ///
	.n ".n:Not willing/able" ///
	.m ".m:Missing" ///
	.r ".r:Refuse" ///
	.d ".d:DK" 

label define bmicate2 ///
	1 "1.underweight (less than 18.4)" ///
	2 "2.normal weight (18.5-24.9)" ///
	3 "3.overweight (25.0-29.9)" ///
	4 "4.obesity class 1 (30-34.9)" ///
	5 "5.obesity class 2 (35-39.9)" ///
	6 "6.obesity class 3 (>=40)" ///
	.m ".m:Missing" ///
	.d ".d:DK" ///
	.r ".r:Refuse" ///
	.s ".s:Not in physical measure" ///
	.n ".n:Not willing/able" ///
	.i ".i:invalid"
	
label define visiond ///
	1 "1.20/20" ///
	2 "2.20/25" ///
	3 "3.20/32" ///
	4 "4.20/40" ///
	5 "5.20/50" ///
	6 "6.20/63" ///
	7 "7.20/80" ///
	8 "8.20/100" ///
	9 "9.20/125" ///
	10 "10.20/160" ///
	11 "11.20/200" ///
	12 "12.20/250" ///
	13 "13.20/320" ///
	14 "14.blind" ///
	.s ".s:Not in physical measure" 
	
label define visionn ///
	1 "1.20/20" ///
	2 "2.20/25" ///
	3 "3.20/32" ///
	4 "4.20/40" ///
	5 "5.20/50" ///
	6 "6.20/63" ///
	7 "7.20/80" ///
	8 "8.20/100" ///
	9 "9.20/125" ///
	10 "10.20/160" ///
	11 "11.20/250" ///
	12 "12.20/320" ///
	13 "13.20/400" ///
	14 "14.blind" ///
	.s ".s:Not in physical measure" 
	
label define visioncat ///
	1 "1.no VI" ///
	2 "2.mild VI" ///
	3 "3.moderate VI" ///
	4 "4.severe VI/blind" ///
	.s ".s:Not in physical measure"
	 


*set wave number
local wv=1

***merge with wave 1 data***
local phys_w1_ind bm001 bm002 bm003 bm004 bm006 bm007 bm008 bm010 bm011 bm012 bm014 ///
                  bm015 bm016 bm017 bm018 bm019 bm020 bm021 bm022 bm024 bm025 bm026 bm028 bm029 ///
                  bm030 bm031 bm032 bm033 bm034 bm036 bm037 bm038 bm039 bm040 bm041 bm042 bm043 bm044 bm045 bm046 bm048 bm049_iwer ///
                  bm050 bm051_iwer bm052 bm053_iwer bm054 bm055 bm056 bm057 bm058 bm059 bm060a bm060b bm061 bm062 bm063 bm064 ///
                  bm065 bm066 bm067 bm068 bm069 bm071 bm072 bm073 bm074 bm076 bm077 bm079 ///
                  bm080s1 bm080s2 bm080s3 bm080s4 bm080s5 bm080s6 bm080s7 
merge 1:1 prim_key using "$wave_1_ind_bm", keepusing(`phys_w1_ind') nogen

*********************************************************************
***Blood Pressure Measurements***
*********************************************************************

***Blood pressure-systolic 1
gen r`wv'systo1 = .
missing_lasi bm006, result(r`wv'systo1) wave(`wv')
replace r`wv'systo1 = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'systo1 = .n if bm001 == 2 | (bm003 == 1 & bm004 == 1)
replace r`wv'systo1 = .r if bm006 == .r 
replace r`wv'systo1 = bm006 if inrange(bm006,60,250)
label variable r`wv'systo1 "r`wv'systo1:w`wv' r blood pressure measure (systolic) 1"
*spouse
gen s`wv'systo1 =.
spouse r`wv'systo1, result(s`wv'systo1) wave(`wv')
label variable s`wv'systo1 "s`wv'systo1:w`wv' s blood pressure measure (systolic) 1"

***Blood pressure-systolic 2
gen r`wv'systo2 = .
missing_lasi bm010, result(r`wv'systo2) wave(`wv')
replace r`wv'systo2 = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'systo2 = .n if bm001 == 2 | (bm003 == 1 & bm004 == 1)
replace r`wv'systo2 = .r if bm010==.r 
replace r`wv'systo2 = bm010  if inrange(bm010,60,250)
label variable r`wv'systo2 "r`wv'systo2:w`wv' r blood pressure measure (systolic) 2"
*spouse
gen s`wv'systo2 =.
spouse r`wv'systo2, result(s`wv'systo2) wave(`wv')
label variable s`wv'systo2 "s`wv'systo2:w`wv' s blood pressure measure (systolic) 2"

***Blood pressure-systolic 3
gen r`wv'systo3 = .
missing_lasi bm014, result(r`wv'systo3) wave(`wv')
replace r`wv'systo3 = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'systo3 = .n if bm001 == 2 | (bm003 == 1 & bm004 == 1)
replace r`wv'systo3 = .r if bm014==.r
replace r`wv'systo3 = bm014 if inrange(bm014,60,250)
label variable r`wv'systo3 "r`wv'systo3:w`wv' r blood pressure measure (systolic) 3"
*spouse
gen s`wv'systo3 =.
spouse r`wv'systo3, result(s`wv'systo3) wave(`wv')
label variable s`wv'systo3 "s`wv'systo3:w`wv' s blood pressure measure (systolic) 3"

***Average blood pressure-systolic
gen r`wv'systo = .
missing_lasi bm017, result(r`wv'systo) wave(`wv')
replace r`wv'systo = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'systo = .n if bm001 == 2 | (bm003 == 1 & bm004 == 1)
replace r`wv'systo = .r if bm017==.r 
replace r`wv'systo = bm017 if inrange(bm017,60,250) 
label variable r`wv'systo "r`wv'systo:w`wv' r average blood pressure measure (systolic) 2 & 3"
*spouse
gen s`wv'systo =.
spouse r`wv'systo, result(s`wv'systo) wave(`wv')
label variable s`wv'systo "s`wv'systo:w`wv' s average blood pressure measure (systolic) 2 & 3"

***Blood pressure-diastolic 1
gen r`wv'diasto1 = .
missing_lasi bm007, result(r`wv'diasto1) wave(`wv')
replace r`wv'diasto1 = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'diasto1 = .n if bm001 == 2 | (bm003 == 1 & bm004 == 1)
replace r`wv'diasto1 = .r if bm007== .r 
replace r`wv'diasto1 = bm007 if inrange(bm007,40,180) 
label variable r`wv'diasto1 "r`wv'diasto1:w`wv' r blood pressure measure (diastolic) 1"
*spouse
gen s`wv'diasto1 =.
spouse r`wv'diasto1, result(s`wv'diasto1) wave(`wv')
label variable s`wv'diasto1 "s`wv'diasto1:w`wv' s blood pressure measure (diastolic) 1"

***Blood pressure-diastolic 2
gen r`wv'diasto2 = .
missing_lasi bm011, result(r`wv'diasto2) wave(`wv')
replace r`wv'diasto2 = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'diasto2 = .n if bm001 == 2 | (bm003 == 1 & bm004 == 1)
replace r`wv'diasto2 = .r if bm011==.r  
replace r`wv'diasto2 = bm011  if inrange(bm011,40,180)
label variable r`wv'diasto2 "r`wv'diasto2:w`wv' r blood pressure measure (diastolic) 2"
*spouse
gen s`wv'diasto2 =.
spouse r`wv'diasto2, result(s`wv'diasto2) wave(`wv')
label variable s`wv'diasto2 "s`wv'diasto2:w`wv' s blood pressure measure (diastolic) 2"

***Blood pressure-diastolic 3
gen r`wv'diasto3 = .
missing_lasi bm015, result(r`wv'diasto3) wave(`wv')
replace r`wv'diasto3 = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'diasto3 = .n if bm001 == 2 | (bm003 == 1 & bm004 == 1)
replace r`wv'diasto3 = .r if bm015==.r 
replace r`wv'diasto3 = bm015 if inrange(bm015,40,180)
label variable r`wv'diasto3 "r`wv'diasto3:w`wv' r blood pressure measure (diastolic) 3"
*spouse
gen s`wv'diasto3 =.
spouse r`wv'diasto3, result(s`wv'diasto3) wave(`wv')
label variable s`wv'diasto3 "s`wv'diasto3:w`wv' s blood pressure measure (diastolic) 3"

***Average blood pressure-diastolic
gen r`wv'diasto = .
missing_lasi bm018, result(r`wv'diasto) wave(`wv')
replace r`wv'diasto = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'diasto = .n if bm001 == 2 | (bm003 == 1 & bm004 == 1)
replace r`wv'diasto = .r if bm018 == .r
replace r`wv'diasto = bm018 if inrange(bm018,40,180)
label variable r`wv'diasto "r`wv'diasto:w`wv' r average blood pressure measure (diastolic) 2 & 3 "
*spouse
gen s`wv'diasto =.
spouse r`wv'diasto, result(s`wv'diasto) wave(`wv')
label variable s`wv'diasto "s`wv'diasto:w`wv' s average blood pressure measure (diastolic) 2 & 3 "

***Blood pressure-pulse 1
gen r`wv'pulse1 = .
missing_lasi bm008, result(r`wv'pulse1) wave(`wv')
replace r`wv'pulse1 = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'pulse1 = .n if bm001 == 2 | (bm003 == 1 & bm004 == 1)
replace r`wv'pulse1 = .r if bm008 == .r
replace r`wv'pulse1 = .m if bm008 == .e
replace r`wv'pulse1 = bm008 if inrange(bm008,30,160)
label variable r`wv'pulse1 "r`wv'pulse1:w`wv' r pulse measure 1"
*spouse
gen s`wv'pulse1 =.
spouse r`wv'pulse1, result(s`wv'pulse1) wave(`wv')
label variable s`wv'pulse1 "s`wv'pulse1:w`wv' s pulse measure 1"

***Blood pressure - pulse 2
gen r`wv'pulse2 = .
missing_lasi bm012, result(r`wv'pulse2) wave(`wv')
replace r`wv'pulse2 = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'pulse2 = .n if bm001 == 2 | (bm003 == 1 & bm004 == 1)
replace r`wv'pulse2 = .r if bm012 == .r
replace r`wv'pulse2 = bm012 if inrange(bm012,30,160)
label variable r`wv'pulse2 "r`wv'pulse2:w`wv' r pulse measure 2"
*spouse
gen s`wv'pulse2 =.
spouse r`wv'pulse2, result(s`wv'pulse2) wave(`wv')
label variable s`wv'pulse2 "s`wv'pulse2:w`wv' s pulse measure 2"

***Blood pressure - pulse 3
gen r`wv'pulse3 = .
missing_lasi bm016, result(r`wv'pulse3) wave(`wv')
replace r`wv'pulse3 = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'pulse3 = .n if bm001 == 2 | (bm003 == 1 & bm004 == 1)
replace r`wv'pulse3 = .r if bm016 == .r
replace r`wv'pulse3 = bm016 if inrange(bm016,30,160)
label variable r`wv'pulse3 "r`wv'pulse3:w`wv' r pulse measure 3"
*spouse
gen s`wv'pulse3 =.
spouse r`wv'pulse3, result(s`wv'pulse3) wave(`wv')
label variable s`wv'pulse3 "s`wv'pulse3:w`wv' s pulse measure 3"

***Average blood pressure-pulse
gen r`wv'pulse = .
missing_lasi bm019, result(r`wv'pulse) wave(`wv')
replace r`wv'pulse = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'pulse = .n if bm001 == 2 | (bm003 == 1 & bm004 == 1)
replace r`wv'pulse = .r if bm019==.r
replace r`wv'pulse = bm019  if inrange(bm019,30,160)
label variable r`wv'pulse "r`wv'pulse:w`wv' r average pulse measure 2 & 3"
*spouse
gen s`wv'pulse =.
spouse r`wv'pulse, result(s`wv'pulse) wave(`wv')
label variable s`wv'pulse "s`wv'pulse:w`wv' s average pulse measure 2 & 3"

***Willing to complete bp tests
gen r`wv'bpcomp = .
missing_lasi bm001 bm003 bm004, result(r`wv'bpcomp) wave(`wv')
replace r`wv'bpcomp = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'bpcomp = 0 if bm001==2 | (bm003==1 & bm004==1)
replace r`wv'bpcomp = 1 if bm001==1 & (bm003==2 | bm004==2)
label variable r`wv'bpcomp "r`wv'bpcomp:w`wv' r willing and able to complete bp tests"
label values r`wv'bpcomp yesnon
*spouse
gen s`wv'bpcomp = .
spouse r`wv'bpcomp, result(s`wv'bpcomp) wave(`wv')
label variable s`wv'bpcomp "s`wv'bpcomp:w`wv' s willing and able to complete bp tests"
label values s`wv'bpcomp yesnon

***Blood pressure position
gen r`wv'bldpos = .
missing_lasi bm021, result(r`wv'bldpos) wave(`wv')
replace r`wv'bldpos = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'bldpos = .n if bm001 == 2 | (bm003 == 1 & bm004 == 1)
replace r`wv'bldpos = bm021 if inrange(bm021,1,3)
label variable r`wv'bldpos "r`wv'bldpos:w`wv' r position for blood pressure test"  
label value r`wv'bldpos post
*spouse
gen s`wv'bldpos =.
spouse r`wv'bldpos, result(s`wv'bldpos) wave(`wv')
label variable s`wv'bldpos "s`wv'bldpos:w`wv' s position for blood pressure test"
label value s`wv'bldpos post

***Which arm was used for the measurement
gen r`wv'bparm = . 
missing_lasi bm020, result(r`wv'bparm) wave(`wv')
replace r`wv'bparm = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'bparm = .n if bm001 == 2 | (bm003 == 1 & bm004 == 1)  
replace r`wv'bparm = 1 if bm020 == 1
replace r`wv'bparm = 2 if bm020 == 2
label variable r`wv'bparm "r`wv'bparm:w`wv' r arm used for blood pressure test"  
label value r`wv'bparm right
*spouse
gen s`wv'bparm =.
spouse r`wv'bparm, result(s`wv'bparm) wave(`wv')
label variable s`wv'bparm "s`wv'bparm:w`wv' s arm used for blood pressure test"
label value s`wv'bparm right

***How compliant during bp test
gen r`wv'bpcompl = . 
missing_lasi bm022, result(r`wv'bpcompl) wave(`wv')
replace r`wv'bpcompl = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'bpcompl = .n if bm001 == 2 | (bm003 == 1 & bm004 == 1)   
replace r`wv'bpcompl = bm022 if inrange(bm022,1,3)
label variable r`wv'bpcompl "r`wv'bpcompl:w`wv' r compliance during blood pressure test"  
label value r`wv'bpcompl compli
*spouse
gen s`wv'bpcompl =.
spouse r`wv'bpcompl, result(s`wv'bpcompl) wave(`wv')
label variable s`wv'bpcompl "s`wv'bpcompl:w`wv' s compliance during blood pressure test"
label value s`wv'bpcompl compli

***Activity in Last 30 Minutes that Affects BP
gen r`wv'bpact30=.
missing_lasi bm002, result(r`wv'bpact30) wave(`wv')                                                                                                               
replace r`wv'bpact30=.s if inw`wv'pm==0 & inw`wv'==1
replace r`wv'bpact30=.n if bm001==2
replace r`wv'bpact30=0 if bm002==2
replace r`wv'bpact30=1 if bm002==1
label variable r`wv'bpact30 "r`wv'bpact30:w`wv' r did activity last 30 minutes that affects BP"
label value r`wv'bpact30 yesnon
*spouse
gen s`wv'bpact30=.
spouse r`wv'bpact30, result(s`wv'bpact30) wave(`wv')
label variable s`wv'bpact30 "s`wv'bpact30:w`wv' s did activity last 30 minutes that affects BP"
label value s`wv'bpact30 yesnon


*********************************************************************
***Hand Grip Strength Measurements***
*********************************************************************

***Grip dominant hand
gen r`wv'domhand = .
missing_lasi bm026, result(r`wv'domhand) wave(`wv')
replace r`wv'domhand = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'domhand = .n if bm025 == 1
replace r`wv'domhand = bm026 if inrange(bm026,1,3)
label variable r`wv'domhand "r`wv'domhand:w`wv' r dominant hand (grip strength)"
label value r`wv'domhand hand
*spouse
gen s`wv'domhand =.
spouse r`wv'domhand, result(s`wv'domhand) wave(`wv')
label variable s`wv'domhand "s`wv'domhand:w`wv' s dominant hand (grip strength)"
label value s`wv'domhand hand

***Left Hand 1
gen r`wv'lgrip1 = .
missing_lasi bm028, result(r`wv'lgrip1) wave(`wv')
replace r`wv'lgrip1 = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'lgrip1 = .n if bm025==1
replace r`wv'lgrip1 = .l if bm025==2
replace r`wv'lgrip1 = .d if bm028==.d
replace r`wv'lgrip1 = .r if bm028==.r  
replace r`wv'lgrip1 = bm028 if inrange(bm028,0,70)  
label variable r`wv'lgrip1 "r`wv'lgrip1:w`wv' r left hand grip measurement 1(kg)"
*spouse
gen s`wv'lgrip1 =.
spouse r`wv'lgrip1, result(s`wv'lgrip1) wave(`wv')
label variable s`wv'lgrip1 "s`wv'lgrip1:w`wv' s left hand grip measurement 1(kg)"

***Left Hand 2
gen r`wv'lgrip2 = .
missing_lasi bm030, result(r`wv'lgrip2) wave(`wv')
replace r`wv'lgrip2 = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'lgrip2 = .n if bm025==1
replace r`wv'lgrip2 = .l if bm025==2
replace r`wv'lgrip2 = .d if bm030==.d
replace r`wv'lgrip2 = .r if bm030==.r
replace r`wv'lgrip2 = bm030 if inrange(bm030,0,70)
label variable r`wv'lgrip2 "r`wv'lgrip2:w`wv' r left hand grip measurement 2(kg)"
*spouse
gen s`wv'lgrip2 =.
spouse r`wv'lgrip2, result(s`wv'lgrip2) wave(`wv')
label variable s`wv'lgrip2 "s`wv'lgrip2:w`wv' s left hand grip measurement 2(kg)"

***Left Hand Maximum
egen r`wv'lgrip = rowmax(r`wv'lgrip1 r`wv'lgrip2) if inw`wv' == 1
missing_lasi r`wv'lgrip1 r`wv'lgrip2 if mi(r`wv'lgrip), result(r`wv'lgrip) wave(`wv')
replace r`wv'lgrip = .s if (r`wv'lgrip1==.s | r`wv'lgrip2==.s) & mi(r`wv'lgrip)
replace r`wv'lgrip = .n if (r`wv'lgrip1==.n | r`wv'lgrip2==.n) & mi(r`wv'lgrip)
replace r`wv'lgrip = .l if (r`wv'lgrip1==.l | r`wv'lgrip2==.l) & mi(r`wv'lgrip)
label variable r`wv'lgrip "r`wv'lgrip:w`wv' r maximum left hand grip measurement(kg)"
*spouse
gen s`wv'lgrip =.
spouse r`wv'lgrip, result(s`wv'lgrip) wave(`wv')
label variable s`wv'lgrip "s`wv'lgrip:w`wv' s maximum left hand grip measurement(kg)"

***Right Hand 1
gen r`wv'rgrip1 = .
missing_lasi bm029, result(r`wv'rgrip1) wave(`wv')
replace r`wv'rgrip1 = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'rgrip1 = .n if bm025==1
replace r`wv'rgrip1 = .t if bm025==3
replace r`wv'rgrip1 = .d if bm029==.d  
replace r`wv'rgrip1 = .r if bm029==.r   
replace r`wv'rgrip1 = bm029 if inrange(bm029,0,70) 
label variable r`wv'rgrip1 "r`wv'rgrip1:w`wv' r right hand grip measurement 1(kg)"
*spouse
gen s`wv'rgrip1 =.
spouse r`wv'rgrip1, result(s`wv'rgrip1) wave(`wv')
label variable s`wv'rgrip1 "s`wv'rgrip1:w`wv' s right hand grip measurement 1(kg)"

***Right Hand 2
gen r`wv'rgrip2 = .
missing_lasi bm031, result(r`wv'rgrip2) wave(`wv')
replace r`wv'rgrip2 = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'rgrip2 = .n if bm025==1
replace r`wv'rgrip2 = .t if bm025==3
replace r`wv'rgrip2 = .d if bm031==.d
replace r`wv'rgrip2 = .r if bm031==.r 
replace r`wv'rgrip2 = bm031 if inrange(bm031,0,70)
label variable r`wv'rgrip2 "r`wv'rgrip2:w`wv' r right hand grip measurement 2(kg)"
*spouse
gen s`wv'rgrip2 = .
spouse r`wv'rgrip2, result(s`wv'rgrip2) wave(`wv')
label variable s`wv'rgrip2 "s`wv'rgrip2:w`wv' s right hand grip measurement 2(kg)"

***Right Hand Maximum
egen r`wv'rgrip =rowmax (r`wv'rgrip1 r`wv'rgrip2) if inw`wv' == 1
missing_lasi r`wv'rgrip1 r`wv'rgrip2 if mi(r`wv'rgrip), result(r`wv'rgrip) wave(`wv')
replace r`wv'rgrip = .s if (r`wv'rgrip1==.s | r`wv'rgrip2==.s) & mi(r`wv'rgrip)
replace r`wv'rgrip = .n if (r`wv'rgrip1==.n | r`wv'rgrip2==.n) & mi(r`wv'rgrip)
replace r`wv'rgrip = .t if (r`wv'rgrip1==.t | r`wv'rgrip2==.t) & mi(r`wv'rgrip)
label variable r`wv'rgrip "r`wv'rgrip:w`wv' r maximum right hand grip measurement(kg)"
*spouse
gen s`wv'rgrip =.
spouse r`wv'rgrip, result(s`wv'rgrip) wave(`wv')
label variable s`wv'rgrip "s`wv'rgrip:w`wv' s maximum right hand grip measurement(kg)"

***Grip Strength Summary Value (value of dominant hand)
gen r`wv'gripsum =. 
replace r`wv'gripsum = max(r`wv'rgrip, r`wv'lgrip) if inlist(r`wv'domhand,3,.d,.s,.m,.r,.n) 
replace r`wv'gripsum = r`wv'rgrip if r`wv'domhand == 1
replace r`wv'gripsum = r`wv'lgrip if r`wv'domhand == 2
missing_lasi r`wv'rgrip r`wv'lgrip if mi(r`wv'gripsum), result(r`wv'gripsum) wave(`wv')
replace r`wv'gripsum = .s if (r`wv'rgrip == .s | r`wv'lgrip == .s) & mi(r`wv'gripsum)
replace r`wv'gripsum = .n if (r`wv'rgrip == .n | r`wv'lgrip == .n) & mi(r`wv'gripsum)
replace r`wv'gripsum = .l if (r`wv'rgrip == .l | r`wv'lgrip == .l) & mi(r`wv'gripsum)
replace r`wv'gripsum = .t if (r`wv'rgrip == .t | r`wv'lgrip == .t) & mi(r`wv'gripsum)
label variable r`wv'gripsum "r`wv'gripsum:w`wv' r summary of grip strength(kg)"
*spouse
gen s`wv'gripsum =.
spouse r`wv'gripsum, result(s`wv'gripsum) wave(`wv')
label variable s`wv'gripsum "s`wv'gripsum:w`wv' s summary of grip strength(kg)"

***whether willing to complete grip tests
gen r`wv'gripcomp = .
missing_lasi bm024 bm025, result(r`wv'gripcomp) wave(`wv')
replace r`wv'gripcomp = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'gripcomp = 0 if bm024==1 & bm025==1
replace r`wv'gripcomp = 1 if bm024==2 | (bm024==1 & inlist(bm025,2,3))
label variable r`wv'gripcomp "r`wv'gripcomp:w`wv' r willing and able to complete grip strength tests"
label values r`wv'gripcomp yesnon
*spouse
gen s`wv'gripcomp = .
spouse r`wv'gripcomp, result(s`wv'gripcomp) wave(`wv')
label variable s`wv'gripcomp "s`wv'gripcomp:w`wv' s willing and able to complete grip strength tests"
label values s`wv'gripcomp yesnon

***Grip strength position
gen r`wv'grippos = .
missing_lasi bm033, result(r`wv'grippos) wave(`wv')
replace r`wv'grippos = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'grippos = .n if bm025 == 1
replace r`wv'grippos = bm033 if inrange(bm033,1,3)
label variable r`wv'grippos "r`wv'grippos:w`wv' r position for grip strength test"  
label value r`wv'grippos post
*spouse
gen s`wv'grippos =.
spouse r`wv'grippos, result(s`wv'grippos) wave(`wv')
label variable s`wv'grippos "s`wv'grippos:w`wv' s position for grip strength test"
label value s`wv'grippos post

***effort level grip strength
gen r`wv'gripeff = . 
missing_lasi bm032, result(r`wv'gripeff) wave(`wv')
replace r`wv'gripeff = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'gripeff = .n if bm025 == 1 
replace r`wv'gripeff = bm032 if inrange(bm032,1,3)
label variable r`wv'gripeff "r`wv'gripeff:w`wv' r effort level grip strength test"  
label value r`wv'gripeff effort

*wave 1 Spouse effort level grip strength
gen s`wv'gripeff =.
spouse r`wv'gripeff, result(s`wv'gripeff) wave(`wv')
label variable s`wv'gripeff "s`wv'gripeff:w`wv' s effort level grip strength test"
label value s`wv'gripeff effort

***Rested Arms for Grip Test
gen r`wv'griprsta=.
missing_lasi bm034, result(r`wv'griprsta) wave(`wv')
replace r`wv'griprsta=.s if inw`wv'pm==0 & inw`wv'==1
replace r`wv'griprsta=.n if bm025==1
replace r`wv'griprsta=0 if bm034==2
replace r`wv'griprsta=1 if bm034==1
label variable r`wv'griprsta "r`wv'griprsta:w`wv' r rested arms on a support during grip strength test"
label values r`wv'griprsta yesnon

*wave 1 spouse rested arms for grip test
gen s`wv'griprsta=.
spouse r`wv'griprsta, result(s`wv'griprsta) wave(`wv')
label variable s`wv'griprsta "s`wv'griprsta:w`wv' s rested arms on a support during grip strength test"
label values s`wv'griprsta yesnon


*********************************************************************
***Balance Tests***
*********************************************************************

***semi-tandem
gen r`wv'semidone =  .
missing_lasi bm037 bm038, result(r`wv'semidone) wave(`wv')
replace r`wv'semidone = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'semidone = .n if bm036==1 | bm037 == 2
replace r`wv'semidone = 0 if  bm038 == 2
replace r`wv'semidone = 1 if  bm038 == 1
label variable r`wv'semidone "r`wv'semidone:w`wv' r whether completed full 10 sec semi-tandem test"
label value r`wv'semidone yesnon
*spouse 
gen s`wv'semidone =.
spouse r`wv'semidone, result(s`wv'semidone) wave(`wv')
label variable s`wv'semidone "s`wv'semidone:w`wv' s whether completed full 10 sec semi-tandem test"
label value s`wv'semidone yesnon

***semi-tandem seconds
gen r`wv'semitan = .
missing_lasi bm037 bm038 bm039, result(r`wv'semitan) wave(`wv')
replace r`wv'semitan = .s if inw`wv'pm==0 & inw`wv'==1
replace r`wv'semitan = .n if bm036==1 | bm037==2
replace r`wv'semitan = bm039 if inrange(bm039,0,9.99)
replace r`wv'semitan = 10 if bm038==1
label variable r`wv'semitan "r`wv'semitan:w`wv' r semi-tandem test result (sec)"
*spouse
gen s`wv'semitan = .
spouse r`wv'semitan, result(s`wv'semitan) wave(`wv')
label variable s`wv'semitan "s`wv'semitan:w`wv' s semi-tandem test result (sec)"

***whether willing to complete semi-tandem
gen r`wv'semicomp = .
missing_lasi bm036 bm037, result(r`wv'semicomp) wave(`wv')
replace r`wv'semicomp = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'semicomp = 0 if bm036==1 & bm037==2
replace r`wv'semicomp = 1 if bm036==2 | (bm036==1 & bm037==1)
label variable r`wv'semicomp "r`wv'semicomp:w`wv' r willing and able to complete semi-tandem test"
label values r`wv'semicomp yesnon
*spouse
gen s`wv'semicomp = .
spouse r`wv'semicomp, result(s`wv'semicomp) wave(`wv')
label variable s`wv'semicomp "s`wv'semicomp:w`wv' s willing and able to complete semi-tandem test"
label values s`wv'semicomp yesnon

***semi-tandem compensatory movements
gen r`wv'semitanc = .
missing_lasi bm037 bm040, result(r`wv'semitanc) wave(`wv')
replace r`wv'semitanc = .s if inw`wv'pm==0 & inw`wv'==1
replace r`wv'semitanc = .n if bm036==1 | bm037==2
replace r`wv'semitanc = 0 if bm040==2
replace r`wv'semitanc = 1 if bm040==1
label variable r`wv'semitanc "r`wv'semitanc:w`wv' r semi-tandem test-compensatory movements"
label values r`wv'semitanc yesnon
*spouse
gen s`wv'semitanc = .
spouse r`wv'semitanc, result(s`wv'semitanc) wave(`wv')
label variable s`wv'semitanc "s`wv'semitanc:w`wv' s semi-tandem test-compensatory movements"
label values s`wv'semitanc yesnon

***Whether completed 10 seconds side-by-side
gen r`wv'sbsdone = . 
missing_lasi bm042 bm037 bm038, result(r`wv'sbsdone) wave(`wv')
replace r`wv'sbsdone = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'sbsdone = .n if bm036==1 | bm041 == 2 | bm037 == 2
replace r`wv'sbsdone = .t if bm038 == 1
replace r`wv'sbsdone = 0 if bm042 == 2
replace r`wv'sbsdone = 1 if bm042 == 1
label variable r`wv'sbsdone "r`wv'sbsdone:w`wv' r whether completed 10 seconds side-by-side"  
label value r`wv'sbsdone yesnon
*spouse
gen s`wv'sbsdone =.
spouse r`wv'sbsdone, result(s`wv'sbsdone) wave(`wv')
label variable s`wv'sbsdone "s`wv'sbsdone:w`wv' s whether completed 10 seconds side-by-side"
label value s`wv'sbsdone yesnon

***side-by-side seconds
gen r`wv'sbstan = .
missing_lasi bm042 bm037 bm038, result(r`wv'sbstan) wave(`wv')
replace r`wv'sbstan = .s if inw`wv'pm==0 & inw`wv'==1
replace r`wv'sbstan = .n if bm036==1 | bm041==2 | bm037==2
replace r`wv'sbstan = .t if bm038==1
replace r`wv'sbstan = bm043 if inrange(bm043,0,9.99)
replace r`wv'sbstan = 10 if bm042==1
label variable r`wv'sbstan "r`wv'sbstan:w`wv' r side-by-side test result (sec)"
*spouse
gen s`wv'sbstan = .
spouse r`wv'sbstan, result(s`wv'sbstan) wave(`wv')
label variable s`wv'sbstan "s`wv'sbstan:w`wv' s side-by-side test result (sec)"

***whether willing to complete side-by-side
gen r`wv'sbscomp = .
missing_lasi bm036 bm037 bm041, result(r`wv'sbscomp) wave(`wv')
replace r`wv'sbscomp = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'sbscomp = .t if bm038==1
replace r`wv'sbscomp = 0 if (bm036==1 & bm037==2) | bm041==2
replace r`wv'sbscomp = 1 if bm041==1
label variable r`wv'sbscomp "r`wv'sbscomp:w`wv' r willing and able to complete side-by-side"
label values r`wv'sbscomp yesnon
*spouse
gen s`wv'sbscomp = .
spouse r`wv'sbscomp, result(s`wv'sbscomp) wave(`wv')
label variable s`wv'sbscomp "s`wv'sbscomp:w`wv' s willing and able to complete side-by-side"
label values s`wv'sbscomp yesnon

***side-by-side compensatory movements
gen r`wv'sbstanc = .
missing_lasi bm036 bm037 bm044, result(r`wv'sbstanc) wave(`wv')
replace r`wv'sbstanc = .s if inw`wv'pm==0 & inw`wv'==1
replace r`wv'sbstanc = .n if bm036==1 | bm041==2 | bm037==2
replace r`wv'sbstanc = .t if bm038==1
replace r`wv'sbstanc = 0 if bm044==2
replace r`wv'sbstanc = 1 if bm044==1
label variable r`wv'sbstanc "r`wv'sbstanc:w`wv' r side-by-side test-compensatory movements"
label values r`wv'sbstanc yesnon
*spouse
gen s`wv'sbstanc = .
spouse r`wv'sbstanc, result(s`wv'sbstanc) wave(`wv')
label variable s`wv'sbstanc "s`wv'sbstanc:w`wv' s side-by-side test-compensatory movements"
label values s`wv'sbstanc yesnon

***Whether completed 30/60 seconds full-tandem 
gen r`wv'fulldone = .
missing_lasi bm049_iwer bm037 bm038 bm050, result(r`wv'fulldone) wave(`wv') 
replace r`wv'fulldone = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'fulldone = .m if bm050 == .e 
replace r`wv'fulldone = .n if bm036==1 | bm048 == 2 | bm037 == 2
replace r`wv'fulldone = .t if bm038 == 2
replace r`wv'fulldone = 0 if bm049_iwer == 2 
replace r`wv'fulldone = 1 if bm049_iwer == 1 | (bm050 == 60 & inrange(r`wv'agey,1,70)) | (bm050 == 30 & inrange(r`wv'agey,71,150))
label variable r`wv'fulldone "r`wv'fulldone:w`wv' r whether completed 30/60 seconds full-tandem"  
label value r`wv'fulldone yesnon
*spouse
gen s`wv'fulldone =.
spouse r`wv'fulldone, result(s`wv'fulldone) wave(`wv')
label variable s`wv'fulldone "s`wv'fulldone:w`wv' s whether completed 30/60 seconds full-tandem"
label value s`wv'fulldone yesnon

***full-tandem seconds
gen r`wv'fulltan = .
missing_lasi bm049_iwer bm037 bm038 bm050, result(r`wv'fulltan) wave(`wv')
replace r`wv'fulltan = .s if inw`wv'pm==0 & inw`wv'==1
replace r`wv'fulltan = .m if bm050==.e
replace r`wv'fulltan = .n if bm036==1 | bm048==2 | bm037==2
replace r`wv'fulltan = .t if bm038==2
replace r`wv'fulltan = bm050 if inrange(bm050,0,60)
replace r`wv'fulltan = 30 if mi(bm050) & bm049_iwer==1 & inrange(r`wv'agey,71,150)
replace r`wv'fulltan = 60 if mi(bm050) & bm049_iwer==1 & inrange(r`wv'agey,1,70)
label variable r`wv'fulltan "r`wv'fulltan:w`wv' r full-tandem test result (sec)"
*spouse 
gen s`wv'fulltan = .
spouse r`wv'fulltan, result(s`wv'fulltan) wave(`wv')
label variable s`wv'fulltan "s`wv'fulltan:w`wv' s full-tandem test result (sec)"

***whether willing to complete full-tandem
gen r`wv'fullcomp = .
missing_lasi bm036 bm037 bm048, result(r`wv'fullcomp) wave(`wv')
replace r`wv'fullcomp = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'fullcomp = .t if bm038==2
replace r`wv'fullcomp = 0 if (bm036==1 & bm037==2) | bm048==2
replace r`wv'fullcomp = 1 if bm048==1
label variable r`wv'fullcomp "r`wv'fullcomp:w`wv' r willing and able to complete full-tandem"
label values r`wv'fullcomp yesnon
*spouse
gen s`wv'fullcomp = .
spouse r`wv'fullcomp, result(s`wv'fullcomp) wave(`wv')
label variable s`wv'fullcomp "s`wv'fullcomp:w`wv' s willing and able to complete full-tandem"
label values s`wv'fullcomp yesnon

***full-tandem compensatory movements
gen r`wv'fulltanc = .
missing_lasi bm036 bm037 bm051_iwer, result(r`wv'fulltanc) wave(`wv')
replace r`wv'fulltanc = .s if inw`wv'pm==0 & inw`wv'==1
replace r`wv'fulltanc = .n if bm036==1 | bm048==2 | bm037==2
replace r`wv'fulltanc = .t if bm038==2
replace r`wv'fulltanc = 0 if bm051_iwer==2
replace r`wv'fulltanc = 1 if bm051_iwer==1
label variable r`wv'fulltanc "r`wv'fulltanc:w`wv' r full-tandem test-compensatory movements"
label values r`wv'fulltanc yesnon
*spouse 
gen s`wv'fulltanc = .
spouse r`wv'fulltanc, result(s`wv'fulltanc) wave(`wv')
label variable s`wv'fulltanc "s`wv'fulltanc:w`wv' s full-tandem test-compensatory movements"
label values s`wv'fulltanc yesnon

***Balance Test Summary Score 
gen r`wv'balance =  .
missing_lasi r`wv'semidone r`wv'sbsdone r`wv'fulldone, result(r`wv'balance) wave(`wv')
replace r`wv'balance = .s if r`wv'semidone == .s | r`wv'sbsdone == .s | r`wv'fulldone == .s
replace r`wv'balance = .n if r`wv'semidone == .n | r`wv'sbsdone == .n | r`wv'fulldone == .n
replace r`wv'balance = 1 if r`wv'semidone == 0 & r`wv'sbsdone == 0
replace r`wv'balance = 2 if r`wv'semidone == 0 & r`wv'sbsdone == 1
replace r`wv'balance = 3 if r`wv'semidone == 1 & r`wv'fulldone == 0
replace r`wv'balance = 4 if r`wv'semidone == 1 & r`wv'fulldone == 1
label variable r`wv'balance "r`wv'balance:w`wv' r balance test summary score"
label value r`wv'balance blnc
*spouse
gen s`wv'balance =.
spouse r`wv'balance, result(s`wv'balance) wave(`wv')
label variable s`wv'balance "s`wv'balance:w`wv' s balance test summary score"
label value s`wv'balance blnc

***balance test floor type
gen r`wv'balflr = . 
missing_lasi bm045 r`wv'balance, result(r`wv'balflr) wave(`wv')
replace r`wv'balflr = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'balflr = .n if bm036==1 | bm037 == 2 | bm041==2 | bm048==2
replace r`wv'balflr = bm045 if inrange(bm045,1,3)
replace r`wv'balflr = bm052 if inrange(bm052,1,3)
label variable r`wv'balflr "r`wv'balflr:w`wv' r balance tests floor type"  
label value r`wv'balflr floor
*spouse
gen s`wv'balflr =.
spouse r`wv'balflr, result(s`wv'balflr) wave(`wv')
label variable s`wv'balflr "s`wv'balflr:w`wv' s balance tests floor type"
label value s`wv'balflr floor

***balance test compliance
gen r`wv'balcompl = .
missing_lasi bm046 r`wv'balance, result(r`wv'balcompl) wave(`wv') 
replace r`wv'balcompl = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'balcompl = .n if bm036==1 | bm037 == 2 | bm041==2 | bm048==2
replace r`wv'balcompl = bm046 if inrange(bm046,1,3)
replace r`wv'balcompl = bm053_iwer if inrange(bm053_iwer,1,3)
label variable r`wv'balcompl "r`wv'balcompl:w`wv' r compliance during balance tests"  
label value r`wv'balcompl compli
*spouse
gen s`wv'balcompl =.
spouse r`wv'balcompl, result(s`wv'balcompl) wave(`wv')
label variable s`wv'balcompl "s`wv'balcompl:w`wv' s compliance during balance tests"
label value s`wv'balcompl compli


*********************************************************************
***Timed Walk Measurements***
*********************************************************************

***Walking Test 1st Trial Time
gen r`wv'wspeed1 = . 
missing_lasi bm056, result(r`wv'wspeed1) wave(`wv')
replace r`wv'wspeed1 = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'wspeed1 = .n if inrange(bm054,2,4) | bm055 == 2 
replace r`wv'wspeed1 = bm056 if inrange(bm056,0,60) 
label variable r`wv'wspeed1 "r`wv'wspeed1:w`wv' r walking speed 1(sec)"
*spouse
gen s`wv'wspeed1 =.
spouse r`wv'wspeed1, result(s`wv'wspeed1) wave(`wv')
label variable s`wv'wspeed1 "s`wv'wspeed1:w`wv' s walking speed 1(sec)"

***Walking Test 2nd Trial Time 
gen r`wv'wspeed2 = . 
missing_lasi bm057, result(r`wv'wspeed2) wave(`wv')
replace r`wv'wspeed2 = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'wspeed2 = .n if inrange(bm054,2,4) | bm055 == 2 
replace r`wv'wspeed2 = bm057 if inrange(bm057,0,60)
label variable r`wv'wspeed2 "r`wv'wspeed2:w`wv' r walking speed 2(sec)"
*spouse
gen s`wv'wspeed2 =.
spouse r`wv'wspeed2, result(s`wv'wspeed2) wave(`wv')
label variable s`wv'wspeed2 "s`wv'wspeed2:w`wv' s walking speed 2(sec)"

***Measure Walking Speed Average 
gen r`wv'wspeed = . 
missing_lasi r`wv'wspeed1 r`wv'wspeed2, result(r`wv'wspeed) wave(`wv')
replace r`wv'wspeed = .s if r`wv'wspeed1 == .s | r`wv'wspeed2 == .s 
replace r`wv'wspeed = .n if r`wv'wspeed1 == .n | r`wv'wspeed2 == .n  
replace r`wv'wspeed = (r`wv'wspeed1 + r`wv'wspeed2)/2 if !mi(r`wv'wspeed1) & !mi(r`wv'wspeed2)
label variable r`wv'wspeed "r`wv'wspeed:w`wv' r average walking speed(sec)"
*spouse
gen s`wv'wspeed =.
spouse r`wv'wspeed, result(s`wv'wspeed) wave(`wv')
label variable s`wv'wspeed "s`wv'wspeed:w`wv' s average walking speed(sec)"

***whether willing to complete walking test
gen r`wv'walkcomp = .
missing_lasi bm054 bm055, result(r`wv'walkcomp) wave(`wv')
replace r`wv'walkcomp = .s if inw`wv'pm==0 & inw`wv'==1
replace r`wv'walkcomp = 0 if inrange(bm054,2,4) | bm055==2
replace r`wv'walkcomp = 1 if bm054==1 & bm055==1
label variable r`wv'walkcomp "r`wv'walkcomp:w`wv' r willing and able to complete walking test"
label values r`wv'walkcomp yesnon
*spouse
gen s`wv'walkcomp = .
spouse r`wv'walkcomp, result(s`wv'walkcomp) wave(`wv')
label variable s`wv'walkcomp "s`wv'walkcomp:w`wv' s willing and able to complete walking test"
label values s`wv'walkcomp yesnon

***compliance during the walking test  
gen r`wv'walkcompl = . 
missing_lasi bm059, result(r`wv'walkcompl) wave(`wv')
replace r`wv'walkcompl = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'walkcompl = .n if inrange(bm054,2,4) | bm055 == 2  
replace r`wv'walkcompl = bm059 if inrange(bm059,1,3)
label variable r`wv'walkcompl "r`wv'walkcompl:w`wv' r compliance during walking speed test"  
label value r`wv'walkcompl compli
*spouse
gen s`wv'walkcompl =.
spouse r`wv'walkcompl, result(s`wv'walkcompl) wave(`wv')
label variable s`wv'walkcompl "s`wv'walkcompl:w`wv' s compliance during walking speed test"
label value s`wv'walkcompl compli

***Type of Aid - Walking Test
gen r`wv'walkaid=.
missing_lasi bm058, result(r`wv'walkaid) wave(`wv')
replace r`wv'walkaid=.s if inw`wv'pm==0 & inw`wv'==1
replace r`wv'walkaid=.n if inrange(bm054,2,4) | bm055==2
replace r`wv'walkaid=bm058 if inrange(bm058,1,5)
label variable r`wv'walkaid "r`wv'walkaid:w`wv' type aid used during r's walking speed test"
label value r`wv'walkaid aids
*Spouse
gen s`wv'walkaid=.
spouse r`wv'walkaid, result(s`wv'walkaid) wave(`wv')
label variable s`wv'walkaid "s`wv'walkaid:w`wv' type aid used during s's walking speed test"
label value s`wv'walkaid aids


*********************************************************************
***Height***
*********************************************************************

***willing/able to complete height***
gen r`wv'htcomp = .
missing_lasi bm066 bm067, result(r`wv'htcomp) wave(`wv')
replace r`wv'htcomp = .s if inw`wv'pm==0 & inw`wv'==1
replace r`wv'htcomp = 0 if bm066==2 & mi(bm067)
replace r`wv'htcomp = 1 if bm066==1 & !mi(bm067)
label variable r`wv'htcomp "r`wv'htcomp:w`wv' r willing and able to complete height measurement"
label values r`wv'htcomp yesnon
*spouse
gen s`wv'htcomp = .
spouse r`wv'htcomp, result(s`wv'htcomp) wave(`wv')
label variable s`wv'htcomp "s`wv'htcomp:w`wv' s willing and able to complete height measurement"
label values s`wv'htcomp yesnon

***Measured height
gen r`wv'mheight = . 
missing_lasi bm067, result(r`wv'mheight) wave(`wv')
replace r`wv'mheight = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'mheight = .n if bm066 == 2 
replace r`wv'mheight = bm067/100 if inrange(bm067,50,200)
label variable r`wv'mheight "r`wv'mheight:w`wv' r height measurement in meters"
*spouse
gen s`wv'mheight =.
spouse r`wv'mheight, result(s`wv'mheight) wave(`wv')
label variable s`wv'mheight "s`wv'mheight:w`wv' s height measurement in meters"

***Wearing any artificial limbs or orthosis during height measure 
gen r`wv'htlimbs = .
missing_lasi bm068, result(r`wv'htlimbs) wave(`wv')
replace r`wv'htlimbs = .s if inw`wv'pm==0 & inw`wv'==1
replace r`wv'htlimbs = 0 if bm068==2
replace r`wv'htlimbs = 1 if bm068==1
label variable r`wv'htlimbs "r`wv'htlimbs:w`wv' r wearing artificial limb/orthosis for height measure"
label values r`wv'htlimbs yesnon
*spouse
gen s`wv'htlimbs = .
spouse r`wv'htlimbs, result(s`wv'htlimbs) wave(`wv')
label variable s`wv'htlimbs "s`wv'htlimbs:w`wv' s wearing artificial limb/orthosis for height measure"
label values s`wv'htlimbs yesnon

***compliance during height measurement 
gen r`wv'htcompl = .
missing_lasi bm069, result(r`wv'htcompl) wave(`wv') 
replace r`wv'htcompl = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'htcompl = .n if bm066 == 2  
replace r`wv'htcompl = bm069 if inrange(bm069,1,3)
label variable r`wv'htcompl "r`wv'htcompl:w`wv' r compliance during height measurement"  
label value r`wv'htcompl compli
*spouse
gen s`wv'htcompl =.
spouse r`wv'htcompl, result(s`wv'htcompl) wave(`wv')
label variable s`wv'htcompl "s`wv'htcompl:w`wv' s compliance during height measurement"
label value s`wv'htcompl compli


*********************************************************************
***Weight***
*********************************************************************

***willing/able to complete weight***
gen r`wv'wtcomp = .
missing_lasi bm066 bm071, result(r`wv'wtcomp) wave(`wv')
replace r`wv'wtcomp = .s if inw`wv'pm==0 & inw`wv'==1
replace r`wv'wtcomp = 0 if bm066==2 & mi(bm071)
replace r`wv'wtcomp = 1 if bm066==1 & !mi(bm071)
label variable r`wv'wtcomp "r`wv'wtcomp:w`wv' r willing and able to complete weight measurement"
label values r`wv'wtcomp yesnon
*spouse
gen s`wv'wtcomp = .
spouse r`wv'wtcomp, result(s`wv'wtcomp) wave(`wv')
label variable s`wv'wtcomp "s`wv'wtcomp:w`wv' s willing and able to complete weight measurement"
label values s`wv'wtcomp yesnon

***Measurement weight
gen r`wv'mweight = . 
missing_lasi bm071 bm073, result(r`wv'mweight) wave(`wv')
replace r`wv'mweight = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'mweight = .n if bm066 == 2 
replace r`wv'mweight = bm071 if inrange(bm071,20,150)
replace r`wv'mweight = r`wv'mweight - bm073 if bm072==1 & inrange(r`wv'mweight,10,150) & inrange(bm073,0,70)
replace r`wv'mweight = .i if inrange(r`wv'mweight,-100,0) 
label variable r`wv'mweight "r`wv'mweight:w`wv' r weight measurement in kilograms"
*spouse
gen s`wv'mweight =.
spouse r`wv'mweight, result(s`wv'mweight) wave(`wv')
label variable s`wv'mweight "s`wv'mweight:w`wv' s weight measurement in kilograms"

***Wearing any artificial limbs or orthosis during weight measure
gen r`wv'wtlimbs = .
missing_lasi bm072, result(r`wv'wtlimbs) wave(`wv')
replace r`wv'wtlimbs = .s if inw`wv'pm==0 & inw`wv'==1
replace r`wv'wtlimbs = 0 if bm072==2
replace r`wv'wtlimbs = 1 if bm072==1
label variable r`wv'wtlimbs "r`wv'wtlimbs:w`wv' r wearing artificial limb/orthosis for weight measure"
label values r`wv'wtlimbs yesnon
*spouse
gen s`wv'wtlimbs = .
spouse r`wv'wtlimbs, result(s`wv'wtlimbs) wave(`wv')
label variable s`wv'wtlimbs "s`wv'wtlimbs:w`wv' s wearing artificial limb/orthosis for weight measure"
label values s`wv'wtlimbs yesnon

***compliance during weight measurement 
gen r`wv'wtcompl = .
missing_lasi bm074, result(r`wv'wtcompl) wave(`wv') 
replace r`wv'wtcompl = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'wtcompl = .n if bm066 == 2   
replace r`wv'wtcompl = bm074 if inrange(bm074,1,3)
label variable r`wv'wtcompl "r`wv'wtcompl:w`wv' r compliance during weight measurement "  
label value r`wv'wtcompl compli
*spouse
gen s`wv'wtcompl =.
spouse r`wv'wtcompl, result(s`wv'wtcompl) wave(`wv')
label variable s`wv'wtcompl "s`wv'wtcompl:w`wv' s compliance during weight measurement "
label value s`wv'wtcompl compli

***Measured BMI
gen r`wv'mbmi = . 
missing_lasi r`wv'mweight r`wv'mheight, result(r`wv'mbmi) wave(`wv')
replace r`wv'mbmi = .s if r`wv'mweight == .s | r`wv'mheight == .s 
replace r`wv'mbmi = .n if r`wv'mweight == .n | r`wv'mheight == .n 
replace r`wv'mbmi = .i if r`wv'mweight == .i
replace r`wv'mbmi = r`wv'mweight / ((r`wv'mheight)^2) if !mi(r`wv'mweight) & !mi(r`wv'mheight)
label variable r`wv'mbmi "r`wv'mbmi:w`wv' r measured Body Mass Index=kg/m2"
*spouse
gen s`wv'mbmi =.
spouse r`wv'mbmi, result(s`wv'mbmi) wave(`wv')
label variable s`wv'mbmi "s`wv'mbmi:w`wv' s measured Body Mass Index=kg/m2"

***BMI Categories  
*HRS & ELSA have obesity class 1 (30-34.9), obesity class 2 (35-39.9), obesity class 3 (>=40)
gen r`wv'mbmicat=.
missing_lasi r`wv'mbmi r`wv'mweight r`wv'mheight, result(r`wv'mbmicat) wave(`wv')
replace r`wv'mbmicat=.s if r`wv'mweight==.s | r`wv'mheight==.s
replace r`wv'mbmicat=.n if r`wv'mweight==.n | r`wv'mheight==.n
replace r`wv'mbmicat=.i if r`wv'mbmi==.i
replace r`wv'mbmicat=1 if inrange(r`wv'mbmi,0.001,18.49999)
replace r`wv'mbmicat=2 if inrange(r`wv'mbmi,18.5,24.99999)
replace r`wv'mbmicat=3 if inrange(r`wv'mbmi,25.0, 29.99999)
replace r`wv'mbmicat=4 if inrange(r`wv'mbmi,30.0, 34.99999)
replace r`wv'mbmicat=5 if inrange(r`wv'mbmi,35.0, 39.99999)
replace r`wv'mbmicat=6 if inrange(r`wv'mbmi,40,150)
label variable r`wv'mbmicat "r`wv'mbmicat:w`wv' r measured BMI categorization"
label value r`wv'mbmicat bmicate2 
*Spouse
gen s`wv'mbmicat=.
spouse r`wv'mbmicat, result(s`wv'mbmicat) wave(`wv')
label variable s`wv'mbmicat "s`wv'mbmicat:w`wv' s measured BMI categorization"
label value s`wv'mbmicat bmicate2


*********************************************************************
***Waist Measurements ***
*********************************************************************
***willing/able to complete waist***
gen r`wv'watcomp = .
missing_lasi bm066 bm076, result(r`wv'watcomp) wave(`wv')
replace r`wv'watcomp = .s if inw`wv'pm==0 & inw`wv'==1
replace r`wv'watcomp = 0 if bm066==2 & mi(bm076)
replace r`wv'watcomp = 1 if bm066==1 & !mi(bm076)
label variable r`wv'watcomp "r`wv'watcomp:w`wv' r willing and able to complete waist measurement"
label values r`wv'watcomp yesnon
*spouse
gen s`wv'watcomp = .
spouse r`wv'watcomp, result(s`wv'watcomp) wave(`wv')
label variable s`wv'watcomp "s`wv'watcomp:w`wv' s willing and able to complete waist measurement"
label values s`wv'watcomp yesnon

****Waist measurement: 
gen r`wv'mwaist = .
missing_lasi bm076, result(r`wv'mwaist) wave(`wv')
replace r`wv'mwaist = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'mwaist = .n if bm066 == 2
replace r`wv'mwaist = .r if bm076==.r
replace r`wv'mwaist = bm076 if inrange(bm076,20,800)
label variable r`wv'mwaist "r`wv'mwaist:w`wv' r waist measurement in cm"
*spouse
gen s`wv'mwaist =.
spouse r`wv'mwaist, result(s`wv'mwaist) wave(`wv')
label variable s`wv'mwaist "s`wv'mwaist:w`wv' s waist measurement in cm"

***Whether wearing bulky clothing 
gen r`wv'bulky = . 
missing_lasi bm077, result(r`wv'bulky) wave(`wv')
replace r`wv'bulky = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'bulky = .n if bm066 == 2  
replace r`wv'bulky = 0 if bm077 == 2
replace r`wv'bulky = 1 if bm077 == 1
label variable r`wv'bulky "r`wv'bulky:w`wv' r wearing bulky clothes for waist measurement"  
label value r`wv'bulky yesnon
*spouse
gen s`wv'bulky =.
spouse r`wv'bulky, result(s`wv'bulky) wave(`wv')
label variable s`wv'bulky "s`wv'bulky:w`wv' s wearing bulky clothes for waist measurement"
label value s`wv'bulky yesnon


*********************************************************************
***Hip Measurements***
*********************************************************************
***willing/able to complete hip***
gen r`wv'hipcomp = .
missing_lasi bm066 bm079, result(r`wv'hipcomp) wave(`wv')
replace r`wv'hipcomp = .s if inw`wv'pm==0 & inw`wv'==1
replace r`wv'hipcomp = 0 if bm066==2 & mi(bm079)
replace r`wv'hipcomp = 1 if bm066==1 & !mi(bm079)
label variable r`wv'hipcomp "r`wv'hipcomp:w`wv' r willing and able to complete hip measurement"
label values r`wv'hipcomp yesnon
*spouse
gen s`wv'hipcomp = .
spouse r`wv'hipcomp, result(s`wv'hipcomp) wave(`wv')
label variable s`wv'hipcomp "s`wv'hipcomp:w`wv' s willing and able to complete hip measurement"
label values s`wv'hipcomp yesnon

***Hip measurement - changed to cm 
*Code .i if negative values or if smaller than 50 cm or greater than 500 cm; 999 = .r
gen r`wv'mhip = . 
missing_lasi bm079, result(r`wv'mhip) wave(`wv')
replace r`wv'mhip = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'mhip = .n if bm066 == 2  
replace r`wv'mhip = bm079 if inrange(bm079,20,1000)
label variable r`wv'mhip "r`wv'mhip:w`wv' r hip measurement in cm"
*spouse
gen s`wv'mhip =.
spouse r`wv'mhip, result(s`wv'mhip) wave(`wv')
label variable s`wv'mhip "s`wv'mhip:w`wv' s hip measurement in cm"

***difficulty during hip measurement
gen r`wv'hipdiff = . 
missing_lasi bm080s1 bm080s2 bm080s3 bm080s4 bm080s5 bm080s6 bm080s7, result(r`wv'hipdiff) wave(`wv')
replace r`wv'hipdiff = .s if inw`wv'pm == 0 & inw`wv'==1
replace r`wv'hipdiff = .n if bm066 == 2  
replace r`wv'hipdiff = 0 if bm080s1==1 | bm080s2==0 | bm080s3==0 | bm080s4==0 | bm080s5==0 | bm080s6==0 | bm080s7==0 
replace r`wv'hipdiff = 1 if bm080s2==1 | bm080s3==1 | bm080s4==1 | bm080s5==1 | bm080s6==1 | bm080s7==1
label variable r`wv'hipdiff "r`wv'hipdiff:w`wv' r any difficulty during hip measurement"  
label value r`wv'hipdiff yesnon
*spouse
gen s`wv'hipdiff =.
spouse r`wv'hipdiff, result(s`wv'hipdiff) wave(`wv')
label variable s`wv'hipdiff "s`wv'hipdiff:w`wv' s any difficulty during hip measurement"
label value s`wv'hipdiff yesnon

****Measurement whr
gen r`wv'mwhratio = . 
missing_lasi r`wv'mwaist r`wv'mhip, result(r`wv'mwhratio) wave(`wv')
replace r`wv'mwhratio = .s if r`wv'mwaist == .s | r`wv'mhip == .s
replace r`wv'mwhratio = .n if r`wv'mwaist == .n | r`wv'mhip == .n 
replace r`wv'mwhratio = r`wv'mwaist / r`wv'mhip if !mi(r`wv'mwaist) & !mi(r`wv'mhip)
label variable r`wv'mwhratio "r`wv'mwhratio:w`wv' r measured waist-hip ratio"
*spouse
gen s`wv'mwhratio =.
spouse r`wv'mwhratio, result(s`wv'mwhratio) wave(`wv')
label variable s`wv'mwhratio "s`wv'mwhratio:w`wv' s measured waist-hip ratio"


***********BREATHING TEST********************
****whether willing to complete breathing test

**NOTE: current dataset does not have bm082-bm087

**wave 1 respondent whether willing to complete breathing test
*gen r`wv'brcomp = .
*missing_lasi bm082a bm082b bm082c bm082d bm082e bm084, result(r`wv'brcomp) wave(`wv')
*replace r`wv'brcomp = .b if inw`wv'pm==0
*replace r`wv'brcomp = .m if bm084==3
*replace r`wv'brcomp = 0 if bm082a==1 | bm082b==1 | bm082c==1 | bm082d==1 | bm082e==1 | bm084==2
*replace r`wv'brcomp = 1 if bm084==1
*label variable r`wv'brcomp "r`wv'brcomp:w`wv' r willing and able to complete breathing test"
*label values r`wv'brcomp yesnon
*
**wave 1 spouse whether willing to complete breathing test
*gen s`wv'brcomp = .
*spouse r`wv'brcomp, result(s`wv'brcomp) wave(`wv')
*label variable s`wv'brcomp "s`wv'brcomp:w`wv' s willing and able to complete breathing test"
*label values s`wv'brcomp yesnon 
*
*
****whether used inhaler in last 6 hours***
**wave 1 respondent whether used inhaler in last 6 hours
*gen r`wv'brinhlr = .
*missing_lasi bm083, result(r`wv'brinhlr) wave(`wv')
*replace r`wv'brinhlr = .b if inw`wv'pm==0
*replace r`wv'brinhlr = 0 if bm083==2
*replace r`wv'brinhlr = 1 if bm083==1
*label variable r`wv'brinhlr "r`wv'brinhlr:w`wv' r whether used inhaler in last 6 hours"
*label values r`wv'brinhlr yesnon
*
**wave 1 spouse whether used inhaler in last 6 hours
*gen s`wv'brinhlr = .
*spouse r`wv'brinhlr, result(s`wv'brinhlr) wave(`wv')
*label variable s`wv'brinhlr "s`wv'brinhlr:w`wv' s whether used inhaler in last 6 hours"
*label values s`wv'brinhlr yesnon
*
*
****breathing test 1***
**wave 1 respondent breathing test 1
*gen r`wv'breath1 = .
*missing_lasi bm085a, result(r`wv'breath1) wave(`wv')
*replace r`wv'breath1 = .b if inw`wv'pm==0
*replace r`wv'breath1 = .s if bm082a==1 | bm082b==1 | bm082c==1 | bm082d==1 | bm082e==1 | bm084==2
*replace r`wv'breath1 = bm085a if !mi(bm085a)
*label variable r`wv'breath1 "r`wv'breath1:w`wv' r breathing test score 1"
*
**wave 1 spouse breathing test 1
*gen s`wv'breath1 = .
*spouse r`wv'breath1, result(s`wv'breath1) wave(`wv')
*label variable s`wv'breath1 "s`wv'breath1:w`wv' s breathing test score 1"
*
*
****breathing test 2***
**wave 1 respondent breathing test 2
*gen r`wv'breath2 = .
*missing_lasi bm085b, result(r`wv'breath2) wave(`wv')
*replace r`wv'breath2 = .b if inw`wv'pm==0
*replace r`wv'breath2 = .s if bm082a==1 | bm082b==1 | bm082c==1 | bm082d==1 | bm082e==1 | bm084==2
*replace r`wv'breath2 = bm085b if !mi(bm085b)
*label variable r`wv'breath2 "r`wv'breath2:w`wv' r breathing test score 2"
*
**wave 1 spouse breathing test 2
*gen s`wv'breath2 = .
*spouse r`wv'breath2, result(s`wv'breath2) wave(`wv')
*label variable s`wv'breath2 "s`wv'breath2:w`wv' s breathing test score 2"
*
*
****breathing test 3***
**wave 1 respondent breathing test 3
*gen r`wv'breath3 = .
*missing_lasi bm085c, result(r`wv'breath3) wave(`wv')
*replace r`wv'breath3 = .b if inw`wv'pm==0
*replace r`wv'breath3 = .s if bm082a==1 | bm082b==1 | bm082c==1 | bm082d==1 | bm082e==1 | bm084==2
*replace r`wv'breath3 = bm085c if !mi(bm085c)
*label variable r`wv'breath3 "r`wv'breath3:w`wv' r breathing test score 3"
*
**wave 1 spouse breathing test 3
*gen s`wv'breath3 = .
*spouse r`wv'breath3, result(s`wv'breath3) wave(`wv')
*label variable s`wv'breath3 "s`wv'breath3:w`wv' s breathing test score 3"
*
*
****breathing test maximum***
**wave 1 respondent breathing test max
*egen r`wv'breath = rowmax(r`wv'breath1 r`wv'breath2 r`wv'breath3) if inw`wv' == 1
*missing_lasi r`wv'breath1 r`wv'breath2 r`wv'breath3 if mi(r`wv'breath), result(r`wv'breath) wave(`wv')
*replace r`wv'breath = .b if inw`wv'pm==0
*replace r`wv'breath = .s if bm082a==1 | bm082b==1 | bm082c==1 | bm082d==1 | bm082e==1 | bm084==2
*label variable r`wv'breath "r`wv'breath:w`wv' r maximum breathing test score"
*
**wave 1 spouse breathing test max
*gen s`wv'breath = .
*spouse r`wv'breath, result(s`wv'breath) wave(`wv')
*label variable s`wv'breath "s`wv'breath:w`wv' s maximum breathing test score"
*
*
****breathing test position***
**wave 1 respondent breathing test position
*gen r`wv'brpos = .
*missing_lasi bm086, result(r`wv'brpos) wave(`wv')
*replace r`wv'brpos = .b if inw`wv'pm==0
*replace r`wv'brpos = .s if bm082a==1 | bm082b==1 | bm082c==1 | bm082d==1 | bm082e==1 | bm084==2
*replace r`wv'brpos = bm086 if inrange(bm086,1,3)
*label variable r`wv'brpos "r`wv'brpos:w`wv' r position during breathing test"
*label values r`wv'brpos post
*
**wave 1 spouse breathing test position
*gen s`wv'brpos = .
*spouse r`wv'brpos, result(s`wv'brpos) wave(`wv')
*label variable s`wv'brpos "s`wv'brpos:w`wv' s position during breathing test"
*label values s`wv'brpos post
*
*
****breathing test effort***
**wave 1 respondent breathing test effort
*gen r`wv'breff = .
*missing_lasi bm087, result(r`wv'breff) wave(`wv')
*replace r`wv'breff = .b if inw`wv'pm==0
*replace r`wv'breff = .s if bm082a==1 | bm082b==1 | bm082c==1 | bm082d==1 | bm082e==1 | bm084==2
*replace r`wv'breff = bm087 if inrange(bm087,1,3)
*label variable r`wv'breff "r`wv'breff:w`wv' r effort level breathing test"
*label values r`wv'breff effort
*
**wave 1 spouse breathing test effort
*gen s`wv'breff = .
*spouse r`wv'breff, result(s`wv'breff) wave(`wv')
*label variable s`wv'breff "s`wv'breff:w`wv' s effort level breathing test"
*label values s`wv'breff effort


********************************************************************
***Vision Test***
********************************************************************
**??LASI_BM dta missing variables bm061, bm062, bm063, bm064 

***See light & count fingers 2ft - Left eye
gen r`wv'lvsn2ft=.
missing_lasi bm060a, result(r`wv'lvsn2ft) wave(`wv')
replace r`wv'lvsn2ft=.s if inw`wv'pm==0 & inw`wv'==1
replace r`wv'lvsn2ft=0 if bm060a==2
replace r`wv'lvsn2ft=1 if bm060a==1
label variable r`wv'lvsn2ft "r`wv'lvsn2ft:w`wv' r see light & count fingers 2 ft in front - left eye"
label values r`wv'lvsn2ft yesnon
*Spouse
gen s`wv'lvsn2ft=.
spouse r`wv'lvsn2ft, result(s`wv'lvsn2ft) wave(`wv')
label variable s`wv'lvsn2ft "s`wv'lvsn2ft:w`wv' s see light & count fingers 2 ft in front - left eye"
label values s`wv'lvsn2ft yesnon

***See light & count fingers 2ft - right eye
gen r`wv'rvsn2ft=.
missing_lasi bm060b, result(r`wv'rvsn2ft) wave(`wv')
replace r`wv'rvsn2ft=.s if inw`wv'pm==0 & inw`wv'==1
replace r`wv'rvsn2ft=0 if bm060b==2
replace r`wv'rvsn2ft=1 if bm060b==1
label variable r`wv'rvsn2ft "r`wv'rvsn2ft:w`wv' r see light & count fingers 2ft in front - right eye"
label values r`wv'rvsn2ft yesnon
*spouse
gen s`wv'rvsn2ft=.
spouse r`wv'rvsn2ft, result(s`wv'rvsn2ft) wave(`wv')
label variable s`wv'rvsn2ft "s`wv'rvsn2ft:w`wv' s see light & count fingers 2ft in front - right eye"
label values s`wv'rvsn2ft yesnon

***Distance vision - left eye
gen r`wv'lvsndst = .
replace r`wv'lvsndst=.m if inlist(bm061,".e","") & inw`wv'==1
missing_lasi bm060a, result(r`wv'lvsndst) wave(`wv')
replace r`wv'lvsndst=.s if inw`wv'pm==0 & inw`wv'==1
replace r`wv'lvsndst=1 if bm061=="20/20"
replace r`wv'lvsndst=2 if bm061=="20/25"
replace r`wv'lvsndst=3 if bm061=="20/32"
replace r`wv'lvsndst=4 if bm061=="20/40"
replace r`wv'lvsndst=5 if bm061=="20/50"
replace r`wv'lvsndst=6 if bm061=="20/63"
replace r`wv'lvsndst=7 if bm061=="20/80"
replace r`wv'lvsndst=8 if bm061=="20/100"
replace r`wv'lvsndst=9 if bm061=="20/125"
replace r`wv'lvsndst=10 if bm061=="20/160"
replace r`wv'lvsndst=11 if bm061=="20/200"
replace r`wv'lvsndst=12 if bm061=="20/250"
replace r`wv'lvsndst=13 if bm061=="20/320"
replace r`wv'lvsndst=14 if bm061=="blind / NPL" | bm060a==2
label variable r`wv'lvsndst "r`wv'lvsndst:w`wv' r distance vision - left eye"
label values r`wv'lvsndst visiond
*spouse
gen s`wv'lvsndst=.
spouse r`wv'lvsndst, result(s`wv'lvsndst) wave(`wv')
label variable s`wv'lvsndst "s`wv'lvsndst:w`wv' s distance vision - left eye"
label values s`wv'lvsndst visiond

***Distance vision - right eye
gen r`wv'rvsndst = .
replace r`wv'rvsndst=.m if inlist(bm062,".e","") & inw`wv'==1
missing_lasi bm060b, result(r`wv'rvsndst) wave(`wv')
replace r`wv'rvsndst=.s if inw`wv'pm==0 & inw`wv'==1
replace r`wv'rvsndst=1 if bm062=="20/20"
replace r`wv'rvsndst=2 if bm062=="20/25"
replace r`wv'rvsndst=3 if bm062=="20/32"
replace r`wv'rvsndst=4 if bm062=="20/40"
replace r`wv'rvsndst=5 if bm062=="20/50"
replace r`wv'rvsndst=6 if bm062=="20/63"
replace r`wv'rvsndst=7 if bm062=="20/80"
replace r`wv'rvsndst=8 if bm062=="20/100"
replace r`wv'rvsndst=9 if bm062=="20/125"
replace r`wv'rvsndst=10 if bm062=="20/160"
replace r`wv'rvsndst=11 if bm062=="20/200"
replace r`wv'rvsndst=12 if bm062=="20/250"
replace r`wv'rvsndst=13 if bm062=="20/320"
replace r`wv'rvsndst=14 if bm062=="blind / NPL" | bm060b==2
label variable r`wv'rvsndst "r`wv'rvsndst:w`wv' r distance vision - right eye"
label values r`wv'rvsndst visiond
*spouse
gen s`wv'rvsndst=.
spouse r`wv'rvsndst, result(s`wv'rvsndst) wave(`wv')
label variable s`wv'rvsndst "s`wv'rvsndst:w`wv' s distance vision - right eye"
label values s`wv'rvsndst visiond

***Distance visual impairment in better eye***
gen r`wv'dstvi = .
replace r`wv'dstvi=.m if inlist(bm062,".e","") & inw`wv'==1
missing_lasi bm060a bm060b r`wv'rvsndst r`wv'lvsndst, result(r`wv'dstvi) wave(`wv')
replace r`wv'dstvi=.s if inw`wv'pm==0 & inw`wv'==1
replace r`wv'dstvi=4 if inlist(r`wv'lvsndst,12,13,14) | inlist(r`wv'rvsndst,12,13,14)
replace r`wv'dstvi=3 if inlist(r`wv'lvsndst,6,7,8,9,10,11) | inlist(r`wv'rvsndst,6,7,8,9,10,11)
replace r`wv'dstvi=2 if r`wv'lvsndst==5 | r`wv'rvsndst==5
replace r`wv'dstvi=1 if inlist(r`wv'lvsndst,1,2,3,4) | inlist(r`wv'rvsndst,1,2,3,4)
label variable r`wv'dstvi "r`wv'dstvi:w`wv' r distance visual impairment in better eye"
label values r`wv'dstvi visioncat

*spouse
gen s`wv'dstvi = .
spouse r`wv'dstvi, result(s`wv'dstvi) wave(`wv')
label variable s`wv'dstvi "s`wv'dstvi:w`wv' s distance visual impairment in better eye"
label values s`wv'dstvi visioncat

***Near vision - left eye
gen r`wv'lvsnnr = .
replace r`wv'lvsnnr=.m if inlist(bm063,".e","") & inw`wv'==1
missing_lasi bm060a, result(r`wv'lvsnnr) wave(`wv')
replace r`wv'lvsnnr=.s if inw`wv'pm==0 & inw`wv'==1
replace r`wv'lvsnnr=1 if bm063=="20/20"
replace r`wv'lvsnnr=2 if bm063=="20/25"
replace r`wv'lvsnnr=3 if bm063=="20/32"
replace r`wv'lvsnnr=4 if bm063=="20/40"
replace r`wv'lvsnnr=5 if bm063=="20/50"
replace r`wv'lvsnnr=6 if bm063=="20/63"
replace r`wv'lvsnnr=7 if bm063=="20/80"
replace r`wv'lvsnnr=8 if bm063=="20/100"
replace r`wv'lvsnnr=9 if bm063=="20/125"
replace r`wv'lvsnnr=10 if bm063=="20/160"
replace r`wv'lvsnnr=11 if bm063=="20/250"
replace r`wv'lvsnnr=12 if bm063=="20/320"
replace r`wv'lvsnnr=13 if bm063=="20/400"
replace r`wv'lvsnnr=14 if bm063=="blind/NPL" | bm060a==2
label variable r`wv'lvsnnr "r`wv'lvsnnr:w`wv' r near vision - left eye"
label values r`wv'lvsnnr visionn
*spouse
gen s`wv'lvsnnr=.
spouse r`wv'lvsnnr, result(s`wv'lvsnnr) wave(`wv')
label variable s`wv'lvsnnr "s`wv'lvsnnr:w`wv' s near vision - left eye"
label values s`wv'lvsnnr visionn

***Near vision - right eye
gen r`wv'rvsnnr = .
replace r`wv'rvsnnr=.m if inlist(bm064,".e","") & inw`wv'==1
missing_lasi bm060b, result(r`wv'rvsnnr) wave(`wv')
replace r`wv'rvsnnr=.s if inw`wv'pm==0 & inw`wv'==1
replace r`wv'rvsnnr=1 if bm064=="20/20"
replace r`wv'rvsnnr=2 if bm064=="20/25"
replace r`wv'rvsnnr=3 if bm064=="20/32"
replace r`wv'rvsnnr=4 if bm064=="20/40"
replace r`wv'rvsnnr=5 if bm064=="20/50"
replace r`wv'rvsnnr=6 if bm064=="20/63"
replace r`wv'rvsnnr=7 if bm064=="20/80"
replace r`wv'rvsnnr=8 if bm064=="20/100"
replace r`wv'rvsnnr=9 if bm064=="20/125"
replace r`wv'rvsnnr=10 if bm064=="20/160"
replace r`wv'rvsnnr=11 if bm064=="20/250"
replace r`wv'rvsnnr=12 if bm064=="20/320"
replace r`wv'rvsnnr=13 if bm064=="20/400"
replace r`wv'rvsnnr=14 if bm064=="blind/NPL" | bm060b==2
label variable r`wv'rvsnnr "r`wv'rvsnnr:w`wv' r near vision - right eye"
label values r`wv'rvsnnr visionn
*spouse
gen s`wv'rvsnnr=.
spouse r`wv'rvsnnr, result(s`wv'rvsnnr) wave(`wv')
label variable s`wv'rvsnnr "s`wv'rvsnnr:w`wv' s near vision - right eye"
label values s`wv'rvsnnr visionn

***Near visual impairment***
gen r`wv'nrvi = .
replace r`wv'nrvi=.m if inlist(bm062,".e","") & inw`wv'==1
missing_lasi bm060a bm060b r`wv'lvsnnr r`wv'rvsnnr, result(r`wv'nrvi) wave(`wv')
replace r`wv'nrvi=.s if inw`wv'pm==0 & inw`wv'==1
replace r`wv'nrvi=4 if inlist(r`wv'lvsnnr,11,12,13,14) | inlist(r`wv'rvsnnr,11,12,13,14)
replace r`wv'nrvi=3 if inlist(r`wv'lvsnnr,6,7,8,9,10) | inlist(r`wv'rvsnnr,6,7,8,9,10)
replace r`wv'nrvi=2 if r`wv'lvsnnr==5 | r`wv'rvsnnr==5
replace r`wv'nrvi=1 if inlist(r`wv'lvsnnr,1,2,3,4) | inlist(r`wv'rvsnnr,1,2,3,4)
label variable r`wv'nrvi "r`wv'nrvi:w`wv' r near visual impairment in better eye"
label values r`wv'nrvi visioncat

*spouse
gen s`wv'nrvi = .
spouse r`wv'nrvi, result(s`wv'nrvi) wave(`wv')
label variable s`wv'nrvi "s`wv'nrvi:w`wv' s near visual impairment in better eye"
label values s`wv'nrvi visioncat

***uncorrected presbyopia***
gen r`wv'uprsbyp = .
missing_lasi r`wv'dstvi r`wv'nrvi, result(r`wv'uprsbyp) wave(`wv')
replace r`wv'uprsbyp = .s if inw`wv'pm==0 & inw`wv'==1
replace r`wv'uprsbyp = 0 if inrange(r`wv'dstvi,2,4) //distance vision in better eye worse than 20/40
replace r`wv'uprsbyp = 0 if r`wv'dstvi==1 & r`wv'nrvi==1 //distance vision in better eye better than/equal to 20/40 and near vision in better eye better than/equal to 20/40
replace r`wv'uprsbyp = 1 if r`wv'dstvi==1 & inrange(r`wv'nrvi,2,4) //distance vision in better eye better than/equal to 20/40 and near vision in better eye worse than 20/40
label variable r`wv'uprsbyp "r`wv'uprsbyp:w`wv' r uncorrected presbyopia"
label values r`wv'uprsbyp yesnon

*spouse
gen s`wv'uprsbyp = .
spouse r`wv'uprsbyp, result(s`wv'uprsbyp) wave(`wv')
label variable s`wv'uprsbyp "s`wv'uprsbyp:w`wv' s uncorrected presbyopia"
label values s`wv'uprsbyp yesnon

***How compliant during vision tests
gen r`wv'vsncompl=.
missing_lasi bm065 bm060a bm060b, result(r`wv'vsncompl) wave(`wv')
replace r`wv'vsncompl=.s if inw`wv'pm==0 & inw`wv'==1
replace r`wv'vsncompl=.n if (bm060a==2 & bm060b==2)
replace r`wv'vsncompl=bm065 if inrange(bm065,1,3)
label variable r`wv'vsncompl "r`wv'vsncompl:w`wv' r compliance during vision test"
label values r`wv'vsncompl compli
*Spouse
gen s`wv'vsncompl=.
spouse r`wv'vsncompl, result(s`wv'vsncompl) wave(`wv')
label variable s`wv'vsncompl "s`wv'vsncompl:w`wv' s compliance during vision test"
label values s`wv'vsncompl compli


***************************************



***drop LAsI wave 1 file raw variables***
drop `phys_w1_ind' 


*yesnocare
label define yesnocare ///
		0 "0.no" ///
		1 "1.yes" ///
		.d ".d:DK" ///
		.r ".r:Refuse" /// 
		.m ".m:Missing" ///
		.s ".s:no spouse/partner" ///
		.c ".c:no children" ///
		.k ".k:no grandchildren" /// 
		.l ".l:no spouse/partner/children/grandchildren" /// 
		.u ".u:Unmar" ///
		.v ".v:Sp Nr"

*yesnohelper
label define yesnohelper ///
		0 "0.no" ///
		1 "1.yes" ///
		.d ".d:DK" ///
		.r ".r:Refuse" ///
		.m ".m:Missing" ///
		.h ".h:no help received" ///
		.x ".x:no difficulty" ///
		.s ".s:can't determine relationship" ///
		.u ".u:Unmar" ///
		.v ".v:Sp Nr" 



*set wave number 
local wv=1

***merge with individual file***
local care_w1_ind ht401 ht402 ht403 ht404 ht405 ht406 ht407 ht408 ht409 ht410 ht411 ht412 ///
									ht413 ht414 ht415 ht416 ht417 ht418 ht419 ht420 ht421 ht422 ht423 ht424 ///
									ht426 ht426_hh ht427 ht428 ht429 ht430 fs407 fs408  ///
									fs411 fs414 fs201 fs213 fs215 fs216

merge 1:1 prim_key using "$wave_1_ind_bm", keepusing(`care_w1_ind') nogen

***merge with raw individual file***
local care_w1_raw_ind fs203*
merge 1:1 prim_key using "$wave_1_raw_ind", keepusing(`care_w1_raw_ind') nogen

***merge with cover screen data
local care_w1_cv cv003_* cv013_* 
merge m:1 hhid using "$wave_1_cv", keepusing(`care_w1_cv')
drop if _merge==2
drop _merge 

*********************************************************************
***Whether anyone helps with ADL or IADL*** - NOT AVAILABLE IN LASI
*********************************************************************
*LASI does not have questions on whether anyone helps R per ADL/IADL activity 

**********************************************************************
***Whether Uses Personal Aids***
**********************************************************************
*Not creating this section for LASI

*********************************************************************
***ADLs/IADLs: Receives Any Care***
*********************************************************************
***No difficulty for ADLS/IADLS
*Code of 1 indicates that respondent answered "Not having difficulty" to any ADL/IADL questions 
gen nodiff=.
replace nodiff=.d if ht401==.d | ht402==.d | ht403==.d | ht404==.d | ht405==.d | ht406==.d | ///
										 ht407==.d | ht408==.d | ht409==.d | ht410==.d | ht411==.d | ht412==.d | ht413==.d
replace nodiff=0 if ht401==1 | ht402==1 | ht403==1 | ht404==1 | ht405==1 | ht406==1 | ///
										ht407==1 | ht408==1 | ht409==1 | ht410==1 | ht411==1 | ht412==1 | ht413==1
replace nodiff=1 if ht401==2 & ht402==2 & ht403==2 & ht404==2 & ht405==2 & ht406==2 & ///
										ht407==2 & ht408==2 & ht409==2 & ht410==2 & ht411==2 & ht412==2 & ht413==2 

***Received any care for ADL/IADL 
*Answered only if R says Yes to any ADL/IADL questions (no mobility questions) 
gen r`wv'rcany=.
missing_lasi ht424 nodiff, result(r`wv'rcany) wave(`wv')
replace r`wv'rcany=.x if nodiff==1 //no difficulty 
replace r`wv'rcany=0 if ht424==2
replace r`wv'rcany=1 if ht424==1
label variable r`wv'rcany "r`wv'rcany:w`wv' r receives any care for adls/iadls"
label values r`wv'rcany yesnohelper

*Spouse
gen s`wv'rcany=.
spouse r`wv'rcany, result(s`wv'rcany) wave(`wv')
label variable s`wv'rcany "s`wv'rcany:w`wv' s receives any care for adls/iadls"
label values s`wv'rcany yesnohelper


*********************************************************************
***For helpers household member***
*********************************************************************
***Determining whether respondent reported themself
gen rself = .
replace rself = 0 if ht426_hh!=pn & ht424==1 //reported someone other than self
replace rself = 1 if ht426_hh==pn & ht424==1 //reported self

***Determining whether respondent is the household head 
*Replace with 1 if respondent id isn't equal to household head or household head's spouse
gen hhhdsp = .
forvalues i = 1/35 {
	replace hhhdsp = 0 if pn==`i' & !inlist(cv003_`i',1,2,13) & ht424==1 & rself==0 //not hh head or spouse & received help & didn't report self
}
forvalues i = 1/35 {
	replace hhhdsp = 1 if pn==`i' & inlist(cv003_`i',1,2,13) & ht424==1 & rself==0 //hh head or spouse & received help & didn't report self
}

***obtain spouse pn
gen spn = substr(s`wv'prim_key,-2,.) if ht424==1
destring spn, replace

*********************************************************************
***Spouse helper for ADLS/IADLS***
*********************************************************************

***Any spouse helper for adls/iadls (current or former) - spouse, ex-spouse, live-in-partner  
*Since we have spouse household member IDs, don't need to worry about coding .s if nothh==1
gen r`wv'rscare_l=.
missing_lasi ht424 ht426_hh ht427 nodiff r`wv'rcany, result(r`wv'rscare_l) wave(`wv')
replace r`wv'rscare_l=.x if nodiff==1
replace r`wv'rscare_l=.h if r`wv'rcany==0
replace r`wv'rscare_l=.s if hhhdsp==0
replace r`wv'rscare_l=0 if inrange(ht427,2,15) | ht427==17 //outside of hh help
forvalues i=1/35 {
	replace r`wv'rscare_l=0 if ht426_hh==`i' & (inrange(cv003_`i',3,12) | inlist(cv003_`i',14,15)) & hhhdsp==1
} //helper id doesn't fall within categories for hh head or spouse
replace r`wv'rscare_l=1 if inlist(ht427,1,16)  
forvalues i=1/35 {
	replace r`wv'rscare_l=1 if ht426_hh==`i' & inlist(cv003_`i',1,2,13) & hhhdsp==1
} //helper id does fall within categories for hh head or spouse
replace r`wv'rscare_l=1 if ht426_hh==spn & inrange(ht426_hh,1,20) & rself==0 //to catch spouses with spouse helper id
label variable r`wv'rscare_l "r`wv'rscare_l:w`wv' r receives informal care most from spouse for adls/iadls"
label values r`wv'rscare_l yesnohelper

*Spouse
gen s`wv'rscare_l=.
spouse r`wv'rscare_l, result(s`wv'rscare_l) wave(`wv')
label variable s`wv'rscare_l "s`wv'rscare_l:w`wv' s receives informal care most from spouse for adls/iadls"
label values s`wv'rscare_l yesnohelper

***Whether spouse missing values for days per month help for adls/iadls
*No need to create for all vars

***Any spouse helper, days per month received care
gen r`wv'rscaredpm_l=.
missing_lasi r`wv'rscare_l ht428, result(r`wv'rscaredpm_l) wave(`wv')
replace r`wv'rscaredpm_l=.x if nodiff==1
replace r`wv'rscaredpm_l=.h if r`wv'rcany==0
replace r`wv'rscaredpm_l=.s if hhhdsp==0
replace r`wv'rscaredpm_l=0 if r`wv'rscare_l==0 
replace r`wv'rscaredpm_l=ht428 if r`wv'rscare_l==1 & inrange(ht428,0,31) 
label variable r`wv'rscaredpm_l "r`wv'rscaredpm_l:w`wv' days/month spouse helps r with adls/iadls"

*Spouse
gen s`wv'rscaredpm_l=.
spouse r`wv'rscaredpm_l, result(s`wv'rscaredpm_l) wave(`wv')
label variable s`wv'rscaredpm_l "s`wv'rscaredpm_l:w`wv' days/month spouse helps s with adls/iadls"
 
***Any spouse helper, hours per day received care  
gen r`wv'rscarehr_l=.
missing_lasi r`wv'rscare_l ht429, result(r`wv'rscarehr_l) wave(`wv')
replace r`wv'rscarehr_l=.x if nodiff==1
replace r`wv'rscarehr_l=.h if r`wv'rcany==0
replace r`wv'rscarehr_l=.s if hhhdsp==0
replace r`wv'rscarehr_l=0 if r`wv'rscare_l==0
replace r`wv'rscarehr_l=ht429 if r`wv'rscare_l==1 & inrange(ht429,0,24)
label variable r`wv'rscarehr_l "r`wv'rscarehr_l:w`wv' hours/day spouse helps r with adls/iadls"

*Spouse
gen s`wv'rscarehr_l=.
spouse r`wv'rscarehr_l, result(s`wv'rscarehr_l) wave(`wv')
label variable s`wv'rscarehr_l "s`wv'rscarehr_l:w`wv' hours/day spouse helps s with adls/iadls"

***Any spouse helper, paid
gen r`wv'rscarepd_l=.
missing_lasi r`wv'rscare_l ht430, result(r`wv'rscarepd_l) wave(`wv')
replace r`wv'rscarepd_l=.x if nodiff==1
replace r`wv'rscarepd_l=.h if r`wv'rcany==0
replace r`wv'rscarepd_l=.s if hhhdsp==0
replace r`wv'rscarepd_l=0 if r`wv'rscare_l==0 | (r`wv'rscare_l==1 & ht430==2)
replace r`wv'rscarepd_l=1 if r`wv'rscare_l==1 & ht430==1 
label variable r`wv'rscarepd_l "r`wv'rscarepd_l:w`wv' whether spouse paid for care given to r"
label values r`wv'rscarepd_l yesnohelper 

*Spouse
gen s`wv'rscarepd_l=.
spouse r`wv'rscarepd_l, result(s`wv'rscarepd_l) wave(`wv')
label variable s`wv'rscarepd_l "s`wv'rscarepd_l:w`wv' whether spouse paid for care given to s"
label values s`wv'rscarepd_l yesnohelper 

 
**********************************************************************
***Kids/Grandkids helper for ADLS/IADLS***
**********************************************************************

***Any kids/grandkids helper for adls/iadls
*Since we have children household member ID, don't need to code .s if nothh==1
gen r`wv'rccare_l=.
missing_lasi ht424 ht426_hh ht427 nodiff r`wv'rcany, result(r`wv'rccare_l) wave(`wv')
replace r`wv'rccare_l=.x if nodiff==1
replace r`wv'rccare_l=.h if r`wv'rcany==0
replace r`wv'rccare_l=.s if hhhdsp==0
replace r`wv'rccare_l=0 if ht427==1 | inrange(ht427,5,17) 
forvalues i=1/35 {
	replace r`wv'rccare_l=0 if ht426_hh==`i' & (inlist(cv003_`i',1,2) | inrange(cv003_`i',7,15)) & hhhdsp==1
}
replace r`wv'rccare_l=1 if inrange(ht427,2,4)
forvalues i=1/35 {
	replace r`wv'rccare_l=1 if ht426_hh==`i' & inrange(cv003_`i',3,6) & hhhdsp==1
}
forvalues c=1/21 {
	replace r`wv'rccare_l=1 if ht426_hh==fs203_child_namehh_`c'_ & inrange(ht426_hh,1,20) & rself==0
}
label variable r`wv'rccare_l "r`wv'rccare_l:w`wv' r receives informal care most from kid/grandkid for adls/iadls"
label values r`wv'rccare_l yesnohelper

*Spouse
gen s`wv'rccare_l=.
spouse r`wv'rccare_l, result(s`wv'rccare_l) wave(`wv')
label variable s`wv'rccare_l "s`wv'rccare_l:w`wv' s receives informal care most from kid/grandkid for adls/iadls"
label values s`wv'rccare_l yesnohelper 

***Any kids/grandkids helper, days per month received care
gen r`wv'rccaredpm_l=.
missing_lasi r`wv'rccare_l ht428, result(r`wv'rccaredpm_l) wave(`wv')
replace r`wv'rccaredpm_l=.x if nodiff==1
replace r`wv'rccaredpm_l=.h if r`wv'rcany==0
replace r`wv'rccaredpm_l=.s if hhhdsp==0
replace r`wv'rccaredpm_l=0 if r`wv'rccare_l==0
replace r`wv'rccaredpm_l=ht428 if r`wv'rccare_l==1 & inrange(ht428,0,31)
label variable r`wv'rccaredpm_l "r`wv'rccaredpm_l:w`wv' days/month kid/grandkid helps r with adls/iadls"

*Spouse
gen s`wv'rccaredpm_l=.
spouse r`wv'rccaredpm_l, result(s`wv'rccaredpm_l) wave(`wv')
label variable s`wv'rccaredpm_l "s`wv'rccaredpm_l:w`wv' days/month kid/grandkid helps s with adls/iadls"

***Any kids/grandkids helper, hours per day received care 
gen r`wv'rccarehr_l=.
missing_lasi r`wv'rccare_l ht429, result(r`wv'rccarehr_l) wave(`wv')
replace r`wv'rccarehr_l=.x if nodiff==1
replace r`wv'rccarehr_l=.h if r`wv'rcany==0
replace r`wv'rccarehr_l=.s if hhhdsp==0
replace r`wv'rccarehr_l=0 if r`wv'rccare_l==0 
replace r`wv'rccarehr_l=ht429 if r`wv'rccare_l==1 & inrange(ht429,0,24)
label variable r`wv'rccarehr_l "r`wv'rccarehr_l:w`wv' hours/day kid/grandkid helps r with adls/iadls"

*Spouse
gen s`wv'rccarehr_l=.
spouse r`wv'rccarehr_l, result(s`wv'rccarehr_l) wave(`wv')
label variable s`wv'rccarehr_l "s`wv'rccarehr_l:w`wv' hours/day kid/grandkid helps s with adls/iadls"

***Any kids/grandkids helper, paid
gen r`wv'rccarepd_l=.
missing_lasi r`wv'rccare_l ht430, result(r`wv'rccarepd_l) wave(`wv')
replace r`wv'rccarepd_l=.x if nodiff==1
replace r`wv'rccarepd_l=.h if r`wv'rcany==0
replace r`wv'rccarepd_l=.s if hhhdsp==0
replace r`wv'rccarepd_l=0 if r`wv'rccare_l==0 | (r`wv'rccare_l==1 & ht430==2)
replace r`wv'rccarepd_l=1 if r`wv'rccare_l==1 & ht430==1
label variable r`wv'rccarepd_l "r`wv'rccarepd_l:w`wv' whether kid/grandkid paid for care given to r"
label values r`wv'rccarepd_l yesnohelper 
 
*Spouse
gen s`wv'rccarepd_l=.
spouse r`wv'rccarepd_l, result(s`wv'rccarepd_l) wave(`wv')
label variable s`wv'rccarepd_l "s`wv'rccarepd_l:w`wv' whether kid/grandkid paid for care given to s"
label values s`wv'rccarepd_l yesnohelper 


**********************************************************************
***Receives informal care from relatives***
**********************************************************************
***Any relative helper for adls/iadls
*Includes parents & siblings, but not spouse and kids/grandkids
gen r`wv'rrcare_l=.
missing_lasi ht426_hh ht427 nodiff r`wv'rcany, result(r`wv'rrcare_l) wave(`wv')
replace r`wv'rrcare_l=.x if nodiff==1
replace r`wv'rrcare_l=.h if r`wv'rcany==0
replace r`wv'rrcare_l=.s if hhhdsp==0
replace r`wv'rrcare_l=0 if inrange(ht427,1,4) | inrange(ht427,14,17)
forvalues i=1/35 {
	replace r`wv'rrcare_l=0 if ht426_hh==`i' & (inrange(cv003_`i',1,6) | inlist(cv003_`i',13,15)) & hhhdsp==1
}
replace r`wv'rrcare_l=1 if inrange(ht427,5,13) 
forvalues i=1/35 {
	replace r`wv'rrcare_l=1 if ht426_hh==`i' & (inrange(cv003_`i',7,12) | cv003_`i'==14) & hhhdsp==1
}
label variable r`wv'rrcare_l "r`wv'rrcare_l:w`wv' r receives informal care most from relative for adls/iadls" 
label values r`wv'rrcare_l yesnohelper

*Spouse
gen s`wv'rrcare_l=.
spouse r`wv'rrcare_l, result(s`wv'rrcare_l) wave(`wv')
label variable s`wv'rrcare_l "s`wv'rrcare_l:w`wv' s receives informal care most from relative for adls/iadls"
label values s`wv'rrcare_l yesnohelper

***Any relatives helper, days per month received care
gen r`wv'rrcaredpm_l=.
missing_lasi r`wv'rrcare_l ht428, result(r`wv'rrcaredpm_l) wave(`wv')
replace r`wv'rrcaredpm_l=.x if nodiff==1
replace r`wv'rrcaredpm_l=.h if r`wv'rcany==0
replace r`wv'rrcaredpm_l=.s if hhhdsp==0
replace r`wv'rrcaredpm_l=0 if r`wv'rrcare_l==0
replace r`wv'rrcaredpm_l=ht428 if r`wv'rrcare_l==1 & inrange(ht428,0,31)
label variable r`wv'rrcaredpm_l "r`wv'rrcaredpm_l:w`wv' days/month relative helps r with adls/iadls"

*Spouse
gen s`wv'rrcaredpm_l=.
spouse r`wv'rrcaredpm_l, result(s`wv'rrcaredpm_l) wave(`wv')
label variable s`wv'rrcaredpm_l "s`wv'rrcaredpm_l:w`wv' days/month relative helps s with adls/iadls"

***Any relatives helper, hours/day received care
gen r`wv'rrcarehr_l=.
missing_lasi r`wv'rrcare_l ht429, result(r`wv'rrcarehr_l) wave(`wv')
replace r`wv'rrcarehr_l=.x if nodiff==1
replace r`wv'rrcarehr_l=.h if r`wv'rcany==0
replace r`wv'rrcarehr_l=.s if hhhdsp==0
replace r`wv'rrcarehr_l=0 if r`wv'rrcare_l==0 
replace r`wv'rrcarehr_l=ht429 if r`wv'rrcare_l==1 & inrange(ht429,0,24)
label variable r`wv'rrcarehr_l "r`wv'rrcarehr_l:w`wv' hours/day relative helps r with adls/iadls"

*Spouse
gen s`wv'rrcarehr_l=.
spouse r`wv'rrcarehr_l, result(s`wv'rrcarehr_l) wave(`wv')
label variable s`wv'rrcarehr_l "s`wv'rrcarehr_l:w`wv' hours/day relative helps s with adls/iadls"  

***Any relatives helper, paid
gen r`wv'rrcarepd_l=.
missing_lasi r`wv'rrcare_l ht430, result(r`wv'rrcarepd_l) wave(`wv')
replace r`wv'rrcarepd_l=.x if nodiff==1
replace r`wv'rrcarepd_l=.h if r`wv'rcany==0
replace r`wv'rrcarepd_l=.s if hhhdsp==0 
replace r`wv'rrcarepd_l=0 if r`wv'rrcare_l==0 | (r`wv'rrcare_l==1 & ht430==2)
replace r`wv'rrcarepd_l=1 if r`wv'rrcare_l==1 & ht430==1
label variable r`wv'rrcarepd_l "r`wv'rrcarepd_l:w`wv' whether relative paid for care given to r"
label values r`wv'rrcarepd_l yesnohelper

*Spouse
gen s`wv'rrcarepd_l=.
spouse r`wv'rrcarepd_l, result(s`wv'rrcarepd_l) wave(`wv')
label variable s`wv'rrcarepd_l "s`wv'rrcarepd_l:w`wv' whether relative paid for care given to s"
label values s`wv'rrcarepd_l yesnohelper 


**********************************************************************
***Receives informal care from non-relative helpers***
**********************************************************************
***Any non-relative helpers (other, not related; other, not specified; non-professional paid person)
gen r`wv'rfcare_l=.
missing_lasi ht426_hh ht427 nodiff r`wv'rcany, result(r`wv'rfcare_l) wave(`wv')
replace r`wv'rfcare_l=.x if nodiff==1
replace r`wv'rfcare_l=.h if r`wv'rcany==0
replace r`wv'rfcare_l=.s if hhhdsp==0
replace r`wv'rfcare_l=0 if inrange(ht427,1,16)
forvalues i=1/35 {
	replace r`wv'rfcare_l=0 if ht426_hh==`i' & inrange(cv003_`i',1,14) & hhhdsp==1
}
replace r`wv'rfcare_l=1 if ht427==17
forvalues i=1/35 {
	replace r`wv'rfcare_l=1 if ht426_hh==`i' & cv003_`i'==15 & hhhdsp==1
}
label variable r`wv'rfcare_l "r`wv'rfcare_l:w`wv' r receives informal care most from non-relative for adls/iadls"
label values r`wv'rfcare_l yesnohelper

*Spouse
gen s`wv'rfcare_l=.
spouse r`wv'rfcare_l, result(s`wv'rfcare_l) wave(`wv')
label variable s`wv'rfcare_l "s`wv'rfcare_l:w`wv' s receives informal care most from non-relative for adls/iadls"
label values s`wv'rfcare_l yesnohelper

***Any non-relative helpers, days per month received help
gen r`wv'rfcaredpm_l=.
missing_lasi r`wv'rfcare_l ht428, result(r`wv'rfcaredpm_l) wave(`wv')
replace r`wv'rfcaredpm_l=.x if nodiff==1
replace r`wv'rfcaredpm_l=.h if r`wv'rcany==0
replace r`wv'rfcaredpm_l=.s if hhhdsp==0
replace r`wv'rfcaredpm_l=0 if r`wv'rfcare_l==0
replace r`wv'rfcaredpm_l=ht428 if r`wv'rfcare_l==1 & inrange(ht428,0,31)
label variable r`wv'rfcaredpm_l "r`wv'rfcaredpm_l:w`wv' days/month non-relative helps r with adls/iadls"

*Spouse
gen s`wv'rfcaredpm_l=.
spouse r`wv'rfcaredpm_l, result(s`wv'rfcaredpm_l) wave(`wv')
label variable s`wv'rfcaredpm_l "s`wv'rfcaredpm_l:w`wv' days/month non-relative helps s with adls/iadls"

***Any non-relative helpers, hours per day received help 
gen r`wv'rfcarehr_l=.
missing_lasi r`wv'rfcare_l ht429, result(r`wv'rfcarehr_l) wave(`wv')
replace r`wv'rfcarehr_l=.x if nodiff==1
replace r`wv'rfcarehr_l=.h if r`wv'rcany==0
replace r`wv'rfcarehr_l=.s if hhhdsp==0
replace r`wv'rfcarehr_l=0 if r`wv'rfcare_l==0 
replace r`wv'rfcarehr_l=ht429 if r`wv'rfcare_l==1 & inrange(ht429,0,24)
label variable r`wv'rfcarehr_l "r`wv'rfcarehr_l:w`wv' hours/day non-relative helps r with adls/iadls"
 
*Spouse
gen s`wv'rfcarehr_l=.
spouse r`wv'rfcarehr_l, result(s`wv'rfcarehr_l) wave(`wv')
label variable s`wv'rfcarehr_l "s`wv'rfcarehr_l:w`wv' hours/day non-relative helps r with adls/iadls"

***Any non-relative helpers, paid
gen r`wv'rfcarepd_l=.
missing_lasi r`wv'rfcare_l ht430, result(r`wv'rfcarepd_l) wave(`wv')
replace r`wv'rfcarepd_l=.x if nodiff==1
replace r`wv'rfcarepd_l=.h if r`wv'rcany==0
replace r`wv'rfcarepd_l=.s if hhhdsp==0
replace r`wv'rfcarepd_l=0 if r`wv'rfcare_l==0 | (r`wv'rfcare_l==1 & ht430==2)
replace r`wv'rfcarepd_l=1 if r`wv'rfcare_l==1 & ht430==1
label variable r`wv'rfcarepd_l "r`wv'rfcarepd_l:w`wv' whether non-relative paid for care given to r"
label values r`wv'rfcarepd_l yesnohelper 

*Spouse
gen s`wv'rfcarepd_l=.
spouse r`wv'rfcarepd_l, result(s`wv'rfcarepd_l) wave(`wv')
label variable s`wv'rfcarepd_l "s`wv'rfcarepd_l:w`wv' whether non-relative paid for care given to s"
label values s`wv'rfcarepd_l yesnohelper 


**********************************************************************
***ADLs/IADLs: Whether received any informal care***
**********************************************************************
***Any informal care for ADLS/IADLS
gen r`wv'rcaany_l=.
missing_lasi r`wv'rscare_l r`wv'rccare_l r`wv'rrcare_l r`wv'rfcare_l, result(r`wv'rcaany_l) wave(`wv')
replace r`wv'rcaany_l=.x if nodiff==1
replace r`wv'rcaany_l=.s if hhhdsp==0
replace r`wv'rcaany_l=0 if r`wv'rcany==0
replace r`wv'rcaany_l=0 if r`wv'rscare_l==0 | r`wv'rccare_l==0 | r`wv'rrcare_l==0 | r`wv'rfcare_l==0
replace r`wv'rcaany_l=1 if r`wv'rscare_l==1 | r`wv'rccare_l==1 | r`wv'rrcare_l==1 | r`wv'rfcare_l==1
label variable r`wv'rcaany_l "r`wv'rcaany_l:w`wv' r receives informal care most for adls/iadls"
label values r`wv'rcaany_l yesnohelper

*Spouse
gen s`wv'rcaany_l=.
spouse r`wv'rcaany_l, result(s`wv'rcaany_l) wave(`wv')
label variable s`wv'rcaany_l "s`wv'rcaany_l:w`wv' s receives informal care most for adls/iadls"
label values s`wv'rcaany_l yesnohelper


*********************************************************************
***ADLs/IADLs: Whether received paid formal care***
*********************************************************************
***Any professional paid helper
gen r`wv'rpfcare_l=.
missing_lasi ht426_hh ht427 nodiff r`wv'rcany ht430, result(r`wv'rpfcare_l) wave(`wv')
replace r`wv'rpfcare_l=.x if nodiff==1
replace r`wv'rpfcare_l=.h if r`wv'rcany==0
replace r`wv'rpfcare_l=0 if inrange(ht427,1,13) | inrange(ht427,16,17) //captures informal care for helpers outside of household
forvalues i=1/35 {
	replace r`wv'rpfcare_l=0 if ht426_hh==`i' & inrange(cv003_`i',1,15)
}
replace r`wv'rpfcare_l=0 if inlist(ht427,14,15) & ht430==2 //captures professional help (unpaid)
replace r`wv'rpfcare_l=1 if inlist(ht427,14,15) & ht430==1
label variable r`wv'rpfcare_l "r`wv'rpfcare_l:w`wv' r receives formal care most from paid professional for adls/iadls"
label values r`wv'rpfcare_l yesnohelper 
 
*Spouse
gen s`wv'rpfcare_l=.
spouse r`wv'rpfcare_l, result(s`wv'rpfcare_l) wave(`wv')
label variable s`wv'rpfcare_l "s`wv'rpfcare_l:w`wv' s receives formal care most from paid professional for adls/iadls"
label values s`wv'rpfcare_l yesnohelper 

***Any professional paid helper, days per month received help
gen  r`wv'rpfcaredpm_l=.
missing_lasi r`wv'rpfcare_l ht428, result(r`wv'rpfcaredpm_l) wave(`wv')
replace r`wv'rpfcaredpm_l=.x if nodiff==1
replace r`wv'rpfcaredpm_l=.h if r`wv'rcany==0
replace r`wv'rpfcaredpm_l=0 if r`wv'rpfcare_l==0
replace r`wv'rpfcaredpm_l=ht428 if r`wv'rpfcare_l==1 & inrange(ht428,0,31)
label variable r`wv'rpfcaredpm_l "r`wv'rpfcaredpm_l:w`wv' days/month paid professional helps r with adls/iadls"

*Spouse
gen s`wv'rpfcaredpm_l=.
spouse r`wv'rpfcaredpm_l, result(s`wv'rpfcaredpm_l) wave(`wv')
label variable s`wv'rpfcaredpm_l "s`wv'rpfcaredpm_l:w`wv' days/month paid professional helps s with adls/iadls"

***Any profesional paid helper, hours / day received help
gen r`wv'rpfcarehr_l=.
missing_lasi r`wv'rpfcare_l ht429, result(r`wv'rpfcarehr_l) wave(`wv')
replace r`wv'rpfcarehr_l=.x if nodiff==1
replace r`wv'rpfcarehr_l=.h if r`wv'rcany==0
replace r`wv'rpfcarehr_l=0 if r`wv'rpfcare_l==0
replace r`wv'rpfcarehr_l=ht429 if r`wv'rpfcare_l==1 & inrange(ht429,0,24)
label variable r`wv'rpfcarehr_l "r`wv'rpfcarehr_l:w`wv' hours/day paid professional helps r with adls/iadls"

*Spouse
gen s`wv'rpfcarehr_l=.
spouse r`wv'rpfcarehr_l, result(s`wv'rpfcarehr_l) wave(`wv')
label variable s`wv'rpfcarehr_l "s`wv'rpfcarehr_l:w`wv' hours/day paid professional helps s with adls/iadls"


********************************************************************
***ADLS/IADLS: Whether received unpaid formal care***
********************************************************************
***Any professional unpaid helper
gen r`wv'rufcare_l=.
missing_lasi ht426_hh ht427 nodiff r`wv'rcany ht430, result(r`wv'rufcare_l) wave(`wv')
replace r`wv'rufcare_l=.x if nodiff==1
replace r`wv'rufcare_l=.h if r`wv'rcany==0
replace r`wv'rufcare_l=0 if inrange(ht427,1,13) | inrange(ht427,16,17)
forvalues i=1/35 {
	replace r`wv'rufcare_l=0 if ht426_hh==`i' & inrange(cv003_`i',1,15)
}
replace r`wv'rufcare_l=0 if inlist(ht427,14,15) & ht430==1 
replace r`wv'rufcare_l=1 if inlist(ht427,14,15) & ht430==2
label variable r`wv'rufcare_l "r`wv'rufcare_l:w`wv' r receives formal care most from unpaid professional for adls/iadls"
label values r`wv'rufcare_l yesnohelper

*Spouse
gen s`wv'rufcare_l=.
spouse r`wv'rufcare_l, result(s`wv'rufcare_l) wave(`wv')
label variable s`wv'rufcare_l "s`wv'rufcare_l:w`wv' s receives formal care most from unpaid professional for adls/iadls"
label values s`wv'rufcare_l yesnohelper

***Any professional unpaid helper, days/month helped
gen r`wv'rufcaredpm_l=.
missing_lasi r`wv'rufcare_l ht428, result(r`wv'rufcaredpm_l) wave(`wv')
replace r`wv'rufcaredpm_l=.x if nodiff==1
replace r`wv'rufcaredpm_l=.h if r`wv'rcany==0
replace r`wv'rufcaredpm_l=0 if r`wv'rufcare_l==0
replace r`wv'rufcaredpm_l=ht428 if r`wv'rufcare_l==1 & inrange(ht428,0,31)
label variable r`wv'rufcaredpm_l "r`wv'rufcaredpm_l:w`wv' days/month unpaid professional helps r with adls/iadls"

*Spouse
gen s`wv'rufcaredpm_l=.
spouse r`wv'rufcaredpm_l, result(s`wv'rufcaredpm_l) wave(`wv')
label variable s`wv'rufcaredpm_l "s`wv'rufcaredpm_l:w`wv' days/month unpaid professional helps s with adls/iadls"

***Any professional unpaid helper, hours/day helped
gen r`wv'rufcarehr_l=.
missing_lasi r`wv'rufcare_l ht429, result(r`wv'rufcarehr_l) wave(`wv')
replace r`wv'rufcarehr_l=.x if nodiff==1
replace r`wv'rufcarehr_l=.h if r`wv'rcany==0
replace r`wv'rufcarehr_l=0 if r`wv'rufcare_l==0
replace r`wv'rufcarehr_l=ht429 if r`wv'rufcare_l==1 & inrange(ht429,0,24)
label variable r`wv'rufcarehr_l "r`wv'rufcarehr_l:w`wv' hours/day unpaid professional helps r with adls/iadls"

*Spouse
gen s`wv'rufcarehr_l=.
spouse r`wv'rufcarehr_l, result(s`wv'rufcarehr_l) wave(`wv')
label variable s`wv'rufcarehr_l "s`wv'rufcarehr_l:w`wv' hours/day unpaid professional helps s with adls/iadls"


*************************************************************
***ADLS/IADLS: Whether received any formal care***
*************************************************************
gen r`wv'rfaany_l=.
missing_lasi r`wv'rpfcare_l r`wv'rufcare_l, result(r`wv'rfaany_l) wave(`wv')
replace r`wv'rfaany_l=.x if nodiff==1
replace r`wv'rfaany_l=0 if r`wv'rcany==0
replace r`wv'rfaany_l=0 if r`wv'rpfcare_l==0 | r`wv'rufcare_l==0
replace r`wv'rfaany_l=1 if r`wv'rpfcare_l==1 | r`wv'rufcare_l==1
label variable r`wv'rfaany_l "r`wv'rfaany_l:w`wv' r receives formal care most for adls/iadls"
label values r`wv'rfaany_l yesnohelper

*Spouse
gen s`wv'rfaany_l=.
spouse r`wv'rfaany_l, result(s`wv'rfaany_l) wave(`wv')
label variable s`wv'rfaany_l "s`wv'rfaany_l:w`wv' s receives formal care most for adls/iadls"
label values s`wv'rfaany_l yesnohelper


*************************************************************
***Care Provided***
*************************************************************
***Provide care for spouse/partner 
gen r`wv'gascare_l=.
missing_lasi fs407 fs408 fs411 fs414, result(r`wv'gascare_l) wave(`wv')
replace r`wv'gascare_l=0 if inrange(r`wv'mstat,4,8) //no spouse/partner
replace r`wv'gascare_l=0 if inlist(r`wv'mstat,1,3) & fs407==2 //R is married but family does not need care
replace r`wv'gascare_l=0 if inlist(r`wv'mstat,1,3) & (fs408==2 & fs411==2) //R is married but does not provide care to family & outside of family
replace r`wv'gascare_l=0 if inlist(r`wv'mstat,1,3) & (fs408==1 | fs411==1) & inrange(fs414,2,7) //R is married but primary person cared for is not spouse/partner
replace r`wv'gascare_l=1 if inlist(r`wv'mstat,1,3) & (fs408==1 | fs411==1) & fs414==1 
label variable r`wv'gascare_l "r`wv'gascare_l:w`wv' r provides personal care to spouse"
label values r`wv'gascare_l yesnocare

*Spouse
gen s`wv'gascare_l=.
spouse r`wv'gascare_l, result(s`wv'gascare_l) wave(`wv')
label variable s`wv'gascare_l "s`wv'gascare_l:w`wv' s provides personal care to spouse" 
label values s`wv'gascare_l yesnocare 

***Provide care to children 
gen r`wv'gaccare_l=.
missing_lasi fs407 fs408 fs411 fs414, result(r`wv'gaccare_l) wave(`wv')
replace r`wv'gaccare_l=0 if fs201==0 //no children alive
replace r`wv'gaccare_l=0 if inrange(fs201,1,20) & fs407==2 
replace r`wv'gaccare_l=0 if inrange(fs201,1,20) & (fs408==2 & fs411==2) 
replace r`wv'gaccare_l=0 if inrange(fs201,1,20) & (fs408==1 | fs411==1) & inlist(fs414,1,2,3,4,6,7)
replace r`wv'gaccare_l=1 if inrange(fs201,1,20) & (fs408==1 | fs411==1) & fs414==5
label variable r`wv'gaccare_l "r`wv'gaccare_l:w`wv' r provides personal care to children"
label values r`wv'gaccare_l yesnocare

*Spouse
gen s`wv'gaccare_l=.
spouse r`wv'gaccare_l, result(s`wv'gaccare_l) wave(`wv')
label variable s`wv'gaccare_l "s`wv'gaccare_l:w`wv' s provides personal care to children"
label values s`wv'gaccare_l yesnocare

***Provide care to grandchildren
gen r`wv'gksit=.
missing_lasi fs213 fs215, result(r`wv'gksit) wave(`wv')
replace r`wv'gksit=0 if fs213==2 //no grandchildren
replace r`wv'gksit=0 if fs213==1 & fs215==2
replace r`wv'gksit=1 if fs213==1 & fs215==1
label variable r`wv'gksit "r`wv'gksit:w`wv' r looks after grandchildren"
label values r`wv'gksit yesnocare

*Spouse
gen s`wv'gksit=.
spouse r`wv'gksit, result(s`wv'gksit) wave(`wv')
label variable s`wv'gksit "s`wv'gksit:w`wv' s looks after grandchildren"
label values s`wv'gksit yesnocare
 
***Provide care to parents, parents-in-law
gen r`wv'gapcare_l=.
missing_lasi fs407 fs408 fs411 fs414, result(r`wv'gapcare_l) wave(`wv')
replace r`wv'gapcare_l=0 if fs407==2
replace r`wv'gapcare_l=0 if fs408==2 & fs411==2
replace r`wv'gapcare_l=0 if (fs408==1 | fs411==1) & inlist(fs414,1,4,5,6,7)
replace r`wv'gapcare_l=1 if (fs408==1 | fs411==1) & inlist(fs414,2,3)
label variable r`wv'gapcare_l "r`wv'gapcare_l:w`wv' r provides personal care to parents"
label values r`wv'gapcare_l yesnocare

*Spouse
gen s`wv'gapcare_l=.
spouse r`wv'gapcare_l, result(s`wv'gapcare_l) wave(`wv')
label variable s`wv'gapcare_l "s`wv'gapcare_l:w`wv' s provides personal care to parents"
label values s`wv'gapcare_l yesnocare 
 
***Provide care to siblings
gen r`wv'gabcare_l=.
missing_lasi fs407 fs408 fs411 fs414, result(r`wv'gabcare_l) wave(`wv')
replace r`wv'gabcare_l=0 if fs407==2
replace r`wv'gabcare_l=0 if fs408==2 & fs411==2
replace r`wv'gabcare_l=0 if (fs408==1 | fs411==1) & inlist(fs414,1,2,3,5,6,7)
replace r`wv'gabcare_l=1 if (fs408==1 | fs411==1) & fs414==4
label variable r`wv'gabcare_l "r`wv'gabcare_l:w`wv' r provides personal care to siblings"
label values r`wv'gabcare_l yesnocare

*Spouse
gen s`wv'gabcare_l=.
spouse r`wv'gabcare_l, result(s`wv'gabcare_l) wave(`wv')
label variable s`wv'gabcare_l "s`wv'gabcare_l:w`wv' s provides personal care to siblings"
label values s`wv'gabcare_l yesnocare 

***Provide care to relatives
*Include parents, parents-in-law, brothers/sister, other relatives
gen r`wv'garcare_l=.
missing_lasi fs407 fs408 fs411 fs414, result(r`wv'garcare_l) wave(`wv')
replace r`wv'garcare_l=0 if fs407==2
replace r`wv'garcare_l=0 if fs408==2 & fs411==2
replace r`wv'garcare_l=0 if (fs408==1 | fs411==1) & inlist(fs414,1,5,7)
replace r`wv'garcare_l=1 if (fs408==1 | fs411==1) & inlist(fs414,2,3,4,6)
label variable r`wv'garcare_l "r`wv'garcare_l:w`wv' r provides personal care to relatives"
label values r`wv'garcare_l yesnocare

*Spouse
gen s`wv'garcare_l=.
spouse r`wv'garcare_l, result(s`wv'garcare_l) wave(`wv')
label variable s`wv'garcare_l "s`wv'garcare_l:w`wv' s provides personal care to relatives"
label values s`wv'garcare_l yesnocare 



***Provide care to non-relatives
gen r`wv'gafcare_l=.
missing_lasi fs407 fs408 fs411 fs414, result(r`wv'gafcare_l) wave(`wv')
replace r`wv'gafcare_l=0 if fs407==2
replace r`wv'gafcare_l=0 if fs408==2 & fs411==2
replace r`wv'gafcare_l=0 if (fs408==1 | fs411==1) & inrange(fs414,1,6)
replace r`wv'gafcare_l=1 if (fs408==1 | fs411==1) & fs414==7
label variable r`wv'gafcare_l "r`wv'gafcare_l:w`wv' r provides personal care to non-relatives"
label values r`wv'gafcare_l yesnocare

*Spouse
gen s`wv'gafcare_l=.
spouse r`wv'gafcare_l, result(s`wv'gafcare_l) wave(`wv')
label variable s`wv'gafcare_l "s`wv'gafcare_l:w`wv' s provides personal care to non-relatives"
label values s`wv'gafcare_l yesnocare

***Provide any informal care
gen r`wv'gacare=.
missing_lasi fs407 fs408 fs411 r`wv'gksit, result(r`wv'gacare)
replace r`wv'gacare=0 if fs407==2 | (fs408==2 & fs411==2) 
replace r`wv'gacare=1 if fs408==1 | fs411==1
label variable r`wv'gacare "r`wv'gacare:w`wv' r provides any personal care"
label values r`wv'gacare yesnocare

*Spouse
gen s`wv'gacare=.
spouse r`wv'gacare, result(s`wv'gacare) wave(`wv')
label variable s`wv'gacare "s`wv'gacare:w`wv' s provides any personal care"
label values s`wv'gacare yesnocare


***Drop***
drop nodiff spn rself hhhdsp

*************************


***drop LASI wave 1 indivudal file raw variables***
drop `care_w1_ind' 

***drop LASI Wave 1 raw indivudal file raw variables***
drop `care_w1_raw_ind '

***drop wave 1 cover screen file raw variables***
drop `care_w1_cv'




****mental health****
label define cesdd ///
    1 "1.Rarely or never (< 1 day)"  ///
    2 "2.Sometimes (1-2 days)"  ///
    3 "3.Often (3-4 days)"  ///
    4 "4.Most or all of the time (5-7 days)"  ///
    .d ".d:DK"  ///
    .r ".r:RF"  ///
    .m ".m:oth missing" ///
    .p ".p:proxy"
   
***CESD yes no***
label define yesnocesd /// 
    0 "0.no" ///
    1 "1.yes" ///
    .m ".m:oth missing" ///
    .d ".d:DK" ///
    .r ".r:RF" ///
    .p ".p:Proxy" ///
    .a ".a:skipped-subsection" ///
    .b ".b:skipped-activity" ///
    .u ".u:Unmar" ///
    .v ".v:Sp Nr" 
    
****CIDI****
label define cidid /// 
    0 "0.no" ///
    1 "1.yes" ///
    .m ".m:oth missing" ///
    .d ".d:DK" ///
    .r ".r:RF" ///
    .p ".p:Proxy" ///
    .x ".x:does not have condition" ///
    .s ".s:Skipped" ///
    .u ".u:Unmar" ///
    .v ".v:Sp Nr" ///
    .t ".t:meds, two conditions"

****Satisfaction with Life Scale 7-point****
label define lifeagree /// 
		1 "1.strongly disagree" /// 
		2 "2.disagree" /// 
		3 "3.slightly disagree" /// 
		4 "4.neither agree nor disagree" /// 
		5 "5.slightly agree" /// 
		6 "6.agree" /// 
		7 "7.strongly agree" /// 
		.m ".m:oth missing" /// 
		.d ".d:DK" /// 
		.r ".r:RF" /// 
		.p ".p:proxy" /// 
		.u ".u:Unmar" /// 
		.v ".v:Sp Nr" 
		
****Satisfaction with Life Scale 3-point****
label define lifeagree3 /// 
		1 "1.disagree" /// 
		2 "2.neither agree nor disagree" /// 
		3 "3.agree" /// 
		.m ".m:oth missing" /// 
		.d ".d:DK" /// 
		.r ".r:RF" /// 
		.p ".p:proxy" /// 
		.u ".u:Unmar" /// 
		.v ".v:Sp Nr" 

****Single life satisfaction question****
label define singsat /// 
		1 "1.completely satisfied" /// 
		2 "2.very satisfied" /// 
		3 "3.somewhat satisfied" /// 
		4 "4.not very satisfied" /// 
		5 "5.not at all satisfied" /// 
		.d ".d:DK" /// 
		.r ".r:RF" /// 
		.m ".m:oth missing" /// 
		.u ".u:Unmar" /// 
		.v ".v:Sp Nr" ///
		.p ".p:proxy"

****Domain-Specific Satisfaction question****
label define satarea ///
	1 "1.strongly satisfied" ///
	2 "2.satisfied" ///
	3 "3.neither satisfied nor dissatisfied" ///
	4 "4.dissatisfied" ///
	5 "5.strongly dissatisfied" ///
	.p ".p:proxy"
	
	
****Day Reconstruction****
	label define dayofweek ///
	1 "1.Monday" ///
	2 "2.Tuesday" ///
	3 "3.Wednesday" ///
	4 "4.Thursday" ///
	5 "5.Friday" ///
	6 "6.Saturday" ///
	7 "7.Sunday" ///
	.p ".p:Proxy" ///
  .a ".a:skipped-subsection"
	
	label define normday ///
	1 "1.unusually good" ///
	2 "2.normal" ///
	3 "3.unusually bad" ///
	.p ".p:Proxy" ///
  .a ".a:skipped-subsection"
	
	****Well-being Yesterday****
	label define fdegree ///
	1 "1.not at all" ///
	2 "2.a little" ///
	3 "3.somewhat" ///
	4 "4.quite a bit" ///
	5 "5.very" ///
	.p ".p:Proxy" ///
  .a ".a:skipped-subsection"
	
****Pain Yesterday****
label define pdegree ///
	1 "1.none" ///
	2 "2.a little" ///
	3 "3.some" ///
	4 "4.quite a bit" ///
	5 "5.a lot" ///
	.p ".p:Proxy" ///
  .a ".a:skipped-subsection"
	

*set wave number
local wv=1

***merge with  data***
local psy_w1_ind	mh126 fs701 fs702 fs703 fs704 fs705 fs706 fs707 /// 
									fs708 fs709 fs710 mh201 mh202 mh203 mh204 mh205 /// 
									mh206 mh207 mh208 mh209 mh210 mh211 mh212 mh213 /// 
									mh214 mh215 mh216 mh217 mh218 mh219 mh220 mh221 mh222 ///
									fs609a fs609b fs609c fs609d fs609e fs329 fs612 rproxy dm002 ///
									tu004 tu001 tu002 tu008 tu003 ///
									tu006_1 tu006_2 tu006_3 tu006_4 tu006_5 tu006_6 tu006_7 /// 
									tu006_8 tu006_9 tu006_10 tu006_11 tu007 ///
									tu013_1 tu018_1 tu022_1 tu026_1 tu030_1 tu034_1 tu038_1 ///
									tu013_2 tu018_2 tu022_2 tu026_2 tu030_2 tu034_2 tu038_2 ///
									tu013_3 tu018_3 tu022_3 tu026_3 tu030_3 tu034_3 tu038_3 ///
									tu013_4 tu018_4 tu022_4 tu026_4 tu030_4 tu034_4 tu038_4 ///
									tu010 tu011_hour tu011_minute tu014 tu017_hour tu017_minute ///
									tu020 tu021_hour tu021_minute tu024 tu025_hour tu025_minute ///
									tu028 tu029_hour tu029_minute tu032 tu033_hour tu033_minute ///
									tu036 tu037_hour tu037_minute ///
									tu009 ee001 ee002 es001_1 es002_1 ev001 ev002
									
									
merge 1:1 prim_key using "$wave_1_ind_bm", keepusing(`psy_w1_ind') nogen



*********************************************************************
***Mental Health (cesd10 score)***
*********************************************************************

***Trouble concentrating
gen r`wv'mindtsl=.
missing_lasi fs701, result(r`wv'mindtsl) wave(`wv')
replace r`wv'mindtsl=.p if fs701==. & inrange(mh126,1,3)
replace r`wv'mindtsl=fs701 if inrange(fs701,1,4)
label variable r`wv'mindtsl "r`wv'mindtsl:w`wv' r CESD: had trouble concentrating"
label values r`wv'mindtsl cesdd
*spouse 
gen s`wv'mindtsl=.
spouse r`wv'mindtsl , result(s`wv'mindtsl) wave(`wv')
label variable s`wv'mindtsl "s`wv'mindtsl:w`wv' s CESD: had trouble concentrating"
label values s`wv'mindtsl cesdd

***Feel depressed
gen r`wv'depresl=.
missing_lasi fs702, result(r`wv'depresl) wave(`wv')
replace r`wv'depresl=.p if fs702==. & inrange(mh126,1,3)
replace r`wv'depresl=fs702 if inrange(fs702,1,4)
label variable r`wv'depresl "r`wv'depresl:w`wv' r CESD: felt depressed"
label values r`wv'depresl cesdd
*spouse
gen s`wv'depresl=.
spouse r`wv'depresl , result(s`wv'depresl) wave(`wv')
label variable s`wv'depresl "s`wv'depresl:w`wv' s CESD: felt depressed"
label values s`wv'depresl cesdd

***Feel tired or low energy
gen r`wv'ftiredl=.
missing_lasi fs703, result(r`wv'ftiredl) wave(`wv')
replace r`wv'ftiredl=.p if fs703==. & inrange(mh126,1,3)
replace r`wv'ftiredl=fs703 if inrange(fs703,1,4)
label variable r`wv'ftiredl "r`wv'ftiredl:w`wv' r CESD: felt tired or low energy"
label values r`wv'ftiredl cesdd
*spouse 
gen s`wv'ftiredl=.
spouse r`wv'ftiredl , result(s`wv'ftiredl) wave(`wv')
label variable s`wv'ftiredl "s`wv'ftiredl:w`wv' s CESD: felt tired or low energy"
label values s`wv'ftiredl cesdd

***Feel afraid of something
gen r`wv'fearfll=.
missing_lasi fs704, result(r`wv'fearfll) wave(`wv')
replace r`wv'fearfll=.p if fs704==. & inrange(mh126,1,3)
replace r`wv'fearfll=fs704 if inrange(fs704,1,4)
label variable r`wv'fearfll "r`wv'fearfll:w`wv' r CESD: felt afraid of something"
label values r`wv'fearfll cesdd
*spouse 
gen s`wv'fearfll=.
spouse r`wv'fearfll , result(s`wv'fearfll) wave(`wv')
label variable s`wv'fearfll "s`wv'fearfll:w`wv' s CESD: felt afraid of something"
label values s`wv'fearfll cesdd

***Feel overall satisfied
gen r`wv'fsatisl=.
missing_lasi fs705, result(r`wv'fsatisl) wave(`wv')
replace r`wv'fsatisl=.p if fs705==. & inrange(mh126,1,3)
replace r`wv'fsatisl=fs705 if inrange(fs705,1,4)
label variable r`wv'fsatisl "r`wv'fsatisl:w`wv' r CESD: felt overall satisfied"
label values r`wv'fsatisl cesdd
*spouse 
gen s`wv'fsatisl=.
spouse r`wv'fsatisl , result(s`wv'fsatisl) wave(`wv')
label variable s`wv'fsatisl "s`wv'fsatisl:w`wv' s CESD: felt overall satisfied"
label values s`wv'fsatisl cesdd

***Felt Lonely
gen r`wv'flonel=.
missing_lasi fs706, result(r`wv'flonel) wave(`wv')
replace r`wv'flonel=.p if fs706==. & inrange(mh126,1,3)
replace r`wv'flonel=fs706 if inrange(fs706,1,4)
label variable r`wv'flonel "r`wv'flonel:w`wv' r CESD: felt lonely"
label values r`wv'flonel cesdd
*spouse 
gen s`wv'flonel=.
spouse r`wv'flonel , result(s`wv'flonel) wave(`wv')
label variable s`wv'flonel "s`wv'flonel:w`wv' s CESD: felt lonely"
label values s`wv'flonel cesdd

***bothered by little things
gen r`wv'botherl=.
missing_lasi fs707, result(r`wv'botherl) wave(`wv')
replace r`wv'botherl=.p if fs707==. & inrange(mh126,1,3)
replace r`wv'botherl=fs707 if inrange(fs707,1,4)
label variable r`wv'botherl "r`wv'botherl:w`wv' r CESD: bothered by little things"
label values r`wv'botherl cesdd
*spouse 
gen s`wv'botherl=.
spouse r`wv'botherl , result(s`wv'botherl) wave(`wv')
label variable s`wv'botherl "s`wv'botherl:w`wv' s CESD: bothered by little things"
label values s`wv'botherl cesdd

***Everything an effort
gen r`wv'effortl=.
missing_lasi fs708, result(r`wv'effortl) wave(`wv')
replace r`wv'effortl=.p if fs708==. & inrange(mh126,1,3)
replace r`wv'effortl=fs708 if inrange(fs708,1,4)
label variable r`wv'effortl "r`wv'effortl:w`wv' r CESD: everything an effort"
label values r`wv'effortl cesdd
*spouse 
gen s`wv'effortl=.
spouse r`wv'effortl , result(s`wv'effortl) wave(`wv')
label variable s`wv'effortl "s`wv'effortl:w`wv' s CESD: everything an effort"
label values s`wv'effortl cesdd

***Feel hopeful about the future
gen r`wv'fhopel=.
missing_lasi fs709, result(r`wv'fhopel) wave(`wv')
replace r`wv'fhopel=.p if fs709==. & inrange(mh126,1,3)
replace r`wv'fhopel=fs709 if inrange(fs709,1,4)
label variable r`wv'fhopel "r`wv'fhopel:w`wv' r CESD: felt hopeful about the future"
label values r`wv'fhopel cesdd
*spouse
gen s`wv'fhopel=.
spouse r`wv'fhopel , result(s`wv'fhopel) wave(`wv')
label variable s`wv'fhopel "s`wv'fhopel:w`wv' s CESD: felt hopeful about the future"
label values s`wv'fhopel cesdd

***feel happy
gen r`wv'whappyl=.
missing_lasi fs710, result(r`wv'whappyl) wave(`wv')
replace r`wv'whappyl=.p if fs710==. & inrange(mh126,1,3)
replace r`wv'whappyl=fs710 if inrange(fs710,1,4)
label variable r`wv'whappyl "r`wv'whappyl:w`wv' r CESD: was happy"
label values r`wv'whappyl cesdd
*spouse 
gen s`wv'whappyl=.
spouse r`wv'whappyl , result(s`wv'whappyl) wave(`wv')
label variable s`wv'whappyl "s`wv'whappyl:w`wv' s CESD: was happy"
label values s`wv'whappyl cesdd


****CESD missing
*respondent CESD missing
egen r`wv'cesd10m=rowmiss(r`wv'mindtsl r`wv'depresl r`wv'effortl r`wv'ftiredl r`wv'whappyl r`wv'flonel r`wv'fsatisl r`wv'fearfll r`wv'botherl r`wv'fhopel) if inw`wv'==1
replace r`wv'cesd10m=.p if r`wv'mindtsl==.p & r`wv'depresl==.p & r`wv'effortl==.p & r`wv'whappyl==.p & r`wv'ftiredl==.p & r`wv'flonel==.p & r`wv'fsatisl==.p & r`wv'fearfll==.p & r`wv'fhopel==.p & r`wv'botherl==.p
label variable r`wv'cesd10m "r`wv'cesd10m:w`wv' r missings in CESD 10 score"
*spouse CESD missing
gen s`wv'cesd10m=.
spouse r`wv'cesd10m, result(s`wv'cesd10m) wave(`wv')
label variable s`wv'cesd10m "s`wv'cesd10m:w`wv' s missings in CESD 10 score"

*****CESD score
***recode the positive
recode r`wv'whappyl (1=4) (2=3) (3=2) (4=1), gen(xr`wv'whappyl)
recode r`wv'fhopel  (1=4) (2=3) (3=2) (4=1), gen(xr`wv'fhopel)	
recode r`wv'fsatisl (1=4) (2=3) (3=2) (4=1), gen(xr`wv'fsatisl)	
	
*total CESD score value 
foreach var in r`wv'mindtsl r`wv'depresl r`wv'effortl r`wv'ftiredl xr`wv'whappyl r`wv'flonel xr`wv'fsatisl r`wv'fearfll r`wv'botherl xr`wv'fhopel {
	gen `var'_scale=`var' - 1
}
*respondent CESD score
egen r`wv'cesd10=rowtotal(r`wv'mindtsl_scale r`wv'depresl_scale r`wv'effortl_scale r`wv'ftiredl_scale xr`wv'whappyl_scale r`wv'flonel_scale xr`wv'fsatisl_scale r`wv'fearfll_scale r`wv'botherl_scale xr`wv'fhopel_scale) if inrange(r`wv'cesd10m,0,9),m
replace r`wv'cesd10=.m if r`wv'cesd10m == 10 & (r`wv'mindtsl==.m | r`wv'depresl==.m | r`wv'effortl==.m | r`wv'whappyl==.m | r`wv'ftiredl==.m | r`wv'flonel==.m | r`wv'fsatisl==.m | r`wv'fearfll==.m | r`wv'fhopel==.m | r`wv'botherl==.m)
replace r`wv'cesd10=.d if r`wv'cesd10m == 10 & (r`wv'mindtsl==.d | r`wv'depresl==.d | r`wv'effortl==.d | r`wv'whappyl==.d | r`wv'ftiredl==.d | r`wv'flonel==.d | r`wv'fsatisl==.d | r`wv'fearfll==.d | r`wv'fhopel==.d | r`wv'botherl==.d)
replace r`wv'cesd10=.r if r`wv'cesd10m == 10 & (r`wv'mindtsl==.r | r`wv'depresl==.r | r`wv'effortl==.r | r`wv'whappyl==.r | r`wv'ftiredl==.r | r`wv'flonel==.r | r`wv'fsatisl==.r | r`wv'fearfll==.r | r`wv'fhopel==.r | r`wv'botherl==.r)
replace r`wv'cesd10=.p if r`wv'cesd10m == .p
label variable r`wv'cesd10 "r`wv'cesd10:w`wv' r CESD 10 score (0-30)"
*spouse 
gen s`wv'cesd10=. 
spouse r`wv'cesd10, result(s`wv'cesd10) wave(`wv')
label variable s`wv'cesd10 "s`wv'cesd10:w`wv' s CESD 10 score (0-30)"

drop xr`wv'whappyl xr`wv'fsatisl xr`wv'fhopel
drop r`wv'mindtsl_scale r`wv'depresl_scale r`wv'effortl_scale xr`wv'whappyl_scale r`wv'ftiredl_scale r`wv'flonel_scale xr`wv'fsatisl_scale r`wv'fearfll_scale xr`wv'fhopel_scale r`wv'botherl_scale


***CESD score (0-10 scale) - dichotomous scale

**first, let's recode: negative (0 = rarely or never & sometimes; 1=often & most or all of the time); positive (0=often & most or all of the time; 1=rarely or never& sometimes)
*negative
recode r`wv'mindtsl (1 2=0) (3 4=1), gen(x2r`wv'mindtsl)
recode r`wv'depresl (1 2=0) (3 4=1), gen(x2r`wv'depresl)
recode r`wv'effortl (1 2=0) (3 4=1), gen(x2r`wv'effortl)
recode r`wv'ftiredl (1 2=0) (3 4=1), gen(x2r`wv'ftiredl)
recode r`wv'flonel (1 2=0) (3 4=1), gen(x2r`wv'flonel)
recode r`wv'fearfll (1 2=0) (3 4=1), gen(x2r`wv'fearfll)
recode r`wv'botherl (1 2=0) (3 4=1), gen(x2r`wv'botherl)

*positive
recode r`wv'whappyl (3 4=0) (1 2=1), gen(x2r`wv'whappyl)
recode r`wv'fhopel (3 4=0) (1 2=1), gen(x2r`wv'fhopel)
recode r`wv'fsatisl (3 4=0) (1 2=1), gen(x2r`wv'fsatisl)

**total score (0-10), missing
egen r`wv'cesd10m_l=rowmiss(x2r`wv'mindtsl x2r`wv'depresl x2r`wv'effortl x2r`wv'ftiredl x2r`wv'flonel x2r`wv'fearfll x2r`wv'botherl x2r`wv'whappyl x2r`wv'fhopel x2r`wv'fsatisl) if inw`wv'==1
replace r`wv'cesd10m_l=.p if r`wv'mindtsl==.p & r`wv'depresl==.p & r`wv'effortl==.p & r`wv'ftiredl==.p & r`wv'flonel==.p & r`wv'fearfll==.p & r`wv'botherl==.p & r`wv'whappyl==.p & r`wv'fhopel==.p & r`wv'fsatisl==.p
label variable r`wv'cesd10m_l "r`wv'cesd10m_l:w`wv' r missings in CESD 10 score, dichotomous scale"
*spouse
gen s`wv'cesd10m_l=.
spouse r`wv'cesd10m_l, result(s`wv'cesd10m_l) wave(`wv')
label variable s`wv'cesd10m_l "s`wv'cesd10m_l:w`wv' s missings in CESD 10 score, dichotomous scale"

**total score (0-10)
egen r`wv'cesd10_l=rowtotal(x2r`wv'mindtsl x2r`wv'depresl x2r`wv'effortl x2r`wv'ftiredl x2r`wv'flonel x2r`wv'fearfll x2r`wv'botherl x2r`wv'whappyl x2r`wv'fhopel x2r`wv'fsatisl) if inrange(r`wv'cesd10m_l,0,9),m
replace r`wv'cesd10_l = .m if r`wv'cesd10m_l==10 & (r`wv'mindtsl==.m | r`wv'depresl==.m | r`wv'effortl==.m | r`wv'ftiredl==.m | r`wv'flonel==.m | r`wv'fearfll==.m | r`wv'botherl==.m | r`wv'whappyl==.m | r`wv'fhopel==.m | r`wv'fsatisl==.m)
replace r`wv'cesd10_l = .d if r`wv'cesd10m_l==10 & (r`wv'mindtsl==.d | r`wv'depresl==.d | r`wv'effortl==.d | r`wv'ftiredl==.d | r`wv'flonel==.d | r`wv'fearfll==.d | r`wv'botherl==.d | r`wv'whappyl==.d | r`wv'fhopel==.d | r`wv'fsatisl==.d)
replace r`wv'cesd10_l = .r if r`wv'cesd10m_l==10 & (r`wv'mindtsl==.r | r`wv'depresl==.r | r`wv'effortl==.r | r`wv'ftiredl==.r | r`wv'flonel==.r | r`wv'fearfll==.r | r`wv'botherl==.r | r`wv'whappyl==.r | r`wv'fhopel==.r | r`wv'fsatisl==.r)
replace r`wv'cesd10_l = .p if r`wv'cesd10m_l==.p
label variable r`wv'cesd10_l "r`wv'cesd10_l:w`wv' r CESD 10 score(0-10), dichotomous scale"
*spouse
gen s`wv'cesd10_l=.
spouse r`wv'cesd10_l, result(s`wv'cesd10_l) wave(`wv')
label variable s`wv'cesd10_l "s`wv'cesd10_l:w`wv' s CESD 10 score(0-10), dichotomous scale"

drop x2r`wv'mindtsl x2r`wv'depresl x2r`wv'effortl x2r`wv'ftiredl x2r`wv'flonel x2r`wv'fearfll x2r`wv'botherl x2r`wv'whappyl x2r`wv'fhopel x2r`wv'fsatisl

***CESD presence of depressive symptoms based on CESD 10 score(0-10)
gen r`wv'cesd10dep=.
missing_lasi r`wv'cesd10_l, result(r`wv'cesd10dep) wave(`wv')
replace r`wv'cesd10dep=.p if r`wv'cesd10_l==.p
replace r`wv'cesd10dep=0 if inrange(r`wv'cesd10_l,0,3)
replace r`wv'cesd10dep=1 if inrange(r`wv'cesd10_l,4,10)
label variable r`wv'cesd10dep "r`wv'cesd10dep:w`wv' r CESD presence of depressive symptoms (4+ symp), dichotomous scale"
label values r`wv'cesd10dep yesnocesd
*spouse
gen s`wv'cesd10dep=.
spouse r`wv'cesd10dep, result(s`wv'cesd10dep) wave(`wv')
label variable s`wv'cesd10dep "s`wv'cesd10dep:w`wv' s CESD presence of depressive symptoms (4+ symp), dichotomous scale"
label values s`wv'cesd10dep yesnocesd


**************
*****CIDI*****
**************
foreach var in mh204 mh205 mh208 mh209 mh210 ///
							 mh217 mh218 mh219 mh220 mh221 mh222 {
	recode `var' (2=0) (8 9 = .), gen(_`var')
}

*depressed most of the time
gen _mh201a = .
missing_lasi mh201 mh202 mh203, result(_mh201a) wave(`wv')
replace _mh201a = .p if inrange(mh126,1,3)
replace _mh201a = 0 if mh201==2 | inlist(mh202,3,4) | mh203==3
replace _mh201a = 1 if mh201==1 & inlist(mh202,1,2) & inlist(mh203,1,2)

*combined lose or increase appetite
gen _mh206a = .
missing_lasi mh206 mh207, result(_mh206a) wave(`wv')
replace _mh206a = 0 if mh206==2 | mh207==2
replace _mh206a = 1 if mh206==1 | mh207==1

*sleep problems every night/nearly every night 
gen _mh211a = .
missing_lasi mh211 mh212, result(_mh211a) wave(`wv')
replace _mh211a = 0 if mh211==2 | mh212==3
replace _mh211a = 1 if inlist(mh212,1,2)

*CIDI1 total score
egen _cidi1_totm = rowmiss(_mh204 _mh205 _mh206a _mh211a _mh208 _mh209 _mh210) if inw`wv'==1 & _mh201a==1
egen _cidi1_tot = rowtotal(_mh204 _mh205 _mh206a _mh211a _mh208 _mh209 _mh210) if inrange(_cidi1_totm,0,6),m

***CIDI depression symptom score***
*wave 1 respondent depression symptom score
gen r`wv'cididep = .
missing_lasi mh201 mh202 mh203 mh204 mh205 mh206 mh207 mh211 mh212 mh208 mh209 mh210, result(r`wv'cididep) wave(`wv')
replace r`wv'cididep = .p if inrange(mh126,1,3)
replace r`wv'cididep = .n if _mh201a==0
replace r`wv'cididep = _cidi1_tot if inrange(_cidi1_tot,0,7) & _mh201a==1
label variable r`wv'cididep "r`wv'cididep:w`wv' r CIDI depression stem symptom score (0-7)"
*wave 1 spouse
gen s`wv'cididep = .
spouse r`wv'cididep, result(s`wv'cididep) wave(`wv')
label variable s`wv'cididep "s`wv'cididep:w`wv' s CIDI depression stem symptom score (0-7)"

*wave 1 respondent depression symptom missing
gen r`wv'cididepm = .
replace r`wv'cididepm = .p if inrange(mh126,1,3)
replace r`wv'cididepm = .n if inlist(_mh201a,0,.d,.m,.r)
replace r`wv'cididepm = _cidi1_totm if inrange(_cidi1_totm,0,7) & _mh201a==1
label variable r`wv'cididepm "r`wv'cididepm:w`wv' r CIDI depression stem symptom missings"
*wave 1 spouse
gen s`wv'cididepm = .
spouse r`wv'cididepm, result(s`wv'cididepm) wave(`wv')
label variable s`wv'cididepm "s`wv'cididepm:w`wv' s CIDI depression stem symptom missings"

*loss of interest most of the time
gen _mh214a = .
missing_lasi mh214 mh215 mh216, result(_mh214a) wave(`wv')
replace _mh214a = .p if inrange(mh126,1,3)
replace _mh214a = 0 if mh214==2 | inlist(mh215,3,4) | mh216==3
replace _mh214a = 1 if mh214==1 & inlist(mh215,1,2) & inlist(mh216,1,2)

*CIDI2 total score 
egen _cidi2_totm = rowmiss(_mh214a _mh217 _mh218 _mh222 _mh219 _mh220 _mh221) if inw`wv'==1 & _mh214a==1
egen _cidi2_tot = rowtotal(_mh214a _mh217 _mh218 _mh222 _mh219 _mh220 _mh221) if inrange(_cidi2_totm,0,6),m

***CIDI anhedonia symptom score***
*wave 1 respondent anhedonia symptom score
gen r`wv'cidianh = .
missing_lasi _mh201a mh214 mh215 mh216 mh217 mh218 mh222 mh219 mh220 mh221, result(r`wv'cidianh) wave(`wv')
replace r`wv'cidianh = .p if inrange(mh126,1,3)
replace r`wv'cidianh = .n if _mh201a==1 | _mh214a==0
replace r`wv'cidianh = _cidi2_tot if inrange(_cidi2_tot,0,7) & _mh214a==1 & _mh201a==0
label variable r`wv'cidianh "r`wv'cidianh:w`wv' r CIDI anhedonia stem symptom score (0-7)"
*wave 1 spouse
gen s`wv'cidianh=.
spouse r`wv'cidianh, result(s`wv'cidianh) wave(`wv')
label variable s`wv'cidianh "s`wv'cidianh:w`wv' s CIDI anhedonia stem symptom score (0-7)"

*wave 1 respondent anhedonia symptom missing
gen r`wv'cidianhm = .
replace r`wv'cidianhm = .p if inrange(mh126,1,3)
replace r`wv'cidianhm = .n if inlist(_mh201a,1,.d,.m,.r) | inlist(_mh214a,0,.d,.m,.r)
replace r`wv'cidianhm = _cidi2_totm if inrange(_cidi2_totm,0,7) & _mh214a==1 & _mh201a==0
label variable r`wv'cidianhm "r`wv'cidianhm:w`wv' r CIDI anhedonia stem symptom missings"
*wave 1 spouse
gen s`wv'cidianhm = .
spouse r`wv'cidianhm, result(s`wv'cidianhm) wave(`wv')
label variable s`wv'cidianhm "s`wv'cidianhm:w`wv' s CIDI anhedonia stem symptom missings"

***CIDI total symptom score***
*wave 1 respondent total symptom score
gen r`wv'cidisymp = .
missing_lasi mh201 mh202 mh203 mh204 mh205 mh206 mh207 mh211 mh212 mh208 mh209 mh210 ///
				mh214 mh215 mh216 mh217 mh218 mh222 mh219 mh220 mh221, result(r`wv'cidisymp) wave(`wv')
replace r`wv'cidisymp = .p if inrange(mh126,1,3)
replace r`wv'cidisymp = 0 if _mh201a==0 & _mh214a==0
replace r`wv'cidisymp = _cidi1_tot if inrange(_cidi1_tot,0,7) & _mh201a==1
replace r`wv'cidisymp = _cidi2_tot if inrange(_cidi2_tot,0,7) & _mh214a==1
label variable r`wv'cidisymp "r`wv'cidisymp:w`wv' r CIDI total symptom score"
*wave 1 spouse
gen s`wv'cidisymp = .
spouse r`wv'cidisymp, result(s`wv'cidisymp) wave(`wv')
label variable s`wv'cidisymp "s`wv'cidisymp:w`wv' s CIDI total symptom score"

*wave 1 respondent total symptom score missing
gen r`wv'cidisympm = .
replace r`wv'cidisympm = .p if inrange(mh126,1,3)
replace r`wv'cidisympm = 0 if inlist(_mh201a,0,.d,.m,.r) & inlist(_mh214a,0,.d,.m,.r)
replace r`wv'cidisympm = _cidi1_totm if inrange(_cidi1_totm,0,7) & _mh201a==1
replace r`wv'cidisympm = _cidi2_totm if inrange(_cidi2_totm,0,7) & _mh214a==1
label variable r`wv'cidisympm "r`wv'cidisympm:w`wv' r CIDI total symptom missings"
*wave 1 spouse
gen s`wv'cidisympm = .
spouse r`wv'cidisympm, result(s`wv'cidisympm) wave(`wv')
label variable s`wv'cidisympm "s`wv'cidisympm:w`wv' s CIDI total symptom missings"
											
***CIDI major depressive episode 3 point***
*wave 1 respondent major depressive episode 3 point
gen r`wv'cidimde3 = .
missing_lasi mh201 mh202 mh203 mh204 mh205 mh206 mh207 mh211 mh212 mh208 mh209 mh210 ///
				mh214 mh215 mh216 mh217 mh218 mh222 mh219 mh220 mh221, result(r`wv'cidimde3) wave(`wv')
replace r`wv'cidimde3 = .p if inrange(mh126,1,3)
replace r`wv'cidimde3 = 0 if inrange(r`wv'cidisymp,0,2)
replace r`wv'cidimde3 = 1 if inrange(r`wv'cidisymp,3,7)
label variable r`wv'cidimde3 "r`wv'cidimde3:w`wv' r CIDI probable major depressive episode (3+ symp)"
label values r`wv'cidimde3 cidid
*wave 1 spouse major depressive episode 3 point
gen s`wv'cidimde3 = .
spouse r`wv'cidimde3, result(s`wv'cidimde3) wave(`wv')
label variable s`wv'cidimde3 "s`wv'cidimde3:w`wv' s CIDI probable major depressive episode (3+ symp)"
label values s`wv'cidimde3 cidid

***CIDI major depressive episode 5 point***
*wave 1 respondent major depressive episode 5 point
gen r`wv'cidimde5 = .
missing_lasi mh201 mh202 mh203 mh204 mh205 mh206 mh207 mh211 mh212 mh208 mh209 mh210 ///
				mh214 mh215 mh216 mh217 mh218 mh222 mh219 mh220 mh221, result(r`wv'cidimde5) wave(`wv')
replace r`wv'cidimde5 = .p if inrange(mh126,1,3)
replace r`wv'cidimde5 = 0 if inrange(r`wv'cidisymp,0,4)
replace r`wv'cidimde5 = 1 if inrange(r`wv'cidisymp,5,7)
label variable r`wv'cidimde5 "r`wv'cidimde5:w`wv' r CIDI probable major depressive episode (5+ symp)"
label values r`wv'cidimde5 cidid
*wave 1 spouse major depressive episode 5 point
gen s`wv'cidimde5 = .
spouse r`wv'cidimde5, result(s`wv'cidimde5) wave(`wv')
label variable s`wv'cidimde5 "s`wv'cidimde5:w`wv' s CIDI probable major depressive episode (5+ symp)"
label values s`wv'cidimde5 cidid

drop _cidi1_tot _cidi1_totm _cidi2_tot _cidi2_totm _mh*

**********************************************************************
****Major depressive episode (cidi_1 cidi_2 score)***
**********************************************************************
*
*foreach var in mh204 mh205 mh206 mh207 mh208 mh209 mh210 mh211 mh217 mh218 mh219 mh220 mh221 mh222 {
*	recode `var' (2=0), g(_`var')
*}
*
*****IIPS skip pattern is wrong: second set questions should only asked R who did not meet screen1
*gen _screen1=.
*replace _screen1=.m if inw`wv'==1
*replace _screen1=.d if mh201==.d
*replace _screen1=.r if mh201==.r
*replace _screen1=0 if mh201==2 | inlist(mh202,3,4) | mh203==3
*replace _screen1=1 if mh201==1 & inlist(mh202,1,2) & inlist(mh203,1,2)
*
***combined lose or increase appetite
*gen _mh206a=.
*replace _mh206a=.d if _mh206==.d | _mh207==.d
*replace _mh206a=0 if _mh206==0 | _mh207==0
*replace _mh206a=1 if _mh206==1 | _mh207==1
*
***MATHEW suggested not to use mh212 but HRS use; mh212 every night/nearly everynight 
*gen _mh212a=.
*replace _mh212a=.d if mh211==.d | mh212==.d
*replace _mh212a=0 if mh212==3 | mh211==2
*replace _mh212a=1 if inlist(mh212,1,2)
*
***CIDI1 total score
*egen _cidi1_totm=rowmiss(_mh204 _mh205 _mh206a _mh208 _mh209 _mh210 _mh212a) if inw`wv'==1
*egen _cidi1_tot=rowtotal(_mh204 _mh205 _mh206a _mh208 _mh209 _mh210 _mh212a) if inrange(_cidi1_totm,0,6),m
*
*gen r`wv'cidi1tot=.
*replace r`wv'cidi1tot=.m if inw`wv'==1
*replace r`wv'cidi1tot=.p if _cidi1_tot==. & inrange(mh126,1,3)
*replace r`wv'cidi1tot=.d if _screen1==.d
*replace r`wv'cidi1tot=.r if _screen1==.r
*replace r`wv'cidi1tot=0 if _screen1==0
*replace r`wv'cidi1tot=_cidi1_tot if _screen1==1 & inrange(_cidi1_tot,0,7)
*label variable r`wv'cidi1tot "r`wv'cidi1tot:w`wv' r probable major depressive episode score-symptom (0-7)"
*
**spouse
*gen s`wv'cidi1tot=.
*spouse r`wv'cidi1tot, result(s`wv'cidi1tot) wave(`wv')
*label variable s`wv'cidi1tot "s`wv'cidi1tot:w`wv' s probable major depressive episode score-symptom (0-7)"
*
****CIDI1 major depressive episode
*gen r`wv'cidi1md=.
*replace r`wv'cidi1md=.m if inw`wv'==1
*replace r`wv'cidi1md=.p if r`wv'cidi1tot==.p
*replace r`wv'cidi1md=.d if r`wv'cidi1tot==.d
*replace r`wv'cidi1md=.r if r`wv'cidi1tot==.r
*replace r`wv'cidi1md=0 if inrange(r`wv'cidi1tot,0,2)
*replace r`wv'cidi1md=1 if inrange(r`wv'cidi1tot,3,7)
*label variable r`wv'cidi1md "r`wv'cidi1md:w`wv' r probable major depressive episode-symptom (r`wv'cidi1tot>3)"
*label values r`wv'cidi1md cidid
*
**spouse
*gen s`wv'cidi1md=.
*spouse r`wv'cidi1md, result(s`wv'cidi1md) wave(`wv')
*label variable s`wv'cidi1md "s`wv'cidi1md:w`wv' s probable major depressive episode-symptom (s`wv'cidi1tot>3)"
*label values s`wv'cidi1md cidid
*
*******2nd set of questions should only ask if screen1=0 or missing
****use mh214, mh215, mh216 for lost interest question
*gen _mh214=.
*replace _mh214=.m if inw`wv'==1
*replace _mh214=0 if mh214==2 | inlist(mh215,3,4) | mh216==3
*replace _mh214=1 if mh214==1 & inlist(mh215,1,2) & inlist(mh216,1,2)
*
****CIDI2 total score
*egen _cidi2_totm=rowmiss(_mh214 _mh217 _mh218 _mh219 _mh220 _mh221 _mh222) if inw`wv'==1
*egen _cidi2_tot=rowtotal(_mh214 _mh217 _mh218 _mh219 _mh220 _mh221 _mh222) if inrange(_cidi2_totm,0,6),m
*replace _cidi2_tot=0 if _cidi2_tot==. & _screen1==0
*
*gen r`wv'cidi2tot=.
*replace r`wv'cidi2tot=.m if _screen1==.m
*replace r`wv'cidi2tot=.p if r`wv'cidi1tot==.p | (mh214==. & inrange(mh126,1,3))
*replace r`wv'cidi2tot=.d if _screen1==.d | mh214==.d
*replace r`wv'cidi2tot=.r if _screen1==.r | mh214==.r
*replace r`wv'cidi2tot=.s if _screen1==1
*replace r`wv'cidi2tot=0 if mh214==2 & _screen1==0 
*replace r`wv'cidi2tot=_cidi2_tot if _screen1==0
*label variable r`wv'cidi2tot "r`wv'cidi2tot:w`wv' r probable major depressive episode score-anhedonia (0-7)"
**Spouse
*gen s`wv'cidi2tot=.
*spouse r`wv'cidi2tot, result(s`wv'cidi2tot) wave(`wv')
*label variable s`wv'cidi2tot "s`wv'cidi2tot:w`wv' s probable major depressive episode score-anhedonia (0-7)"
*
****CIDI2 major depressive episode 
*gen r`wv'cidi2md=.
*replace r`wv'cidi2md=.m if r`wv'cidi2tot==.m
*replace r`wv'cidi2md=.p if r`wv'cidi2tot==.p
*replace r`wv'cidi2md=.d if r`wv'cidi2tot==.d
*replace r`wv'cidi2md=.r if r`wv'cidi2tot==.r
*replace r`wv'cidi2md=.s if r`wv'cidi2tot==.s
*replace r`wv'cidi2md=0 if inrange(r`wv'cidi2tot,0,2)
*replace r`wv'cidi2md=1 if inrange(r`wv'cidi2tot,3,7)
*label variable r`wv'cidi2md "r`wv'cidi2md:w`wv' r probable major depressive episode-anhedonia (r`wv'cidi2tot>3)"
*label values r`wv'cidi2md cidid
*
**Spouse
*gen s`wv'cidi2md=.
*spouse r`wv'cidi2md, result(s`wv'cidi2md) wave(`wv')
*label variable s`wv'cidi2md "s`wv'cidi2md:w`wv' s probable major depressive episode-anhedonia (s`wv'cidi2tot>3)"
*label values s`wv'cidi2md cidid 


*********************************************************************
***Satisfaction with Life Scale***
*********************************************************************
*Psychosocial section is skipped if proxy interview

*****7-point scores
***Life is close to ideal
gen r`wv'lideal = .
missing_lasi fs609a, result(r`wv'lideal) wave(`wv')
replace r`wv'lideal=.p if rproxy==1 //proxy interview
replace r`wv'lideal=fs609a if inrange(fs609a,1,7)
label variable r`wv'lideal "r`wv'lideal:w`wv' r life is close to ideal 7-point"
label values r`wv'lideal lifeagree

*Spouse
gen s`wv'lideal=.
spouse r`wv'lideal, result(s`wv'lideal) wave(`wv')
label variable s`wv'lideal "s`wv'lideal:w`wv' s life is close to ideal 7-point"
label values s`wv'lideal lifeagree

***Life conditions are excellent
gen r`wv'lexcl = .
missing_lasi fs609b, result(r`wv'lexcl) wave(`wv')
replace r`wv'lexcl=.p if rproxy==1
replace r`wv'lexcl=fs609b if inrange(fs609b,1,7)
label variable r`wv'lexcl "r`wv'lexcl:w`wv' r life conditions are excellent 7-point"
label values r`wv'lexcl lifeagree

*Spouse
gen s`wv'lexcl = .
spouse r`wv'lexcl, result(s`wv'lexcl) wave(`wv')
label variable s`wv'lexcl "s`wv'lexcl:w`wv' s life conditions are excellent 7-point"
label values s`wv'lexcl lifeagree

***Satisfied with life
gen r`wv'lstsf = .
missing_lasi fs609c, result(r`wv'lstsf) wave(`wv')
replace r`wv'lstsf=.p if rproxy==1
replace r`wv'lstsf=fs609c if inrange(fs609c,1,7)
label variable r`wv'lstsf "r`wv'lstsf:w`wv' r satisfied with life 7-point"
label values r`wv'lstsf lifeagree

*Spouse
gen s`wv'lstsf=.
spouse r`wv'lstsf, result(s`wv'lstsf) wave(`wv')
label variable s`wv'lstsf "s`wv'lstsf:w`wv' s satisfied with life 7-point"
label values s`wv'lstsf lifeagree

***Gotten important things in life
gen r`wv'limptt = .
missing_lasi fs609d, result(r`wv'limptt) wave(`wv')
replace r`wv'limptt=.p if rproxy==1
replace r`wv'limptt=fs609d if inrange(fs609d,1,7)
label variable r`wv'limptt "r`wv'limptt:w`wv' r gotten important things in life 7-point"
label values r`wv'limptt lifeagree

*Spouse
gen s`wv'limptt=.
spouse r`wv'limptt, result(s`wv'limptt) wave(`wv')
label variable s`wv'limptt "s`wv'limptt:w`wv' s gotten important things in life 7-point"
label values s`wv'limptt lifeagree

***Change almost nothing if lived again
gen r`wv'lchnot = .
missing_lasi fs609e, result(r`wv'lchnot) wave(`wv')
replace r`wv'lchnot=.p if rproxy==1
replace r`wv'lchnot=fs609e if inrange(fs609e,1,7)
label variable r`wv'lchnot "r`wv'lchnot:w`wv' r change almost nothing if lived again 7-point"
label values r`wv'lchnot lifeagree

*Spouse
gen s`wv'lchnot=.
spouse r`wv'lchnot, result(s`wv'lchnot) wave(`wv')
label variable s`wv'lchnot "s`wv'lchnot:w`wv' s change almost nothing if lived again 7-point"
label values s`wv'lchnot lifeagree

***Satisfaction with life scale missing count 7-point
egen r`wv'lsatscm = rowmiss(r`wv'lideal r`wv'lexcl r`wv'lstsf r`wv'limptt r`wv'lchnot) if inw`wv'==1
replace r`wv'lsatscm = .p if r`wv'lideal==.p & r`wv'lexcl==.p & r`wv'lstsf==.p & r`wv'limptt==.p & r`wv'lchnot==.p
label variable r`wv'lsatscm "r`wv'lsatscm:w`wv' r satisfaction with life scale 7-point score missing"

*Spouse
gen s`wv'lsatscm=.
spouse r`wv'lsatscm, result(s`wv'lsatscm) wave(`wv')
label variable s`wv'lsatscm "s`wv'lsatscm:w`wv' s satisfaction with life scale 7-point score missing"

***Satisfaction with life scale score 7-point
egen r`wv'lsatsc = rowmean(r`wv'lideal r`wv'lexcl r`wv'lstsf r`wv'limptt r`wv'lchnot) if inrange(r`wv'lsatscm,0,2)
replace r`wv'lsatsc=.m if inrange(r`wv'lsatscm,3,5)
replace r`wv'lsatsc=.p if r`wv'lsatscm==.p
label variable r`wv'lsatsc "r`wv'lsatsc:w`wv' r satisfaction with life scale 7-point score"

*Spouse
gen s`wv'lsatsc=.
spouse r`wv'lsatsc, result(s`wv'lsatsc) wave(`wv') 
label variable s`wv'lsatsc "s`wv'lsatsc:w`wv' s satisfaction with life scale 7-point score"

*****3-point scores
***Life is close to ideal 3-point
*wave 1 respondent
recode r`wv'lideal (1/3=1) (4=2) (4/7=3), gen(r`wv'lideal3)
label variable r`wv'lideal3 "r`wv'lideal3:w`wv' r life is close to ideal 3-point"
label values r`wv'lideal3 lifeagree3

*wave 1 spouse
gen s`wv'lideal3 = .
spouse r`wv'lideal3, result(s`wv'lideal3) wave(`wv')
label variable s`wv'lideal3 "s`wv'lideal3:w`wv' s life is close to ideal 3-point"
label values s`wv'lideal3 lifeagree3

***Life conditions are excellent 3-point
*wave 1 respondent
recode r`wv'lexcl (1/3=1) (4=2) (5/7=3), gen(r`wv'lexcl3)
label variable r`wv'lexcl3 "r`wv'lexcl3:w`wv' r life conditions are excellent 3-point"
label values r`wv'lexcl3 lifeagree3

*wave 1 spouse
gen s`wv'lexcl3 = .
spouse r`wv'lexcl3, result(s`wv'lexcl3) wave(`wv')
label variable s`wv'lexcl3 "s`wv'lexcl3:w`wv' s life conditions are excellent 3-point"
label values s`wv'lexcl3 lifeagree3

***Satisfied with life 3-point
*wave 1 respondent
recode r`wv'lstsf (1/3=1) (4=2) (5/7=3), gen(r`wv'lstsf3)
label variable r`wv'lstsf3 "r`wv'lstsf3:w`wv' r satisfied with life 3-point"
label values r`wv'lstsf3 lifeagree3

*wave 1 spouse
gen s`wv'lstsf3 = .
spouse r`wv'lstsf3, result(s`wv'lstsf3) wave(`wv')
label variable s`wv'lstsf3 "s`wv'lstsf3:w`wv' s satisfied with life 3-point"
label values s`wv'lstsf3 lifeagree3

***Gotten important things in life 3-point
*wave 1 respondent
recode r`wv'limptt (1/3=1) (4=2) (5/7=3), gen(r`wv'limptt3)
label variable r`wv'limptt3 "r`wv'limptt3:w`wv' r gotten important things in life 3-point"
label values r`wv'limptt3 lifeagree3

*wave 1 spouse
gen s`wv'limptt3 = .
spouse r`wv'limptt3, result(s`wv'limptt3) wave(`wv')
label variable s`wv'limptt3 "s`wv'limptt3:w`wv' s gotten important things in life 3-point"
label values s`wv'limptt3 lifeagree3

***Change almost nothing if lived again 3-point
*wave 1 respondent
recode r`wv'lchnot (1/3=1) (4=2) (5/7=3), gen(r`wv'lchnot3)
label variable r`wv'lchnot3 "r`wv'lchnot3:w`wv' r change almost nothing if lived again 3-point"
label values r`wv'lchnot3 lifeagree3

*wave 1 spouse
gen s`wv'lchnot3 = .
spouse r`wv'lchnot3, result(s`wv'lchnot3) wave(`wv')
label variable s`wv'lchnot3 "s`wv'lchnot3:w`wv' s change almost nothing if lived again 3-point"
label values s`wv'lchnot3 lifeagree3

***Satisfaction with life scale missing 3-point
egen r`wv'lsatsc3m = rowmiss(r`wv'lideal3 r`wv'lexcl3 r`wv'lstsf3 r`wv'limptt3 r`wv'lchnot3) if inw`wv'==1
replace r`wv'lsatsc3m = .p if r`wv'lideal3==.p & r`wv'lexcl3==.p & r`wv'lstsf3==.p & r`wv'limptt3==.p & r`wv'lchnot3==.p
label variable r`wv'lsatsc3m "r`wv'lsatsc3m:w`wv' r satisfaction with life scale 3-point score missings"

gen s`wv'lsatsc3m=.
spouse r`wv'lsatsc3m, result(s`wv'lsatsc3m) wave(`wv')
label variable s`wv'lsatsc3m "s`wv'lsatsc3m:w`wv' s satisfaction with life scale 3-point score missing"

***Satisfaction with life scale score 3-point
egen r`wv'lsatsc3 = rowmean(r`wv'lideal3 r`wv'lexcl3 r`wv'lstsf3 r`wv'limptt3 r`wv'lchnot3) if inrange(r`wv'lsatsc3m,0,2)
replace r`wv'lsatsc3 = .m if inrange(r`wv'lsatsc3m,3,5)
replace r`wv'lsatsc3 = .p if r`wv'lsatsc3m==.p
label variable r`wv'lsatsc3 "r`wv'lsatsc3:w`wv' r satisfaction with life scale 3-point score"

*Spouse
gen s`wv'lsatsc3=.
spouse r`wv'lsatsc3, result(s`wv'lsatsc3) wave(`wv')
label variable s`wv'lsatsc3 "s`wv'lsatsc3:w`wv' s satisfaction with life scale 3-point score"


*********************************************************************
***Satisfaction with Accommodation***
*********************************************************************

***satisfaction with current living arrangements
*wave 1 respondent
gen r`wv'sathome=.
missing_lasi fs329, result(r`wv'sathome) wave(`wv')
replace r`wv'sathome = .p if r`wv'proxy==1
replace r`wv'sathome = fs329 if inrange(fs329,1,5)
label variable r`wv'sathome "r`wv'sathome:w`wv' r satisfied with current living arrangements"
label values r`wv'sathome satarea

*wave 1 spouse
gen s`wv'sathome=.
spouse r`wv'sathome, result(s`wv'sathome) wave(`wv')
label variable s`wv'sathome "s`wv'sathome:w`wv' s satisfied with current living arrangements"
label values s`wv'sathome satarea


*********************************************************************
***Single Life Satisfaction Question***
*********************************************************************

***satisfaction with life as a whole
*wave 1 respondent
gen r`wv'satwlife=.
missing_lasi dm002, result(r`wv'satwlife) wave(`wv')
replace r`wv'satwlife = .p if r`wv'proxy==1
replace r`wv'satwlife=1 if dm002==1
replace r`wv'satwlife=2 if dm002==2
replace r`wv'satwlife=3 if dm002==3
replace r`wv'satwlife=4 if dm002==4
replace r`wv'satwlife=5 if dm002==5
label variable r`wv'satwlife "r`wv'satwlife:w`wv' r satisfied with life"
label values r`wv'satwlife singsat

*wave 1 spouse
gen s`wv'satwlife=.
spouse r`wv'satwlife, result(s`wv'satwlife) wave(`wv')
label variable s`wv'satwlife "s`wv'satwlife:w`wv' s satisfied with life"
label values s`wv'satwlife singsat

*********************************************************************
***Cantril Ladder***
*********************************************************************

*wave 1 respondent
gen r`wv'cantril = .
missing_lasi fs612, result(r`wv'cantril) wave(`wv')
replace r`wv'cantril = .p if rproxy==1 //proxy interview
replace r`wv'cantril = fs612 if inrange(fs612,1,10)
label variable r`wv'cantril "r`wv'cantril:w`wv' r cantril ladder rating"

*wave 1 spouse
gen s`wv'cantril = .
spouse r`wv'cantril, result(s`wv'cantril) wave(`wv')
label variable s`wv'cantril "s`wv'cantril:w`wv' s cantril ladder rating"


*********************************************************************
***Day Reconstruction***
*********************************************************************

***Day of Week***
*wave 1 respondent
generate double tu001_1 = clock(tu001, "hm")

gen r`wv'drday = .
missing_lasi tu004, result(r`wv'drday) wave(`wv')
replace r`wv'drday = .p if r`wv'proxy==1
replace r`wv'drday = .a if tu001_1==. & (ee001!=. | es001_1!=. | ev001!=.)
replace r`wv'drday = tu004 if inrange(tu004,1,7)
label variable r`wv'drday "r`wv'drday:w`wv' r day reconstruction day of week"
label values r`wv'drday dayofweek

*wave 1 spouse
gen s`wv'drday = .
spouse r`wv'drday, result(s`wv'drday) wave(`wv')
label variable s`wv'drday "s`wv'drday:w`wv' s day reconstruction day of week"
label values s`wv'drday dayofweek

***Time woke up***
*wave 1 respondent
gen r`wv'drwaketm = .
replace r`wv'drwaketm = .m if tu001_1==. & inw`wv'==1
replace r`wv'drwaketm = .d if tu001==".d"
replace r`wv'drwaketm = .r if tu001==".r"
replace r`wv'drwaketm = .p if r`wv'proxy==1
replace r`wv'drwaketm = .a if tu001_1==. & (ee001!=. | es001_1!=. | ev001!=.)
replace r`wv'drwaketm = tu001_1 if tu001_1!=.
label variable r`wv'drwaketm "r`wv'drwaketm:w`wv' r day reconstruction time woke up"
format r`wv'drwaketm %tcHH:MM:SS

*wave 1 spouse
gen s`wv'drwaketm = .
spouse r`wv'drwaketm, result(s`wv'drwaketm) wave(`wv')
label variable s`wv'drwaketm "s`wv'drwaketm:w`wv' s day reconstruction time woke up"
format s`wv'drwaketm %tcHH:MM:SS

***Time went to sleep***
*wave 1 respondent
generate double tu002_2 = clock(tu002, "hm")
gen r`wv'drsleeptm = .
replace r`wv'drsleeptm = .m if tu002_2==. & inw`wv'==1
replace r`wv'drsleeptm = .d if tu002==".d"
replace r`wv'drsleeptm = .r if tu002==".r"
replace r`wv'drsleeptm = .p if r`wv'proxy==1
replace r`wv'drsleeptm = .a if tu001_1==. & (ee001!=. | es001_1!=. | ev001!=.)
replace r`wv'drsleeptm = tu002_2 if tu002_2!=.
label variable r`wv'drsleeptm "r`wv'drsleeptm:w`wv' r day reconstruction time went to sleep"
format r`wv'drsleeptm %tcHH:MM:SS

*wave 1 spouse
gen s`wv'drsleeptm = .
spouse r`wv'drsleeptm, result(s`wv'drsleeptm) wave(`wv')
label variable s`wv'drsleeptm "s`wv'drsleeptm:w`wv' s day reconstruction time went to sleep"
format s`wv'drsleeptm %tcHH:MM:SS

***Felt well-rested***
*wave 1 respondent
gen r`wv'drwlrstd = .
missing_lasi tu008, result(r`wv'drwlrstd) wave(`wv')
replace r`wv'drwlrstd = .p if r`wv'proxy==1
replace r`wv'drwlrstd = .a if tu001_1==. & (ee001!=. | es001_1!=. | ev001!=.)
replace r`wv'drwlrstd = 0 if tu008==2
replace r`wv'drwlrstd = 1 if tu008==1
label variable r`wv'drwlrstd "r`wv'drwlrstd:w`wv' r day reconstruction felt well-rested in am"
label values r`wv'drwlrstd yesnocesd

*wave 1 spouse
gen s`wv'drwlrstd = .
spouse r`wv'drwlrstd, result(s`wv'drwlrstd) wave(`wv')
label variable s`wv'drwlrstd "s`wv'drwlrstd:w`wv' s day reconstruction felt well-rested in am"
label values s`wv'drwlrstd yesnocesd

***Normal day***
*wave 1 respondent
gen r`wv'drnrmlday = .
missing_lasi tu003, result(r`wv'drnrmlday) wave(`wv')
replace r`wv'drnrmlday = .p if r`wv'proxy==1
replace r`wv'drnrmlday = .a if tu001_1==. & (ee001!=. | es001_1!=. | ev001!=.)
replace r`wv'drnrmlday = 1 if tu003==3
replace r`wv'drnrmlday = 2 if tu003==1
replace r`wv'drnrmlday = 3 if tu003==2
label variable r`wv'drnrmlday "r`wv'drnrmlday:w`wv' r day reconstruction normal day"
label values r`wv'drnrmlday normday

*wave 1 spouse
gen s`wv'drnrmlday = .
spouse r`wv'drnrmlday, result(s`wv'drnrmlday) wave(`wv')
label variable s`wv'drnrmlday "s`wv'drnrmlday:w`wv' s day reconstruction normal day"
label values s`wv'drnrmlday normday

*********************************************************************
***Overall Experienced Well-being Yesterday***
*********************************************************************

***felt frustrated yesterday***
*wave 1 respondent
gen r`wv'ydfrust = .
missing_lasi tu006_1, result(r`wv'ydfrust) wave(`wv')
replace r`wv'ydfrust = .p if r`wv'proxy==1
replace r`wv'ydfrust = .a if tu001_1==. & (ee001!=. | es001_1!=. | ev001!=.)
replace r`wv'ydfrust = tu006_1 if inrange(tu006_1,1,5)
label variable r`wv'ydfrust "r`wv'ydfrust:w`wv' r felt frustrated yesterday"
label values r`wv'ydfrust fdegree

*wave 1 spouse
gen s`wv'ydfrust = .
spouse r`wv'ydfrust, result(s`wv'ydfrust) wave(`wv')
label variable s`wv'ydfrust "s`wv'ydfrust:w`wv' s felt frustrated yesterday"
label values s`wv'ydfrust fdegree

***felt sad yesterday***
*wave 1 respondent
gen r`wv'ydsad = .
missing_lasi tu006_2, result(r`wv'ydsad) wave(`wv')
replace r`wv'ydsad = .p if r`wv'proxy==1
replace r`wv'ydsad = .a if tu001_1==. & (ee001!=. | es001_1!=. | ev001!=.)
replace r`wv'ydsad = tu006_2 if inrange(tu006_2,1,5)
label variable r`wv'ydsad "r`wv'ydsad:w`wv' r felt sad yesterday"
label values r`wv'ydsad fdegree

*wave 1 spouse
gen s`wv'ydsad = .
spouse r`wv'ydsad, result(s`wv'ydsad) wave(`wv')
label variable s`wv'ydsad "s`wv'ydsad:w`wv' s felt sad yesterday"
label values s`wv'ydsad fdegree

***felt enthusiastic yesterday***
*wave 1 respondent
gen r`wv'ydenthu = .
missing_lasi tu006_3, result(r`wv'ydenthu) wave(`wv')
replace r`wv'ydenthu = .p if r`wv'proxy==1
replace r`wv'ydenthu = .a if tu001_1==. & (ee001!=. | es001_1!=. | ev001!=.)
replace r`wv'ydenthu = tu006_3 if inrange(tu006_3,1,5)
label variable r`wv'ydenthu "r`wv'ydenthu:w`wv' r felt enthusiastic yesterday"
label values r`wv'ydenthu fdegree

*wave 1 spouse
gen s`wv'ydenthu= .
spouse r`wv'ydenthu, result(s`wv'ydenthu) wave(`wv')
label variable s`wv'ydenthu "s`wv'ydenthu:w`wv' s felt enthusiastic yesterday"
label values s`wv'ydenthu fdegree

***felt lonely yesterday***
*wave 1 respondent
gen r`wv'ydlonely = .
missing_lasi tu006_4, result(r`wv'ydlonely) wave(`wv')
replace r`wv'ydlonely = .p if r`wv'proxy==1
replace r`wv'ydlonely = .a if tu001_1==. & (ee001!=. | es001_1!=. | ev001!=.)
replace r`wv'ydlonely = tu006_4 if inrange(tu006_4,1,5)
label variable r`wv'ydlonely "r`wv'ydlonely:w`wv' r felt lonely yesterday"
label values r`wv'ydlonely fdegree

*wave 1 spouse
gen s`wv'ydlonely = .
spouse r`wv'ydlonely, result(s`wv'ydlonely) wave(`wv')
label variable s`wv'ydlonely "s`wv'ydlonely:w`wv' s felt lonely yesterday"
label values s`wv'ydlonely fdegree

***felt content yesterday***
*wave 1 respondent
gen r`wv'ydcontent = .
missing_lasi tu006_5, result(r`wv'ydcontent) wave(`wv')
replace r`wv'ydcontent = .p if r`wv'proxy==1
replace r`wv'ydcontent = .a if tu001_1==. & (ee001!=. | es001_1!=. | ev001!=.)
replace r`wv'ydcontent = tu006_5 if inrange(tu006_5,1,5)
label variable r`wv'ydcontent "r`wv'ydcontent:w`wv' r felt content yesterday"
label values r`wv'ydcontent fdegree

*wave 1 spouse
gen s`wv'ydcontent = .
spouse r`wv'ydcontent, result(s`wv'ydcontent) wave(`wv')
label variable s`wv'ydcontent "s`wv'ydcontent:w`wv' s felt content yesterday"
label values s`wv'ydcontent fdegree

***felt worried yesterday***
*wave 1 respondent
gen r`wv'ydworry = .
missing_lasi tu006_6, result(r`wv'ydworry) wave(`wv')
replace r`wv'ydworry = .p if r`wv'proxy==1
replace r`wv'ydworry = .a if tu001_1==. & (ee001!=. | es001_1!=. | ev001!=.)
replace r`wv'ydworry = tu006_6 if inrange(tu006_6,1,5)
label variable r`wv'ydworry "r`wv'ydworry:w`wv' r felt worried yesterday"
label values r`wv'ydworry fdegree

*wave 1 spouse
gen s`wv'ydworry = .
spouse r`wv'ydworry, result(s`wv'ydworry) wave(`wv')
label variable s`wv'ydworry "s`wv'ydworry:w`wv' s felt worried yesterday"
label values s`wv'ydworry fdegree

***felt bored yesterday***
*wave 1 respondent
gen r`wv'ydbored = .
missing_lasi tu006_7, result(r`wv'ydbored) wave(`wv')
replace r`wv'ydbored = .p if r`wv'proxy==1
replace r`wv'ydbored = .a if tu001_1==. & (ee001!=. | es001_1!=. | ev001!=.)
replace r`wv'ydbored = tu006_7 if inrange(tu006_7,1,5)
label variable r`wv'ydbored "r`wv'ydbored:w`wv' r felt bored yesterday"
label values r`wv'ydbored fdegree

*wave 1 spouse
gen s`wv'ydbored = .
spouse r`wv'ydbored, result(s`wv'ydbored) wave(`wv')
label variable s`wv'ydbored "s`wv'ydbored:w`wv' s felt bored yesterday"
label values s`wv'ydbored fdegree

***felt happy yesterday***
*wave 1 respondent
gen r`wv'ydhappy = .
missing_lasi tu006_8, result(r`wv'ydhappy) wave(`wv')
replace r`wv'ydhappy = .p if r`wv'proxy==1
replace r`wv'ydhappy = .a if tu001_1==. & (ee001!=. | es001_1!=. | ev001!=.)
replace r`wv'ydhappy = tu006_8 if inrange(tu006_8,1,5)
label variable r`wv'ydhappy "r`wv'ydhappy:w`wv' r felt happy yesterday"
label values r`wv'ydhappy fdegree

*wave 1 spouse
gen s`wv'ydhappy = .
spouse r`wv'ydhappy, result(s`wv'ydhappy) wave(`wv')
label variable s`wv'ydhappy "s`wv'ydhappy:w`wv' s felt happy yesterday"
label values s`wv'ydhappy fdegree

***felt angry yesterday***
*wave 1 respondent
gen r`wv'ydangry = .
missing_lasi tu006_9, result(r`wv'ydangry) wave(`wv')
replace r`wv'ydangry = .p if r`wv'proxy==1
replace r`wv'ydangry = .a if tu001_1==. & (ee001!=. | es001_1!=. | ev001!=.)
replace r`wv'ydangry = tu006_9 if inrange(tu006_9,1,5)
label variable r`wv'ydangry "r`wv'ydangry:w`wv' r felt angry yesterday"
label values r`wv'ydangry fdegree

*wave 1 spouse
gen s`wv'ydangry = .
spouse r`wv'ydangry, result(s`wv'ydangry) wave(`wv')
label variable s`wv'ydangry "s`wv'ydangry:w`wv' s felt angry yesterday"
label values s`wv'ydangry fdegree

***felt tired yesterday***
*wave 1 respondent
gen r`wv'ydtired = .
missing_lasi tu006_10, result(r`wv'ydtired) wave(`wv')
replace r`wv'ydtired = .p if r`wv'proxy==1
replace r`wv'ydtired = .a if tu001_1==. & (ee001!=. | es001_1!=. | ev001!=.)
replace r`wv'ydtired = tu006_10 if inrange(tu006_10,1,5)
label variable r`wv'ydtired "r`wv'ydtired:w`wv' r felt tired yesterday"
label values r`wv'ydtired fdegree

*wave 1 spouse
gen s`wv'ydtired = .
spouse r`wv'ydtired, result(s`wv'ydtired) wave(`wv')
label variable s`wv'ydtired "s`wv'ydtired:w`wv' s felt tired yesterday"
label values s`wv'ydtired fdegree

***felt stressed yesterday***
*wave 1 respondent
gen r`wv'ydstress = .
missing_lasi tu006_11, result(r`wv'ydstress) wave(`wv')
replace r`wv'ydstress = .p if r`wv'proxy==1
replace r`wv'ydstress = .a if tu001_1==. & (ee001!=. | es001_1!=. | ev001!=.)
replace r`wv'ydstress = tu006_11 if inrange(tu006_11,1,5)
label variable r`wv'ydstress "r`wv'ydstress:w`wv' r felt stressed yesterday"
label values r`wv'ydstress fdegree

*wave 1 spouse
gen s`wv'ydstress = .
spouse r`wv'ydstress, result(s`wv'ydstress) wave(`wv')
label variable s`wv'ydstress "s`wv'ydstress:w`wv' s felt stressed yesterday"
label values s`wv'ydstress fdegree

***felt pain yesterday***
*wave 1 respondent
gen r`wv'ydpain = .
missing_lasi tu007, result(r`wv'ydpain) wave(`wv')
replace r`wv'ydpain = .p if r`wv'proxy==1
replace r`wv'ydpain = .a if tu001_1==. & (ee001!=. | es001_1!=. | ev001!=.)
replace r`wv'ydpain = tu007 if inrange(tu007,1,5)
label variable r`wv'ydpain "r`wv'ydpain:w`wv' r felt pain yesterday"
label values r`wv'ydpain pdegree

*wave 1 spouse
gen s`wv'ydpain = .
spouse r`wv'ydpain, result(s`wv'ydpain) wave(`wv')
label variable s`wv'ydpain "s`wv'ydpain:w`wv' s felt pain yesterday"
label values s`wv'ydpain pdegree

***Average score of experienced positive affect overall: Enthusiastic, Content and Happy***
*wave 1 respondent missing
egen r`wv'ovexpos3m = rowmiss(r`wv'ydenthu r`wv'ydcontent r`wv'ydhappy) if inw`wv'==1
label variable r`wv'ovexpos3m "r`wv'ovexpos3m:w`wv' r average score of experienced positive affect overall index missings"

*wave 1 respondent score
egen r`wv'ovexpos3 = rowmean(r`wv'ydenthu r`wv'ydcontent r`wv'ydhappy) if inrange(r`wv'ovexpos3m,0,1)
replace r`wv'ovexpos3 = .m if mi(r`wv'ovexpos3) & (r`wv'ydenthu==.m | r`wv'ydcontent==.m | r`wv'ydhappy==.m)
replace r`wv'ovexpos3 = .d if mi(r`wv'ovexpos3) & (r`wv'ydenthu==.d | r`wv'ydcontent==.d | r`wv'ydhappy==.d)
replace r`wv'ovexpos3 = .r if mi(r`wv'ovexpos3) & (r`wv'ydenthu==.r | r`wv'ydcontent==.r | r`wv'ydhappy==.r)
replace r`wv'ovexpos3 = .p if mi(r`wv'ovexpos3) & (r`wv'ydenthu==.p | r`wv'ydcontent==.p | r`wv'ydhappy==.p)
replace r`wv'ovexpos3 = .a if mi(r`wv'ovexpos3) & (r`wv'ydenthu==.a | r`wv'ydcontent==.a | r`wv'ydhappy==.a)
label variable r`wv'ovexpos3 "r`wv'ovexpos3:w`wv' r average score of experienced positive affect overall index"

*wave 1 spouse missing
gen s`wv'ovexpos3m = .
spouse r`wv'ovexpos3m, result(s`wv'ovexpos3m) wave(`wv')
label variable s`wv'ovexpos3m "s`wv'ovexpos3m:w`wv' s average score of experienced positive affect overall index missings"

*wave 1 spouse score
gen s`wv'ovexpos3 = .
spouse r`wv'ovexpos3, result(s`wv'ovexpos3) wave(`wv')
label variable s`wv'ovexpos3 "s`wv'ovexpos3:w`wv' s average score of experienced positive affect overall index"

***Average score of experienced negative affect overall: Frustrated, Sad, Lonely, Worried, Bored and Angry***
*wave 1 respondent missing
egen r`wv'ovexneg6m = rowmiss(r`wv'ydfrust r`wv'ydsad r`wv'ydlonely r`wv'ydworry r`wv'ydbored r`wv'ydangry) if inw`wv'==1
label variable r`wv'ovexneg6m "r`wv'ovexneg6m:w`wv' r average score of experienced negative affect overall index missings"

*wave 1 respondent score
egen r`wv'ovexneg6 = rowmean(r`wv'ydfrust r`wv'ydsad r`wv'ydlonely r`wv'ydworry r`wv'ydbored r`wv'ydangry) if inrange(r`wv'ovexneg6m,0,2)
replace r`wv'ovexneg6 = .m if mi(r`wv'ovexneg6) & (r`wv'ydfrust==.m | r`wv'ydsad==.m | r`wv'ydlonely==.m | r`wv'ydworry==.m | r`wv'ydbored==.m | r`wv'ydangry==.m)
replace r`wv'ovexneg6 = .d if mi(r`wv'ovexneg6) & (r`wv'ydfrust==.d | r`wv'ydsad==.d | r`wv'ydlonely==.d | r`wv'ydworry==.d | r`wv'ydbored==.d | r`wv'ydangry==.d)
replace r`wv'ovexneg6 = .r if mi(r`wv'ovexneg6) & (r`wv'ydfrust==.r | r`wv'ydsad==.r | r`wv'ydlonely==.r | r`wv'ydworry==.r | r`wv'ydbored==.r | r`wv'ydangry==.r)
replace r`wv'ovexneg6 = .p if mi(r`wv'ovexneg6) & (r`wv'ydfrust==.p | r`wv'ydsad==.p | r`wv'ydlonely==.p | r`wv'ydworry==.p | r`wv'ydbored==.p | r`wv'ydangry==.p)
replace r`wv'ovexneg6 = .a if mi(r`wv'ovexneg6) & (r`wv'ydfrust==.a | r`wv'ydsad==.a | r`wv'ydlonely==.a | r`wv'ydworry==.a | r`wv'ydbored==.a | r`wv'ydangry==.a)
label variable r`wv'ovexneg6 "r`wv'ovexneg6:w`wv' r average score of experienced negative affect overall index"

*wave 1 spouse missing
gen s`wv'ovexneg6m = .
spouse r`wv'ovexneg6m, result(s`wv'ovexneg6m) wave(`wv')
label variable s`wv'ovexneg6m "s`wv'ovexneg6m:w`wv' s average score of experienced negative affect overall index missings"

*wave 1 spouse score
gen s`wv'ovexneg6 = .
spouse r`wv'ovexneg6, result(s`wv'ovexneg6) wave(`wv')
label variable s`wv'ovexneg6 "s`wv'ovexneg6:w`wv' s average score of experienced negative affect overall index"

***Average score of experienced psychosomatic symptoms overall: Tired, Stressed and Pain***
*wave 1 respondent missing
egen r`wv'ovexpsy3m = rowmiss(r`wv'ydtired r`wv'ydstress r`wv'ydpain) if inw`wv'==1
label variable r`wv'ovexpsy3m "r`wv'ovexpsy3m:w`wv' r average score of experienced psychosomatic symptoms overall index missings"

*wave 1 respondent score
egen r`wv'ovexpsy3 = rowmean(r`wv'ydtired r`wv'ydstress r`wv'ydpain) if inrange(r`wv'ovexpsy3m,0,1)
replace r`wv'ovexpsy3 = .m if mi(r`wv'ovexpsy3) & (r`wv'ydtired==.m | r`wv'ydstress==.m | r`wv'ydpain==.m)
replace r`wv'ovexpsy3 = .d if mi(r`wv'ovexpsy3) & (r`wv'ydtired==.d | r`wv'ydstress==.d | r`wv'ydpain==.d)
replace r`wv'ovexpsy3 = .r if mi(r`wv'ovexpsy3) & (r`wv'ydtired==.r | r`wv'ydstress==.r | r`wv'ydpain==.r)
replace r`wv'ovexpsy3 = .p if mi(r`wv'ovexpsy3) & (r`wv'ydtired==.p | r`wv'ydstress==.p | r`wv'ydpain==.p)
replace r`wv'ovexpsy3 = .a if mi(r`wv'ovexpsy3) & (r`wv'ydtired==.a | r`wv'ydstress==.a | r`wv'ydpain==.a)
label variable r`wv'ovexpsy3 "r`wv'ovexpsy3:w`wv' r average score of experienced psychosomatic symptoms overall index"

*wave 1 spouse missing
gen s`wv'ovexpsy3m = .
spouse r`wv'ovexpsy3m, result(s`wv'ovexpsy3m) wave(`wv')
label variable s`wv'ovexpsy3m "s`wv'ovexpsy3m:w`wv' s average score of experienced psychosomatic symptoms overall index missings"

*wave 1 spouse score
gen s`wv'ovexpsy3 = .
spouse r`wv'ovexpsy3, result(s`wv'ovexpsy3) wave(`wv')
label variable s`wv'ovexpsy3 "s`wv'ovexpsy3:w`wv' s average score of experienced psychosomatic symptoms overall index"


*********************************************************************
***Activity-related Affective Experience Yesterday***
*********************************************************************
***watched tv***
*wave 1 respondent
gen r`wv'wtchtv = .
missing_lasi tu010, result(r`wv'wtchtv) wave(`wv')
replace r`wv'wtchtv = .p if r`wv'proxy==1
replace r`wv'wtchtv = .a if tu001_1==. & (ee001!=. | es001_1!=. | ev001!=.)
replace r`wv'wtchtv = .b if tu009==. & (!mi(tu014) | !mi(tu020) | !mi(tu024) | !mi(tu028) | !mi(tu032) | !mi(tu036))
replace r`wv'wtchtv = 0 if tu010==2
replace r`wv'wtchtv = 1 if tu010==1
label variable r`wv'wtchtv "r`wv'wtchtv:w`wv' r watched tv yesterday"
label values r`wv'wtchtv yesnocesd

*wave 1 spouse
gen s`wv'wtchtv = .
spouse r`wv'wtchtv, result(s`wv'wtchtv) wave(`wv')
label variable s`wv'wtchtv "s`wv'wtchtv:w`wv' s watched tv yesterday"
label values s`wv'wtchtv yesnocesd

***minutes watched tv***
gen h2m = tu011_hour*60 if inrange(tu011_hour,0,24)
gen m2m = tu011_minute if inrange(tu011_minute,0,60)
egen min = rowtotal(h2m m2m) if (!mi(h2m) | !mi(m2m))

*wave 1 respondent
gen r`wv'wtchtvmn = .
replace r`wv'wtchtvmn = .m if inw`wv'==1 & (tu011_hour==. | tu011_minute==.)
replace r`wv'wtchtvmn = .d if tu011_hour==.d | tu011_minute==.d
replace r`wv'wtchtvmn = .r if tu011_hour==.r | tu011_minute==.r
replace r`wv'wtchtvmn = .p if r`wv'wtchtv==.p
replace r`wv'wtchtvmn = .a if r`wv'wtchtv==.a
replace r`wv'wtchtvmn = .b if r`wv'wtchtv==.b
replace r`wv'wtchtvmn = 0 if tu010==2
replace r`wv'wtchtvmn = min if inrange(min,0,1440)
label variable r`wv'wtchtvmn "r`wv'wtchtvmn:w`wv' minutes r watched tv yesterday"

*wave 1 spouse
gen s`wv'wtchtvmn = .
spouse r`wv'wtchtvmn, result(s`wv'wtchtvmn) wave(`wv')
label variable s`wv'wtchtvmn "s`wv'wtchtvmn:w`wv' minutes s watched tv yesterday"

drop h2m m2m min

***Feeling when watched TV yesterday***
***Happy***
*wave 1 respondent
gen r`wv'wtvhpya = .
missing_lasi tu013_1, result(r`wv'wtvhpya) wave(`wv')
replace r`wv'wtvhpya = .p if r`wv'wtchtv==.p
replace r`wv'wtvhpya = .a if r`wv'wtchtv==.a
replace r`wv'wtvhpya = .b if r`wv'wtchtv==.b
replace r`wv'wtvhpya = .x if r`wv'wtchtv==0
replace r`wv'wtvhpya = tu013_1 if inrange(tu013_1,1,6) //1-Did not experience the feeling at all, to 6-Feeling was extremely strong
label variable r`wv'wtvhpya "r`wv'wtvhpya:w`wv' How happy r felt when watched TV yesterday"

*wave 1 spouse
gen s`wv'wtvhpya = .
spouse r`wv'wtvhpya, result(s`wv'wtvhpya) wave(`wv')
label variable s`wv'wtvhpya "s`wv'wtvhpya:w`wv' How happy s felt when watched TV yesterday"

***Interested***
*wave 1 respondent
gen r`wv'wtvinta = .
missing_lasi tu013_2, result(r`wv'wtvinta) wave(`wv')
replace r`wv'wtvinta = .p if r`wv'wtchtv==.p
replace r`wv'wtvinta = .a if r`wv'wtchtv==.a
replace r`wv'wtvinta = .b if r`wv'wtchtv==.b
replace r`wv'wtvinta = .x if r`wv'wtchtv==0
replace r`wv'wtvinta = tu013_2 if inrange(tu013_2,1,6) //1-Did not experience the feeling at all, to 6-Feeling was extremely strong
label variable r`wv'wtvinta "r`wv'wtvinta:w`wv' How interested r felt when watched TV yesterday"

*wave 1 spouse
gen s`wv'wtvinta = .
spouse r`wv'wtvinta, result(s`wv'wtvinta) wave(`wv')
label variable s`wv'wtvinta "s`wv'wtvinta:w`wv' How interested s felt when watched TV yesterday"

***Frustrated***
*wave 1 respondent
gen r`wv'wtvfrsa = .
missing_lasi tu013_3, result(r`wv'wtvfrsa) wave(`wv')
replace r`wv'wtvfrsa = .p if r`wv'wtchtv==.p
replace r`wv'wtvfrsa = .a if r`wv'wtchtv==.a
replace r`wv'wtvfrsa = .b if r`wv'wtchtv==.b
replace r`wv'wtvfrsa = .x if r`wv'wtchtv==0
replace r`wv'wtvfrsa = tu013_3 if inrange(tu013_3,1,6) //1-Did not experience the feeling at all, to 6-Feeling was extremely strong
label variable r`wv'wtvfrsa "r`wv'wtvfrsa:w`wv' How frustrated r felt when watched TV yesterday"

*wave 1 spouse
gen s`wv'wtvfrsa = .
spouse r`wv'wtvfrsa, result(s`wv'wtvfrsa) wave(`wv')
label variable s`wv'wtvfrsa "s`wv'wtvfrsa:w`wv' How frustrated s felt when watched TV yesterday"

***Sad***
*wave 1 respondent
gen r`wv'wtvsada = .
missing_lasi tu013_4, result(r`wv'wtvsada) wave(`wv')
replace r`wv'wtvsada = .p if r`wv'wtchtv==.p
replace r`wv'wtvsada = .a if r`wv'wtchtv==.a
replace r`wv'wtvsada = .b if r`wv'wtchtv==.b
replace r`wv'wtvsada = .x if r`wv'wtchtv==0
replace r`wv'wtvsada = tu013_4 if inrange(tu013_4,1,6) //1-Did not experience the feeling at all, to 6-Feeling was extremely strong
label variable r`wv'wtvsada "r`wv'wtvsada:w`wv' How sad r felt when watched TV yesterday"

*wave 1 spouse
gen s`wv'wtvsada = .
spouse r`wv'wtvsada, result(s`wv'wtvsada) wave(`wv')
label variable s`wv'wtvsada "s`wv'wtvsada:w`wv' How sad s felt when watched TV yesterday"

***Average score of how happy and interested**
*wave 1 respondent score
egen r`wv'wtvpos2ma = rowmiss(r`wv'wtvhpya r`wv'wtvinta) if inw`wv'==1

egen r`wv'wtvpos2a = rowmean(r`wv'wtvhpya r`wv'wtvinta) if r`wv'wtvpos2ma==0
replace r`wv'wtvpos2a = .m if mi(r`wv'wtvpos2a) & (r`wv'wtvhpya==.m | r`wv'wtvinta==.m)
replace r`wv'wtvpos2a = .d if mi(r`wv'wtvpos2a) & (r`wv'wtvhpya==.d | r`wv'wtvinta==.d)
replace r`wv'wtvpos2a = .r if mi(r`wv'wtvpos2a) & (r`wv'wtvhpya==.r | r`wv'wtvinta==.r)
replace r`wv'wtvpos2a = .p if mi(r`wv'wtvpos2a) & (r`wv'wtvhpya==.p | r`wv'wtvinta==.p)
replace r`wv'wtvpos2a = .a if mi(r`wv'wtvpos2a) & (r`wv'wtvhpya==.a | r`wv'wtvinta==.a)
replace r`wv'wtvpos2a = .b if mi(r`wv'wtvpos2a) & (r`wv'wtvhpya==.b | r`wv'wtvinta==.b)
replace r`wv'wtvpos2a = .x if mi(r`wv'wtvpos2a) & (r`wv'wtvhpya==.x | r`wv'wtvinta==.x) // *same as: replace r`wv'wtvpos2a = .x if r`wv'wtchtv==0
label variable r`wv'wtvpos2a "r`wv'wtvpos2a:w`wv' r avg pos affect watching TV (happy, interested)"

*wave 1 spouse score
gen s`wv'wtvpos2a = .
spouse r`wv'wtvpos2a, result(s`wv'wtvpos2a) wave(`wv')
label variable s`wv'wtvpos2a "s`wv'wtvpos2a:w`wv' s avg pos affect watching TV (happy, interested)"

drop r`wv'wtvpos2ma

***Average score of how frustrated and sad***
*wave 1 respondent score
egen r`wv'wtvneg2ma = rowmiss(r`wv'wtvfrsa r`wv'wtvsada) if inw`wv'==1

egen r`wv'wtvneg2a = rowmean(r`wv'wtvfrsa r`wv'wtvsada) if r`wv'wtvneg2ma==0
replace r`wv'wtvneg2a = .m if mi(r`wv'wtvneg2a) & (r`wv'wtvfrsa==.m | r`wv'wtvsada==.m)
replace r`wv'wtvneg2a = .d if mi(r`wv'wtvneg2a) & (r`wv'wtvfrsa==.d | r`wv'wtvsada==.d)
replace r`wv'wtvneg2a = .r if mi(r`wv'wtvneg2a) & (r`wv'wtvfrsa==.r | r`wv'wtvsada==.r)
replace r`wv'wtvneg2a = .p if mi(r`wv'wtvneg2a) & (r`wv'wtvfrsa==.p | r`wv'wtvsada==.p)
replace r`wv'wtvneg2a = .a if mi(r`wv'wtvneg2a) & (r`wv'wtvfrsa==.a | r`wv'wtvsada==.a)
replace r`wv'wtvneg2a = .b if mi(r`wv'wtvneg2a) & (r`wv'wtvfrsa==.b | r`wv'wtvsada==.b)
replace r`wv'wtvneg2a = .x if mi(r`wv'wtvneg2a) & (r`wv'wtvfrsa==.x | r`wv'wtvsada==.x)
label variable r`wv'wtvneg2a "r`wv'wtvneg2a:w`wv' r avg neg affect watching TV (frustrated, sad)"

*wave 1 spouse score
gen s`wv'wtvneg2a = .
spouse r`wv'wtvneg2a, result(s`wv'wtvneg2a) wave(`wv')
label variable s`wv'wtvneg2a "s`wv'wtvneg2a:w`wv' s avg neg affect watching TV (frustrated, sad)"

drop r`wv'wtvneg2ma


***worked or volunteered***
*wave 1 respondent
gen r`wv'wkvlntr = .
missing_lasi tu014, result(r`wv'wkvlntr) wave(`wv')
replace r`wv'wkvlntr = .p if r`wv'proxy==1
replace r`wv'wkvlntr = .a if tu001_1==. & (ee001!=. | es001_1!=. | ev001!=.)
replace r`wv'wkvlntr = .b if tu014==. & (!mi(tu009) | !mi(tu020) | !mi(tu024) | !mi(tu028) | !mi(tu032) | !mi(tu036))
replace r`wv'wkvlntr = 0 if tu014==4
replace r`wv'wkvlntr = 1 if inlist(tu014,1,2,3)
label variable r`wv'wkvlntr "r`wv'wkvlntr:w`wv' r worked or volunteered yesterday"
label values r`wv'wkvlntr yesnocesd

*wave 1 spouse
gen s`wv'wkvlntr = .
spouse r`wv'wkvlntr, result(s`wv'wkvlntr) wave(`wv')
label variable s`wv'wkvlntr "s`wv'wkvlntr:w`wv' s worked or volunteered yesterday"
label values s`wv'wkvlntr yesnocesd

***minutes worked or volunteered***
gen h2m = tu017_hour*60 if inrange(tu017_hour,0,24)
gen m2m = tu017_minute if inrange(tu017_minute,0,60)
egen min = rowtotal(h2m m2m) if (!mi(h2m) | !mi(m2m))

*wave 1 respondent
gen r`wv'wkvlntrmn = .
replace r`wv'wkvlntrmn = .m if inw`wv'==1 & (tu017_hour==. | tu017_minute==. | tu017_hour==.e | tu017_minute==.e)
replace r`wv'wkvlntrmn = .d if tu017_hour==.d | tu017_minute==.d
replace r`wv'wkvlntrmn = .r if tu017_hour==.r | tu017_minute==.r
replace r`wv'wkvlntrmn = .p if r`wv'wkvlntr==.p
replace r`wv'wkvlntrmn = .a if r`wv'wkvlntr==.a
replace r`wv'wkvlntrmn = .b if r`wv'wkvlntr==.b
replace r`wv'wkvlntrmn = 0 if tu014==4
replace r`wv'wkvlntrmn = min if inrange(min,0,1440)
label variable r`wv'wkvlntrmn "r`wv'wkvlntrmn:w`wv' minutes r worked or volunteered yesterday"

*wave 1 spouse
gen s`wv'wkvlntrmn = .
spouse r`wv'wkvlntrmn, result(s`wv'wkvlntrmn) wave(`wv')
label variable s`wv'wkvlntrmn "s`wv'wkvlntrmn:w`wv' minutes s worked or volunteered yesterday"

drop h2m m2m min

***Feeling when worked or volunteered yesterday***
***Happy***
*wave 1 respondent
gen r`wv'wkvhpya = .
missing_lasi tu018_1, result(r`wv'wkvhpya) wave(`wv')
replace r`wv'wkvhpya = .p if r`wv'wkvlntr==.p
replace r`wv'wkvhpya = .a if r`wv'wkvlntr==.a
replace r`wv'wkvhpya = .b if r`wv'wkvlntr==.b
replace r`wv'wkvhpya = .x if r`wv'wkvlntr==0
replace r`wv'wkvhpya = tu018_1 if inrange(tu018_1,1,6) //1-Did not experience the feeling at all, to 6-Feeling was extremely strong
label variable r`wv'wkvhpya "r`wv'wkvhpya:w`wv' How happy r felt when worked or volunteered yesterday"

*wave 1 spouse
gen s`wv'wkvhpya = .
spouse r`wv'wkvhpya, result(s`wv'wkvhpya) wave(`wv')
label variable s`wv'wkvhpya "s`wv'wkvhpya:w`wv' How happy s felt when worked or volunteered yesterday"

***Interested***
*wave 1 respondent
gen r`wv'wkvinta = .
missing_lasi tu018_2, result(r`wv'wkvinta) wave(`wv')
replace r`wv'wkvinta = .p if r`wv'wkvlntr==.p
replace r`wv'wkvinta = .a if r`wv'wkvlntr==.a
replace r`wv'wkvinta = .b if r`wv'wkvlntr==.b
replace r`wv'wkvinta = .x if r`wv'wkvlntr==0
replace r`wv'wkvinta = tu018_2 if inrange(tu018_2,1,6) //1-Did not experience the feeling at all, to 6-Feeling was extremely strong
label variable r`wv'wkvinta "r`wv'wkvinta:w`wv' How interested r felt when worked or volunteered yesterday"

*wave 1 spouse
gen s`wv'wkvinta = .
spouse r`wv'wkvinta, result(s`wv'wkvinta) wave(`wv')
label variable s`wv'wkvinta "s`wv'wkvinta:w`wv' How interested s felt when worked or volunteered yesterday"

***Frustrated***
*wave 1 respondent
gen r`wv'wkvfrsa = .
missing_lasi tu018_3, result(r`wv'wkvfrsa) wave(`wv')
replace r`wv'wkvfrsa = .p if r`wv'wkvlntr==.p
replace r`wv'wkvfrsa = .a if r`wv'wkvlntr==.a
replace r`wv'wkvfrsa = .b if r`wv'wkvlntr==.b
replace r`wv'wkvfrsa = .x if r`wv'wkvlntr==0
replace r`wv'wkvfrsa = tu018_3 if inrange(tu018_3,1,6) //1-Did not experience the feeling at all, to 6-Feeling was extremely strong
label variable r`wv'wkvfrsa "r`wv'wkvfrsa:w`wv' How frustrated r felt when worked or volunteered yesterday"

*wave 1 spouse
gen s`wv'wkvfrsa = .
spouse r`wv'wkvfrsa, result(s`wv'wkvfrsa) wave(`wv')
label variable s`wv'wkvfrsa "s`wv'wkvfrsa:w`wv' How frustrated s felt when worked or volunteered yesterday"

***Sad***
*wave 1 respondent
gen r`wv'wkvsada = .
missing_lasi tu018_4, result(r`wv'wkvsada) wave(`wv')
replace r`wv'wkvsada = .p if r`wv'wkvlntr==.p
replace r`wv'wkvsada = .a if r`wv'wkvlntr==.a
replace r`wv'wkvsada = .b if r`wv'wkvlntr==.b
replace r`wv'wkvsada = .x if r`wv'wkvlntr==0
replace r`wv'wkvsada = tu018_4 if inrange(tu018_4,1,6) //1-Did not experience the feeling at all, to 6-Feeling was extremely strong
label variable r`wv'wkvsada "r`wv'wkvsada:w`wv' How sad r felt when worked or volunteered yesterday"

*wave 1 spouse
gen s`wv'wkvsada = .
spouse r`wv'wkvsada, result(s`wv'wkvsada) wave(`wv')
label variable s`wv'wkvsada "s`wv'wkvsada:w`wv' How sad s felt when worked or volunteered yesterday"

***Average score of how happy and interested***
*wave 1 respondent score
egen r`wv'wkvpos2ma = rowmiss(r`wv'wkvhpya r`wv'wkvinta) if inw`wv'==1

egen r`wv'wkvpos2a = rowmean(r`wv'wkvhpya r`wv'wkvinta) if r`wv'wkvpos2ma==0
replace r`wv'wkvpos2a = .m if mi(r`wv'wkvpos2a) & (r`wv'wkvhpya==.m | r`wv'wkvinta==.m)
replace r`wv'wkvpos2a = .d if mi(r`wv'wkvpos2a) & (r`wv'wkvhpya==.d | r`wv'wkvinta==.d)
replace r`wv'wkvpos2a = .r if mi(r`wv'wkvpos2a) & (r`wv'wkvhpya==.r | r`wv'wkvinta==.r)
replace r`wv'wkvpos2a = .p if mi(r`wv'wkvpos2a) & (r`wv'wkvhpya==.p | r`wv'wkvinta==.p)
replace r`wv'wkvpos2a = .a if mi(r`wv'wkvpos2a) & (r`wv'wkvhpya==.a | r`wv'wkvinta==.a)
replace r`wv'wkvpos2a = .b if mi(r`wv'wkvpos2a) & (r`wv'wkvhpya==.b | r`wv'wkvinta==.b)
replace r`wv'wkvpos2a = .x if mi(r`wv'wkvpos2a) & (r`wv'wkvhpya==.x | r`wv'wkvinta==.x)
label variable r`wv'wkvpos2a "r`wv'wkvpos2a:w`wv' r avg pos affect work/volunteer (happy, interested)"

*wave 1 spouse score
gen s`wv'wkvpos2a = .
spouse r`wv'wkvpos2a, result(s`wv'wkvpos2a) wave(`wv')
label variable s`wv'wkvpos2a "s`wv'wkvpos2a:w`wv' s avg pos affect work/volunteer (happy, interested)"

drop r`wv'wkvpos2ma

***Average score of how frustrated and sad***
*wave 1 respondent score
egen r`wv'wkvneg2ma = rowmiss(r`wv'wkvfrsa r`wv'wkvsada) if inw`wv'==1

egen r`wv'wkvneg2a = rowmean(r`wv'wkvfrsa r`wv'wkvsada) if r`wv'wkvneg2ma==0
replace r`wv'wkvneg2a = .m if mi(r`wv'wkvneg2a) & (r`wv'wkvfrsa==.m | r`wv'wkvsada==.m)
replace r`wv'wkvneg2a = .d if mi(r`wv'wkvneg2a) & (r`wv'wkvfrsa==.d | r`wv'wkvsada==.d)
replace r`wv'wkvneg2a = .r if mi(r`wv'wkvneg2a) & (r`wv'wkvfrsa==.r | r`wv'wkvsada==.r)
replace r`wv'wkvneg2a = .p if mi(r`wv'wkvneg2a) & (r`wv'wkvfrsa==.p | r`wv'wkvsada==.p)
replace r`wv'wkvneg2a = .a if mi(r`wv'wkvneg2a) & (r`wv'wkvfrsa==.a | r`wv'wkvsada==.a)
replace r`wv'wkvneg2a = .b if mi(r`wv'wkvneg2a) & (r`wv'wkvfrsa==.b | r`wv'wkvsada==.b)
replace r`wv'wkvneg2a = .x if mi(r`wv'wkvneg2a) & (r`wv'wkvfrsa==.x | r`wv'wkvsada==.x)
label variable r`wv'wkvneg2a "r`wv'wkvneg2a:w`wv' r avg neg affect work/volunteer (frustrated, sad)"

*wave 1 spouse score
gen s`wv'wkvneg2a = .
spouse r`wv'wkvneg2a, result(s`wv'wkvneg2a) wave(`wv')
label variable s`wv'wkvneg2a "s`wv'wkvneg2a:w`wv' s avg neg affect work/volunteer (frustrated, sad)"

drop r`wv'wkvneg2ma


***walked or exercised***
*wave 1 respondent
gen r`wv'walkex = .
missing_lasi tu020, result(r`wv'walkex) wave(`wv')
replace r`wv'walkex = .p if r`wv'proxy==1
replace r`wv'walkex = .a if tu001_1==. & (ee001!=. | es001_1!=. | ev001!=.)
replace r`wv'walkex = .b if tu020==. & (!mi(tu014) | !mi(tu009) | !mi(tu024) | !mi(tu028) | !mi(tu032) | !mi(tu036))
replace r`wv'walkex = 0 if tu020==2
replace r`wv'walkex = 1 if tu020==1
label variable r`wv'walkex "r`wv'walkex:w`wv' r walked or exercised yesterday"
label values r`wv'walkex yesnocesd

*wave 1 spouse
gen s`wv'walkex = .
spouse r`wv'walkex, result(s`wv'walkex) wave(`wv')
label variable s`wv'walkex "s`wv'walkex:w`wv' s walked or exercised yesterday"
label values s`wv'walkex yesnocesd

***minutes walked or exercised***
gen h2m = tu021_hour*60 if inrange(tu021_hour,0,24)
gen m2m = tu021_minute if inrange(tu021_minute,0,60)
egen min = rowtotal(h2m m2m) if (!mi(h2m) | !mi(m2m))

*wave 1 respondent
gen r`wv'walkexmn = .
replace r`wv'walkexmn = .m if inw`wv'==1 & (tu021_hour==. | tu021_minute==. | tu021_hour==.e | tu021_minute==.e)
replace r`wv'walkexmn = .d if tu021_hour==.d | tu021_minute==.d
replace r`wv'walkexmn = .r if tu021_hour==.r | tu021_minute==.r
replace r`wv'walkexmn = .p if r`wv'walkex==.p
replace r`wv'walkexmn = .a if r`wv'walkex==.a
replace r`wv'walkexmn = .b if r`wv'walkex==.b
replace r`wv'walkexmn = 0 if tu020==2
replace r`wv'walkexmn = min if inrange(min,0,1440)
label variable r`wv'walkexmn "r`wv'walkexmn:w`wv' minutes r walked or exercised yesterday"

*wave 1 spouse
gen s`wv'walkexmn = .
spouse r`wv'walkexmn, result(s`wv'walkexmn) wave(`wv')
label variable s`wv'walkexmn "s`wv'walkexmn:w`wv' minutes s walked or exercised yesterday"

drop h2m m2m min

***Feeling when walked or exercised yesterday***
***Happy***
*wave 1 respondent
gen r`wv'exrhpya = .
missing_lasi tu022_1, result(r`wv'exrhpya) wave(`wv')
replace r`wv'exrhpya = .p if r`wv'walkex==.p
replace r`wv'exrhpya = .a if r`wv'walkex==.a
replace r`wv'exrhpya = .b if r`wv'walkex==.b
replace r`wv'exrhpya = .x if r`wv'walkex==0
replace r`wv'exrhpya = tu022_1 if inrange(tu022_1,1,6) //1-Did not experience the feeling at all, to 6-Feeling was extremely strong
label variable r`wv'exrhpya "r`wv'exrhpya:w`wv' How happy r felt when walked or exercised yesterday"

*wave 1 spouse
gen s`wv'exrhpya = .
spouse r`wv'exrhpya, result(s`wv'exrhpya) wave(`wv')
label variable s`wv'exrhpya "s`wv'exrhpya:w`wv' How happy s felt when walked or exercised yesterday"

***Interested***
*wave 1 respondent
gen r`wv'exrinta = .
missing_lasi tu022_2, result(r`wv'exrinta) wave(`wv')
replace r`wv'exrinta = .p if r`wv'walkex==.p
replace r`wv'exrinta = .a if r`wv'walkex==.a
replace r`wv'exrinta = .b if r`wv'walkex==.b
replace r`wv'exrinta = .x if r`wv'walkex==0
replace r`wv'exrinta = tu022_2 if inrange(tu022_2,1,6) //1-Did not experience the feeling at all, to 6-Feeling was extremely strong
label variable r`wv'exrinta "r`wv'exrinta:w`wv' How interested r felt when walked or exercised yesterday"

*wave 1 spouse
gen s`wv'exrinta = .
spouse r`wv'exrinta, result(s`wv'exrinta) wave(`wv')
label variable s`wv'exrinta "s`wv'exrinta:w`wv' How interested s felt when walked or exercised yesterday"

***Frustrated***
*wave 1 respondent
gen r`wv'exrfrsa = .
missing_lasi tu022_3, result(r`wv'exrfrsa) wave(`wv')
replace r`wv'exrfrsa = .p if r`wv'walkex==.p
replace r`wv'exrfrsa = .a if r`wv'walkex==.a
replace r`wv'exrfrsa = .b if r`wv'walkex==.b
replace r`wv'exrfrsa = .x if r`wv'walkex==0
replace r`wv'exrfrsa = tu022_3 if inrange(tu022_3,1,6) //1-Did not experience the feeling at all, to 6-Feeling was extremely strong
label variable r`wv'exrfrsa "r`wv'exrfrsa:w`wv' How frustrated r felt when walked or exercised yesterday"

*wave 1 spouse
gen s`wv'exrfrsa = .
spouse r`wv'exrfrsa, result(s`wv'exrfrsa) wave(`wv')
label variable s`wv'exrfrsa "s`wv'exrfrsa:w`wv' How frustrated s felt when walked or exercised yesterday"

***Sad***
*wave 1 respondent
gen r`wv'exrsada = .
missing_lasi tu022_4, result(r`wv'exrsada) wave(`wv')
replace r`wv'exrsada = .p if r`wv'walkex==.p
replace r`wv'exrsada = .a if r`wv'walkex==.a
replace r`wv'exrsada = .b if r`wv'walkex==.b
replace r`wv'exrsada = .x if r`wv'walkex==0
replace r`wv'exrsada = tu022_4 if inrange(tu022_4,1,6) //1-Did not experience the feeling at all, to 6-Feeling was extremely strong
label variable r`wv'exrsada "r`wv'exrsada:w`wv' How sad r felt when walked or exercised yesterday"

*wave 1 spouse
gen s`wv'exrsada = .
spouse r`wv'exrsada, result(s`wv'exrsada) wave(`wv')
label variable s`wv'exrsada "s`wv'exrsada:w`wv' How sad s felt when walked or exercised yesterday"

***Average score of how happy and interested***
*wave 1 respondent score
egen r`wv'exrpos2ma = rowmiss(r`wv'exrhpya r`wv'exrinta) if inw`wv'==1

egen r`wv'exrpos2a = rowmean(r`wv'exrhpya r`wv'exrinta) if r`wv'exrpos2ma==0
replace r`wv'exrpos2a = .m if mi(r`wv'exrpos2a) & (r`wv'exrhpya==.m | r`wv'exrinta==.m)
replace r`wv'exrpos2a = .d if mi(r`wv'exrpos2a) & (r`wv'exrhpya==.d | r`wv'exrinta==.d)
replace r`wv'exrpos2a = .r if mi(r`wv'exrpos2a) & (r`wv'exrhpya==.r | r`wv'exrinta==.r)
replace r`wv'exrpos2a = .p if mi(r`wv'exrpos2a) & (r`wv'exrhpya==.p | r`wv'exrinta==.p)
replace r`wv'exrpos2a = .a if mi(r`wv'exrpos2a) & (r`wv'exrhpya==.a | r`wv'exrinta==.a)
replace r`wv'exrpos2a = .b if mi(r`wv'exrpos2a) & (r`wv'exrhpya==.b | r`wv'exrinta==.b)
replace r`wv'exrpos2a = .x if mi(r`wv'exrpos2a) & (r`wv'exrhpya==.x | r`wv'exrinta==.x)
label variable r`wv'exrpos2a "r`wv'exrpos2a:w`wv' r avg pos affect walk/exercise (happy, interested)"

*wave 1 spouse score
gen s`wv'exrpos2a = .
spouse r`wv'exrpos2a, result(s`wv'exrpos2a) wave(`wv')
label variable s`wv'exrpos2a "s`wv'exrpos2a:w`wv' s avg pos affect walk/exercise (happy, interested)"

drop r`wv'exrpos2ma

***Average score of how frustrated and sad***
*wave 1 respondent score
egen r`wv'exrneg2ma = rowmiss(r`wv'exrfrsa r`wv'exrsada) if inw`wv'==1

egen r`wv'exrneg2a = rowmean(r`wv'exrfrsa r`wv'exrsada) if r`wv'exrneg2ma==0
replace r`wv'exrneg2a = .m if mi(r`wv'exrneg2a) & (r`wv'exrfrsa==.m | r`wv'exrsada==.m)
replace r`wv'exrneg2a = .d if mi(r`wv'exrneg2a) & (r`wv'exrfrsa==.d | r`wv'exrsada==.d)
replace r`wv'exrneg2a = .r if mi(r`wv'exrneg2a) & (r`wv'exrfrsa==.r | r`wv'exrsada==.r)
replace r`wv'exrneg2a = .p if mi(r`wv'exrneg2a) & (r`wv'exrfrsa==.p | r`wv'exrsada==.p)
replace r`wv'exrneg2a = .a if mi(r`wv'exrneg2a) & (r`wv'exrfrsa==.a | r`wv'exrsada==.a)
replace r`wv'exrneg2a = .b if mi(r`wv'exrneg2a) & (r`wv'exrfrsa==.b | r`wv'exrsada==.b)
replace r`wv'exrneg2a = .x if mi(r`wv'exrneg2a) & (r`wv'exrfrsa==.x | r`wv'exrsada==.x)
label variable r`wv'exrneg2a "r`wv'exrneg2a:w`wv' r avg neg affect walk/exercise (frustrated, sad)"

*wave 1 spouse score
gen s`wv'exrneg2a = .
spouse r`wv'exrneg2a, result(s`wv'exrneg2a) wave(`wv')
label variable s`wv'exrneg2a "s`wv'exrneg2a:w`wv' s avg neg affect walk/exercise (frustrated, sad)"

drop r`wv'exrneg2ma


***health-related activity***
*wave 1 respondent
gen r`wv'hlthac = .
missing_lasi tu024, result(r`wv'hlthac) wave(`wv')
replace r`wv'hlthac = .p if r`wv'proxy==1
replace r`wv'hlthac = .a if tu001_1==. & (ee001!=. | es001_1!=. | ev001!=.)
replace r`wv'hlthac = .b if tu024==. & (!mi(tu014) | !mi(tu020) | !mi(tu009) | !mi(tu028) | !mi(tu032) | !mi(tu036))
replace r`wv'hlthac = 0 if tu024==2
replace r`wv'hlthac = 1 if tu024==1
label variable r`wv'hlthac "r`wv'hlthac:w`wv' r did health-related activity yesterday"
label values r`wv'hlthac yesnocesd

*wave 1 spouse
gen s`wv'hlthac = .
spouse r`wv'hlthac, result(s`wv'hlthac) wave(`wv')
label variable s`wv'hlthac "s`wv'hlthac:w`wv' s did health-related activity yesterday"
label values s`wv'hlthac yesnocesd

***minutes health-related activity***
gen h2m = tu025_hour*60 if inrange(tu025_hour,0,24)
gen m2m = tu025_minute if inrange(tu025_minute,0,60)
egen min = rowtotal(h2m m2m) if (!mi(h2m) | !mi(m2m))

*wave 1 respondent
gen r`wv'hlthacmn = .
replace r`wv'hlthacmn = .m if inw`wv'==1 & (tu025_hour==. | tu025_minute==. | tu025_hour==.e | tu025_minute==.e)
replace r`wv'hlthacmn = .d if tu025_hour==.d | tu025_minute==.d
replace r`wv'hlthacmn = .r if tu025_hour==.r | tu025_minute==.r
replace r`wv'hlthacmn = .p if r`wv'hlthac==.p
replace r`wv'hlthacmn = .a if r`wv'hlthac==.a
replace r`wv'hlthacmn = .b if r`wv'hlthac==.b
replace r`wv'hlthacmn = 0 if tu024==2
replace r`wv'hlthacmn = min if inrange(min,0,1440)
label variable r`wv'hlthacmn "r`wv'hlthacmn:w`wv' minutes r did health-related activity yesterday"

*wave 1 spouse
gen s`wv'hlthacmn = .
spouse r`wv'hlthacmn, result(s`wv'hlthacmn) wave(`wv')
label variable s`wv'hlthacmn "s`wv'hlthacmn:w`wv' minutes s did health-related activity yesterday"

drop h2m m2m min

***Feeling when did health-related activity yesterday***
***Happy***
*wave 1 respondent
gen r`wv'hlthpya = .
missing_lasi tu026_1, result(r`wv'hlthpya) wave(`wv')
replace r`wv'hlthpya = .p if r`wv'hlthac==.p
replace r`wv'hlthpya = .a if r`wv'hlthac==.a
replace r`wv'hlthpya = .b if r`wv'hlthac==.b
replace r`wv'hlthpya = .x if r`wv'hlthac==0
replace r`wv'hlthpya = tu026_1 if inrange(tu026_1,1,6) //1-Did not experience the feeling at all, to 6-Feeling was extremely strong
label variable r`wv'hlthpya "r`wv'hlthpya:w`wv' How happy r felt when did health-related activity yesterday"

*wave 1 spouse
gen s`wv'hlthpya = .
spouse r`wv'hlthpya, result(s`wv'hlthpya) wave(`wv')
label variable s`wv'hlthpya "s`wv'hlthpya:w`wv' How happy s felt when did health-related activity yesterday"

***Interested***
*wave 1 respondent
gen r`wv'hltinta = .
missing_lasi tu026_2, result(r`wv'hltinta) wave(`wv')
replace r`wv'hltinta = .p if r`wv'hlthac==.p
replace r`wv'hltinta = .a if r`wv'hlthac==.a
replace r`wv'hltinta = .b if r`wv'hlthac==.b
replace r`wv'hltinta = .x if r`wv'hlthac==0
replace r`wv'hltinta = tu026_2 if inrange(tu026_2,1,6) //1-Did not experience the feeling at all, to 6-Feeling was extremely strong
label variable r`wv'hltinta "r`wv'hltinta:w`wv' How interested r felt when did health-related activity yesterday"

*wave 1 spouse
gen s`wv'hltinta = .
spouse r`wv'hltinta, result(s`wv'hltinta) wave(`wv')
label variable s`wv'hltinta "s`wv'hltinta:w`wv' How interested s felt when did health-related activity yesterday"

***Frustrated***
*wave 1 respondent
gen r`wv'hltfrsa = .
missing_lasi tu026_3, result(r`wv'hltfrsa) wave(`wv')
replace r`wv'hltfrsa = .p if r`wv'hlthac==.p
replace r`wv'hltfrsa = .a if r`wv'hlthac==.a
replace r`wv'hltfrsa = .b if r`wv'hlthac==.b
replace r`wv'hltfrsa = .x if r`wv'hlthac==0
replace r`wv'hltfrsa = tu026_3 if inrange(tu026_3,1,6) //1-Did not experience the feeling at all, to 6-Feeling was extremely strong
label variable r`wv'hltfrsa "r`wv'hltfrsa:w`wv' How frustrated r felt when did health-related activity yesterday"

*wave 1 spouse
gen s`wv'hltfrsa = .
spouse r`wv'hltfrsa, result(s`wv'hltfrsa) wave(`wv')
label variable s`wv'hltfrsa "s`wv'hltfrsa:w`wv' How frustrated s felt when did health-related activity yesterday"

***Sad***
*wave 1 respondent
gen r`wv'hltsada = .
missing_lasi tu026_4, result(r`wv'hltsada) wave(`wv')
replace r`wv'hltsada = .p if r`wv'hlthac==.p
replace r`wv'hltsada = .a if r`wv'hlthac==.a
replace r`wv'hltsada = .b if r`wv'hlthac==.b
replace r`wv'hltsada = .x if r`wv'hlthac==0
replace r`wv'hltsada = tu026_4 if inrange(tu026_4,1,6) //1-Did not experience the feeling at all, to 6-Feeling was extremely strong
label variable r`wv'hltsada "r`wv'hltsada:w`wv' How sad r felt when did health-related activity yesterday"

*wave 1 spouse
gen s`wv'hltsada = .
spouse r`wv'hltsada, result(s`wv'hltsada) wave(`wv')
label variable s`wv'hltsada "s`wv'hltsada:w`wv' How sad s felt when did health-related activity yesterday"

***Average score of how happy and interested***
*wave 1 respondent score
egen r`wv'hltpos2ma = rowmiss(r`wv'hlthpya r`wv'hltinta) if inw`wv'==1

egen r`wv'hltpos2a = rowmean(r`wv'hlthpya r`wv'hltinta) if r`wv'hltpos2ma==0
replace r`wv'hltpos2a = .m if mi(r`wv'hltpos2a) & (r`wv'hlthpya==.m | r`wv'hltinta==.m)
replace r`wv'hltpos2a = .d if mi(r`wv'hltpos2a) & (r`wv'hlthpya==.d | r`wv'hltinta==.d)
replace r`wv'hltpos2a = .r if mi(r`wv'hltpos2a) & (r`wv'hlthpya==.r | r`wv'hltinta==.r)   
replace r`wv'hltpos2a = .p if mi(r`wv'hltpos2a) & (r`wv'hlthpya==.p | r`wv'hltinta==.p)
replace r`wv'hltpos2a = .a if mi(r`wv'hltpos2a) & (r`wv'hlthpya==.a | r`wv'hltinta==.a)
replace r`wv'hltpos2a = .b if mi(r`wv'hltpos2a) & (r`wv'hlthpya==.b | r`wv'hltinta==.b)
replace r`wv'hltpos2a = .x if mi(r`wv'hltpos2a) & (r`wv'hlthpya==.x | r`wv'hltinta==.x)
label variable r`wv'hltpos2a "r`wv'hltpos2a:w`wv' r avg pos affect health-relat (happy, interested)"

*wave 1 spouse score
gen s`wv'hltpos2a = .
spouse r`wv'hltpos2a, result(s`wv'hltpos2a) wave(`wv')
label variable s`wv'hltpos2a "s`wv'hltpos2a:w`wv' s avg pos affect health-relat (happy, interested)"

drop r`wv'hltpos2ma

***Average score of how frustrated and sad***
*wave 1 respondent score
egen r`wv'hltneg2ma = rowmiss(r`wv'hltfrsa r`wv'hltsada) if inw`wv'==1

egen r`wv'hltneg2a = rowmean(r`wv'hltfrsa r`wv'hltsada) if r`wv'hltneg2ma==0
replace r`wv'hltneg2a = .m if mi(r`wv'hltneg2a) & (r`wv'hltfrsa==.m | r`wv'hltsada==.m)
replace r`wv'hltneg2a = .d if mi(r`wv'hltneg2a) & (r`wv'hltfrsa==.d | r`wv'hltsada==.d)
replace r`wv'hltneg2a = .r if mi(r`wv'hltneg2a) & (r`wv'hltfrsa==.r | r`wv'hltsada==.r)
replace r`wv'hltneg2a = .p if mi(r`wv'hltneg2a) & (r`wv'hltfrsa==.p | r`wv'hltsada==.p)
replace r`wv'hltneg2a = .a if mi(r`wv'hltneg2a) & (r`wv'hltfrsa==.a | r`wv'hltsada==.a)
replace r`wv'hltneg2a = .b if mi(r`wv'hltneg2a) & (r`wv'hltfrsa==.b | r`wv'hltsada==.b)
replace r`wv'hltneg2a = .x if mi(r`wv'hltneg2a) & (r`wv'hltfrsa==.x | r`wv'hltsada==.x)
label variable r`wv'hltneg2a "r`wv'hltneg2a:w`wv' r avg neg affect health-relat (frustrated, sad)"

*wave 1 spouse score
gen s`wv'hltneg2a = .
spouse r`wv'hltneg2a, result(s`wv'hltneg2a) wave(`wv')
label variable s`wv'hltneg2a "s`wv'hltneg2a:w`wv' s avg neg affect health-relat (frustrated, sad)"

drop r`wv'hltneg2ma


***travel or commute***
*wave 1 respondent
gen r`wv'trvlcom = .
missing_lasi tu028, result(r`wv'trvlcom) wave(`wv')
replace r`wv'trvlcom = .p if r`wv'proxy==1
replace r`wv'trvlcom = .a if tu001_1==. & (ee001!=. | es001_1!=. | ev001!=.)
replace r`wv'trvlcom = .b if tu028==. & (!mi(tu014) | !mi(tu020) | !mi(tu024) | !mi(tu009) | !mi(tu032) | !mi(tu036))
replace r`wv'trvlcom = 0 if tu028==2
replace r`wv'trvlcom = 1 if tu028==1
label variable r`wv'trvlcom "r`wv'trvlcom:w`wv' r traveled or commuted yesterday"
label values r`wv'trvlcom yesnocesd

*wave 1 spouse
gen s`wv'trvlcom = .
spouse r`wv'trvlcom, result(s`wv'trvlcom) wave(`wv')
label variable s`wv'trvlcom "s`wv'trvlcom:w`wv' s traveled or commuted yesterday"
label values s`wv'trvlcom yesnocesd

***minutes travel or commute***
gen h2m = tu029_hour*60 if inrange(tu029_hour,0,24)
gen m2m = tu029_minute if inrange(tu029_minute,0,60)
egen min = rowtotal(h2m m2m) if (!mi(h2m) | !mi(m2m))

*wave 1 respondent
gen r`wv'trvlcommn = .
replace r`wv'trvlcommn = .m if inw`wv'==1 & (tu029_hour==. | tu029_minute==. | tu029_hour==.e | tu029_minute==.e)
replace r`wv'trvlcommn = .d if tu029_hour==.d | tu029_minute==.d
replace r`wv'trvlcommn = .r if tu029_hour==.d | tu029_minute==.r
replace r`wv'trvlcommn = .p if r`wv'trvlcom==.p
replace r`wv'trvlcommn = .a if r`wv'trvlcom==.a
replace r`wv'trvlcommn = .b if r`wv'trvlcom==.b
replace r`wv'trvlcommn = 0 if tu028==2
replace r`wv'trvlcommn = min if inrange(min,0,1440)
label variable r`wv'trvlcommn "r`wv'trvlcommn:w`wv' minutes r traveled or commuted yesterday"

*wave 1 spouse
gen s`wv'trvlcommn = .
spouse r`wv'trvlcommn, result(s`wv'trvlcommn) wave(`wv')
label variable s`wv'trvlcommn "s`wv'trvlcommn:w`wv' minutes s traveled or commuted yesterday"

drop h2m m2m min

***Feeling when traveled or commuted yesterday***
***Happy***
*wave 1 respondent
gen r`wv'trvhpya = .
missing_lasi tu030_1, result(r`wv'trvhpya) wave(`wv')
replace r`wv'trvhpya = .p if r`wv'trvlcom==.p
replace r`wv'trvhpya = .a if r`wv'trvlcom==.a
replace r`wv'trvhpya = .b if r`wv'trvlcom==.b
replace r`wv'trvhpya = .x if r`wv'trvlcom==0
replace r`wv'trvhpya = tu030_1 if inrange(tu030_1,1,6) //1-Did not experience the feeling at all, to 6-Feeling was extremely strong
label variable r`wv'trvhpya "r`wv'trvhpya:w`wv' How happy r felt when traveled or commuted yesterday"

*wave 1 spouse
gen s`wv'trvhpya = .
spouse r`wv'trvhpya, result(s`wv'trvhpya) wave(`wv')
label variable s`wv'trvhpya "s`wv'trvhpya:w`wv' How happy s felt when traveled or commuted yesterday"

***Interested***
*wave 1 respondent
gen r`wv'trvinta = .
missing_lasi tu030_2, result(r`wv'trvinta) wave(`wv')
replace r`wv'trvinta = .p if r`wv'trvlcom==.p
replace r`wv'trvinta = .a if r`wv'trvlcom==.a
replace r`wv'trvinta = .b if r`wv'trvlcom==.b
replace r`wv'trvinta = .x if r`wv'trvlcom==0
replace r`wv'trvinta = tu030_2 if inrange(tu030_2,1,6) //1-Did not experience the feeling at all, to 6-Feeling was extremely strong
label variable r`wv'trvinta "r`wv'trvinta:w`wv' How interested r felt when traveled or commuted yesterday"

*wave 1 spouse
gen s`wv'trvinta = .
spouse r`wv'trvinta, result(s`wv'trvinta) wave(`wv')
label variable s`wv'trvinta "s`wv'trvinta:w`wv' How interested s felt when traveled or commuted yesterday"

***Frustrated***
*wave 1 respondent
gen r`wv'trvfrsa = .
missing_lasi tu030_3, result(r`wv'trvfrsa) wave(`wv')
replace r`wv'trvfrsa = .p if r`wv'trvlcom==.p
replace r`wv'trvfrsa = .a if r`wv'trvlcom==.a
replace r`wv'trvfrsa = .b if r`wv'trvlcom==.b
replace r`wv'trvfrsa = .x if r`wv'trvlcom==0
replace r`wv'trvfrsa = tu030_3 if inrange(tu030_3,1,6) //1-Did not experience the feeling at all, to 6-Feeling was extremely strong
label variable r`wv'trvfrsa "r`wv'trvfrsa:w`wv' How frustrated r felt when traveled or commuted yesterday"

*wave 1 spouse
gen s`wv'trvfrsa = .
spouse r`wv'trvfrsa, result(s`wv'trvfrsa) wave(`wv')
label variable s`wv'trvfrsa "s`wv'trvfrsa:w`wv' How frustrated s felt when traveled or commuted yesterday"

***Sad***
*wave 1 respondent
gen r`wv'trvsada = .
missing_lasi tu030_4, result(r`wv'trvsada) wave(`wv')
replace r`wv'trvsada = .p if r`wv'trvlcom==.p
replace r`wv'trvsada = .a if r`wv'trvlcom==.a
replace r`wv'trvsada = .b if r`wv'trvlcom==.b
replace r`wv'trvsada = .x if r`wv'trvlcom==0
replace r`wv'trvsada = tu030_4 if inrange(tu030_4,1,6) //1-Did not experience the feeling at all, to 6-Feeling was extremely strong
label variable r`wv'trvsada "r`wv'trvsada:w`wv' How sad r felt when traveled or commuted yesterday"

*wave 1 spouse
gen s`wv'trvsada = .
spouse r`wv'trvsada, result(s`wv'trvsada) wave(`wv')
label variable s`wv'trvsada "s`wv'trvsada:w`wv' How sad s felt when traveled or commuted yesterday"

***Average score of how happy and interested***
*wave 1 respondent score
egen r`wv'trvpos2ma = rowmiss(r`wv'trvhpya r`wv'trvinta) if inw`wv'==1

egen r`wv'trvpos2a = rowmean(r`wv'trvhpya r`wv'trvinta) if r`wv'trvpos2ma==0
replace r`wv'trvpos2a = .m if mi(r`wv'trvpos2a) & (r`wv'trvhpya==.m | r`wv'trvinta==.m)
replace r`wv'trvpos2a = .d if mi(r`wv'trvpos2a) & (r`wv'trvhpya==.d | r`wv'trvinta==.d)
replace r`wv'trvpos2a = .r if mi(r`wv'trvpos2a) & (r`wv'trvhpya==.r | r`wv'trvinta==.r)
replace r`wv'trvpos2a = .p if mi(r`wv'trvpos2a) & (r`wv'trvhpya==.p | r`wv'trvinta==.p)
replace r`wv'trvpos2a = .a if mi(r`wv'trvpos2a) & (r`wv'trvhpya==.a | r`wv'trvinta==.a)
replace r`wv'trvpos2a = .b if mi(r`wv'trvpos2a) & (r`wv'trvhpya==.b | r`wv'trvinta==.b)
replace r`wv'trvpos2a = .x if mi(r`wv'trvpos2a) & (r`wv'trvhpya==.x | r`wv'trvinta==.x)
label variable r`wv'trvpos2a "r`wv'trvpos2a:w`wv' r avg pos affect travel/commute (happy, interested)"

*wave 1 spouse score
gen s`wv'trvpos2a = .
spouse r`wv'trvpos2a, result(s`wv'trvpos2a) wave(`wv')
label variable s`wv'trvpos2a "s`wv'trvpos2a:w`wv' s avg pos affect travel/commute (happy, interested)"

drop r`wv'trvpos2ma

***Average score of how frustrated and sad***
*wave 1 respondent score
egen r`wv'trvneg2ma = rowmiss(r`wv'trvfrsa r`wv'trvsada) if inw`wv'==1

egen r`wv'trvneg2a = rowmean(r`wv'trvfrsa r`wv'trvsada) if r`wv'trvneg2ma==0
replace r`wv'trvneg2a = .m if mi(r`wv'trvneg2a) & (r`wv'trvfrsa==.m | r`wv'trvsada==.m)
replace r`wv'trvneg2a = .d if mi(r`wv'trvneg2a) & (r`wv'trvfrsa==.d | r`wv'trvsada==.d)
replace r`wv'trvneg2a = .r if mi(r`wv'trvneg2a) & (r`wv'trvfrsa==.r | r`wv'trvsada==.r)
replace r`wv'trvneg2a = .p if mi(r`wv'trvneg2a) & (r`wv'trvfrsa==.p | r`wv'trvsada==.p)
replace r`wv'trvneg2a = .a if mi(r`wv'trvneg2a) & (r`wv'trvfrsa==.a | r`wv'trvsada==.a)
replace r`wv'trvneg2a = .b if mi(r`wv'trvneg2a) & (r`wv'trvfrsa==.b | r`wv'trvsada==.b)
replace r`wv'trvneg2a = .x if mi(r`wv'trvneg2a) & (r`wv'trvfrsa==.x | r`wv'trvsada==.x)
label variable r`wv'trvneg2a "r`wv'trvneg2a:w`wv' r avg neg affect travel/commute (frustrated, sad)"

*wave 1 spouse score
gen s`wv'trvneg2a = .
spouse r`wv'trvneg2a, result(s`wv'trvneg2a) wave(`wv')
label variable s`wv'trvneg2a "s`wv'trvneg2a:w`wv' s avg neg affect travel/commute (frustrated, sad)"

drop r`wv'trvneg2ma


***spent time with friends***
*wave 1 respondent
gen r`wv'tmfrnd = .
missing_lasi tu032, result(r`wv'tmfrnd) wave(`wv')
replace r`wv'tmfrnd = .p if r`wv'proxy==1
replace r`wv'tmfrnd = .a if tu001_1==. & (ee001!=. | es001_1!=. | ev001!=.)
replace r`wv'tmfrnd = .b if tu032==. & (!mi(tu014) | !mi(tu020) | !mi(tu024) | !mi(tu028) | !mi(tu009) | !mi(tu036))
replace r`wv'tmfrnd = 0 if tu032==2
replace r`wv'tmfrnd = 1 if tu032==1
label variable r`wv'tmfrnd "r`wv'tmfrnd:w`wv' r spent time with friends yesterday"
label values r`wv'tmfrnd yesnocesd

*wave 1 spouse
gen s`wv'tmfrnd = .
spouse r`wv'tmfrnd, result(s`wv'tmfrnd) wave(`wv')
label variable s`wv'tmfrnd "s`wv'tmfrnd:w`wv' s spent time with friends yesterday"
label values s`wv'tmfrnd yesnocesd

***minutes spent time with friends***
gen h2m = tu033_hour*60 if inrange(tu033_hour,0,24)
gen m2m = tu033_minute if inrange(tu033_minute,0,60)
egen min = rowtotal(h2m m2m) if (!mi(h2m) | !mi(m2m))

*wave 1 respondent
gen r`wv'tmfrndmn = .
replace r`wv'tmfrndmn = .m if inw`wv'==1 & (tu033_hour==. | tu033_minute==. | tu033_hour==.e | tu033_minute==.e)
replace r`wv'tmfrndmn = .d if tu033_hour==.d | tu033_minute==.d
replace r`wv'tmfrndmn = .r if tu033_hour==.r | tu033_minute==.r
replace r`wv'tmfrndmn = .p if r`wv'tmfrnd==.p
replace r`wv'tmfrndmn = .a if r`wv'tmfrnd==.a
replace r`wv'tmfrndmn = .b if r`wv'tmfrnd==.b
replace r`wv'tmfrndmn = 0 if tu032==2
replace r`wv'tmfrndmn = min if inrange(min,0,1441)
label variable r`wv'tmfrndmn "r`wv'tmfrndmn:w`wv' minutes r spent with friends yesterday"

*wave 1 spouse
gen s`wv'tmfrndmn = .
spouse r`wv'tmfrndmn, result(s`wv'tmfrndmn) wave(`wv')
label variable s`wv'tmfrndmn "s`wv'tmfrndmn:w`wv' minutes s spent with friends yesterday"

drop h2m m2m min

***Feeling when spent time with friends yesterday***
***Happy***
*wave 1 respondent
gen r`wv'frnhpya = .
missing_lasi tu034_1, result(r`wv'frnhpya) wave(`wv')
replace r`wv'frnhpya = .p if r`wv'tmfrnd==.p
replace r`wv'frnhpya = .a if r`wv'tmfrnd==.a
replace r`wv'frnhpya = .b if r`wv'tmfrnd==.b
replace r`wv'frnhpya = .x if r`wv'tmfrnd==0
replace r`wv'frnhpya = tu034_1 if inrange(tu034_1,1,6) //1-Did not experience the feeling at all, to 6-Feeling was extremely strong
label variable r`wv'frnhpya "r`wv'frnhpya:w`wv' How happy r felt when spent time with friends yesterday"

*wave 1 spouse
gen s`wv'frnhpya = .
spouse r`wv'frnhpya, result(s`wv'frnhpya) wave(`wv')
label variable s`wv'frnhpya "s`wv'frnhpya:w`wv' How happy s felt when spent time with friends yesterday"

***Interested***
*wave 1 respondent
gen r`wv'frninta = .
missing_lasi tu034_2, result(r`wv'frninta) wave(`wv')
replace r`wv'frninta = .p if r`wv'tmfrnd==.p
replace r`wv'frninta = .a if r`wv'tmfrnd==.a
replace r`wv'frninta = .b if r`wv'tmfrnd==.b
replace r`wv'frninta = .x if r`wv'tmfrnd==0
replace r`wv'frninta = tu034_2 if inrange(tu034_2,1,6) //1-Did not experience the feeling at all, to 6-Feeling was extremely strong
label variable r`wv'frninta "r`wv'frninta:w`wv' How interested r felt when spent time with friends yesterday"

*wave 1 spouse
gen s`wv'frninta = .
spouse r`wv'frninta, result(s`wv'frninta) wave(`wv')
label variable s`wv'frninta "s`wv'frninta:w`wv' How interested s felt when spent time with friends yesterday"

***Frustrated***
*wave 1 respondent
gen r`wv'frnfrsa = .
missing_lasi tu034_3, result(r`wv'frnfrsa) wave(`wv')
replace r`wv'frnfrsa = .p if r`wv'tmfrnd==.p
replace r`wv'frnfrsa = .a if r`wv'tmfrnd==.a
replace r`wv'frnfrsa = .b if r`wv'tmfrnd==.b
replace r`wv'frnfrsa = .x if r`wv'tmfrnd==0
replace r`wv'frnfrsa = tu034_3 if inrange(tu034_3,1,6) //1-Did not experience the feeling at all, to 6-Feeling was extremely strong
label variable r`wv'frnfrsa "r`wv'frnfrsa:w`wv' How frustrated r felt when spent time with friends yesterday"

*wave 1 spouse
gen s`wv'frnfrsa = .
spouse r`wv'frnfrsa, result(s`wv'frnfrsa) wave(`wv')
label variable s`wv'frnfrsa "s`wv'frnfrsa:w`wv' How frustrated s felt when spent time with friends yesterday"

***Sad***
*wave 1 respondent
gen r`wv'frnsada = .
missing_lasi tu034_4, result(r`wv'frnsada) wave(`wv')
replace r`wv'frnsada = .p if r`wv'tmfrnd==.p
replace r`wv'frnsada = .a if r`wv'tmfrnd==.a
replace r`wv'frnsada = .b if r`wv'tmfrnd==.b
replace r`wv'frnsada = .x if r`wv'tmfrnd==0
replace r`wv'frnsada = tu034_4 if inrange(tu034_4,1,6) //1-Did not experience the feeling at all, to 6-Feeling was extremely strong
label variable r`wv'frnsada "r`wv'frnsada:w`wv' How sad r felt when spent time with friends yesterday"

*wave 1 spouse
gen s`wv'frnsada = .
spouse r`wv'frnsada, result(s`wv'frnsada) wave(`wv')
label variable s`wv'frnsada "s`wv'frnsada:w`wv' How sad s felt when spent time with friends yesterday"

**Average score of how happy and interested**
*wave 1 respondent score
egen r`wv'frnpos2ma = rowmiss(r`wv'frnhpya r`wv'frninta) if inw`wv'==1

egen r`wv'frnpos2a = rowmean(r`wv'frnhpya r`wv'frninta) if r`wv'frnpos2ma==0
replace r`wv'frnpos2a = .m if mi(r`wv'frnpos2a) & (r`wv'frnhpya==.m | r`wv'frninta==.m)
replace r`wv'frnpos2a = .d if mi(r`wv'frnpos2a) & (r`wv'frnhpya==.d | r`wv'frninta==.d)
replace r`wv'frnpos2a = .r if mi(r`wv'frnpos2a) & (r`wv'frnhpya==.r | r`wv'frninta==.r)
replace r`wv'frnpos2a = .p if mi(r`wv'frnpos2a) & (r`wv'frnhpya==.p | r`wv'frninta==.p)
replace r`wv'frnpos2a = .a if mi(r`wv'frnpos2a) & (r`wv'frnhpya==.a | r`wv'frninta==.a)
replace r`wv'frnpos2a = .b if mi(r`wv'frnpos2a) & (r`wv'frnhpya==.b | r`wv'frninta==.b)
replace r`wv'frnpos2a = .x if mi(r`wv'frnpos2a) & (r`wv'frnhpya==.x | r`wv'frninta==.x)
label variable r`wv'frnpos2a "r`wv'frnpos2a:w`wv' r avg pos affect time w/ friends (happy, interested)"

*wave 1 spouse score
gen s`wv'frnpos2a = .
spouse r`wv'frnpos2a, result(s`wv'frnpos2a) wave(`wv')
label variable s`wv'frnpos2a "s`wv'frnpos2a:w`wv' s avg pos affect time w/ friends (happy, interested)"

drop r`wv'frnpos2ma

***Average score of how frustrated and sad***
*wave 1 respondent score
egen r`wv'frnneg2ma = rowmiss(r`wv'frnfrsa r`wv'frnsada) if inw`wv'==1

egen r`wv'frnneg2a = rowmean(r`wv'frnfrsa r`wv'frnsada) if r`wv'frnneg2ma==0
replace r`wv'frnneg2a = .m if mi(r`wv'frnneg2a) & (r`wv'frnfrsa==.m | r`wv'frnsada==.m)
replace r`wv'frnneg2a = .d if mi(r`wv'frnneg2a) & (r`wv'frnfrsa==.d | r`wv'frnsada==.d)
replace r`wv'frnneg2a = .r if mi(r`wv'frnneg2a) & (r`wv'frnfrsa==.r | r`wv'frnsada==.r)
replace r`wv'frnneg2a = .p if mi(r`wv'frnneg2a) & (r`wv'frnfrsa==.p | r`wv'frnsada==.p)
replace r`wv'frnneg2a = .a if mi(r`wv'frnneg2a) & (r`wv'frnfrsa==.a | r`wv'frnsada==.a)
replace r`wv'frnneg2a = .b if mi(r`wv'frnneg2a) & (r`wv'frnfrsa==.b | r`wv'frnsada==.b)
replace r`wv'frnneg2a = .x if mi(r`wv'frnneg2a) & (r`wv'frnfrsa==.x | r`wv'frnsada==.x)
label variable r`wv'frnneg2a "r`wv'frnneg2a:w`wv' r avg neg affect time w/ friends (frustrated, sad)"

*wave 1 spouse score
gen s`wv'frnneg2a = .
spouse r`wv'frnneg2a, result(s`wv'frnneg2a) wave(`wv')
label variable s`wv'frnneg2a "s`wv'frnneg2a:w`wv' s avg neg affect time w/ friends (frustrated, sad)"

drop r`wv'frnneg2ma


***spent time at home by themself***
*wave 1 respondent
gen r`wv'tmself = .
missing_lasi tu036, result(r`wv'tmself) wave(`wv')
replace r`wv'tmself = .p if r`wv'proxy==1
replace r`wv'tmself = .a if tu001_1==. & (ee001!=. | es001_1!=. | ev001!=.)
*replace r`wv'tmself = .b if tu036==. & (!mi(tu014) | !mi(tu020) | !mi(tu024) | !mi(tu028) | !mi(tu032) | !mi(tu009))
replace r`wv'tmself = 0 if tu036==2
replace r`wv'tmself = 1 if tu036==1
label variable r`wv'tmself "r`wv'tmself:w`wv' r spent time home by themself yesterday"
label values r`wv'tmself yesnocesd

*wave 1 spouse
gen s`wv'tmself = .
spouse r`wv'tmself, result(s`wv'tmself) wave(`wv')
label variable s`wv'tmself "s`wv'tmself:w`wv' s spent time home by themself yesterday"
label values s`wv'tmself yesnocesd

***minutes spent time at home by themself***
gen h2m = tu037_hour*60 if inrange(tu037_hour,0,24)
gen m2m = tu037_minute if inrange(tu037_minute,0,60)
egen min = rowtotal(h2m m2m) if (!mi(h2m) | !mi(m2m))

*wave 1 respondent
gen r`wv'tmselfmn = .
replace r`wv'tmselfmn = .m if inw`wv'==1 & (tu037_hour==. | tu037_minute==. | tu037_hour==.e | tu037_minute==.e)
replace r`wv'tmselfmn = .d if tu037_hour==.d | tu037_minute==.d
replace r`wv'tmselfmn = .r if tu037_hour==.r | tu037_minute==.r
replace r`wv'tmselfmn = .p if r`wv'tmself==.p
replace r`wv'tmselfmn = .a if r`wv'tmself==.a
*replace r`wv'tmselfmn = .b if r`wv'tmself==.b
replace r`wv'tmselfmn = 0 if tu036==2
replace r`wv'tmselfmn = min if inrange(min,0,1440)
label variable r`wv'tmselfmn "r`wv'tmselfmn:w`wv' minutes r spent home by themself yesterday"

*wave 1 spouse
gen s`wv'tmselfmn = .
spouse r`wv'tmselfmn, result(s`wv'tmselfmn) wave(`wv')
label variable s`wv'tmselfmn "s`wv'tmselfmn:w`wv' minutes s spent home by themself yesterday"

drop h2m m2m min

***Feeling when spent time at home by themself yesterday***
***Happy***
*wave 1 respondent
gen r`wv'slfhpya = .
missing_lasi tu038_1, result(r`wv'slfhpya) wave(`wv')
replace r`wv'slfhpya = .p if r`wv'tmself==.p
replace r`wv'slfhpya = .a if r`wv'tmself==.a
*replace r`wv'slfhpya = .b if r`wv'tmself==.b
replace r`wv'slfhpya = .x if r`wv'tmself==0
replace r`wv'slfhpya = tu038_1 if inrange(tu038_1,1,6) //1-Did not experience the feeling at all, to 6-Feeling was extremely strong
label variable r`wv'slfhpya "r`wv'slfhpya:w`wv' How happy r felt when spent time at home by themself yesterday"

*wave 1 spouse
gen s`wv'slfhpya = .
spouse r`wv'slfhpya, result(s`wv'slfhpya) wave(`wv')
label variable s`wv'slfhpya "s`wv'slfhpya:w`wv' How happy s felt when spent time at home by themself yesterday"

***Interested***
*wave 1 respondent
gen r`wv'slfinta = .
missing_lasi tu038_2, result(r`wv'slfinta) wave(`wv')
replace r`wv'slfinta = .p if r`wv'tmself==.p
replace r`wv'slfinta = .a if r`wv'tmself==.a
*replace r`wv'slfinta = .b if r`wv'tmself==.b
replace r`wv'slfinta = .x if r`wv'tmself==0
replace r`wv'slfinta = tu038_2 if inrange(tu038_2,1,6) //1-Did not experience the feeling at all, to 6-Feeling was extremely strong
label variable r`wv'slfinta "r`wv'slfinta:w`wv' How interested r felt when spent time at home by themself yesterday"

*wave 1 spouse
gen s`wv'slfinta = .
spouse r`wv'slfinta, result(s`wv'slfinta) wave(`wv')
label variable s`wv'slfinta "s`wv'slfinta:w`wv' How interested s felt when spent time at home by themself yesterday"

***Frustrated***
*wave 1 respondent
gen r`wv'slffrsa = .
missing_lasi tu038_3, result(r`wv'slffrsa) wave(`wv')
replace r`wv'slffrsa = .p if r`wv'tmself==.p
replace r`wv'slffrsa = .a if r`wv'tmself==.a
*replace r`wv'slffrsa = .b if r`wv'tmself==.b
replace r`wv'slffrsa = .x if r`wv'tmself==0
replace r`wv'slffrsa = tu038_3 if inrange(tu038_3,1,6) //1-Did not experience the feeling at all, to 6-Feeling was extremely strong
label variable r`wv'slffrsa "r`wv'slffrsa:w`wv' How frustrated r felt when spent time at home by themself yesterday"

*wave 1 spouse
gen s`wv'slffrsa = .
spouse r`wv'slffrsa, result(s`wv'slffrsa) wave(`wv')
label variable s`wv'slffrsa "s`wv'slffrsa:w`wv' How frustrated s felt when spent time at home by themself yesterday"

***Sad***
*wave 1 respondent
gen r`wv'slfsada = .
missing_lasi tu038_4, result(r`wv'slfsada) wave(`wv')
replace r`wv'slfsada = .p if r`wv'tmself==.p
replace r`wv'slfsada = .a if r`wv'tmself==.a
*replace r`wv'slfsada = .b if r`wv'tmself==.b
replace r`wv'slfsada = .x if r`wv'tmself==0
replace r`wv'slfsada = tu038_4 if inrange(tu038_4,1,6) //1-Did not experience the feeling at all, to 6-Feeling was extremely strong
label variable r`wv'slfsada "r`wv'slfsada:w`wv' How sad r felt when spent time at home by themself yesterday"

*wave 1 spouse
gen s`wv'slfsada = .
spouse r`wv'slfsada, result(s`wv'slfsada) wave(`wv')
label variable s`wv'slfsada "s`wv'slfsada:w`wv' How sad s felt when spent time at home by themself yesterday"

***Average score of how happy and interested***
*wave 1 respondent score
egen r`wv'slfpos2ma = rowmiss(r`wv'slfhpya r`wv'slfinta) if inw`wv'==1

egen r`wv'slfpos2a = rowmean(r`wv'slfhpya r`wv'slfinta) if r`wv'slfpos2ma==0
replace r`wv'slfpos2a = .m if mi(r`wv'slfpos2a) & (r`wv'slfhpya==.m | r`wv'slfinta==.m)
replace r`wv'slfpos2a = .d if mi(r`wv'slfpos2a) & (r`wv'slfhpya==.d | r`wv'slfinta==.d)
replace r`wv'slfpos2a = .r if mi(r`wv'slfpos2a) & (r`wv'slfhpya==.r | r`wv'slfinta==.r)
replace r`wv'slfpos2a = .p if mi(r`wv'slfpos2a) & (r`wv'slfhpya==.p | r`wv'slfinta==.p)
replace r`wv'slfpos2a = .a if mi(r`wv'slfpos2a) & (r`wv'slfhpya==.a | r`wv'slfinta==.a)
*replace r`wv'slfpos2a = .b if mi(r`wv'slfpos2a) & (r`wv'slfhpya==.b | r`wv'slfinta==.b)
replace r`wv'slfpos2a = .x if mi(r`wv'slfpos2a) & (r`wv'slfhpya==.x | r`wv'slfinta==.x)
label variable r`wv'slfpos2a "r`wv'slfpos2a:w`wv' r avg pos affect time home alone (happy, interested)"

*wave 1 spouse score
gen s`wv'slfpos2a = .
spouse r`wv'slfpos2a, result(s`wv'slfpos2a) wave(`wv')
label variable s`wv'slfpos2a "s`wv'slfpos2a:w`wv' s avg pos affect time home alone (happy, interested)"

drop r`wv'slfpos2ma

***Average score of how frustrated and sad***
*wave 1 respondent score
egen r`wv'slfneg2ma = rowmiss(r`wv'slffrsa r`wv'slfsada) if inw`wv'==1

egen r`wv'slfneg2a = rowmean(r`wv'slffrsa r`wv'slfsada) if r`wv'slfneg2ma==0
replace r`wv'slfneg2a = .m if mi(r`wv'slfneg2a) & (r`wv'slffrsa==.m | r`wv'slfsada==.m)
replace r`wv'slfneg2a = .d if mi(r`wv'slfneg2a) & (r`wv'slffrsa==.d | r`wv'slfsada==.d)
replace r`wv'slfneg2a = .r if mi(r`wv'slfneg2a) & (r`wv'slffrsa==.r | r`wv'slfsada==.r)
replace r`wv'slfneg2a = .p if mi(r`wv'slfneg2a) & (r`wv'slffrsa==.p | r`wv'slfsada==.p)
replace r`wv'slfneg2a = .a if mi(r`wv'slfneg2a) & (r`wv'slffrsa==.a | r`wv'slfsada==.a)
*replace r`wv'slfneg2a = .b if mi(r`wv'slfneg2a) & (r`wv'slffrsa==.b | r`wv'slfsada==.b)
replace r`wv'slfneg2a = .x if mi(r`wv'slfneg2a) & (r`wv'slffrsa==.x | r`wv'slfsada==.x)
label variable r`wv'slfneg2a "r`wv'slfneg2a:w`wv' r avg neg affect time home alone (frustrated, sad)"

*wave 1 spouse score
gen s`wv'slfneg2a = .
spouse r`wv'slfneg2a, result(s`wv'slfneg2a) wave(`wv')
label variable s`wv'slfneg2a "s`wv'slfneg2a:w`wv' s avg neg affect time home alone (frustrated, sad)"

drop r`wv'slfneg2ma
drop tu001_1 tu002_2

***************************************


***drop LASI  file raw variables***
drop `psy_w1_ind' 



****safe****
label define safe ///
    1 "1.completely safe"  ///
    2 "2.safe"  ///
    3 "3.not very safe"  ///
    4 "4.not safe at all"  ///
    .d ".d:DK"  ///
    .r ".r:RF"  ///
    .m ".m:oth missing" ///
    .p ".p:proxy"
   
****Discrimination****
label define resp /// 
    1 "1.never" /// 
    2 "2.less than once a year" /// 
    3 "3.a few times a year" /// 
    4 "4.a few times a month" /// 
    5 "5.at least once a week" /// 
    6 "6.almost everyday" /// 
    .m ".m:oth missing" ///
    .d ".d:DK" ///
    .r ".r:RF" ///
    .p ".p:Proxy" ///
    .s ".s:Skipped" ///
    .u ".u:Unmar" ///
    .v ".v:Sp Nr" 

****Yes no stress****
label define yesnostr /// 
		0 "0.no" /// 
		1 "1.yes" /// 
		.m ".m:oth missing" /// 
		.n ".n:no discrimination" /// 
		.d ".d:DK" /// 
		.r ".r:RF" /// 
		.p ".p:proxy" /// 
		.u ".u:Unmar" /// 
		.v ".v:Sp Nr" 

****Rating health condition****
label define ratestr /// 
		1 "1.very good" /// 
		2 "2.good" /// 
		3 "3.fair" /// 
		4 "4.poor" /// 
		5 "5.very poor" /// 
		.m ".m:oth missing" /// 
		.d ".d:DK" /// 
		.r ".r:RF" /// 
		.u ".u:Unmar" /// 
		.v ".v:Sp Nr" 		
		
***Financial situation***
label define finstr /// 
		1 "1.pretty well off" /// 
		2 "2.average" /// 
		3 "3.poor" /// 
		.n ".n:it varied" /// 
		.m ".m:oth missing" /// 
		.d ".d:DK" /// 
		.r ".r:RF" /// 
		.u ".u:Unmar" /// 
		.v ".v:Sp Nr" 				

*set wave number
local wv=1

***merge with  data***
local strs_w1_ind	fs521 fs522 fs523 fs524 fs525 fs526 fs527s1 fs527s2 fs527s3 /// 
									fs527s4 fs527s5 fs527s6 fs527s7 fs527s8 fs527s9 fs606 fs607 ///
									ht231 ht232_proxy ht233 ht234 ht235 rproxy
									
merge 1:1 prim_key using "$wave_1_ind_bm", keepusing(`strs_w1_ind') nogen



*********************************************************************
***Neighborhood Physical Disorder / Social Cohesion***
*********************************************************************
*All psychosocial measures do not allow proxy interviews (FS521 onward)

***Safe from crime/violence at home alone 
gen r`wv'sfhome_l=.
missing_lasi fs606, result(r`wv'sfhome_l) wave(`wv')
replace r`wv'sfhome_l=.p if rproxy==1
replace r`wv'sfhome_l = fs606 if inrange(fs606,1,4)
label variable r`wv'sfhome_l "r`wv'sfhome_l:w`wv' r safe from crime/violence when home alone"
label values r`wv'sfhome_l safe

*spouse
gen s`wv'sfhome_l=.
spouse r`wv'sfhome_l, result(s`wv'sfhome_l) wave(`wv')
label variable s`wv'sfhome_l "s`wv'sfhome_l:w`wv' s safe from crime/violence when home alone"
label values s`wv'sfhome_l safe

***Feels safe walking alone
*Note: HRS scale is 1-7 (safe to afraid); LASI is 1-4
gen r`wv'afwalk_l=.
missing_lasi fs607, result(r`wv'afwalk_l) wave(`wv')
replace r`wv'afwalk_l =.p if rproxy==1
replace r`wv'afwalk_l = fs607 if inrange(fs607,1,4)
label variable r`wv'afwalk_l "r`wv'afwalk_l:w`wv' r safe walking alone in this area"
label values r`wv'afwalk_l safe

*Spouse
gen s`wv'afwalk_l=.
spouse r`wv'afwalk_l, result(s`wv'afwalk_l) wave(`wv')
label variable s`wv'afwalk_l "s`wv'afwalk_l:w`wv' s safe walking alone in this area"
label values s`wv'afwalk_l safe

*********************************************************************
***Childhood Stressful Events***
*********************************************************************

***Health condition while growing up 
*NOTE: Categories differ from HRS (1.excellent, v good, above average, fair, 5.poor)
*NOTE: LASI (1.v good, good, fair, poor, 5.v poor)
gen rachshlta=.
missing_lasi ht231 ht232_proxy, result(rachshlta) wave(`wv')
replace rachshlta=1 if ht231==1 | ht232_proxy==1
replace rachshlta=2 if ht231==2 | ht232_proxy==2
replace rachshlta=3 if ht231==3 | ht232_proxy==3
replace rachshlta=4 if ht231==4 | ht232_proxy==4
replace rachshlta=5 if ht231==5 | ht232_proxy==5
label variable rachshlta "rachshlta: r childhood health status"
label values rachshlta ratestr

*Spouse
gen s`wv'chshlta=.
spouse rachshlta, result(s`wv'chshlta) wave(`wv')
label variable s`wv'chshlta "s`wv'chshlta:w`wv' s childhood health status"
label values s`wv'chshlta ratestr

***Bedridden more than 1 month in childhood
gen rabedrdch=.
missing_lasi ht233, result(rabedrdch) wave(`wv')
replace rabedrdch=0 if ht233==2
replace rabedrdch=1 if ht233==1
label variable rabedrdch "rabedrdch: r bedridden more than 1 month in childhood"
label values rabedrdch yesnostr

*Spouse
gen s`wv'bedrdch=.
spouse rabedrdch, result(s`wv'bedrdch) wave(`wv')
label variable s`wv'bedrdch "s`wv'bedrdch:w`wv' s bedridden more than 1 month in childhood"
label values s`wv'bedrdch yesnostr

***Missed school for 1+ month due to health
gen ramischlth=.
missing_lasi ht234, result(ramischlth) wave(`wv')
replace ramischlth=0 if ht234==2
replace ramischlth=1 if ht234==1
label variable ramischlth "ramischlth: r missed school for 1+ mo due to health"
label values ramischlth yesnostr

*Spouse
gen s`wv'mischlth=.
spouse ramischlth, result(s`wv'mischlth) wave(`wv')
label variable s`wv'mischlth "s`wv'mischlth:w`wv' s missed school for 1+ mo due to health"
label values s`wv'mischlth yesnostr

***Financial situation while growing up
gen rafinanch=.
missing_lasi ht235, result(rafinanch) wave(`wv')
replace rafinanch = .n if ht235 == 4
replace rafinanch=ht235 if inrange(ht235,1,3)
label variable rafinanch "rafinanch: financial situation while r was growing up"
label values rafinanch finstr

*Spouse
gen s`wv'financh=.
spouse rafinanch, result(s`wv'financh) wave(`wv')
label variable s`wv'financh "s`wv'financh:w`wv' financial situation while s was growing up"
label values s`wv'financh finstr

*********************************************************************
***Everyday Discrimination***
*********************************************************************

***Treated with less courtesy or respect
gen r`wv'lsrspct=.
missing_lasi fs521, result(r`wv'lsrspct) wave(`wv')
replace r`wv'lsrspct=.p if rproxy==1
replace r`wv'lsrspct= 7 - fs521 if inrange(fs521,1,6)
label variable r`wv'lsrspct "r`wv'lsrspct:w`wv' r was treated with less courtesy or respect"
label values r`wv'lsrspct resp

*Sposue
gen s`wv'lsrspct=.
spouse r`wv'lsrspct, result(s`wv'lsrspct) wave(`wv')
label variable s`wv'lsrspct "s`wv'lsrspct:w`wv' s was treated with less courtesy or respect" 
label values s`wv'lsrspct resp

***Received poorer service 
gen r`wv'prsrvc=.
missing_lasi fs522, result(r`wv'prsrvc) wave(`wv')
replace r`wv'prsrvc=.p if rproxy==1
replace r`wv'prsrvc= 7 - fs522 if inrange(fs522,1,6)
label variable r`wv'prsrvc "r`wv'prsrvc:w`wv' r received poorer service at restaurants/stores"
label values r`wv'prsrvc resp

*Spouse
gen s`wv'prsrvc=.
spouse r`wv'prsrvc, result(s`wv'prsrvc) wave(`wv')
label variable s`wv'prsrvc "s`wv'prsrvc:w`wv' s received poorer service at restaurants/stores"
label values s`wv'prsrvc resp

***People act as if you are not smart
gen r`wv'notsmrt=.
missing_lasi fs523, result(r`wv'notsmrt) wave(`wv')
replace r`wv'notsmrt=.p if rproxy==1
replace r`wv'notsmrt= 7 - fs523 if inrange(fs523,1,6)
label variable r`wv'notsmrt "r`wv'notsmrt:w`wv' people act as if r is not smart"
label values r`wv'notsmrt resp

*Spouse
gen s`wv'notsmrt=.
spouse r`wv'notsmrt, result(s`wv'notsmrt) wave(`wv')
label variable s`wv'notsmrt "s`wv'notsmrt:w`wv' people act as if s is not smart"
label values s`wv'notsmrt resp

***People act afraid of you
gen r`wv'actafd=.
missing_lasi fs524, result(r`wv'actafd) wave(`wv')
replace r`wv'actafd=.p if rproxy==1
replace r`wv'actafd= 7 - fs524 if inrange(fs524,1,6)
label variable r`wv'actafd "r`wv'actafd:w`wv' people act afraid of r"
label values r`wv'actafd resp

*Spouse
gen s`wv'actafd=.
spouse r`wv'actafd, result(s`wv'actafd) wave(`wv')
label variable s`wv'actafd "s`wv'actafd:w`wv' people act afraid of s"
label values s`wv'actafd resp

***Threatened or harrassed
gen r`wv'harass=.
missing_lasi fs525, result(r`wv'harass) wave(`wv')
replace r`wv'harass=.p if rproxy==1
replace r`wv'harass= 7 - fs525 if inrange(fs525,1,6)
label variable r`wv'harass "r`wv'harass:w`wv' r was threatened or harassed"
label values r`wv'harass resp

*Spouse
gen s`wv'harass=.
spouse r`wv'harass, result(s`wv'harass) wave(`wv')
label variable s`wv'harass "s`wv'harass:w`wv' s was threatened or harassed"
label values s`wv'harass resp

***Received poorer service from doctors or hospitals
gen r`wv'prtrmt=.
missing_lasi fs526, result(r`wv'prtrmt) wave(`wv')
replace r`wv'prtrmt=.p if rproxy==1
replace r`wv'prtrmt= 7 - fs526 if inrange(fs526,1,6)
label variable r`wv'prtrmt "r`wv'prtrmt:w`wv' r received poorer service from doctors/hospitals"
label values r`wv'prtrmt resp

*Spouse
gen s`wv'prtrmt=.
spouse r`wv'prtrmt, result(s`wv'prtrmt) wave(`wv')
label variable s`wv'prtrmt "s`wv'prtrmt:w`wv' s received poorer service from doctors/hospitals"
label values s`wv'prtrmt resp

/***Summary discrimination
recode r`wv'lsrspct (1=6) (2=5) (3=4) (4=3) (5=2) (6=1), gen(xr`wv'lsrspct)
recode r`wv'prsrvc  (1=6) (2=5) (3=4) (4=3) (5=2) (6=1), gen(xr`wv'prsrvc)
recode r`wv'notsmrt (1=6) (2=5) (3=4) (4=3) (5=2) (6=1), gen(xr`wv'notsmrt)
recode r`wv'actafd  (1=6) (2=5) (3=4) (4=3) (5=2) (6=1), gen(xr`wv'actafd)
recode r`wv'harass  (1=6) (2=5) (3=4) (4=3) (5=2) (6=1), gen(xr`wv'harass)
recode r`wv'prtrmt  (1=6) (2=5) (3=4) (4=3) (5=2) (6=1), gen(xr`wv'prtrmt)*/

*Missing
egen r`wv'dscrimm = rowmiss(r`wv'lsrspct r`wv'prsrvc r`wv'notsmrt r`wv'actafd r`wv'harass r`wv'prtrmt) if inw`wv'==1
replace r`wv'dscrimm = .p if rproxy==1 & inw`wv'==1
label variable r`wv'dscrimm "r`wv'dscrimm:w`wv' r 6-item discrimination summary mean score missings"

*Spouse missing
gen s`wv'dscrimm=.
spouse r`wv'dscrimm, result(s`wv'dscrimm) wave(`wv')
label variable s`wv'dscrimm "s`wv'dscrimm:w`wv' s 6-item discrimination summary mean score missings"

*Summary mean score
egen r`wv'dscrim = rowmean(r`wv'lsrspct r`wv'prsrvc r`wv'notsmrt r`wv'actafd r`wv'harass r`wv'prtrmt)  if inw`wv'==1
replace r`wv'dscrim = .m if r`wv'dscrimm==6 & inw`wv'==1
replace r`wv'dscrim = .p if rproxy==1 & inw`wv'==1
label variable r`wv'dscrim "r`wv'dscrim:w`wv' r 6-item discrimination summary mean score"

*Spouse summary mean score
gen s`wv'dscrim=.
spouse r`wv'dscrim, result(s`wv'dscrim) wave(`wv')
label variable s`wv'dscrim "s`wv'dscrim:w`wv' s 6-item discrimination summary mean score"

*drop xr`wv'lsrspct xr`wv'prsrvc xr`wv'notsmrt xr`wv'actafd xr`wv'harass xr`wv'prtrmt


*********************************************************************
***Reasons for Everyday Discrimination***
*********************************************************************

***Discrimination reason: Age
gen r`wv'dcage=.
missing_lasi fs527s1, result(r`wv'dcage) wave(`wv')
replace r`wv'dcage=.p if rproxy==1
replace r`wv'dcage=.n if r`wv'lsrspct==1 & r`wv'prsrvc==1 & r`wv'notsmrt==1 & r`wv'actafd==1 & r`wv'harass==1 & r`wv'prtrmt==1
replace r`wv'dcage=fs527s1 if inrange(fs527s1,0,1)
label variable r`wv'dcage "r`wv'dcage:w`wv' r discrimination reason:age"
label values r`wv'dcage yesnostr

*Spouse
gen s`wv'dcage=.
spouse r`wv'dcage, result(s`wv'dcage) wave(`wv')
label variable s`wv'dcage "s`wv'dcage:w`wv' s discrimination reason:age" 
label values s`wv'dcage yesnostr

***Discrimination reason: Gender
gen r`wv'dcgendr=.
missing_lasi fs527s2, result(r`wv'dcgendr) wave(`wv')
replace r`wv'dcgendr=.p if rproxy==1
replace r`wv'dcgendr=.n if r`wv'lsrspct==1 & r`wv'prsrvc==1 & r`wv'notsmrt==1 & r`wv'actafd==1 & r`wv'harass==1 & r`wv'prtrmt==1
replace r`wv'dcgendr=fs527s2 if inrange(fs527s2,0,1)
label variable r`wv'dcgendr "r`wv'dcgendr:w`wv' r discrimination reason:gender"
label values r`wv'dcgendr yesnostr

*Spouse
gen s`wv'dcgendr=.
spouse r`wv'dcgendr, result(s`wv'dcgendr) wave(`wv')
label variable s`wv'dcgendr "s`wv'dcgendr:w`wv' s discrimination reason:gender"
label values s`wv'dcgendr yesnostr

***Discrimination reason: Religion
gen r`wv'dcrlgon=.
missing_lasi fs527s3, result(r`wv'dcrlgon) wave(`wv')
replace r`wv'dcrlgon=.p if rproxy==1
replace r`wv'dcrlgon=.n if r`wv'lsrspct==1 & r`wv'prsrvc==1 & r`wv'notsmrt==1 & r`wv'actafd==1 & r`wv'harass==1 & r`wv'prtrmt==1
replace r`wv'dcrlgon=fs527s3 if inrange(fs527s3,0,1)
label variable r`wv'dcrlgon "r`wv'dcrlgon:w`wv' r discrimination reason:religion"
label values r`wv'dcrlgon yesnostr

*Spouse
gen s`wv'dcrlgon=.
spouse r`wv'dcrlgon, result(s`wv'dcrlgon) wave(`wv')
label variable s`wv'dcrlgon "s`wv'dcrlgon:w`wv' s discrimination reason:religion"
label values s`wv'dcrlgon yesnostr

***Discrimination reason: Caste
gen r`wv'dccaste=.
missing_lasi fs527s4, result(r`wv'dccaste) wave(`wv')
replace r`wv'dccaste=.p if rproxy==1
replace r`wv'dccaste=.n if r`wv'lsrspct==1 & r`wv'prsrvc==1 & r`wv'notsmrt==1 & r`wv'actafd==1 & r`wv'harass==1 & r`wv'prtrmt==1
replace r`wv'dccaste=fs527s4 if inrange(fs527s4,0,1)
label variable r`wv'dccaste "r`wv'dccaste:w`wv' r discrimination reason:caste"
label values r`wv'dccaste yesnostr

*Spouse
gen s`wv'dccaste=.
spouse r`wv'dccaste, result(s`wv'dccaste) wave(`wv')
label variable s`wv'dccaste "s`wv'dccaste:w`wv' s discrimination reason:caste"
label values s`wv'dccaste yesnostr

***Discrimination reason: Weight
gen r`wv'dcwegt=.
missing_lasi fs527s5, result(r`wv'dcwegt) wave(`wv')
replace r`wv'dcwegt=.p if rproxy==1
replace r`wv'dcwegt=.n if r`wv'lsrspct==1 & r`wv'prsrvc==1 & r`wv'notsmrt==1 & r`wv'actafd==1 & r`wv'harass==1 & r`wv'prtrmt==1
replace r`wv'dcwegt=fs527s5 if inrange(fs527s5,0,1)
label variable r`wv'dcwegt "r`wv'dcwegt:w`wv' r discrimination reason:weight"
label values r`wv'dcwegt yesnostr

*Spouse
gen s`wv'dcwegt=.
spouse r`wv'dcwegt, result(s`wv'dcwegt) wave(`wv')
label variable s`wv'dcwegt "s`wv'dcwegt:w`wv' s discrimination reason:weight"
label values s`wv'dcwegt yesnostr

***Discrimination reason: Physical disability
gen r`wv'dcdstat=.
missing_lasi fs527s6, result(r`wv'dcdstat) wave(`wv')
replace r`wv'dcdstat=.p if rproxy==1
replace r`wv'dcdstat=.n if r`wv'lsrspct==1 & r`wv'prsrvc==1 & r`wv'notsmrt==1 & r`wv'actafd==1 & r`wv'harass==1 & r`wv'prtrmt==1
replace r`wv'dcdstat=fs527s6 if inrange(fs527s6,0,1)
label variable r`wv'dcdstat "r`wv'dcdstat:w`wv' r discrimination reason:physical activity"
label values r`wv'dcdstat yesnostr

*Spouse
gen s`wv'dcdstat=.
spouse r`wv'dcdstat, result(s`wv'dcdstat) wave(`wv')
label variable s`wv'dcdstat "s`wv'dcdstat:w`wv' s discrimination reason:physical activity"
label values s`wv'dcdstat yesnostr 

***Discrimination reason: Other aspect of physical appearance
gen r`wv'dcaprnc=.
missing_lasi fs527s7, result(r`wv'dcaprnc) wave(`wv')
replace r`wv'dcaprnc=.p if rproxy==1
replace r`wv'dcaprnc=.n if r`wv'lsrspct==1 & r`wv'prsrvc==1 & r`wv'notsmrt==1 & r`wv'actafd==1 & r`wv'harass==1 & r`wv'prtrmt==1
replace r`wv'dcaprnc=fs527s7 if inrange(fs527s7,0,1)
label variable r`wv'dcaprnc "r`wv'dcaprnc:w`wv' r discrimination reason:physical appearance"
label values r`wv'dcaprnc yesnostr

*Spouse
gen s`wv'dcaprnc=.
spouse r`wv'dcaprnc, result(s`wv'dcaprnc) wave(`wv')
label variable s`wv'dcaprnc "s`wv'dcaprnc:w`wv' s discrimination reason:physical appearance"
label values s`wv'dcaprnc yesnostr

***Discrimination reason: Financial status
gen r`wv'dcfinan=.
missing_lasi fs527s8, result(r`wv'dcfinan) wave(`wv')
replace r`wv'dcfinan=.p if rproxy==1
replace r`wv'dcfinan=.n if r`wv'lsrspct==1 & r`wv'prsrvc==1 & r`wv'notsmrt==1 & r`wv'actafd==1 & r`wv'harass==1 & r`wv'prtrmt==1
replace r`wv'dcfinan=fs527s8 if inrange(fs527s8,0,1)
label variable r`wv'dcfinan "r`wv'dcfinan:w`wv' r discrimination reason:financial status"
label values r`wv'dcfinan yesnostr

*Spouse
gen s`wv'dcfinan=.
spouse r`wv'dcfinan, result(s`wv'dcfinan) wave(`wv')
label variable s`wv'dcfinan "s`wv'dcfinan:w`wv' s discrimination reason:financial status"
label values s`wv'dcfinan yesnostr

***Discrimination reason: Other
gen r`wv'dcother=.
missing_lasi fs527s9, result(r`wv'dcother) wave(`wv')
replace r`wv'dcother=.p if rproxy==1
replace r`wv'dcother=.n if r`wv'lsrspct==1 & r`wv'prsrvc==1 & r`wv'notsmrt==1 & r`wv'actafd==1 & r`wv'harass==1 & r`wv'prtrmt==1
replace r`wv'dcother=fs527s9 if inrange(fs527s9,0,1)
label variable r`wv'dcother "r`wv'dcother:w`wv' r discrimination reason:other"
label values r`wv'dcother yesnostr

*Spouse
gen s`wv'dcother=.
spouse r`wv'dcother, result(s`wv'dcother) wave(`wv')
label variable s`wv'dcother "s`wv'dcother:w`wv' s discrimination reason:other"
label values s`wv'dcother yesnostr

***Summary reason
egen r`wv'dcreas_l = rowtotal(r`wv'dcage r`wv'dcgendr r`wv'dcrlgon r`wv'dccaste r`wv'dcwegt r`wv'dcdstat r`wv'dcaprnc r`wv'dcfinan r`wv'dcother) if inw`wv'==1
replace r`wv'dcreas_l=.p if rproxy==1 & inw`wv'==1
replace r`wv'dcreas_l=.n if r`wv'lsrspct==1  & r`wv'prsrvc==1 & r`wv'notsmrt==1 & r`wv'actafd==1 & r`wv'harass==1 & r`wv'prtrmt==1
label variable r`wv'dcreas_l "r`wv'dcreas_l:w`wv' r number reasons for discrimination"

*Spouse
gen s`wv'dcreas_l=.
spouse r`wv'dcreas_l, result(s`wv'dcreas_l) wave(`wv')
label variable s`wv'dcreas_l "s`wv'dcreas_l:w`wv' s number reasons for discrimination"




***************************************


***drop LASI  file raw variables***
drop `strs_w1_ind'

drop __000*


********************************************************************************************************************

***create inflation multiplier variables***
gen c2017cpindex = 159.9 //2017
gen c2018cpindex = 167.6 //2018
gen c2019cpindex = 180.4 //2019
gen c2020cpindex = 190.5 //2020
gen c2021cpindex = 199.7 //2021

label variable c2017cpindex "2017 consumer price index, 2010=100"
label variable c2018cpindex "2018 consumer price index, 2010=100"
label variable c2019cpindex "2019 consumer price index, 2010=100"
label variable c2020cpindex "2020 consumer price index, 2010=100"
label variable c2021cpindex "2021 consumer price index, 2010=100"

***Update all value labels***
foreach v of var * {
	local vlabel : value label `v'
	if "`vlabel'" != "" {
		label define `vlabel' ///
			.v ".v:SP NR" ///
			.u ".u:Unmar" ///
			.r ".r:Refuse" ///
			.m ".m:Missing" ///
			.d ".d:DK", modify
	}
}

***prim_key
label variable prim_key "prim_key:primary key ID" 
replace prim_key = "" if mi(pnc)

***household identifier - character
label variable hhid "hhid:HHold ID (char)" 

***drop some intermediate variables
drop hhorder 
*ssuid
drop inddata cvdata hhdata

***drop access to schooling variables
drop raeduprim ///
	 s?eduprim ///
	 raedumid ///
	 s?edumid ///
	 raeduhigh ///
	 s?eduhigh

***drop imputation variables
drop hh1rural_i ragender_i r1agecat_i hh1agecat_i hh1hhres_i

***keep if considered in Wave 1 (see demog_w1 for definition)
keep if inw1 == 1
	 
***Order variables
order prim_key ///
			hhid ///
			pnc ///
			pn ///
			h?coupid ///
			s?prim_key ///
			raspid1 ///
			r?mltsps ///
			inw1 ///
			inw1pm /// 
			r?iwstat ///
			s?iwstat ///
			r?wtresp ///
			s?wtresp /// 
			hh?wthh ///
			hh?hhresp ///
			r?nwtresp ///
			s?nwtresp ///
			h?cpl ///
			r?hhr ///
			s?hhr ///
			hh?ohhr ///
			hh?anyhhr ///
			r?finr ///
			s?finr ///
			hh?ofinr ///
			hh?anyfinr ///
			r?proxy ///
			s?proxy ///
			r?iwy ///
			s?iwy ///
			r?iwm ///
			s?iwm ///
			rabyear ///
			s?byear ///
			rabmonth ///
			s?bmonth ///
			r?agey ///
			s?agey /// 
			ragender ///
			s?gender ///
			raeduc_l ///
			s?educ_l ///
			raeducl ///
			s?educl ///
			raedyrs ///
			s?edyrs ///
			raliterate /// 
			s?literate /// 
			r?mstat ///
			s?mstat ///
			r?mstath ///
			s?mstath ///
			r?mnev ///
			s?mnev ///
			r?mrct ///
			s?mrct ///
			r?mcurln ///
			s?mcurln ///
			rabplace ///
			s?bplace ///
			rabcountry /// 
			s?bcountry /// 
			rabcountry_l /// 
			s?bcountry_l ///
			hh?rural ///
			hh?state ///
			r?caste ///
			s?caste ///
			r?relig_l ///
			s?relig_l ///
			r?lang_l ///
			s?lang_l /// 
			///
			r?shlt ///
			s?shlt ///
			r?shlta ///
			s?shlta ///
			r?hlthlm ///
			s?hlthlm ///
			r?walkra ///
			s?walkra ///
			r?dressa ///
			s?dressa ///
			r?batha ///
			s?batha ///
			r?eata ///
			s?eata ///
			r?beda ///
			s?beda ///
			r?toilta ///
			s?toilta ///
			r?phonea ///
			s?phonea ///
			r?medsa ///
			s?medsa ///
			r?moneya ///
			s?moneya ///
			r?shopa ///
			s?shopa ///
			r?mealsa ///
			s?mealsa ///
			r?geta ///
			s?geta ///
			r?housewka ///
			s?housewka ///
			r?walk100a ///
			s?walk100a ///
			r?sita ///
			s?sita ///
			r?chaira ///
			s?chaira ///
			r?clim1a ///
			s?clim1a ///
			r?stoopa ///
			s?stoopa ///
			r?lifta ///
			s?lifta ///
			r?dimea ///
			s?dimea ///
			r?armsa ///
			s?armsa ///
			r?pusha ///
			s?pusha ///
			r?adlwa ///
			s?adlwa ///
			r?adlwam ///
			s?adlwam ///
			r?adlwaa /// 
			s?adlwaa ///
			r?adla ///
			s?adla ///
			r?adlam ///
			s?adlam ///
			r?adlaa ///
			s?adlaa /// 
			r?adlfive /// 
			s?adlfive /// 
			r?adlfivem /// 
			s?adlfivem /// 
			r?adlfivea /// 
			s?adlfivea /// 
			r?adltot6 /// 
			s?adltot6 /// 
			r?adltot6m /// 
			s?adltot6m /// 
			r?adltot6a ///
			s?adltot6a ///
			r?iadla ///
			s?iadla ///
			r?iadlam ///
			s?iadlam ///
			r?iadlaa /// 
			s?iadlaa ///
			r?iadlfour /// 
			s?iadlfour /// 
			r?iadlfourm /// 
			s?iadlfourm ///
			r?iadlfoura /// 
			s?iadlfoura /// 			
			r?iadlza ///
			s?iadlza ///
			r?iadlzam ///
			s?iadlzam ///
			r?iadlzaa /// 
			s?iadlzaa /// 
			r?iadltot_l /// 
			s?iadltot_l /// 
			r?iadltotm_l /// 
			s?iadltotm_l /// 
			r?iadltota_l /// 
			s?iadltota_l /// 
			r?mobilc ///
			s?mobilc ///
			r?mobilcm ///
			s?mobilcm ///
			r?mobilca /// 
			s?mobilca /// 
			r?mobilsev_l /// 
			s?mobilsev_l /// 
			r?mobilsevm_l /// 
			s?mobilsevm_l /// 
			r?mobilseva_l /// 
			s?mobilseva_l /// 
			r?lgmusa ///
			s?lgmusa ///
			r?lgmusam ///
			s?lgmusam ///
			r?lgmusaa /// 
			s?lgmusaa /// 
			r?grossa ///
			s?grossa ///
			r?grossam ///
			s?grossam ///
			r?grossaa /// 
			s?grossaa ///
			r?finea ///
			s?finea ///
			r?fineam ///
			s?fineam ///
			r?fineaa /// 
			s?fineaa /// 
			r?lowermob_l /// 
			s?lowermob_l /// 
			r?lowermobm_l /// 
			s?lowermobm_l /// 
			r?lowermoba_l /// 
			s?lowermoba_l /// 
			r?uppermob /// 
			s?uppermob /// 
			r?uppermobm /// 
			s?uppermobm /// 
			r?uppermoba /// 
			s?uppermoba ///
			r?nagi8 ///
			s?nagi8 ///
			r?nagi8m ///
			s?nagi8m ///
			r?nagi8a ///
			s?nagi8a ///
			r?malaria /// 
			s?malaria ///
			r?diarrh /// 
			s?diarrh /// 
			r?typhoid /// 
			s?typhoid /// 
			r?anemia /// 
			s?anemia /// 
			r?hibpe ///
			s?hibpe ///
			r?diabe ///
			s?diabe ///
			r?cancre ///
			s?cancre ///
			r?lunge ///
			s?lunge ///
			r?hearte ///
			s?hearte ///
			r?stroke ///
			s?stroke ///
			r?arthre ///
			s?arthre ///
			r?psyche ///
			s?psyche ///
			r?alzdeme ///
			s?alzdeme ///
			r?hchole ///
			s?hchole ///
			r?asthmae /// 
			s?asthmae /// 
			r?conhrtfe /// 
			s?conhrtfe /// 
			r?hrtatte /// 
			s?hrtatte /// 
			r?hrtrhme /// 
			s?hrtrhme /// 
			r?osteoe /// 
			s?osteoe /// 
			r?thyroide /// 
			s?thyroide /// 
			r?gstroine /// 
			s?gstroine /// 
			r?skindise /// 
			s?skindise /// 
			r?kidstne /// 
			s?kidstne /// 
			r?prsbype /// 
			s?prsbype /// 
			r?catracte /// 
			s?catracte /// 
			r?glaucome /// 
			s?glaucome /// 
			r?myopiae /// 
			s?myopiae /// 
			r?hyprmtpe /// 
			s?hyprmtpe /// 
			r?dntlcvte /// 
			s?dntlcvte /// 
			r?perdntle /// 
			s?perdntle /// 
			r?hrtatt /// 
			s?hrtatt /// 
			r?rxhibp /// 
			s?rxhibp /// 
			r?rxdiabo /// 
			s?rxdiabo /// 
			r?rxdiabi /// 
			s?rxdiabi /// 
			r?rxdiab /// 
			s?rxdiab /// 
			r?cncrchem /// 
			s?cncrchem /// 
			r?cncrsurg /// 
			s?cncrsurg /// 
			r?cncrradn /// 
			s?cncrradn /// 
			r?cncrmeds /// 
			s?cncrmeds /// 
			r?cncrothr /// 
			s?cncrothr /// 
			r?rxheart /// 
			s?rxheart /// 
			r?rxstrok /// 
			s?rxstrok /// 
			r?rxosteo /// 
			s?rxosteo /// 
			r?rxarthr /// 
			s?rxarthr /// 
			r?rxpsych /// 
			s?rxpsych /// 
			r?trpsych /// 
			s?trpsych /// 
			r?rxalzdem /// 
			s?rxalzdem /// 
			r?tralzdem /// 
			s?tralzdem /// 
			r?rxhchol /// 
			s?rxhchol /// 
			radiaghibp /// 
			s?diaghibp /// 
			radiagdiab /// 
			s?diagdiab /// 
			radiagcancr /// 
			s?diagcancr /// 
			radiagresp /// 
			s?diagresp /// 
			rafrhrtatt /// 
			s?frhrtatt /// 
			radiagheart /// 
			s?diagheart /// 
			radiagstrok /// 
			s?diagstrok /// 
			radiagarthr /// 
			s?diagarthr /// 
			radiagosteo /// 
			s?diagosteo /// 
			radiagpsych /// 
			s?diagpsych /// 
			radiagalzdem /// 
			s?diagalzdem /// 
			radiaghchol ///
			s?diaghchol ///
			r?dsighta /// 
			s?dsighta /// 
			r?nsighta /// 
			s?nsighta /// 
			r?glasses /// 
			s?glasses /// 
			r?catrcte /// 
			s?catrcte /// 
			r?glaucoma /// 
			s?glaucoma /// 
			r?hearaid /// 
			s?hearaid /// 
			r?hearcnde /// 
			s?hearcnde ///
			r?noteeth /// 
			s?noteeth /// 
			r?denture /// 
			s?denture /// 
			r?fall /// 
			s?fall /// 
			r?fallinj /// 
			s?fallinj /// 
			r?fallnum /// 
			s?fallnum /// 
			r?fallslp /// 
			s?fallslp /// 
			r?wakent /// 
			s?wakent /// 
			r?wakeup /// 
			s?wakeup /// 
			r?unrstd /// 
			s?unrstd /// 
			r?rxslp /// 
			s?rxslp /// 
			r?painfr /// 
			s?painfr /// 
			r?painfrq /// 
			s?painfrq /// 
			r?paina /// 
			s?paina /// 
			r?rxpain /// 
			s?rxpain /// 
			r?urinae /// 
			s?urinae /// 
			r?urincgh_l /// 
			s?urincgh_l /// 
			r?swell /// 
			s?swell /// 
			r?breath /// 
			s?breath /// 
			r?dizzy /// 
			s?dizzy /// 
			r?backp /// 
			s?backp /// 
			r?headache /// 
			s?headache /// 
			r?fatigue /// 
			s?fatigue /// 
			r?wheeze /// 
			s?wheeze /// 
			r?jointp /// 
			s?jointp /// 
			r?cough /// 
			s?cough ///		
			r?hystere /// 
			s?hystere /// 
			r?lstmnspd_l /// 
			s?lstmnspd_l /// 				
			r?mammog ///
			s?mammog ///
			r?papsm ///
			s?papsm ///
			r?flushte ///
			s?flushte ///
			r?cholst /// 
			s?cholst /// 
			r?pneushte /// 
			s?pneushte /// 
			r?vgactx ///
			s?vgactx ///
			r?mdactx ///
			s?mdactx ///
			r?yogax ///
			s?yogax ///
			r?drinkev ///
			s?drinkev ///
			r?drink3m ///
			s?drink3m ///
			r?drinkx_l ///
			s?drinkx_l ///
			r?drinkb /// 
			s?drinkb /// 
			r?bingedcat /// 
			s?bingedcat /// 
			r?drinkcut /// 
			s?drinkcut /// 
			r?drinkcr /// 
			s?drinkcr /// 
			r?drinkbd /// 
			s?drinkbd /// 
			r?drinknr /// 
			s?drinknr /// 
			r?cage /// 
			s?cage /// 
			r?cagem /// 
			s?cagem /// 
			r?smokev ///
			s?smokev ///
			r?smoken ///
			s?smoken ///
			r?smokef ///
			s?smokef ///	
			r?otbccv ///
			s?otbccv ///
			r?otbccn /// 
			s?otbccn /// 
			r?strtsmok /// 
			s?strtsmok /// 
			r?strtotbcc /// 
			s?strtotbcc /// 
			r?quitsmok /// 
			s?quitsmok /// 
			r?quitotbcc /// 
			s?quitotbcc /// 
			///		
			r?hosp1y ///
			s?hosp1y ///
			r?hsptim1y ///
			s?hsptim1y ///
			r?hspnit1y ///
			s?hspnit1y ///
			r?doctor1y ///
			s?doctor1y ///
			r?trdmed1y ///
			s?trdmed1y ///
			r?dentst1y ///
			s?dentst1y ///
			r?medvst1y ///
			s?medvst1y ///
			r?mdvtim1y ///
			s?mdvtim1y ///
			r?higov ///
			s?higov ///
			r?covr ///
			s?covr ///
			r?hiothp ///
			s?hiothp ///
			r?hident ///
			s?hident ///
			r?hidrug ///
			s?hidrug ///
			r?prmm1y ///
			s?prmm1y ///
			r?prmmf1y /// 
			s?prmmf1y ///
			r?oophos1y ///
			s?oophos1y ///
			r?oophosf1y ///
			s?oophosf1y ///
			r?oopdoc1y ///
			s?oopdoc1y ///
			r?oopdocf1y ///
			s?oopdocf1y  ///
			r?oopsupl1y ///
			s?oopsupl1y ///
			r?oopsuplf1y ///
			s?oopsuplf1y  ///
			r?oopmd1y_l /// 
			s?oopmd1y_l /// 
			r?oopmdf1y_l /// 
			s?oopmdf1y_l /// 
			///
			r?mo ///
			s?mo ///
			r?fmo_l ///
			s?fmo_l ///
			r?dy ///
			s?dy ///
			r?fdy_l ///
			s?fdy_l ///
			r?yr ///
			s?yr ///
			r?fyr_l ///
			s?fyr_l ///
			r?dw ///
			s?dw ///
			r?fdw_l ///
			s?fdw_l ///
			r?orient ///
			s?orient ///
			r?place ///
			s?place ///
			r?fplace_l ///
			s?fplace_l ///
			r?address ///
			s?address ///
			r?faddress_l ///
			s?faddress_l ///
			r?city ///
			s?city ///
			r?fcity_l ///
			s?fcity_l ///
			r?dist ///
			s?dist ///
			r?fdist_l ///
			s?fdist_l ///
			r?orientp ///
			s?orientp ///
			r?imrc ///
			s?imrc ///
			r?fimrc_l ///
			s?fimrc_l ///
			r?dlrc ///
			s?dlrc ///
			r?fdlrc_l ///
			s?fdlrc_l ///
			r?tr20 /// 
			s?tr20 ///
			r?verbf ///
			s?verbf ///
			r?fverbf_l ///
			s?fverbf_l ///
			r?verbfi ///
			s?verbfi ///		
			r?fverbfi_l ///
			s?fverbfi_l ///	
			r?object1 ///
			s?object1 ///
			r?fobject1_l ///
			s?fobject1_l ///
			r?object2 ///
			s?object2 ///
			r?fobject2_l ///
			s?fobject2_l ///
			r?object ///
			s?object ///
			r?bwc20a ///
			s?bwc20a ///
			r?fbwc20a_l ///
			s?fbwc20a_l ///
			r?bwc100a ///
			s?bwc100a ///	
			r?fbwc100a_l ///
			s?fbwc100a_l ///		
			r?ser7 ///
			s?ser7 ///
			r?fser7_l ///
			s?fser7_l ///
			r?compu1 ///
			s?compu1 ///
			r?fcompu1_l ///
			s?fcompu1_l ///
			r?compu2 ///
			s?compu2 ///
			r?fcompu2_l ///
			s?fcompu2_l ///
			r?compu ///
			s?compu ///			
			r?read ///
			s?read ///
			r?fread_l ///
			s?fread_l ///
			r?senten ///
			s?senten ///		
			r?fsenten_l ///
			s?fsenten_l ///		
			r?execu ///
			s?execu ///
			r?fexecu_l ///
			s?fexecu_l ///
			r?draw ///
			s?draw ///
			r?fdraw_l ///
			s?fdraw_l ///
			r?drawcl ///
			s?drawcl ///
			r?fdrawcl_l ///
			s?fdrawcl_l ///
			r?fgcp /// 
			s?fgcp /// 
			r?ciqscore1 ///
			s?ciqscore1 ///
			r?ciqscore2 ///
			s?ciqscore2 ///
			r?ciqscore3 ///
			s?ciqscore3 ///
			r?ciqscore4 ///
			s?ciqscore4 /// 
			r?ciqscore5 ///
			s?ciqscore5 ///
			r?ciqscore6 ///
			s?ciqscore6 ///
			r?ciqscore7 ///
			s?ciqscore7 ///
			r?ciqscore8 ///
			s?ciqscore8 ///
			r?ciqscore9 ///
			s?ciqscore9 ///
			r?ciqscore10 ///
			s?ciqscore10 ///
			r?ciqscore11 ///
			s?ciqscore11 ///
			r?ciqscore12 ///
			s?ciqscore12 ///
			r?ciqscore13 ///
			s?ciqscore13 ///
			r?ciqscore14 ///
			s?ciqscore14 ///
			r?ciqscore15 ///
			s?ciqscore15 ///
			r?ciqscore16 ///
			s?ciqscore16 ///
			r?cjormscore ///
			s?cjormscore ///
			r?coginter ///
			s?coginter ///
			r?cogassist ///
			s?cogassist  ///			
			///
			c201?cpindex ///
			c202?cpindex ///
			hh?aland ///
			hh?afland ///
			hh?aagri ///
			hh?afagri ///
			hh?adurbl ///
			hh?afdurbl ///
			hh?afixc ///
			hh?affixc ///
			hh?ahous ///
			hh?afhous ///
			hh?ahsdr ///
			hh?afhsdr ///
			hh?ahsdp ///
			hh?afhsdp ///
			hh?arles ///
			hh?afrles ///
			hh?aosdr ///
			hh?afosdr ///
			hh?absns ///
			hh?afbsns ///
			hh?atotf ///
			hh?aftotf ///
			hh?adebt ///
			hh?afdebt ///
			hh?alend ///
			hh?aflend ///
			hh?atotb ///
			hh?aftotb /// 
			///
			hh?iearn ///
			r?iearn ///
			s?iearn ///
			hh?ifearn ///
			r?ifearn ///
			s?ifearn ///
			hh?isemp ///
			hh?ifsemp ///
			hh?irent ///
			hh?ifrent ///
			hh?itrest ///
			hh?iftrest ///
			hh?icap ///
			hh?ifcap ///
			hh?ipena ///
			r?ipena ///
			s?ipena ///
			hh?ifpena ///
			r?ifpena ///
			s?ifpena ///
			hh?ipubpen ///
			r?ipubpen ///
			s?ipubpen ///
			hh?ifpubpen ///
			r?ifpubpen ///
			s?ifpubpen ///
			hh?ipeno ///
			r?ipeno ///
			s?ipeno ///
			hh?ifpeno ///
			r?ifpeno ///
			s?ifpeno ///
			hh?ipen ///
			r?ipen ///
			s?ipen ///
			hh?ifpen ///
			r?ifpen ///
			s?ifpen ///
			hh?igxfr ///
			hh?ifgxfr ///
			hh?ipxfr ///
			hh?ifpxfr ///
			hh?iothr ///
			hh?ifothr ///
			hh?itot ///
			hh?iftot ///
			hh?cfood1w ///
			hh?cffood1w ///
			hh?cnf1m ///
			hh?cfnf1m ///
			hh?cnf1y ///
			hh?cfnf1y ///
			hh?cohc1m ///
			hh?cfohc1m ///
			hh?cihc1y ///
			hh?cfihc1y ///
			hh?ctot ///
			hh?cftot ///
			hh?cperc ///
			hh?cfperc ///
			hh?poverty ///
			///
			hh?hhres ///
			r?child ///
			s?child ///
			r?grchild ///
			s?grchild ///
			r?dchild ///
			s?dchild ///
			r?livbro ///
			s?livbro ///
			r?livsis ///
			s?livsis ///
			r?livsib ///
			s?livsib ///
			r?decbro ///
			s?decbro ///
			r?decsis ///
			s?decsis ///
			r?decsib ///
			s?decsib ///
			r?momliv ///
			s?momliv ///
			r?dadliv ///
			s?dadliv ///
			r?livpar ///
			s?livpar ///
			r?momage ///
			s?momage ///
			r?dadage ///
			s?dadage /// 
			rameduc_l ///
			s?meduc_l ///
			rafeduc_l ///
			s?feduc_l ///
			ramomeducl /// 
			s?momeducl ///
			radadeducl /// 
			s?dadeducl /// 
			r?lvwith ///
			s?lvwith ///
			r?coresd ///
			s?coresd ///
			r?lvnear ///
			s?lvnear ///
			r?fcany ///
			s?fcany ///
			r?fpany ///
			s?fpany ///
			r?foany ///
			s?foany ///
			r?tcany ///
			s?tcany ///
			r?tpany ///
			s?tpany ///
			r?toany ///
			s?toany ///
			r?frec ///
			s?frec ///
			r?ffrec ///
			s?ffrec ///
			r?tgiv ///
			s?tgiv ///
			r?ftgiv ///
			s?ftgiv ///
			r?ftot /// 
			s?ftot /// 
			r?fftot /// 
			s?fftot ///
			r?fcntf ///
			s?fcntf ///
			r?fcntpm ///
			s?fcntpm ///
			r?fcnt ///
			s?fcnt ///
			r?rfcntf ///
			s?rfcntf ///
			r?socyr ///
			s?socyr ///
			r?socwk ///
			s?socwk ///
			r?relgwk ///
			s?relgwk ///
			r?socrelg_l ///
			s?socrelg_l ///
			///
			r?worka /// 
			s?worka ///
			r?work ///
			s?work ///
			r?work2 ///
			s?work2 ///
			r?njobs2 ///
			s?njobs2 ///
			r?slfemp ///
			s?slfemp ///
			r?lbrf_l ///
			s?lbrf_l ///
			r?lbrfs_l ///
			s?lbrfs_l ///
			r?inlbrf ///
			s?inlbrf ///
			r?unemp ///
			s?unemp ///
			r?jhours ///
			s?jhours ///
			r?jhour2 ///
			s?jhour2 ///
			r?jhourtot /// 
			s?jhourtot /// 
			r?jweeks_l ///
			s?jweeks_l ///
			r?wgiwk ///
			s?wgiwk ///
			r?wgfwk ///
			s?wgfwk ///
			r?wgiwk2 ///
			s?wgiwk2 ///
			r?wgfwk2 ///
			s?wgfwk2 ///
			r?jphys ///
			s?jphys ///
			r?jlift ///
			s?jlift ///
			r?jstoop ///
			s?jstoop ///
			r?jsight ///
			s?jsight ///
			r?jconcntrb /// 
			s?jconcntrb /// 
			r?jdealpplb ///
			s?jdealpplb /// 
			r?jsmoka /// 
			s?jsmoka /// 
			r?jchema /// 
			s?jchema /// 
			r?jodora /// 
			s?jodora ///
			r?jgovtemp /// 
			s?jgovtemp ///
			r?jsprvs /// 
			s?jsprvs ///
			r?jcten ///
			s?jcten ///
			r?jcocc_l ///
			s?jcocc_l ///
			r?jcind_l ///
			s?jcind_l ///
			r?fsize ///
			s?fsize ///
			r?ffsize ///
			s?ffsize ///
			r?jlasty ///
			s?jlasty ///
			r?jlastm ///
			s?jlastm ///
			r?lookwrkpf /// 
			s?lookwrkpf /// 
			r?lookwrksd /// 
			s?lookwrksd /// 
			r?lookarea /// 
			s?lookarea /// 
			r?looknwk /// 
			s?looknwk /// 
			r?looknwkpf /// 
			s?looknwkpf /// 
			r?looknwksd /// 
			s?looknwksd /// 
			r?looknarea /// 
			s?looknarea ///
			///
			r?sayret_l ///
			s?sayret_l ///
			r?fret_l ///
			s?fret_l ///
			r?retmon ///
			s?retmon ///
			r?retyr ///
			s?retyr ///
			r?rplnya ///
			s?rplnya  /// 
			/// 
			r?pubpen ///
			s?pubpen ///
			r?peninc ///
			s?peninc ///
			r?jcpen ///
			s?jcpen ///
			r?pubpeni ///
			s?pubpeni ///
			r?fpubpeni ///
			s?fpubpeni ///
			r?penai ///
			s?penai ///
			r?fpenai ///
			s?fpenai ///
			r?peni ///
			s?peni ///
			r?fpeni ///
			s?fpeni ///
			///
			r?systo1 ///
			s?systo1 ///
			r?systo2 ///
			s?systo2 ///
			r?systo3 ///
			s?systo3 ///
			r?systo ///
			s?systo ///
			r?diasto1 ///
			s?diasto1 ///
			r?diasto2 ///
			s?diasto2 ///
			r?diasto3 ///
			s?diasto3 ///
			r?diasto ///
			s?diasto ///
			r?pulse1 ///
			s?pulse1 ///
			r?pulse2 ///
			s?pulse2 ///
			r?pulse3 ///
			s?pulse3 ///
			r?pulse ///
			s?pulse ///
			r?bpcomp ///
			s?bpcomp ///
			r?bldpos ///
			s?bldpos ///
			r?bparm ///
			s?bparm ///
			r?bpcompl ///
			s?bpcompl ///
			r?bpact30 ///
			s?bpact30 ///
			r?domhand ///
			s?domhand ///
			r?lgrip1 ///
			s?lgrip1 ///
			r?lgrip2 ///
			s?lgrip2 ///
			r?rgrip1 ///
			s?rgrip1 ///
			r?rgrip2 ///
			s?rgrip2 ///
			r?lgrip ///
			s?lgrip ///
			r?rgrip ///
			s?rgrip ///
			r?gripsum ///
			s?gripsum ///
			r?gripcomp ///
			s?gripcomp ///
			r?grippos ///
			s?grippos ///
			r?gripeff ///
			s?gripeff ///
			r?griprsta ///
			s?griprsta ///
			r?semidone ///
			s?semidone ///
			r?semitan ///
			s?semitan ///
			r?semicomp ///
			s?semicomp ///
			r?sbsdone ///
			s?sbsdone ///
			r?sbstan ///
			s?sbstan ///
			r?sbscomp ///
			s?sbscomp ///
			r?fulldone ///
			s?fulldone ///
			r?fulltan ///
			s?fulltan ///
			r?fullcomp ///
			s?fullcomp ///
			r?balance ///
			s?balance ///
			r?balflr ///
			s?balflr ///
			r?balcompl ///
			s?balcompl ///
			r?semitanc ///
			s?semitanc ///
			r?sbstanc ///
			s?sbstanc ///
			r?fulltanc ///
			s?fulltanc ///
			r?wspeed1 ///
			s?wspeed1 ///
			r?wspeed2 ///
			s?wspeed2 ///
			r?wspeed ///
			s?wspeed ///
			r?walkcomp ///
			s?walkcomp ///
			r?walkcompl ///
			s?walkcompl ///
			r?walkaid ///
			s?walkaid ///
			r?mheight ///
			s?mheight ///
			r?mweight ///
			s?mweight ///
			r?mbmi ///
			s?mbmi ///
			r?mbmicat /// 
			s?mbmicat /// 
			r?htcomp ///
			s?htcomp ///
			r?wtcomp ///
			s?wtcomp ///
			r?htlimbs ///
			s?htlimbs ///
			r?wtlimbs ///
			s?wtlimbs ///
			r?htcompl ///
			s?htcompl ///
			r?wtcompl ///
			s?wtcompl ///
			r?mwaist ///
			s?mwaist ///
			r?mhip ///
			s?mhip ///
			r?mwhratio ///
			s?mwhratio ///
			r?watcomp /// 
			s?watcomp ///
			r?hipcomp ///
			s?hipcomp ///
			r?bulky ///
			s?bulky ///
			r?hipdiff ///
			s?hipdiff ///
			r?lvsn2ft /// 
			s?lvsn2ft /// 
			r?rvsn2ft /// 
			s?rvsn2ft /// 
			r?lvsndst /// 
			s?lvsndst /// 
			r?rvsndst /// 
			s?rvsndst ///
			r?lvsnnr /// 
			s?lvsnnr /// 
			r?rvsnnr /// 
			s?rvsnnr /// 
			r?dstvi ///
			s?dstvi ///
			r?nrvi ///
			s?nrvi ///
			r?uprsbyp ///
			s?uprsbyp ///
			r?vsncompl /// 
			s?vsncompl ///
			///
			r?rcany ///
			s?rcany ///
			r?rcaany_l  ///
			s?rcaany_l  ///
			r?rscare_l ///
			s?rscare_l ///
			r?rscaredpm_l ///
			s?rscaredpm_l ///
			r?rscarehr_l ///
			s?rscarehr_l ///
			r?rscarepd_l ///
			s?rscarepd_l ///
			r?rccare_l ///
			s?rccare_l ///
			r?rccaredpm_l ///
			s?rccaredpm_l ///
			r?rccarehr_l  ///
			s?rccarehr_l  ///
			r?rccarepd_l  ///
			s?rccarepd_l  ///
			r?rrcare_l ///
			s?rrcare_l ///
			r?rrcaredpm_l ///
			s?rrcaredpm_l ///
			r?rrcarehr_l ///
			s?rrcarehr_l ///
			r?rrcarepd_l ///
			s?rrcarepd_l ///
			r?rfcare_l ///
			s?rfcare_l ///
			r?rfcaredpm_l ///
			s?rfcaredpm_l ///
			r?rfcarehr_l ///
			s?rfcarehr_l ///
			r?rfcarepd_l ///
			s?rfcarepd_l ///
			r?rfaany_l  ///
			s?rfaany_l  ///
			r?rpfcare_l ///
			s?rpfcare_l ///
			r?rpfcaredpm_l ///
			s?rpfcaredpm_l ///
			r?rpfcarehr_l ///
			s?rpfcarehr_l ///
			r?rufcare_l ///
			s?rufcare_l ///
			r?rufcaredpm_l ///
			s?rufcaredpm_l ///
			r?rufcarehr_l ///
			s?rufcarehr_l ///
			r?gacare  ///
			s?gacare  ///
			r?gascare_l  ///
			s?gascare_l  ///
			r?gaccare_l  ///
			s?gaccare_l  ///
			r?gapcare_l ///
			s?gapcare_l ///
			r?gabcare_l ///
			s?gabcare_l ///
			r?garcare_l ///
			s?garcare_l ///
			r?gafcare_l  ///
			s?gafcare_l  ///
			r?gksit ///
			s?gksit ///
			/// 
			r?sfhome_l /// 
			s?sfhome_l /// 
			r?afwalk_l /// 
			s?afwalk_l /// 
			ramischlth /// 
			s?mischlth /// 
			rabedrdch /// 
			s?bedrdch /// 
			rafinanch /// 
			s?financh /// 
			rachshlta /// 
			s?chshlta /// 
			r?lsrspct /// 
			s?lsrspct /// 
			r?prsrvc /// 
			s?prsrvc /// 
			r?notsmrt /// 
			s?notsmrt /// 
			r?harass /// 
			s?harass /// 
			r?prtrmt /// 
			s?prtrmt /// 
			r?actafd /// 
			s?actafd /// 
			r?dscrim /// 
			s?dscrim /// 
			r?dscrimm /// 
			s?dscrimm /// 
			r?dcage /// 
			s?dcage /// 
			r?dcgendr /// 
			s?dcgendr /// 
			r?dcrlgon /// 
			s?dcrlgon /// 
			r?dccaste /// 
			s?dccaste /// 
			r?dcwegt /// 
			s?dcwegt /// 
			r?dcdstat /// 
			s?dcdstat /// 
			r?dcaprnc /// 
			s?dcaprnc /// 
			r?dcfinan /// 
			s?dcfinan /// 
			r?dcother /// 
			s?dcother /// 
			r?dcreas_l /// 
			s?dcreas_l ///
			///
			hh?bedsep ///
			hh?sanitat ///
			hh?drksrc ///			
			hh?waterhm ///
			hh?electr ///
			hh?electrhr ///
			hh?clncook ///
			hh?indrplltn ///
			hh?incense /// 
			hh?pucca ///  
			/// 
			r?mindtsl ///
			s?mindtsl ///
			r?depresl ///
			s?depresl ///
			r?effortl ///
			s?effortl ///
			r?ftiredl ///
			s?ftiredl ///
			r?whappyl ///
			s?whappyl ///
			r?flonel ///
			s?flonel ///
			r?fsatisl ///
			s?fsatisl ///
			r?fearfll ///
			s?fearfll ///
			r?fhopel ///
			s?fhopel ///
			r?botherl ///
			s?botherl ///
			r?cesd10 ///
			s?cesd10 ///
			r?cesd10m ///
			s?cesd10m ///
			r?cesd10_l /// 
			s?cesd10_l /// 
			r?cesd10m_l /// 
			s?cesd10m_l /// 
			r?cesd10dep ///
			s?cesd10dep ///
			r?cididep /// 
			s?cididep ///
			r?cididepm ///
			s?cididepm ///
			r?cidianh ///
			s?cidianh ///
			r?cidianhm ///
			s?cidianhm ///
			r?cidisymp ///
			s?cidisymp /// 
			r?cidisympm /// 
			s?cidisympm /// 
			r?cidimde3 /// 
			s?cidimde3 /// 
			r?cidimde5 /// 
			s?cidimde5 ///
			r?lideal /// 
			s?lideal /// 
			r?lexcl /// 
			s?lexcl /// 
			r?lstsf /// 
			s?lstsf /// 
			r?limptt /// 
			s?limptt /// 
			r?lchnot /// 
			s?lchnot ///
			r?lideal3 /// 
			s?lideal3 /// 
			r?lexcl3 /// 
			s?lexcl3 /// 
			r?lstsf3 /// 
			s?lstsf3 /// 
			r?limptt3 /// 
			s?limptt3 /// 
			r?lchnot3 ///
			s?lchnot3 ///
			r?lsatsc /// 
			s?lsatsc /// 
			r?lsatscm /// 
			s?lsatscm /// 
			r?lsatsc3 /// 
			s?lsatsc3 /// 
			r?lsatsc3m /// 
			s?lsatsc3m ///
			r?sathome	///
			s?sathome ///
			r?satwlife /// 
			s?satwlife ///
			r?wtchtv ///
			s?wtchtv ///
			r?wtchtvmn ///
			s?wtchtvmn ///
			r?wtvhpya ///
			s?wtvhpya ///
			r?wtvinta ///
			s?wtvinta ///
			r?wtvfrsa ///
			s?wtvfrsa ///
			r?wtvsada ///
			s?wtvsada ///
			r?wtvpos2a ///
			s?wtvpos2a ///
			r?wtvneg2a ///
			s?wtvneg2a ///
			r?wkvlntr ///
			s?wkvlntr ///
			r?wkvlntrmn ///
			s?wkvlntrmn ///
			r?wkvhpya ///
			s?wkvhpya ///
			r?wkvinta ///
			s?wkvinta ///
			r?wkvfrsa ///
			s?wkvfrsa ///
			r?wkvsada ///
			s?wkvsada ///
			r?wkvpos2a ///
			s?wkvpos2a ///
			r?wkvneg2a ///
			s?wkvneg2a ///
			r?walkex ///
			s?walkex ///
			r?walkexmn ///
			s?walkexmn ///
			r?exrhpya ///
			s?exrhpya ///
			r?exrinta ///
			s?exrinta ///
			r?exrfrsa ///
			s?exrfrsa ///
			r?exrsada ///
			s?exrsada ///
			r?exrpos2a ///
			s?exrpos2a ///
			r?exrneg2a ///
			s?exrneg2a ///
			r?hlthac ///
			s?hlthac ///
			r?hlthacmn ///
			s?hlthacmn ///
			r?hlthpya ///
			s?hlthpya ///
			r?hltinta ///
			s?hltinta ///
			r?hltfrsa ///
			s?hltfrsa ///
			r?hltsada ///
			s?hltsada ///
			r?hltpos2a ///
			s?hltpos2a ///
			r?hltneg2a ///
			s?hltneg2a ///
			r?trvlcom ///
			s?trvlcom ///
			r?trvlcommn ///
			s?trvlcommn ///
			r?trvhpya ///
			s?trvhpya ///
			r?trvinta ///
			s?trvinta ///
			r?trvfrsa ///
			s?trvfrsa ///
			r?trvsada ///
			s?trvsada ///
			r?trvpos2a ///
			s?trvpos2a ///
			r?trvneg2a ///
			s?trvneg2a ///
			r?tmfrnd ///
			s?tmfrnd ///
			r?tmfrndmn ///
			s?tmfrndmn ///
			r?frnhpya ///
			s?frnhpya ///
			r?frninta ///
			s?frninta ///
			r?frnfrsa ///
			s?frnfrsa ///
			r?frnsada ///
			s?frnsada ///
			r?frnpos2a ///
			s?frnpos2a ///
			r?frnneg2a ///
			s?frnneg2a ///
			r?tmself ///
			s?tmself ///
			r?tmselfmn ///
			s?tmselfmn ///
			r?slfhpya ///
			s?slfhpya ///
			r?slfinta ///
			s?slfinta ///
			r?slffrsa ///
			s?slffrsa ///
			r?slfsada ///
			s?slfsada ///
			r?slfpos2a ///
			s?slfpos2a ///
			r?slfneg2a ///
			s?slfneg2a ///
			r?cantril	///
			s?cantril ///
			r?drday ///
			s?drday ///
			r?drwaketm ///
			s?drwaketm ///
			r?drsleeptm ///
			s?drsleeptm ///
			r?drwlrstd ///
			s?drwlrstd ///
			r?drnrmlday ///
			s?drnrmlday ///
			r?ydfrust ///
			s?ydfrust ///
			r?ydsad ///
			s?ydsad ///
			r?ydenthu ///
			s?ydenthu ///
			r?ydlonely ///
			s?ydlonely ///
			r?ydcontent ///
			s?ydcontent ///
			r?ydworry ///
			s?ydworry ///
			r?ydbored ///
			s?ydbored ///
			r?ydhappy ///
			s?ydhappy ///
			r?ydangry ///
			s?ydangry ///
			r?ydtired ///
			s?ydtired ///
			r?ydstress ///
			s?ydstress ///
			r?ydpain ///
			s?ydpain ///
			r?ovexpos3 ///
			s?ovexpos3 ///
			r?ovexpos3m ///
			s?ovexpos3m ///
			r?ovexneg6 ///
			s?ovexneg6 ///
			r?ovexneg6m ///
			s?ovexneg6m ///
			r?ovexpsy3 ///
			s?ovexpsy3 ///
			r?ovexpsy3m ///
			s?ovexpsy3m 

***generate prim_keys for household observations where no indivudal interview was completed
replace prim_key = substr(hhid,1,13) + "00" if mi(prim_key)

***unset as mi data***
mi unset, asis

***compress data***
compress

***add label
label data "Harmonized LASI Ver.A3"

***add notes
notes drop _dta
note: Harmonized LASI Ver.A3
note: created April 2023 as part of the Gateway to Global Aging Data (www.g2aging.org)
note: see Harmonized LASI codebook for more information

***remove unsued value lables
labelbook, problems
label drop `r(notused)'

***save output dataset
save "`output'/H_LASI_a3", replace
