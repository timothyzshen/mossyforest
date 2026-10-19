# Plot Shadow Stability Frequencies for a Mossy Forest Object

Displays the subsample shadow stability selection frequency for each
stable feature as a horizontal bar chart. Features are sorted by
frequency.

## Usage

``` r
plot_stability(object, ...)

# S3 method for class 'mossy_forest'
plot_stability(
  object,
  fill = "#3e568a",
  main = "Shadow Stability Frequencies",
  ...
)
```

## Arguments

- object:

  A `mossy_forest` object.

- ...:

  Ignored.

- fill:

  Bar color. Default `"#3e568a"`.

- main:

  Plot title. Default `"Shadow Stability Frequencies"`.

## Value

A `ggplot2` object (invisibly).

## Methods (by class)

- `plot_stability(mossy_forest)`: Stability frequency plot for a
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
plot_stability(fit)
```
