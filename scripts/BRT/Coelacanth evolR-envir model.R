## Coelocanth environmental determination of evolution rate analysis
## Corey Bradshaw
## June 2023 / updated Mar 2024

# testing effects of dissolved O₂, CO₂, continental flooding area,
# % shallow seas, subduction flux, sea surface temperature on rate of evolution preceding fossil discovery

# libraries
library(dismo)
library(gbm)

## import data
cdat <- read.csv("coelacanthDatV2.csv")
head(cdat)

## calculate median values for full set
ageM <- apply(cdat[,c(5,6)], MARGIN=1, mean, na.rm=T)
contfld <- apply(cdat[,c(7:10)], MARGIN=1, mean, na.rm=T)
dO2M <- apply(cdat[,c(11:14)], MARGIN=1, mean, na.rm=T)
pcShallM <- apply(cdat[,c(15,16)], MARGIN=1, mean, na.rm=T)
CO2M <- apply(cdat[,c(17:20)], MARGIN=1, mean, na.rm=T)
O2M <- apply(cdat[,c(21:24)], MARGIN=1, mean, na.rm=T)
subFluxM <- apply(cdat[,c(25:28)], MARGIN=1, mean, na.rm=T)
SLM <- apply(cdat[,c(29:32)], MARGIN=1, mean, na.rm=T)
SSTM <- apply(cdat[,c(33:36)], MARGIN=1, mean, na.rm=T)

datM <- data.frame(cdat[,c(1:4)], ageM, contfld, dO2M, pcShallM, CO2M, O2M, subFluxM, SLM, SSTM)
colnames(datM) <- c(colnames(cdat)[1:4], "ageM", "contfld", "dO2", "pcShall", "CO2", "O2", "subFlux", "SL", "SST")
head(datM)

## correlation matrix of mean values
cor.dat <- datM[,c(6,7,8,9,11,12,13)]
cormat <- cor(na.omit(cor.dat), method="kendall")
cormat[lower.tri(cormat)] <- NA
cormat
dim(cormat)
t(cormat)

# remove O2 and sea level from analysis (dissolved O2 more relevant; sea level correlated with subduction flux)

# histograms
hist(contfld)
hist(dO2M)
hist(pcShallM)
hist(CO2M)
hist(subFluxM)
hist(SSTM)

## bivariate plots
# by time
par(mfrow=c(2,4))
plot(datM$ageM, datM$evolR, pch=19, col="grey", xlab="age", ylab="evolR")
fitssdO2 <- smooth.spline(datM$ageM, datM$evolR,cv = TRUE)
lines(fitssdO2, lwd=2, lty=2, col="black")

plot(datM$ageM, datM$contfld, pch=19, col="orange", xlab="age", ylab="continental flooding")
fitsscontfld <- smooth.spline(datM$ageM, datM$contfld,cv = TRUE)
lines(fitsscontfld, lwd=2, lty=2, col="darkorange")

plot(datM$ageM, datM$dO2, pch=19, col="lightgreen", xlab="age", ylab="dO2")
fitssdO2 <- smooth.spline(datM$ageM, datM$dO2,cv = TRUE)
lines(fitssdO2, lwd=2, lty=2, col="green")

plot(datM$ageM, datM$pcShall, pch=19, col="grey", xlab="age", ylab="% shallow")
fitsspcShall <- smooth.spline(datM$ageM, datM$pcShall,cv = TRUE)
lines(fitsspcShall, lwd=2, lty=2, col="darkgrey")

plot(datM$ageM, datM$CO2, pch=19, col="tan", xlab="age", ylab="CO2")
fitssCO2 <- smooth.spline(datM$ageM, datM$CO2,cv = TRUE)
lines(fitssCO2, lwd=2, lty=2, col="brown")

plot(datM$ageM, datM$subFlux, pch=19, col="red", xlab="age", ylab="subduction flux")
fitsssubFlux <- smooth.spline(datM$ageM, datM$subFlux,cv = TRUE)
lines(fitsssubFlux, lwd=2, lty=2, col="darkred")

plot(datM$ageM, datM$SST, pch=19, col="blue", xlab="age", ylab="sea surface temperature")
fitssSST <- smooth.spline(datM$ageM, datM$SST,cv = TRUE)
lines(fitssSST, lwd=2, lty=2, col="purple")
par(mfrow=c(1,1))

smthsplnFitsOut <- data.frame(fitsscontfld$x, scale(fitsscontfld$y, center=T, scale=T), fitssdO2$x, scale(fitssdO2$y,
                              center=T, scale=T), scale(fitsspcShall$y, center=T, scale=T), scale(fitssCO2$y,
                              center=T, scale=T), scale(fitsssubFlux$y, center=T, scale=T), scale(fitssSST$y,
                              center=T, scale=T))
colnames(smthsplnFitsOut) <- c("contfldx","contfldy","dO2x","dO2y","pcShally","CO2y","subFluxy","SSTy")

