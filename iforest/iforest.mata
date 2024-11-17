*! version 1.0.0 12sep2021
version 17.0

set matastrict on
mata:

real scalar cfactor( real scalar n)
{
    ///Finds average path length	
	return(2 * (log(n - 1) + 0.5772156649) - (2 * (n - 1)/ n))
}


struct Node
{
	real scalar h_e
	real scalar size
	real colvector nv
	real rowvector inter
	struct Node matrix left
	struct Node matrix right
	string scalar ntype
}


class iTree
{
	real scalar exlevel
	real scalar h_e
	real scalar size
	real scalar p
	real scalar h_l
	real colvector minx, maxx
	real rowvector inter
	real colvector nv
	real scalar exnodes
	struct Node matrix root
	void setup()
	struct Node matrix make_tree()
//	struct Node matrix make_tree_orig()
	struct Node matrix nodesetup()
	real rowvector geninter()
	real colvector gennv()
}

void iTree::setup(real matrix user_X, real scalar user_h_e,
			real scalar user_l, real scalar user_exlevel )
{
	exlevel = user_exlevel
	h_e = user_h_e
	size = rows(user_X)
	p     = cols(user_X)
	h_l = user_l
	inter = J(0, 0, .)   
	nv = J(0, 0, .)
	exnodes = 0
	minx = colmin(user_X)
	maxx = colmax(user_X)
	root = 	make_tree(user_X, user_h_e)
}

real rowvector iTree::geninter()
{
	return(runiform(2,1, minx, maxx)[1,] )
}

real colvector iTree::gennv()
{
	real colvector idxs, user_nv
	idxs = mm_srswor(p - exlevel - 1, p)
	user_nv   = rnormal(p, 1, 0, 1)
	user_nv[idxs] = J(length(idxs), 1,0)
	return(user_nv)
}

struct Node matrix iTree::nodesetup(real matrix user_X, real scalar user_h_e, 
					real colvector user_nv, 
					real rowvector user_inter, 
					struct Node matrix user_left,
					struct Node matrix user_right, 
					string scalar user_ntype)
{
	struct Node scalar node
	node.h_e = user_h_e
	node.size = rows(user_X)
	node.nv = user_nv
	node.inter = user_inter
	node.left = user_left
	node.right = user_right
	node.ntype = user_ntype
	return(node)
}



