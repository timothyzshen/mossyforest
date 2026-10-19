# Print a Mossy Forest Object

Prints the stable feature set with final feature importance scores and
shadow stability selection frequencies.

## Usage

``` r
# S3 method for class 'mossy_forest'
print(x, ...)
```

## Arguments

- x:

  A `mossy_forest` object.

- ...:

  Ignored.

## Value

Invisibly returns `x`.

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
```
