# Plot Elbow Plot of Absolute SHAP Values for a Mossy Forest Object

Ranks stable features by their importance score and displays an elbow
(scree) plot, optionally colored by module membership. The score is mean
\|SHAP\| for the Python backend and for the pure R backend with
`r_shap = "treeshap"`, and ranger permutation importance for
`r_shap = "permutation"`.

## Usage

``` r
plot_elbow(object, ...)

# S3 method for class 'mossy_forest'
plot_elbow(
  object,
  main = NULL,
  xlab = NULL,
  ylab = NULL,
  colorName = NULL,
  color = TRUE,
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

  Plot title. Default `"Elbow Plot of Absolute SHAP Values"`
  (`"Elbow Plot of Variable Importance"` when the fit has no SHAP
  scores).

- xlab:

  X axis label. Default `"Features"`.

- ylab:

  Y axis label. Default `"Absolute SHAP Values"`
  (`"Variable Importance"` when the fit has no SHAP scores).

- colorName:

  Legend title for module color. Default `"Module"`.

- color:

  Color points by module membership? Default `TRUE`.

- module_labels:

  Optional two column data frame of label mappings. Default `NULL`.

## Value

A `ggplot2` object (invisibly).

## Methods (by class)

- `plot_elbow(mossy_forest)`: Elbow plot for a `mossy_forest` object.

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
plot_elbow(fit)
```
