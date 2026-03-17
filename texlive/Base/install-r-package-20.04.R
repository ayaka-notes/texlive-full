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
AER 1.2-9
agricolae 1.3-3
AlgDesign 1.2.0
alr4 1.0.6
animation 2.6
askpass 1.1
assertthat 0.2.1
backports 1.1.8
base64enc 0.1-3
bayesplot 1.7.2
BB 2019.10-1
bdsmatrix 1.3-4
betareg 3.1-3
BH 1.72.0-3
bibtex 0.4.2.2
bindr 0.1.1
Biobase 2.46.0
BiocGenerics 0.32.0
BiocManager 1.30.10
BiocVersion 3.10.1
bit 1.1-15.2
bit64 0.9-7.1
bitops 1.0-6
blob 1.2.1
BMA 3.18.12
boot 1.3-25
broom 0.7.0
ca 0.71.1
callr 3.4.3
car 3.0-8
carData 3.0-4
caret 6.0-86
caTools 1.18.0
cellranger 1.1.0
changepoint 2.2.2
checkmate 2.0.0
chron 2.3-55
CircStats 0.2-6
circular 0.4-93
class 7.3-17
classInt 0.4-3
cli 2.0.2
clipr 0.7.0
cluster 2.1.0
coda 0.19-3
codetools 0.2-16
coin 1.3-1
colorspace 1.4-1
combinat 0.0-8
commonmark 1.7
conquer 1.0.1
corpcor 1.6.9
coxme 2.2-16
cpm 2.2
crayon 1.3.4
crosstalk 1.1.0.1
cubature 2.0.4.1
curl 4.3
DAAG 1.24
data.table 1.12.8
DBI 1.1.0
dbplyr 1.4.4
deldir 0.1-28
DEoptim 2.2-5
DEoptimR 1.0-8
Deriv 4.0
desc 1.2.0
dfoptim 2018.2-1
diagram 1.6.4
dichromat 2.0-0
digest 0.6.25
doBy 4.6.7
doParallel 1.0.15
dotCall64 1.0-0
dplyr 1.0.0
dtplyr 1.0.1
dynlm 0.3-6
e1071 1.7-3
earth 5.1.2
economiccomplexity 1.0
effects 4.1-4
ellipsis 0.3.1
emmeans 1.4.8
estimability 1.3
evaluate 0.14
expm 0.999-5
fansi 0.4.1
farver 2.0.3
fastICA 1.2-2
fastmap 1.0.1
fastmatch 1.1-0
fBasics 3042.89.1
fda 5.1.5
fdrtool 1.2.15
fdth 1.2-5
fGarch 3042.83.2
filehash 2.4-2
flexmix 2.3-15
forcats 0.5.0
foreach 1.5.0
forecast 8.12
foreign 0.8-76
formatR 1.7
Formula 1.2-3
fracdiff 1.5-1
fs 1.4.2
gamlss 5.1-7
gamlss.data 5.1-4
gamlss.dist 5.1-7
gamm4 0.2-6
gbRd 0.4-11
gdata 2.18.0
GeneNet 1.2.15
generics 0.0.2
GenSA 1.1.7
ggplot2 3.3.2
ggplot2movies 0.0.1
ggridges 0.5.2
glasso 1.11
glassoFast 1.0
glm2 1.2.1
glmnet 4.0-2
glue 1.4.1
gmodels 2.18.1
gnm 1.1-1
goftest 1.2-2
gower 0.2.2
gplots 3.0.4
gridBase 0.4-7
gridExtra 2.3
gridGraphics 0.5-0
gss 2.2-2
gsubfn 0.7
gtable 0.3.0
gtools 3.8.2
haven 2.3.1
hexbin 1.28.1
highlight 0.5.0
highr 0.8
Hmisc 4.4-0
hms 0.5.3
HSAUR2 1.1-17
htmlTable 2.0.1
htmltools 0.5.0
htmlwidgets 1.5.1
httpuv 1.5.4
httr 1.4.2
ibdreg 0.2.5
igraph 1.2.5
InformationValue 1.2.3
inline 0.3.15
ipred 0.9-9
IQCC 0.7
irlba 2.3.3
isoband 0.2.2
iterators 1.0.12
itertools 0.1-3
jpeg 0.1-8.1
jsonlite 1.7.0
kedd 1.0.3
kernlab 0.9-29
KernSmooth 2.23-17
klaR 0.6-15
knitr 1.29
labeling 0.3
labelled 2.5.0
Lahman 8.0-0
lars 1.2
later 1.1.0.1
latex2exp 0.4.0
lattice 0.20-41
latticeExtra 0.6-29
lava 1.6.7
lazyeval 0.2.2
leaps 3.1
LearnBayes 2.15.1
libcoin 1.0-5
lifecycle 0.2.0
littler 0.3.11
lme4 1.1-23
lmtest 0.9-37
longitudinal 1.1.12
lsmeans 2.30-0
lubridate 1.7.9
magick 2.4.0
magrittr 1.5
mapdata 2.3.0
mapproj 1.2.7
maps 3.3.0
maptools 1.0-1
markdown 1.1
MASS 7.3-51.6
Matrix 1.2-18
MatrixModels 0.4-1
matrixStats 0.56.0
maxLik 1.3-8
memoise 1.1.0
MEMSS 0.9-3
mgcv 1.8-31
mime 0.9
miniUI 0.1.1.1
minqa 1.2.4
misc3d 0.8-4
miscTools 0.6-26
mistat 1.0-5
mitools 2.4
mlbench 2.1-1
mlmRev 1.0-8
mnormt 1.5-7
ModelMetrics 1.2.2.2
modelr 0.1.8
modeltools 0.2-23
moments 0.14
mondate 0.10.01.02
multcomp 1.4-13
munsell 0.5.0
mvtnorm 1.1-1
nanotime 0.2.4
network 1.16.0
nlme 3.1-148
nloptr 1.2.2.2
nls2 0.2
nlstools 1.0-2
NMF 0.22.0
nnet 7.3-14
nortest 1.0-4
np 0.60-10
numDeriv 2016.8-1.1
nycflights13 1.0.1
openair 2.7-4
openssl 1.4.2
openxlsx 4.1.5
optextras 2019-12.4
optimx 2020-4.2
oz 1.0-21
party 1.3-5
pbkrtest 0.4-8.6
PBSmapping 2.72.1
pcaMethods 1.78.0
pcaPP 1.9-73
PerformanceAnalytics 2.0.4
pillar 1.4.6
pixmap 0.4-11
pkgbuild 1.1.0
pkgconfig 2.0.3
pkgKitten 0.1.5
pkgload 1.1.0
pkgmaker 0.31.1
PKPDmodels 0.3.2
plm 2.2-3
plogr 0.2.0
plot3D 1.3
plotmo 3.5.7
plotrix 3.7-8
plyr 1.8.6
png 0.1-7
polyclip 1.10-0
popbio 2.7
PortfolioAnalytics 1.1.0
praise 1.0.0
prettyunits 1.1.1
pROC 1.16.2
processx 3.4.3
prodlim 2019.11.13
progress 1.2.2
promises 1.1.1
proto 1.0.0
ps 1.3.3
pso 1.0.3
psych 1.9.12.31
purrr 0.3.4
qcc 2.7
quadprog 1.5-8
qualityTools 1.55
quantmod 0.4.17
quantreg 5.61
questionr 0.7.1
qvcalc 1.0.2
R.cache 0.14.0
R.methodsS3 1.8.0
R.oo 1.23.0
R.utils 2.9.2
R6 2.4.1
randomForest 4.6-14
randtests 1.0
raster 3.3-13
Rcgmin 2013-2.21
RColorBrewer 1.1-2
Rcpp 1.0.5
RcppArmadillo 0.9.900.2.0
RcppCCTZ 0.2.7
RcppEigen 0.3.3.7.0
RCurl 1.98-1.2
Rdpack 1.0.0
readr 1.3.1
readstata13 0.9.2
readxl 1.3.1
recipes 0.1.13
registry 0.5-1
relaimpo 2.2-3
relimp 1.0-5
rematch 1.0.1
rematch2 2.1.2
reporttools 1.1.2
reprex 0.3.0
reshape 0.8.8
reshape2 1.4.4
rex 1.2.0
rio 0.5.16
rjson 0.2.20
rlang 0.4.7
Rlinsolve 0.3.1
rmarkdown 2.3
rngtools 1.5
robustbase 0.93-6
ROI 0.3-3
ROI.plugin.quadprog 0.2-5
rpart 4.1-15
rprojroot 1.3-2
rrcov 1.5-2
Rsolnp 1.16
RSQLite 2.2.0
rstudioapi 0.11
rvest 0.3.5
Rvmmin 2018-4.17
sandwich 2.5-1
scales 1.1.1
scatterplot3d 0.3-41
selectr 0.4-2
setRNG 2013.9-1
sf 0.9-5
shape 1.4.4
shiny 1.5.0
SixSigma 0.9-52
slam 0.1-47
soiltexture 1.5.1
sourcetools 0.1.7
sp 1.4-2
spam 2.5-1
SparseM 1.78
spatial 7.3-12
spatstat 1.64-1
spatstat.data 1.4-3
spatstat.utils 1.17-0
spc 0.6.4
spData 0.3.8
spdep 1.1-5
sphet 1.7
splm 1.4-11
sqldf 0.4-11
SQUAREM 2020.3
stabledist 0.7-1
statmod 1.4.34
stringi 1.4.6
stringr 1.4.0
strucchange 1.5-2
styler 1.3.2
survey 4.0
survival 3.2-3
symbols 1.1
sys 3.3
TeachingDemos 2.12
tensor 1.5
testthat 2.3.2
TH.data 1.0-10
tibble 3.0.3
tidyr 1.1.0
tidyselect 1.1.0
tidyverse 1.3.0
tikzDevice 0.12.3.1
timeDate 3043.102
timeSeries 3062.100
tinytex 0.24
tis 1.38
truncnorm 1.0-8
tseries 0.10-47
TTR 0.23-6
ucminf 1.1-4
units 0.6-7
urca 1.3-0
utf8 1.1.4
vcd 1.4-7
vcdExtra 0.7-1
vctrs 0.3.2
viridis 0.5.1
viridisLite 0.3.0
whisker 0.4
withr 2.2.0
wooldridge 1.3.1
xfun 0.15
xml2 1.3.2
xtable 1.8-4
xts 0.12-0
yaml 2.2.1
yuima 1.9.6
zeallot 0.1.0
zip 2.0.4
zoo 1.8-8
"

# 解析
lines <- trimws(strsplit(txt, "\n")[[1]])
lines <- lines[nchar(lines) > 0]

pkg <- sub(" .*", "", lines)
ver <- sub(".* ", "", lines)

repo <- "https://packagemanager.posit.co/cran/2020-07-22"

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
