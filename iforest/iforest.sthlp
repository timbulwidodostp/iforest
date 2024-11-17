{smcl}
{* *! version 1.0.0  jun2020}{...}
{vieweralsosee "[GD] Generate Data" "help gendata"}{...}
{vieweralsosee "[iforest] Predict" "help iforest_p"}{...}
{vieweralsosee "[iforest] Estimate Metrix" "help iforest_estat"}{...}
{vieweralsosee "[r] Histogram" "help histogram"}{...}
{viewerjumpto "Syntax" "iforest##syntax"}{...}
{viewerjumpto "Options for iForest"iforest##options"}{...}
{viewerjumpto "Examples of iForest"iforest##examples"}{...}
{viewerjumpto "Stored results" "iforest##results"}{...}
{viewerjumpto "Reference" "iforest##reference"}{...}

{p2colset 1 16 18 2}{...}
{p2col:{bf: iforest} {hline 2}}Isolation Forest{p_end}
{p2colreset}{...}



{marker syntax}{...}
{title:Syntax}

{pstd}
Detects anomaly observation by recursively isolating and buiding trees.

{p 8 15 2}
{cmdab:iforest} {varlist} {ifin}
[{cmd:,}
{it:{help iforest##options_table:options}}]

{pstd}
Isolates anomalies using binary trees.

{synoptset 20 tabbed}{...}

{marker options_table}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt:{opt ntrees(#)}} Number of trees to be used in the ensemble. Default value is 200. {p_end}
{synopt:{opt samplesize(#)}} The size of the sample to draw from data to train each tree. Must be smaller then number of observations n.{p_end}
{synopt:{opt maxdepth(#)}} The maximum depth the tree can grow. Default is log2(samplesize)  .{p_end}
{synopt:{opt extlevel(#)}}  Specifies degree of freedom in choosing the hyperplanes for dividing up data ({help iforest##eiforest2018:Haririr and et.al 2018}). 
Must be smaller than the number of observations n of the data.{p_end}
{synopt: {opt noHist}} Whether to plot the histogram for the estimated score .{p_end} 
{synopt: {opt hist_options(#)}} Histogram options {helpb histogram}{p_end} 
{marker description}{...}
{title:Description}

{pstd}
{cmd:iforest} iforest builds an ensemble of isolation trees for a given dataset, 
then anomalies are those which have short average path length on the trees.
({help iforest##iforest2008:Liu and et.al 2008}). 

{pstd}
{cmd:iforest} allows data in both the form of variable and Stata matrix.

{marker examples_iforest}{...}
{title:Examples of iforest}
{phang2}{cmd:. set seed 15}{p_end}

{pstd}Setup by simulating data from {helpb gendata}{p_end}
{phang2}{cmd:. gendata, n(600) p(2) type(cluster)}{p_end}

{pstd} Isolate anomalies chosing ntrees = 100, subsample = 256, extlevel = 1. {p_end}
{phang2}{cmd:. iforest X1 X2 ,extlevel(1) ntrees(100) subsample(256) threshold(2)}{p_end}

{pstd} Return the estimated scores. {p_end}
{phang2}{cmd:. mat list e(Score)}{p_end}

{pstd} Predict anomalies {helpb predict}. {p_end}
{phang2}{cmd:. predict Yhat, threshold(0.7) }{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:iforest} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}

{p2col 5 20 24 2: Scalar}{p_end}
{synopt:{cmd:e(N)}} Number of observations{p_end}
{synopt:{cmd:e(k_vars)}} Number of variables{p_end}
{synopt:{cmd:e(maxdepth)}} Maximum depth of the tree{p_end}
{synopt:{cmd:e(ntree)}} Number of trees{p_end}
{synopt:{cmd:e(samplesize)}} Batch size{p_end}
{synopt:{cmd:e(extlevel)}} Degrees of freedom for the hyperplane{p_end}

{p2col 5 20 24 2: Matrix}{p_end}
{synopt:{cmd:e(Score)}} Estimated scores{p_end}
{p2colreset}{...}

{marker reference}{...}
{title:Reference}

{marker iforest2008}{...}
{phang}
Fei Tony Liu, Kai Ming Ting, and Zhi-Hua Zhou. 2008. Isolation Forest. 
In Proceedings of the 2008 Eighth IEEE International Conference on Data Mining (ICDM ’08). 
IEEE Computer Society, USA, 413–422. DOI:https://doi.org/10.1109/ICDM.2008.17
{p_end}
{marker eiforest2018}{...}
{phang}
Sahand Hariri and Matias Carrasco Kind and Robert J. Brunner. 2018. Extended Isolation Forest. 
http://arxiv.org/abs/1811.02141.
{p_end}

