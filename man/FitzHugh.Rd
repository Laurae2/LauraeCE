\docType{data}
\name{FitzHugh}
\alias{FitzHugh}
\title{Simulated data from FitzHugh-Nagumo differential equations}

\usage{data(FitzHugh)}

\format{A numeric vetor of length 401}
\description{
  The data correspond to the values V(t) of the  FitzHugh-Nagumo differential
  equations

  V'(t) = c*(V(t) - (V(t)^3)/3 + R(t))
  
  R'(t) = -(1/c)*(V(t) - a + b*R(t)) 
  
  at times 0, 0.05,..,20.0, with parameters a = 0.2, b = 0.2, c = 3 and
  initial conditions V(0) = -1, R(0)=1, and  adding gaussian noise with
  standard deviation 0.5.
}
\keyword{datasets}

\references{Nagumo, J.  and Arimoto, S. and  Yoshizawa, S. (1962) An
  active pulse ransmission line simulating nerve axon, \emph{Proceedings
  of the IRE}, \bold{50} (10), 2061--2070.

Ramsay, J.O.  and Hooker, G. and Campbell, D. and Cao J. (2007)
Parameter estimation for differential equations: A generalized smoothing
approach, \emph{Journal of the Royal Statistical Society, Series B}
\bold{69} (5) 741--796.

Benham T.,  Duan Q., Kroese D.P., Liquet B. (2017) \bold{CEoptim}:
Cross-Entropy \R package for optimization. \emph{Journal of Statistical
  Software}, 76(8), 1-29.
}

\examples{
## Plot the data
data(FitzHugh)
plot(FitzHugh,col="blue")
}

