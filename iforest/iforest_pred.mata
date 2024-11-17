version 16
set matastrict on

mata:
void iforest_pred(real matrix S, string scalar newvarname, real scalar user_threshold)
{
        real colvector indxyhat, Yhat
	real scalar threshold, idx
	threshold = user_threshold
	indxyhat = selectindex(S :>= threshold)
	Yhat = J(rows(S), 1, 0)
	Yhat[indxyhat] = J(length(indxyhat), 1, 1)
	idx = st_addvar("int", newvarname)
	st_store(.,idx, Yhat)
	st_rclear()
	st_matrix("r(Yhat)",  Yhat)
//	return(Yhat)
}

end