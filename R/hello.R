#'
#' hello
#'
#' @export

hello <- function() {
  print("Hello, Jared, you are the best!")
}

#'
#'  Data Generate
#'
#'  This a a simple function to create some test data for our model.
#'  The model generate the dat set is that: \deqn{y = \sum_{i = 0}^p \beta_i x_i  + e }{ y = \sum_{i = 0}^p \beta_i x_i  + e }
#'
#'
#' @param n A integer that gives the sample size
#' @param beta A vector gives the coeficients of the true model
#'
#' @return This function returns a list of two element \code{y} and \code{X}
#'
#' @examples
#' gen_dat(n = 100, beta = c(1,1))
#'
#' @export

gen_dat <- function(n = 100, beta = c(1,1)){
  p <- length(beta) -1
  e <- rexp(n, rate =1)
  x <- matrix(rnorm(n*p), ncol = p)
  X <- cbind(rep(1,n), x)
  y <- beta %*% t(X) + e
  list(y = drop(y), X = X)
}

#'
#' Function to optimize
#'
#' This is a function of estimate the coeficients of some sufficient condition
#' from the dataset.
#'
#' @param y A vector that gives the predict variable
#' @param X A matrix that gives the samples of features
#' @param lambda A number to penalize the complexity of the model
#'
#' @return A coeficient of selected feature form the sufficient condition.
#'
#' @importFrom lpSolveAPI make.lp set.column set.constr.type set.rhs set.bounds set.objfn
#' @importFrom magrittr "%>%"
#'
#' @examples
#' d = gen_dat()
#' estcondmin(d$y, d$X, lambda = 0.1)
#'
#' @export
estcondmin <- function(y, X, lambda = 0){
  p <- ncol(X)
  n <- nrow(X)
  c <- colMeans(X)
  w = c(-c, rep(lambda,p))
  A <- cbind(rbind(X, -diag(1,nrow = p), diag(1, nrow = p)),
             rbind(matrix(0,n,p), -diag(1,nrow = p), -diag(1, nrow = p)))
  b <- c(y, rep(0, 2*p))
  # @import lpSolveAPI make.lp set.column set.constr.type set.rhs set.bounds set.objfn

  # library(lpSolveAPI)
  # library(magrittr)
  lps.model <- lpSolveAPI::make.lp(n+ 2*p, 2*p)
  for (i in 1:(2*p)) {
    lpSolveAPI::set.column(lps.model, i, A[,i])
  }
  lpSolveAPI::set.constr.type(lps.model, rep("<=", n + 2*p))
  lpSolveAPI::set.rhs(lps.model, b = b)
  lpSolveAPI::set.bounds(lps.model,lower=rep(-Inf, 2*p),upper=rep(Inf, 2*p))
  lpSolveAPI::set.objfn(lps.model,obj=w)
  solve(lps.model)
  lpSolveAPI::get.variables(lps.model) %>%
    matrix(ncol = 2) %>%
    (function(dat) dat[,1])
}

#'
#' Function 2 to optimize
#'
#' This is a function of estimate the coeficients of some sufficient condition
#' from the dataset.
#'
#' @param y A vector that gives the predict variable
#' @param X A matrix that gives the samples of features
#' @param lambda A number to penalize the complexity of the model
#' @param epsilon A muber of disturb to the central point
#'
#' @importFrom lpSolveAPI make.lp set.column set.constr.type set.rhs set.bounds set.objfn
#' @importFrom magrittr "%>%"
#' @importFrom stats rnorm rexp
#'
#' @return A coeficient of selected feature form the sufficient condition.
#'
#' @examples
#' d = gen_dat()
#' estcondmin(d$y, d$X, lambda = 0.1)
#'
#' @export
estcondmin2 <- function(y, X, lambda = 0, epsilon = 0.01){
  p <- ncol(X)
  n <- nrow(X)
  c <- colMeans(X) + rnorm(1, sd = epsilon)
  w = c(-c, rep(lambda,p))
  A <- cbind(rbind(X, -diag(1,nrow = p), diag(1, nrow = p)),
             rbind(matrix(0,n,p), -diag(1,nrow = p), -diag(1, nrow = p)))
  b <- c(y, rep(0, 2*p))
  # @import lpSolveAPI make.lp set.column set.constr.type set.rhs set.bounds set.objfn
#
#   library(lpSolveAPI)
#   library(magrittr)
  lps.model <- lpSolveAPI::make.lp(n+ 2*p, 2*p)
  for (i in 1:(2*p)) {
    lpSolveAPI::set.column(lps.model, i, A[,i])
  }
  lpSolveAPI::set.constr.type(lps.model, rep("<=", n + 2*p))
  lpSolveAPI::set.rhs(lps.model, b = b)
  lpSolveAPI::set.bounds(lps.model,lower=rep(-Inf, 2*p),upper=rep(Inf, 2*p))
  lpSolveAPI::set.objfn(lps.model,obj=w)
  solve(lps.model)
  lpSolveAPI::get.variables(lps.model) %>%
    matrix(ncol = 2) %>%
    (function(dat) dat[,1])
}
