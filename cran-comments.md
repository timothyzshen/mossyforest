## Test environments

* local macOS 26.6 (aarch64), R 4.4.3
* Windows Server 2022 (win-builder), R Under development (2026-10-18 r90707 ucrt)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

## Some Notes

* The default backend uses Python (scikit-learn, shap, numpy) through
  reticulate and is listed in `SystemRequirements`. Python is not needed to
  install or load the package, and nothing is installed or downloaded
  automatically. The examples and the vignette do not need Python, the pure R
  backend (`backend = "R"`) runs without it, and the tests that use Python are
  skipped on CRAN.
* The methods paper for this package is still under development, will cite when
  completed.
