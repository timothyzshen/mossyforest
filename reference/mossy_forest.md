# Mossy Forest Object

Output for the `mossy_forest` return type.

## Usage

``` r
mossy_forest(
  final_rf,
  final_X,
  module_membership,
  WGCNA_object = NULL,
  survivor_list,
  selection_list,
  final_shap,
  shap_obj,
  runtime,
  feature_list = NULL,
  stability_freq = NULL,
  stability_data = NULL
)
```

## Arguments

- final_rf:

  Final `ranger` object fitted on the stable feature set.

- final_X:

  Data frame of features in the stable set.

- module_membership:

  Data frame mapping each feature to its module.

- WGCNA_object:

  WGCNA output object, or `NULL`.

- survivor_list:

  Per module screening survivors.

- selection_list:

  Feature lists at each selection iteration.

- final_shap:

  Data frame of stable features with mean absolute SHAP, 95 percent CIs,
  and shadow stability frequencies.

- shap_obj:

  List with elements `shapley_values` (signed SHAP matrix, samples x
  stable features) and `interaction_matrix` (mean absolute TreeSHAP
  interaction matrix, stable features x stable features). `NULL` when
  unavailable. For binary classification, signed values (and
  `final_shap`'s `direction` / `dir_corr` / `signed_importance`)
  describe the probability of `levels(y)[1]`, the first level of the
  outcome factor. Relevel `y` if you want a different reference class.

- runtime:

  Named list of runtimes (seconds): Screen, Selection, Final_RF.

- feature_list:

  Data frame of the stable feature set with importance scores.

- stability_freq:

  Named numeric vector. Shadow subsample selection frequency per stable
  feature.

- stability_data:

  Data frame with per pool shadow stability curves used by
  [`plot_stability_elbow`](https://timothyzshen.github.io/mossyforest/reference/plot_stability_elbow.md).
  Columns are `pool`, `rank`, `feature`, `freq`, `selected`,
  `threshold`, `elbow_rank`. `NULL` if unavailable.

## Value

An object of class `mossy_forest`.
