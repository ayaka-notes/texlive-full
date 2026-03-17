# CPU 核心检测
cores <- parallel::detectCores()
cat("Detected CPU cores:", cores, "\n")
# 使用两倍并行
jobs <- cores * 2
Sys.setenv(MAKEFLAGS = paste0("-j", jobs))
cat("MAKEFLAGS =", Sys.getenv("MAKEFLAGS"), "\n")

# 如果没有 remotes 就安装
if (!requireNamespace("remotes", quietly = TRUE))
  install.packages("remotes", repos="https://cloud.r-project.org")

# 把你的包列表直接粘到这里
txt <- "
abind 1.4-5
acepack 1.4.1
ADGofTest 0.3
admisc 0.28
AER 1.2-10
agricolae 1.3-5
AlgDesign 1.2.1
alr4 1.0.6
animation 2.7
ash 1.0-15
askpass 1.1
assertthat 0.2.1
backports 1.4.1
base64enc 0.1-3
BayesFactor 0.9.12-4.3
bayesm 3.1-4
bayesplot 1.9.0
bayestestR 0.12.1
BB 2019.10-1
bbmle 1.0.25
bdsmatrix 1.3-6
Benchmarking 0.30
betareg 3.1-4
BH 1.78.0-0
bibtex 0.4.2.3
bindr 0.1.1
Biobase 2.54.0
BiocGenerics 0.40.0
BiocManager 1.30.18
BiocVersion 3.14.0
bit 4.0.4
bit64 4.0.5
bitops 1.0-7
blavaan 0.4-3
blob 1.2.3
BMA 3.18.17
boot 1.3-28
brio 1.1.3
broom 0.8.0
bslib 0.3.1
ca 0.71.1
cachem 1.0.6
calculus 0.3.3
callr 3.7.0
car 3.1-0
carData 3.0-5
caret 6.0-92
cartogram 0.2.2
caTools 1.18.2
CDM 8.1-12
cellranger 1.1.0
changepoint 2.2.3
checkmate 2.1.0
chron 2.3-57
CircStats 0.2-6
circular 0.4-95
class 7.3-20
classInt 0.4-7
cli 3.3.0
clipr 0.8.0
cluster 2.1.3
cmna 1.0.5
coda 0.19-4
codetools 0.2-18
coin 1.4-2
collapse 1.8.6
colorspace 2.0-3
combinat 0.0-8
commonmark 1.8.0
compositions 2.0-4
CompQuadForm 1.4.3
conflicted 1.1.0
contfrac 1.1-12
copula 1.1-0
corpcor 1.6.10
correlation 0.8.1
corrplot 0.92
cowplot 1.1.1
coxme 2.2-17
coxphw 4.0.2
cpm 2.3
cpp11 0.4.2
crayon 1.5.1
crosstalk 1.2.0
cubature 2.0.4.4
curl 4.3.2
DAAG 1.25.4
data.table 1.14.2
datawizard 0.4.1
DBI 1.1.2
dbplyr 2.2.0
dcurver 0.9.2
deldir 1.0-6
dendextend 1.15.2
DEoptim 2.2-6
DEoptimR 1.0-11
Deriv 4.1.3
desc 1.4.1
deSolve 1.32
dfoptim 2020.10-1
diagram 1.6.5
dials 1.0.0
DiceDesign 1.9
dichromat 2.0-0.1
diffobj 0.3.5
digest 0.6.29
distributional 0.3.0
doBy 4.6.13
doParallel 1.0.17
dotCall64 1.0-1
dplyr 1.0.9
DT 0.23
dtplyr 1.2.1
dynlm 0.3-6
e1071 1.7-11
earth 5.3.1
Ecdat 0.4-0
Ecfun 0.2-6
economiccomplexity 1.1
effects 4.2-1
effectsize 0.7.0
ellipse 0.4.3
ellipsis 0.3.2
elliptic 1.4-0
emmeans 1.7.4-1
eRm 1.0-2
estimability 1.3
evaluate 0.15
exactRankTests 0.8-35
expm 0.999-6
extrafont 0.18
extrafontdb 1.0
factoextra 1.0.7
FactoMineR 2.4
fansi 1.0.3
faraway 1.0.7
farver 2.1.0
fastICA 1.2-3
fastmap 1.1.0
fastmatch 1.1-3
fBasics 3042.89.2
fda 6.0.3
fdrtool 1.2.17
fds 1.8
fdth 1.2-6
fftwtools 0.9-11
fGarch 3042.83.2
filehash 2.4-3
flashClust 1.01-2
flexmix 2.3-18
FNN 1.1.3.1
fontawesome 0.2.2
forcats 0.5.1
foreach 1.5.2
forecast 8.16
foreign 0.8-82
formatR 1.12
Formula 1.2-4
fracdiff 1.5-1
frontier 1.1-8
fs 1.5.2
furrr 0.3.0
future 1.26.1
future.apply 1.9.0
gamlss 5.4-3
gamlss.data 6.0-2
gamlss.dist 6.0-3
gamm4 0.2-6
gargle 1.2.0
gdata 2.18.0.1
gdtools 0.2.4
GeneNet 1.2.16
generics 0.1.2
GenSA 1.1.7
geojsonsf 2.0.3
geometries 0.2.0
ggcorrplot 0.1.3
ggeffects 1.1.2
ggplot2 3.3.6
ggplot2movies 0.0.1
ggpubr 0.4.0
ggrepel 0.9.1
ggridges 0.5.3
ggsci 2.9
ggsignif 0.6.3
ggstatsplot 0.9.3
ggtext 0.1.1
glasso 1.11
glassoFast 1.0
glm2 1.2.1
glmnet 4.1-4
globals 0.15.0
glue 1.6.2
gmodels 2.18.1.1
gnm 1.1-2
goftest 1.2-3
googledrive 2.0.0
googlesheets4 1.0.0
gower 1.0.0
GPArotation 2022.4-1
GPfit 1.0-8
gplots 3.1.3
gridBase 0.4-7
gridExtra 2.3
gridGraphics 0.5-1
gridSVG 1.7-4
gridtext 0.1.4
grImport 0.9-5
grImport2 0.2-0
gsl 2.1-7.1
gss 2.2-3
gsubfn 0.7
gtable 0.3.0
gtools 3.9.2.2
hardhat 1.1.0
haven 2.5.0
hdrcde 3.4
hexbin 1.28.2
highlight 0.5.0
highr 0.9
Hmisc 4.7-0
hms 1.1.1
hrbrthemes 0.8.0
HSAUR2 1.1-19
htmlTable 2.4.0
htmltools 0.5.2
htmlwidgets 1.5.4
httpuv 1.6.5
httr 1.4.3
hypergeo 1.2-13
ibdreg 0.3.6
ICS 1.3-1
ICSOutlier 0.3-0
ids 1.0.1
igraph 1.3.2
infer 1.0.2
InformationValue 1.2.3
inline 0.3.19
insight 0.17.1
ipred 0.9-13
IQCC 0.7
irlba 2.3.5
isoband 0.2.5
iterators 1.0.14
itertools 0.1-3
itsmr 1.9
JointAI 1.0.3
jpeg 0.1-9
jquerylib 0.1.4
jsonify 1.2.1
jsonlite 1.8.0
kableExtra 1.3.4
kernlab 0.9-31
KernSmooth 2.23-20
klaR 1.7-0
km.ci 0.5-6
KMsurv 0.1-5
knitr 1.39
ks 1.13.5
labeling 0.4.2
labelled 2.9.1
Lahman 10.0-1
lars 1.3
later 1.3.0
latex2exp 0.9.4
lattice 0.20-45
latticeExtra 0.6-29
lava 1.6.10
lavaan 0.6-11
lazyeval 0.2.2
leafem 0.2.0
leaflet 2.1.1
leaflet.providers 1.9.0
leafsync 0.1.0
leaps 3.1
LearnBayes 2.15.1
lemon 0.4.5
lhs 1.1.5
libcoin 1.0-9
lifecycle 1.0.1
listenv 0.8.0
littler 0.3.15
lm.beta 1.6-2
lme4 1.1-29
lmerTest 3.1-3
lmtest 0.9-40
locfit 1.5-9.5
locpol 0.7-0
lomb 2.1.0
longitudinal 1.1.13
loo 2.5.1
lpSolveAPI 5.5.2.0-17.7
lsmeans 2.30-0
ltm 1.2-0
lubridate 1.8.0
lwgeom 0.2-8
magick 2.7.3
magrittr 2.0.3
mapdata 2.3.0
mapproj 1.2.8
maps 3.4.0
maptools 1.1-4
markdown 1.1
MASS 7.3-57
mathjaxr 1.6-0
Matrix 1.4-1
MatrixModels 0.5-0
matrixStats 0.62.0
maxLik 1.5-2
maxstat 0.7-25
mc2d 0.1-21
mclust 5.4.10
mcmcse 1.5-0
memoise 2.0.1
MEMSS 0.9-3
meta 5.2-0
metadat 1.2-0
metafor 3.4-0
mgcv 1.8-40
mice 3.14.0
micEcon 0.6-16
micEconIndex 0.1-6
microbenchmark 1.4.9
mime 0.12
miniUI 0.1.1.1
minqa 1.2.4
mirt 1.36.1
misc3d 0.9-1
miscTools 0.6-26
mistat 2.0.3
mitools 2.4
mlbench 2.1-3
mlmRev 1.0-8
mnormt 2.1.0
modeldata 0.1.1
ModelMetrics 1.2.2.2
modelr 0.1.8
modeltools 0.2-23
moments 0.14.1
mondate 0.10.02
msm 1.6.9
mstate 0.3.2
multcomp 1.4-19
multicool 0.1-12
munsell 0.5.0
mvtnorm 1.1-3
nanotime 0.3.6
network 1.17.2
nlme 3.1-158
nloptr 2.0.3
nls2 0.3-3
nlstools 2.0-0
NMF 0.24.0
nnet 7.3-17
nonlinearTseries 0.2.12
nonnest2 0.5-5
norm2 2.0.4
nortest 1.0-4
np 0.60-11
numDeriv 2016.8-1.1
nycflights13 1.0.2
openair 2.9-1
OpenMx 2.20.6
openssl 2.0.2
openxlsx 4.2.5
optextras 2019-12.4
optimx 2022-4.30
oz 1.0-21
packcircles 0.3.4
paletteer 1.4.0
parallelly 1.32.0
parameters 0.18.1
parsnip 1.0.0
party 1.3-10
patchwork 1.1.1
pbapply 1.5-0
pbivnorm 0.6.0
pbkrtest 0.5.1
PBSmapping 2.73.0
pcaMethods 1.86.0
pcaPP 2.0-1
performance 0.9.0
PerformanceAnalytics 2.0.4
permute 0.9-7
pillar 1.7.0
pixmap 0.4-12
pkgbuild 1.3.1
pkgconfig 2.0.3
pkgKitten 0.2.2
pkgload 1.2.4
pkgmaker 0.32.2
PKPDmodels 0.3.2
plm 2.6-1
plogr 0.2.0
plot3D 1.4
plotly 4.10.0
plotmo 3.6.2
plotrix 3.8-2
pls 2.8-0
plyr 1.8.7
png 0.1-7
polyclip 1.10-0
polycor 0.8-1
polynom 1.4-1
popbio 2.7
PortfolioAnalytics 1.1.0
posterior 1.2.2
pracma 2.3.8
praise 1.0.0
prettyunits 1.1.1
prismatic 1.1.0
pROC 1.18.0
processx 3.6.1
prodlim 2019.11.13
progress 1.2.2
progressr 0.10.1
promises 1.2.0.1
proto 1.0.0
proxy 0.4-27
ps 1.7.0
pso 1.0.4
pspline 1.0-19
psych 2.2.5
purrr 0.3.4
qcc 2.7
qicharts2 0.7.2
quadprog 1.5-8
quantmod 0.4.20
quantreg 5.93
questionr 0.7.7
qvcalc 1.0.2
R.cache 0.15.0
R.methodsS3 1.8.2
R.oo 1.25.0
R.utils 2.11.0
R6 2.5.1
rainbow 3.6
randomForest 4.7-1.1
randomizeR 2.0.0
randtests 1.0
rapidjsonr 1.2.0
rappdirs 0.3.3
raster 3.5-15
rbibutils 2.2.8
Rcgmin 2022-4.30
RColorBrewer 1.1-3
Rcpp 1.0.8.3
RcppArmadillo 0.11.2.0.0
RcppCCTZ 0.2.10
RcppDate 0.0.3
RcppEigen 0.3.3.9.2
RcppParallel 5.1.5
RCurl 1.98-1.7
rdd 0.57
rddtools 1.6.0
Rdpack 2.3.1
rdrobust 2.0.2
readr 2.1.2
readstata13 0.10.0
readxl 1.4.0
recipes 0.2.0
registry 0.5-1
relaimpo 2.2-6
relimp 1.0-5
rematch 1.0.1
rematch2 2.1.2
reporttools 1.1.3
reprex 2.0.1
reshape 0.8.9
reshape2 1.4.4
rex 1.2.1
RGraphics 3.0-2
RHRV 4.2.6
rio 0.5.29
rjags 4-13
rJava 1.0-6
rjson 0.2.21
rlang 1.0.2
Rlinsolve 0.3.2
rmarkdown 2.14
rngtools 1.5.2
robustbase 0.95-0
ROI 1.0-0
ROI.plugin.quadprog 1.0-0
rpart 4.1.16
rpf 1.0.11
rprojroot 2.0.3
rrcov 1.7-0
rsample 0.1.1
RSQLite 2.2.14
rstan 2.21.5
rstantools 2.2.0
rstatix 0.7.0
rstudioapi 0.13
Rttf2pt1 1.3.10
rvest 1.0.2
Rvmmin 2018-4.17.1
Ryacas 1.1.3.1
s2 1.0.7
sandwich 3.0-2
sass 0.4.1
scales 1.2.0
scatterplot3d 0.3-41
selectr 0.4-2
setRNG 2022.4-1
sf 1.0-7
sfheaders 0.4.0
shape 1.4.6
shiny 1.7.1
SixSigma 0.10.3
sjlabelled 1.2.0
sjmisc 2.8.9
sjPlot 2.8.10
sjstats 0.18.1
slam 0.1-50
slider 0.2.2
sm 2.2-5.7
soiltexture 1.5.1
sourcetools 0.1.7
sp 1.5-0
spam 2.8-0
SparseM 1.81
spatial 7.3-15
spatialreg 1.2-3
spatstat 2.3-4
spatstat.core 2.4-4
spatstat.data 2.2-0
spatstat.geom 2.4-0
spatstat.linnet 2.3-2
spatstat.random 2.2-0
spatstat.sparse 2.1-1
spatstat.utils 2.3-1
spc 0.6.6
spData 2.0.1
spdep 1.2-4
sphet 2.0
splm 1.5-3
sqldf 0.4-11
SQUAREM 2021.1
stabledist 0.7-1
StanHeaders 2.21.0-7
stargazer 5.2.3
stars 0.5-5
statmod 1.4.36
statnet.common 4.6.0
statsExpressions 1.3.2
stringi 1.7.6
stringr 1.4.0
strucchange 1.5-3
styler 1.7.0
survey 4.1-1
survival 3.3-1
survminer 0.4.9
survMisc 0.5.6
svglite 2.1.0
sys 3.4
systemfonts 1.0.4
TeachingDemos 2.12
tensor 1.5
tensorA 0.36.2
terra 1.5-34
testthat 3.1.4
texreg 1.38.6
TH.data 1.1-1
tibble 3.1.7
tidymodels 0.2.0
tidyr 1.2.0
tidyselect 1.1.2
tidyverse 1.3.1
tikzDevice 0.12.3.1
timeDate 3043.102
timeSeries 3062.100
tinytex 0.40
tis 1.39
tmap 3.3-3
tmaptools 3.1-1
tmvnsim 1.0-2
tseries 0.10-51
TTR 0.24.3
tune 0.2.0
tzdb 0.3.0
ucminf 1.1-4
units 0.8-0
urca 1.3-0
utf8 1.2.2
uuid 1.1-0
vcd 1.4-10
vcdExtra 0.8-0
vctrs 0.4.1
vegan 2.6-2
viridis 0.6.2
viridisLite 0.4.0
vroom 1.5.7
waldo 0.4.0
warp 0.2.0
waveslim 1.8.2
wavethresh 4.6.9
webshot 0.5.3
widgetframe 0.3.1
withr 2.5.0
wk 0.6.0
wooldridge 1.4-2
workflows 0.2.6
workflowsets 0.2.1
WRS2 1.1-4
xfun 0.31
xlsx 0.6.5
xlsxjars 0.6.1
XML 3.99-0.10
xml2 1.3.3
xtable 1.8-4
xts 0.12.1
yaml 2.3.5
yardstick 1.0.0
yuima 1.15.3
zeallot 0.1.0
zip 2.2.0
zoo 1.8-10
"

