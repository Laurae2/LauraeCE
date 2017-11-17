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
   0.09    0.00    0.10 
> 
> system.time({
+   set.seed(11111)
+   res2 <- CEoptim(fun,
+                   continuous = list(mean = mu0,
+                                     sd = sigma0),
+                   maximize = TRUE)
+ })
   user  system elapsed 
   0.09    0.00    0.10 
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
   0.34    0.02    1.36 
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
   2.80    0.00    2.81 
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
Fri Nov 17 2017 08:52:31 PM - iter: 00001 (00s063ms, 47592.49 samples/s) - opt: 494 - maxProbs: 0.5
Fri Nov 17 2017 08:52:31 PM - iter: 00002 (00s080ms, 37047.98 samples/s) - opt: 501 - maxProbs: 0.5
Fri Nov 17 2017 08:52:31 PM - iter: 00003 (00s072ms, 41604.88 samples/s) - opt: 501 - maxProbs: 0.5
Fri Nov 17 2017 08:52:31 PM - iter: 00004 (00s089ms, 33704.44 samples/s) - opt: 501 - maxProbs: 0.4966667
Fri Nov 17 2017 08:52:32 PM - iter: 00005 (00s087ms, 34308.88 samples/s) - opt: 506 - maxProbs: 0.5
Fri Nov 17 2017 08:52:32 PM - iter: 00006 (00s076ms, 39087.45 samples/s) - opt: 510 - maxProbs: 0.5
Fri Nov 17 2017 08:52:32 PM - iter: 00007 (00s099ms, 30264.22 samples/s) - opt: 514 - maxProbs: 0.5
Fri Nov 17 2017 08:52:32 PM - iter: 00008 (00s100ms, 29927.96 samples/s) - opt: 515 - maxProbs: 0.5
Fri Nov 17 2017 08:52:32 PM - iter: 00009 (00s082ms, 36370.31 samples/s) - opt: 519 - maxProbs: 0.4966667
Fri Nov 17 2017 08:52:32 PM - iter: 00010 (00s114ms, 26217.81 samples/s) - opt: 523 - maxProbs: 0.4933333
Fri Nov 17 2017 08:52:32 PM - iter: 00011 (00s173ms, 17267.98 samples/s) - opt: 526 - maxProbs: 0.4966667
Fri Nov 17 2017 08:52:32 PM - iter: 00012 (00s065ms, 45560.72 samples/s) - opt: 528 - maxProbs: 0.4933333
Fri Nov 17 2017 08:52:33 PM - iter: 00013 (00s077ms, 38496.48 samples/s) - opt: 528 - maxProbs: 0.4866667
Fri Nov 17 2017 08:52:33 PM - iter: 00014 (00s082ms, 36347.39 samples/s) - opt: 530 - maxProbs: 0.4966667
Fri Nov 17 2017 08:52:33 PM - iter: 00015 (00s086ms, 34807.63 samples/s) - opt: 532 - maxProbs: 0.49
Fri Nov 17 2017 08:52:33 PM - iter: 00016 (00s166ms, 18057.39 samples/s) - opt: 532 - maxProbs: 0.4733333
Fri Nov 17 2017 08:52:33 PM - iter: 00017 (00s066ms, 45055.22 samples/s) - opt: 532 - maxProbs: 0.4533333
Fri Nov 17 2017 08:52:33 PM - iter: 00018 (00s090ms, 33115.76 samples/s) - opt: 533 - maxProbs: 0.49
Fri Nov 17 2017 08:52:33 PM - iter: 00019 (00s068ms, 44050.27 samples/s) - opt: 533 - maxProbs: 0.4533333
Fri Nov 17 2017 08:52:33 PM - iter: 00020 (00s073ms, 40817.41 samples/s) - opt: 533 - maxProbs: 0.5
Fri Nov 17 2017 08:52:34 PM - iter: 00021 (00s081ms, 36711.61 samples/s) - opt: 533 - maxProbs: 0.4366667
Fri Nov 17 2017 08:52:34 PM - iter: 00022 (00s071ms, 42021.61 samples/s) - opt: 533 - maxProbs: 0.3766667
Fri Nov 17 2017 08:52:34 PM - iter: 00023 (00s082ms, 36292.86 samples/s) - opt: 533 - maxProbs: 0.3633333
Fri Nov 17 2017 08:52:34 PM - iter: 00024 (00s085ms, 35009.94 samples/s) - opt: 533 - maxProbs: 0.3466667
   user  system elapsed 
   2.97    0.00    2.92 
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
Fri Nov 17 2017 08:52:38 PM - iter: 00001 (04s335ms, 691.93 samples/s, 345.96 s/s/thread) - opt: 494 - maxProbs: 0.5
Fri Nov 17 2017 08:52:40 PM - iter: 00002 (00s535ms, 5606.58 samples/s, 2803.29 s/s/thread) - opt: 501 - maxProbs: 0.5
Fri Nov 17 2017 08:52:41 PM - iter: 00003 (01s568ms, 1913.22 samples/s, 956.61 s/s/thread) - opt: 501 - maxProbs: 0.5
Fri Nov 17 2017 08:52:42 PM - iter: 00004 (01s446ms, 2073.43 samples/s, 1036.71 s/s/thread) - opt: 501 - maxProbs: 0.4966667
Fri Nov 17 2017 08:52:43 PM - iter: 00005 (00s631ms, 4750.56 samples/s, 2375.28 s/s/thread) - opt: 506 - maxProbs: 0.5
Fri Nov 17 2017 08:52:44 PM - iter: 00006 (01s468ms, 2042.84 samples/s, 1021.42 s/s/thread) - opt: 510 - maxProbs: 0.5
Fri Nov 17 2017 08:52:46 PM - iter: 00007 (00s596ms, 5027.46 samples/s, 2513.73 s/s/thread) - opt: 514 - maxProbs: 0.5
Fri Nov 17 2017 08:52:47 PM - iter: 00008 (01s551ms, 1934.02 samples/s, 967.01 s/s/thread) - opt: 515 - maxProbs: 0.5
Fri Nov 17 2017 08:52:48 PM - iter: 00009 (01s401ms, 2139.99 samples/s, 1069.99 s/s/thread) - opt: 519 - maxProbs: 0.4966667
Fri Nov 17 2017 08:52:49 PM - iter: 00010 (01s475ms, 2032.73 samples/s, 1016.36 s/s/thread) - opt: 523 - maxProbs: 0.4933333
Fri Nov 17 2017 08:52:50 PM - iter: 00011 (00s504ms, 5941.48 samples/s, 2970.74 s/s/thread) - opt: 526 - maxProbs: 0.4966667
Fri Nov 17 2017 08:52:52 PM - iter: 00012 (01s626ms, 1844.98 samples/s, 922.49 s/s/thread) - opt: 528 - maxProbs: 0.4933333
Fri Nov 17 2017 08:52:53 PM - iter: 00013 (01s472ms, 2036.91 samples/s, 1018.46 s/s/thread) - opt: 528 - maxProbs: 0.4866667
Fri Nov 17 2017 08:52:54 PM - iter: 00014 (01s460ms, 2054.40 samples/s, 1027.20 s/s/thread) - opt: 530 - maxProbs: 0.4966667
Fri Nov 17 2017 08:52:56 PM - iter: 00015 (00s534ms, 5609.19 samples/s, 2804.59 s/s/thread) - opt: 532 - maxProbs: 0.49
Fri Nov 17 2017 08:52:57 PM - iter: 00016 (01s467ms, 2044.74 samples/s, 1022.37 s/s/thread) - opt: 532 - maxProbs: 0.4733333
Fri Nov 17 2017 08:52:58 PM - iter: 00017 (01s445ms, 2075.91 samples/s, 1037.96 s/s/thread) - opt: 532 - maxProbs: 0.4533333
Fri Nov 17 2017 08:52:59 PM - iter: 00018 (00s578ms, 5189.29 samples/s, 2594.64 s/s/thread) - opt: 533 - maxProbs: 0.49
Fri Nov 17 2017 08:53:00 PM - iter: 00019 (01s553ms, 1930.52 samples/s, 965.26 s/s/thread) - opt: 533 - maxProbs: 0.4533333
Fri Nov 17 2017 08:53:02 PM - iter: 00020 (01s414ms, 2120.41 samples/s, 1060.21 s/s/thread) - opt: 533 - maxProbs: 0.5
Fri Nov 17 2017 08:53:03 PM - iter: 00021 (01s498ms, 2002.18 samples/s, 1001.09 s/s/thread) - opt: 533 - maxProbs: 0.4366667
Fri Nov 17 2017 08:53:04 PM - iter: 00022 (00s553ms, 5424.29 samples/s, 2712.14 s/s/thread) - opt: 533 - maxProbs: 0.3766667
Fri Nov 17 2017 08:53:06 PM - iter: 00023 (01s534ms, 1954.90 samples/s, 977.45 s/s/thread) - opt: 533 - maxProbs: 0.3633333
Fri Nov 17 2017 08:53:07 PM - iter: 00024 (01s552ms, 1932.30 samples/s, 966.15 s/s/thread) - opt: 533 - maxProbs: 0.3466667
   user  system elapsed 
  16.30    7.45   32.52 
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
Fri Nov 17 2017 08:53:11 PM - iter: 00001 (03s901ms, 768.91 samples/s, 384.45 s/s/thread) - opt: 494 - maxProbs: 0.5
Fri Nov 17 2017 08:53:12 PM - iter: 00002 (00s436ms, 6877.99 samples/s, 3438.99 s/s/thread) - opt: 501 - maxProbs: 0.5
Fri Nov 17 2017 08:53:13 PM - iter: 00003 (01s451ms, 2066.92 samples/s, 1033.46 s/s/thread) - opt: 501 - maxProbs: 0.5
Fri Nov 17 2017 08:53:15 PM - iter: 00004 (01s406ms, 2132.94 samples/s, 1066.47 s/s/thread) - opt: 501 - maxProbs: 0.4966667
Fri Nov 17 2017 08:53:16 PM - iter: 00005 (00s485ms, 6182.57 samples/s, 3091.28 s/s/thread) - opt: 506 - maxProbs: 0.5
Fri Nov 17 2017 08:53:17 PM - iter: 00006 (01s582ms, 1895.22 samples/s, 947.61 s/s/thread) - opt: 510 - maxProbs: 0.5
Fri Nov 17 2017 08:53:18 PM - iter: 00007 (01s468ms, 2042.29 samples/s, 1021.15 s/s/thread) - opt: 514 - maxProbs: 0.5
Fri Nov 17 2017 08:53:20 PM - iter: 00008 (01s509ms, 1987.68 samples/s, 993.84 s/s/thread) - opt: 515 - maxProbs: 0.5
Fri Nov 17 2017 08:53:21 PM - iter: 00009 (00s448ms, 6684.03 samples/s, 3342.02 s/s/thread) - opt: 519 - maxProbs: 0.4966667
Fri Nov 17 2017 08:53:22 PM - iter: 00010 (01s480ms, 2026.94 samples/s, 1013.47 s/s/thread) - opt: 523 - maxProbs: 0.4933333
Fri Nov 17 2017 08:53:23 PM - iter: 00011 (01s523ms, 1969.20 samples/s, 984.60 s/s/thread) - opt: 526 - maxProbs: 0.4966667
   user  system elapsed 
   7.30    2.80   16.22 
