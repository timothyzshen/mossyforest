# Selection Step Parameters

Creates a parameter object controlling the shadow stability selection
step of
[`mf`](https://timothyzshen.github.io/mossyforest/reference/mf.md).

## Usage

``` r
select_control(
  mtry_factor = 1,
  mtry_rule = "auto",
  mtry_on_real = FALSE,
  min_ntree = 500L,
  ntree_factor = 1,
  shadow_mode = "split",
  n_reps = 50L,
  pi_thr = 0.6,
  pi_thr_unassigned = NULL,
  threshold_mode = "pi_thr",
  shadow_percentile = 95,
  unassigned_modules = NULL,
  use_cfres = FALSE,
  cfres_n_folds = 5L,
  cfres_ntree = 300L,
  cfres_scope = "unassigned",
  early_stop = FALSE,
  early_stop_tol = 0.01,
  early_stop_check_every = 10L
)
```

## Arguments

- mtry_factor:

  `mtry` multiplier for random forests. Default `1`.

- mtry_rule:

  How `mtry` is derived from the feature count. One of `"auto"`
  (default), `"sqrt"`, `"p_over_3"`. See
  [`screen_control`](https://timothyzshen.github.io/mossyforest/reference/screen_control.md).
  Unlike screening, a single stability selection run can fit BOTH
  classification and regression forests even though `y` is one fixed
  type. For instance, when `use_cfres = TRUE`, any pool that gets cfRes
  residualized (see `cfres_scope`) turns continuous for that pool's own
  forest.

- mtry_on_real:

  Logical. If `TRUE`, `mtry` on the augmented \\\[real \| shadow\]\\
  matrix is `2 * rule(p_real)` so real feature sampling is not diluted
  by the shadows. Default `FALSE`.

- min_ntree:

  Minimum trees per forest. Default `500`.

- ntree_factor:

  Trees per forest scaling factor. Default `1`.

- shadow_mode:

  Shadow stability pooling strategy. One of `"split"` (correlated and
  unassigned pools evaluated separately) or `"within_module"` (one
  shadow run per module). Default `"split"`.

- n_reps:

  Number of subsample replicates for shadow stability (each draws half
  the rows without replacement). Default `50`.

- pi_thr:

  Stability frequency threshold for correlated pool features. A feature
  is selected if its shadow win rate across replicates exceeds `pi_thr`.
  Default `0.60`.

- pi_thr_unassigned:

  Stability threshold for the unassigned pool. `NULL` (default) uses an
  automatic elbow detection rule. We recommend keeping this `NULL`.

- threshold_mode:

  Selection cutoff rule. `"pi_thr"` (default) uses the fixed `pi_thr`
  for the correlated pool and elbow detection for the unassigned pool.
  `"elbow"` applies the adaptive elbow rule to *both* pools.

- shadow_percentile:

  Percentile of the shadow feature distribution used as the importance
  threshold within each replicate. Default `95`.

- unassigned_modules:

  Character vector of module names treated as the unassigned pool (e.g.
  `"M10_unassigned"`). Names must match values in `module_membership`; a
  name that matches no module gives a warning. `NULL` disables split
  pool logic.

- use_cfres:

  Logical. If `TRUE`, a cross fitted random forest is used to
  residualize `y` before the unassigned pool stability step, reducing
  confounding from correlated modules. Default `FALSE`.

- cfres_n_folds:

  Number of cross fitting folds for cfRes residualization. Default `5`.

- cfres_ntree:

  Trees per fold forest in cfRes residualization. Default `300`.

- cfres_scope:

  Scope of cfRes residualization. `"unassigned"` (default) applies cfRes
  only to the unassigned pool. `"all_modules"` applies per module cfRes
  to every module (removes the contribution of all other modules before
  that module's stability run).

- early_stop:

  Logical. If `TRUE`, stop the replicate loop once selection frequencies
  converge. Default `FALSE`.

- early_stop_tol:

  Convergence tolerance for `early_stop`: stop when the largest change
  in any feature's frequency between batches falls below this. Default
  `0.01`.

- early_stop_check_every:

  Replicates per batch. Convergence is checked between batches. Default
  `10`.

## Value

An object of class `select_control`.

## See also

[`screen_control`](https://timothyzshen.github.io/mossyforest/reference/screen_control.md),
[`mf`](https://timothyzshen.github.io/mossyforest/reference/mf.md)

## Examples

``` r
select_control()
#> $mtry_factor
#> [1] 1
#> 
#> $mtry_rule
#> [1] "auto"
#> 
#> $mtry_on_real
#> [1] FALSE
#> 
#> $min_ntree
#> [1] 500
#> 
#> $ntree_factor
#> [1] 1
#> 
#> $shadow_mode
#> [1] "split"
#> 
#> $n_reps
#> [1] 50
#> 
#> $pi_thr
#> [1] 0.6
#> 
#> $pi_thr_unassigned
#> NULL
#> 
#> $threshold_mode
#> [1] "pi_thr"
#> 
#> $shadow_percentile
#> [1] 95
#> 
#> $unassigned_modules
#> NULL
#> 
#> $use_cfres
#> [1] FALSE
#> 
#> $cfres_n_folds
#> [1] 5
#> 
#> $cfres_ntree
#> [1] 300
#> 
#> $cfres_scope
#> [1] "unassigned"
#> 
#> $early_stop
#> [1] FALSE
#> 
#> $early_stop_tol
#> [1] 0.01
#> 
#> $early_stop_check_every
#> [1] 10
#> 
#> attr(,"class")
#> [1] "select_control"
# cross fitted residualization of the outcome, with a stricter threshold
select_control(n_reps = 20, pi_thr = 0.7, use_cfres = TRUE)
#> $mtry_factor
#> [1] 1
#> 
#> $mtry_rule
#> [1] "auto"
#> 
#> $mtry_on_real
#> [1] FALSE
#> 
#> $min_ntree
#> [1] 500
#> 
#> $ntree_factor
#> [1] 1
#> 
#> $shadow_mode
#> [1] "split"
#> 
#> $n_reps
#> [1] 20
#> 
#> $pi_thr
#> [1] 0.7
#> 
#> $pi_thr_unassigned
#> NULL
#> 
#> $threshold_mode
#> [1] "pi_thr"
#> 
#> $shadow_percentile
#> [1] 95
#> 
#> $unassigned_modules
#> NULL
#> 
#> $use_cfres
#> [1] TRUE
#> 
#> $cfres_n_folds
#> [1] 5
#> 
#> $cfres_ntree
#> [1] 300
#> 
#> $cfres_scope
#> [1] "unassigned"
#> 
#> $early_stop
#> [1] FALSE
#> 
#> $early_stop_tol
#> [1] 0.01
#> 
#> $early_stop_check_every
#> [1] 10
#> 
#> attr(,"class")
#> [1] "select_control"
```