# 解析
lines <- trimws(strsplit(txt, "\n")[[1]])
lines <- lines[nchar(lines) > 0]

pkg <- sub(" .*", "", lines)
ver <- sub(".* ", "", lines)

repo <- "https://packagemanager.posit.co/cran/2022-06-17"

# 安装
for(i in seq_along(pkg)){
  cat("Installing", pkg[i], ver[i], "\n")
  try(remotes::install_version(
      pkg[i],
      version = ver[i],
      repos = repo,
      lib = "/usr/local/lib/R/site-library",
      Ncpus = parallel::detectCores()
  ))
}

# 安装 BIO 系列包
bioc_avail <- BiocManager::available()
is_bioc <- pkg %in% bioc_avail

if (any(is_bioc)) {
  options(repos = BiocManager::repositories())
  for (i in which(is_bioc)) {
    cat("Installing Bioconductor package", pkg[i], ver[i], "\n")
    try(
      BiocManager::install(
        pkg[i],
        lib = "/usr/local/lib/R/site-library",
        ask = FALSE,
        update = FALSE
      )
    )
  }
}

# 检查
cat("\n===== Checking installed packages =====\n")

ip <- installed.packages(lib.loc = "/usr/local/lib/R/site-library")

missing <- c()

for(i in seq_along(pkg)){
  p <- pkg[i]
  v <- ver[i]

  if(!(p %in% rownames(ip))){
    missing <- c(missing, sprintf("%s %s (not installed)", p, v))
  } else {
    installed_v <- ip[p, "Version"]
    if(installed_v != v){
      missing <- c(missing, sprintf("%s %s (installed %s)", p, v, installed_v))
    }
  }
}

if(length(missing) == 0){
  cat("All packages installed correctly\n")
} else {
  cat("Packages missing or wrong version:\n")
  cat(paste(missing, collapse = "\n"), "\n")
}