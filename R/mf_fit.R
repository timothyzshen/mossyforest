#' Mossy Forest Feature Selection
#'
#' Runs the Mossy Forest algorithm.
#'
#' @export
#' @param X                 A data frame where each column is a feature.
#' @param y                 Response vector (numeric for regression, factor for
#'                          classification).
#' @param module_membership A named character vector assigning each feature in
#'                          \code{X} to a module. Names must match \code{colnames(X)}.
#'                          Modules named in \code{select_control(unassigned_modules)}
#'                          form the unassigned pool, which is selected with its own
#'                          elbow based threshold; all other modules use \code{pi_thr}.
#' @param screen_params     Screening parameters. See
#'                          \code{\link{screen_control}}.
#' @param select_params     Selection parameters. See
#'                          \code{\link{select_control}}.
#' @param final_ntree       Number of trees in the final random forest.
#'                          Default \code{500}.
#' @param nodesize          Minimum terminal node size. Defaults to \code{1}
#'                          for classification and \code{5} for regression.
#' @param num_processors    Number of parallel threads for random forests.
#'                          Default \code{1}.
#' @param max_modsize       Maximum module size before blockwise pre reduction
#'                          is applied (Python backend only). Default \code{5000}.
#' @param verbose           Verbose level. \code{0} = silent; \code{1} =
#'                          progress messages; \code{2} = detailed output.
#'                          Default \code{1}.
#' @param seed              Integer random seed for reproducibility. Defaults to
#'                          current system time.
#' @param compute_interactions Logical. If \code{TRUE} (default), the TreeSHAP
#'                          interaction matrix is computed by the Python backend
#'                          and by the pure R backend with
#'                          \code{r_shap = "treeshap"}. Set \code{FALSE} to skip
#'                          it (faster); \code{detect_interaction()} and
#'                          \code{plot_potential_interactions()} then have
#'                          nothing to use. It has no effect with
#'                          \code{r_shap = "permutation"}, which never computes
#'                          interactions.
#' @param backend           Computation backend. \code{"python"} (default) uses
#'                          a Python scikit-learn / SHAP engine via
#'                          \pkg{reticulate} and provides exact TreeSHAP values
#'                          plus an interaction matrix.  \code{"R"} uses a
#'                          R \pkg{ranger} implementation, no Python
#'                          installation required. Choose the final importance
#'                          method with \code{r_shap}.
#' @param r_shap            Final SHAP / importance method used when
#'                          \code{backend = "R"}. Ignored for the Python
#'                          backend. One of:
#'   \describe{
#'     \item{\code{"permutation"}}{Ranger permutation variable importance
#'       (default). No extra packages needed. Returns a scalar VIM per
#'       feature; per observation SHAP values and SHAP based plots are
#'       unavailable.}
#'     \item{\code{"treeshap"}}{Exact TreeSHAP values via the R
#'       \pkg{treeshap} package. Requires \pkg{treeshap}. Also computes a
#'       \eqn{p \times p} interaction matrix, enabling
#'       \code{detect_interaction()} and
#'       \code{plot_potential_interactions()}.}
#'   }
#'
#' @return An object of class \code{\link{mossy_forest}}.
#'
#' @references
#' Chernozhukov, V., Chetverikov, D., Demirer, M., Duflo, E., Hansen, C.,
#'   Newey, W., & Robins, J. (2018). Double/cross-fit residualed machine learning for
#'   treatment and structural parameters. \emph{The Econometrics Journal},
#'   21(1), C1-C68.
#'
#' Lundberg, S. M., & Lee, S. I. (2017). A unified model for interpreting
#'   predictions. \emph{NeurIPS}, 30.
#'
#' @importFrom ranger ranger
#' @import dplyr
#'
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
#' head(fit$final_SHAP)
#'
#' \dontrun{
#' # The Python backend (exact TreeSHAP) needs a configured Python environment
#' mf_setup(condaenv = "sfenv")
#' fit_py <- mf(X, y, module_membership = membership, backend = "python")
#' plot_importance(fit_py)
#' }
mf <- function(X, y,
               module_membership,
               screen_params   = screen_control(),
               select_params   = select_control(),
               final_ntree     = 500L,
               nodesize        = NULL,
               num_processors  = 1L,
               max_modsize     = 5000L,
               verbose         = 1L,
               seed            = as.integer(Sys.time()),
               compute_interactions = TRUE,
               backend         = "python",
               r_shap          = "permutation") {

  backend <- match.arg(backend, c("python", "R"))
  r_shap  <- match.arg(r_shap,  c("permutation", "treeshap"))

  # load Python backend
  if (backend == "python") .ensure_python()

  old_seed <- .save_seed()
  on.exit(.restore_seed(old_seed), add = TRUE)
  set.seed(seed)

  # validation
  if (!is.data.frame(X))
    stop("X must be a data.frame.", call. = FALSE)
  if (!(is.vector(y) || is.factor(y)))
    stop("y must be a numeric vector (regression) or factor (classification).",
         call. = FALSE)
  if (is.null(names(module_membership)))
    names(module_membership) <- colnames(X)[seq_along(module_membership)]

  # an unassigned_modules name that matches no module would be silently ignored
  um_missing <- setdiff(as.character(select_params$unassigned_modules),
                        as.character(module_membership))
  if (length(um_missing) > 0L)
    warning("`unassigned_modules` not found in `module_membership`: ",
            paste(sQuote(um_missing, FALSE), collapse = ", "),
            ". Those features are treated as an ordinary module, not as an ",
            "unassigned pool. Modules present: ",
            paste(sort(unique(as.character(module_membership))), collapse = ", "),
            ".", call. = FALSE)

  CLASSIFICATION <- is.factor(y)
  if (is.null(nodesize))
    nodesize <- if (CLASSIFICATION) 1L else 5L

  if (verbose == 0L) {
    old_opts <- options(warn = -1)
    on.exit(options(old_opts), add = TRUE)
  }

  sc <- screen_params
  sl <- select_params

  module_membership_screen <- module_membership[names(module_membership) %in% colnames(X)]
  module_list_screen       <- unique(module_membership_screen)

  runtime <- list(Screen = NA_real_, Selection = NA_real_, Final_RF = NA_real_)

  # R backend, pure ranger, no Python required
  if (backend == "R") {
    return(.mf_R_backend(
      X = X, y = y,
      module_membership        = module_membership,
      module_membership_screen = module_membership_screen,
      module_list_screen       = module_list_screen,
      screen_params            = screen_params,
      select_params            = select_params,
      final_ntree              = final_ntree,
      nodesize                 = nodesize,
      num_processors           = num_processors,
      verbose                  = verbose,
      seed                     = seed,
      CLASSIFICATION           = CLASSIFICATION,
      runtime                  = runtime,
      r_shap                   = r_shap,
      compute_interactions     = compute_interactions
    ))
  }

  # Python inputs
  X_mat <- as.matrix(X); mode(X_mat) <- "double"

  y_py <- if (CLASSIFICATION) {
    if (nlevels(y) == 2L) as.integer(y == levels(y)[1L]) else as.integer(y)
  } else {
    as.numeric(y)
  }
  feature_names <- colnames(X)
  module_assign <- as.character(module_membership_screen[feature_names])
  module_list_r <- as.character(module_list_screen)

  # Screening Phase
  if (verbose >= 1L) cat("Screening ...\n")
  t0 <- proc.time()

  screen_py <- .mf_py$run_screen_rfe(
    X_mat              = X_mat,
    y                  = y_py,
    feature_names      = feature_names,
    module_assignments = module_assign,
    module_list        = module_list_r,
    drop_fraction      = sc$drop_fraction,
    keep_fraction      = sc$keep_fraction,
    mtry_factor        = sc$mtry_factor,
    ntree_factor       = as.numeric(sc$ntree_factor),
    min_ntree          = as.integer(sc$min_ntree),
    mtry_rule          = sc$mtry_rule,
    nodesize           = as.integer(nodesize),
    classification     = CLASSIFICATION,
    seed               = as.integer(seed),
    n_jobs             = as.integer(num_processors),
    max_modsize        = as.integer(max_modsize)
  )

  runtime$Screen <- (proc.time() - t0)["elapsed"]

  # Reconstruct survivor_results from Python output 
  survivor_results <- vector("list", length(module_list_screen))
  for (i in seq_along(module_list_screen)) {
    feats    <- as.character(screen_py$survivor_features[[i]])
    vims     <- as.numeric(screen_py$survivor_vims[[i]])
    surv_df  <- data.frame(features    = feats,
                            mod_varlist = vims,
                            stringsAsFactors = FALSE)
    survivor_results[[i]] <- list(survivor = surv_df)
  }

  # Compile survivor pool 
  survivor_list  <- lapply(survivor_results, `[[`, "survivor")
  names(survivor_list) <- module_list_screen

  survivors         <- do.call(rbind, survivor_list)
  survivors         <- as.data.frame(survivors, stringsAsFactors = FALSE)
  survivors[, 2]    <- as.numeric(survivors[, 2])
  names(survivors)  <- c("featureID", "Permutation VIM")
  X_surv <- X[, names(X) %in% survivors[, 1], drop = FALSE]

  # Shadow stability selection
  if (verbose >= 1L) cat("Selecting stable features ...\n")
  t0 <- proc.time()

  X_surv_mat       <- as.matrix(X_surv); mode(X_surv_mat) <- "double"

  surv_feat_to_mod <- unlist(lapply(names(survivor_list), function(mod) {
    df <- survivor_list[[mod]]
    if (is.null(df) || nrow(df) == 0L) return(character(0))
    setNames(rep(mod, nrow(df)), as.character(df[, 1L]))
  }))
  module_assigns_ordered <- surv_feat_to_mod[colnames(X_surv)]
  module_assigns_ordered[is.na(module_assigns_ordered)] <- "unknown"

  module_ev <- vapply(names(survivor_list), function(mod) {
    df <- survivor_list[[mod]]
    if (is.null(df) || nrow(df) == 0L) return(0.0)
    mean(as.numeric(df[, 2L]), na.rm = TRUE)
  }, numeric(1L))

  select_py <- .mf_py$run_select_rfe(
    X_surv_mat              = X_surv_mat,
    y                       = y_py,
    feature_names_surv      = as.list(colnames(X_surv)),
    module_assignments_surv = as.list(as.character(module_assigns_ordered)),
    mtry_factor             = sl$mtry_factor,
    ntree_factor            = as.numeric(sl$ntree_factor),
    min_ntree               = as.integer(sl$min_ntree),
    nodesize                = as.integer(nodesize),
    classification          = CLASSIFICATION,
    seed                    = as.integer(seed),
    n_jobs                  = as.integer(num_processors),
    n_reps                 = as.integer(sl$n_reps),
    pi_thr                  = as.numeric(sl$pi_thr),
    compute_interactions    = as.logical(compute_interactions),
    shadow_mode             = sl$shadow_mode,
    shadow_percentile       = as.numeric(sl$shadow_percentile),
    pi_thr_unassigned            = if (!is.null(sl$pi_thr_unassigned))
                                as.numeric(sl$pi_thr_unassigned) else NULL,
    threshold_mode          = sl$threshold_mode,
    mtry_rule               = sl$mtry_rule,
    mtry_on_real            = as.logical(sl$mtry_on_real),
    early_stop        = as.logical(sl$early_stop),
    early_stop_tol          = as.numeric(sl$early_stop_tol),
    early_stop_check_every  = as.integer(sl$early_stop_check_every),
    unassigned_modules           = if (!is.null(sl$unassigned_modules))
                                as.list(sl$unassigned_modules) else NULL,
    use_cfres        = as.logical(sl$use_cfres),
    cfres_n_folds             = as.integer(sl$cfres_n_folds),
    cfres_ntree               = as.integer(sl$cfres_ntree),
    cfres_scope               = sl$cfres_scope,
    verbose                 = as.logical(verbose >= 2L)
  )

  runtime$Selection <- (proc.time() - t0)["elapsed"]

  # Unpack Python selection output
  stable_features <- as.character(select_py$final_features)
  n_stable        <- length(stable_features)

  if (verbose >= 1L)
    cat(sprintf("Stable features: %d\n", n_stable))

  stability_freq_vec <- if (n_stable > 0L)
    setNames(as.numeric(select_py$stability_freq), stable_features)
  else
    setNames(numeric(0), character(0))

  shap_matrix <- if (n_stable > 0L && length(select_py$shap_matrix) > 0L) {
    matrix(
      as.numeric(unlist(select_py$shap_matrix)),
      nrow     = nrow(X_surv),
      ncol     = n_stable,
      byrow    = TRUE,   # Python .tolist() is row major, fill by row to preserve
                         # per observation alignment (else the matrix is scrambled)
      dimnames = list(NULL, stable_features)
    )
  } else {
    matrix(NA_real_, nrow = nrow(X_surv), ncol = 0L)
  }

  # TreeSHAP interaction matrix 
  interaction_matrix <- if (n_stable > 0L && length(select_py$interaction_matrix) > 0L) {
    m <- matrix(
      as.numeric(unlist(select_py$interaction_matrix)),
      nrow     = n_stable,
      ncol     = n_stable,
      byrow    = TRUE,   # row major from Python 
      dimnames = list(stable_features, stable_features)
    )
    m
  } else {
    NULL
  }

  selection_list <- lapply(seq_along(select_py$selection_list_feats), function(i) {
    data.frame(
      feature_name        = as.character(select_py$selection_list_feats[[i]]),
      variable_importance = round(as.numeric(select_py$selection_list_vims[[i]]), 4L),
      stringsAsFactors    = FALSE
    )
  })

  # per pool shadow stability data 
  stability_data <- if (!is.null(select_py$pool_stability) &&
                         length(select_py$pool_stability) > 0L) {
    pool_rows <- lapply(select_py$pool_stability, function(p) {
      n_p <- length(p$feature_names)
      if (n_p == 0L) return(NULL)
      er  <- if (!is.null(p$elbow_rank)) as.integer(p$elbow_rank) else NA_integer_
      data.frame(
        pool        = rep(as.character(p$pool), n_p),
        rank        = seq_len(n_p),
        feature     = as.character(p$feature_names),
        freq        = as.numeric(p$freqs),
        selected    = as.logical(p$selected),
        threshold   = rep(as.numeric(p$threshold), n_p),
        elbow_rank  = rep(er, n_p),
        stringsAsFactors = FALSE
      )
    })
    do.call(rbind, Filter(Negate(is.null), pool_rows))
  } else {
    NULL
  }

  # Final Random Forest Phase
  if (verbose >= 1L) cat("Fitting final model ...\n")
  t0 <- proc.time()

  feature_list <- data.frame(
    feature_name        = stable_features,
    variable_importance = round(as.numeric(select_py$final_vims), 4L),
    module_membership   = as.character(module_membership[stable_features]),
    stringsAsFactors    = FALSE
  )

  final_X    <- X[, stable_features, drop = FALSE]
  current_p  <- ncol(final_X)

  if (current_p == 0L) {
    if (verbose >= 1L)
      cat("No stable features selected; skipping final model.\n")
    final_rf <- NULL
  } else {
  final_mtry <- {
    base <- switch(sl$mtry_rule,
      sqrt     = sqrt(current_p),
      p_over_3 = current_p / 3,
      if (CLASSIFICATION) sqrt(current_p) else current_p / 3)   # "auto"
    max(1L, min(ceiling(sl$mtry_factor * base), current_p))
  }

  final_rf <- ranger::ranger(
    x             = final_X,
    y             = y,
    mtry          = final_mtry,
    num.trees     = as.integer(final_ntree),
    importance    = "none",
    min.node.size = as.integer(nodesize),
    probability   = CLASSIFICATION,
    verbose       = FALSE,
    num.threads   = as.integer(num_processors),
    seed          = as.integer(seed)
  )
  }

  final_module_membership <- data.frame(
    feature_name = names(final_X),
    module       = as.character(module_membership[names(final_X)]),
    stringsAsFactors = FALSE
  )

  # Build final_SHAP data frame 
  mean_shap <- setNames(as.numeric(select_py$final_vims), stable_features)

  shap_final_list <- data.frame(
    feature_name        = stable_features,
    variable_importance = round(mean_shap, 4L),
    module_membership   = as.character(module_membership[stable_features]),
    stringsAsFactors    = FALSE
  )

  # Add per observation SHAP CIs if matrix is available
  if (ncol(shap_matrix) > 0L) {
    feat_ord  <- stable_features
    valid_cols <- feat_ord[feat_ord %in% colnames(shap_matrix)]
    shap_ord  <- shap_matrix[, valid_cols, drop = FALSE]
    n_obs     <- nrow(shap_ord)

    abs_mat      <- abs(shap_ord)
    mean_abs     <- colMeans(abs_mat)
    se_abs       <- apply(abs_mat,  2L, sd) / sqrt(n_obs)
    mean_signed  <- colMeans(shap_ord)
    se_signed    <- apply(shap_ord, 2L, sd) / sqrt(n_obs)

    shap_final_list$mean_abs_shap    <- round(mean_abs[feat_ord],                              4L)
    shap_final_list$se_abs_shap      <- round(se_abs[feat_ord],                                4L)
    shap_final_list$ci_lower_abs     <- round(pmax(0, mean_abs[feat_ord] - 1.96 * se_abs[feat_ord]), 4L)
    shap_final_list$ci_upper_abs     <- round(mean_abs[feat_ord] + 1.96 * se_abs[feat_ord],   4L)
    shap_final_list$mean_signed_shap <- round(mean_signed[feat_ord],                           4L)
    shap_final_list$se_signed_shap   <- round(se_signed[feat_ord],                             4L)
    shap_final_list$ci_lower_signed  <- round(mean_signed[feat_ord] - 1.96 * se_signed[feat_ord], 4L)
    shap_final_list$ci_upper_signed  <- round(mean_signed[feat_ord] + 1.96 * se_signed[feat_ord], 4L)
    shap_final_list$stability_freq   <- round(stability_freq_vec[feat_ord],                    4L)

    # global signed direction
    val_ord  <- final_X[, valid_cols, drop = FALSE]
    dir_corr <- vapply(seq_along(valid_cols), function(k) {
      xj <- as.numeric(val_ord[[k]]); sj <- shap_ord[, k]
      if (stats::sd(xj) == 0 || stats::sd(sj) == 0) return(0)
      cc <- suppressWarnings(stats::cor(xj, sj, method = "spearman"))
      if (is.na(cc)) 0 else cc
    }, numeric(1L))
    names(dir_corr) <- valid_cols
    direction <- sign(dir_corr)
    shap_final_list$direction           <- as.integer(direction[feat_ord])
    shap_final_list$dir_corr            <- round(dir_corr[feat_ord], 4L)
    shap_final_list$signed_importance   <- round(direction[feat_ord] * mean_abs[feat_ord], 4L)
    shap_final_list$direction_ambiguous <- abs(dir_corr[feat_ord]) < 0.1
  }

  runtime$Final_RF <- (proc.time() - t0)["elapsed"]

  shap_obj <- list(
    shapley_values    = shap_matrix,
    interaction_matrix = interaction_matrix
  )
  class(shap_obj) <- "explanation"

  if (verbose >= 1L) cat("Done.\n")

  mossy_forest(
    final_rf          = final_rf,
    final_X           = final_X,
    module_membership = final_module_membership,
    WGCNA_object      = NULL,
    survivor_list     = survivor_list,
    selection_list    = selection_list,
    final_shap        = shap_final_list,
    shap_obj          = shap_obj,
    runtime           = runtime,
    feature_list      = feature_list,
    stability_freq    = stability_freq_vec,
    stability_data    = stability_data
  )
}


