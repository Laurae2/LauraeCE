library(LauraeCE)
library(parallel)


# Continuous Testing

fun <- function(x){
  return(3 * (1 - x[1]) ^ 2 * exp(-x[1] ^ 2 - (x[2] + 1) ^ 2) - 10 * (x[1] / 5 - x[1] ^ 3 - x[2] ^ 5) * exp(-x[1] ^ 2 - x[2] ^ 2) - 1 / 3 * exp(-(x[1] + 1) ^ 2 - x[2] ^ 2))
}

mu0 <- c(-3, -3)
sigma0 <- c(10, 10)

set.seed(11111)
res1 <- CEoptim::CEoptim(fun, continuous = list(mean = mu0, sd = sigma0), maximize = TRUE)

set.seed(11111)
res2 <- CEoptim(fun, continuous = list(mean = mu0, sd = sigma0), maximize = TRUE)

cl <- makeCluster(2)
set.seed(11111)
res3 <- CEoptim(fun, continuous = list(mean = mu0, sd = sigma0), maximize = TRUE, parallelize = TRUE, cl = cl)
stopCluster(cl)
closeAllConnections()

all.equal(res1$optimum, res2$optimum)
all.equal(res1$optimum, res3$optimum)


# Discrete Testing

data(lesmis)
fmaxcut <- function(x,costs) {
  v1 <- which(x == 1)
  v2 <- which(x == 0)
  return(sum(costs[v1, v2]))
}

p0 <- list()
for (i in 1:77) {
  p0 <- c(p0, list(rep(0.5, 2)))
}
p0[[1]] <- c(0, 1)

set.seed(11111)
res1 <- CEoptim::CEoptim(fmaxcut, f.arg = list(costs = lesmis), maximize = T, verbose = TRUE, discrete = list(probs = p0), N = 3000L)

set.seed(11111)
res2 <- CEoptim(fmaxcut, f.arg = list(costs = lesmis), maximize = T, verbose = TRUE, discrete = list(probs = p0), N = 3000L)

cl <- makeCluster(2)
set.seed(11111)
res3 <- CEoptim(fmaxcut, f.arg = list(costs = lesmis), maximize = T, verbose = TRUE, discrete = list(probs = p0), N = 3000L, parallelize = TRUE, cl = cl)
stopCluster(cl)
closeAllConnections()

all.equal(res1$optimizer$discrete, res2$optimizer$discrete)
all.equal(res1$optimizer$discrete, res3$optimizer$discrete)



# Mixed Input (Continuous + Discrete) Testing

sumsqrs <- function(theta, rm1, x) {
  N <- length(x) #without x[0]
  r <- 1 + sort(rm1) # internal end points of regimes
  if (r[1] == r[2]) { # test for invalid regime
    return(Inf);
  }
  thetas <- rep(theta, times = c(r, N) - c(1, r + 1) + 1)
  xhat <- c(0, head(x, -1)) * thetas
  # Compute sum of squared errors
  sum((x - xhat) ^ 2)
}

data(yt)
xt <- yt - c(0, yt[-300])

A <- rbind(diag(3), -diag(3))
b <- rep(1, 6)

set.seed(11111)
res1 <- CEoptim::CEoptim(f = sumsqrs,
                         f.arg = list(xt),
                         continuous = list(mean = c(0, 0,0),
                                           sd = rep(1, 0,3),
                                           conMat = A,
                                           conVec = b),
                         discrete = list(categories = c(298L, 298L),
                                         smoothProb = 0.5),
                         N = 10000,
                         rho = 0.001,
                         verbose = TRUE)

set.seed(11111)
res2 <- CEoptim(f = sumsqrs,
                f.arg = list(xt),
                continuous = list(mean = c(0, 0,0),
                                  sd = rep(1, 0,3),
                                  conMat = A,
                                  conVec = b),
                discrete = list(categories = c(298L, 298L),
                                smoothProb = 0.5),
                N = 10000,
                rho = 0.001,
                verbose = TRUE)

cl <- makeCluster(2)
set.seed(11111)
res3 <- CEoptim(f = sumsqrs,
                f.arg = list(xt),
                continuous = list(mean = c(0, 0,0),
                                  sd = rep(1, 0,3),
                                  conMat = A,
                                  conVec = b),
                discrete = list(categories = c(298L, 298L),
                                smoothProb = 0.5),
                N = 10000,
                rho = 0.001,
                verbose = TRUE,
                parallelize = TRUE,
                cl = cl)
stopCluster(cl)
closeAllConnections()

all.equal(res1$optimum, res2$optimum)
all.equal(res1$optimum, res3$optimum)
