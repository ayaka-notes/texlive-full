# CPU 核心检测
cores <- parallel::detectCores()
cat("Detected CPU cores:", cores, "\n")
# 包级并行交给 install.packages(Ncpus)，单包内部编译限 -j4，避免并发乘积过载
jobs <- 4
Sys.setenv(MAKEFLAGS = paste0("-j", jobs))
cat("MAKEFLAGS =", Sys.getenv("MAKEFLAGS"), "\n")

# 如果没有 remotes 就安装
if (!requireNamespace("remotes", quietly = TRUE))
  install.packages("remotes", repos="https://packagemanager.posit.co/cran/2026-06-25")


# 安装 BiocManager 包
if (!requireNamespace("BiocManager", quietly = TRUE))
  remotes::install_version(
    "BiocManager",
    version = "1.30.27",
    repos = "https://packagemanager.posit.co/cran/2026-06-25",
    lib = "/usr/local/lib/R/site-library",
    Ncpus = parallel::detectCores(),
    upgrade = "never"
  )


# 把你的包列表直接粘到这里
txt <- "
abind 1.4-8
acepack 1.6.3
ADGofTest 0.3
admisc 0.40
AER 1.2-16
afex 1.5-1
agricolae 1.3-7
alabama 2025.1.0
AlgDesign 1.2.1.2
alr4 1.0.7
animation 2.8
armadillo4r 1.0.0
ash 1.0-15
AsioHeaders 1.30.2-1
askpass 1.2.1
assertthat 0.2.1
audio 0.1-12
backports 1.5.1
base64enc 0.1-6
BayesFactor 0.9.12-4.8
bayesm 3.1-7
bayesplot 1.15.0
bayestestR 0.18.1
BB 2026.1.0
bbmle 1.0.25.1
bdsmatrix 1.3-7
beepr 2.0
Benchmarking 0.33
betareg 3.2-4
BH 1.90.0-1
bib2df 1.1.2.0
bibtex 0.5.2
bigD 0.3.1
bindr 0.1.3
Biobase 2.72.0
BiocGenerics 0.58.1
BiocManager 1.30.27
BiocVersion 3.23.1
bit 4.6.0
bit64 4.8.2
bitops 1.0-9
blavaan 0.5-10
blob 1.3.0
BMA 3.18.21
boot 1.3-32
brio 1.1.5
broom 1.0.13
BSDA 1.2.2
bslib 0.11.0
BWStest 0.2.3
ca 0.71.1
cachem 1.1.0
calculus 1.1.0
callr 3.8.0
car 3.1-5
carData 3.0-6
cards 0.8.0
cardx 0.3.3
caret 7.0-1
cartogram 0.3.0
caTools 1.18.3
CDM 8.3-14
cellranger 1.1.0
changepoint 2.3
checkmate 2.3.4
chromote 0.5.1
chron 2.3-62
CircStats 0.2-7
circular 0.5-2
class 7.3-23
classInt 0.4-11
cli 3.6.6
clipr 0.8.1
clock 0.7.4
cluster 2.1.8.2
cmna 1.0.5
cmprsk 2.2-12
cobs 1.3-9-1
coda 0.19-4.1
codetools 0.2-20
coin 1.4-3
collapse 2.1.7
colorspace 2.1-2
cols4all 0.10
combinat 0.0-8
commonmark 2.0.0
compositions 2.0-9
CompQuadForm 1.4.4
conflicted 1.2.0
contfrac 1.1-12
copula 1.1-7
corpcor 1.6.10
correlation 0.8.8
corrplot 0.95
cowplot 1.2.0
coxme 2.2-22
coxphw 4.0.3
cpm 2.3
cpp11 0.5.5
cpp4r 1.0.0
crayon 1.5.3
crosstalk 1.2.2
crs 0.15-44
crul 1.6.0
cubature 2.1.4-1
curl 7.1.0
cvar 0.6
DAAG 1.25.7
data.table 1.18.4
datawizard 1.3.1
DBI 1.3.0
dbplyr 2.6.0
dcurver 0.9.3
DeclareDesign 1.1.1
deldir 2.0-4
demography 2.0.1
dendextend 1.19.1
DEoptim 2.2-8
DEoptimR 1.2-0
Deriv 4.2.0
desc 1.4.3
DescTools 0.99.60
deSolve 1.42
dfoptim 2023.1.0
diagram 1.6.5
dials 1.4.4
DiceDesign 1.10
dichromat 2.0-0.1
diffobj 0.3.6
digest 0.6.39
distributional 0.8.0
doBy 4.7.1
doParallel 1.0.17
dotCall64 1.2
dplyr 1.2.1
DT 0.34.0
dtplyr 1.3.3
dynlm 0.3-6
e1071 1.7-17
earth 5.3.5
Ecdat 0.4.7
Ecfun 0.4.0
economiccomplexity 2.1.0
ecp 3.1.6
effects 4.2-5
effectsize 1.0.2
ellipse 0.5.0
ellipsis 0.3.3
elliptic 1.5-1
emmeans 2.0.3
energy 1.7-12
enhancer 1.1.1
eRm 1.0-10
errors 0.4.4
estimability 1.5.1
estimatr 1.0.6
evaluate 1.0.5
evgam 1.0.1
Exact 3.3
exactRankTests 0.8-37
expm 1.0-0
fabricatr 1.0.2
factoextra 2.0.0
FactoMineR 2.15
faraway 1.0.9
farver 2.1.2
fastGHQuad 1.0.1
fastICA 1.2-7
fastmap 1.2.0
fastmatch 1.1-8
fBasics 4052.98
fda 6.3.0
fdapace 0.6.0
fdrtool 1.2.18
fds 1.9
fdth 1.5-0
fftwtools 0.9-11
fGarch 4052.93
fields 17.3
filehash 2.4-6
flashClust 1.1-4
flexmix 2.3-20
flexsurv 2.3.2
FNN 1.1.4.1
fontawesome 0.5.3
forcats 1.0.1
foreach 1.5.2
forecast 9.0.2
foreign 0.8-91
formatR 1.14
Formula 1.2-5
fracdiff 1.5-4
frontier 1.1-8
fs 2.1.0
ftsa 6.7
furrr 0.4.0
future 1.70.0
future.apply 1.20.2
gamlss 5.5-0
gamlss.data 6.0-7
gamlss.dist 6.1-1
gamm4 0.2-7
gargle 1.6.1
GauPro 0.2.17
gbm 2.2.3
gbutils 0.5.1
gdata 3.0.1
GDINA 2.9.12
geepack 1.3.13
GeneNet 1.2.17
generics 0.1.4
GenSA 1.1.15
geojsonsf 2.0.5
geometries 0.2.5
geometry 0.5.2
ggcorrplot 0.1.4.1
ggeffects 2.3.2
ggplot2 4.0.3
ggplot2movies 0.0.1
ggpubr 0.6.3
ggrepel 0.9.8
ggridges 0.5.7
ggsci 5.0.0
ggside 0.4.1
ggsignif 0.6.4
ggstatsplot 1.0.0
ggtext 0.1.2
glasso 1.11
glassoFast 1.0.1
gld 2.6.8
glm2 1.2.1
glmnet 5.0
globals 0.19.1
glue 1.8.1
gmodels 2.19.1
gmp 0.7-5.1
gnm 1.1-5
goftest 1.2-3
googledrive 2.1.2
googlesheets4 1.1.2
gower 1.0.2
GPArotation 2026.6-1
gplots 3.3.0
gridBase 0.4-7
gridExtra 2.3.1
gridGraphics 0.5-1
gridSVG 1.7-7
gridtext 0.1.6
grImport 0.9-7
grImport2 0.3-3
gsDesign 3.9.0
gsl 2.1-9
gss 2.2-10
gsubfn 0.7
gt 1.3.0
gtable 0.3.6
gtools 3.9.5
gtsummary 2.5.1
handlr 0.3.1
hardhat 1.4.3
haven 2.5.5
hdrcde 3.5.0
hexbin 1.28.5
highlight 0.5.2
highr 0.12
HMDHFDplus 2.0.8
Hmisc 5.2-6
hms 1.1.4
hrbrthemes 0.9.3
HSAUR2 1.1-21
htmlTable 2.5.0
htmltools 0.5.9
htmlwidgets 1.6.4
httpcode 0.3.0
httpuv 1.6.17
httr 1.4.8
humaniformat 0.6.0
hypergeo 1.2-14
ICS 1.4-2
ICSOutlier 0.4-1
ids 1.0.1
igraph 2.3.2
infer 1.1.0
inline 0.3.21
insight 1.5.1
interp 1.1-6
ipred 0.9-15
IQCC 0.7
irlba 2.3.7
isoband 0.3.0
iterators 1.0.14
itertools 0.1-3
itsmr 1.11
janitor 2.2.1
JointAI 1.1.0
jomo 2.7-6
jpeg 0.1-11
jquerylib 0.1.4
jsonify 1.2.3
jsonlite 2.0.0
juicyjuice 0.1.0
kableExtra 1.4.0
kernlab 0.9-33
KernSmooth 2.23-26
klaR 1.7-4
KMsurv 0.1-6
knitr 1.51
ks 1.15.2
kSamples 1.2-12
labeling 0.4.3
labelled 2.16.0
Lahman 14.0-0
LaplacesDemon 16.1.8
lars 1.3
later 1.4.8
latex2exp 0.9.8
lattice 0.22-9
latticeExtra 0.6-31
lava 1.9.1
lavaan 0.6-21
lazyeval 0.2.3
lbfgs 1.2.1.2
leafem 0.2.5
leafgl 0.2.4
leaflegend 1.2.8
leaflet 2.2.3
leaflet.providers 3.0.0
leafsync 0.1.0
leaps 3.2
LearnBayes 2.15.2
lemon 0.5.2
libcoin 1.0-13
lifecycle 1.0.5
linprog 0.9-6
listenv 1.0.0
litedown 0.9
littler 0.3.23
lm.beta 1.7-3
lme4 2.0-1
lmerTest 3.2-1
lmom 3.3
Lmoments 1.3-2
lmtest 0.9-40
locfit 1.5-9.12
locpol 0.9.0
logger 0.4.2
lomb 2.5.0
longitudinal 1.1.13
loo 2.9.0
lpSolve 5.6.23
lpSolveAPI 5.5.2.0-17.15
lsmeans 2.30-2
lsoda 1.2
ltm 1.2-0
lubridate 1.9.5
lwgeom 0.2-16
magic 1.6-1
magick 2.9.1
magrittr 2.0.5
mapdata 2.3.1
mapproj 1.2.12
maps 3.4.3
maptiles 0.11.0
marginaleffects 0.32.0
markdown 2.0
MASS 7.3-65
mathjaxr 2.0-0
Matrix 1.7-5
MatrixModels 0.5-4
matrixStats 1.5.0
maxLik 1.5-2.2
maxstat 0.7-26
mc2d 0.2.2
mclust 6.1.2
mcmcse 1.5-1
mco 1.17
memoise 2.0.1
MEMSS 0.9-4
meta 8.5-0
metabook 0.2-0
metadat 1.6-0
metafor 5.0-1
mets 1.3.10
mgcv 1.9-4
mice 3.19.0
micEcon 0.6-20
micEconIndex 0.1-8
microbenchmark 1.5.0
mime 0.13
miniUI 0.1.2
minqa 1.2.8
mirai 2.7.1
mirt 1.46.1
misc3d 0.9-2
miscTools 0.6-30
mitml 0.4-5
mitools 2.4
mixopt 0.1.3
mlbench 2.1-8
mlmRev 1.0-9
mnormt 2.1.2
modeldata 1.5.1
modelenv 0.2.0
ModelMetrics 1.2.2.2
modelr 0.1.11
modeltools 0.2-24
moments 0.14.1
mondate 1.0
msm 1.8.2
mstate 0.3.3
muhaz 1.2.6.4
multcomp 1.4-30
multcompView 0.1-11
multicool 1.0.1
multitaper 1.0-17
munsell 0.5.1
MVN 6.3
mvtnorm 1.4-1
nanonext 1.9.1
nanotime 0.3.15
network 1.20.0
nlme 3.1-169
nloptr 2.2.1
nls2 0.3-4
nlstools 2.1-0
NMF 0.28
nnet 7.3-20
nonlinearTseries 0.3.2
nonnest2 0.5-9
nortest 1.0-4
np 0.70-3
NPCDTools 1.1.0
numDeriv 2016.8-1.1
nycflights13 1.0.2
openair 3.1.0
OpenMx 2.22.11
openssl 2.4.2
openxlsx 4.2.8.1
optextras 2019-12.4
optimx 2025-4.9
ordinal 2025.12-29
otel 0.2.0
oz 1.0-22
packcircles 0.3.7
paletteer 1.7.0
pan 1.9
parallelly 1.47.0
parameters 0.29.1
parsnip 1.6.0
party 1.3-20
patchwork 1.3.2
pbapply 1.7-4
pbivnorm 0.6.0
pbkrtest 0.5.5
PBSmapping 2.74.1
pcaMethods 2.4.0
pcaPP 2.0-5
pdfCluster 1.0-4
pec 2025.06.24
performance 0.17.0
PerformanceAnalytics 2.1.0
permute 0.9-10
pillar 1.11.1
pixmap 0.4-14
pkgbuild 1.4.8
pkgconfig 2.0.3
pkgKitten 0.2.4
pkgload 1.5.3
plm 2.6-7
plot3D 1.4.2
plotly 4.12.0
plotmo 3.7.0
plotrix 3.8-14
pls 2.9-0
plyr 1.8.9
PMCMRplus 1.9.12
png 0.1-9
polspline 1.1.25
polyclip 1.10-7
polycor 0.8-2
polynom 1.4-1
popbio 2.8
PortfolioAnalytics 2.1.2
posterior 1.7.0
pracma 2.4.6
praise 1.0.0
prettyunits 1.2.0
prismatic 1.1.2
pROC 1.19.0.1
processx 3.9.0
prodlim 2026.03.11
progress 1.2.3
progressr 0.19.0
promises 1.5.0
proto 1.0.0
proxy 0.4-29
ps 1.9.3
pseudo 1.4.3
pso 1.0.4
pspline 1.0-21
psych 2.6.5
Publish 2025.07.24
purrr 1.2.2
PwrGSD 2.3.8
pyramid 1.5
qcc 2.7
qicharts2 0.8.1
qs2 0.2.2
quadprog 1.5-8
quantmod 0.4.28
quantreg 6.1
questionr 0.8.2
QuickJSR 1.10.0
qvcalc 1.0.4
R.cache 0.17.0
R.methodsS3 1.8.2
R.oo 1.27.1
R.utils 2.13.0
r2rtf 1.3.1
R6 2.6.1
ragg 1.5.2
rainbow 3.8
randomForest 4.7-1.2
randomizeR 3.0.2
randomizr 1.0.1
randtests 1.0.2
ranger 0.18.0
rapidjsonr 1.2.1
rappdirs 0.3.4
raster 3.6-32
rbibutils 2.4.1
RColorBrewer 1.1-3
Rcpp 1.1.1-1.1
RcppArmadillo 15.4.0-1
RcppCCTZ 0.2.14
RcppDate 0.0.6
RcppEigen 0.3.4.0.2
RcppParallel 5.1.11-2
RcppProgress 0.4.2
RCurl 1.98-1.19
rddtools 2.0.2
Rdpack 2.6.6
rdrobust 4.0.0
reactable 0.4.5
reactR 0.6.1
readr 2.2.0
readstata13 0.11.0
readxl 1.5.0
recipes 1.3.3
RefManageR 1.4.0
reformulas 0.4.4
registry 0.5-1
relaimpo 2.2-7
relimp 1.0-5
rematch 2.0.0
rematch2 2.1.2
reporttools 1.1.4
reprex 2.1.1
reshape 0.8.10
reshape2 1.4.5
rex 1.2.2
RGraphics 3.0-2
RHRV 5.0.0
rio 1.3.0
riskRegression 2026.03.11
rjags 4-17
rJava 1.0-18
rjson 0.2.23
rlang 1.2.0
Rlinsolve 0.3.3
rmarkdown 2.31
Rmpfr 1.1-2
rms 8.1-1
rngtools 1.5.2
robustbase 0.99-7
ROI 1.0-2
ROI.plugin.quadprog 1.0-1
ROI.plugin.symphony 1.0-0
ROOPSD 0.3.9
rootSolve 1.8.2.4
rpart 4.1.27
rpf 1.0.15
rprojroot 2.1.1
rrcov 1.7-7
rsample 1.3.2
Rsolnp 2.0.1
RSQLite 3.53.2
rstan 2.32.7
rstantools 2.6.0
rstatix 0.7.3
rstpm2 1.7.1
rstudioapi 0.19.0
Rsymphony 0.1-33
rvest 1.0.5
rworldmap 1.3-8
Ryacas 1.1.6
s2 1.1.11
S7 0.2.2
sampleSelection 1.2-14
sandwich 3.1-1
sass 0.4.10
scales 1.4.0
scatterplot3d 0.3-45
sde 2.0.21
segmented 2.2-1
selectr 0.6-0
servr 0.33
sessioninfo 1.2.4
setRNG 2024.2-1
sf 1.1-1
sfcr 0.2.3
sfd 0.1.0
sfheaders 0.4.5
shape 1.4.6.1
shiny 1.14.0
shinydashboard 0.7.3
SimDesign 2.25
SixSigma 0.11.1
sjlabelled 1.2.0
sjmisc 2.8.11
sjPlot 2.9.0
sjstats 0.19.1
slam 0.1-55
slider 0.3.3
sm 2.2-6.0
snakecase 0.11.1
soiltexture 1.5.3
sommer 4.4.5
sourcetools 0.1.7-2
sp 2.2-1
spacesXYZ 1.6-0
spam 2.11-4
SparseM 1.84-2
sparsevctrs 0.3.6
spatial 7.3-18
spatialreg 1.4-3
spatstat 3.6-1
spatstat.data 3.1-9
spatstat.explore 3.8-1
spatstat.geom 3.8-1
spatstat.linnet 3.5-1
spatstat.model 3.7-1
spatstat.random 3.5-0
spatstat.sparse 3.2-0
spatstat.univar 3.2-0
spatstat.utils 3.2-3
spc 0.7.2
spData 2.3.5
spdep 1.4-2
sphet 2.1-1
splines2 0.5.4
splitfngr 0.1.2
splm 1.6-5
sqldf 0.4-12
SQUAREM 2026.1
stabledist 0.7-2
StanHeaders 2.32.10
stargazer 5.2.3
stars 0.7-2
statmod 1.5.2
statnet.common 4.13.0
statsExpressions 2.0.0
stringdist 0.9.17
stringfish 0.19.0
stringi 1.8.7
stringr 1.6.0
strucchange 1.5-4
styler 1.11.0
SuppDists 1.1-9.9
survey 4.5
survival 3.8-6
survminer 0.5.2
svglite 2.2.2
sys 3.4.3
systemfit 1.1-30
systemfonts 1.3.2
table1 1.5.1
tailor 0.1.0
TeachingDemos 2.13
tensor 1.5.1
tensorA 0.36.2.1
terra 1.9-34
testthat 3.3.2
texreg 1.39.5
textshaping 1.0.5
TH.data 1.1-5
tibble 3.3.1
tidymodels 1.5.0
tidyr 1.3.2
tidyselect 1.2.1
tidyverse 2.0.0
tikzDevice 0.12.6
timechange 0.4.0
timeDate 4052.112
timereg 2.0.7
timeSeries 4052.112
tinytex 0.60
tis 1.39
tmap 4.4
tmaptools 3.3
tmvnsim 1.0-2
triebeard 0.4.1
truncnorm 1.0-9
tseries 0.10-61
TTR 0.24.4
tune 2.1.0
tzdb 0.5.0
ucminf 1.2.3
units 1.0-1
urca 1.3-4
urltools 1.7.3.1
utf8 1.2.6
uuid 1.2-2
V8 8.2.0
vars 1.6-1
vcd 1.4-13
vcdExtra 0.9.6
vctrs 0.7.3
vegan 2.7-5
VGAM 1.1-14
viridis 0.6.5
viridisLite 0.4.3
vroom 1.7.1
waldo 0.6.2
warp 0.2.3
waveslim 1.8.5
wavethresh 4.7.3
webshot2 0.1.2
websocket 1.4.4
withr 3.0.3
wk 0.9.5
wooldridge 1.4-4
workflows 1.3.0
workflowsets 1.1.1
writexl 1.5.4
WRS2 1.1-7
xfun 0.59
xlsx 0.6.5
xlsxjars 0.9.0
XML 3.99-0.23
xml2 1.6.0
xtable 1.8-8
xts 0.14.2
yaml 2.3.12
yardstick 1.4.0
yuima 1.15.34
yyjsonr 0.1.22
zeallot 0.2.0
zip 3.0.0
zoo 1.8-15
"

