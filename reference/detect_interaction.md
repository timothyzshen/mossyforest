# Detect Pairwise Interactions from a Mossy Forest Object

Returns TreeSHAP pairwise interaction strengths for all stable features.
Interaction values are computed during model fitting and stored in the
object, either by the Python backend
(`TreeExplainer.shap_interaction_values()`) or by the pure R backend
with `r_shap = "treeshap"`. They are not available with
`r_shap = "permutation"` or when `compute_interactions = FALSE`.

## Usage

``` r
detect_interaction(object, thresh = 0, all = FALSE, verbose = TRUE, ...)
```

## Arguments

- object:

  A `mossy_forest` object.

- thresh:

  Interaction strength threshold. Only pairs whose mean
  \\\|\phi\_{jk}\|\\ exceeds `thresh` are returned (those above the
  threshold). Set to `0` to return all pairs.

- all:

  If `TRUE`, return every off diagonal pair (upper triangle) regardless
  of `thresh`. Default `FALSE`.

- verbose:

  If `TRUE`, print the table of above threshold pairs (or a message if
  none are found). Default `TRUE`.

- ...:

  Ignored.

## Value

A data frame with columns `FeatureA`, `FeatureB`, and
`Interaction_Strength` (mean absolute TreeSHAP interaction), sorted by
interaction strength descending. Invisibly when `all = TRUE`.

## Details

The \\p \times p\\ **interaction matrix** stored in
`object$shap_obj$interaction_matrix` is defined as: \$\$M\_{jk} =
\frac{1}{n}\sum\_{i=1}^{n}\|\phi\_{jk}(x_i)\|\$\$ where
\\\phi\_{jk}(x_i)\\ is the TreeSHAP interaction value for the pair \\(j,
k)\\ at observation \\i\\ (Lundberg et al., 2018). Diagonal entries are
main effects and off diagonal entries are pairwise interactions.

## References

Lundberg, S. M., Erion, G., Chen, H., DeGrave, A., Prutkin, J. M., Nair,
B., Katz, R., Himmelfarb, J., Bansal, N., & Lee, S.-I. (2020). From
local explanations to global understanding with explainable AI for
trees. *Nature Machine Intelligence*, 2, 56-67.

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
detect_interaction(fit)
#>   FeatureA FeatureB Interaction_Strength
#> 1       a1       a2           0.06960101
```