> stopCluster(cl)
> closeAllConnections()
> all.equal(res1$optimizer$discrete, res3$optimizer$discrete)
[1] "Mean relative difference: 2.333333"
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
   8.56    0.00    8.56 
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
Fri Nov 17 2017 08:53:33 PM - iter: 00001 (00s624ms, 16019.76 samples/s) - opt: 3.009517 - maxSd: 0.3248419 - maxProbs: 0.9483221
Fri Nov 17 2017 08:53:34 PM - iter: 00002 (00s621ms, 16083.93 samples/s) - opt: 2.70702 - maxSd: 0.07449603 - maxProbs: 0.7741611
Fri Nov 17 2017 08:53:34 PM - iter: 00003 (00s588ms, 16996.45 samples/s) - opt: 2.688896 - maxSd: 0.04549593 - maxProbs: 0.7495805
Fri Nov 17 2017 08:53:35 PM - iter: 00004 (00s637ms, 15678.53 samples/s) - opt: 2.677602 - maxSd: 0.03024808 - maxProbs: 0.6247903
Fri Nov 17 2017 08:53:35 PM - iter: 00005 (00s544ms, 18368.28 samples/s) - opt: 2.675769 - maxSd: 0.006000473 - maxProbs: 0.4498951
Fri Nov 17 2017 08:53:36 PM - iter: 00006 (00s588ms, 16983.78 samples/s) - opt: 2.675727 - maxSd: 0.000613875 - maxProbs: 0.2249476
Fri Nov 17 2017 08:53:37 PM - iter: 00007 (00s731ms, 13663.57 samples/s) - opt: 2.675727 - maxSd: 7.4365e-05 - maxProbs: 0.1124738
Fri Nov 17 2017 08:53:37 PM - iter: 00008 (00s587ms, 17017.11 samples/s) - opt: 2.675727 - maxSd: 4.23201e-06 - maxProbs: 0.05623689
Fri Nov 17 2017 08:53:38 PM - iter: 00009 (00s616ms, 16231.28 samples/s) - opt: 2.675727 - maxSd: 4.225456e-07 - maxProbs: 0.02811845
Fri Nov 17 2017 08:53:39 PM - iter: 00010 (00s733ms, 13628.64 samples/s) - opt: 2.675727 - maxSd: 3.376241e-08 - maxProbs: 0.01405922
Fri Nov 17 2017 08:53:39 PM - iter: 00011 (00s574ms, 17392.88 samples/s) - opt: 2.675727 - maxSd: 7.751173e-09 - maxProbs: 0.007029611
Fri Nov 17 2017 08:53:40 PM - iter: 00012 (00s619ms, 16153.81 samples/s) - opt: 2.675727 - maxSd: 2.775761e-09 - maxProbs: 0.003514806
Fri Nov 17 2017 08:53:41 PM - iter: 00013 (00s637ms, 15686.03 samples/s) - opt: 2.675727 - maxSd: 1.736754e-09 - maxProbs: 0.001757403
Fri Nov 17 2017 08:53:41 PM - iter: 00014 (00s650ms, 15375.06 samples/s) - opt: 2.675727 - maxSd: 1.219703e-09 - maxProbs: 0.0008787014
   user  system elapsed 
   8.99    0.02    9.02 
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
Fri Nov 17 2017 08:53:45 PM - iter: 00001 (03s141ms, 3183.35 samples/s, 1591.68 s/s/thread) - opt: 3.009517 - maxSd: 0.3248419 - maxProbs: 0.9483221
Fri Nov 17 2017 08:53:47 PM - iter: 00002 (02s041ms, 4898.33 samples/s, 2449.16 s/s/thread) - opt: 2.70702 - maxSd: 0.07449603 - maxProbs: 0.7741611
Fri Nov 17 2017 08:53:49 PM - iter: 00003 (01s958ms, 5106.20 samples/s, 2553.10 s/s/thread) - opt: 2.688896 - maxSd: 0.04549593 - maxProbs: 0.7495805
Fri Nov 17 2017 08:53:51 PM - iter: 00004 (01s922ms, 5200.34 samples/s, 2600.17 s/s/thread) - opt: 2.677602 - maxSd: 0.03024808 - maxProbs: 0.6247903
Fri Nov 17 2017 08:53:52 PM - iter: 00005 (01s078ms, 9269.77 samples/s, 4634.88 s/s/thread) - opt: 2.675769 - maxSd: 0.006000473 - maxProbs: 0.4498951
Fri Nov 17 2017 08:53:54 PM - iter: 00006 (02s038ms, 4904.83 samples/s, 2452.42 s/s/thread) - opt: 2.675727 - maxSd: 0.000613875 - maxProbs: 0.2249476
Fri Nov 17 2017 08:53:56 PM - iter: 00007 (01s967ms, 5083.00 samples/s, 2541.50 s/s/thread) - opt: 2.675727 - maxSd: 7.4365e-05 - maxProbs: 0.1124738
Fri Nov 17 2017 08:53:58 PM - iter: 00008 (01s132ms, 8831.01 samples/s, 4415.51 s/s/thread) - opt: 2.675727 - maxSd: 4.23201e-06 - maxProbs: 0.05623689
Fri Nov 17 2017 08:53:59 PM - iter: 00009 (02s079ms, 4809.46 samples/s, 2404.73 s/s/thread) - opt: 2.675727 - maxSd: 4.225456e-07 - maxProbs: 0.02811845
Fri Nov 17 2017 08:54:01 PM - iter: 00010 (01s980ms, 5048.15 samples/s, 2524.08 s/s/thread) - opt: 2.675727 - maxSd: 3.376241e-08 - maxProbs: 0.01405922
Fri Nov 17 2017 08:54:03 PM - iter: 00011 (00s996ms, 10033.53 samples/s, 5016.77 s/s/thread) - opt: 2.675727 - maxSd: 7.751173e-09 - maxProbs: 0.007029611
Fri Nov 17 2017 08:54:04 PM - iter: 00012 (01s988ms, 5029.29 samples/s, 2514.64 s/s/thread) - opt: 2.675727 - maxSd: 2.775761e-09 - maxProbs: 0.003514806
Fri Nov 17 2017 08:54:06 PM - iter: 00013 (02s246ms, 4451.55 samples/s, 2225.78 s/s/thread) - opt: 2.675727 - maxSd: 1.736754e-09 - maxProbs: 0.001757403
Fri Nov 17 2017 08:54:08 PM - iter: 00014 (01s114ms, 8973.21 samples/s, 4486.60 s/s/thread) - opt: 2.675727 - maxSd: 1.219703e-09 - maxProbs: 0.0008787014
   user  system elapsed 
  14.30    4.60   26.47 
> stopCluster(cl)
> closeAllConnections()
> 
> all.equal(res1$optimum, res2$optimum)
[1] TRUE
> all.equal(res1$optimum, res3$optimum)
[1] TRUE
```