## data standardisation for time-series plots
# subFlux
subFluxsc <- as.numeric(scale(c(as.vector(cdat$subFluxageMinHi), as.vector(cdat$subFluxageMinLo),
                            as.vector(cdat$subFluxageMaxHi), as.vector(cdat$subFluxageMaxLo)), center=T, scale=T))
subFluxscDat <- data.frame(subFluxsc[1:81], subFluxsc[82:(2*81)], subFluxsc[163:(3*81)], subFluxsc[244:(4*81)])

age.mn <- apply(cbind(cdat$FAD, cdat$LAD), MARGIN=1, mean)
age.sd <- (cdat$FAD - cdat$LAD)/2/1.96
subFluxsc.mn <- apply(subFluxscDat, MARGIN=1, mean)
subFluxsc.up <- apply(subFluxscDat, MARGIN=1, quantile, probs=0.975)
subFluxsc.lo <- apply(subFluxscDat, MARGIN=1, quantile, probs=0.025)

subFluxscOut <- data.frame(age.mn, age.sd, subFluxsc.mn,subFluxsc.up,subFluxsc.lo)
fitsssubFluxsc <- smooth.spline(subFluxscOut$age.mn, subFluxscOut$subFluxsc.mn,cv = TRUE)
subFluxscsSmthSpln <- data.frame(fitsssubFluxsc$x, fitsssubFluxsc$y)

# pcShall
pcShallsc <- as.numeric(scale(c(as.vector(cdat$pcShallageMin), as.vector(cdat$pcShallageMax)), center=T, scale=T))
pcShallscDat <- data.frame(pcShallsc[1:81], pcShallsc[82:(2*81)])

age.mn <- apply(cbind(cdat$FAD, cdat$LAD), MARGIN=1, mean)
age.sd <- (cdat$FAD - cdat$LAD)/2/1.96
pcShallsc.mn <- apply(pcShallscDat, MARGIN=1, mean)
pcShallsc.up <- apply(pcShallscDat, MARGIN=1, quantile, probs=0.975)
pcShallsc.lo <- apply(pcShallscDat, MARGIN=1, quantile, probs=0.025)

pcShallscOut <- data.frame(age.mn, age.sd, pcShallsc.mn,pcShallsc.up,pcShallsc.lo)
fitsspcShallsc <- smooth.spline(pcShallscOut$age.mn, pcShallscOut$pcShallsc.mn,cv = TRUE)
pcShallscsSmthSpln <- data.frame(fitsspcShallsc$x, fitsspcShallsc$y)

# SST
SSTsc <- as.numeric(scale(c(as.vector(cdat$SSTageMinHi), as.vector(cdat$SSTageMinLo),
                                as.vector(cdat$SSTageMaxHi), as.vector(cdat$SSTageMaxLo)), center=T, scale=T))
SSTscDat <- data.frame(SSTsc[1:81], SSTsc[82:(2*81)], SSTsc[163:(3*81)], SSTsc[244:(4*81)])

age.mn <- apply(cbind(cdat$FAD, cdat$LAD), MARGIN=1, mean)
age.sd <- (cdat$FAD - cdat$LAD)/2/1.96
SSTsc.mn <- apply(SSTscDat, MARGIN=1, mean)
SSTsc.up <- apply(SSTscDat, MARGIN=1, quantile, probs=0.975)
SSTsc.lo <- apply(SSTscDat, MARGIN=1, quantile, probs=0.025)

SSTscOut <- data.frame(age.mn, age.sd, SSTsc.mn,SSTsc.up,SSTsc.lo)
fitssSSTsc <- smooth.spline(SSTscOut$age.mn, SSTscOut$SSTsc.mn,cv = TRUE)
SSTscsSmthSpln <- data.frame(fitssSSTsc$x, fitssSSTsc$y)

# CO2
CO2sc <- as.numeric(scale(c(as.vector(cdat$CO2ageMinHi), as.vector(cdat$CO2ageMinLo),
           as.vector(cdat$CO2ageMaxHi), as.vector(cdat$CO2ageMaxLo)), center=T, scale=T))
CO2scDat <- data.frame(CO2sc[1:81], CO2sc[82:(2*81)], CO2sc[163:(3*81)], CO2sc[244:(4*81)])

age.mn <- apply(cbind(cdat$FAD, cdat$LAD), MARGIN=1, mean, na.rm=T)
age.sd <- (cdat$FAD - cdat$LAD)/2/1.96
CO2sc.mn <- apply(CO2scDat, MARGIN=1, mean, na.rm=T)
CO2sc.up <- apply(CO2scDat, MARGIN=1, quantile, probs=0.975, na.rm=T)
CO2sc.lo <- apply(CO2scDat, MARGIN=1, quantile, probs=0.025, na.rm=T)

CO2scOut <- data.frame(age.mn, age.sd, CO2sc.mn,CO2sc.up,CO2sc.lo)
fitssCO2sc <- smooth.spline(CO2scOut$age.mn, CO2scOut$CO2sc.mn,cv = TRUE)
CO2scsSmthSpln <- data.frame(fitssCO2sc$x, fitssCO2sc$y)

