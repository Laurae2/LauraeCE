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
- [x] ~~add hot loading (use previous optimization)~~ (this one was stupid because one could just use the previous mean/sd/probs)
- [ ] add interrupt on the fly while saving data (tcltk?)
- [x] add maximum computation time before cancelling (while returning cleanly)

# Example

This is how it currently looks and you will notice it is absurdly SLOW on very small tasks:

```r
> suppressMessages(library(LauraeCE))
> suppressMessages(library(parallel))
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
> system.time({
+   set.seed(11111)
+   res1 <- CEoptim::CEoptim(fun,
+                            continuous = list(mean = mu0,
+                                              sd = sigma0),
+                            maximize = TRUE)
+ })
   user  system elapsed 
   0.03    0.00    0.03 
> 
> system.time({
+   set.seed(11111)
+   res2 <- CEoptim(fun,
+                   continuous = list(mean = mu0,
+                                     sd = sigma0),
+                   maximize = TRUE)
+ })
   user  system elapsed 
   0.42    0.00    0.44 
> 
> cl <- makeCluster(2)
> system.time({
+   set.seed(11111)
+   res3 <- CEoptim(fun,
+                   continuous = list(mean = mu0,
+                                     sd = sigma0),
+                   maximize = TRUE,
+                   parallelize = TRUE,
+                   cl = cl)
+ })
   user  system elapsed 
   0.09    0.02    0.14 
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
> system.time({
+   set.seed(11111)
+   res1 <- CEoptim::CEoptim(fmaxcut,
+                            f.arg = list(costs = lesmis),
+                            maximize = TRUE,
+                            verbose = TRUE,
+                            discrete = list(probs = p0),
+                            N = 3000L)
+ })
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
   2.40    0.00    2.41 
> 
> system.time({
+   set.seed(11111)
+   res2 <- CEoptim(fmaxcut,
+                   f.arg = list(costs = lesmis),
+                   maximize = TRUE,
+                   verbose = TRUE,
+                   discrete = list(probs = p0),
+                   N = 3000L)
+ })
Number of continuous variables: 0  
Number of discrete variables: 77 
conMat= 
NULL
conVec= 
NULL
smoothMean: 1 smoothSd: 1 smoothProb: 1 
N: 3000 rho: 0.1 iterThr: 10000 sdThr: 0.001 probThr 0.001 
Sat Dec 23 2017 02:36:45 PM - iter: 00001 (00s082ms, 36287.07 samples/s) - opt: 494 - maxProbs: 0.5
Sat Dec 23 2017 02:36:45 PM - iter: 00002 (00s066ms, 44985.61 samples/s) - opt: 501 - maxProbs: 0.5
Sat Dec 23 2017 02:36:45 PM - iter: 00003 (00s073ms, 40941.17 samples/s) - opt: 501 - maxProbs: 0.5
Sat Dec 23 2017 02:36:46 PM - iter: 00004 (00s068ms, 43923.99 samples/s) - opt: 501 - maxProbs: 0.4966667
Sat Dec 23 2017 02:36:46 PM - iter: 00005 (00s076ms, 39105.11 samples/s) - opt: 506 - maxProbs: 0.5
Sat Dec 23 2017 02:36:46 PM - iter: 00006 (00s143ms, 20878.71 samples/s) - opt: 510 - maxProbs: 0.5
Sat Dec 23 2017 02:36:46 PM - iter: 00007 (00s065ms, 45805.62 samples/s) - opt: 514 - maxProbs: 0.5
Sat Dec 23 2017 02:36:46 PM - iter: 00008 (00s070ms, 42742.95 samples/s) - opt: 515 - maxProbs: 0.5
Sat Dec 23 2017 02:36:46 PM - iter: 00009 (00s076ms, 39368.59 samples/s) - opt: 519 - maxProbs: 0.4966667
Sat Dec 23 2017 02:36:46 PM - iter: 00010 (00s081ms, 36701.63 samples/s) - opt: 523 - maxProbs: 0.4933333
Sat Dec 23 2017 02:36:46 PM - iter: 00011 (00s068ms, 43615.30 samples/s) - opt: 526 - maxProbs: 0.4966667
Sat Dec 23 2017 02:36:46 PM - iter: 00012 (00s086ms, 34672.88 samples/s) - opt: 528 - maxProbs: 0.4933333
Sat Dec 23 2017 02:36:47 PM - iter: 00013 (00s170ms, 17563.39 samples/s) - opt: 528 - maxProbs: 0.4866667
Sat Dec 23 2017 02:36:47 PM - iter: 00014 (00s060ms, 49344.64 samples/s) - opt: 530 - maxProbs: 0.4966667
Sat Dec 23 2017 02:36:47 PM - iter: 00015 (00s065ms, 45481.46 samples/s) - opt: 532 - maxProbs: 0.49
Sat Dec 23 2017 02:36:47 PM - iter: 00016 (00s157ms, 19045.67 samples/s) - opt: 532 - maxProbs: 0.4733333
Sat Dec 23 2017 02:36:47 PM - iter: 00017 (00s079ms, 37972.81 samples/s) - opt: 532 - maxProbs: 0.4533333
Sat Dec 23 2017 02:36:47 PM - iter: 00018 (00s069ms, 42964.58 samples/s) - opt: 533 - maxProbs: 0.49
Sat Dec 23 2017 02:36:47 PM - iter: 00019 (00s072ms, 41309.76 samples/s) - opt: 533 - maxProbs: 0.4533333
Sat Dec 23 2017 02:36:47 PM - iter: 00020 (00s066ms, 45445.80 samples/s) - opt: 533 - maxProbs: 0.5
Sat Dec 23 2017 02:36:47 PM - iter: 00021 (00s081ms, 36698.12 samples/s) - opt: 533 - maxProbs: 0.4366667
Sat Dec 23 2017 02:36:48 PM - iter: 00022 (00s065ms, 45617.55 samples/s) - opt: 533 - maxProbs: 0.3766667
Sat Dec 23 2017 02:36:48 PM - iter: 00023 (00s072ms, 41595.58 samples/s) - opt: 533 - maxProbs: 0.3633333
Sat Dec 23 2017 02:36:48 PM - iter: 00024 (00s128ms, 23352.47 samples/s) - opt: 533 - maxProbs: 0.3466667
   user  system elapsed 
   2.77    0.01    2.77 
> 
> cl <- makeCluster(2)
> system.time({
+   set.seed(11111)
+   res3 <- CEoptim(fmaxcut,
+                   f.arg = list(costs = lesmis),
+                   maximize = TRUE,
+                   verbose = TRUE,
+                   discrete = list(probs = p0),
+                   N = 3000L,
+                   parallelize = TRUE,
+                   cl = cl)
+ })
Number of continuous variables: 0  
Number of discrete variables: 77 
conMat= 
NULL
conVec= 
NULL
smoothMean: 1 smoothSd: 1 smoothProb: 1 
N: 3000 rho: 0.1 iterThr: 10000 sdThr: 0.001 probThr 0.001 
Sat Dec 23 2017 02:36:50 PM - iter: 00001 (02s014ms, 1489.11 samples/s, 744.55 s/s/thread) - opt: 494 - maxProbs: 0.5
Sat Dec 23 2017 02:36:51 PM - iter: 00002 (00s682ms, 4395.58 samples/s, 2197.79 s/s/thread) - opt: 501 - maxProbs: 0.5
Sat Dec 23 2017 02:36:52 PM - iter: 00003 (01s691ms, 1773.06 samples/s, 886.53 s/s/thread) - opt: 501 - maxProbs: 0.5
Sat Dec 23 2017 02:36:54 PM - iter: 00004 (00s440ms, 6811.68 samples/s, 3405.84 s/s/thread) - opt: 501 - maxProbs: 0.4966667
Sat Dec 23 2017 02:36:55 PM - iter: 00005 (01s532ms, 1957.99 samples/s, 978.99 s/s/thread) - opt: 506 - maxProbs: 0.5
Sat Dec 23 2017 02:36:56 PM - iter: 00006 (01s619ms, 1852.11 samples/s, 926.05 s/s/thread) - opt: 510 - maxProbs: 0.5
Sat Dec 23 2017 02:36:57 PM - iter: 00007 (00s571ms, 5247.09 samples/s, 2623.54 s/s/thread) - opt: 514 - maxProbs: 0.5
Sat Dec 23 2017 02:36:59 PM - iter: 00008 (01s551ms, 1933.35 samples/s, 966.68 s/s/thread) - opt: 515 - maxProbs: 0.5
Sat Dec 23 2017 02:37:00 PM - iter: 00009 (01s431ms, 2095.47 samples/s, 1047.74 s/s/thread) - opt: 519 - maxProbs: 0.4966667
Sat Dec 23 2017 02:37:01 PM - iter: 00010 (00s544ms, 5514.17 samples/s, 2757.08 s/s/thread) - opt: 523 - maxProbs: 0.4933333
Sat Dec 23 2017 02:37:02 PM - iter: 00011 (01s449ms, 2070.38 samples/s, 1035.19 s/s/thread) - opt: 526 - maxProbs: 0.4966667
Sat Dec 23 2017 02:37:03 PM - iter: 00012 (01s438ms, 2085.91 samples/s, 1042.95 s/s/thread) - opt: 528 - maxProbs: 0.4933333
Sat Dec 23 2017 02:37:05 PM - iter: 00013 (00s497ms, 6034.04 samples/s, 3017.02 s/s/thread) - opt: 528 - maxProbs: 0.4866667
Sat Dec 23 2017 02:37:06 PM - iter: 00014 (01s495ms, 2006.57 samples/s, 1003.29 s/s/thread) - opt: 530 - maxProbs: 0.4966667
Sat Dec 23 2017 02:37:07 PM - iter: 00015 (01s589ms, 1887.85 samples/s, 943.93 s/s/thread) - opt: 532 - maxProbs: 0.49
Sat Dec 23 2017 02:37:08 PM - iter: 00016 (01s465ms, 2047.09 samples/s, 1023.55 s/s/thread) - opt: 532 - maxProbs: 0.4733333
Sat Dec 23 2017 02:37:10 PM - iter: 00017 (00s530ms, 5649.94 samples/s, 2824.97 s/s/thread) - opt: 532 - maxProbs: 0.4533333
Sat Dec 23 2017 02:37:11 PM - iter: 00018 (01s609ms, 1863.66 samples/s, 931.83 s/s/thread) - opt: 533 - maxProbs: 0.49
Sat Dec 23 2017 02:37:12 PM - iter: 00019 (01s451ms, 2066.34 samples/s, 1033.17 s/s/thread) - opt: 533 - maxProbs: 0.4533333
Sat Dec 23 2017 02:37:13 PM - iter: 00020 (00s557ms, 5377.65 samples/s, 2688.83 s/s/thread) - opt: 533 - maxProbs: 0.5
Sat Dec 23 2017 02:37:15 PM - iter: 00021 (01s630ms, 1839.57 samples/s, 919.78 s/s/thread) - opt: 533 - maxProbs: 0.4366667
Sat Dec 23 2017 02:37:16 PM - iter: 00022 (01s564ms, 1917.31 samples/s, 958.66 s/s/thread) - opt: 533 - maxProbs: 0.3766667
Sat Dec 23 2017 02:37:17 PM - iter: 00023 (01s426ms, 2103.27 samples/s, 1051.64 s/s/thread) - opt: 533 - maxProbs: 0.3633333
Sat Dec 23 2017 02:37:19 PM - iter: 00024 (00s485ms, 6179.45 samples/s, 3089.73 s/s/thread) - opt: 533 - maxProbs: 0.3466667
   user  system elapsed 
  17.10    7.63   30.55 
> stopCluster(cl)
> closeAllConnections()
> 
> all.equal(res1$optimizer$discrete, res2$optimizer$discrete)
[1] TRUE
> all.equal(res1$optimizer$discrete, res3$optimizer$discrete)
[1] TRUE
> 
> cl <- makeCluster(2)
> system.time({
+   set.seed(11111)
+   res3 <- CEoptim(fmaxcut,
+                   f.arg = list(costs = lesmis),
+                   maximize = TRUE,
+                   verbose = TRUE,
+                   discrete = list(probs = p0),
+                   N = 3000L,
+                   max_time = 15,
+                   parallelize = TRUE,
+                   cl = cl)
+ })
Number of continuous variables: 0  
Number of discrete variables: 77 
conMat= 
NULL
conVec= 
NULL
smoothMean: 1 smoothSd: 1 smoothProb: 1 
N: 3000 rho: 0.1 iterThr: 10000 sdThr: 0.001 probThr 0.001 
Sat Dec 23 2017 02:37:21 PM - iter: 00001 (01s909ms, 1571.21 samples/s, 785.61 s/s/thread) - opt: 494 - maxProbs: 0.5
Sat Dec 23 2017 02:37:22 PM - iter: 00002 (01s501ms, 1998.43 samples/s, 999.21 s/s/thread) - opt: 501 - maxProbs: 0.5
Sat Dec 23 2017 02:37:23 PM - iter: 00003 (00s451ms, 6644.30 samples/s, 3322.15 s/s/thread) - opt: 501 - maxProbs: 0.5
Sat Dec 23 2017 02:37:24 PM - iter: 00004 (01s539ms, 1949.02 samples/s, 974.51 s/s/thread) - opt: 501 - maxProbs: 0.4966667
Sat Dec 23 2017 02:37:26 PM - iter: 00005 (01s617ms, 1854.80 samples/s, 927.40 s/s/thread) - opt: 506 - maxProbs: 0.5
Sat Dec 23 2017 02:37:27 PM - iter: 00006 (00s426ms, 7027.42 samples/s, 3513.71 s/s/thread) - opt: 510 - maxProbs: 0.5
Sat Dec 23 2017 02:37:28 PM - iter: 00007 (01s526ms, 1965.72 samples/s, 982.86 s/s/thread) - opt: 514 - maxProbs: 0.5
Sat Dec 23 2017 02:37:29 PM - iter: 00008 (01s603ms, 1870.60 samples/s, 935.30 s/s/thread) - opt: 515 - maxProbs: 0.5
Sat Dec 23 2017 02:37:31 PM - iter: 00009 (00s483ms, 6203.28 samples/s, 3101.64 s/s/thread) - opt: 519 - maxProbs: 0.4966667
Sat Dec 23 2017 02:37:32 PM - iter: 00010 (01s520ms, 1973.57 samples/s, 986.79 s/s/thread) - opt: 523 - maxProbs: 0.4933333
Sat Dec 23 2017 02:37:33 PM - iter: 00011 (01s528ms, 1962.99 samples/s, 981.50 s/s/thread) - opt: 526 - maxProbs: 0.4966667
Sat Dec 23 2017 02:37:34 PM - iter: 00012 (00s511ms, 5869.28 samples/s, 2934.64 s/s/thread) - opt: 528 - maxProbs: 0.4933333
Sat Dec 23 2017 02:37:36 PM - iter: 00013 (01s484ms, 2021.28 samples/s, 1010.64 s/s/thread) - opt: 528 - maxProbs: 0.4866667
   user  system elapsed 
   8.96    4.17   16.38 
> stopCluster(cl)
> closeAllConnections()
> all.equal(res1$optimizer$discrete, res3$optimizer$discrete)
[1] "Mean relative difference: 1.8"
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
> system.time({
+   set.seed(11111)
+   res1 <- CEoptim::CEoptim(f = sumsqrs,
+                            f.arg = list(xt),
+                            continuous = list(mean = c(0, 0,0),
+                                              sd = rep(1, 0,3),
+                                              conMat = A,
+                                              conVec = b),
+                            discrete = list(categories = c(298L, 298L),
+                                            smoothProb = 0.5),
+                            N = 10000,
+                            rho = 0.001,
+                            verbose = TRUE)
+ })
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
   9.06    0.02    9.10 
> 
> system.time({
+   set.seed(11111)
+   res2 <- CEoptim(f = sumsqrs,
+                   f.arg = list(xt),
+                   continuous = list(mean = c(0, 0,0),
+                                     sd = rep(1, 0,3),
+                                     conMat = A,
+                                     conVec = b),
+                   discrete = list(categories = c(298L, 298L),
+                                   smoothProb = 0.5),
+                   N = 10000,
+                   rho = 0.001,
+                   verbose = TRUE)
+ })
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
Sat Dec 23 2017 02:37:45 PM - iter: 00001 (00s578ms, 17290.24 samples/s) - opt: 3.009517 - maxSd: 0.3248419 - maxProbs: 0.9483221
Sat Dec 23 2017 02:37:46 PM - iter: 00002 (00s605ms, 16510.56 samples/s) - opt: 2.70702 - maxSd: 0.07449603 - maxProbs: 0.7741611
Sat Dec 23 2017 02:37:47 PM - iter: 00003 (00s644ms, 15522.24 samples/s) - opt: 2.688896 - maxSd: 0.04549593 - maxProbs: 0.7495805
Sat Dec 23 2017 02:37:47 PM - iter: 00004 (00s559ms, 17870.68 samples/s) - opt: 2.677602 - maxSd: 0.03024808 - maxProbs: 0.6247903
Sat Dec 23 2017 02:37:48 PM - iter: 00005 (00s564ms, 17700.87 samples/s) - opt: 2.675769 - maxSd: 0.006000473 - maxProbs: 0.4498951
Sat Dec 23 2017 02:37:49 PM - iter: 00006 (00s611ms, 16348.60 samples/s) - opt: 2.675727 - maxSd: 0.000613875 - maxProbs: 0.2249476
Sat Dec 23 2017 02:37:49 PM - iter: 00007 (00s651ms, 15338.11 samples/s) - opt: 2.675727 - maxSd: 7.4365e-05 - maxProbs: 0.1124738
Sat Dec 23 2017 02:37:50 PM - iter: 00008 (00s660ms, 15143.02 samples/s) - opt: 2.675727 - maxSd: 4.23201e-06 - maxProbs: 0.05623689
Sat Dec 23 2017 02:37:51 PM - iter: 00009 (00s575ms, 17381.87 samples/s) - opt: 2.675727 - maxSd: 4.225456e-07 - maxProbs: 0.02811845
Sat Dec 23 2017 02:37:51 PM - iter: 00010 (00s572ms, 17476.10 samples/s) - opt: 2.675727 - maxSd: 3.376241e-08 - maxProbs: 0.01405922
Sat Dec 23 2017 02:37:52 PM - iter: 00011 (00s654ms, 15274.31 samples/s) - opt: 2.675727 - maxSd: 7.751173e-09 - maxProbs: 0.007029611
Sat Dec 23 2017 02:37:53 PM - iter: 00012 (00s644ms, 15524.89 samples/s) - opt: 2.675727 - maxSd: 2.775761e-09 - maxProbs: 0.003514806
Sat Dec 23 2017 02:37:53 PM - iter: 00013 (00s669ms, 14946.07 samples/s) - opt: 2.675727 - maxSd: 1.736754e-09 - maxProbs: 0.001757403
Sat Dec 23 2017 02:37:54 PM - iter: 00014 (00s732ms, 13657.75 samples/s) - opt: 2.675727 - maxSd: 1.219703e-09 - maxProbs: 0.0008787014
   user  system elapsed 
   9.09    0.00    9.09 
> 
> cl <- makeCluster(2)
> system.time({
+   set.seed(11111)
+   res3 <- CEoptim(f = sumsqrs,
+                   f.arg = list(xt),
+                   continuous = list(mean = c(0, 0,0),
+                                     sd = rep(1, 0,3),
+                                     conMat = A,
+                                     conVec = b),
+                   discrete = list(categories = c(298L, 298L),
+                                   smoothProb = 0.5),
+                   N = 10000,
+                   rho = 0.001,
+                   verbose = TRUE,
+                   parallelize = TRUE,
+                   cl = cl)
+ })
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
Sat Dec 23 2017 02:37:57 PM - iter: 00001 (02s695ms, 3710.54 samples/s, 1855.27 s/s/thread) - opt: 3.009517 - maxSd: 0.3248419 - maxProbs: 0.9483221
Sat Dec 23 2017 02:37:59 PM - iter: 00002 (01s692ms, 5907.40 samples/s, 2953.70 s/s/thread) - opt: 2.70702 - maxSd: 0.07449603 - maxProbs: 0.7741611
Sat Dec 23 2017 02:38:01 PM - iter: 00003 (02s838ms, 3522.83 samples/s, 1761.42 s/s/thread) - opt: 2.688896 - maxSd: 0.04549593 - maxProbs: 0.7495805
Sat Dec 23 2017 02:38:04 PM - iter: 00004 (01s740ms, 5745.79 samples/s, 2872.89 s/s/thread) - opt: 2.677602 - maxSd: 0.03024808 - maxProbs: 0.6247903
Sat Dec 23 2017 02:38:06 PM - iter: 00005 (02s531ms, 3950.54 samples/s, 1975.27 s/s/thread) - opt: 2.675769 - maxSd: 0.006000473 - maxProbs: 0.4498951
Sat Dec 23 2017 02:38:08 PM - iter: 00006 (02s708ms, 3691.60 samples/s, 1845.80 s/s/thread) - opt: 2.675727 - maxSd: 0.000613875 - maxProbs: 0.2249476
Sat Dec 23 2017 02:38:10 PM - iter: 00007 (01s610ms, 6210.28 samples/s, 3105.14 s/s/thread) - opt: 2.675727 - maxSd: 7.4365e-05 - maxProbs: 0.1124738
Sat Dec 23 2017 02:38:13 PM - iter: 00008 (02s847ms, 3511.41 samples/s, 1755.71 s/s/thread) - opt: 2.675727 - maxSd: 4.23201e-06 - maxProbs: 0.05623689
Sat Dec 23 2017 02:38:15 PM - iter: 00009 (01s692ms, 5908.85 samples/s, 2954.42 s/s/thread) - opt: 2.675727 - maxSd: 4.225456e-07 - maxProbs: 0.02811845
Sat Dec 23 2017 02:38:18 PM - iter: 00010 (02s934ms, 3407.62 samples/s, 1703.81 s/s/thread) - opt: 2.675727 - maxSd: 3.376241e-08 - maxProbs: 0.01405922
Sat Dec 23 2017 02:38:20 PM - iter: 00011 (02s522ms, 3965.07 samples/s, 1982.53 s/s/thread) - opt: 2.675727 - maxSd: 7.751173e-09 - maxProbs: 0.007029611
Sat Dec 23 2017 02:38:22 PM - iter: 00012 (01s564ms, 6390.96 samples/s, 3195.48 s/s/thread) - opt: 2.675727 - maxSd: 2.775761e-09 - maxProbs: 0.003514806
Sat Dec 23 2017 02:38:24 PM - iter: 00013 (02s707ms, 3693.70 samples/s, 1846.85 s/s/thread) - opt: 2.675727 - maxSd: 1.736754e-09 - maxProbs: 0.001757403
Sat Dec 23 2017 02:38:26 PM - iter: 00014 (01s462ms, 6838.37 samples/s, 3419.18 s/s/thread) - opt: 2.675727 - maxSd: 1.219703e-09 - maxProbs: 0.0008787014
   user  system elapsed 
  20.54    5.69   32.11 
> stopCluster(cl)
> closeAllConnections()
> 
> all.equal(res1$optimum, res2$optimum)
[1] TRUE
> all.equal(res1$optimum, res3$optimum)
[1] TRUE
```