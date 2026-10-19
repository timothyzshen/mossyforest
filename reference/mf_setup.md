# Configure the Python environment for Mossy Forest

Tells Mossy Forest which Python installation to use for its backend.
Call this once at the start of each R session before using
[`mf`](https://timothyzshen.github.io/mossyforest/reference/mf.md) with
`backend = "python"`. The pure R backend does not need it.

## Usage

``` r
mf_setup(python = NULL, condaenv = NULL, virtualenv = NULL)
```

## Arguments

- python:

  Path to a Python binary. Passed to
  [`reticulate::use_python()`](https://rstudio.github.io/reticulate/reference/use_python.html).

- condaenv:

  Name of a conda environment. Passed to
  [`reticulate::use_condaenv()`](https://rstudio.github.io/reticulate/reference/use_python.html).

- virtualenv:

  Path to a virtual environment. Passed to
  [`reticulate::use_virtualenv()`](https://rstudio.github.io/reticulate/reference/use_python.html).

## Value

Invisible `NULL`.

## Details

The Python environment must have `scikit-learn`, `shap`, and `numpy`
installed. Example setup:


      conda create -n sfenv python=3.11
      conda activate sfenv
      pip install scikit-learn shap numpy

## Examples

``` r
if (FALSE) { # \dontrun{
  mf_setup(condaenv = "sfenv")
  mf_setup(python = "/usr/local/bin/python3")
} # }
```
