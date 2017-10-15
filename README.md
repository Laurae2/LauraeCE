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
   0.14    0.00    0.14 
> 
> system.time({
+   set.seed(11111)
+   res2 <- CEoptim(fun,
+                   continuous = list(mean = mu0,
+                                     sd = sigma0),
+                   maximize = TRUE)
+ })
   user  system elapsed 
   0.14    0.00    0.14 
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
   0.50    0.01    1.91 
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
   3.19    0.00    3.21 
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
Sun Oct 15 2017 06:01:20 PM - iter: 00001 (00s068ms, 44086.62 samples/s) - opt: 494 - maxProbs: 0.5
Sun Oct 15 2017 06:01:20 PM - iter: 00002 (00s072ms, 41647.18 samples/s) - opt: 501 - maxProbs: 0.5
Sun Oct 15 2017 06:01:20 PM - iter: 00003 (00s070ms, 42827.72 samples/s) - opt: 501 - maxProbs: 0.5
Sun Oct 15 2017 06:01:20 PM - iter: 00004 (00s101ms, 29676.29 samples/s) - opt: 501 - maxProbs: 0.4966667
Sun Oct 15 2017 06:01:21 PM - iter: 00005 (00s081ms, 37011.49 samples/s) - opt: 506 - maxProbs: 0.5
Sun Oct 15 2017 06:01:21 PM - iter: 00006 (00s119ms, 25192.30 samples/s) - opt: 510 - maxProbs: 0.5
Sun Oct 15 2017 06:01:21 PM - iter: 00007 (00s082ms, 36559.57 samples/s) - opt: 514 - maxProbs: 0.5
Sun Oct 15 2017 06:01:21 PM - iter: 00008 (00s092ms, 32585.95 samples/s) - opt: 515 - maxProbs: 0.5
Sun Oct 15 2017 06:01:21 PM - iter: 00009 (00s101ms, 29687.40 samples/s) - opt: 519 - maxProbs: 0.4966667
Sun Oct 15 2017 06:01:21 PM - iter: 00010 (00s109ms, 27508.03 samples/s) - opt: 523 - maxProbs: 0.4933333
Sun Oct 15 2017 06:01:21 PM - iter: 00011 (00s107ms, 28018.01 samples/s) - opt: 526 - maxProbs: 0.4966667
Sun Oct 15 2017 06:01:21 PM - iter: 00012 (00s130ms, 23060.47 samples/s) - opt: 528 - maxProbs: 0.4933333
Sun Oct 15 2017 06:01:22 PM - iter: 00013 (00s117ms, 25623.27 samples/s) - opt: 528 - maxProbs: 0.4866667
Sun Oct 15 2017 06:01:22 PM - iter: 00014 (00s095ms, 31556.97 samples/s) - opt: 530 - maxProbs: 0.4966667
Sun Oct 15 2017 06:01:22 PM - iter: 00015 (00s102ms, 29385.53 samples/s) - opt: 532 - maxProbs: 0.49
Sun Oct 15 2017 06:01:22 PM - iter: 00016 (00s101ms, 29676.86 samples/s) - opt: 532 - maxProbs: 0.4733333
Sun Oct 15 2017 06:01:22 PM - iter: 00017 (00s093ms, 32235.13 samples/s) - opt: 532 - maxProbs: 0.4533333
Sun Oct 15 2017 06:01:22 PM - iter: 00018 (00s095ms, 31550.33 samples/s) - opt: 533 - maxProbs: 0.49
Sun Oct 15 2017 06:01:22 PM - iter: 00019 (00s130ms, 23059.38 samples/s) - opt: 533 - maxProbs: 0.4533333
Sun Oct 15 2017 06:01:23 PM - iter: 00020 (00s217ms, 13814.94 samples/s) - opt: 533 - maxProbs: 0.5
Sun Oct 15 2017 06:01:23 PM - iter: 00021 (00s079ms, 37946.77 samples/s) - opt: 533 - maxProbs: 0.4366667
Sun Oct 15 2017 06:01:23 PM - iter: 00022 (00s080ms, 37480.78 samples/s) - opt: 533 - maxProbs: 0.3766667
Sun Oct 15 2017 06:01:23 PM - iter: 00023 (00s085ms, 35276.69 samples/s) - opt: 533 - maxProbs: 0.3633333
   user  system elapsed 
   3.08    0.02    3.08 
