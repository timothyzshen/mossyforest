#' ALL Leukemia Gene Expression Data
#'
#' A list containing the top 500 most variable probe sets from the Acute
#' Lymphoblastic Leukemia (ALL) microarray dataset (Chiaretti et al., 2004),
#' along with the corresponding molecular-subtype outcome.
#'
#' Starting from the \code{ALL} Bioconductor package (128 patients, 12 625
#' probe-sets), samples are restricted to the B-lineage cases carrying one of
#' two balanced molecular subtypes which were the BCR/ABL (Philadelphia-chromosome, Ph+)
#' fusion versus cytogenetically normal (NEG). This creates 79 patients (37
#' BCR/ABL, 42 NEG).Features were then ranked by across-sample variance and the top 500
#' are retainedretained.  See \code{data-raw/prep_leukemia.R} for the exact preprocessing
#' steps.
#'
#' @docType data
#' @keywords datasets
#' @name leukemia
#' @usage data(leukemia)
#' @format A list with two elements:
#' \describe{
#'   \item{X}{A numeric matrix with 79 rows (patients) and 500 columns
#'     (Affymetrix HGU95Av2 probe-sets, already log\eqn{_2}-scaled by the
#'     original authors).}
#'   \item{y}{An integer vector of length 79: \code{1} (BCR/ABL subtype) or
#'     \code{0} (NEG, cytogenetically normal), derived from the
#'     \code{mol.biol} column of the original ALL phenotype data.}
#' }
#' @references Chiaretti, S. et al. (2004). Gene expression profile of adult
#'   T-cell acute lymphocytic leukemia identifies distinct subsets of patients
#'   with different response to therapy and survival. \emph{Blood}, 103(7),
#'   2771–2778. \doi{10.1182/blood-2003-09-3243}
#'   
#' @references Li, X. *ALL: A data package*. Bioconductor.
#'   \doi{10.18129/B9.bioc.ALL}
NULL

#' World Development Indicators (2020)
#'
#' A list containing World Bank development indicators and life expectancy for
#' 181 countries in 2020. 
#'
#' @docType data
#' @keywords datasets
#' @name wdi
#' @usage data(wdi)
#' @format A list with three elements:
#' \describe{
#'   \item{X}{A numeric matrix with 181 rows (countries) and 501 columns of 
#'     World Bank development indicators for 2020, filtered to those present
#'     for at least 80\% of countries and with residual gaps median imputed.
#'     Row names are country short names.}
#'   \item{y}{A numeric vector of length 181 of life expectancy at birth
#'     (total, in years).  All life-table-derived series (life expectancy,
#'     mortality, survival, and death counts) were removed from \code{X}.}
#'   \item{labels}{A named character vector mapping each indicator code in
#'     \code{colnames(X)} to its human-readable World Bank indicator name.}
#' }
#' @source The World Development Indicators bulk database
#'   (\url{https://databank.worldbank.org/}).  See \code{data-raw/prep_wdi.R}
#'   for the exact download and preprocessing steps.
#' @references World Bank. \emph{World Development Indicators}. Washington, DC:
#'   The World Bank Group.
NULL
