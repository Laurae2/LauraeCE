\docType{data}
\name{lesmis}
\alias{lesmis}
\title{Network data from Les Miserables}
\format{Matrix of weights (77x77)}

\description{An R implementation of Donald Knuth's social network graph 
	describing  the interaction of characters in Vicor Hugo's novel
	Les Miserables. Each node represents a character, and edges connect any pair of characters that coappear. The weights of the edges are the number of such coapperances.
	}
\usage{data(lesmis)}

\keyword{datasets}

\references{Knuth, D.E. (1993) \emph{The Stanford GraphBase: A Platform for
	Combinatorial Computing}, ACM Press: Reading MA

Benham T.,  Duan Q., Kroese D.P., Liquet B. (2017) \bold{CEoptim}:
Cross-Entropy \R package for optimization. \emph{Journal of Statistical
  Software}, 76(8), 1-29.
}

\examples{
## Display the social network graph
data(lesmis)
gplot(lesmis,gmode="graph")
}