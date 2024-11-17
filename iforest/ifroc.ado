*! version 1.0.0 19sep2021
program define ifroc
	version 17.0
	
        if (`"`e(cmd)'"'!="iforest" ) {      
                di as err "last estimates not found"
                exit 301
        }

                                                //  store eclass results
        tempname est
        capture _estimates hold `est', copy restore
                                                // draw graph
        cap noi __graph_roc `0'
        local rc = _rc
	
                                                // exit errors if happens
        if `rc' exit `rc'
	
                                                // unhold est
        capture _est unhold `est'
end

program __graph_roc, rclass

	syntax varname(numeric) [if] [in], [threshold(numlist >=0 <=1) *]
	marksample touse
	markout `touse'
	

	capture numlist "`threshold'", sort
	if("`r(numlist)'" != "") {
		local threshold: subinstr local threshold " " ", ", all	
	} 
	else {
		numlist "0.1(0.05)0.9"
		local threshold "`r(numlist)'"
		local threshold: subinstr local threshold " " ", ", all
	}
	
	mata: S = st_matrix("e(Score)")
	mata: r = EstatMetrics(1)
	mata: r.initvalues("`varlist'", "`touse'", (`threshold'), S)
	mata: r.isroc = "Yes"
	mata: r.metric()

	_get_gropts , graphopts(`options') getallowed(RLOPts plot addplot)
	
	local options `"`s(graphopts)'"'
	local rlopts `"`s(rlopts)'"'
	local plot `"`s(plot)'"'
	local addplot `"`s(addplot)'"'
	_check4gropts rlopts, opt(`rlopts')

//	matrix rownames metric = threshold tpr fpr tdr
//	return matrix metric = metric

	local area : di %6.4f r(AUC)
	local note `"Area under ROC curve = `area'"'

	#delimit ;
	noi di in gr _n 
		"Isolation Forest"
		`" model for `varlist'"' _n
		`"Number of observations = "' in yel %8.0f r(N) _n
		in gr `"Area under ROC curve   = "' 
		in yel %8.4f r(AUC) ;
	#delimit cr
	
	label variable `sens' "True Positive Rate"
	label variable `fpr'  "False Positive Rate"
	
	
	if `"`graph'"' == `""' {
		format `sens' `fpr' %4.2f
		local yttl : var label `sens'
		local xttl : var label `fpr'
		if `"`plot'`addplot'"' == "" {
			local legend legend(nodraw)
		}
		noi version 8, missing: graph twoway	///
		(connected `sens' `fpr',		///
			sort				///
			ylabel(0(.25)1, grid)		///
			ytitle(`"`yttl'"')		///
			xlabel(0(.25)1, grid)		///
			xtitle(`"`xttl'"')		///
			note(`"`note'"')		///
			`legend'			/// no legend
			`options'			///
		)					///
		(function y=x,				///
			lstyle(refline)			///
			range(`fpr')			///
			n(2)				///
			yvarlabel("Reference")		///
			`rlopts'			///
		)					///
		|| `plot' || `addplot'			///
		// blank
	}

// capture	
end