# dO2
dO2sc <- as.numeric(scale(c(as.vector(cdat$disO2ageMinHi), as.vector(cdat$disO2ageMinLo),
                            as.vector(cdat$disO2ageMaxHi), as.vector(cdat$disO2ageMaxLo)), center=T, scale=T))
dO2scDat <- data.frame(dO2sc[1:81], dO2sc[82:(2*81)], dO2sc[163:(3*81)], dO2sc[244:(4*81)])

age.mn <- apply(cbind(cdat$FAD, cdat$LAD), MARGIN=1, mean)
age.sd <- (cdat$FAD - cdat$LAD)/2/1.96
dO2sc.mn <- apply(dO2scDat, MARGIN=1, mean)
dO2sc.up <- apply(dO2scDat, MARGIN=1, quantile, probs=0.975)
dO2sc.lo <- apply(dO2scDat, MARGIN=1, quantile, probs=0.025)

dO2scOut <- data.frame(age.mn, age.sd, dO2sc.mn,dO2sc.up,dO2sc.lo)
fitssdO2sc <- smooth.spline(dO2scOut$age.mn, dO2scOut$dO2sc.mn,cv = TRUE)
dO2scsSmthSpln <- data.frame(fitssdO2sc$x, fitssdO2sc$y)

# continental flooding
contfldsc <- as.numeric(scale(c(as.vector(cdat$floodageMinHi), as.vector(cdat$floodageMinLo),
                            as.vector(cdat$floodageMaxHi), as.vector(cdat$floodageMaxLo)), center=T, scale=T))
contfldscDat <- data.frame(contfldsc[1:81], contfldsc[82:(2*81)], contfldsc[163:(3*81)], contfldsc[244:(4*81)])

age.mn <- apply(cbind(cdat$FAD, cdat$LAD), MARGIN=1, mean)
age.sd <- (cdat$FAD - cdat$LAD)/2/1.96
contfldsc.mn <- apply(contfldscDat, MARGIN=1, mean)
contfldsc.up <- apply(contfldscDat, MARGIN=1, quantile, probs=0.975)
contfldsc.lo <- apply(contfldscDat, MARGIN=1, quantile, probs=0.025)

contfldscOut <- data.frame(age.mn, age.sd, contfldsc.mn,contfldsc.up,contfldsc.lo)
fitsscontfldsc <- smooth.spline(contfldscOut$age.mn, contfldscOut$contfldsc.mn,cv = TRUE)
contfldscsSmthSpln <- data.frame(fitsscontfldsc$x, fitsscontfldsc$y)

# rate of evolution
evolRsc <- as.numeric(scale(cdat$evolR, center=T, scale=T))

age.mn <- apply(cbind(cdat$FAD, cdat$LAD), MARGIN=1, mean)
age.sd <- (cdat$FAD - cdat$LAD)/2/1.96

evolRscOut <- data.frame(age.mn, age.sd, evolRsc)
fitssevolRsc <- smooth.spline(evolRscOut$age.mn, evolRscOut$evolRsc, cv = TRUE)
evolRscsSmthSpln <- data.frame(fitssevolRsc$x, fitssevolRsc$y)


# plots by rate of evolution
par(mfrow=c(3,3))

plot(datM$contfld, datM$evolR, pch=19, col="orange", ylab="rate of evolution", xlab="continental flooding")
fitsscontfld <- smooth.spline(datM$contfld, datM$evolR,cv = TRUE)
lines(fitsscontfld, lwd=2, lty=2, col="darkorange")

plot(datM$dO2, datM$evolR, pch=19, col="lightgreen", ylab="rate of evolution", xlab="dO2")
fitssdO2 <- smooth.spline(datM$dO2, datM$evolR,cv = TRUE)
lines(fitssdO2, lwd=2, lty=2, col="green")

plot(datM$pcShall, datM$evolR, pch=19, col="grey", ylab="rate of evolution", xlab="% shallow")
fitsspcShall <- smooth.spline(datM$pcShall, datM$evolR,cv = TRUE)
lines(fitsspcShall, lwd=2, lty=2, col="darkgrey")

plot(datM$CO2, datM$evolR, pch=19, col="tan", ylab="rate of evolution", xlab="CO2")
fitssCO2 <- smooth.spline(datM$CO2, datM$evolR,cv = TRUE)
lines(fitssCO2, lwd=2, lty=2, col="brown")

plot(datM$O2, datM$evolR, pch=19, col="lightblue", ylab="rate of evolution", xlab="O2")
fitssO2 <- smooth.spline(datM$O2, datM$evolR,cv = TRUE)
lines(fitssO2, lwd=2, lty=2, col="cyan")

plot(datM$subFlux, datM$evolR, pch=19, col="red", ylab="rate of evolution", xlab="subduction flux")
fitsssubFlux <- smooth.spline(datM$subFlux, datM$evolR,cv = TRUE)
lines(fitsssubFlux, lwd=2, lty=2, col="darkred")

