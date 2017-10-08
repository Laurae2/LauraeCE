\docType{data}
\name{yt}
\alias{yt}
\title{Simulated cumulative data from an AR(1) model with regime switching}
\format{Numeric vector of length 300}

\description{
	yt represents the added value of a stock at time t, at day t=1,2,...,300; that is, the increase (which may be negative) in stock price relative to the price at time t=0.
		}
\usage{data(yt)}

\keyword{datasets}

\references{
 Benham T.,  Duan Q., Kroese D.P., Liquet B. (2017) \bold{CEoptim}:
Cross-Entropy \R package for optimization. \emph{Journal of Statistical Software}, 76(8), 1-29.
}

\examples{
## Plot the yt data
data(yt)
plot(yt,type="l",col="blue")
}