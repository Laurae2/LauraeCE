\name{print}
\alias{print.CEoptim}

\title{Print method for the CEoptim object}

\description{
Produce \code{print} method for class \code{"CEoptim"}
}

\usage{
\method{print}{CEoptim}(x,\ldots)

}

\arguments{
  \item{x}{object of class inheriting from \code{"CEoptim"}}
  \item{\ldots}{additional arguments: \code{optimizer}; \code{optimum}; \code{termination};\code{states};\code{states.probs}}
}

\details{
\code{print} method for \code{"CEoptim"} class, 
returns by default the main description of the \code{x} object including: \code{optimizer}; \code{optimum}; \code{termination}.
To get the \code{states} and \code{states.probs} outputs, one should specify the corresponding argument to "TRUE".
}

\author{Tim Benham, Qibin Duan, Dirk P. Kroese, Benoit Liquet}

\references{Benham T.,  Duan Q., Kroese D.P., Liquet B. (2017) \bold{CEoptim}:
Cross-Entropy \R package for optimization. \emph{Journal of Statistical
  Software}, 76(8), 1-29.}

\seealso{\code{\link{CEoptim}}}

\examples{
## Maximizing the Peaks Function


fun <- function(x){
return(3*(1-x[1])^2*exp(-x[1]^2 - (x[2]+1)^2)
	-10*(x[1]/5-x[1]^3 - x[2]^5)*exp(-x[1]^2 - x[2]^2)
	-1/3*exp(-(x[1]+1)^2 - x[2]^2))}

set.seed(1234)

mu0 <- c(-3,-3); sigma0 <- c(10,10)
 
res <- CEoptim(fun,continuous=list(mean=mu0, sd=sigma0), maximize=TRUE)

## Print method provides by default 
## optimizer; optimum and termination.
print(res)
## To print only the Optimal value of fun
print(res,optimum=TRUE)
## To print only the location of the optimal value
print(res,optimizer=TRUE)
## To print only termination information
print(res,termination=TRUE)
}