plot(datM$SL, datM$evolR, pch=19, col="pink", ylab="rate of evolution", xlab="sea level")
fitssSL <- smooth.spline(datM$SL, datM$evolR,cv = TRUE)
lines(fitssSL, lwd=2, lty=2, col="magenta")

plot(datM$SST, datM$evolR, pch=19, col="blue", ylab="rate of evolution", xlab="sea surface temperature")
fitssSST <- smooth.spline(datM$SST, datM$evolR,cv = TRUE)
lines(fitssSST, lwd=2, lty=2, col="purple")
par(mfrow=c(1,1))

# scale
datM$evolRsc <- scale(log10(datM$evolR), scale=T, center=T)
datM$contfldsc <- scale((datM$contfld), scale=T, center=T)
datM$dO2sc <- scale((datM$dO2), scale=T, center=T)
datM$pcShallsc <- scale((datM$pcShall), scale=T, center=T)
datM$CO2sc <- scale((datM$CO2), scale=T, center=T)
datM$O2sc <- scale((datM$O2), scale=T, center=T)
datM$subFluxsc <- scale((datM$subFlux), scale=T, center=T)
datM$SLsc <- scale((datM$SL), scale=T, center=T)
datM$SSTsc <- scale((datM$SST), scale=T, center=T)

# scaled histograms
par(mfrow=c(3,3))
hist(datM$evolRsc)
hist(datM$contfldsc)
hist(datM$dO2sc)
hist(datM$pcShallsc)
hist(datM$CO2sc)
hist(datM$O2sc)
hist(datM$subFluxsc)
hist(datM$SLsc)
hist(datM$SSTsc)
par(mfrow=c(1,1))


## boosted regression tree with mean parameters
brt.fitM <- gbm.step(datM, gbm.x = attr(datM, "names")[c(15:18,20,22)], gbm.y = attr(datM, "names")[14], 
                     family="gaussian", max.trees=100000, tolerance = 0.001, learning.rate = 0.0001, 
                     bag.fraction=0.75, tree.complexity = 2)
summary(brt.fitM)
D2 <- 100 * (brt.fitM$cv.statistics$deviance.mean - brt.fitM$self.statistics$mean.resid) / 
  brt.fitM$cv.statistics$deviance.mean
D2 # % deviance explained
gbm.plot(brt.fitM)
gbm.plot.fits(brt.fitM)

brtM.CV.cor <- 100 * brt.fitM$cv.statistics$correlation.mean
brtM.CV.cor
brtM.CV.cor.se <- 100 * brt.fitM$cv.statistics$correlation.se
brtM.CV.cor.se
print(c(brtM.CV.cor, brtM.CV.cor.se))


##########################
## resampling procedure ##
##########################

# set up interval selector
mFAD <- -mean(diff(cdat$FAD))
mLAD <- -mean(diff(cdat$LAD))

sdFAD <- sd(diff(cdat$FAD))
sdLAD <- sd(diff(cdat$LAD))

nFAD <- length(diff(cdat$FAD))
nLAD <- length(diff(cdat$LAD))

# combined mean diffs
mComb <- ((nFAD*mFAD) + (nLAD*mLAD)) / (nFAD+nLAD)

# mean diff diffs
dFAD <- mComb - mFAD
dLAD <- mComb - mLAD

# combined sd diffs
sdComb <- sqrt(((nFAD*(sdFAD^2 + dFAD)) + nLAD*(sdLAD^2 + dLAD))/(nFAD+nLAD))

# oldest
oldest <- max(cdat$FAD)

## iterate
biter <- 1000
eq.sp.points <- 100

# create storage arrays
val.arr <- pred.arr <- array(data = NA, dim = c(eq.sp.points, dim(datM[,c(15:16,19,20,22)])[2], biter),
                             dimnames=list(paste("x",1:eq.sp.points,sep=""), colnames(datM[,c(15:16,19,20,22)]), 
                             paste("b",1:biter,sep="")))

# create storage vectors
D2.vec <- CV.cor.vec <- CV.cor.se.vec <- 
  contfld.ri <- dO2.ri <- CO2.ri <- subFlux.ri <- SST.ri <- rep(NA,biter)

# datset addresses
nCols <- dim(cdat[,c(4,7:14,17:36)])[2]
colnums <- c(4,7:14,17:36)

