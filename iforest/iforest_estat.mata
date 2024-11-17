*! version 1.0.0 17sep2021
version 17
set matastrict on


mata:

class EstatMetrics
{
	real vector estimated
	real vector threshlist
	real scalar threshold
	real scalar auc
	real matrix S
	pointer(real vector) scalar true
	real scalar p
	real scalar listlength
	real matrix result
	real vector combined
	real vector sens
	real vector spec
	real vector tpr_vec
	real vector spec_vec
	string scalar isroc // Check whether command run from roc
//	string scalar selection
	//functions
	void initvalues()
	void metrics_thresh()
	void pred_thresh()
	void metric()
	real colvector diff()
	 

}


void EstatMetrics::initvalues(string scalar varlist, 
			      string scalar touse, 
			      real vector user_threshlist, 
			      real matrix user_S) {
	
	real vector usr_true, index, sel
	
	pragma unset usr_true
	 
	st_view(usr_true, ., tokens(varlist), touse)
	true = &usr_true
	p = length(*true)
	threshlist = user_threshlist
	listlength = length(threshlist)
	result = J(listlength, 5, .)
	pragma unset sel	
	st_view(sel,., touse)
	index = selectindex(sel :== 1)
	S = user_S[index]
	
}


void EstatMetrics::metric() {
	
	string colvector buffer
	real scalar i, fpr
	real vector minindex, select_index, fpr_vec
	real matrix w
	buffer = J(listlength + 2, 1, "")
	buffer[1] = sprintf("{txt}{space 2}Threshold {space 1} {c |} Sens. {space 2}  Spec. {space 3} TDR {space 5} F1")
	buffer[2] = sprintf("{hline 14}{c +}{hline 35}")
	for(i = 1; i<= listlength; i++ ) {
		// Predict esitmated vectore
		pred_thresh(threshlist[i])
		metrics_thresh()
		result[i, ] = combined
		buffer[i + 2] = sprintf("{txt}%10.0g{space 3} {c |} %3.2f {space 4} %3.2f {space 4} %3.2f {space 4} %3.2f", combined[1], combined[2], combined[3],combined[4], combined[5])
	}
	pragma unset minindex
	pragma unset w
	maxindex(result[,5], 1, minindex, w)
	minindex = minindex[1]
	buffer[minindex + 2] = buffer[minindex + 2] + "*"
	threshold = threshlist[minindex]
	fpr_vec = 1 :- result[,3]
	auc = sum(revorder(result[,2]) :* diff(revorder(fpr_vec))
		) + sum(diff(revorder(result[,2])) :* 
		diff(revorder(fpr_vec))) / 2
	printf("\n")
	printf("{txt} iForest estimated AUC score %g \n", auc )
	printf("\n")
	display(buffer)
	if (isroc == "Yes") {
		st_store((1,listlength), sens = st_addvar("double", 
		st_tempname()), (result[,2]))
		st_store((1,listlength), fpr = st_addvar("double",
		st_tempname()), ( fpr_vec))
		st_local("sens",st_varname(sens))
		st_local("fpr",st_varname(fpr))
	}
	st_rclear()
	st_numscalar("r(AUC)", auc)
	st_numscalar("r(N)", p)
	st_matrix("r(metric)", result)
	st_numscalar("r(threshold)", threshold)

}

void EstatMetrics::metrics_thresh() {
	
	real vector  diffm, diffm2, sumy, fpr_vec
	real scalar nmbTrueEdges, nmbTrueGaps, trueEstEdges, i
	real scalar nmbEstEdges
	real scalar tpr, fpr, tdr, PPV, F1
	string colvector cv
	diffm = estimated - *true
	nmbTrueGaps = sum(*true :== 0)
	if (nmbTrueGaps == 0) {
		fpr = 1
	}else {
	        fpr = (sum(diffm :> 0)) / nmbTrueGaps
	 }
	 spec = 1 - fpr
	 spec_vec = 1 :- fpr_vec
	 
	 diffm2 = *true - estimated
	 nmbTrueEdges = sum(*true :== 1) 
	 if (nmbTrueEdges == 0) {
	        tpr = 0
	 }else {
	        tpr = 1 - (sum(diffm2 :> 0)) / nmbTrueEdges
	 }
//	 auc = sum(tpr_vec :* diff(fpr_vec)) + sum(diff(tpr_vec) :* diff(fpr_vec)) / 2
//	 printf("auc is %g \n", auc )
	 
	 trueEstEdges = nmbTrueEdges - sum(diffm2 :> 0) 
	 if (nmbTrueEdges == 0) {
	 	if(trueEstEdges == 0) {
			tdr = 1
		}else {
			tdr = 0
		}
	 }else {
	 	tdr = trueEstEdges / (sum(estimated :== 1) )
	 }
	 
	 nmbEstEdges = sum(estimated :> 0)
	 if (nmbEstEdges == 0) {
	 	PPV = 0
	 } else {
	 	PPV = (nmbTrueEdges - sum(diffm2 :> 0)) / nmbEstEdges
	 }
	 if (PPV > 0 & tpr > 0) {
		F1 = 2 * PPV * tpr / (PPV + tpr)
	 } else{
	 	F1 = 0
	 }
	 combined = (threshold,tpr,spec,tdr, F1)
}


real colvector EstatMetrics::diff(real colvector k) {
	real scalar len, lag
	real colvector diff
	len = length(k)
	lag = 1
	diff = k[(1 + lag) :: len] - k[1 :: (len - lag)]
	diff = (diff \ 0)
	return(diff)
	
}

void EstatMetrics::pred_thresh(real scalar user_threshold)
{
        real colvector indxyhat
	real scalar idx
	threshold = user_threshold
	indxyhat = selectindex(S :>= threshold)
	estimated = J(rows(S), 1, 0)
	estimated[indxyhat] = J(length(indxyhat), 1, 1)
}


end
