# LauraeCE: Laurae's R package for Parallel Cross-Entropy Optimization

This R pacakge is meant to be used for Cross-Entropy optimization, which is a global optimization method for both continuous and discrete parameters. It tends to outperform Differential Evolution in my local tests.

It also uses [LauraeParallel](https://github.com/Laurae2/LauraeParallel/) load balancing for parallelization, which makes it suitable for long and dynamic optimization tasks.

**Cross-Entropy optimization earned 3rd place *(thanks to [Laurae](https://www.kaggle.com/laurae2))* in 2017 at the Ecole Nationale Supérieure metachallenge, earning several 1st and 2nd places in several challenges of the metachallenge** *(did you know Laurae did not receive any gift for such feat because the organizers ran out of gifts? now you know!)*.

Installation:

```r
devtools::install_github("Laurae2/LauraeParallel")
devtools::install_github("Laurae2/LauraeCE")
```

Original source: https://cran.r-project.org/web/packages/CEoptim/index.html

TO-DO:
- [x] add parallelism
- [x] add load balancing
- [ ] ~~add hot loading (use previous optimization)~~ (this one was stupid because one could just use the previous mean/sd/probs)
- [ ] add interrupt on the fly while saving data (tcltk?)
- [x] add maximum computation time before cancelling (while returning cleanly)

# Example

This is how it currently looks and you will notice it is absurdly SLOW on very small tasks:

```r
> library(LauraeCE)
Loading required package: MASS
Loading required package: msm
Loading required package: sna
Loading required package: statnet.common
Loading required package: network
network: Classes for Relational Data
Version 1.13.0 created on 2015-08-31.
copyright (c) 2005, Carter T. Butts, University of California-Irvine
                    Mark S. Handcock, University of California -- Los Angeles
                    David R. Hunter, Penn State University
                    Martina Morris, University of Washington
                    Skye Bender-deMoll, University of Washington
 For citation information, type citation("network").
 Type help("network-package") to get started.

sna: Tools for Social Network Analysis
Version 2.4 created on 2016-07-23.
copyright (c) 2005, Carter T. Butts, University of California-Irvine
 For citation information, type citation("sna").
 Type help(package="sna") to get started.

Loading required package: R.utils
Loading required package: R.oo
Loading required package: R.methodsS3
R.methodsS3 v1.7.1 (2016-02-15) successfully loaded. See ?R.methodsS3 for help.
R.oo v1.21.0 (2016-10-30) successfully loaded. See ?R.oo for help.

Attaching package: ‘R.oo’

The following object is masked from ‘package:sna’:

    hierarchy

The following objects are masked from ‘package:methods’:

    getClasses, getMethods

The following objects are masked from ‘package:base’:

    attach, detach, gc, load, save

R.utils v2.5.0 (2016-11-07) successfully loaded. See ?R.utils for help.

Attaching package: ‘R.utils’

The following object is masked from ‘package:utils’:

    timestamp

The following objects are masked from ‘package:base’:

    cat, commandArgs, getOption, inherits, isOpen, parse, warnings

Loading required package: LauraeParallel
> library(parallel)
> 
> 
> # Continuous Testing
> 
> fun <- function(x){
+   return(3 * (1 - x[1]) ^ 2 * exp(-x[1] ^ 2 - (x[2] + 1) ^ 2) - 10 * (x[1] / 5 - x[1] ^ 3 - x[2] ^ 5) * exp(-x[1] ^ 2 - x[2] ^ 2) - 1 / 3 * exp(-(x[1] + 1) ^ 2 - x[2] ^ 2))
+ }
> 
> mu0 <- c(-3, -3)
> sigma0 <- c(10, 10)
> 
> system.time({set.seed(11111)
+ res1 <- CEoptim::CEoptim(fun, continuous = list(mean = mu0, sd = sigma0), maximize = TRUE)})
   user  system elapsed 
   0.14    0.00    0.14 
> 
> system.time({set.seed(11111)
+ res2 <- CEoptim(fun, continuous = list(mean = mu0, sd = sigma0), maximize = TRUE)})
   user  system elapsed 
   0.14    0.00    0.16 
> 
> cl <- makeCluster(2)
> system.time({set.seed(11111)
+ res3 <- CEoptim(fun, continuous = list(mean = mu0, sd = sigma0), maximize = TRUE, parallelize = TRUE, cl = cl)})
   user  system elapsed 
   0.39    0.02    2.21 
> stopCluster(cl)
> closeAllConnections()
> 
> all.equal(res1$optimum, res2$optimum)
[1] TRUE
> all.equal(res1$optimum, res3$optimum)
[1] TRUE
> 
> 
> # Discrete Testing
> 
> data(lesmis)
> fmaxcut <- function(x,costs) {
+   v1 <- which(x == 1)
+   v2 <- which(x == 0)
+   return(sum(costs[v1, v2]))
+ }
> 
> p0 <- list()
> for (i in 1:77) {
+   p0 <- c(p0, list(rep(0.5, 2)))
+ }
> p0[[1]] <- c(0, 1)
> 
> system.time({set.seed(11111)
+ res1 <- CEoptim::CEoptim(fmaxcut, f.arg = list(costs = lesmis), maximize = T, verbose = TRUE, discrete = list(probs = p0), N = 3000L)})
Number of continuous variables: 0  
Number of discrete variables: 77 
conMat= 
NULL
conVec= 
NULL
smoothMean: 1 smoothSd: 1 smoothProb: 1 
N: 3000 rho: 0.1 iterThr: 10000 sdThr: 0.001 probThr 0.001 
iter: 0  opt: 494 maxProbs: 0.5
iter: 1  opt: 501 maxProbs: 0.5
iter: 2  opt: 501 maxProbs: 0.5
iter: 3  opt: 501 maxProbs: 0.4966667
iter: 4  opt: 506 maxProbs: 0.5
iter: 5  opt: 510 maxProbs: 0.5
iter: 6  opt: 514 maxProbs: 0.5
iter: 7  opt: 515 maxProbs: 0.5
iter: 8  opt: 519 maxProbs: 0.4966667
iter: 9  opt: 523 maxProbs: 0.4933333
iter: 10  opt: 526 maxProbs: 0.4966667
iter: 11  opt: 528 maxProbs: 0.4933333
iter: 12  opt: 528 maxProbs: 0.4866667
iter: 13  opt: 530 maxProbs: 0.4966667
iter: 14  opt: 532 maxProbs: 0.49
iter: 15  opt: 532 maxProbs: 0.4733333
iter: 16  opt: 532 maxProbs: 0.4533333
iter: 17  opt: 533 maxProbs: 0.49
iter: 18  opt: 533 maxProbs: 0.4533333
iter: 19  opt: 533 maxProbs: 0.5
iter: 20  opt: 533 maxProbs: 0.4366667
iter: 21  opt: 533 maxProbs: 0.3766667
iter: 22  opt: 533 maxProbs: 0.3633333
   user  system elapsed 
   3.76    0.00    3.76 
> 
> system.time({set.seed(11111)
+ res2 <- CEoptim(fmaxcut, f.arg = list(costs = lesmis), maximize = T, verbose = TRUE, discrete = list(probs = p0), N = 3000L)})
Number of continuous variables: 0  
Number of discrete variables: 77 
conMat= 
NULL
conVec= 
NULL
smoothMean: 1 smoothSd: 1 smoothProb: 1 
N: 3000 rho: 0.1 iterThr: 10000 sdThr: 0.001 probThr 0.001 
Sun Oct 15 2017 05:24:48 PM t: 00s092ms - iter: 00000 - opt: 494 - maxProbs: 0.5
Sun Oct 15 2017 05:24:48 PM t: 00s103ms - iter: 00001 - opt: 501 - maxProbs: 0.5
Sun Oct 15 2017 05:24:48 PM t: 00s104ms - iter: 00002 - opt: 501 - maxProbs: 0.5
Sun Oct 15 2017 05:24:49 PM t: 00s122ms - iter: 00003 - opt: 501 - maxProbs: 0.4966667
Sun Oct 15 2017 05:24:49 PM t: 00s128ms - iter: 00004 - opt: 506 - maxProbs: 0.5
Sun Oct 15 2017 05:24:49 PM t: 00s114ms - iter: 00005 - opt: 510 - maxProbs: 0.5
Sun Oct 15 2017 05:24:49 PM t: 00s092ms - iter: 00006 - opt: 514 - maxProbs: 0.5
Sun Oct 15 2017 05:24:49 PM t: 00s095ms - iter: 00007 - opt: 515 - maxProbs: 0.5
Sun Oct 15 2017 05:24:49 PM t: 00s111ms - iter: 00008 - opt: 519 - maxProbs: 0.4966667
Sun Oct 15 2017 05:24:49 PM t: 00s112ms - iter: 00009 - opt: 523 - maxProbs: 0.4933333
Sun Oct 15 2017 05:24:50 PM t: 00s130ms - iter: 00010 - opt: 526 - maxProbs: 0.4966667
Sun Oct 15 2017 05:24:50 PM t: 00s112ms - iter: 00011 - opt: 528 - maxProbs: 0.4933333
Sun Oct 15 2017 05:24:50 PM t: 00s109ms - iter: 00012 - opt: 528 - maxProbs: 0.4866667
Sun Oct 15 2017 05:24:50 PM t: 00s131ms - iter: 00013 - opt: 530 - maxProbs: 0.4966667
Sun Oct 15 2017 05:24:50 PM t: 00s109ms - iter: 00014 - opt: 532 - maxProbs: 0.49
Sun Oct 15 2017 05:24:50 PM t: 00s124ms - iter: 00015 - opt: 532 - maxProbs: 0.4733333
Sun Oct 15 2017 05:24:50 PM t: 00s119ms - iter: 00016 - opt: 532 - maxProbs: 0.4533333
Sun Oct 15 2017 05:24:51 PM t: 00s161ms - iter: 00017 - opt: 533 - maxProbs: 0.49
Sun Oct 15 2017 05:24:51 PM t: 00s126ms - iter: 00018 - opt: 533 - maxProbs: 0.4533333
Sun Oct 15 2017 05:24:51 PM t: 00s211ms - iter: 00019 - opt: 533 - maxProbs: 0.5
Sun Oct 15 2017 05:24:51 PM t: 00s087ms - iter: 00020 - opt: 533 - maxProbs: 0.4366667
Sun Oct 15 2017 05:24:51 PM t: 00s099ms - iter: 00021 - opt: 533 - maxProbs: 0.3766667
Sun Oct 15 2017 05:24:51 PM t: 00s105ms - iter: 00022 - opt: 533 - maxProbs: 0.3633333
   user  system elapsed 
   3.61    0.01    3.67 
> 
> cl <- makeCluster(2)
> system.time({set.seed(11111)
+ res3 <- CEoptim(fmaxcut, f.arg = list(costs = lesmis), maximize = T, verbose = TRUE, discrete = list(probs = p0), N = 3000L, parallelize = TRUE, cl = cl)})
Number of continuous variables: 0  
Number of discrete variables: 77 
conMat= 
NULL
conVec= 
NULL
smoothMean: 1 smoothSd: 1 smoothProb: 1 
N: 3000 rho: 0.1 iterThr: 10000 sdThr: 0.001 probThr 0.001 
Sun Oct 15 2017 05:24:57 PM t: 05s591ms - iter: 00000 - opt: 494 - maxProbs: 0.5
Sun Oct 15 2017 05:24:59 PM t: 01s035ms - iter: 00001 - opt: 501 - maxProbs: 0.5
Sun Oct 15 2017 05:25:01 PM t: 02s080ms - iter: 00002 - opt: 501 - maxProbs: 0.5
Sun Oct 15 2017 05:25:02 PM t: 02s069ms - iter: 00003 - opt: 501 - maxProbs: 0.4966667
Sun Oct 15 2017 05:25:04 PM t: 01s188ms - iter: 00004 - opt: 506 - maxProbs: 0.5
Sun Oct 15 2017 05:25:06 PM t: 02s013ms - iter: 00005 - opt: 510 - maxProbs: 0.5
Sun Oct 15 2017 05:25:07 PM t: 01s033ms - iter: 00006 - opt: 514 - maxProbs: 0.5
Sun Oct 15 2017 05:25:09 PM t: 02s080ms - iter: 00007 - opt: 515 - maxProbs: 0.5
Sun Oct 15 2017 05:25:11 PM t: 02s052ms - iter: 00008 - opt: 519 - maxProbs: 0.4966667
Sun Oct 15 2017 05:25:12 PM t: 01s137ms - iter: 00009 - opt: 523 - maxProbs: 0.4933333
Sun Oct 15 2017 05:25:14 PM t: 02s109ms - iter: 00010 - opt: 526 - maxProbs: 0.4966667
Sun Oct 15 2017 05:25:16 PM t: 01s217ms - iter: 00011 - opt: 528 - maxProbs: 0.4933333
Sun Oct 15 2017 05:25:18 PM t: 02s225ms - iter: 00012 - opt: 528 - maxProbs: 0.4866667
Sun Oct 15 2017 05:25:19 PM t: 01s183ms - iter: 00013 - opt: 530 - maxProbs: 0.4966667
Sun Oct 15 2017 05:25:21 PM t: 01s969ms - iter: 00014 - opt: 532 - maxProbs: 0.49
Sun Oct 15 2017 05:25:23 PM t: 01s251ms - iter: 00015 - opt: 532 - maxProbs: 0.4733333
Sun Oct 15 2017 05:25:25 PM t: 02s118ms - iter: 00016 - opt: 532 - maxProbs: 0.4533333
Sun Oct 15 2017 05:25:26 PM t: 01s239ms - iter: 00017 - opt: 533 - maxProbs: 0.49
Sun Oct 15 2017 05:25:28 PM t: 02s158ms - iter: 00018 - opt: 533 - maxProbs: 0.4533333
Sun Oct 15 2017 05:25:30 PM t: 01s337ms - iter: 00019 - opt: 533 - maxProbs: 0.5
Sun Oct 15 2017 05:25:31 PM t: 02s127ms - iter: 00020 - opt: 533 - maxProbs: 0.4366667
Sun Oct 15 2017 05:25:33 PM t: 01s226ms - iter: 00021 - opt: 533 - maxProbs: 0.3766667
Sun Oct 15 2017 05:25:35 PM t: 02s191ms - iter: 00022 - opt: 533 - maxProbs: 0.3633333
   user  system elapsed 
  19.12   11.11   44.43 
> stopCluster(cl)
> closeAllConnections()
> 
> all.equal(res1$optimizer$discrete, res2$optimizer$discrete)
[1] TRUE
> all.equal(res1$optimizer$discrete, res3$optimizer$discrete)
[1] TRUE
> 
> cl <- makeCluster(2)
> system.time({set.seed(11111)
+   res3 <- CEoptim(fmaxcut, f.arg = list(costs = lesmis), maximize = T, verbose = TRUE, discrete = list(probs = p0), N = 3000L, max_time = 15, parallelize = TRUE, cl = cl)})
Number of continuous variables: 0  
Number of discrete variables: 77 
conMat= 
NULL
conVec= 
NULL
smoothMean: 1 smoothSd: 1 smoothProb: 1 
N: 3000 rho: 0.1 iterThr: 10000 sdThr: 0.001 probThr 0.001 
Sun Oct 15 2017 05:25:42 PM t: 05s774ms - iter: 00000 - opt: 494 - maxProbs: 0.5
Sun Oct 15 2017 05:25:44 PM t: 01s097ms - iter: 00001 - opt: 501 - maxProbs: 0.5
Sun Oct 15 2017 05:25:46 PM t: 01s987ms - iter: 00002 - opt: 501 - maxProbs: 0.5
Sun Oct 15 2017 05:25:47 PM t: 01s035ms - iter: 00003 - opt: 501 - maxProbs: 0.4966667
Sun Oct 15 2017 05:25:49 PM t: 02s055ms - iter: 00004 - opt: 506 - maxProbs: 0.5
Sun Oct 15 2017 05:25:51 PM t: 02s057ms - iter: 00005 - opt: 510 - maxProbs: 0.5
   user  system elapsed 
   5.64    2.98   15.25 
> stopCluster(cl)
> closeAllConnections()
> all.equal(res1$optimizer$discrete, res3$optimizer$discrete)
[1] "Mean relative difference: 2.25"
> 
> 
> # Mixed Input (Continuous + Discrete) Testing
> 
> sumsqrs <- function(theta, rm1, x) {
+   N <- length(x) #without x[0]
+   r <- 1 + sort(rm1) # internal end points of regimes
+   if (r[1] == r[2]) { # test for invalid regime
+     return(Inf);
+   }
+   thetas <- rep(theta, times = c(r, N) - c(1, r + 1) + 1)
+   xhat <- c(0, head(x, -1)) * thetas
+   # Compute sum of squared errors
+   sum((x - xhat) ^ 2)
+ }
> 
> data(yt)
> xt <- yt - c(0, yt[-300])
> 
> A <- rbind(diag(3), -diag(3))
> b <- rep(1, 6)
> 
> system.time({set.seed(11111)
+ res1 <- CEoptim::CEoptim(f = sumsqrs,
+                          f.arg = list(xt),
+                          continuous = list(mean = c(0, 0,0),
+                                            sd = rep(1, 0,3),
+                                            conMat = A,
+                                            conVec = b),
+                          discrete = list(categories = c(298L, 298L),
+                                          smoothProb = 0.5),
+                          N = 10000,
+                          rho = 0.001,
+                          verbose = TRUE)})
Number of continuous variables: 3  
Number of discrete variables: 2 
conMat= 
     [,1] [,2] [,3]
[1,]    1    0    0
[2,]    0    1    0
[3,]    0    0    1
[4,]   -1    0    0
[5,]    0   -1    0
[6,]    0    0   -1
conVec= 
[1] 1 1 1 1 1 1
smoothMean: 1 smoothSd: 1 smoothProb: 0.5 
N: 10000 rho: 0.001 iterThr: 10000 sdThr: 0.001 probThr 0.001 
iter: 0  opt: 3.009517 maxSd: 0.3248419 maxProbs: 0.9483221
iter: 1  opt: 2.70702 maxSd: 0.07449603 maxProbs: 0.7741611
iter: 2  opt: 2.688896 maxSd: 0.04549593 maxProbs: 0.7495805
iter: 3  opt: 2.677602 maxSd: 0.03024808 maxProbs: 0.6247903
iter: 4  opt: 2.675769 maxSd: 0.006000473 maxProbs: 0.4498951
iter: 5  opt: 2.675727 maxSd: 0.000613875 maxProbs: 0.2249476
iter: 6  opt: 2.675727 maxSd: 7.4365e-05 maxProbs: 0.1124738
iter: 7  opt: 2.675727 maxSd: 4.23201e-06 maxProbs: 0.05623689
iter: 8  opt: 2.675727 maxSd: 4.225456e-07 maxProbs: 0.02811845
iter: 9  opt: 2.675727 maxSd: 3.376241e-08 maxProbs: 0.01405922
iter: 10  opt: 2.675727 maxSd: 7.751173e-09 maxProbs: 0.007029611
iter: 11  opt: 2.675727 maxSd: 2.775761e-09 maxProbs: 0.003514806
iter: 12  opt: 2.675727 maxSd: 1.736754e-09 maxProbs: 0.001757403
   user  system elapsed 
  11.84    0.00   11.84 
> 
> system.time({set.seed(11111)
+ res2 <- CEoptim(f = sumsqrs,
+                 f.arg = list(xt),
+                 continuous = list(mean = c(0, 0,0),
+                                   sd = rep(1, 0,3),
+                                   conMat = A,
+                                   conVec = b),
+                 discrete = list(categories = c(298L, 298L),
+                                 smoothProb = 0.5),
+                 N = 10000,
+                 rho = 0.001,
+                 verbose = TRUE)})
Number of continuous variables: 3  
Number of discrete variables: 2 
conMat= 
     [,1] [,2] [,3]
[1,]    1    0    0
[2,]    0    1    0
[3,]    0    0    1
[4,]   -1    0    0
[5,]    0   -1    0
[6,]    0    0   -1
conVec= 
[1] 1 1 1 1 1 1
smoothMean: 1 smoothSd: 1 smoothProb: 0.5 
N: 10000 rho: 0.001 iterThr: 10000 sdThr: 0.001 probThr 0.001 
Sun Oct 15 2017 05:26:05 PM t: 00s744ms - iter: 00000 - opt: 3.009517 - maxSd: 0.3248419 - maxProbs: 0.9483221
Sun Oct 15 2017 05:26:06 PM t: 00s821ms - iter: 00001 - opt: 2.70702 - maxSd: 0.07449603 - maxProbs: 0.7741611
Sun Oct 15 2017 05:26:07 PM t: 00s800ms - iter: 00002 - opt: 2.688896 - maxSd: 0.04549593 - maxProbs: 0.7495805
Sun Oct 15 2017 05:26:08 PM t: 00s826ms - iter: 00003 - opt: 2.677602 - maxSd: 0.03024808 - maxProbs: 0.6247903
Sun Oct 15 2017 05:26:08 PM t: 00s822ms - iter: 00004 - opt: 2.675769 - maxSd: 0.006000473 - maxProbs: 0.4498951
Sun Oct 15 2017 05:26:09 PM t: 00s870ms - iter: 00005 - opt: 2.675727 - maxSd: 0.000613875 - maxProbs: 0.2249476
Sun Oct 15 2017 05:26:10 PM t: 01s034ms - iter: 00006 - opt: 2.675727 - maxSd: 7.4365e-05 - maxProbs: 0.1124738
Sun Oct 15 2017 05:26:11 PM t: 00s769ms - iter: 00007 - opt: 2.675727 - maxSd: 4.23201e-06 - maxProbs: 0.05623689
Sun Oct 15 2017 05:26:12 PM t: 00s891ms - iter: 00008 - opt: 2.675727 - maxSd: 4.225456e-07 - maxProbs: 0.02811845
Sun Oct 15 2017 05:26:13 PM t: 00s849ms - iter: 00009 - opt: 2.675727 - maxSd: 3.376241e-08 - maxProbs: 0.01405922
Sun Oct 15 2017 05:26:14 PM t: 00s893ms - iter: 00010 - opt: 2.675727 - maxSd: 7.751173e-09 - maxProbs: 0.007029611
Sun Oct 15 2017 05:26:15 PM t: 00s879ms - iter: 00011 - opt: 2.675727 - maxSd: 2.775761e-09 - maxProbs: 0.003514806
Sun Oct 15 2017 05:26:16 PM t: 00s959ms - iter: 00012 - opt: 2.675727 - maxSd: 1.736754e-09 - maxProbs: 0.001757403
   user  system elapsed 
  12.07    0.00   12.07 
> 
> cl <- makeCluster(2)
> system.time({set.seed(11111)
+ res3 <- CEoptim(f = sumsqrs,
+                 f.arg = list(xt),
+                 continuous = list(mean = c(0, 0,0),
+                                   sd = rep(1, 0,3),
+                                   conMat = A,
+                                   conVec = b),
+                 discrete = list(categories = c(298L, 298L),
+                                 smoothProb = 0.5),
+                 N = 10000,
+                 rho = 0.001,
+                 verbose = TRUE,
+                 parallelize = TRUE,
+                 cl = cl)})
Number of continuous variables: 3  
Number of discrete variables: 2 
conMat= 
     [,1] [,2] [,3]
[1,]    1    0    0
[2,]    0    1    0
[3,]    0    0    1
[4,]   -1    0    0
[5,]    0   -1    0
[6,]    0    0   -1
conVec= 
[1] 1 1 1 1 1 1
smoothMean: 1 smoothSd: 1 smoothProb: 0.5 
N: 10000 rho: 0.001 iterThr: 10000 sdThr: 0.001 probThr 0.001 
Sun Oct 15 2017 05:26:22 PM t: 05s496ms - iter: 00000 - opt: 3.009517 - maxSd: 0.3248419 - maxProbs: 0.9483221
Sun Oct 15 2017 05:26:25 PM t: 02s019ms - iter: 00001 - opt: 2.70702 - maxSd: 0.07449603 - maxProbs: 0.7741611
Sun Oct 15 2017 05:26:27 PM t: 02s975ms - iter: 00002 - opt: 2.688896 - maxSd: 0.04549593 - maxProbs: 0.7495805
Sun Oct 15 2017 05:26:29 PM t: 01s796ms - iter: 00003 - opt: 2.677602 - maxSd: 0.03024808 - maxProbs: 0.6247903
Sun Oct 15 2017 05:26:32 PM t: 02s832ms - iter: 00004 - opt: 2.675769 - maxSd: 0.006000473 - maxProbs: 0.4498951
Sun Oct 15 2017 05:26:34 PM t: 01s951ms - iter: 00005 - opt: 2.675727 - maxSd: 0.000613875 - maxProbs: 0.2249476
Sun Oct 15 2017 05:26:37 PM t: 02s909ms - iter: 00006 - opt: 2.675727 - maxSd: 7.4365e-05 - maxProbs: 0.1124738
Sun Oct 15 2017 05:26:39 PM t: 01s948ms - iter: 00007 - opt: 2.675727 - maxSd: 4.23201e-06 - maxProbs: 0.05623689
Sun Oct 15 2017 05:26:42 PM t: 02s916ms - iter: 00008 - opt: 2.675727 - maxSd: 4.225456e-07 - maxProbs: 0.02811845
Sun Oct 15 2017 05:26:44 PM t: 02s807ms - iter: 00009 - opt: 2.675727 - maxSd: 3.376241e-08 - maxProbs: 0.01405922
Sun Oct 15 2017 05:26:47 PM t: 01s977ms - iter: 00010 - opt: 2.675727 - maxSd: 7.751173e-09 - maxProbs: 0.007029611
Sun Oct 15 2017 05:26:49 PM t: 02s680ms - iter: 00011 - opt: 2.675727 - maxSd: 2.775761e-09 - maxProbs: 0.003514806
Sun Oct 15 2017 05:26:52 PM t: 02s009ms - iter: 00012 - opt: 2.675727 - maxSd: 1.736754e-09 - maxProbs: 0.001757403
   user  system elapsed 
  21.30    6.25   37.12 
> stopCluster(cl)
> closeAllConnections()
> 
> all.equal(res1$optimum, res2$optimum)
[1] TRUE
> all.equal(res1$optimum, res3$optimum)
[1] TRUE
```