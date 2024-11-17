*! version 1.0.0 12sep2021
version 17.0

set matastrict on
mata:

real matrix gendata(real scalar n, real scalar p,|  string scalar type , real scalar seed, real scalar cont )
{
	real colvector mean, mean1, mean2, mean3, mean4, X, x, y, x1, y1, theta, idx, center, theta1, idx1, idx2, Y, Y1, Y2
	real matrix X1, X2, sigma, an1, an2, anom, sigma1
	real scalar R1, R
    if (type == "")
	{
	    printf("Type is not specified, adopting normal type \n")
		type = "Normal"
	}
 //   rseed(seed)
	if ( n <= 1 | p <= 1)
	{
	    errprintf(" n should be positive and p > 1 \n")
		exit(498)
	}
	if(cont == .)
	{
	    cont = 0.1
	}
	if (cont < 0 | cont > 1)
	{
	    errprintf(" cont should be between [0,1] \n")
		exit(498)
	}
	if (type == "normal")
	{
	    Y = J(n, 1, 0)
	    mean = J(p, 1, 0)
		sigma = I(p) * 0.1
		X = mvrnorm(n, mean, sigma)
		idx = mm_srswor(ceil(n * cont), n)
	    mean1 = (0 \ J(p - 1, 1, 2))
		mean2 = (J(p - 1, 1, 2) \ 0)
	    sigma1 = I(p) :* 0.01
		an1 = mvrnorm(ceil(length(idx)/2), mean1, sigma1)
		an2 = mvrnorm(floor(length(idx)/2), mean2, sigma1)
		anom = (an1 \ an2)
		X[idx, ] = anom  //X[idx, ] :+
		Y[idx] = J(length(idx), 1, 1)
	}
	if( type ==  "cluster")
	{
		sigma = I(p) :* 0.2
	    mean1 = (0 \ J(p - 1, 1, 10))
		mean2 = (J(p - 1, 1, 10) \ 0)
	//	sigma1 = I(p) 
	    Y1 = J(ceil(n/2), 1, 0)
		Y2 = J(floor(n/2), 1, 0)
		X1 = mvrnorm(ceil(n/2), mean1, sigma)
		X2 = mvrnorm(floor(n/2), mean2, sigma)
		idx1 = mm_srswor(ceil(n/2 * cont), n/2)
		idx2 = mm_srswor(floor(n/2 * cont), n/2)
		Y1[idx1] = J(length(idx1), 1, 1)
		Y2[idx2] = J(length(idx2), 1, 1)
//		idx1 = idx[1 .. length(idx)/2]
//		idx2 = idx[(length(idx)/2 + 1) .. length(idx)]
	    sigma1 = I(p) * 3.5
		an1 = mvrnorm(ceil(length(idx1)), mean1, sigma1)
		an2 = mvrnorm(ceil(length(idx2)) , mean2, sigma1)
		//anom = (an1 \ an2)
		X1[idx1, ] = an1 //X[idx, ] :+
		X2[idx2, ] = an2
		X = (X1 \ X2)
		Y = (Y1 \ Y2)
	}
	if ( type == "ring")
	{
	    if(p > 2)
		{
		    errprintf(" This option available only for p = 2 \n")
			exit(498)
		}
		R = 6
		center = J(2, 1, 0)
		theta = runiform(n, 1) * 2 * pi()
		x = center[1] :+ R * cos(theta) :+ rnormal(n, 1, 0, 0.4)
		y = center[2] :+ R * sin(theta) :+ rnormal(n, 1, 0, 0.4)
		R1 = R / 3
		theta1 = runiform(n/20, 1) * 2 * pi()
		x1 = center[1] :+ R1 * cos(theta1) :+ rnormal(ceil(n / 20), 1, 0, 0.4)
		y1 = center[2] :+ R1 * sin(theta1) :+ rnormal(ceil(n / 20), 1, 0, 0.4)
		x = (x \ x1)
		y = (y \ y1)
		X = (x , y)
	}
		if ( type == "sinusoid")
	{
	    if(p > 2)
		{
		    errprintf(" This option available only for p = 2 \n")
			exit(498)
		}
		x = runiform(n, 1) * 8 * pi()
		y = sin(x) :+ rnormal(n, 1, 0, 1) / 2
		X = (x , y)
	}
	st_rclear()
	st_matrix("r(X)", X)
	st_matrix("r(Y)", Y)
	return(X)
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
end