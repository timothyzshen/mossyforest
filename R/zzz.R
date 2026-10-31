# Python Environment
.mf_py <- new.env(parent = emptyenv())
.mf_py$loaded <- FALSE

.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "Mossy Forest loaded. Run mf_setup() to configure the Python environment."
  )
}

#' Configure the Python environment for Mossy Forest
#'
#' Tells Mossy Forest which Python installation to use for its backend.
#' Call this once at the start of each R session before using \code{\link{mf}}
#' with \code{backend = "python"}. The pure R backend does not need it.
#'
#' @param python     Path to a Python binary. Passed to
#'                   \code{reticulate::use_python()}.
#' @param condaenv   Name of a conda environment. Passed to
#'                   \code{reticulate::use_condaenv()}.
#' @param virtualenv Path to a virtual environment. Passed to
#'                   \code{reticulate::use_virtualenv()}.
#'
#' @details
#' The Python environment must have \code{scikit-learn}, \code{shap}, and
#' \code{numpy} installed. Example setup:
#' \preformatted{
#'   conda create -n sfenv python=3.11
#'   conda activate sfenv
#'   pip install scikit-learn shap numpy
#' }
#'
#' @return Invisible \code{NULL}.
#' @export
#' @examples
#' \dontrun{
#'   mf_setup(condaenv = "sfenv")
#'   mf_setup(python = "/usr/local/bin/python3")
#' }
mf_setup <- function(python = NULL, condaenv = NULL, virtualenv = NULL) {
  if (!requireNamespace("reticulate", quietly = TRUE))
    stop("Package 'reticulate' is required. Install with install.packages('reticulate')",
         call. = FALSE)

  if (!is.null(condaenv))
    reticulate::use_condaenv(condaenv, required = TRUE)
  else if (!is.null(virtualenv))
    reticulate::use_virtualenv(virtualenv, required = TRUE)
  else if (!is.null(python))
    reticulate::use_python(python, required = TRUE)

  .load_python_backend()
  invisible(NULL)
}

# Internal: keep seeding inside mossyforest from changing the caller's own
# random number stream. Save the state on entry, restore it with on.exit().
.save_seed <- function() {
  if (exists(".Random.seed", envir = globalenv(), inherits = FALSE))
    get(".Random.seed", envir = globalenv(), inherits = FALSE)
}

.restore_seed <- function(old) {
  if (is.null(old)) {
    if (exists(".Random.seed", envir = globalenv(), inherits = FALSE))
      rm(".Random.seed", envir = globalenv())
  } else {
    assign(".Random.seed", old, envir = globalenv())
  }
  invisible(NULL)
}

# Internal, load the bundled Python backend into .mf_py
.load_python_backend <- function() {
  if (!requireNamespace("reticulate", quietly = TRUE))
    stop("Package 'reticulate' is required. Install with: install.packages('reticulate')",
         call. = FALSE)

  # Python reads this once at start up; keep it set only while the backend
  # loads, then restore the caller's environment.
  if (!nzchar(Sys.getenv("PYTHONIOENCODING"))) {
    Sys.setenv(PYTHONIOENCODING = "utf-8")
    on.exit(Sys.unsetenv("PYTHONIOENCODING"), add = TRUE)
  }

  py_file <- system.file("python", "mf_python_backend.py",
                          package = "mossyforest")
  if (!nzchar(py_file) || !file.exists(py_file))
    stop("Mossy Forest Python backend not found in package installation.",
         call. = FALSE)

  reticulate::source_python(py_file, envir = .mf_py)
  .mf_py$loaded <- TRUE
  invisible(NULL)
}

# Internal, ensure Python backend is ready, loading lazily on first call
.ensure_python <- function() {
  if (isTRUE(.mf_py$loaded)) return(invisible(NULL))
  .load_python_backend()
}

# Stop with a clear message when a fit has no per-observation SHAP values.
.check_shap <- function(object) {
  sv <- object$shap_obj$shapley_values
  if (is.null(sv) || ncol(sv) == 0L || anyNA(sv))
    stop("This plot needs per-observation SHAP values, which this fit does not ",
         "have. Refit with backend = \"python\", or backend = \"R\" with ",
         "r_shap = \"treeshap\" (r_shap = \"permutation\" does not compute them).",
         call. = FALSE)
  invisible(object)
}
