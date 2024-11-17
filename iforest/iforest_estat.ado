*! version 1.0.0 09sep2021
program define iforest_estat
	version 17

	gettoken sub rest: 0, parse(" ,")
	
	local lsub = length(`"`sub'"')
	
	if "`sub'" == "metric"{
		__estat_metric `rest' //if e(sample)
	}
	else {
		di as err `"unknown subcommand `sub'"'
		exit 321
	}
		

end

program __estat_metric, rclass

	syntax varname(numeric) [if] [in], [threshold(numlist >=0 <=1)]
	marksample touse
	markout `touse'
	
//	__check_metric `metric'
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
	mata: r.metric()
	
	return add
	
	
end

/*
program __check_metric, sclass
	local metric
	if "`0'" == "" | "`0'" == "F1"  {
		local metric = "F1"
		sreturn local metric "`metric'"
	}
	else if "`0'"==bsubstr("sensitivity", 1, max(3, `l')) {
		local metric = "sens"
		sreturn "`metric'"
	}
	else {
		di as smcl as err "syntax error"
		di as smcl as err "{p 4 4 2}"
		di as smcl as err ///
		"{bf:metric} takes only {bf:F1} and {bf: sens} ."
		di as smcl as err ///
		"You might type {bf:metric(F1)}, or {bf:metric(sens)}."
		di as smcl as err "{p_end}"
		exit 198
	}

end

