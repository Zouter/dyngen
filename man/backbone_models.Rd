% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/0a_backbone.R, R/0d_backbones.R
\name{list_backbones}
\alias{list_backbones}
\alias{backbone_bifurcating}
\alias{backbone_bifurcating_converging}
\alias{backbone_bifurcating_cycle}
\alias{backbone_bifurcating_loop}
\alias{backbone_branching}
\alias{backbone_binary_tree}
\alias{backbone_consecutive_bifurcating}
\alias{backbone_trifurcating}
\alias{backbone_converging}
\alias{backbone_cycle}
\alias{backbone_cycle_simple}
\alias{backbone_linear}
\alias{backbone_linear_simple}
\alias{backbone_disconnected}
\title{List of all predefined backbone models}
\usage{
list_backbones()

backbone_bifurcating()

backbone_bifurcating_converging()

backbone_bifurcating_cycle()

backbone_bifurcating_loop()

backbone_branching(
  num_modifications = rbinom(1, size = 6, 0.25) + 1,
  min_degree = 3,
  max_degree = sample(min_degree:5, 1)
)

backbone_binary_tree(num_modifications = rbinom(1, size = 6, 0.25) + 1)

backbone_consecutive_bifurcating()

backbone_trifurcating()

backbone_converging()

backbone_cycle()

backbone_cycle_simple()

backbone_linear()

backbone_linear_simple()

backbone_disconnected(
  left_backbone = list_backbones() \%>\% keep(., names(.) != "disconnected") \%>\%
    sample(1) \%>\% first(),
  right_backbone = list_backbones() \%>\% keep(., names(.) != "disconnected") \%>\%
    sample(1) \%>\% first(),
  num_common_modules = 10
)
}
\arguments{
\item{num_modifications}{The number of branch points in the generated backbone.}

\item{min_degree}{The minimum degree of each node in the backbone.}

\item{max_degree}{The maximum degree of each node in the backbone.}

\item{left_backbone}{A backbone (other than a disconnected backbone), see \code{\link[=list_backbones]{list_backbones()}}.}

\item{right_backbone}{A backbone (other than a disconnected backbone), see \code{\link[=list_backbones]{list_backbones()}}.}

\item{num_common_modules}{The number of modules which are regulated by either backbone.}
}
\value{
A list of all the available backbone generators.
}
\description{
A module is a group of genes which, to some extent, shows the same
expression behaviour. Several modules are connected together such that
one or more genes from one module will regulate the expression of
another module. By creating chains of modules, a dynamic behaviour in gene
regulation can be created.
}
\examples{
names(list_backbones())

bb <- backbone_bifurcating()
bb <- backbone_bifurcating_converging()
bb <- backbone_bifurcating_cycle()
bb <- backbone_bifurcating_loop()
bb <- backbone_binary_tree()
bb <- backbone_branching()
bb <- backbone_consecutive_bifurcating()
bb <- backbone_converging()
bb <- backbone_cycle()
bb <- backbone_cycle_simple()
bb <- backbone_disconnected()
bb <- backbone_linear()
bb <- backbone_linear_simple()
bb <- backbone_trifurcating()

model <- initialise_model(
  backbone = bb
)
}
\seealso{
\link{dyngen} on how to run a dyngen simulation
}
