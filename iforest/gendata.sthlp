{smcl}
{* *! version 1.0.0  jun2020}{...}
{vieweralsosee "[iforest] Anomaly detection" "help iforest"}{...}
{viewerjumpto "Syntax" "gendata##syntax"}{...}
{viewerjumpto "Options for gendata" "gendata##options"}{...}
{viewerjumpto "Examples of gendata"gendata##examples_gendata"}{...}
{viewerjumpto "Stored results" "gendata##results"}{...}


{p2colset 1 16 18 2}{...}
{p2col:{bf: gendata} {hline 2}} Generates Data for anomaly detection.{p_end}
{p2colreset}{...}



{marker syntax}{...}
{title:Syntax}

{pstd}
Generates structured data from multivariate normal distribution for 
anomaly detection using {it: normal}, and {it: cluster} structures.

{p 8 18 2}
{cmd:gendata} {cmd:,} {it: n(#)} {it: p(#)} [{it: type(string)}]

{phang}
{it:n(#)} The number of observations of sample size. {p_end}

{phang}
{it:p(#)} The number of variables(dimension) of sample size. {p_end}
{phang}
{it:type(string)} Type of the data structure: normal, cluster, and ring. {it: Normal} generates
population data from multivariate normal distribution with two clusters anomalies. The distance between the center of normal cluster and anomaly clusters is equal 2.
{it: Cluster} population data consists of two clusters with variance 0.5.and anomalies have the same cluster centers with higher variance equal to 2.5. 
In both structures the number of anomalies over the total number of normal observations is equal to 0.1. The default structure type is {\it Normal}.{p_end}
{synoptset 20 tabbed}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:gendata} The data is generated as follows: For type Normal we generate data from multivariate normal distribution N(0,0.1*I), where  I is a p x p identity matrix.
The two anomaly cluster are generated from multivariate normal in a way that the distance between the normal data center and clusters center is equal 2 and covariance matrix is 0.05*I. 
For type Cluster, we generate two cluster from multivariate normal distribution with different centers and covariance matrix equal to 0.5*I. The anomalies are generated with the same centers
as population data but with higher variances.

{marker examples_gendata}{...}
{title:Examples of gendata}
{pstd}Simulating data with n = 100, p = 2 and Normal type.{p_end}
{phang2}{cmd:. gendata,n(100) p(150) type(normal)}{p_end}

{pstd} Extract the data and the binary vector with true anomalies.{p_end}
{phang2}{cmd:. mat X = r(X)} {p_end}
{phang2}{cmd:. mat Y = r(Y)} {p_end} 
{phang2}{cmd:. svmat X}      {p_end}

{pstd} Plot the data{p_end}
{phang2}{cmd:. graph twoway scatter X2 X1, mcolor("bluishgray") }{p_end}

{pstd}Simulating data with n = 100, p = 2 and Cluster type.{p_end}
{phang2}{cmd:. gendata,n(100) p(150) type(cluster)}{p_end}

{pstd} Extract the data and the binary vector with true anomalies.{p_end}
{phang2}{cmd:. mat X = r(X)} {p_end}
{phang2}{cmd:. mat Y = r(Y)} {p_end} 
{phang2}{cmd:. svmat X}      {p_end}

{pstd} Plot the data{p_end}
{phang2}{cmd:. graph twoway scatter X2 X1, mcolor("bluishgray") }{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:gendata} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(X)}}Generated data matrix{p_end}
{synopt:{cmd:r(Y)}}Binary vector that admits 1 if the observation is anomaly.{p_end}
{p2colreset}{...}
