# Predict from a Mossy Forest Object

Generates predictions from the final random forest fitted on the stable
feature set.

## Usage

``` r
# S3 method for class 'mossy_forest'
predict(object, new_data, ...)
```

## Arguments

- object:

  A `mossy_forest` object.

- new_data:

  A matrix or data frame of new observations. Column names must match
  the training features.

- ...:

  Additional arguments passed to
  [`predict.ranger`](http://imbs-hl.github.io/ranger/reference/predict.ranger.md).

## Value

A `ranger` prediction object. Predictions always come from the `ranger`
forest refit on the stable features, whichever backend selected them.

## Examples

``` r
# A small simulated regression problem with two modules of features
set.seed(1)
n <- 60
z <- rnorm(n)
X <- data.frame(a1 = z + rnorm(n, sd = 0.3), a2 = z + rnorm(n, sd = 0.3),
                a3 = z + rnorm(n, sd = 0.3), b1 = rnorm(n), b2 = rnorm(n),
                b3 = rnorm(n))
y <- z + rnorm(n, sd = 0.3)
membership <- c(a1 = "A", a2 = "A", a3 = "A", b1 = "B", b2 = "B", b3 = "B")

# The pure R backend needs no Python installation
fit <- mf(X, y, module_membership = membership,
          screen_params = screen_control(min_ntree = 50),
          select_params = select_control(n_reps = 10, min_ntree = 50),
          final_ntree = 50, backend = "R", verbose = 0, seed = 1)
predict(fit, X[1:5, ])$predictions
#> [1] -0.34108607  0.08524273 -0.74515475  1.27604719  0.17627111
```
