# Mossy Forest with WGCNA Module Detection

Runs a Weighted Gene Co expression Network Analysis (WGCNA) to derive
module membership, then passes the result to
[`mf`](https://timothyzshen.github.io/mossyforest/reference/mf.md).

## Usage

``` r
wmf(
  X,
  y,
  WGCNA_params = WGCNA_control(power = 6),
  screen_params = screen_control(),
  select_params = select_control(),
  final_ntree = 500L,
  nodesize = NULL,
  num_processors = 1L,
  max_modsize = 5000L,
  verbose = 1L,
  seed = as.integer(Sys.time()),
  backend = "python",
  r_shap = "permutation",
  compute_interactions = TRUE
)
```

## Arguments

- X:

  A data frame where each column is a feature.

- y:

  Response vector (numeric for regression, factor for classification).

- WGCNA_params:

  WGCNA parameters. See
  [`WGCNA_control`](https://timothyzshen.github.io/mossyforest/reference/WGCNA_control.md).

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

- compute_interactions:

  Logical. If `TRUE` (default), the TreeSHAP interaction matrix is
  computed by the Python backend and by the pure R backend with
  `r_shap = "treeshap"`. Set `FALSE` to skip it (faster);
  [`detect_interaction()`](https://timothyzshen.github.io/mossyforest/reference/detect_interaction.md)
  and
  [`plot_potential_interactions()`](https://timothyzshen.github.io/mossyforest/reference/plot_potential_interactions.md)
  then have nothing to use. It has no effect with
  `r_shap = "permutation"`, which never computes interactions.

## Value

An object of class
[`mossy_forest`](https://timothyzshen.github.io/mossyforest/reference/mossy_forest.md)
with an additional `$WGCNA_object` slot containing the raw WGCNA output.

## References

Zhang, B., & Horvath, S. (2005). A general framework for weighted gene
co expression network analysis. *Statistical Applications in Genetics
and Molecular Biology*, 4(1), Article 17.

## Examples

``` r
# \donttest{
# Two blocks of correlated features; WGCNA finds the modules
set.seed(1)
n <- 30
z1 <- rnorm(n); z2 <- rnorm(n)
block <- function(k, zz) as.data.frame(replicate(k, zz + rnorm(n, sd = 0.4)))
X <- cbind(block(10, z1), block(10, z2))
colnames(X) <- paste0("g", seq_len(ncol(X)))
y <- z1 - z2 + rnorm(n, sd = 0.3)
fit <- wmf(X, y, WGCNA_params = WGCNA_control(power = 6, min_features = 6),
           screen_params = screen_control(min_ntree = 30),
           select_params = select_control(n_reps = 3, min_ntree = 30),
           final_ntree = 30, backend = "R", verbose = 0, seed = 1)
table(fit$WGCNA_object$colors)
#> 
#>      blue turquoise 
#>        10        10 
# }
```
