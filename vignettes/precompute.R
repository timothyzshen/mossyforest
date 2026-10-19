# Re-knit the precomputed vignette. Run from the package root after installing
# the current package: source("vignettes/precompute.R")
# Needs WGCNA and a Python environment with scikit-learn, shap and numpy.
local({
  old <- setwd("vignettes")
  on.exit(setwd(old))
  Sys.setenv(NOT_CRAN = "true")
  knitr::knit("mossyforest.Rmd.orig", "mossyforest.Rmd")
})
