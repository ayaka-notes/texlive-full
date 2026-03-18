# CPU 核心检测
cores <- parallel::detectCores()
cat("Detected CPU cores:", cores, "\n")
# 使用两倍并行
jobs <- cores * 2
Sys.setenv(MAKEFLAGS = paste0("-j", jobs))
cat("MAKEFLAGS =", Sys.getenv("MAKEFLAGS"), "\n")

# 如果没有 remotes 就安装
if (!requireNamespace("remotes", quietly = TRUE))
  install.packages("remotes", repos="https://packagemanager.posit.co/cran/2024-03-15")


# 安装 BiocManager 包
if (!requireNamespace("BiocManager", quietly = TRUE))
  remotes::install_version(
    "BiocManager",
    version = "1.30.22",
    repos = "https://packagemanager.posit.co/cran/2024-03-15",
    lib = "/usr/local/lib/R/site-library",
    Ncpus = parallel::detectCores(),
    upgrade = "never"
  )


# 把你的包列表直接粘到这里
txt <- "
abind 1.4-5
acepack 1.4.2
ADGofTest 0.3
admisc 0.35
AER 1.2-12
afex 1.3-1
agricolae 1.3-7
AlgDesign 1.2.1
alr4 1.0.6
animation 2.7
ash 1.0-15
askpass 1.2.0
assertthat 0.2.1
backports 1.4.1
base64enc 0.1-3
BayesFactor 0.9.12-4.7
bayesm 3.1-6
bayesplot 1.11.1
bayestestR 0.13.2
BB 2019.10-1
bbmle 1.0.25.1
bdsmatrix 1.3-7
Benchmarking 0.32
betareg 3.1-4
BH 1.84.0-0
bib2df 1.1.1
bibtex 0.5.1
bigD 0.2.0
bindr 0.1.1
Biobase 2.62.0
BiocGenerics 0.48.1
BiocManager 1.30.22
BiocVersion 3.18.1
bit 4.0.5
bit64 4.0.5
bitops 1.0-7
blavaan 0.5-3
blob 1.2.4
BMA 3.18.17
boot 1.3-30
brio 1.1.4
broom 1.0.5
broom.helpers 1.14.0
bslib 0.6.1
BWStest 0.2.3
ca 0.71.1
cachem 1.0.8
calculus 1.0.1
callr 3.7.5
car 3.1-2
carData 3.0-5
caret 6.0-94
cartogram 0.3.0
caTools 1.18.2
CDM 8.2-6
cellranger 1.1.0
changepoint 2.2.4
checkmate 2.3.1
chron 2.3-61
CircStats 0.2-6
circular 0.5-0
class 7.3-22
classInt 0.4-10
cli 3.6.2
clipr 0.8.0
clock 0.7.0
cluster 2.1.6
cmna 1.0.5
cmprsk 2.2-11
cobs 1.3-8
coda 0.19-4.1
codetools 0.2-19
coin 1.4-3
collapse 2.0.10
colorspace 2.1-0
combinat 0.0-8
commonmark 1.9.1
compositions 2.0-8
CompQuadForm 1.4.3
conflicted 1.2.0
contfrac 1.1-12
copula 1.1-3
corpcor 1.6.10
correlation 0.8.4
corrplot 0.92
cowplot 1.1.3
coxme 2.2-20
coxphw 4.0.3
cpm 2.3
cpp11 0.4.7
crayon 1.5.2
crosstalk 1.2.1
crul 1.4.0
cubature 2.1.0
curl 5.2.1
cvar 0.5
DAAG 1.25.4
data.table 1.15.2
datawizard 0.9.1
DBI 1.2.2
dbplyr 2.4.0
dcurver 0.9.2
DeclareDesign 1.0.8
deldir 2.0-4
demography 2.0
dendextend 1.17.1
DEoptim 2.2-8
DEoptimR 1.1-3
Deriv 4.1.3
desc 1.4.3
deSolve 1.40
dfoptim 2023.1.0
diagram 1.6.5
dials 1.2.1
DiceDesign 1.10
dichromat 2.0-0.1
diffobj 0.3.5
digest 0.6.35
distributional 0.4.0
doBy 4.6.20
doParallel 1.0.17
dotCall64 1.1-1
dplyr 1.1.4
DT 0.32
dtplyr 1.3.1
dynlm 0.3-6
e1071 1.7-14
earth 5.3.3
Ecdat 0.4-2
Ecfun 0.3-2
economiccomplexity 1.5.0
ecp 3.1.5
effects 4.2-2
effectsize 0.8.6
ellipse 0.5.0
ellipsis 0.3.2
elliptic 1.4-0
emmeans 1.10.0
energy 1.7-11
eRm 1.0-6
estimability 1.5
estimatr 1.0.2
evaluate 0.23
evgam 1.0.0
exactRankTests 0.8-35
expm 0.999-9
extrafont 0.19
extrafontdb 1.0
fabricatr 1.0.2
factoextra 1.0.7
FactoMineR 2.10
fansi 1.0.6
faraway 1.0.8
farver 2.1.1
fastGHQuad 1.0.1
fastICA 1.2-4
fastmap 1.1.1
fastmatch 1.1-4
fBasics 4032.96
fda 6.1.8
fdapace 0.5.9
fdrtool 1.2.17
fds 1.8
fdth 1.3-0
fftwtools 0.9-11
fGarch 4032.91
fields 15.2
filehash 2.4-5
flashClust 1.01-2
flexmix 2.3-19
flexsurv 2.2.2
FNN 1.1.4
fontawesome 0.5.2
fontBitstreamVera 0.1.1
fontLiberation 0.1.0
fontquiver 0.2.1
forcats 1.0.0
foreach 1.5.2
forecast 8.22.0
foreign 0.8-86
formatR 1.14
Formula 1.2-5
fracdiff 1.5-3
frontier 1.1-8
fs 1.6.3
ftsa 6.4
furrr 0.3.1
future 1.33.1
future.apply 1.11.1
gamlss 5.4-20
gamlss.data 6.0-6
gamlss.dist 6.1-1
gamm4 0.2-6
gargle 1.5.2
gbutils 0.5
gdata 3.0.0
gdtools 0.3.7
geepack 1.3.10
GeneNet 1.2.16
generics 0.1.3
GenSA 1.1.14
geojsonsf 2.0.3
geometries 0.2.4
geometry 0.4.7
gfonts 0.2.0
ggcorrplot 0.1.4.1
ggeffects 1.5.0
ggplot2 3.5.0
ggplot2movies 0.0.1
ggpubr 0.6.0
ggrepel 0.9.5
ggridges 0.5.6
ggsci 3.0.1
ggside 0.3.1
ggsignif 0.6.4
ggstatsplot 0.12.2
ggtext 0.1.2
glasso 1.11
glassoFast 1.0.1
glm2 1.2.1
glmnet 4.1-8
globals 0.16.3
glue 1.7.0
gmodels 2.19.1
gmp 0.7-4
gnm 1.1-5
goftest 1.2-3
googledrive 2.1.1
googlesheets4 1.1.1
gower 1.0.1
GPArotation 2024.3-1
GPfit 1.0-8
gplots 3.1.3.1
gridBase 0.4-7
gridExtra 2.3
gridGraphics 0.5-1
gridSVG 1.7-5
gridtext 0.1.5
grImport 0.9-7
grImport2 0.3-1
gsDesign 3.6.1
gsl 2.1-8
gss 2.2-7
gsubfn 0.7
gt 0.10.1
gtable 0.3.4
gtools 3.9.5
gtsummary 1.7.2
handlr 0.3.0
hardhat 1.3.1
haven 2.5.4
hdrcde 3.4
here 1.0.1
hexbin 1.28.3
highlight 0.5.1
highr 0.10
HMDHFDplus 2.0.3
Hmisc 5.1-2
hms 1.1.3
hrbrthemes 0.8.7
HSAUR2 1.1-20
htmlTable 2.4.2
htmltools 0.5.7
htmlwidgets 1.6.4
httpcode 0.3.0
httpuv 1.6.14
httr 1.4.7
humaniformat 0.6.0
hypergeo 1.2-13
ICS 1.4-1
ICSOutlier 0.4-0
ids 1.0.1
igraph 2.0.3
infer 1.0.6
inline 0.3.19
insight 0.19.8
interp 1.1-6
ipred 0.9-14
IQCC 0.7
irlba 2.3.5.1
isoband 0.2.7
iterators 1.0.14
itertools 0.1-3
itsmr 1.10
janitor 2.2.0
JointAI 1.0.5
jomo 2.7-6
jpeg 0.1-10
jquerylib 0.1.4
jsonify 1.2.2
jsonlite 1.8.8
juicyjuice 0.1.0
kableExtra 1.4.0
kernlab 0.9-32
KernSmooth 2.23-22
klaR 1.7-3
km.ci 0.5-6
KMsurv 0.1-5
knitr 1.45
ks 1.14.2
kSamples 1.2-10
labeling 0.4.3
labelled 2.12.0
Lahman 11.0-0
LaplacesDemon 16.1.6
lars 1.3
later 1.3.2
latex2exp 0.9.6
lattice 0.22-5
latticeExtra 0.6-30
lava 1.8.0
lavaan 0.6-17
lazyeval 0.2.2
leafem 0.2.3
leaflet 2.2.1
leaflet.providers 2.0.0
leafsync 0.1.0
leaps 3.1
LearnBayes 2.15.1
lemon 0.4.9
lhs 1.1.6
libcoin 1.0-10
lifecycle 1.0.4
linprog 0.9-4
listenv 0.9.1
littler 0.3.19
lm.beta 1.7-2
lme4 1.1-35.1
lmerTest 3.1-3
Lmoments 1.3-1
lmtest 0.9-40
locfit 1.5-9.9
locpol 0.8.0
lomb 2.2.0
longitudinal 1.1.13
loo 2.7.0
lpSolve 5.6.20
lpSolveAPI 5.5.2.0-17.11
lsmeans 2.30-0
ltm 1.2-0
lubridate 1.9.3
lwgeom 0.2-14
magic 1.6-1
magick 2.8.3
magrittr 2.0.3
mapdata 2.3.1
mapproj 1.2.11
maps 3.4.2
markdown 1.12
MASS 7.3-60.0.1
mathjaxr 1.6-0
Matrix 1.6-5
MatrixModels 0.5-3
matrixStats 1.2.0
maxLik 1.5-2
maxstat 0.7-25
mc2d 0.2.0
mclust 6.1
mcmcse 1.5-0
memoise 2.0.1
MEMSS 0.9-3
meta 7.0-0
metadat 1.2-0
metafor 4.4-0
mets 1.3.4
mgcv 1.9-1
mice 3.16.0
micEcon 0.6-18
micEconIndex 0.1-8
microbenchmark 1.4.10
mime 0.12
miniUI 0.1.1.1
minqa 1.2.6
mirt 1.41
misc3d 0.9-1
miscTools 0.6-28
mistat 2.0.4
mitml 0.4-5
mitools 2.4
mlbench 2.1-3.1
mlmRev 1.0-8
mnormt 2.1.1
modeldata 1.3.0
modelenv 0.1.1
ModelMetrics 1.2.2.2
modelr 0.1.11
modeltools 0.2-23
moments 0.14.1
mondate 1.0
msm 1.7.1
mstate 0.3.2
muhaz 1.2.6.4
multcomp 1.4-25
multcompView 0.1-10
multicool 1.0.1
munsell 0.5.0
MVN 5.9
mvtnorm 1.2-4
nanotime 0.3.7
network 1.18.2
nlme 3.1-164
nloptr 2.0.3
nls2 0.3-3
nlstools 2.1-0
NMF 0.27
nnet 7.3-19
nonlinearTseries 0.2.12
nonnest2 0.5-6
nortest 1.0-4
np 0.60-17
numDeriv 2016.8-1.1
nycflights13 1.0.2
openair 2.18-2
OpenMx 2.21.11
openssl 2.1.1
openxlsx 4.2.5.2
optextras 2019-12.4
optimx 2023-10.21
ordinal 2023.12-4
oz 1.0-22
packcircles 0.3.6
paletteer 1.6.0
pan 1.9
parallelly 1.37.1
parameters 0.21.5
parsnip 1.2.0
party 1.3-14
patchwork 1.2.0
pbapply 1.7-2
pbivnorm 0.6.0
pbkrtest 0.5.2
PBSmapping 2.73.4
pcaMethods 1.94.0
pcaPP 2.0-4
pdfCluster 1.0-4
pec 2023.04.12
performance 0.10.9
PerformanceAnalytics 2.0.4
permute 0.9-7
pillar 1.9.0
pixmap 0.4-12
pkgbuild 1.4.3
pkgconfig 2.0.3
pkgKitten 0.2.3
pkgload 1.3.4
plm 2.6-3
plogr 0.2.0
plot3D 1.4.1
plotly 4.10.4
plotmo 3.6.3
plotrix 3.8-4
pls 2.8-3
plyr 1.8.9
PMCMRplus 1.9.10
png 0.1-8
polspline 1.1.24
polyclip 1.10-6
polycor 0.8-1
polynom 1.4-1
popbio 2.7
PortfolioAnalytics 1.1.0
posterior 1.5.0
pracma 2.4.4
praise 1.0.0
prettyunits 1.2.0
prismatic 1.1.1
pROC 1.18.5
processx 3.8.3
prodlim 2023.08.28
progress 1.2.3
progressr 0.14.0
promises 1.2.1
proto 1.0.0
proxy 0.4-27
ps 1.7.6
pseudo 1.4.3
pso 1.0.4
pspline 1.0-19
psych 2.4.1
Publish 2023.01.17
purrr 1.0.2
PwrGSD 2.3.6
pyramid 1.5
qcc 2.7
qicharts2 0.7.4
quadprog 1.5-8
quantmod 0.4.26
quantreg 5.97
questionr 0.7.8
QuickJSR 1.1.3
qvcalc 1.0.3
R.cache 0.16.0
R.methodsS3 1.8.2
R.oo 1.26.0
R.utils 2.12.3
r2rtf 1.1.1
R6 2.5.1
ragg 1.3.0
rainbow 3.8
randomForest 4.7-1.1
randomizeR 3.0.2
randomizr 1.0.0
randtests 1.0.1
ranger 0.16.0
rapidjsonr 1.2.0
rappdirs 0.3.3
raster 3.6-26
rbibutils 2.2.16
RColorBrewer 1.1-3
Rcpp 1.0.12
RcppArmadillo 0.12.8.1.0
RcppCCTZ 0.2.12
RcppDate 0.0.3
RcppEigen 0.3.4.0.0
RcppParallel 5.1.7
RcppProgress 0.4.2
RCurl 1.98-1.14
rdd 0.57
rddtools 1.6.0
Rdpack 2.6
rdrobust 2.2
reactable 0.4.4
reactR 0.5.0
readr 2.1.5
readstata13 0.10.1
readxl 1.4.3
recipes 1.0.10
RefManageR 1.4.0
registry 0.5-1
relaimpo 2.2-7
relimp 1.0-5
rematch 2.0.0
rematch2 2.1.2
reporttools 1.1.3
reprex 2.1.0
reshape 0.8.9
reshape2 1.4.4
rex 1.2.1
RGraphics 3.0-2
RHRV 4.2.7
rio 1.0.1
riskRegression 2023.12.21
rjags 4-15
rJava 1.0-11
rjson 0.2.21
rlang 1.1.3
Rlinsolve 0.3.2
rmarkdown 2.26
Rmpfr 0.9-5
rms 6.8-0
rngtools 1.5.2
robustbase 0.99-2
ROI 1.0-1
ROI.plugin.quadprog 1.0-1
ROOPSD 0.3.9
rootSolve 1.8.2.4
rpart 4.1.23
rpf 1.0.14
rprojroot 2.0.4
rrcov 1.7-5
rsample 1.2.0
RSQLite 2.3.5
rstan 2.32.6
rstantools 2.4.0
rstatix 0.7.2
rstpm2 1.6.3
rstudioapi 0.15.0
Rttf2pt1 1.3.12
rvest 1.0.4
rworldmap 1.3-8
Ryacas 1.1.5
s2 1.1.6
sampleSelection 1.2-12
sandwich 3.1-0
sass 0.4.8
scales 1.3.0
scatterplot3d 0.3-44
sde 2.0.18
selectr 0.4-2
setRNG 2024.2-1
sf 1.0-15
sfcr 0.2.1
sfheaders 0.4.4
shape 1.4.6.1
shiny 1.8.0
SixSigma 0.11.1
sjlabelled 1.2.0
sjmisc 2.8.9
sjPlot 2.8.15
sjstats 0.18.2
slam 0.1-50
slider 0.3.1
sm 2.2-6.0
snakecase 0.11.1
soiltexture 1.5.3
sommer 4.3.3
sourcetools 0.1.7-1
sp 2.1-3
spam 2.10-0
SparseM 1.81
spatial 7.3-17
spatialreg 1.3-2
spatstat 3.0-7
spatstat.data 3.0-4
spatstat.explore 3.2-6
spatstat.geom 3.2-9
spatstat.linnet 3.1-4
spatstat.model 3.2-10
spatstat.random 3.2-3
spatstat.sparse 3.0-3
spatstat.utils 3.0-4
spc 0.6.7
spData 2.3.0
spdep 1.3-3
sphet 2.0
splm 1.6-5
sqldf 0.4-11
SQUAREM 2021.1
stabledist 0.7-1
StanHeaders 2.32.6
stargazer 5.2.3
stars 0.6-4
statmod 1.5.0
statnet.common 4.9.0
statsExpressions 1.5.3
stringi 1.8.3
stringr 1.5.1
strucchange 1.5-3
styler 1.10.2
SuppDists 1.1-9.7
survey 4.4-1
survival 3.5-8
survminer 0.4.9
survMisc 0.5.6
svglite 2.1.3
sys 3.4.2
systemfit 1.1-30
systemfonts 1.0.6
table1 1.4.3
TeachingDemos 2.13
tensor 1.5
tensorA 0.36.2.1
terra 1.7-71
testthat 3.2.1
texreg 1.39.3
textshaping 0.3.7
TH.data 1.1-2
tibble 3.2.1
tidymodels 1.1.1
tidyr 1.3.1
tidyselect 1.2.1
tidyverse 2.0.0
tikzDevice 0.12.6
timechange 0.3.0
timeDate 4032.109
timereg 2.0.5
timeSeries 4032.109
tinytex 0.49
tis 1.39
tmaptools 3.1-1
tmvnsim 1.0-2
triebeard 0.4.1
tseries 0.10-55
TTR 0.24.4
tune 1.1.2
tzdb 0.4.0
ucminf 1.2.1
units 0.8-5
urca 1.3-3
urltools 1.7.3
utf8 1.2.4
uuid 1.2-0
V8 4.4.2
vars 1.6-0
vcd 1.4-12
vcdExtra 0.8-5
vctrs 0.6.5
vegan 2.6-4
VGAM 1.1-10
viridis 0.6.5
viridisLite 0.4.2
vroom 1.6.5
waldo 0.5.2
warp 0.2.1
waveslim 1.8.4
wavethresh 4.7.2
widgetframe 0.3.1
withr 3.0.0
wk 0.9.1
wooldridge 1.4-3
workflows 1.1.4
workflowsets 1.0.1
writexl 1.5.0
WRS2 1.1-6
xfun 0.42
xlsx 0.6.5
xlsxjars 0.6.1
XML 3.99-0.16.1
xml2 1.3.6
xtable 1.8-4
xts 0.13.2
yaml 2.3.8
yardstick 1.3.0
yuima 1.15.27
zeallot 0.1.0
zip 2.3.1
zoo 1.8-12
"

# 解析
lines <- trimws(strsplit(txt, "\n")[[1]])
lines <- lines[nchar(lines) > 0]

pkg <- sub(" .*", "", lines)
ver <- sub(".* ", "", lines)

repo <- "https://packagemanager.posit.co/cran/2024-03-15"
bioc_avail <- BiocManager::available()
is_bioc <- pkg %in% bioc_avail

# 剩下的再源码安装
for(i in seq_along(pkg)){
  # 如果是 Bioconductor 包，跳过
  if(is_bioc[i]) next
  cat("Installing", pkg[i], ver[i], "\n")
  try(remotes::install_version(
    pkg[i],
    version = ver[i],
    repos = repo,
    lib = "/usr/local/lib/R/site-library",
    Ncpus = parallel::detectCores(),
    upgrade = "never"
  ))
}

# 安装 BIO 系列包
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

ip <- installed.packages()

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
