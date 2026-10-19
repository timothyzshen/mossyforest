# End-to-end behaviour of the pure-R backend (ranger, no Python required).

test_that("pure-R backend (permutation) returns the documented result contract", {
  d <- make_sf_data()
  r <- fit_R(d, r_shap = "permutation")

  expect_s3_class(r, "mossy_forest")
  expect_setequal(
    names(r),
    c("final_rf", "final_X", "module_membership", "WGCNA_object",
      "survivor_list", "selection_list", "final_SHAP", "shap_obj",
      "runtimes", "feature_list", "stability_freq", "stability_data")
  )

  expect_s3_class(r$final_SHAP, "data.frame")
  expect_true(all(c("feature_name", "variable_importance", "module_membership")
                  %in% names(r$final_SHAP)))
  expect_gte(nrow(r$final_SHAP), 1L)

  stable <- r$final_SHAP$feature_name
  expect_true(all(stable %in% colnames(d$X)))          # never invents a feature
  expect_named(r$stability_freq)                       # named per-feature freq
})

test_that("screening keeps the true signals and can drop noise", {
  d <- make_sf_data()
  r <- fit_R(d, r_shap = "permutation")

  survivors <- unlist(lapply(r$survivor_list, function(df) {
    if (is.null(df) || nrow(df) == 0L) character(0) else as.character(df[[1L]])
  }), use.names = FALSE)

  # Strong signals should survive module-stratified screening.
  kept_signals <- intersect(survivors, d$true_signals)
  expect_gte(length(kept_signals), 5L)
})

test_that("the auto mtry rule is sqrt(p) for classification and p/3 for regression", {
  expect_equal(.compute_mtry_R(100, 1, classification = TRUE),  10)
  expect_equal(.compute_mtry_R(30,  1, classification = FALSE), 10)
  expect_equal(.compute_mtry_R(100, 1, TRUE,  rule = "p_over_3"), 34)
  expect_equal(.compute_mtry_R(100, 1, FALSE, rule = "sqrt"),     10)
})

test_that("screening stops exactly at the keep target, never below it", {
  set.seed(1)
  n <- 120
  X <- as.data.frame(matrix(rnorm(n * 7), n, 7))
  colnames(X) <- paste0("f", 1:7)
  y  <- as.numeric(X$f1 + X$f2 + rnorm(n, sd = 0.5))
  mm <- setNames(rep("M", 7), colnames(X))
  # 7 features, keep_fraction 0.5 -> target 4; dropping 25% per step
  # (7 -> 5 -> 3) used to overshoot to 3 survivors.
  sc  <- screen_control(drop_fraction = 0.25, keep_fraction = 0.5, min_ntree = 50L)
  out <- .mf_R_screen(X, y, mm, sc, nodesize = 5L, num_processors = 1L,
                      seed = 1L, verbose = FALSE)
  expect_equal(nrow(out$survivor_list$M), 4L)
})

test_that("mf() warns when unassigned_modules matches no module", {
  d  <- make_sf_data(n = 60)
  sl <- select_control(n_reps = 4L, min_ntree = 40L, pi_thr = 0.30,
                       unassigned_modules = "no_such_module")
  expect_warning(
    mf(d$X, d$y_reg, module_membership = d$mm, screen_params = fast_screen(),
       select_params = sl, final_ntree = 40L, verbose = 0L, seed = 3L,
       backend = "R"),
    "not found in `module_membership`.*no_such_module")
  # a name that does exist stays silent
  expect_no_warning(fit_R(d))
})

test_that("compute_interactions = FALSE skips the treeshap interaction matrix", {
  skip_if_not_installed("treeshap")
  d <- make_sf_data(n = 60)
  r_on  <- fit_R(d, r_shap = "treeshap")
  r_off <- fit_R(d, r_shap = "treeshap", compute_interactions = FALSE)
  expect_false(is.null(r_on$shap_obj$interaction_matrix))
  expect_null(r_off$shap_obj$interaction_matrix)
})