struct Node matrix iTree::make_tree(real matrix user_X, real scalar user_h_e,
					|real rowvector user_inter,
					real colvector user_nv)
{
	real rowvector u_inter
	real colvector u_nv
	real matrix w, nw
	real colvector minx, maxx
	real scalar i
	real vector idxs
	h_e = user_h_e
	if (args() == 4)
	{
		nv = user_nv
		inter = user_inter
	}
	if (user_h_e >= h_l | rows(user_X) <= 1)
	{
		exnodes = exnodes + 1
		return(nodesetup(user_X, user_h_e, user_nv, user_inter, 
		J(0, 0, .), J(0, 0, .), "exNode"))
	}else{
	    minx = colmin(user_X)
		maxx = colmax(user_X)
		idxs = mm_srswor(p - exlevel - 1, p)
		u_nv   = rnormal(p, 1, 0, 1)
		u_nv[idxs] = J(length(idxs), 1,0)
		u_inter = runiform(p, 1, minx, maxx)[1,]
		u_inter[idxs'] = J(1,length(idxs), 0)
		w = select(user_X, (user_X :- u_inter) * u_nv :<= 0)
		nw = select(user_X, (user_X :- u_inter) * u_nv :> 0)
		
		return(nodesetup(user_X, user_h_e, u_nv, u_inter, make_tree(w, 
		user_h_e + 1,u_inter, u_nv), make_tree(nw, user_h_e + 1, 
		u_inter, u_nv)	, "inNode"))
	}
}


class PathFactor
{
  //  string vector path_list
	real rowvector x
	real scalar h_e
	real scalar path
	void setup()
	real scalar find_path()
	
	private:
	real scalar cnt
	
}

void PathFactor::setup(real matrix user_x, class iTree scalar itree)
{
	x = user_x
	h_e = 0
	path = find_path(itree.root)
	cnt = 0
}
	
	
real scalar PathFactor::find_path(struct Node scalar itree)	
{
    real colvector nv
	real rowvector inter
	if (itree.ntype == "exNode")
	{
	    if(itree.size <= 1)
		{
		    return(h_e)
		}else{
		    h_e = h_e + cfactor(itree.size)
			return(h_e)
		}
	}else{
	    inter = itree.inter
		nv  = itree.nv
		h_e = h_e + 1
		if((x :- inter) * nv <= 0)
		{
			return(find_path(itree.left))
		}else{
			return(find_path(itree.right))
		}
	}
}



class iForest
{
	pointer(real matrix) scalar 	X 
	pointer (real vector) vector 	Trees
	real scalar 			nobjs
	real scalar 			p
	real scalar 			sample_size
	real scalar 			ntrees
	real scalar 			c
	real scalar 			limit  // Maximum height limit
	real scalar 			exlevel
	real colvector 			Yhat
	real matrix 			S
	string scalar 			graph
	
	// functions
	real matrix 			compute_path()
	void 				setup()
	void 				setup1()
	
}

//// Input as variables
void iForest::setup(string scalar varlist, string scalar touse, 
			real scalar  user_ntrees, real scalar user_sample,
			real scalar h_limit, real scalar user_extensionlevel) 
			//real scalar user_contamination)
{
	real scalar i
	real colvector indexx, indexy, X_p
	class iTree scalar itree
	real matrix user_X
	string colvector cv
	pragma unset user_X
	st_view(user_X, ., tokens(varlist), touse)
	X = &user_X
	ntrees = user_ntrees
	sample_size = user_sample
	nobjs = rows(*X)
	p     = cols(*X)

	if(nobjs < 0 | sample_size < 0)
	{
	    errprintf(" Sample size or number of observations is negative \n")
		exit(498)
	}
	if(nobjs < sample_size)
	{
	    errprintf(" Number of obsevations should be greater then sample size \n")
		exit(498)
	}
	if(ntrees <= 0)
	{
	    errprintf(" Number of Trees should be positive \n")
		exit(498)
	}
	Trees = J(ntrees, 1, NULL)
	exlevel = user_extensionlevel
	if (exlevel < 0 | exlevel > p)
	{
	    errprintf(" Exlevel is not specified correctly \n")
		exit(498)
	}
	if (h_limit == 0)
	{
		limit = ceil(log10(sample_size)/ log10(2))
	}else{
	    limit = h_limit
	}
	c = cfactor(sample_size)
	for(i = 1; i <= ntrees; i++)
	{
	   indexx = mm_srswor(sample_size, nobjs)
	   X_p = (*X)[indexx, ]  	   	   
	   itree.setup(X_p, 0 , limit, exlevel)
	   Trees[i] = &(itree)
	}
	st_numscalar("e(N)", nobjs)
	st_numscalar("e(k_vars)", p)
	st_numscalar("e(maxdepth)", limit)
	
}

// Input as matrix
void iForest::setup1(real matrix user_X, real scalar  user_ntrees, 
			real scalar user_sample, real scalar h_limit,
			real scalar user_extensionlevel) 
			//real scalar user_contamination)
{
	real scalar i
	real colvector indexx, indexy, X_p
	class iTree scalar itree
	X = &user_X
	ntrees = user_ntrees
	sample_size = user_sample
	nobjs = rows(*X)
	p     = cols(*X)
	if(nobjs < 0 | sample_size < 0)
	{
	    errprintf(" Sample size or number of observations is negative \n")
		exit(498)
	}
	if(nobjs < sample_size)
	{
	    errprintf(" Number of obsevations should be greater then sample size \n")
		exit(498)
	}
	if(ntrees <= 0)
	{
	    errprintf(" Number of Trees should be positive \n")
		exit(498)
	}
	Trees = J(ntrees, 1, NULL)
	exlevel = user_extensionlevel
	if (exlevel < 0 | exlevel > p)
	{
	    errprintf(" Exlevel is not specified correctly \n")
		exit(498)
	}
	if (h_limit == 0)
	{
		limit = ceil(log10(sample_size)/ log10(2))
	}else{
	    limit = h_limit
	}
	c = cfactor(sample_size)
	 for(i = 1; i <= ntrees; i++)
	{
	   indexx = mm_srswor(sample_size, nobjs)
	   X_p = (*X)[indexx, ]  
	   itree.setup(X_p, 0 , limit, exlevel)
	   Trees[i] = &(itree)
	}

	st_numscalar("e(N)", nobjs)
	st_numscalar("e(k_vars)", p)
	st_numscalar("e(maxdepth)", limit)

}

real matrix iForest::compute_path(| real matrix X_in)
{
	real scalar i, j, h_temp, Eh, score
	real colvector indxyhat
//	pointer (class iTree scalar) scalar r
	class PathFactor scalar pathfact
	if (args() == 0)
	{
	        X_in = *X
	}
	S = J(rows(X_in), 1, 0)
	for(i = 1; i <= rows(X_in); i++) {
	    h_temp = 0
		for (j = 1; j <= ntrees; j++) {
//		    r = Trees[j]
		    pathfact.setup(X_in[i,], *Trees[j])
		    h_temp = h_temp + pathfact.path
		}
		Eh = h_temp / ntrees
		S[i] = 2 ^ (-Eh/ c)
	}
	st_rclear()
	st_matrix("Score", S)
	
	if (graph == "") {
		st_store((1,nobjs), score = st_addvar("double", 
		st_tempname()), S)
		st_local("score",st_varname(score))
	}
	return(S)
}

/*
real matrix iForest::predict_Y(real matrix S)
{
        real colvector ibdxyhat
	indxyhat = selectindex(S :>= threshold)
	Yhat = J(rows(X_in), 1, 0)
	Yhat[indxyhat] = J(length(indxyhat), 1, 1)
	st_rclear()
	st_matrix("r(Yhat)",  Yhat)
		st_view("r(Yhat)",.,st_addvar("integer", Yhat))
	return Yhat
}
*/

end

