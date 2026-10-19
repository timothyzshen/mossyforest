# Screening Step Parameters

Creates a parameter object controlling the screening (recursive feature
elimination) step of
[`mf`](https://timothyzshen.github.io/mossyforest/reference/mf.md).

## Usage

``` r
screen_control(
  drop_fraction = 0.25,
  keep_fraction = 0.5,
  mtry_factor = 1,
  mtry_rule = "auto",
  min_ntree = 500L,
  ntree_factor = 1
)
```

## Arguments

- drop_fraction:

  Fraction of features dropped at each RFE iteration. Default `0.25`.

- keep_fraction:

  Fraction of features retained per module after screening. Default
  `0.50`.

- mtry_factor:

  Multiplier applied to the `mtry_rule`'s base value to derive `mtry`
  for each screening random forest
  (`mtry = ceiling(mtry_factor * base)`, constrained to `[1, p]`).
  Default `1`.

- mtry_rule:

  How `mtry` is derived from the feature count `p`. `"auto"` (default)
  uses `sqrt(p)` for classification and `p/3` for regression. `"sqrt"`
  uses `sqrt(p)` for classification AND regression. `"p_over_3"` uses
  `p/3` for classification AND regression.

- min_ntree:

  Minimum number of trees per screening forest. Default `500`.

- ntree_factor:

  Trees per forest = `max(p * ntree_factor, min_ntree)`. Default `1`.

## Value

An object of class `screen_control`.

## See also

[`select_control`](https://timothyzshen.github.io/mossyforest/reference/select_control.md),
[`mf`](https://timothyzshen.github.io/mossyforest/reference/mf.md)

## Examples

``` r
screen_control()
#> $drop_fraction
#> [1] 0.25
#> 
#> $keep_fraction
#> [1] 0.5
#> 
#> $mtry_factor
#> [1] 1
#> 
#> $mtry_rule
#> [1] "auto"
#> 
#> $min_ntree
#> [1] 500
#> 
#> $ntree_factor
#> [1] 1
#> 
#> attr(,"class")
#> [1] "screen_control"
screen_control(drop_fraction = 0.1, keep_fraction = 0.3, min_ntree = 200)
#> $drop_fraction
#> [1] 0.1
#> 
#> $keep_fraction
#> [1] 0.3
#> 
#> $mtry_factor
#> [1] 1
#> 
#> $mtry_rule
#> [1] "auto"
#> 
#> $min_ntree
#> [1] 200
#> 
#> $ntree_factor
#> [1] 1
#> 
#> attr(,"class")
#> [1] "screen_control"
```
