# World Development Indicators (2020)

A list containing World Bank development indicators and life expectancy
for 181 countries in 2020.

## Usage

``` r
data(wdi)
```

## Format

A list with three elements:

- X:

  A numeric matrix with 181 rows (countries) and 501 columns of World
  Bank development indicators for 2020, filtered to those present for at
  least 80% of countries and with residual gaps median imputed. Row
  names are country short names.

- y:

  A numeric vector of length 181 of life expectancy at birth (total, in
  years). All life table derived series (life expectancy, mortality,
  survival, and death counts) were removed from `X`.

- labels:

  A named character vector mapping each indicator code in `colnames(X)`
  to its human readable World Bank indicator name.

## Source

The World Development Indicators bulk database
(<https://databank.worldbank.org/>). See `data-raw/prep_wdi.R` for the
exact download and preprocessing steps.

## License

World Bank datasets are published under the Creative Commons Attribution
4.0 International license (CC BY 4.0,
<https://datacatalog.worldbank.org/public-licenses>). Credit: World
Bank, World Development Indicators. Changes made: the data were subset,
filtered and median imputed as described above. Some indicators are
compiled by the World Bank from other agencies, so check the original
source before redistributing them separately.

## References

World Bank. *World Development Indicators*. Washington, DC: The World
Bank Group.
