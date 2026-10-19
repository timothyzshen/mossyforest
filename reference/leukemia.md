# ALL Leukemia Gene Expression Data

A list containing the top 500 most variable probe sets from the Acute
Lymphoblastic Leukemia (ALL) microarray dataset (Chiaretti et al.,
2004), along with the corresponding molecular subtype outcome.

## Usage

``` r
data(leukemia)
```

## Format

A list with two elements:

- X:

  A numeric matrix with 79 rows (patients) and 500 columns (Affymetrix
  HGU95Av2 probe sets, already log\\\_2\\-scaled by the original
  authors).

- y:

  An integer vector of length 79: `1` (BCR/ABL subtype) or `0` (NEG,
  cytogenetically normal), derived from the `mol.biol` column of the
  original ALL phenotype data.

## Source

The Bioconductor `ALL` package, which is distributed under the
Artistic-2.0 license. This dataset is a subset of its samples and probe
sets; the expression values are unchanged.

## Details

Starting from the `ALL` Bioconductor package (128 patients, 12 625 probe
sets), samples are restricted to the B lineage cases carrying one of two
balanced molecular subtypes which were the BCR/ABL (Philadelphia
chromosome, Ph+) fusion versus cytogenetically normal (NEG). This
creates 79 patients (37 BCR/ABL, 42 NEG).Features were then ranked by
across sample variance and the top 500 are retained. See
`data-raw/prep_leukemia.R` for the exact preprocessing steps.

## Using `y` as a classification outcome

`y` is stored as an integer vector, so
[`mf()`](https://timothyzshen.github.io/mossyforest/reference/mf.md)
treats it as a regression outcome. For classification, convert it to a
factor first. The first level is the class that SHAP values and
directions refer to:


    y <- factor(leukemia$y, levels = c(1, 0), labels = c("BCR/ABL", "NEG"))

## References

Chiaretti, S. et al. (2004). Gene expression profile of adult T cell
acute lymphocytic leukemia identifies distinct subsets of patients with
different response to therapy and survival. *Blood*, 103(7), 2771-2778.
[doi:10.1182/blood-2003-09-3243](https://doi.org/10.1182/blood-2003-09-3243)

Li, X. *ALL: A data package*. Bioconductor.
[doi:10.18129/B9.bioc.ALL](https://doi.org/10.18129/B9.bioc.ALL)
