#' @importFrom stats setNames predict median sd reshape
#' @importFrom utils capture.output
#' @importFrom grDevices colors
NULL

# Column names referenced through ggplot2's non standard evaluation in the plot
# functions; declared here so R CMD check does not report them as undefined.
utils::globalVariables(c(
  "Cumulative_SHAP", "Feature", "FeatureA", "FeatureB", "Interaction_Strength",
  "Last_Cumulative_SHAP", "Observation", "SHAP", "elbow_rank", "feature", "freq",
  "frequency", "module_membership", "selected_f", "threshold", "variable_importance"
))