## functions
# create random interval time vector
resampDatCreate <- function(dataFrame, ncols, colNums, nFAD, mComb, sdComb, oldest) {
  
  intRand <- rnorm(nFAD, mComb, sdComb/3)
  intRandPos <- ifelse(sign(intRand) == -1, -intRand, intRand)
  
  # create random sequence time points
  ranSeq <- oldest - cumsum(intRandPos)
  ranSeqPos <- c(runif(1, max=oldest, min=max(ranSeq)), ranSeq[ranSeq>0])

  # identify rows for these time points
  rowSubs <- rep(NA,length(ranSeqPos))
  datComb <- datOut <- rep(NA, ncols)
  
  for (t in 1:length(ranSeqPos)) {
    rowSubs <- which(ranSeqPos[t] <= dataFrame$FAD & ranSeqPos[t] >= dataFrame$LAD)
    rowSubs
    
    if (length(rowSubs) > 0) {
      datSub <- dataFrame[rowSubs,colNums]
      datComb <- rbind(datComb, datSub)
      datRmean <- apply(datComb, MARGIN=2, mean, na.rm=T)
    } # end if
    
    if (exists("datRmean")==T) {
      datOut <- rbind(datOut, datRmean)
      rm(datRmean)
    } # end if
    
  } # end t
  
  datOut2 <- datOut[-1,]
  rownames(datOut2) <- NULL

  return(datOut2)
} # end function

bootDatCreate <- function(dataFrame) {
  # resample from within ranges of environmental variables to produce dataset for BRT
  minscontfld <- apply(dataFrame[,c(2:5)], MARGIN=1, min, na.rm=T)
  maxscontfld <- apply(dataFrame[,c(2:5)], MARGIN=1, max, na.rm=T)
  minsdO2 <- apply(dataFrame[,c(6:9)], MARGIN=1, min, na.rm=T)
  maxsdO2 <- apply(dataFrame[,c(6:9)], MARGIN=1, max, na.rm=T)
  minsCO2 <- apply(dataFrame[,c(10:13)], MARGIN=1, min, na.rm=T)
  maxsCO2 <- apply(dataFrame[,c(10:13)], MARGIN=1, max, na.rm=T)
  minssubFlux <- apply(dataFrame[,c(18:21)], MARGIN=1, min, na.rm=T)
  maxssubFlux <- apply(dataFrame[,c(18:21)], MARGIN=1, max, na.rm=T)
  minsSST <- apply(dataFrame[,c(26:29)], MARGIN=1, min, na.rm=T)
  maxsSST <- apply(dataFrame[,c(26:29)], MARGIN=1, max, na.rm=T)
  
  valscontfld <- valsdO2 <- valsCO2 <- valssubFlux <- valsSST <- rep(NA,length(minsdO2))
  
  for (s in 1:length(minsdO2)) {
    valscontfld[s] <- runif(1, minscontfld[s], maxscontfld[s])
    valsdO2[s] <- runif(1, minsdO2[s], maxsdO2[s])
    valsCO2[s] <- runif(1, minsCO2[s], maxsCO2[s])
    valssubFlux[s] <- runif(1, minssubFlux[s], maxssubFlux[s])
    valsSST[s] <- runif(1, minsSST[s], maxsSST[s])
  } # end s
  
  datMboot <- data.frame(scale(log10(dataFrame[,1]), center=T, scale=T), scale(valscontfld, center=T, scale=T),
                         scale(valsdO2, center=T, scale=T), scale(valsCO2, center=T, scale=T),
                         scale(valssubFlux, center=T, scale=T), scale(valsSST, center=T, scale=T))
  colnames(datMboot) <- c("evolR", "contfld", "dO2", "CO2", "subFlux", "SST")

  return(datMboot)
} # end function