> 
> cl <- makeCluster(2)
> system.time({
+   set.seed(11111)
+   res3 <- CEoptim(fmaxcut,
+                   f.arg = list(costs = lesmis),
+                   maximize = T, verbose = TRUE,
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
Sun Oct 15 2017 06:01:29 PM - iter: 00001 (05s681ms, 528.00 samples/s) - opt: 494 - maxProbs: 0.5
Sun Oct 15 2017 06:01:31 PM - iter: 00002 (01s167ms, 2570.24 samples/s) - opt: 501 - maxProbs: 0.5
Sun Oct 15 2017 06:01:32 PM - iter: 00003 (02s130ms, 1408.36 samples/s) - opt: 501 - maxProbs: 0.5
Sun Oct 15 2017 06:01:34 PM - iter: 00004 (01s252ms, 2395.66 samples/s) - opt: 501 - maxProbs: 0.4966667
Sun Oct 15 2017 06:01:36 PM - iter: 00005 (02s107ms, 1423.71 samples/s) - opt: 506 - maxProbs: 0.5
Sun Oct 15 2017 06:01:37 PM - iter: 00006 (01s172ms, 2559.29 samples/s) - opt: 510 - maxProbs: 0.5
Sun Oct 15 2017 06:01:39 PM - iter: 00007 (01s863ms, 1610.17 samples/s) - opt: 514 - maxProbs: 0.5
Sun Oct 15 2017 06:01:41 PM - iter: 00008 (02s188ms, 1370.97 samples/s) - opt: 515 - maxProbs: 0.5
Sun Oct 15 2017 06:01:43 PM - iter: 00009 (00s985ms, 3045.17 samples/s) - opt: 519 - maxProbs: 0.4966667
Sun Oct 15 2017 06:01:44 PM - iter: 00010 (02s134ms, 1405.66 samples/s) - opt: 523 - maxProbs: 0.4933333
Sun Oct 15 2017 06:01:46 PM - iter: 00011 (02s031ms, 1476.98 samples/s) - opt: 526 - maxProbs: 0.4966667
Sun Oct 15 2017 06:01:48 PM - iter: 00012 (01s024ms, 2928.27 samples/s) - opt: 528 - maxProbs: 0.4933333
Sun Oct 15 2017 06:01:49 PM - iter: 00013 (02s142ms, 1400.40 samples/s) - opt: 528 - maxProbs: 0.4866667
Sun Oct 15 2017 06:01:51 PM - iter: 00014 (01s225ms, 2448.31 samples/s) - opt: 530 - maxProbs: 0.4966667
Sun Oct 15 2017 06:01:53 PM - iter: 00015 (02s240ms, 1339.13 samples/s) - opt: 532 - maxProbs: 0.49
Sun Oct 15 2017 06:01:55 PM - iter: 00016 (01s270ms, 2361.77 samples/s) - opt: 532 - maxProbs: 0.4733333
Sun Oct 15 2017 06:01:57 PM - iter: 00017 (02s372ms, 1264.56 samples/s) - opt: 532 - maxProbs: 0.4533333
Sun Oct 15 2017 06:01:58 PM - iter: 00018 (01s073ms, 2795.59 samples/s) - opt: 533 - maxProbs: 0.49
Sun Oct 15 2017 06:02:00 PM - iter: 00019 (02s307ms, 1300.26 samples/s) - opt: 533 - maxProbs: 0.4533333
Sun Oct 15 2017 06:02:02 PM - iter: 00020 (01s225ms, 2448.63 samples/s) - opt: 533 - maxProbs: 0.5
Sun Oct 15 2017 06:02:03 PM - iter: 00021 (02s207ms, 1359.19 samples/s) - opt: 533 - maxProbs: 0.4366667
Sun Oct 15 2017 06:02:05 PM - iter: 00022 (01s068ms, 2808.58 samples/s) - opt: 533 - maxProbs: 0.3766667
Sun Oct 15 2017 06:02:07 PM - iter: 00023 (02s085ms, 1438.70 samples/s) - opt: 533 - maxProbs: 0.3633333
   user  system elapsed 
  19.58   10.86   44.97 
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
Sun Oct 15 2017 06:02:14 PM - iter: 00001 (05s562ms, 539.31 samples/s) - opt: 494 - maxProbs: 0.5
Sun Oct 15 2017 06:02:16 PM - iter: 00002 (02s143ms, 1399.74 samples/s) - opt: 501 - maxProbs: 0.5
Sun Oct 15 2017 06:02:18 PM - iter: 00003 (01s246ms, 2407.38 samples/s) - opt: 501 - maxProbs: 0.5
Sun Oct 15 2017 06:02:20 PM - iter: 00004 (01s421ms, 2110.68 samples/s) - opt: 501 - maxProbs: 0.4966667
Sun Oct 15 2017 06:02:22 PM - iter: 00005 (02s530ms, 1185.57 samples/s) - opt: 506 - maxProbs: 0.5
Sun Oct 15 2017 06:02:24 PM - iter: 00006 (01s551ms, 1933.61 samples/s) - opt: 510 - maxProbs: 0.5
   user  system elapsed 
   6.28    3.30   16.43 
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
  12.02    0.00   12.03 
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
Sun Oct 15 2017 06:02:39 PM - iter: 00001 (00s785ms, 12729.82 samples/s) - opt: 3.009517 - maxSd: 0.3248419 - maxProbs: 0.9483221
Sun Oct 15 2017 06:02:39 PM - iter: 00002 (00s749ms, 13341.64 samples/s) - opt: 2.70702 - maxSd: 0.07449603 - maxProbs: 0.7741611
Sun Oct 15 2017 06:02:40 PM - iter: 00003 (00s809ms, 12351.90 samples/s) - opt: 2.688896 - maxSd: 0.04549593 - maxProbs: 0.7495805
Sun Oct 15 2017 06:02:41 PM - iter: 00004 (00s810ms, 12336.88 samples/s) - opt: 2.677602 - maxSd: 0.03024808 - maxProbs: 0.6247903
Sun Oct 15 2017 06:02:42 PM - iter: 00005 (00s897ms, 11140.12 samples/s) - opt: 2.675769 - maxSd: 0.006000473 - maxProbs: 0.4498951
Sun Oct 15 2017 06:02:43 PM - iter: 00006 (00s911ms, 10968.93 samples/s) - opt: 2.675727 - maxSd: 0.000613875 - maxProbs: 0.2249476
Sun Oct 15 2017 06:02:44 PM - iter: 00007 (00s757ms, 13200.67 samples/s) - opt: 2.675727 - maxSd: 7.4365e-05 - maxProbs: 0.1124738
Sun Oct 15 2017 06:02:44 PM - iter: 00008 (00s799ms, 12506.77 samples/s) - opt: 2.675727 - maxSd: 4.23201e-06 - maxProbs: 0.05623689
Sun Oct 15 2017 06:02:45 PM - iter: 00009 (00s986ms, 10134.74 samples/s) - opt: 2.675727 - maxSd: 4.225456e-07 - maxProbs: 0.02811845
Sun Oct 15 2017 06:02:46 PM - iter: 00010 (00s853ms, 11714.74 samples/s) - opt: 2.675727 - maxSd: 3.376241e-08 - maxProbs: 0.01405922
Sun Oct 15 2017 06:02:47 PM - iter: 00011 (00s852ms, 11728.76 samples/s) - opt: 2.675727 - maxSd: 7.751173e-09 - maxProbs: 0.007029611
Sun Oct 15 2017 06:02:48 PM - iter: 00012 (00s953ms, 10485.51 samples/s) - opt: 2.675727 - maxSd: 2.775761e-09 - maxProbs: 0.003514806
Sun Oct 15 2017 06:02:49 PM - iter: 00013 (01s087ms, 9192.96 samples/s) - opt: 2.675727 - maxSd: 1.736754e-09 - maxProbs: 0.001757403
   user  system elapsed 
  12.15    0.03   12.18 
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
Sun Oct 15 2017 06:02:56 PM - iter: 00001 (05s652ms, 1769.04 samples/s) - opt: 3.009517 - maxSd: 0.3248419 - maxProbs: 0.9483221
Sun Oct 15 2017 06:02:58 PM - iter: 00002 (01s918ms, 5211.70 samples/s) - opt: 2.70702 - maxSd: 0.07449603 - maxProbs: 0.7741611
Sun Oct 15 2017 06:03:01 PM - iter: 00003 (02s944ms, 3395.82 samples/s) - opt: 2.688896 - maxSd: 0.04549593 - maxProbs: 0.7495805
Sun Oct 15 2017 06:03:03 PM - iter: 00004 (01s779ms, 5618.93 samples/s) - opt: 2.677602 - maxSd: 0.03024808 - maxProbs: 0.6247903
Sun Oct 15 2017 06:03:06 PM - iter: 00005 (03s082ms, 3243.82 samples/s) - opt: 2.675769 - maxSd: 0.006000473 - maxProbs: 0.4498951
Sun Oct 15 2017 06:03:08 PM - iter: 00006 (02s011ms, 4970.62 samples/s) - opt: 2.675727 - maxSd: 0.000613875 - maxProbs: 0.2249476
Sun Oct 15 2017 06:03:11 PM - iter: 00007 (03s027ms, 3302.73 samples/s) - opt: 2.675727 - maxSd: 7.4365e-05 - maxProbs: 0.1124738
Sun Oct 15 2017 06:03:13 PM - iter: 00008 (02s956ms, 3381.96 samples/s) - opt: 2.675727 - maxSd: 4.23201e-06 - maxProbs: 0.05623689
Sun Oct 15 2017 06:03:16 PM - iter: 00009 (02s074ms, 4819.82 samples/s) - opt: 2.675727 - maxSd: 4.225456e-07 - maxProbs: 0.02811845
Sun Oct 15 2017 06:03:18 PM - iter: 00010 (02s785ms, 3589.76 samples/s) - opt: 2.675727 - maxSd: 3.376241e-08 - maxProbs: 0.01405922
Sun Oct 15 2017 06:03:21 PM - iter: 00011 (01s873ms, 5336.92 samples/s) - opt: 2.675727 - maxSd: 7.751173e-09 - maxProbs: 0.007029611
Sun Oct 15 2017 06:03:23 PM - iter: 00012 (02s765ms, 3615.70 samples/s) - opt: 2.675727 - maxSd: 2.775761e-09 - maxProbs: 0.003514806
Sun Oct 15 2017 06:03:26 PM - iter: 00013 (02s027ms, 4931.41 samples/s) - opt: 2.675727 - maxSd: 1.736754e-09 - maxProbs: 0.001757403
   user  system elapsed 
  21.99    6.08   37.86 
> stopCluster(cl)
> closeAllConnections()
> 
> all.equal(res1$optimum, res2$optimum)
[1] TRUE
> all.equal(res1$optimum, res3$optimum)
[1] TRUE
```