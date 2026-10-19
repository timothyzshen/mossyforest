# Plot Potential Interaction Matrix for a Mossy Forest Object

Generates a heatmap of pairwise SHAP based potential interaction
strengths for all stable features.

## Usage

``` r
plot_potential_interactions(object, ...)

# S3 method for class 'mossy_forest'
plot_potential_interactions(object, ...)
```

## Arguments

- object:

  A `mossy_forest` object.

- ...:

  Ignored.

## Value

A `ggplot2` object (invisibly).

## Methods (by class)

- `plot_potential_interactions(mossy_forest)`: Interaction heatmap for a
  `mossy_forest` object (uses exact TreeSHAP interaction values).

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
          final_ntree = 50, backend = "R", r_shap = "treeshap", verbose = 0, seed = 1)
plot_potential_interactions(fit)
```
