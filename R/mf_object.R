#' Mossy Forest Object
#'
#' Output for the \code{mossy_forest} return type.
#'
#' @param final_rf        Final \code{ranger} object fitted on the stable
#'                        feature set.
#' @param final_X         Data frame of features in the stable set.
#' @param module_membership Data frame mapping each feature to its module.
#' @param WGCNA_object    WGCNA output object, or \code{NULL}.
#' @param survivor_list   Per module screening survivors.
#' @param selection_list  Feature lists at each selection iteration.
#' @param final_shap      Data frame of stable features with mean absolute SHAP,
#'                        95 percent CIs, and shadow stability frequencies.
#' @param shap_obj        List with elements \code{shapley_values} (signed SHAP
#'                        matrix, samples x stable features) and
#'                        \code{interaction_matrix} (mean absolute TreeSHAP
#'                        interaction matrix, stable features x stable features).
#'                        \code{NULL} when unavailable. For binary classification,
#'                        signed values (and \code{final_shap}'s \code{direction} /
#'                        \code{dir_corr} / \code{signed_importance}) describe the
#'                        probability of \code{levels(y)[1]}, the first level of
#'                        the outcome factor. Relevel \code{y} if you want a
#'                        different reference class.
#' @param runtime         Named list of runtimes (seconds): Screen, Selection,
#'                        Final_RF.
#' @param feature_list    Data frame of the stable feature set with importance
#'                        scores.
#' @param stability_freq  Named numeric vector. Shadow subsample selection
#'                        frequency per stable feature.
#' @param stability_data  Data frame with per pool shadow stability curves used
#'                        by \code{\link{plot_stability_elbow}}. Columns are
#'                        \code{pool}, \code{rank}, \code{feature}, \code{freq},
#'                        \code{selected}, \code{threshold}, \code{elbow_rank}.
#'                        \code{NULL} if unavailable.
#'
#' @return An object of class \code{mossy_forest}.
#' @keywords internal
mossy_forest <- function(final_rf, final_X, module_membership,
                            WGCNA_object    = NULL,
                            survivor_list,
                            selection_list,
                            final_shap,
                            shap_obj,
                            runtime,
                            feature_list    = NULL,
                            stability_freq  = NULL,
                            stability_data  = NULL) {
  out <- list(
    final_rf         = final_rf,
    final_X          = final_X,
    module_membership = module_membership,
    WGCNA_object     = WGCNA_object,
    survivor_list    = survivor_list,
    selection_list   = selection_list,
    final_SHAP       = final_shap,
    shap_obj         = shap_obj,
    runtimes         = runtime,
    feature_list     = feature_list,
    stability_freq   = stability_freq,
    stability_data   = stability_data
  )
  class(out) <- "mossy_forest"
  out
}


#' Print a Mossy Forest Object
#'
#' Prints the stable feature set with final feature importance scores and
#' shadow stability selection frequencies.
#'
#' @param x   A \code{mossy_forest} object.
#' @param ... Ignored.
#'
#' @return Invisibly returns \code{x}.
#' @examples
#' # A small simulated regression problem with two modules of features
#' set.seed(1)
#' n <- 60
#' z <- rnorm(n)
#' X <- data.frame(a1 = z + rnorm(n, sd = 0.3), a2 = z + rnorm(n, sd = 0.3),
#'                 a3 = z + rnorm(n, sd = 0.3), b1 = rnorm(n), b2 = rnorm(n),
#'                 b3 = rnorm(n))
#' y <- z + rnorm(n, sd = 0.3)
#' membership <- c(a1 = "A", a2 = "A", a3 = "A", b1 = "B", b2 = "B", b3 = "B")
#'
#' # The pure R backend needs no Python installation
#' fit <- mf(X, y, module_membership = membership,
#'           screen_params = screen_control(min_ntree = 50),
#'           select_params = select_control(n_reps = 10, min_ntree = 50),
#'           final_ntree = 50, backend = "R", verbose = 0, seed = 1)
#' print(fit)
#' @export
print.mossy_forest <- function(x, ...) {
  cat("--- Mossy Forest ---\n")
  cat(sprintf("Stable features selected: %d\n\n", nrow(x$final_SHAP)))
  print(x$final_SHAP)

  if (!is.null(x$final_rf$prediction.error)) {
    cat(sprintf("\nOOB prediction error: %.4f\n", x$final_rf$prediction.error))
  }
  invisible(x)
}


#' Predict from a Mossy Forest Object
#'
#' Generates predictions from the final random forest fitted on the stable
#' feature set.
#'
#' @param object   A \code{mossy_forest} object.
#' @param new_data A matrix or data frame of new observations. Column names
#'                 must match the training features.
#' @param ...      Additional arguments passed to \code{\link[ranger]{predict.ranger}}.
#'
#' @return A \code{ranger} prediction object. Predictions always come from the
#'   \code{ranger} forest refit on the stable features, whichever backend
#'   selected them.
#' @examples
#' # A small simulated regression problem with two modules of features
#' set.seed(1)
#' n <- 60
#' z <- rnorm(n)
#' X <- data.frame(a1 = z + rnorm(n, sd = 0.3), a2 = z + rnorm(n, sd = 0.3),
#'                 a3 = z + rnorm(n, sd = 0.3), b1 = rnorm(n), b2 = rnorm(n),
#'                 b3 = rnorm(n))
#' y <- z + rnorm(n, sd = 0.3)
#' membership <- c(a1 = "A", a2 = "A", a3 = "A", b1 = "B", b2 = "B", b3 = "B")
#'
#' # The pure R backend needs no Python installation
#' fit <- mf(X, y, module_membership = membership,
#'           screen_params = screen_control(min_ntree = 50),
#'           select_params = select_control(n_reps = 10, min_ntree = 50),
#'           final_ntree = 50, backend = "R", verbose = 0, seed = 1)
#' predict(fit, X[1:5, ])$predictions
#' @export
predict.mossy_forest <- function(object, new_data, ...) {
  predict(object$final_rf, data = new_data, ...)
}
