# `mossyforest`: Module aware Optimal Shap StabilitY (MOSSY) Forest

<!-- badges: start -->
[![R-CMD-check](https://github.com/timothyzshen/mossyforest/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/timothyzshen/mossyforest/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->
  
A tree based network aware stable feature selection with SHAPley values and random forests for high dimensional and correlated data.

**R Package** `mossyforest` selects a stable set of features from high dimensional correlated data through three phases:

1. **Module stratified screening** — recursive feature elimination (RFE) within each correlated module (defined by WGCNA).
2. **Shadow stability selection** — Boruta style subsample selection where each feature must beat its own permuted "shadow" feature across many resamples.
3. **A single RF + TreeSHAP pass** on the stable set to optain SHAP importance values.

A [Python implementation](https://github.com/timothyzshen/mossyforest-py) is the python version of this package. In fact, the python package is bit exact with the `backend = "python"` path 
(see [Parity](#parity-with-the-python-package)).

---

## Installation

```r
if (!require("devtools", quietly = TRUE))
       install.packages("devtools")
library(devtools)
devtools::install_github("timothyzshen/mossyforest")
```

The default `backend = "python"` uses `reticulate` and needs a Python environment with `scikit-learn`, `shap`, and `numpy`. Run `mf_setup()` once to set it up. 
The `backend = "R"` path is pure R (`ranger`) with `r_shap = "permutation"` or `"treeshap"`. 
Note that the two implementations are different estimations of SHAP values. See [Lundberg and Lee (2017),
*A Unified Approach to Interpreting Model Predictions*](https://proceedings.neurips.cc/paper/7062-a-unified-approach-tointerpreting-model-predictions.pdf).


### A note on downloading `WGCNA`

`WGCNA` (used by `wmf()` for WGCNA module membership) installs from Bioconductor:

```r
if (!require("BiocManager", quietly = TRUE))
       install.packages("BiocManager")
BiocManager::install(version = "3.20")
BiocManager::install(c("GO.db", "preprocessCore", "impute"))  # dependencies
install.packages("WGCNA")
```

---

## Quick start

```r
library(mossyforest)

# X: data.frame of samples x features; y: numeric (regression) or factor (classification)
res <- mf(
  X, y,
  module_membership = c(gene1 = "M1", gene2 = "M1", gene3 = "M2", ...),
  screen_params = screen_control(),   # Screening Phase defaults
  select_params = select_control(),   # Shadow Stability Phase defaults
  num_processors = 4, # parallel replicates / modules
  seed = 2002
)

res$final_SHAP  # stable features: importance, mean|SHAP|, 95% CIs, freq
```

### Using MossyForest with WGCNA module detection

```r
res <- wmf(X, y, WGCNA_params = WGCNA_control(power = 6, min_features = 20))
res$WGCNA_object # raw module labels
```

---

## Backends

| `backend` | engine | SHAP Method | notes |
|---|---|---|---|
| `"python"` (default) | scikit-learn RF | TreeSHAP (`shap`) | bit exact with the Python package requires `reticulate` |
| `"R"` | `ranger` | set by `r_shap` | pure R, no Python |

For `backend = "R"`, `r_shap` selects how features are ranked in **screening, stability selection, and the final step**:

- `"permutation"` — ranger permutation importance; fastest.
- `"treeshap"` — TreeSHAP throughout (needs the `treeshap` package; classification support depends on the installed `treeshap` version). Slower.

The pure R backend is aligned with the Python package but is not identical (ranger vs scikit-learn, and a different SHAP
engine).

---

## Parameters

### `screen_control` — Phase 1 (screening)
| param | default | meaning |
|---|---|---|
| `drop_fraction` | 0.25 | fraction of features dropped per RFE step |
| `keep_fraction` | 0.50 | fraction of each module kept after screening |
| `mtry_factor` | 1.0 | `mtry` multiplier |
| `mtry_rule` | `"auto"` | `mtry` rule: `"auto"` ($\sqrt{p}$ classification, $p/3$ reg), `"sqrt"`, `"p_over_3"` |
| `min_ntree` | 500 | minimum trees per forest |
| `ntree_factor` | 1 | trees = `max(p * factor, min_ntree)` |

### `select_control` — Phase 2 (shadow stability)
| param | default | meaning |
|---|---|---|
| `mtry_factor` | 1.0 | `mtry` multiplier |
| `mtry_rule` | `"auto"` | see `screen_control` |
| `mtry_on_real` | `FALSE` | size `mtry` on real features only (not the shadows) |
| `min_ntree` / `ntree_factor` | 500 / 1 | tree count controls |
| `shadow_mode` | `"split"` | `"split"` (corr + unassigned pools) or `"within_module"` |
| `n_reps` | 50 | subsample replicates (half the rows, drawn without replacement) |
| `pi_thr` | 0.60 | stability threshold for the correlated pool |
| `pi_thr_unassigned` | `NULL` | unassigned pool threshold (`NULL` = elbow detection) |
| `threshold_mode` | `"pi_thr"` | `"pi_thr"` (R default) or `"elbow"` (both pools) |
| `shadow_percentile` | 95 | percentile of the shadow null used as the cutoff |
| `unassigned_modules` | `NULL` | module names treated as the unassigned pool |
| `use_cfres` | `FALSE` | cross fitted cfRes residualization of `y` |
| `cfres_n_folds` / `cfres_ntree` | 5 / 300 | cfRes cross fitting controls |
| `cfres_scope` | `"unassigned"` | `"unassigned"` or `"all_modules"` |
| `early_stop` | `FALSE` | stop replicates early once frequencies converge |
| `early_stop_tol` / `early_stop_check_every` | 0.01 / 10 | early stop controls |

### `mf()` execution
| param | default | meaning |
|---|---|---|
| `backend` | `"python"` | `"python"` or `"R"` (see [Backends](#backends)) |
| `r_shap` | `"permutation"` | SHAP method for `backend = "R"` |
| `num_processors` | 1 | parallel workers for replicates + modules |
| `compute_interactions` | `TRUE` | retain the RF so interactions compute lazily |
| `final_ntree` | — | trees in the final model |
| `seed` | — | RNG seed (matches the Python package's scheme) |

---

## Result object (class `mossy_forest`)

| element | description |
|---|---|
| `final_SHAP` | stable features: importance, mean\|SHAP\|, 95% CIs, stability freq |
| `shap_obj$shapley_values` | signed n×p SHAP matrix |
| `stability_freq` | per feature shadow subsample selection frequency |
| `stability_data` | per pool stability curves (for `plot_stability_elbow`) |
| `survivor_list` | Phase 1 survivors per module |
| `final_rf` / `final_X` | the fitted final forest and its design matrix |
| `runtimes` | seconds for Screen / Selection / Final_RF |

---

## Plots

```r
plot_importance(res) # beeswarm / bar SHAP importance
plot_signed_importance(res)
plot_waterfall(res); plot_force(res); plot_decisions(res)
plot_stability(res); plot_stability_elbow(res)     # per pool selection curves
plot_potential_interactions(res)  # TreeSHAP interaction heatmap
plot_modules(res); plot_elbow(res)
```

---

## Parity with the Python package

The `backend = "python"` path and the Python `mossyforest` package are a
bit exact match on identical data, random seed, and stack. It is shown that the screening 
survivors and the selected set are identical, stability frequencies agree to 0.0000, and the
signed SHAP matrix matches (max \|Δ\| = 0.000). You can re verify with
`benchmarks/parity_in_process.py` in the Python repository.

---

## License

GPL-3.0-or-later.
