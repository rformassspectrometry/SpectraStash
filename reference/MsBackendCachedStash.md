# Stash for `MsBackendCached`

The
[Spectra::MsBackendCached](https://rdrr.io/pkg/Spectra/man/MsBackendCached.html)
backend keeps a cache of spectra metadata (spectra variables) in an
internal `data.frame` adding thus support for (temporarily) changing or
adding spectra variables for purely read-only `MsBackend` classes. This
backend is used e.g. by the MsBackendSql::MsBackendSql backend allowing
to add or replace spectra variables without affecting the content of the
underlying data base used by the `MsBackendSql`.

The stash of a `MsBackendCached` contains therefore the local spectra
data cache (if present), the names of the available spectra variables
and the total number of spectra. Supported stash formats are listed in
the sections below.

## Usage

``` r
# S4 method for class 'MsBackendCached,PlainTextParam'
saveMsObject(object, param, ...)

# S4 method for class 'MsBackendCached,PlainTextParam'
readMsObject(object, param, ...)

# S4 method for class 'MsBackendCached'
saveObject(x, path, ...)

# S4 method for class 'MsBackendCached,AlabasterParam'
saveMsObject(object, param, ...)

# S4 method for class 'MsBackendCached,AlabasterParam'
readMsObject(object, param, ...)
```

## Arguments

- object:

  An `MsBackendCached` object.

- param:

  Either a `PlainTextParam` or `AlabasterParam`.

- ...:

  Currently ignored.

- x:

  An `MsBackendCached` object.

- path:

  For `saveObject()`: `character(1)` with the path where the object
  should be stored into.

## Details

Notes for stash-functionality for `MsBackend` objects extending
`MsBackendCached`:

- `saveMsObject()` and `saveObject()` will fail if the stash directory
  already exist. Thus, stash functions of backend implementations
  extending `MsBackendCached` should **first** call the
  `MsBackendCached`'s `saveMsObject()` or `saveObject()` **before**
  exporting their respective content to the stash directory.

## Text-file format, `PlainTextParam`

The data files written into the stash are:

- *ms_backend_data.txt*: tabulator separated text file with the content
  of the `@localData` slot.

- *ms_backend_nspectra.txt*: the number of spectra.

- *ms_backend_spectra_variables.txt*: the names of the object's spectra
  variables (tabulator separated).

## *alabaster*-based format, `AlabasterParam`

The content from all slots of the `MsBackendCached` are stored using
functionality from the *alabaster.base* package into separate
sub-folders of the base stash directory. These are:

- *local_data*: for the `data.frame` with the locally cached spectra
  variables (slot `@localData`).

- *nspectra*: (`integer(1)`) with the number of spectra.

- *spectra_variables*: (`character`) with the names of the object's
  spectra variables.

## Author

Johannes Rainer

## Examples

``` r

library(Spectra)
#> Loading required package: S4Vectors
#> Loading required package: stats4
#> Loading required package: BiocGenerics
#> Loading required package: generics
#> 
#> Attaching package: ‘generics’
#> The following objects are masked from ‘package:base’:
#> 
#>     as.difftime, as.factor, as.ordered, intersect, is.element, setdiff,
#>     setequal, union
#> 
#> Attaching package: ‘BiocGenerics’
#> The following objects are masked from ‘package:stats’:
#> 
#>     IQR, mad, sd, var, xtabs
#> The following object is masked from ‘package:utils’:
#> 
#>     data
#> The following objects are masked from ‘package:base’:
#> 
#>     Filter, Find, Map, Position, Reduce, anyDuplicated, aperm, append,
#>     as.data.frame, basename, cbind, colnames, dirname, do.call,
#>     duplicated, eval, evalq, get, grep, grepl, is.unsorted, lapply,
#>     mapply, match, mget, order, paste, pmax, pmax.int, pmin, pmin.int,
#>     rank, rbind, rownames, sapply, saveRDS, scale, sequence, table,
#>     tapply, transform, unique, unsplit, which.max, which.min
#> 
#> Attaching package: ‘S4Vectors’
#> The following object is masked from ‘package:utils’:
#> 
#>     findMatches
#> The following objects are masked from ‘package:base’:
#> 
#>     I, expand.grid, unname
#> Loading required package: BiocParallel

## Create an empty `MsBackendCached` object
be <- MsBackendCached()

## Stash the object in alabaster-format in a temporary directory
ap <- AlabasterParam(file.path(tempdir(), "cache-stash"))
saveMsObject(be, ap)

## The content of the stash folder:
dir(file.path(tempdir(), "cache-stash"))
#> [1] "OBJECT"            "_environment.json" "local_data"       
#> [4] "nspectra"          "spectra_variables"

## Restore the object
res <- readMsObject(MsBackendCached(), ap)
res
#> MsBackendCached with 0 spectra
```
