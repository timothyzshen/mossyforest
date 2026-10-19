# Package index

## Fit a model

Run Mossy Forest feature selection, with modules supplied by you or
detected with WGCNA.

- [`mf()`](https://timothyzshen.github.io/mossyforest/reference/mf.md) :
  Mossy Forest Feature Selection
- [`wmf()`](https://timothyzshen.github.io/mossyforest/reference/wmf.md)
  : Mossy Forest with WGCNA Module Detection
- [`mf_setup()`](https://timothyzshen.github.io/mossyforest/reference/mf_setup.md)
  : Configure the Python environment for Mossy Forest

## Control parameters

Settings for the screening, selection and WGCNA steps.

- [`screen_control()`](https://timothyzshen.github.io/mossyforest/reference/screen_control.md)
  : Screening Step Parameters
- [`select_control()`](https://timothyzshen.github.io/mossyforest/reference/select_control.md)
  : Selection Step Parameters
- [`WGCNA_control()`](https://timothyzshen.github.io/mossyforest/reference/WGCNA_control.md)
  : WGCNA Parameter Organization

## Work with a fitted object

- [`print(`*`<mossy_forest>`*`)`](https://timothyzshen.github.io/mossyforest/reference/print.mossy_forest.md)
  : Print a Mossy Forest Object
- [`predict(`*`<mossy_forest>`*`)`](https://timothyzshen.github.io/mossyforest/reference/predict.mossy_forest.md)
  : Predict from a Mossy Forest Object
- [`detect_interaction()`](https://timothyzshen.github.io/mossyforest/reference/detect_interaction.md)
  : Detect Pairwise Interactions from a Mossy Forest Object

## Feature importance plots

- [`plot_importance()`](https://timothyzshen.github.io/mossyforest/reference/plot_importance.md)
  : Plot Feature Importance for a Mossy Forest Object
- [`plot_signed_importance()`](https://timothyzshen.github.io/mossyforest/reference/plot_signed_importance.md)
  : Plot Directional (Signed) Feature Importance for a Mossy Forest
  Object
- [`plot_elbow()`](https://timothyzshen.github.io/mossyforest/reference/plot_elbow.md)
  : Plot Elbow Plot of Absolute SHAP Values for a Mossy Forest Object

## Stability and module plots

- [`plot_stability()`](https://timothyzshen.github.io/mossyforest/reference/plot_stability.md)
  : Plot Shadow Stability Frequencies for a Mossy Forest Object
- [`plot_stability_elbow()`](https://timothyzshen.github.io/mossyforest/reference/plot_stability_elbow.md)
  : Plot Shadow Stability Selection Curves for a Mossy Forest Object
- [`plot_modules()`](https://timothyzshen.github.io/mossyforest/reference/plot_modules.md)
  : Plot Module Membership Distribution for a Mossy Forest Object

## Plots for single observations

- [`plot_waterfall()`](https://timothyzshen.github.io/mossyforest/reference/plot_waterfall.md)
  : Plot Waterfall for Specific Observations in a Mossy Forest Object
- [`plot_force()`](https://timothyzshen.github.io/mossyforest/reference/plot_force.md)
  : Plot SHAP Force Plot for Specific Observations in a Mossy Forest
  Object
- [`plot_decisions()`](https://timothyzshen.github.io/mossyforest/reference/plot_decisions.md)
  : Plot Decision Plot for a Mossy Forest Object

## Interaction plots

- [`plot_potential_interactions()`](https://timothyzshen.github.io/mossyforest/reference/plot_potential_interactions.md)
  : Plot Potential Interaction Matrix for a Mossy Forest Object

## Data

- [`leukemia`](https://timothyzshen.github.io/mossyforest/reference/leukemia.md)
  : ALL Leukemia Gene Expression Data
- [`wdi`](https://timothyzshen.github.io/mossyforest/reference/wdi.md) :
  World Development Indicators (2020)
