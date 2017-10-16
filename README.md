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
   0.17    0.00    0.19 
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
   0.36    0.08    2.01 
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
   3.67    0.00    3.72 
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
Tue Oct 17 2017 12:22:11 AM - iter: 00001 (00s107ms, 28017.50 samples/s) - opt: 494 - maxProbs: 0.5
Tue Oct 17 2017 12:22:12 AM - iter: 00002 (00s087ms, 34458.20 samples/s) - opt: 501 - maxProbs: 0.5
Tue Oct 17 2017 12:22:12 AM - iter: 00003 (00s136ms, 22043.11 samples/s) - opt: 501 - maxProbs: 0.5
Tue Oct 17 2017 12:22:12 AM - iter: 00004 (00s083ms, 36119.29 samples/s) - opt: 501 - maxProbs: 0.4966667
Tue Oct 17 2017 12:22:12 AM - iter: 00005 (00s090ms, 33309.57 samples/s) - opt: 506 - maxProbs: 0.5
Tue Oct 17 2017 12:22:12 AM - iter: 00006 (00s103ms, 29105.59 samples/s) - opt: 510 - maxProbs: 0.5
Tue Oct 17 2017 12:22:12 AM - iter: 00007 (00s117ms, 25623.11 samples/s) - opt: 514 - maxProbs: 0.5
Tue Oct 17 2017 12:22:12 AM - iter: 00008 (00s110ms, 27253.43 samples/s) - opt: 515 - maxProbs: 0.5
Tue Oct 17 2017 12:22:13 AM - iter: 00009 (00s136ms, 22043.27 samples/s) - opt: 519 - maxProbs: 0.4966667
Tue Oct 17 2017 12:22:13 AM - iter: 00010 (00s148ms, 20255.87 samples/s) - opt: 523 - maxProbs: 0.4933333
Tue Oct 17 2017 12:22:13 AM - iter: 00011 (00s114ms, 26297.15 samples/s) - opt: 526 - maxProbs: 0.4966667
Tue Oct 17 2017 12:22:13 AM - iter: 00012 (00s100ms, 29979.07 samples/s) - opt: 528 - maxProbs: 0.4933333
Tue Oct 17 2017 12:22:13 AM - iter: 00013 (00s105ms, 28551.31 samples/s) - opt: 528 - maxProbs: 0.4866667
Tue Oct 17 2017 12:22:13 AM - iter: 00014 (00s123ms, 24373.17 samples/s) - opt: 530 - maxProbs: 0.4966667
Tue Oct 17 2017 12:22:14 AM - iter: 00015 (00s153ms, 19593.99 samples/s) - opt: 532 - maxProbs: 0.49
Tue Oct 17 2017 12:22:14 AM - iter: 00016 (00s146ms, 20533.35 samples/s) - opt: 532 - maxProbs: 0.4733333
Tue Oct 17 2017 12:22:14 AM - iter: 00017 (00s123ms, 24372.78 samples/s) - opt: 532 - maxProbs: 0.4533333
Tue Oct 17 2017 12:22:14 AM - iter: 00018 (00s108ms, 27757.70 samples/s) - opt: 533 - maxProbs: 0.49
Tue Oct 17 2017 12:22:14 AM - iter: 00019 (00s115ms, 26068.58 samples/s) - opt: 533 - maxProbs: 0.4533333
Tue Oct 17 2017 12:22:14 AM - iter: 00020 (00s261ms, 11486.08 samples/s) - opt: 533 - maxProbs: 0.5
Tue Oct 17 2017 12:22:15 AM - iter: 00021 (00s115ms, 26068.36 samples/s) - opt: 533 - maxProbs: 0.4366667
Tue Oct 17 2017 12:22:15 AM - iter: 00022 (00s096ms, 31228.24 samples/s) - opt: 533 - maxProbs: 0.3766667
Tue Oct 17 2017 12:22:15 AM - iter: 00023 (00s104ms, 28825.92 samples/s) - opt: 533 - maxProbs: 0.3633333
   user  system elapsed 
   3.64    0.00    3.72 
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
Tue Oct 17 2017 12:22:21 AM - iter: 00001 (05s825ms, 514.95 samples/s, 257.48 s/s/thread) - opt: 494 - maxProbs: 0.5
Tue Oct 17 2017 12:22:23 AM - iter: 00002 (01s266ms, 2369.11 samples/s, 1184.56 s/s/thread) - opt: 501 - maxProbs: 0.5
Tue Oct 17 2017 12:22:25 AM - iter: 00003 (02s457ms, 1220.81 samples/s, 610.40 s/s/thread) - opt: 501 - maxProbs: 0.5
Tue Oct 17 2017 12:22:27 AM - iter: 00004 (01s347ms, 2226.52 samples/s, 1113.26 s/s/thread) - opt: 501 - maxProbs: 0.4966667
Tue Oct 17 2017 12:22:28 AM - iter: 00005 (02s193ms, 1367.88 samples/s, 683.94 s/s/thread) - opt: 506 - maxProbs: 0.5
Tue Oct 17 2017 12:22:30 AM - iter: 00006 (01s130ms, 2654.34 samples/s, 1327.17 s/s/thread) - opt: 510 - maxProbs: 0.5
Tue Oct 17 2017 12:22:32 AM - iter: 00007 (02s097ms, 1430.49 samples/s, 715.25 s/s/thread) - opt: 514 - maxProbs: 0.5
Tue Oct 17 2017 12:22:33 AM - iter: 00008 (01s161ms, 2583.55 samples/s, 1291.77 s/s/thread) - opt: 515 - maxProbs: 0.5
Tue Oct 17 2017 12:22:35 AM - iter: 00009 (02s142ms, 1400.44 samples/s, 700.22 s/s/thread) - opt: 519 - maxProbs: 0.4966667
Tue Oct 17 2017 12:22:37 AM - iter: 00010 (01s191ms, 2518.45 samples/s, 1259.22 s/s/thread) - opt: 523 - maxProbs: 0.4933333
Tue Oct 17 2017 12:22:38 AM - iter: 00011 (02s166ms, 1384.92 samples/s, 692.46 s/s/thread) - opt: 526 - maxProbs: 0.4966667
Tue Oct 17 2017 12:22:40 AM - iter: 00012 (01s059ms, 2832.46 samples/s, 1416.23 s/s/thread) - opt: 528 - maxProbs: 0.4933333
Tue Oct 17 2017 12:22:42 AM - iter: 00013 (02s291ms, 1309.28 samples/s, 654.64 s/s/thread) - opt: 528 - maxProbs: 0.4866667
Tue Oct 17 2017 12:22:44 AM - iter: 00014 (02s193ms, 1367.84 samples/s, 683.92 s/s/thread) - opt: 530 - maxProbs: 0.4966667
Tue Oct 17 2017 12:22:46 AM - iter: 00015 (01s273ms, 2354.85 samples/s, 1177.43 s/s/thread) - opt: 532 - maxProbs: 0.49
Tue Oct 17 2017 12:22:47 AM - iter: 00016 (02s117ms, 1416.96 samples/s, 708.48 s/s/thread) - opt: 532 - maxProbs: 0.4733333
Tue Oct 17 2017 12:22:49 AM - iter: 00017 (01s370ms, 2189.32 samples/s, 1094.66 s/s/thread) - opt: 532 - maxProbs: 0.4533333
Tue Oct 17 2017 12:22:51 AM - iter: 00018 (01s243ms, 2413.41 samples/s, 1206.70 s/s/thread) - opt: 533 - maxProbs: 0.49
Tue Oct 17 2017 12:22:53 AM - iter: 00019 (02s387ms, 1256.53 samples/s, 628.27 s/s/thread) - opt: 533 - maxProbs: 0.4533333
Tue Oct 17 2017 12:22:54 AM - iter: 00020 (01s054ms, 2845.88 samples/s, 1422.94 s/s/thread) - opt: 533 - maxProbs: 0.5
Tue Oct 17 2017 12:22:56 AM - iter: 00021 (02s337ms, 1283.56 samples/s, 641.78 s/s/thread) - opt: 533 - maxProbs: 0.4366667
Tue Oct 17 2017 12:22:58 AM - iter: 00022 (01s167ms, 2570.24 samples/s, 1285.12 s/s/thread) - opt: 533 - maxProbs: 0.3766667
Tue Oct 17 2017 12:22:59 AM - iter: 00023 (02s094ms, 1432.56 samples/s, 716.28 s/s/thread) - opt: 533 - maxProbs: 0.3633333
   user  system elapsed 
  19.53   11.79   45.62 
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
Tue Oct 17 2017 12:23:07 AM - iter: 00001 (05s667ms, 529.32 samples/s, 264.66 s/s/thread) - opt: 494 - maxProbs: 0.5
Tue Oct 17 2017 12:23:09 AM - iter: 00002 (01s206ms, 2487.17 samples/s, 1243.58 s/s/thread) - opt: 501 - maxProbs: 0.5
Tue Oct 17 2017 12:23:10 AM - iter: 00003 (02s067ms, 1451.28 samples/s, 725.64 s/s/thread) - opt: 501 - maxProbs: 0.5
Tue Oct 17 2017 12:23:12 AM - iter: 00004 (01s313ms, 2284.45 samples/s, 1142.22 s/s/thread) - opt: 501 - maxProbs: 0.4966667
Tue Oct 17 2017 12:23:14 AM - iter: 00005 (02s260ms, 1327.32 samples/s, 663.66 s/s/thread) - opt: 506 - maxProbs: 0.5
Tue Oct 17 2017 12:23:15 AM - iter: 00006 (01s097ms, 2734.25 samples/s, 1367.13 s/s/thread) - opt: 510 - maxProbs: 0.5
   user  system elapsed 
   5.12    3.60   15.41 
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
  11.88    0.00   11.99 
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
Tue Oct 17 2017 12:23:30 AM - iter: 00001 (00s814ms, 12276.02 samples/s) - opt: 3.009517 - maxSd: 0.3248419 - maxProbs: 0.9483221
Tue Oct 17 2017 12:23:31 AM - iter: 00002 (00s787ms, 12697.15 samples/s) - opt: 2.70702 - maxSd: 0.07449603 - maxProbs: 0.7741611
Tue Oct 17 2017 12:23:32 AM - iter: 00003 (00s814ms, 12276.55 samples/s) - opt: 2.688896 - maxSd: 0.04549593 - maxProbs: 0.7495805
Tue Oct 17 2017 12:23:33 AM - iter: 00004 (00s807ms, 12382.75 samples/s) - opt: 2.677602 - maxSd: 0.03024808 - maxProbs: 0.6247903
Tue Oct 17 2017 12:23:33 AM - iter: 00005 (00s826ms, 12097.94 samples/s) - opt: 2.675769 - maxSd: 0.006000473 - maxProbs: 0.4498951
Tue Oct 17 2017 12:23:34 AM - iter: 00006 (00s869ms, 11499.29 samples/s) - opt: 2.675727 - maxSd: 0.000613875 - maxProbs: 0.2249476
Tue Oct 17 2017 12:23:35 AM - iter: 00007 (00s892ms, 11202.79 samples/s) - opt: 2.675727 - maxSd: 7.4365e-05 - maxProbs: 0.1124738
Tue Oct 17 2017 12:23:36 AM - iter: 00008 (00s907ms, 11017.75 samples/s) - opt: 2.675727 - maxSd: 4.23201e-06 - maxProbs: 0.05623689
Tue Oct 17 2017 12:23:37 AM - iter: 00009 (00s810ms, 12337.18 samples/s) - opt: 2.675727 - maxSd: 4.225456e-07 - maxProbs: 0.02811845
Tue Oct 17 2017 12:23:38 AM - iter: 00010 (00s836ms, 11953.27 samples/s) - opt: 2.675727 - maxSd: 3.376241e-08 - maxProbs: 0.01405922
Tue Oct 17 2017 12:23:39 AM - iter: 00011 (00s860ms, 11619.63 samples/s) - opt: 2.675727 - maxSd: 7.751173e-09 - maxProbs: 0.007029611
Tue Oct 17 2017 12:23:40 AM - iter: 00012 (00s823ms, 12141.80 samples/s) - opt: 2.675727 - maxSd: 2.775761e-09 - maxProbs: 0.003514806
Tue Oct 17 2017 12:23:40 AM - iter: 00013 (00s902ms, 11078.59 samples/s) - opt: 2.675727 - maxSd: 1.736754e-09 - maxProbs: 0.001757403
   user  system elapsed 
  11.98    0.00   12.11 
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
Tue Oct 17 2017 12:23:47 AM - iter: 00001 (04s641ms, 2154.36 samples/s, 1077.18 s/s/thread) - opt: 3.009517 - maxSd: 0.3248419 - maxProbs: 0.9483221
Tue Oct 17 2017 12:23:50 AM - iter: 00002 (02s941ms, 3399.36 samples/s, 1699.68 s/s/thread) - opt: 2.70702 - maxSd: 0.07449603 - maxProbs: 0.7741611
Tue Oct 17 2017 12:23:52 AM - iter: 00003 (02s753ms, 3631.45 samples/s, 1815.72 s/s/thread) - opt: 2.688896 - maxSd: 0.04549593 - maxProbs: 0.7495805
Tue Oct 17 2017 12:23:55 AM - iter: 00004 (01s894ms, 5277.88 samples/s, 2638.94 s/s/thread) - opt: 2.677602 - maxSd: 0.03024808 - maxProbs: 0.6247903
Tue Oct 17 2017 12:23:57 AM - iter: 00005 (02s707ms, 3693.22 samples/s, 1846.61 s/s/thread) - opt: 2.675769 - maxSd: 0.006000473 - maxProbs: 0.4498951
Tue Oct 17 2017 12:23:59 AM - iter: 00006 (02s011ms, 4970.76 samples/s, 2485.38 s/s/thread) - opt: 2.675727 - maxSd: 0.000613875 - maxProbs: 0.2249476
Tue Oct 17 2017 12:24:02 AM - iter: 00007 (03s031ms, 3298.36 samples/s, 1649.18 s/s/thread) - opt: 2.675727 - maxSd: 7.4365e-05 - maxProbs: 0.1124738
Tue Oct 17 2017 12:24:04 AM - iter: 00008 (01s969ms, 5076.72 samples/s, 2538.36 s/s/thread) - opt: 2.675727 - maxSd: 4.23201e-06 - maxProbs: 0.05623689
Tue Oct 17 2017 12:24:07 AM - iter: 00009 (03s013ms, 3318.05 samples/s, 1659.02 s/s/thread) - opt: 2.675727 - maxSd: 4.225456e-07 - maxProbs: 0.02811845
Tue Oct 17 2017 12:24:10 AM - iter: 00010 (01s912ms, 5228.12 samples/s, 2614.06 s/s/thread) - opt: 2.675727 - maxSd: 3.376241e-08 - maxProbs: 0.01405922
Tue Oct 17 2017 12:24:12 AM - iter: 00011 (02s929ms, 3413.19 samples/s, 1706.59 s/s/thread) - opt: 2.675727 - maxSd: 7.751173e-09 - maxProbs: 0.007029611
Tue Oct 17 2017 12:24:14 AM - iter: 00012 (01s839ms, 5435.74 samples/s, 2717.87 s/s/thread) - opt: 2.675727 - maxSd: 2.775761e-09 - maxProbs: 0.003514806
Tue Oct 17 2017 12:24:17 AM - iter: 00013 (02s903ms, 3443.82 samples/s, 1721.91 s/s/thread) - opt: 2.675727 - maxSd: 1.736754e-09 - maxProbs: 0.001757403
   user  system elapsed 
  21.92    6.31   37.48 
> stopCluster(cl)
> closeAllConnections()
> 
> all.equal(res1$optimum, res2$optimum)
[1] TRUE
> all.equal(res1$optimum, res3$optimum)
[1] TRUE
```