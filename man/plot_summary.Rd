% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotting.R
\name{plot_summary}
\alias{plot_summary}
\title{Plot a summary of all dyngen simulation steps.}
\usage{
plot_summary(model)
}
\arguments{
\item{model}{A dyngen intermediary model for which the simulations have been run with \code{\link[=generate_experiment]{generate_experiment()}}.}
}
\value{
A ggplot2 object.
}
\description{
Plot a summary of all dyngen simulation steps.
}
\examples{
\donttest{
data("example_model")
plot_summary(example_model)
}
}
