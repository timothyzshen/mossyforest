## Test environments

* local macOS 26.6 (aarch64), R 4.4.3
* Windows Server 2022 (win-builder), R Under development (2026-10-18 r90707 ucrt)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

## Notes for the reviewer

* The default backend uses Python (scikit-learn, shap, numpy) through
  reticulate and is listed in `SystemRequirements`. Python is not needed to
  install or load the package, and nothing is installed or downloaded
  automatically. The examples and the vignette do not need Python, the pure R
  backend (`backend = "R"`) runs without it, and the tests that use Python are
  skipped on CRAN.
* The vignette is precomputed. Its source is `vignettes/mossyforest.Rmd.orig`
  and it is rebuilt with `vignettes/precompute.R`.
* `WGCNA` and `treeshap` are in `Suggests` and are only used when installed.
* The `leukemia` and `wdi` datasets are derived from the Bioconductor `ALL`
  package (Artistic-2.0) and the World Bank World Development Indicators
  (CC BY 4.0); the sources, licenses and changes are documented in the help
  pages.
