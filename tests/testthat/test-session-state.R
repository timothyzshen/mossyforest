# mf() and wmf() must leave the caller's session exactly as they found it:
# CRAN policy forbids changing user options, the RNG stream, the search path or
# environment variables without restoring them.

test_that("mf() restores the 'warn' option, whatever verbosity is used", {
  d <- make_sf_data(n = 60)
  for (w in c(0, 1)) {
    withr::local_options(warn = w)
    fit_R(d)                                   # verbose = 0 silences warnings inside
    expect_equal(getOption("warn"), w)
    utils::capture.output(
      mf(d$X, d$y_reg, module_membership = d$mm,
         screen_params = fast_screen(), select_params = fast_select(),
         final_ntree = 60L, verbose = 1L, seed = 3L, backend = "R"))
    expect_equal(getOption("warn"), w)
  }
})

test_that("mf() does not disturb the caller's random-number stream", {
  d <- make_sf_data(n = 60)
  set.seed(99)
  before <- .Random.seed
  fit_R(d)
  expect_identical(.Random.seed, before)

  # the cfRes code path seeds internally too
  set.seed(99)
  before <- .Random.seed
  mf(d$X, d$y_reg, module_membership = d$mm,
     screen_params = fast_screen(), select_params = fast_select(use_cfres = TRUE),
     final_ntree = 60L, verbose = 0L, seed = 3L, backend = "R")
  expect_identical(.Random.seed, before)
})

test_that("mf() with the Python backend also leaves the RNG stream alone", {
  skip_if_no_py_backend()
  d <- make_sf_data(n = 60)
  set.seed(99)
  before <- .Random.seed
  mf(d$X, d$y_reg, module_membership = d$mm,
     screen_params = fast_screen(), select_params = fast_select(),
     final_ntree = 60L, verbose = 0L, seed = 3L, backend = "python")
  expect_identical(.Random.seed, before)
})

test_that("results do not depend on the caller's RNG state", {
  d <- make_sf_data(n = 60)
  set.seed(1);  a <- fit_R(d)
  set.seed(42); b <- fit_R(d)
  expect_identical(a$final_SHAP$feature_name, b$final_SHAP$feature_name)
  expect_identical(a$stability_freq, b$stability_freq)
})

test_that("wmf() does not leave WGCNA attached to the search path", {
  skip_if_not_installed("WGCNA")
  was_attached <- "package:WGCNA" %in% search()
  set.seed(1)
  n  <- 40
  z1 <- rnorm(n); z2 <- rnorm(n)
  block <- function(k, zz) as.data.frame(replicate(k, zz + rnorm(n, sd = 0.4)))
  X <- cbind(block(15, z1), block(15, z2))
  colnames(X) <- paste0("g", seq_len(ncol(X)))
  y <- z1 - z2 + rnorm(n, sd = 0.3)
  wmf(X, y, WGCNA_params = WGCNA_control(power = 6, min_features = 8),
      screen_params = fast_screen(),
      select_params = select_control(n_reps = 10L, min_ntree = 60L, pi_thr = 0.30,
                                     shadow_mode = "split"),
      final_ntree = 60L, verbose = 0L, seed = 3L, backend = "R")
  expect_identical("package:WGCNA" %in% search(), was_attached)
})

test_that("loading the Python backend restores PYTHONIOENCODING", {
  skip_if_no_py_backend()
  withr::local_envvar(PYTHONIOENCODING = NA)   # make sure it starts unset
  .load_python_backend()
  expect_identical(Sys.getenv("PYTHONIOENCODING", unset = NA), NA_character_)
})
