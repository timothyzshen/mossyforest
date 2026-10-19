# Plot SHAP Force Plot for Specific Observations in a Mossy Forest Object

Generates a SHAP force plot for one or more observations. Plots are
built via
[shapviz](https://modeloriented.github.io/shapviz/reference/shapviz.html).

## Usage

``` r
plot_force(object, ...)

# S3 method for class 'mossy_forest'
plot_force(
  object,
  row_id,
  row_name = NULL,
  max_display = NULL,
  fill_colors = c("#59c46b", "#3b528b"),
  contrast = TRUE,
  bar_label_size = 3.2,
  show_annotation = TRUE,
  ...
)
```

## Arguments

- object:

  A `mossy_forest` object.

- ...:

  Ignored.

- row_id:

  Row index (or indices) for the observation(s) to plot.

- row_name:

  Optional name(s) for the observation(s).

- max_display:

  Maximum number of features to display. `NULL` shows all. Default
  `NULL`.

- fill_colors:

  Length 2 vector of colors. Default `c("#59c46b", "#3b528b")`.

- contrast:

  Apply text/arrow contrast? Default `TRUE`.

- bar_label_size:

  Label size on bars. Default `3.2`.

- show_annotation:

  Annotate bars. Default `TRUE`.

## Value

A `ggplot2` object (invisibly).

## Methods (by class)

- `plot_force(mossy_forest)`: Force plot for a `mossy_forest` object.

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
plot_force(fit, row_id = 1)
```