# 解析
lines <- trimws(strsplit(txt, "\n")[[1]])
lines <- lines[nchar(lines) > 0]

pkg <- sub(" .*", "", lines)
ver <- sub(".* ", "", lines)

repo <- "https://packagemanager.posit.co/cran/2026-06-25"
bioc_repos <- BiocManager::repositories()
bioc_avail <- rownames(available.packages(repos = bioc_repos[names(bioc_repos) != "CRAN"]))
is_bioc <- pkg %in% bioc_avail

# Bioc 包不在 CRAN 仓库里，必须先装：清单里的 NMF 依赖 Biobase，
# 若 CRAN 循环先跑，NMF 安装时 Biobase 还不存在。
# 安装 BIO 系列包
if (any(is_bioc)) {
  # Bioc 依赖里的 CRAN 包（如 pcaMethods 依赖 MASS）也必须走锁版本快照：
  # 最新 CRAN 的版本可能要求更新的 R，导致 "not available" 安装失败
  bioc_r <- BiocManager::repositories()
  bioc_r["CRAN"] <- repo
  options(repos = bioc_r)
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

# 剩下的批量并行安装：dated 快照天然锁版本。先并行把源码包预下载成
# 本地仓库（消除逐包串行下载延迟），大包排到队首缩短收尾长尾；然后
# install.packages() 按依赖图生成 Makefile 拓扑排序并行编译。
options(timeout = 300)
todo <- pkg[!is_bioc]
ap <- available.packages(repos = repo)
cache <- "/tmp/pkg-cache/src/contrib"
dir.create(cache, recursive = TRUE, showWarnings = FALSE)
fetch <- todo[todo %in% rownames(ap)]
urls <- paste0(ap[fetch, "Repository"], "/", fetch, "_", ap[fetch, "Version"], ".tar.gz")
dest <- file.path(cache, basename(urls))
invisible(parallel::mcmapply(function(u, d) {
  for (k in 1:3) {
    ok <- tryCatch(download.file(u, d, quiet = TRUE) == 0, error = function(e) FALSE)
    if (ok && file.exists(d)) break
    unlink(d)
  }
}, urls, dest, mc.cores = cores, mc.preschedule = FALSE))
tools::write_PACKAGES(cache)
heavy <- intersect(c("igraph", "stringi", "rstan", "StanHeaders", "s2", "sf", "terra", "Matrix", "V8"), todo)
install.packages(
  c(heavy, setdiff(todo, heavy)),
  repos = c("file:///tmp/pkg-cache", repo),
  lib = "/usr/local/lib/R/site-library",
  Ncpus = parallel::detectCores()
)

# 上面批量装失败的包补装一遍（串行，安全）。个别 pin 与快照版本有微小
# 出入的直接用快照版本，不再逐包回装。
ip0 <- installed.packages()
miss <- setdiff(pkg[!is_bioc], rownames(ip0))
if (length(miss) > 0) {
  cat("Retrying failed packages:", paste(miss, collapse = " "), "\n")
  install.packages(
    miss,
    repos = c("file:///tmp/pkg-cache", repo),
    lib = "/usr/local/lib/R/site-library",
    Ncpus = parallel::detectCores()
  )
}

# 与清单版本不一致或仍缺失的，串行精确回装（冻结日快照下只剩 2~3 个）。
# 直接按 URL 取指定版本 tarball、repos=NULL 本地安装：不做任何依赖解析，
# 杜绝 remotes 之类把缺失依赖从 cloud CRAN 装成最新版（R 版本不兼容）的泄漏。
# 按字母序单轮跑会踩依赖顺序（car 依赖 maptools/rio，但 m/r 排在 c 之后），
# 多跑几轮直到没有新进展；链最深 3 层，5 轮上限绰绰有余。
for (round in 1:5) {
ip1 <- installed.packages(noCache = TRUE)
progress <- FALSE
for (i in seq_along(pkg)) {
  if (is_bioc[i]) next
  if (pkg[i] %in% rownames(ip1) && ip1[pkg[i], "Version"] == ver[i]) next
  fname <- paste0(pkg[i], "_", ver[i], ".tar.gz")
  urls <- c(
    paste0(repo, "/src/contrib/", fname),
    paste0(repo, "/src/contrib/Archive/", pkg[i], "/", fname),
    paste0("https://cloud.r-project.org/src/contrib/", fname),
    paste0("https://cloud.r-project.org/src/contrib/Archive/", pkg[i], "/", fname)
  )
  dest <- file.path(tempdir(), fname)
  got <- FALSE
  for (u in urls) {
    got <- tryCatch(download.file(u, dest, quiet = TRUE) == 0, error = function(e) FALSE)
    if (got && file.exists(dest)) break
    unlink(dest)
  }
  if (!got) { cat("Pinning", pkg[i], ver[i], ": tarball not found\n"); next }
  cat("Pinning", pkg[i], ver[i], "from", u, "\n")
  try(install.packages(dest, repos = NULL, type = "source",
                       lib = "/usr/local/lib/R/site-library"))
  unlink(dest)
  progress <- TRUE
}
if (!progress) break
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