# loop through biter
for (b in 1:biter) {

  datOut3 <- resampDatCreate(cdat, nCols, colnums, nFAD, mComb, sdComb, oldest)

  datMboot <- bootDatCreate(datOut3)
  bootDatNcols <- dim(datMboot[,c(2:6)])[2]
  # continental flooding, dissolved O2, % shallow sea, atmospheric CO2, subduction flux, SST
  
  bootDatColNums <- c(2:6)
  head(datMboot)
  dim(datMboot)
  
  ## if small resampled dataset, redo
  if (dim(datMboot)[1] < 35) {
    datOut3 <- resampDatCreate(cdat, nCols, colnums, nFAD, mComb, sdComb, oldest)
    datMboot <- bootDatCreate(datOut3)
    bootDatNcols <- dim(datMboot[,c(2:6)])[2]
    bootDatColNums <- c(2:6)
  }

  ## if small resampled dataset, redo
  if (dim(datMboot)[1] < 35) {
    datOut3 <- resampDatCreate(cdat, nCols, colnums, nFAD, mComb, sdComb, oldest)
    datMboot <- bootDatCreate(datOut3)
    bootDatNcols <- dim(datMboot[,c(2:6)])[2]
    bootDatColNums <- c(2:6)
  }
  
  ## if small resampled dataset, redo
  if (dim(datMboot)[1] < 35) {
    datOut3 <- resampDatCreate(cdat, nCols, colnums, nFAD, mComb, sdComb, oldest)
    datMboot <- bootDatCreate(datOut3)
    bootDatNcols <- dim(datMboot[,c(2:6)])[2]
    bootDatColNums <- c(2:6)
  }
  
  ## if small resampled dataset, redo
  if (dim(datMboot)[1] < 35) {
    datOut3 <- resampDatCreate(cdat, nCols, colnums, nFAD, mComb, sdComb, oldest)
    datMboot <- bootDatCreate(datOut3)
    bootDatNcols <- dim(datMboot[,c(2:6)])[2]
    bootDatColNums <- c(2:6)
  }

  ## if small resampled dataset, redo
  if (dim(datMboot)[1] < 35) {
    datOut3 <- resampDatCreate(cdat, nCols, colnums, nFAD, mComb, sdComb, oldest)
    datMboot <- bootDatCreate(datOut3)
    bootDatNcols <- dim(datMboot[,c(2:6)])[2]
    bootDatColNums <- c(2:6)
  }
  
    # boosted regression tree
    rm(brt.fit)
    brt.fit <- gbm.step(datMboot, gbm.x = attr(datMboot, "names")[bootDatColNums], 
                        gbm.y = attr(datMboot, "names")[1], family="gaussian", max.trees=1000000,
                        tolerance = 0.00005, learning.rate = 0.0003, bag.fraction=0.75,
                        tree.complexity = 2, silent=T, tolerance.method = "auto")
    
    if (exists("brt.fit")==T) {
      summ.fit <- summary(brt.fit)
    }

    if (is.null("brt.fit")==T) {
      datOut3 <- resampDatCreate(cdat, nCols, colnums, nFAD, mComb, sdComb, oldest)
      datMboot <- bootDatCreate(datOut3)
      bootDatNcols <- dim(datMboot[,c(2:6)])[2]
      bootDatColNums <- c(2:6)
      
      brt.fit <- gbm.step(datMboot, gbm.x = attr(datMboot, "names")[bootDatColNums], 
                        gbm.y = attr(datMboot, "names")[1], family="gaussian", max.trees=1000000,
                        tolerance = 0.00005, learning.rate = 0.0003, bag.fraction=0.75,
                        tree.complexity = 2, silent=T, tolerance.method = "auto")
      summ.fit <- summary(brt.fit)
    }

    if (is.null("brt.fit")==T | dim(datMboot)[1] < 35) {
      datOut3 <- resampDatCreate(cdat, nCols, colnums, nFAD, mComb, sdComb, oldest)
      datMboot <- bootDatCreate(datOut3)
      bootDatNcols <- dim(datMboot[,c(2:6)])[2]
      bootDatColNums <- c(2:6)
      
      brt.fit <- gbm.step(datMboot, gbm.x = attr(datMboot, "names")[bootDatColNums], 
                          gbm.y = attr(datMboot, "names")[1], family="gaussian", max.trees=1000000,
                          tolerance = 0.00005, learning.rate = 0.0003, bag.fraction=0.75,
                          tree.complexity = 2, silent=T, tolerance.method = "auto")
      summ.fit <- summary(brt.fit)
    }
    
    if (is.null("brt.fit")==T | dim(datMboot)[1] < 35) {
      datOut3 <- resampDatCreate(cdat, nCols, colnums, nFAD, mComb, sdComb, oldest)
      datMboot <- bootDatCreate(datOut3)
      bootDatNcols <- dim(datMboot[,c(2:6)])[2]
      bootDatColNums <- c(2:6)
      
      brt.fit <- gbm.step(datMboot, gbm.x = attr(datMboot, "names")[bootDatColNums], 
                          gbm.y = attr(datMboot, "names")[1], family="gaussian", max.trees=1000000,
                          tolerance = 0.00005, learning.rate = 0.0003, bag.fraction=0.75,
                          tree.complexity = 2, silent=T, tolerance.method = "auto")
      summ.fit <- summary(brt.fit)
    }

    if (is.null("brt.fit")==T | dim(datMboot)[1] < 35) {
      datOut3 <- resampDatCreate(cdat, nCols, colnums, nFAD, mComb, sdComb, oldest)
      datMboot <- bootDatCreate(datOut3)
      bootDatNcols <- dim(datMboot[,c(2:6)])[2]
      bootDatColNums <- c(2:6)
      
      brt.fit <- gbm.step(datMboot, gbm.x = attr(datMboot, "names")[bootDatColNums], 
                          gbm.y = attr(datMboot, "names")[1], family="gaussian", max.trees=1000000,
                          tolerance = 0.00005, learning.rate = 0.0003, bag.fraction=0.75,
                          tree.complexity = 2, silent=T, tolerance.method = "auto")
      summ.fit <- summary(brt.fit)
    }
    
    while (is.null("brt.fit")==T) {
      brt.fit <- gbm.step(datMboot, gbm.x = attr(datMboot, "names")[bootDatColNums], 
                          gbm.y = attr(datMboot, "names")[1], family="gaussian", max.trees=1000000,
                          tolerance = 0.00005, learning.rate = 0.0003, bag.fraction=0.75,
                          tree.complexity = 2, silent=T, tolerance.method = "auto")
      summ.fit <- summary(brt.fit)
    }
    
    # variable relative importance
    contfld.ri[b] <- summ.fit$rel.inf[which(summ.fit$var == attr(datMboot, "names")[bootDatColNums][1])]
    dO2.ri[b] <- summ.fit$rel.inf[which(summ.fit$var == attr(datMboot, "names")[bootDatColNums][2])]
    CO2.ri[b] <- summ.fit$rel.inf[which(summ.fit$var == attr(datMboot, "names")[bootDatColNums][3])]
    subFlux.ri[b] <- summ.fit$rel.inf[which(summ.fit$var == attr(datMboot, "names")[bootDatColNums][4])]
    SST.ri[b] <- summ.fit$rel.inf[which(summ.fit$var == attr(datMboot, "names")[bootDatColNums][5])]
    
    D2 <- 100 * (brt.fit$cv.statistics$deviance.mean - brt.fit$self.statistics$mean.resid) / 
        brt.fit$cv.statistics$deviance.mean
    D2.vec[b] <- D2
    CV.cor <- 100 * brt.fit$cv.statistics$correlation.mean
    CV.cor.vec[b] <- CV.cor
    CV.cor.se <- 100 *brt.fit$cv.statistics$correlation.se
    CV.cor.se.vec[b] <- CV.cor.se
    
    RESP.val <- RESP.pred <- matrix(data=NA, nrow=eq.sp.points, ncol=bootDatNcols)
    ## output average predictions
    for (p in 1:bootDatNcols) {
      RESP.val[,p] <- plot.gbm(brt.fit, i.var=p, continuous.resolution=eq.sp.points, return.grid=T)[,1]
      RESP.pred[,p] <- plot.gbm(brt.fit, i.var=p, continuous.resolution=eq.sp.points, return.grid=T)[,2]
    } # end p
    
    RESP.val.dat <- as.data.frame(RESP.val)
    colnames(RESP.val.dat) <- brt.fit$var.names
    RESP.pred.dat <- as.data.frame(RESP.pred)
    colnames(RESP.pred.dat) <- brt.fit$var.names
    
    val.arr[, , b] <- as.matrix(RESP.val.dat)
    pred.arr[, , b] <- as.matrix(RESP.pred.dat)
    
    print(b)

} # end b

