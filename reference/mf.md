# Mossy Forest Feature Selection

Runs the Mossy Forest algorithm.

## Usage

``` r
mf(
  X,
  y,
  module_membership,
  screen_params = screen_control(),
  select_params = select_control(),
  final_ntree = 500L,
  nodesize = NULL,
  num_processors = 1L,
  max_modsize = 5000L,
  verbose = 1L,
  seed = as.integer(Sys.time()),
  compute_interactions = TRUE,
  backend = "python",
  r_shap = "permutation"
)
```

## Arguments

- X:

  A data frame where each column is a feature.

- y:

  Response vector (numeric for regression, factor for classification).

- module_membership:

  A named character vector assigning each feature in `X` to a module.
  Names must match `colnames(X)`. Modules named in
  `select_control(unassigned_modules)` form the unassigned pool, which
  is selected with its own elbow based threshold; all other modules use
  `pi_thr`.

- screen_params:

  Screening parameters. See
  [`screen_control`](https://timothyzshen.github.io/mossyforest/reference/screen_control.md).

- select_params:

  Selection parameters. See
  [`select_control`](https://timothyzshen.github.io/mossyforest/reference/select_control.md).

- final_ntree:

  Number of trees in the final random forest. Default `500`.

- nodesize:

  Minimum terminal node size. Defaults to `1` for classification and `5`
  for regression.

- num_processors:

  Number of parallel threads for random forests. Default `1`.

- max_modsize:

  Maximum module size before blockwise pre reduction is applied (Python
  backend only). Default `5000`.

- verbose:

  Verbose level. `0` = silent; `1` = progress messages; `2` = detailed
  output. Default `1`.

- seed:

  Integer random seed for reproducibility. Defaults to current system
  time.

- compute_interactions:

  Logical. If `TRUE` (default), the TreeSHAP interaction matrix is
  computed by the Python backend and by the pure R backend with
  `r_shap = "treeshap"`. Set `FALSE` to skip it (faster);
  [`detect_interaction()`](https://timothyzshen.github.io/mossyforest/reference/detect_interaction.md)
  and
  [`plot_potential_interactions()`](https://timothyzshen.github.io/mossyforest/reference/plot_potential_interactions.md)
  then have nothing to use. It has no effect with
  `r_shap = "permutation"`, which never computes interactions.

- backend:

  Computation backend. `"python"` (default) uses a Python scikit-learn /
  SHAP engine via reticulate and provides exact TreeSHAP values plus an
  interaction matrix. `"R"` uses a R ranger implementation, no Python
  installation required. Choose the final importance method with
  `r_shap`.

- r_shap:

  Final SHAP / importance method used when `backend = "R"`. Ignored for
  the Python backend. One of:

  `"permutation"`

  :   Ranger permutation variable importance (default). No extra
      packages needed. Returns a scalar VIM per feature; per observation
      SHAP values and SHAP based plots are unavailable.

  `"treeshap"`

  :   Exact TreeSHAP values via the R treeshap package. Requires
      treeshap. Also computes a \\p \times p\\ interaction matrix,
      enabling
      [`detect_interaction()`](https://timothyzshen.github.io/mossyforest/reference/detect_interaction.md)
      and
      [`plot_potential_interactions()`](https://timothyzshen.github.io/mossyforest/reference/plot_potential_interactions.md).

## Value

An object of class
[`mossy_forest`](https://timothyzshen.github.io/mossyforest/reference/mossy_forest.md).

## References

Chernozhukov, V., Chetverikov, D., Demirer, M., Duflo, E., Hansen, C.,
Newey, W., & Robins, J. (2018). Double/cross-fit residualed machine
learning for treatment and structural parameters. *The Econometrics
Journal*, 21(1), C1-C68.

Lundberg, S. M., & Lee, S. I. (2017). A unified model for interpreting
predictions. *NeurIPS*, 30.

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
print(fit)
#> --- Mossy Forest ---
#> Stable features selected: 2
#> 
#>   feature_name variable_importance module_membership
#> 1           a1              0.5034                 A
#> 2           a2              0.4403                 A
#> 
#> OOB prediction error: 0.1831
head(fit$final_SHAP)
#>   feature_name variable_importance module_membership
#> 1           a1              0.5034                 A
#> 2           a2              0.4403                 A

if (FALSE) { # \dontrun{
# The Python backend (exact TreeSHAP) needs a configured Python environment
mf_setup(condaenv = "sfenv")
fit_py <- mf(X, y, module_membership = membership, backend = "python")
plot_importance(fit_py)
} # }
```
