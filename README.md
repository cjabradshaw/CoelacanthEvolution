# Coelacanth evolution rate

Analyses accompanying article on coelacanth evolution.

<img align="right" src="www/coelacanth.png" alt="Latimeria chalumnae" width="400" style="margin-top: 20px">
<br>
<br>
Prof <a href="https://globalecologyflinders.com/people/#DIRECTOR">Corey J. A. Bradshaw</a> <br>
<a href="http://globalecologyflinders.com" target="_blank">Global Ecology</a> | <em><a href="https://globalecologyflinders.com/partuyarta-ngadluku-wardli-kuu/" target="_blank">Partuyarta Ngadluku Wardli Kuu</a></em>, <a href="http://flinders.edu.au" target="_blank">Flinders University</a>, Adelaide, Australia <br>
June 2023<br>
<a href=mailto:corey.bradshaw@flinders.edu.au>e-mail</a> <br>
<br>
article:<br>
<a href="https://www.flinders.edu.au/people/alice.clement">CLEMENT, AM</a>, <a href="https://www.uqar.ca/universite/a-propos-de-l-uqar/departements/departement-de-biologie-chimie-et-geographie/cloutier-richard">R CLOUTIER</a>, <a href="https://www.flinders.edu.au/people/mike.lee">MSY LEE</a>, <a href="https://www.naturalis.nl/en/science/researchers/benedict-king">B KING</a>, <a href="https://scholar.google.com/citations?user=6LHmxgUAAAAJ&hl=en">O VANHAESEBROUCKE</a>, <a href="https://globalecologyflinders.com/people/#DIRECTOR">CJA BRADSHAW</a>, <a href="https://sites.google.com/site/hugodutel/home">H DUTEL</a>, <a href="https://staffportal.curtin.edu.au/staff/profile/view/kate-trinajstic-f0dcf6b1/">K TRINAJSTIC</a>, <a href="https://www.flinders.edu.au/people/john.long">JA LONG</a>. A new Devonian coelacanth reveals cryptic disparity and rates of morphological evolution in the Actinistia. In review
<br>

## Abstract 
'Living fossils' are colloquially characterised as modern species that have undergone little evolutionary change over extended geological time. For more than 85 years, the coelacanth fishes (Sarcopterygii: Actinistia) have been portrayed as emblematic examples of 'living fossils', and one of the most morphologically conservative vertebrate groups. Here we describe a new, exceptionally well-preserved Late Devonian coelacanth from the Gogo Formation in Western Australia. This new fossil fish reveals rare insight into the branchial, neurocranial, and palaeoneurological condition of the earliest coelacanths. We performed the most comprehensive evolutionary analysis of the group to date, using discrete, meristic and continuous traits (including geometric morphometrics) to assess the phylogeny, evolutionary rates, and the morphological disparity of coelacanths. We show that coelacanths experienced a fast burst of evolution during the Devonian Period which then slowed considerably up to present day. Over the last 100 million years, discrete characters have essentially stopped evolving, but meristic and morphometric characters have continued to change. Coelacanths have long ceased evolving major new innovations, but minor tinkering of their body plan has continued unabated; thus, <em>Latimeria</em> can indeed be considered a 'living fossil', but with vital nuances.

## <a href="https://github.com/cjabradshaw/CoelacanthEvolution/tree/main/scripts">Scripts</a>
### 1. <a href="https://github.com/cjabradshaw/CoelacanthEvolution/tree/main/scripts/BRT">boosted regression trees</a>
- <code>Coelacanth evolR-envir model.R</code> (developed by <a href="https://globalecologyflinders.com/people/#DIRECTOR">Corey Bradshaw</a>): R code to reproduce the resampled boosted regression tree analysis for determining the environmental drivers of coelacanth rate of evolution.