# kappa method to reduce effects of outliers on bootstrap estimates
kappa <- 2
kappa.n <- bootDatNcols
pred.update <- pred.arr[,,1:biter]

for (k in 1:kappa.n) {
  boot.mean <- apply(pred.update, MARGIN=c(1,2), mean, na.rm=T)
  boot.sd <- apply(pred.update, MARGIN=c(1,2), sd, na.rm=T)
  
  for (z in 1:biter) {
    pred.update[,,z] <- ifelse((pred.update[,,z] < (boot.mean-kappa*boot.sd) | 
                                  pred.update[,,z] > (boot.mean+kappa*boot.sd)), NA, pred.update[,,z])
  }
  print(k)
} # end k

pred.med <- apply(pred.update, MARGIN=c(1,2), median, na.rm=T)
pred.lo <- apply(pred.update, MARGIN=c(1,2), quantile, probs=0.025, na.rm=T)
pred.up <- apply(pred.update, MARGIN=c(1,2), quantile, probs=0.975, na.rm=T)
val.med <- apply(val.arr[,,1:biter], MARGIN=c(1,2), median, na.rm=T)

# kappa method for output vectors
D2.update <- D2.vec[1:biter]
CV.cor.update <- CV.cor.vec[1:biter]
CV.cor.se.update <- CV.cor.se.vec[1:biter]

contfld.ri.update <- contfld.ri[1:biter]
dO2.ri.update <- dO2.ri[1:biter]
CO2.ri.update <- CO2.ri[1:biter]
subFlux.ri.update <- subFlux.ri[1:biter]
SST.ri.update <- SST.ri[1:biter]

