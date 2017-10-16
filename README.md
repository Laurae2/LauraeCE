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
   0.13    0.00    0.13 
> 
> system.time({
+   set.seed(11111)
+   res2 <- CEoptim(fun,
+                   continuous = list(mean = mu0,
+                                     sd = sigma0),
+                   maximize = TRUE)
+ })
   user  system elapsed 
   0.16    0.00    0.15 
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
   0.45    0.02    2.03 
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
   3.81    0.00    3.86 
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
Tue Oct 17 2017 12:07:19 AM - iter: 00001 (00s082ms, 36559.02 samples/s) - opt: 494 - maxProbs: 0.5
Tue Oct 17 2017 12:07:19 AM - iter: 00002 (00s102ms, 29389.89 samples/s) - opt: 501 - maxProbs: 0.5
Tue Oct 17 2017 12:07:19 AM - iter: 00003 (00s092ms, 32585.95 samples/s) - opt: 501 - maxProbs: 0.5
Tue Oct 17 2017 12:07:19 AM - iter: 00004 (00s101ms, 29681.80 samples/s) - opt: 501 - maxProbs: 0.4966667
Tue Oct 17 2017 12:07:20 AM - iter: 00005 (00s133ms, 22540.59 samples/s) - opt: 506 - maxProbs: 0.5
Tue Oct 17 2017 12:07:20 AM - iter: 00006 (00s113ms, 26529.70 samples/s) - opt: 510 - maxProbs: 0.5
Tue Oct 17 2017 12:07:20 AM - iter: 00007 (00s113ms, 26529.13 samples/s) - opt: 514 - maxProbs: 0.5
Tue Oct 17 2017 12:07:20 AM - iter: 00008 (00s101ms, 29681.80 samples/s) - opt: 515 - maxProbs: 0.5
Tue Oct 17 2017 12:07:20 AM - iter: 00009 (00s106ms, 28281.37 samples/s) - opt: 519 - maxProbs: 0.4966667
Tue Oct 17 2017 12:07:20 AM - iter: 00010 (00s136ms, 22043.63 samples/s) - opt: 523 - maxProbs: 0.4933333
Tue Oct 17 2017 12:07:21 AM - iter: 00011 (00s138ms, 21723.72 samples/s) - opt: 526 - maxProbs: 0.4966667
Tue Oct 17 2017 12:07:21 AM - iter: 00012 (00s129ms, 23239.01 samples/s) - opt: 528 - maxProbs: 0.4933333
Tue Oct 17 2017 12:07:21 AM - iter: 00013 (00s121ms, 24775.74 samples/s) - opt: 528 - maxProbs: 0.4866667
Tue Oct 17 2017 12:07:21 AM - iter: 00014 (00s120ms, 24981.70 samples/s) - opt: 530 - maxProbs: 0.4966667
Tue Oct 17 2017 12:07:21 AM - iter: 00015 (00s128ms, 23420.88 samples/s) - opt: 532 - maxProbs: 0.49
Tue Oct 17 2017 12:07:21 AM - iter: 00016 (00s141ms, 21261.35 samples/s) - opt: 532 - maxProbs: 0.4733333
Tue Oct 17 2017 12:07:22 AM - iter: 00017 (00s111ms, 27007.54 samples/s) - opt: 532 - maxProbs: 0.4533333
Tue Oct 17 2017 12:07:22 AM - iter: 00018 (00s147ms, 20393.60 samples/s) - opt: 533 - maxProbs: 0.49
Tue Oct 17 2017 12:07:22 AM - iter: 00019 (00s135ms, 22207.28 samples/s) - opt: 533 - maxProbs: 0.4533333
Tue Oct 17 2017 12:07:22 AM - iter: 00020 (00s124ms, 24176.22 samples/s) - opt: 533 - maxProbs: 0.5
Tue Oct 17 2017 12:07:22 AM - iter: 00021 (00s232ms, 12921.86 samples/s) - opt: 533 - maxProbs: 0.4366667
Tue Oct 17 2017 12:07:22 AM - iter: 00022 (00s098ms, 30590.37 samples/s) - opt: 533 - maxProbs: 0.3766667
Tue Oct 17 2017 12:07:23 AM - iter: 00023 (00s111ms, 27007.84 samples/s) - opt: 533 - maxProbs: 0.3633333
   user  system elapsed 
   3.72    0.01    3.78 
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
Tue Oct 17 2017 12:07:29 AM - iter: 00001 (05s947ms, 504.37 samples/s) - opt: 494 - maxProbs: 0.5
Tue Oct 17 2017 12:07:31 AM - iter: 00002 (02s045ms, 1466.90 samples/s) - opt: 501 - maxProbs: 0.5
Tue Oct 17 2017 12:07:32 AM - iter: 00003 (01s269ms, 2363.63 samples/s) - opt: 501 - maxProbs: 0.5
Tue Oct 17 2017 12:07:34 AM - iter: 00004 (02s078ms, 1443.57 samples/s) - opt: 501 - maxProbs: 0.4966667
Tue Oct 17 2017 12:07:36 AM - iter: 00005 (01s311ms, 2287.99 samples/s) - opt: 506 - maxProbs: 0.5
Tue Oct 17 2017 12:07:37 AM - iter: 00006 (02s063ms, 1454.06 samples/s) - opt: 510 - maxProbs: 0.5
Tue Oct 17 2017 12:07:39 AM - iter: 00007 (01s001ms, 2996.57 samples/s) - opt: 514 - maxProbs: 0.5
Tue Oct 17 2017 12:07:41 AM - iter: 00008 (02s142ms, 1400.40 samples/s) - opt: 515 - maxProbs: 0.5
Tue Oct 17 2017 12:07:42 AM - iter: 00009 (00s925ms, 3242.87 samples/s) - opt: 519 - maxProbs: 0.4966667
Tue Oct 17 2017 12:07:44 AM - iter: 00010 (02s197ms, 1365.37 samples/s) - opt: 523 - maxProbs: 0.4933333
Tue Oct 17 2017 12:07:46 AM - iter: 00011 (01s159ms, 2588.02 samples/s) - opt: 526 - maxProbs: 0.4966667
Tue Oct 17 2017 12:07:48 AM - iter: 00012 (02s316ms, 1295.19 samples/s) - opt: 528 - maxProbs: 0.4933333
Tue Oct 17 2017 12:07:49 AM - iter: 00013 (01s139ms, 2633.46 samples/s) - opt: 528 - maxProbs: 0.4866667
Tue Oct 17 2017 12:07:51 AM - iter: 00014 (02s293ms, 1308.19 samples/s) - opt: 530 - maxProbs: 0.4966667
Tue Oct 17 2017 12:07:53 AM - iter: 00015 (01s205ms, 2489.22 samples/s) - opt: 532 - maxProbs: 0.49
Tue Oct 17 2017 12:07:55 AM - iter: 00016 (02s247ms, 1334.71 samples/s) - opt: 532 - maxProbs: 0.4733333
Tue Oct 17 2017 12:07:56 AM - iter: 00017 (01s105ms, 2714.48 samples/s) - opt: 532 - maxProbs: 0.4533333
Tue Oct 17 2017 12:07:58 AM - iter: 00018 (02s104ms, 1425.72 samples/s) - opt: 533 - maxProbs: 0.49
Tue Oct 17 2017 12:08:00 AM - iter: 00019 (02s309ms, 1299.12 samples/s) - opt: 533 - maxProbs: 0.4533333
Tue Oct 17 2017 12:08:02 AM - iter: 00020 (01s146ms, 2617.38 samples/s) - opt: 533 - maxProbs: 0.5
Tue Oct 17 2017 12:08:03 AM - iter: 00021 (01s441ms, 2081.56 samples/s) - opt: 533 - maxProbs: 0.4366667
Tue Oct 17 2017 12:08:05 AM - iter: 00022 (02s120ms, 1414.96 samples/s) - opt: 533 - maxProbs: 0.3766667
Tue Oct 17 2017 12:08:07 AM - iter: 00023 (01s216ms, 2466.63 samples/s) - opt: 533 - maxProbs: 0.3633333
   user  system elapsed 
  19.48   11.45   45.35 
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
Tue Oct 17 2017 12:08:14 AM - iter: 00001 (05s667ms, 529.31 samples/s) - opt: 494 - maxProbs: 0.5
Tue Oct 17 2017 12:08:16 AM - iter: 00002 (01s075ms, 2790.28 samples/s) - opt: 501 - maxProbs: 0.5
Tue Oct 17 2017 12:08:18 AM - iter: 00003 (02s248ms, 1334.38 samples/s) - opt: 501 - maxProbs: 0.5
Tue Oct 17 2017 12:08:20 AM - iter: 00004 (01s056ms, 2840.47 samples/s) - opt: 501 - maxProbs: 0.4966667
Tue Oct 17 2017 12:08:21 AM - iter: 00005 (01s979ms, 1515.81 samples/s) - opt: 506 - maxProbs: 0.5
Tue Oct 17 2017 12:08:23 AM - iter: 00006 (01s241ms, 2416.84 samples/s) - opt: 510 - maxProbs: 0.5
   user  system elapsed 
   5.88    2.96   15.53 
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
  12.00    0.01   12.07 
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
Tue Oct 17 2017 12:08:38 AM - iter: 00001 (00s740ms, 13504.21 samples/s) - opt: 3.009517 - maxSd: 0.3248419 - maxProbs: 0.9483221
Tue Oct 17 2017 12:08:39 AM - iter: 00002 (00s775ms, 12894.06 samples/s) - opt: 2.70702 - maxSd: 0.07449603 - maxProbs: 0.7741611
Tue Oct 17 2017 12:08:39 AM - iter: 00003 (00s836ms, 11953.21 samples/s) - opt: 2.688896 - maxSd: 0.04549593 - maxProbs: 0.7495805
Tue Oct 17 2017 12:08:40 AM - iter: 00004 (00s846ms, 11811.67 samples/s) - opt: 2.677602 - maxSd: 0.03024808 - maxProbs: 0.6247903
Tue Oct 17 2017 12:08:41 AM - iter: 00005 (00s811ms, 12321.42 samples/s) - opt: 2.675769 - maxSd: 0.006000473 - maxProbs: 0.4498951
Tue Oct 17 2017 12:08:42 AM - iter: 00006 (00s889ms, 11240.57 samples/s) - opt: 2.675727 - maxSd: 0.000613875 - maxProbs: 0.2249476
Tue Oct 17 2017 12:08:43 AM - iter: 00007 (00s874ms, 11433.51 samples/s) - opt: 2.675727 - maxSd: 7.4365e-05 - maxProbs: 0.1124738
Tue Oct 17 2017 12:08:44 AM - iter: 00008 (00s839ms, 11910.74 samples/s) - opt: 2.675727 - maxSd: 4.23201e-06 - maxProbs: 0.05623689
Tue Oct 17 2017 12:08:44 AM - iter: 00009 (00s793ms, 12601.09 samples/s) - opt: 2.675727 - maxSd: 4.225456e-07 - maxProbs: 0.02811845
Tue Oct 17 2017 12:08:45 AM - iter: 00010 (00s869ms, 11499.55 samples/s) - opt: 2.675727 - maxSd: 3.376241e-08 - maxProbs: 0.01405922
Tue Oct 17 2017 12:08:46 AM - iter: 00011 (00s888ms, 11253.04 samples/s) - opt: 2.675727 - maxSd: 7.751173e-09 - maxProbs: 0.007029611
Tue Oct 17 2017 12:08:47 AM - iter: 00012 (00s934ms, 10699.26 samples/s) - opt: 2.675727 - maxSd: 2.775761e-09 - maxProbs: 0.003514806
Tue Oct 17 2017 12:08:48 AM - iter: 00013 (00s910ms, 10981.22 samples/s) - opt: 2.675727 - maxSd: 1.736754e-09 - maxProbs: 0.001757403
   user  system elapsed 
  11.98    0.02   12.09 
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
Tue Oct 17 2017 12:08:56 AM - iter: 00001 (05s534ms, 1806.93 samples/s) - opt: 3.009517 - maxSd: 0.3248419 - maxProbs: 0.9483221
Tue Oct 17 2017 12:08:58 AM - iter: 00002 (02s928ms, 3414.51 samples/s) - opt: 2.70702 - maxSd: 0.07449603 - maxProbs: 0.7741611
Tue Oct 17 2017 12:09:00 AM - iter: 00003 (02s090ms, 4782.82 samples/s) - opt: 2.688896 - maxSd: 0.04549593 - maxProbs: 0.7495805
Tue Oct 17 2017 12:09:03 AM - iter: 00004 (02s858ms, 3498.01 samples/s) - opt: 2.677602 - maxSd: 0.03024808 - maxProbs: 0.6247903
Tue Oct 17 2017 12:09:05 AM - iter: 00005 (01s958ms, 5105.39 samples/s) - opt: 2.675769 - maxSd: 0.006000473 - maxProbs: 0.4498951
Tue Oct 17 2017 12:09:08 AM - iter: 00006 (02s882ms, 3468.88 samples/s) - opt: 2.675727 - maxSd: 0.000613875 - maxProbs: 0.2249476
Tue Oct 17 2017 12:09:10 AM - iter: 00007 (01s899ms, 5263.94 samples/s) - opt: 2.675727 - maxSd: 7.4365e-05 - maxProbs: 0.1124738
Tue Oct 17 2017 12:09:13 AM - iter: 00008 (03s164ms, 3159.73 samples/s) - opt: 2.675727 - maxSd: 4.23201e-06 - maxProbs: 0.05623689
Tue Oct 17 2017 12:09:16 AM - iter: 00009 (02s158ms, 4632.12 samples/s) - opt: 2.675727 - maxSd: 4.225456e-07 - maxProbs: 0.02811845
Tue Oct 17 2017 12:09:18 AM - iter: 00010 (02s831ms, 3531.43 samples/s) - opt: 2.675727 - maxSd: 3.376241e-08 - maxProbs: 0.01405922
Tue Oct 17 2017 12:09:20 AM - iter: 00011 (01s949ms, 5128.94 samples/s) - opt: 2.675727 - maxSd: 7.751173e-09 - maxProbs: 0.007029611
Tue Oct 17 2017 12:09:23 AM - iter: 00012 (02s811ms, 3556.54 samples/s) - opt: 2.675727 - maxSd: 2.775761e-09 - maxProbs: 0.003514806
Tue Oct 17 2017 12:09:25 AM - iter: 00013 (02s809ms, 3559.10 samples/s) - opt: 2.675727 - maxSd: 1.736754e-09 - maxProbs: 0.001757403
   user  system elapsed 
  20.97    6.75   38.25 
> stopCluster(cl)
> closeAllConnections()
> 
> all.equal(res1$optimum, res2$optimum)
[1] TRUE
> all.equal(res1$optimum, res3$optimum)
[1] TRUE
```