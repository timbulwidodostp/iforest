*! version 1.0.0 09sep2021
program define iforest_p
	version 17
	
	syntax  newvarname [if] [in] [, THReshold(real 0.1)]
	
//	marksample touse
//	markout `touse'

	
	local ntrees 	 = `e(ntree)'
	local samplesize = `e(samplesize)'
	local maxdepth   = `e(maxdepth)'
	local extlevel   = `e(extlevel)'
	local threshold  = `threshold'
	local pred     `e(vars)'
	
	mata: S = st_matrix("e(Score)")
	mata: iforest_pred(S, "`varlist'", `threshold')
	
	if "`theshold'" != "" {
		capture confirm number `threshold'
		if _rc {
			di as err "invalid option {bf:threshold()}; the" ///
				" value must be a positive number"
			exit 198
		}
		
		if `threshold' < 0 | `threhsold' > 1 {
			di as err "invalid option {bf:threshold()}; the" ///
				" value must be a between 0 and 1"
			exit 198
		}
	}

end
	
	