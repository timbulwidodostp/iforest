*! version 1.0.0 12sep2021

program define iforest, eclass
	version 17.0
	
	syntax [anything(everything)] [, *]
	
	if (replay()) {
	        ReplayEstimate
		exit
	}
	else {
	        Estimate `0'
	}
	
	local orig `"`0'"'
	ereturn local cmdline `"iforest `orig'"'
	
end

program ReplayEstimate
	
	if("`e(cmd)'" != "iforest"){
		error 301
	}

end

	
program Estimate, eclass
	version 17
	
	syntax varlist(min=2 numeric) [if] [in] ///
			[, ntrees(integer 200)  ///
			samplesize(integer 256)  ///
			maxdepth(integer 0) 	///
			extlevel(integer 0)   ///
			threshold(numlist >=0 <=1) ///
			NOHist *] 	
			//threshold(real 0.5)
	marksample touse
	markout `touse'
	// Sanity check
	if "`ntrees'" != "" {
		capture confirm integer number `ntrees'
		if _rc {
			di as err "invalid option {bf:ntrees()}; the "	///
				"value must be a positive integer"
			exit 198
		}

	if `ntrees' <= 0 {
		di as err "invalid option {bf:ntrees()}; the "	///
				"value must be a positive integer"
		exit 198
		}
	}

	if "`maxdepth'" != "" {
		capture confirm integer number `maxdepth'
		if _rc {
			di as err "invalid option {bf:maxdepth()}; the"	///
				" value must be a positive integer"
			exit 198
		}
		
		if `maxdepth' < 0 {
			di as err "invalid option {bf:maxdepth()}; the"	///
				" value must be a positive integer"
			exit 198
		}
	}
	
	if "`samplesize'" != "" {
		capture confirm number `samplesize'
		if _rc {
			di as err "invalid option {bf:samplesize()}; "	///
				"the value must be a positive number"
			exit 198
		}
		
		if `samplesize' <= 0 {
			di as err "invalid option {bf:samplesize()}; "	///
				"the value must be a positive number"
			exit 198
		}
	}
	
	
	capture numlist "`threshold'", sort
	if("`r(numlist)'" != "") {
		local threshold: subinstr local threshold " " ", ", all	
	} 
	else {
		numlist "0.1(0.05)0.9"
		local threshold "`r(numlist)'"
		local threshold: subinstr local threshold " " ", ", all
	}
	
	// Making sure that moremata is installed
	capt mata mata which mm_srswor()
	if _rc!= 0 {
		di as err "please install user-written package {bf: moremata}" 
//		di as txt "use {bf: -ssc install moremata-} to do that \m"
		exit 498
	}
	//ereturn post, esample(`touse') 
	mata: r = iForest(1)
	mata: r.graph = "`nohist'"
	mata: r.setup("`varlist'", "`touse'",`ntrees', ///
		`samplesize',`maxdepth', `extlevel')
	mata: S = r.compute_path()

	
	#delimit ;
	noi di in gr _n 
		"Isolation Forest model" _n
		`"Number of observations = "' in yel %3.0f e(N) _n
		in gr `"Number of trees        = "' in yel %14.0f "`ntrees'" _n ;
	#delimit cr
	
/*	
	_get_gropts , graphopts(`options') getallowed(RLOPts plot addplot)
	
	local options `"`s(graphopts)'"'
	local rlopts `"`s(rlopts)'"'
	local plot `"`s(plot)'"'
	local addplot `"`s(addplot)'"'
	_check4gropts rlopts, opt(`rlopts')
*/	
//	local perc =  "percent"

	if `"`nohist'"' == `""' {
		label variable `score' "Score"
		format `score'  %4.2f
		local xttl : var label `score'
		histogram `score',			///
			sort				///
			xtitle(`"`xttl'"')              ///
			`legend'			/// no legend
			`options'			///

	}
 //       ereturn post, esample(`touse')  
	ereturn local cmd "iforest"
	ereturn local vars     "`varlist'"
	ereturn local estat_cmd iforest_estat
	ereturn local predict "iforest_p"
//	ereturn scalar threshold = `threshold'
	ereturn scalar ntree =	`ntrees'
	ereturn scalar samplesize = `samplesize'
	ereturn scalar extlevel = `extlevel'
	ereturn matrix Score = Score

end





