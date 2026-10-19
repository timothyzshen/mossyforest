# Plot Module Membership Distribution for a Mossy Forest Object

Shows the proportion of features per module that were selected as
stable, colored by selection status.

## Usage

``` r
plot_modules(object, ...)

# S3 method for class 'mossy_forest'
plot_modules(
  object,
  main = NULL,
  xlab = NULL,
  ylab = NULL,
  module_labels = NULL,
  ...
)
```

## Arguments

- object:

  A `mossy_forest` object.

- ...:

  Ignored.

- main:

  Plot title. Default `"Module Membership Distribution"`.

- xlab:

  X axis label. Default `"Module"`.

- ylab:

  Y axis label. Default `"Proportion of features"`.

- module_labels:

  Optional two column data frame mapping old module labels to new
  display labels. Default `NULL`.

## Value

A `ggplot2` object (invisibly).

## Methods (by class)

- `plot_modules(mossy_forest)`: Module membership plot for a
  `mossy_forest` object.

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
plot_modules(fit)
```