#' Mossy Forest with WGCNA Module Detection
#'
#' Runs a Weighted Gene Co expression Network Analysis (WGCNA) to derive
#' module membership, then passes the result to \code{\link{mf}}.
#'
#' @inheritParams mf
#' @param WGCNA_params WGCNA parameters. See \code{\link{WGCNA_control}}.
#'
#' @return An object of class \code{\link{mossy_forest}} with an additional
#'   \code{$WGCNA_object} slot containing the raw WGCNA output.
#'
#' @examplesIf requireNamespace("WGCNA", quietly = TRUE)
#' \donttest{
#' # Two blocks of correlated features; WGCNA finds the modules
#' set.seed(1)
#' n <- 30
#' z1 <- rnorm(n); z2 <- rnorm(n)
#' block <- function(k, zz) as.data.frame(replicate(k, zz + rnorm(n, sd = 0.4)))
#' X <- cbind(block(10, z1), block(10, z2))
#' colnames(X) <- paste0("g", seq_len(ncol(X)))
#' y <- z1 - z2 + rnorm(n, sd = 0.3)
#' fit <- wmf(X, y, WGCNA_params = WGCNA_control(power = 6, min_features = 6),
#'            screen_params = screen_control(min_ntree = 30),
#'            select_params = select_control(n_reps = 3, min_ntree = 30),
#'            final_ntree = 30, backend = "R", verbose = 0, seed = 1)
#' table(fit$WGCNA_object$colors)
#' }
#'
#' @export
#' @importFrom ranger ranger
#'
#' @references
#' Zhang, B., & Horvath, S. (2005). A general framework for weighted gene
#'   co expression network analysis. \emph{Statistical Applications in Genetics
#'   and Molecular Biology}, 4(1), Article 17.
wmf <- function(X, y,
                WGCNA_params  = WGCNA_control(power = 6),
                screen_params = screen_control(),
                select_params = select_control(),
                final_ntree   = 500L,
                nodesize      = NULL,
                num_processors = 1L,
                max_modsize   = 5000L,
                verbose       = 1L,
                seed          = as.integer(Sys.time()),
                backend       = "python",
                r_shap        = "permutation",
                compute_interactions = TRUE) {

  if (!requireNamespace("WGCNA", quietly = TRUE))
    stop("Package 'WGCNA' is required for wmf(). Install it first.", call. = FALSE)
  if (!"package:WGCNA" %in% search()) {
    attachNamespace("WGCNA")
    on.exit(detach("package:WGCNA", unload = FALSE), add = TRUE)
  }

  if (!(is.vector(y) || is.factor(y)))
    stop("y must be a numeric vector or factor.", call. = FALSE)

  # Convert X to numeric for WGCNA
  integer_cols <- sapply(X, is.integer)
  if (any(integer_cols))
    X[, integer_cols] <- lapply(X[, integer_cols, drop = FALSE], as.numeric)
  if (!all(sapply(X, is.numeric)))
    stop("All columns of X must be numeric for WGCNA.", call. = FALSE)

  # Run WGCNA
  wgcna_ctrl <- WGCNA_params
  if ("minModuleSize" %in% names(wgcna_ctrl$extra_args))
    stop("Set the minimum module size with WGCNA_control(min_features = ), ",
         "not minModuleSize.", call. = FALSE)
  WGCNA_args <- c(list(datExpr = X, power = wgcna_ctrl$power,
                       minModuleSize = wgcna_ctrl$min_features),
                  wgcna_ctrl$extra_args)
  if (verbose == 0L) {
    invisible(capture.output(suppressWarnings(suppressMessages({
      bwise <- do.call(WGCNA::blockwiseModules, WGCNA_args)
    }))))
  } else {
    bwise <- do.call(WGCNA::blockwiseModules, WGCNA_args)
  }
  module_membership <- bwise$colors

  out <- mf(
    X = X, y = y,
    module_membership = module_membership,
    screen_params     = screen_params,
    select_params     = select_params,
    final_ntree       = final_ntree,
    nodesize          = nodesize,
    num_processors    = num_processors,
    max_modsize       = max_modsize,
    verbose           = verbose,
    seed              = seed,
    backend           = backend,
    r_shap            = r_shap,
    compute_interactions = compute_interactions
  )

  out$WGCNA_object <- bwise
  out
}
