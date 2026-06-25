# Stash for `MsBackendMemory` and `MsBackendDataFrame`

The stash for the in-memory MS backends
[Spectra::MsBackendMemory](https://rdrr.io/pkg/Spectra/man/MsBackend.html)
and
[Spectra::MsBackendDataFrame](https://rdrr.io/pkg/Spectra/man/MsBackend.html)
contains both the spectra variables (spectra metadata) as well as the
peaks data (*m/z* and intensity values). Backend objects can be stashed
and restored with the
[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
and
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html),
respectively. In addition, the `saveObject()` and `readObject()`
functions from *alabaster.base* are supported.

## Usage

``` r
# S4 method for class 'MsBackendInMemory,PlainTextParam'
saveMsObject(object, param, ...)

# S4 method for class 'MsBackendInMemory,PlainTextParam'
readMsObject(object, param, ...)

# S4 method for class 'MsBackendInMemory'
saveObject(x, path, ...)

# S4 method for class 'MsBackendInMemory,AlabasterParam'
saveMsObject(object, param, ...)
```

## Arguments

- object:

  An `MsBackendMemory` or `MsBackendDataFrame` object.

- param:

  Either a `PlainTextParam` or `AlabasterParam`.

- ...:

  Currently ignored.

- x:

  An `MsBackendMemory` or `MsBackendDataFrame` object.

- path:

  For
  [`saveObject()`](https://rdrr.io/pkg/alabaster.base/man/saveObject.html):
  `character(1)` with the path where the object should be stored into.

## Value

[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
returns a restored backend.

## Details

To support storing spectra **and** peaks variables, the
`MsBackendMemory` is converted to a
[Spectra::MsBackendHdf5Peaks](https://rdrr.io/pkg/Spectra/man/MsBackend.html)
object with the full peaks data stored into a *peaks.h5* HDF5 file
within the stash directory. Due to the nested directory structure it is
possible to load a `MsBackendMemory` stash either as a `MsBackendMemory`
or a `MsBackendHdf5Peaks`.

## Note

Currently only peaks variables `"mz"` and `"intensity"` are supported.

## Text-file format, `PlainTextParam`

The `MsBackendMemory` stash contains a text-file format
[MsBackendHdf5PeaksStash](https://rformassspectrometry.github.io/SpectraStash/reference/MsBackendHdf5PeaksStash.md)
within a sub-folder *backend*. When loading, the data is first imported
as a `MsBackendHdf5Peaks` which is then converted to the resulting
`MsBackendMemory` (with all data materialized into memory).

## *alabaster*-based format, `AlabasterParam`

The full data is stored as an *alabaster*-format
[MsBackendHdf5PeaksStash](https://rformassspectrometry.github.io/SpectraStash/reference/MsBackendHdf5PeaksStash.md)
in a directory *backend* within the stash folder. Due to this nesting it
is possible to load the data either as `MsBackendMemory` or
`MsBackendHdf5Peaks`.

## Author

Johannes Rainer

## Examples

``` r

library(Spectra)

## Create an example `MsBackendMemory` object.
d <- data.frame(msLevel = c(1L, 2L, 1L, 1L),
    rtime = c(12.1, 12.2, 13.1, 13.4))
d$mz <- list(
    c(14.4, 155.2, 186.4),
    c(144.3, 231.3, 345.3, 453.1),
    c(111.2, 142.4, 143.1),
    c(143.3, 144.3, 153.3, 532.3, 641.5)
)
d$intensity <- list(
    c(323.2, 53.2, 35.5),
    c(43.3, 54.1, 33.1, 53.1),
    c(435.3, 35312.3, 5432.5),
    c(433.5, 55434.2, 43.4, 54362.1, 24435.3)
)
be <- backendInitialize(MsBackendMemory(), data = d)
be
#> MsBackendMemory with 4 spectra
#>     msLevel     rtime scanIndex
#>   <integer> <numeric> <integer>
#> 1         1      12.1        NA
#> 2         2      12.2        NA
#> 3         1      13.1        NA
#> 4         1      13.4        NA
#>  ... 16 more variables/columns.

## Stash the object in alabaster-format to a temporary folder
p <- AlabasterParam(file.path(tempdir(), "mem_stash"))
saveMsObject(be, p)

## Show directory content of the stash
dir(file.path(tempdir(), "mem_stash"))
#> [1] "OBJECT"            "_environment.json" "backend"          

## Restore the object from the stash
res <- readMsObject(MsBackendMemory(), p)
res
#> MsBackendMemory with 4 spectra
#>     msLevel     rtime scanIndex
#>   <integer> <numeric> <integer>
#> 1         1      12.1         1
#> 2         2      12.2         2
#> 3         1      13.1         3
#> 4         1      13.4         4
#>  ... 16 more variables/columns.

## The in-memory backends store their full MS data through an
## [Spectra::MsBackendHdf5Peaks] backend: their peaks data is stored as a
## (single) HDF5 file within the stash. A `MsBackendMemory` stash contains
## therefore a complete stash of a `MsBackendHdf5Peaks`, which allows to
## read the data also as a `MsBackendHdf5Peaks` backend:
res <- readMsObject(MsBackendHdf5Peaks(),
    AlabasterParam(file.path(tempdir(), "mem_stash", "backend")))
res
#> MsBackendHdf5Peaks with 4 spectra
#>     msLevel     rtime scanIndex
#>   <integer> <numeric> <integer>
#> 1         1      12.1         1
#> 2         2      12.2         2
#> 3         1      13.1         3
#> 4         1      13.4         4
#>  ... 16 more variables/columns.
#> 
#> file(s):
#>  peaks.h5

## In addition to the `saveMsObject()` and `readMsObject()` functions, also
## the `saveObject()` and `readObject()` functions from *alabater.base* are
## supported (for stashes in alabaster format).
library(alabaster.base)
res <- readObject(file.path(tempdir(), "mem_stash"))
res
#> MsBackendMemory with 4 spectra
#>     msLevel     rtime scanIndex
#>   <integer> <numeric> <integer>
#> 1         1      12.1         1
#> 2         2      12.2         2
#> 3         1      13.1         3
#> 4         1      13.4         4
#>  ... 16 more variables/columns.

## Storing and restoring a `MsBackendDataFrame` backend or using a stash in
## plain text file-based format works analogously.
```
