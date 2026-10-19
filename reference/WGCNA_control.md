# WGCNA Parameter Organization

Creates a parameter object for the WGCNA co expression network step used
by [`wmf`](https://timothyzshen.github.io/mossyforest/reference/wmf.md).

## Usage

``` r
WGCNA_control(power = 6, min_features = 20, ...)
```

## Arguments

- power:

  Soft thresholding power passed to
  [`blockwiseModules`](https://rdrr.io/pkg/WGCNA/man/blockwiseModules.html).
  Default `6`.

- min_features:

  Minimum module size, passed to
  [`blockwiseModules`](https://rdrr.io/pkg/WGCNA/man/blockwiseModules.html)
  as `minModuleSize`. Features in clusters smaller than this are left
  unassigned. Default `20`.

- ...:

  Additional arguments forwarded to
  [`blockwiseModules`](https://rdrr.io/pkg/WGCNA/man/blockwiseModules.html).

## Value

An object of class `WGCNA_control`.

## Examples

``` r
WGCNA_control()
#> $power
#> [1] 6
#> 
#> $min_features
#> [1] 20
#> 
#> $extra_args
#> list()
#> 
#> attr(,"class")
#> [1] "WGCNA_control"
# extra arguments are passed on to WGCNA::blockwiseModules()
WGCNA_control(power = 8, min_features = 30, deepSplit = 2)
#> $power
#> [1] 8
#> 
#> $min_features
#> [1] 30
#> 
#> $extra_args
#> $extra_args$deepSplit
#> [1] 2
#> 
#> 
#> attr(,"class")
#> [1] "WGCNA_control"
```
