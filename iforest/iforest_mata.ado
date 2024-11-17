version 16
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
	real colvector nv // normal vector
	real colvector inter // Intercept for the hyperplane
	struct Node matrix left
	struct Node matrix right
	string scalar ntype
}


class iTree
{
    real scalar exlevel
	real scalar h_e
//	real scalar ntype
	real scalar size
	real scalar p
	real colvector Q
	real scalar h_l
	real rowvector inter
	real colvector nv
	real scalar exnodes
	struct Node scalar root
	void setup()
	struct Node matrix make_tree()
}

void iTree::setup(real matrix user_X, real scalar user_h_e, real scalar user_l, real scalar user_exlevel)
{
    exlevel = user_exlevel
	h_e = user_h_e
	size = rows(user_X)
	p     = cols(user_X)
	Q = J(p, 1, .)
	h_l = user_l
	inter = J(p, 1, .)
	nv = J(p,1, .)
	exnodes = 0
	root = make_tree(user_X, h_e )
}


struct Node matrix iTree::make_tree(real matrix user_X, real scalar user_h_e)
{
    struct Node scalar node
	real matrix w, nw
	real scalar minx, maxx
	real vector idxs
    h_e = user_h_e
	if (h_e >= h_l | rows(user_X) <= 1)
	{
		exnodes = exnodes + 1
		node.nv = nv
		node.size = size
		node.inter = inter
		node.ntype = "exNode"
		return(node)
	}else{
	    minx = colmin(user_X)
		maxx = colmax(user_X)
		idxs = mm_srswor(p - exlevel - 1, p)
		nv   = rnormal(p, 1, 0, 1)
		nv[idxs] = J(length(idxs), 1,0)
		inter = (runiform(p, 1, minx, maxx)[1,])
		w = select(user_X, (user_X :- inter) * nv :< 0)
		nw = select(user_X, (user_X :- inter) * nv :>= 0)
		node.nv = nv
		node.size = size
		node.inter = inter
		node.left = make_tree(w, h_e + 1)
		node.right = make_tree(nw, h_e + 1)
		node.ntype = "inNode"
		return(node)
	}
	
}



class PathFactor
{
  //  string vector path_list
	real matrix x
	real scalar h_e
	real scalar path
	void setup()
	real scalar find_path()
	
	private:
	real scalar cnt
	
}

void PathFactor::setup(real matrix user_x, class iTree scalar itree)
{
   // path_list = J(rows(user_x), 1, "" )
	x = user_x
	h_e = 0
	path = find_path(itree.root)
	cnt = 0
}
	
	
real scalar PathFactor::find_path(struct Node matrix itree)	
{
    real colvector inter, nv
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
		cnt = cnt + 1
	//	printf("cnt is %g\n", cnt)
		if((x - inter) * nv < 0)
		{
//		    path_list[cnt] = "L"
			return(find_path(itree.left))
		}else{
	//	    path_list[cnt] = "R"
			return(find_path(itree.right))
		}
	}
}


real matrix mvrnorm(real scalar nobs, real colvector mean, real matrix sigma)
{
	real matrix L, X
	real colvector u
	real scalar p,i
	p = rows(sigma)
	L = cholesky(sigma)
	X = J(nobs, p, 0)
	for(i = 1; i<= nobs; i++)
	{
		u = rnormal(p,1, 0, 1)
		X[i, ] = (mean + L * u )'
	}	
	return(X)
}


class iForest
{
    real scalar ntrees
	real scalar c
	pointer(real matrix) scalar X 
	real scalar nobjs
	real scalar p
	real scalar sample_size
	pointer (real vector) vector Trees
	real scalar limit  // Maximum height limit
	real scalar exlevel
	real matrix compute_path()
	void setup()
	
}


// Input as matrix
void iForest::setup(real matrix user_X, real scalar  user_ntrees, real scalar user_sample, real scalar h_limit, real scalar user_extensionlevel)
{
    real scalar i
	real colvector index, X_p
	class iTree scalar itree
    X = &user_X
    ntrees = user_ntrees
	sample_size = user_sample
	nobjs = rows(*X)
	p     = cols(*X)
	if(nobjs < 0 | sample_size < 0)
	{
	    errprintf(" Sample size or number of observations is negative")
		exit(498)
	}
	if(nobjs < sample_size)
	{
	    errprintf(" Number of obsevations should be greater then sample size")
		exit(498)
	}
	if(ntrees <= 0)
	{
	    errprintf(" Number of Trees should be positive")
		exit(498)
	}

	Trees = J(ntrees, 1, NULL)
	exlevel = user_extensionlevel
	if (exlevel < 0 | exlevel > p)
	{
	    errprintf(" Exlevel is not specified correctly ")
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
	   index = mm_srswor(sample_size, nobjs)
	   X_p = (*X)[index,]  	   	   
	   itree.setup(X_p, 0 , limit, exlevel)
	   Trees[i] = &(itree)
	}
}

real matrix iForest::compute_path( | real matrix X_in)
{
    real matrix S
	real scalar i, j, h_temp, Eh
	pointer (class iTree scalar) scalar r
	class PathFactor scalar pathfact
	class iTree scalar nd
    if (args() == 0)
	{
	    X_in = *X
	}
	S = J(rows(X_in), 1, 0)
	for(i = 1; i <= rows(X_in); i++)
	{
	    h_temp = 0
		for (j = 1; j <= ntrees; j++)
		{
		    r = Trees[j]
		    pathfact.setup(X_in[i,], *r)
		    h_temp = h_temp + pathfact.path
		}
		Eh = h_temp / ntrees
		S[i] = 2 ^ (-Eh/ c)
	}
    st_rclear()
	st_matrix("r(Score)", S)
	return(S)
}


end
