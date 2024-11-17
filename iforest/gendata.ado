*! version 1.0.0 12sep2021

program gendata, rclass
version 17

	syntax  , n(integer) p(integer) ///
	[type(string)  seed(real 111)]  

	if "`type'" != "normal" & "`type'" != "cluster" & "`type'" != "ring" & "`type'" != "sinusoid" {
	   display as error "type should be one of the following normal, cluster, ring or sinusoid" 
	}
	capt mata mata which mm_srswor()
	if _rc!= 0 {
         di as txt "user-written package moremata needs to be installed first;"
         di as txt "use -ssc install moremata- to do that \m"
         exit 498
}
	if `seed' < 0{
	    display as error "Seed should be positive "
		exit 498
	}
	
	mata: X = gendata(`n', `p', "`type'" , `seed')

	return add

end

