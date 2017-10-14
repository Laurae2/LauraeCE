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
- ~~[ ] allow progress bar backend parameter~~
- [ ] add sink results to file parameter
- [ ] add hot loading (use previous optimization)
- [ ] add interrupt on the fly while saving data (tcltk?)

# Example

This is how it currently looks:

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

Loading required package: pbapply
Warning message:
package ‘pbapply’ was built under R version 3.4.1 
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
> set.seed(11111)
> res1 <- CEoptim::CEoptim(fun, continuous = list(mean = mu0, sd = sigma0), maximize = TRUE)
> 
> set.seed(11111)
> res2 <- CEoptim(fun, continuous = list(mean = mu0, sd = sigma0), maximize = TRUE)
> 
> cl <- makeCluster(2)
> set.seed(11111)
> res3 <- CEoptim(fun, continuous = list(mean = mu0, sd = sigma0), maximize = TRUE, parallelize = TRUE, cl = cl)
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
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
> set.seed(11111)
> res1 <- CEoptim::CEoptim(fmaxcut, f.arg = list(costs = lesmis), maximize = T, verbose = TRUE, discrete = list(probs = p0), N = 3000L)
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
> 
> set.seed(11111)
> res2 <- CEoptim(fmaxcut, f.arg = list(costs = lesmis), maximize = T, verbose = TRUE, discrete = list(probs = p0), N = 3000L)
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
> 
> cl <- makeCluster(2)
> set.seed(11111)
> res3 <- CEoptim(fmaxcut, f.arg = list(costs = lesmis), maximize = T, verbose = TRUE, discrete = list(probs = p0), N = 3000L, parallelize = TRUE, cl = cl)
Number of continuous variables: 0  
Number of discrete variables: 77 
conMat= 
NULL
conVec= 
NULL
smoothMean: 1 smoothSd: 1 smoothProb: 1 
N: 3000 rho: 0.1 iterThr: 10000 sdThr: 0.001 probThr 0.001 
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
iter: 0  opt: 494 maxProbs: 0.5
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
iter: 1  opt: 501 maxProbs: 0.5
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
iter: 2  opt: 501 maxProbs: 0.5
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
iter: 3  opt: 501 maxProbs: 0.4966667
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
iter: 4  opt: 506 maxProbs: 0.5
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
iter: 5  opt: 510 maxProbs: 0.5
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
iter: 6  opt: 514 maxProbs: 0.5
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
iter: 7  opt: 515 maxProbs: 0.5
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
iter: 8  opt: 519 maxProbs: 0.4966667
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
iter: 9  opt: 523 maxProbs: 0.4933333
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
iter: 10  opt: 526 maxProbs: 0.4966667
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
iter: 11  opt: 528 maxProbs: 0.4933333
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
iter: 12  opt: 528 maxProbs: 0.4866667
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
iter: 13  opt: 530 maxProbs: 0.4966667
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
iter: 14  opt: 532 maxProbs: 0.49
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
iter: 15  opt: 532 maxProbs: 0.4733333
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
iter: 16  opt: 532 maxProbs: 0.4533333
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
iter: 17  opt: 533 maxProbs: 0.49
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
iter: 18  opt: 533 maxProbs: 0.4533333
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
iter: 19  opt: 533 maxProbs: 0.5
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
iter: 20  opt: 533 maxProbs: 0.4366667
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
iter: 21  opt: 533 maxProbs: 0.3766667
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
iter: 22  opt: 533 maxProbs: 0.3633333
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 00s
> stopCluster(cl)
> closeAllConnections()
> 
> all.equal(res1$optimizer$discrete, res2$optimizer$discrete)
[1] TRUE
> all.equal(res1$optimizer$discrete, res3$optimizer$discrete)
[1] TRUE
> 
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
> set.seed(11111)
> res1 <- CEoptim::CEoptim(f = sumsqrs,
+                          f.arg = list(xt),
+                          continuous = list(mean = c(0, 0,0),
+                                            sd = rep(1, 0,3),
+                                            conMat = A,
+                                            conVec = b),
+                          discrete = list(categories = c(298L, 298L),
+                                          smoothProb = 0.5),
+                          N = 10000,
+                          rho = 0.001,
+                          verbose = TRUE)
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
> 
> set.seed(11111)
> res2 <- CEoptim(f = sumsqrs,
+                 f.arg = list(xt),
+                 continuous = list(mean = c(0, 0,0),
+                                   sd = rep(1, 0,3),
+                                   conMat = A,
+                                   conVec = b),
+                 discrete = list(categories = c(298L, 298L),
+                                 smoothProb = 0.5),
+                 N = 10000,
+                 rho = 0.001,
+                 verbose = TRUE)
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
> 
> cl <- makeCluster(2)
> set.seed(11111)
> res3 <- CEoptim(f = sumsqrs,
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
+                 cl = cl)
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
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 01s
iter: 0  opt: 3.009517 maxSd: 0.3248419 maxProbs: 0.9483221
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 01s
iter: 1  opt: 2.70702 maxSd: 0.07449603 maxProbs: 0.7741611
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 01s
iter: 2  opt: 2.688896 maxSd: 0.04549593 maxProbs: 0.7495805
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 01s
iter: 3  opt: 2.677602 maxSd: 0.03024808 maxProbs: 0.6247903
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 01s
iter: 4  opt: 2.675769 maxSd: 0.006000473 maxProbs: 0.4498951
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 01s
iter: 5  opt: 2.675727 maxSd: 0.000613875 maxProbs: 0.2249476
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 01s
iter: 6  opt: 2.675727 maxSd: 7.4365e-05 maxProbs: 0.1124738
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 02s
iter: 7  opt: 2.675727 maxSd: 4.23201e-06 maxProbs: 0.05623689
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 01s
iter: 8  opt: 2.675727 maxSd: 4.225456e-07 maxProbs: 0.02811845
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 01s
iter: 9  opt: 2.675727 maxSd: 3.376241e-08 maxProbs: 0.01405922
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 01s
iter: 10  opt: 2.675727 maxSd: 7.751173e-09 maxProbs: 0.007029611
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 01s
iter: 11  opt: 2.675727 maxSd: 2.775761e-09 maxProbs: 0.003514806
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 01s
iter: 12  opt: 2.675727 maxSd: 1.736754e-09 maxProbs: 0.001757403
   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed = 01s
> stopCluster(cl)
> closeAllConnections()
> 
> all.equal(res1$optimum, res2$optimum)
[1] TRUE
> all.equal(res1$optimum, res3$optimum)
[1] TRUE
```