for (k in 1:kappa.n) {
  D2.mean <- mean(D2.update, na.rm=T); D2.sd <- sd(D2.update, na.rm=T)
  CV.cor.mean <- mean(CV.cor.update, na.rm=T); CV.cor.sd <- sd(CV.cor.update, na.rm=T)
  CV.cor.se.mean <- mean(CV.cor.se.update, na.rm=T); CV.cor.se.sd <- sd(CV.cor.se.update, na.rm=T)
  
  contfld.mean <- mean(contfld.ri.update, na.rm=T); contfld.sd <- sd(contfld.ri.update, na.rm=T)
  dO2.mean <- mean(dO2.ri.update, na.rm=T); dO2.sd <- sd(dO2.ri.update, na.rm=T)
  CO2.mean <- mean(CO2.ri.update, na.rm=T); CO2.sd <- sd(CO2.ri.update, na.rm=T)
  subFlux.mean <- mean(subFlux.ri.update, na.rm=T); subFlux.sd <- sd(subFlux.ri.update, na.rm=T)
  SST.mean <- mean(SST.ri.update, na.rm=T); SST.sd <- sd(SST.ri.update, na.rm=T)
  
  for (u in 1:biter) {
    D2.update[u] <- ifelse((D2.update[u] < (D2.mean-kappa*D2.sd) | 
                              D2.update[u] > (D2.mean+kappa*D2.sd)), NA, D2.update[u])
    CV.cor.update[u] <- ifelse((CV.cor.update[u] < (CV.cor.mean-kappa*CV.cor.sd) | 
                                  CV.cor.update[u] > (CV.cor.mean+kappa*CV.cor.sd)), NA, CV.cor.update[u])
    CV.cor.se.update[u] <- ifelse((CV.cor.se.update[u] < (CV.cor.se.mean-kappa*CV.cor.se.sd) | 
                                     CV.cor.se.update[u] > (CV.cor.se.mean+kappa*CV.cor.se.sd)), NA, 
                                     CV.cor.se.update[u])
    
    contfld.ri.update[u] <- ifelse((contfld.ri.update[u] < (contfld.mean-kappa*contfld.sd) | 
                                      contfld.ri.update[u] > (contfld.mean+kappa*contfld.sd)), NA, 
                                      contfld.ri.update[u])
    dO2.ri.update[u] <- ifelse((dO2.ri.update[u] < (dO2.mean-kappa*dO2.sd) | 
                                  dO2.ri.update[u] > (dO2.mean+kappa*dO2.sd)), NA, dO2.ri.update[u])
    CO2.ri.update[u] <- ifelse((CO2.ri.update[u] < (CO2.mean-kappa*CO2.sd) | 
                                  CO2.ri.update[u] > (CO2.mean+kappa*CO2.sd)), NA, CO2.ri.update[u])
    subFlux.ri.update[u] <- ifelse((subFlux.ri.update[u] < (subFlux.mean-kappa*subFlux.sd) | 
                                      subFlux.ri.update[u] > (subFlux.mean+kappa*subFlux.sd)), NA, 
                                      subFlux.ri.update[u])
    SST.ri.update[u] <- ifelse((SST.ri.update[u] < (SST.mean-kappa*SST.sd) | 
                                  SST.ri.update[u] > (SST.mean+kappa*SST.sd)), NA, SST.ri.update[u])
  } # end for
  
  print(k)
} # end k

D2.med <- median(D2.update, na.rm=TRUE)
D2.lo <- quantile(D2.update, probs=0.025, na.rm=TRUE)
D2.up <- quantile(D2.update, probs=0.975, na.rm=TRUE)
print(c(D2.lo,D2.med,D2.up))

CV.cor.med <- median(CV.cor.update, na.rm=TRUE)
CV.cor.lo <- quantile(CV.cor.update, probs=0.025, na.rm=TRUE)
CV.cor.up <- quantile(CV.cor.update, probs=0.975, na.rm=TRUE)
print(c(CV.cor.lo,CV.cor.med,CV.cor.up))

contfld.ri.lo <- quantile(contfld.ri.update, probs=0.025, na.rm=TRUE)
contfld.ri.med <- median(contfld.ri.update, na.rm=TRUE)
contfld.ri.up <- quantile(contfld.ri.update, probs=0.975, na.rm=TRUE)

dO2.ri.lo <- quantile(dO2.ri.update, probs=0.025, na.rm=TRUE)
dO2.ri.med <- median(dO2.ri.update, na.rm=TRUE)
dO2.ri.up <- quantile(dO2.ri.update, probs=0.975, na.rm=TRUE)

CO2.ri.lo <- quantile(CO2.ri.update, probs=0.025, na.rm=TRUE)
CO2.ri.med <- median(CO2.ri.update, na.rm=TRUE)
CO2.ri.up <- quantile(CO2.ri.update, probs=0.975, na.rm=TRUE)

subFlux.ri.lo <- quantile(subFlux.ri.update, probs=0.025, na.rm=TRUE)
subFlux.ri.med <- median(subFlux.ri.update, na.rm=TRUE)
subFlux.ri.up <- quantile(subFlux.ri.update, probs=0.975, na.rm=TRUE)

SST.ri.lo <- quantile(SST.ri.update, probs=0.025, na.rm=TRUE)
SST.ri.med <- median(SST.ri.update, na.rm=TRUE)
SST.ri.up <- quantile(SST.ri.update, probs=0.975, na.rm=TRUE)

ri.lo <- c(contfld.ri.lo,dO2.ri.lo,CO2.ri.lo,subFlux.ri.lo,SST.ri.lo)
ri.med <- c(contfld.ri.med,dO2.ri.med,CO2.ri.med,subFlux.ri.med,SST.ri.med)
ri.up <- c(contfld.ri.up,dO2.ri.up,CO2.ri.up,subFlux.ri.up,SST.ri.up)

ri.out <- as.data.frame(cbind(ri.lo,ri.med,ri.up))
colnames(ri.out) <- c("ri.lo","ri.med","ri.up")
rownames(ri.out) <- colnames(datMboot[bootDatColNums])

ri.sort <- ri.out[order(ri.out[,2],decreasing=T),1:3]
ri.sort