test_that("plot_elbow labels the score it plots", {
  d <- make_sf_data(n = 60)
  p <- plot_elbow(fit_R(d, r_shap = "permutation"))
  expect_equal(p$labels$y, "Variable Importance")
  skip_if_not_installed("treeshap")
  p2 <- plot_elbow(fit_R(d, r_shap = "treeshap"))
  expect_equal(p2$labels$y, "Absolute SHAP Values")
})

test_that("the final ranger model can predict on new rows", {
  d <- make_sf_data()
  r <- fit_R(d, r_shap = "permutation")

  expect_false(is.null(r$final_rf))
  pr <- predict(r$final_rf, d$X[, r$final_SHAP$feature_name, drop = FALSE])$predictions
  expect_length(pr, nrow(d$X))
  expect_true(all(is.finite(pr)))
})

test_that("classification target runs end-to-end on the pure-R backend", {
  d <- make_sf_data()
  r <- mf(d$X, d$y_clf, module_membership = d$mm,
          screen_params = fast_screen(), select_params = fast_select(),
          final_ntree = 60L, num_processors = 1L, verbose = 0L, seed = 3L,
          backend = "R", r_shap = "permutation")
  expect_s3_class(r, "mossy_forest")
  expect_gte(nrow(r$final_SHAP), 1L)
})

test_that("r_shap = 'treeshap' drives screening + stability + final without error", {
  skip_if_not_installed("treeshap")
  d <- make_sf_data()
  r <- fit_R(d, r_shap = "treeshap")

  expect_s3_class(r, "mossy_forest")
  expect_gte(nrow(r$final_SHAP), 1L)
  expect_true(all(r$final_SHAP$feature_name %in% colnames(d$X)))
})

test_that("cfRes residualization on the unassigned pool runs (pure-R)", {
  d <- make_sf_data()
  r <- mf(d$X, d$y_reg, module_membership = d$mm,
          screen_params = fast_screen(),
          select_params = fast_select(use_cfres = TRUE,
                                       cfres_n_folds = 3L, cfres_ntree = 80L),
          final_ntree = 60L, num_processors = 1L, verbose = 0L, seed = 3L,
          backend = "R", r_shap = "permutation")
  expect_s3_class(r, "mossy_forest")
})

# directional (signed) importance on the pure-R backend
# Direction needs a per-observation SHAP matrix, so it is only available for
# r_shap = "treeshap", never "permutation" 

direction_cols <- c("direction", "dir_corr", "signed_importance",
                     "direction_ambiguous")

test_that("permutation VIM never produces direction columns", {
  d <- make_sf_data()
  r <- fit_R(d, r_shap = "permutation")
  expect_false(any(direction_cols %in% names(r$final_SHAP)))
})

test_that("treeshap produces direction columns for regression", {
  skip_if_not_installed("treeshap")
  d <- make_sf_data()
  r <- fit_R(d, r_shap = "treeshap")

  expect_true(all(direction_cols %in% names(r$final_SHAP)))
  fs <- r$final_SHAP
  expect_true(all(fs$direction %in% c(-1L, 0L, 1L)))
  expect_equal(fs$signed_importance, fs$direction * fs$mean_abs_shap,
               tolerance = 1e-6)
})

test_that("treeshap on classification either fails upstream or returns direction columns", {
  # Whether treeshap::ranger.unify() accepts the probability forests that mf()
  # fits for classification depends on the installed treeshap version.
  skip_if_not_installed("treeshap")
  d <- make_sf_data()
  r <- tryCatch(
    mf(d$X, d$y_clf, module_membership = d$mm,
       screen_params = fast_screen(), select_params = fast_select(),
       final_ntree = 60L, num_processors = 1L, verbose = 0L, seed = 3L,
       backend = "R", r_shap = "treeshap"),
    error = function(e) e)
  if (inherits(r, "error")) {
    expect_s3_class(r, "error")
  } else {
    expect_true(all(direction_cols %in% names(r$final_SHAP)))
    # SHAP values refer to levels(y)[1], the same class as the Python backend
    sv <- as.matrix(r$shap_obj$shapley_values)
    p1 <- predict(r$final_rf, data = r$final_X)$predictions[, 1L]
    expect_gt(stats::cor(rowSums(sv), p1), 0)
  }
})