### 2. <a href="https://github.com/cjabradshaw/CoelacanthEvolution/tree/main/scripts/BRT">phylogenetics</a>
- <code><a href="https://github.com/cjabradshaw/CoelacanthEvolution/tree/main/scripts/phylogenetics/BEAST">BEAST</a></code> (Bayesian phylogenetic analysis of molecular sequences; developed by <a href="https://www.flinders.edu.au/people/mike.lee">Mike Lee</a>)
- <code><a href="https://github.com/cjabradshaw/CoelacanthEvolution/tree/main/scripts/phylogenetics/PAUP">PAUP</a></code> (Phylogenetic Analysis Using Parsimony; developed by <a href="https://www.flinders.edu.au/people/mike.lee">Mike Lee</a>)
<img align="center" src="www/coelphylogeny.png" alt="coelacanth phylogeny" width="800" style="margin-top: 20px">

### 3. <a href="https://github.com/cjabradshaw/CoelacanthEvolution/tree/main/scripts/evolrate">rates of evolution</a>
- <code>rates_through_time.R</code> (developed by <a href="https://www.naturalis.nl/en/science/researchers/benedict-king">Ben King</a>): R code for plotting the uncorrelated log-normal (UCLN) clock rates through time requires BEAST time treefile (concatentated, post-burnin) for input.  This file contains 8000 trees and is 2 TB, and might have to be subsampled (thinned) due to memory constraints to run the script; plots in article subsampled every 5<sup>th</sup> tree. Tree file included here (<a href="https://github.com/cjabradshaw/CoelacanthEvolution/blob/main/scripts/evolrate/Coelacanths_87_268_tipsVariance_Dis_Mer_Con_uclnG_RootExp418_MC3_sumBi20%3Athinned.trees">Coelacanths_87_268_tipsVariance_Dis_Mer_Con_uclnG_RootExp418_MC3_sumBi20/thinned.trees</a>) is only the first 10 trees from this subsampled file (~ 2 GB).
- <code>functions.R</code>: R source functions called in <code>rates_through_time.R</code>
- <code>epoch_clock.R</code>: R code to create <em>epoch_clock</em> plot (below)
<img align="center" src="www/epoch_clock.png" alt="epoch clock" width="800" style="margin-top: 20px">

## <a href="https://github.com/cjabradshaw/CoelacanthEvolution/tree/main/data">Data</a>
- <em>coelacanthEvolRenvDat.csv</em> (compiled by <a href="https://www.uqar.ca/universite/a-propos-de-l-uqar/departements/departement-de-biologie-chimie-et-geographie/cloutier-richard">Richard Cloutier</a>): rate of evolution and environmental data (subduction flux, % shallow seas, atmospheric CO<sub>2</sub>, sea surface temperature, dissolved O<sub>2</sub>

## Required R libraries
- <code>dismo</code>
- <code>gbm</code>
- <code>tidyverse</code>
- <code>data.table</code>
- <code>dispRity</code>
- <code>phylotate</code>
- <code>geoscale</code>
- <code>phytools</code>

<p><a href="https://www.flinders.edu.au"><img align="bottom-left" src="www/Flinders_University_Logo_Horizontal_RGB_Master.png" alt="Flinders University" width="150" style="margin-top: 20px"></a> &nbsp; <a href="https://globalecologyflinders.com"><img align="bottom-left" src="www/GEL Logo Kaurna New Transp.png" alt="GEL" width="85" style="margin-top: 20px"></a> &nbsp; &nbsp; <a href="https://www.uqar.ca/"><img align="bottom-left" src="www/UQARlogo.png" alt="UQAR" width="100" style="margin-top: 20px"></a> &nbsp; &nbsp; <a href="https://www.samuseum.sa.gov.au/"><img align="bottom-left" src="www/SAMlogo.png" alt="SAM" width="110" style="margin-top: 20px"></a> &nbsp; &nbsp; <a href="https://www.bristol.ac.uk"><img align="bottom-left" src="www/UBlogo.png" alt="UB" width="90" style="margin-top: 20px"></a> &nbsp; &nbsp; &nbsp; <a href="https://www.naturalis.nl/en"><img align="bottom-left" src="www/NBClogo.png" alt="NCU" width="60" style="margin-top: 20px"></a> &nbsp; &nbsp; &nbsp; <a href="https://www.curtin.edu.au/"><img align="bottom-left" src="www/CUlogo.png" alt="CU" width="50" style="margin-top: 20px"></a></p>
