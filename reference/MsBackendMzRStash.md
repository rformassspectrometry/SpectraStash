# MsBackendMzR Stash

`MsBackendMzR` classes can be stashed to (or read from) plain text
file-based or *alabaster*-based formats using the
[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
and
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
functions combined with the
[PlainTextParam](https://rdrr.io/pkg/MsStash/man/PlainTextParam.html)
and
[AlabasterParam](https://rdrr.io/pkg/MsStash/man/AlabasterParam.html)
parameter objects, respectively. Setting parameter `consolidate = TRUE`
in the
[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html) or
`saveObject()` function will copy also the original MS data files into
the folder generating a self-consistent stash. This stash folder can
also be copied to another computer or location in the file system
without the need to use parameter `spectraPath` when restoring the data.

Additional properties of the stash formats are described in detail in
the sections below.

## Usage

``` r
# S4 method for class 'MsBackendMzR,PlainTextParam'
saveMsObject(object, param, consolidate = FALSE)

# S4 method for class 'MsBackendMzR,PlainTextParam'
readMsObject(object, param, spectraPath = character())

# S4 method for class 'MsBackendMzR'
saveObject(x, path, consolidate = FALSE, ...)

# S4 method for class 'MsBackendMzR,AlabasterParam'
saveMsObject(object, param, consolidate = FALSE)

# S4 method for class 'MsBackendMzR,AlabasterParam'
readMsObject(object, param, spectraPath = character())
```

## Arguments

- object:

  An `MsBackendMzR` object.

- param:

  Either a `PlainTextParam` or `AlabasterParam`.

- consolidate:

  `logical(1)` whether in addition to the spectra metadata also the
  original MS data files should be stored in the stash folder. Default
  is `consolidate = FALSE`.

- spectraPath:

  For
  [`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html):
  optional `character(1)` with the path to the MS data files (mzML,
  mzXML or CDF) in case they are on longer available in the folder
  referred to by the original stashed `MsBackendMzR` object.

- x:

  An `MsBackendMzR` object.

- path:

  For `saveObject()`: `character(1)` with the path where the object
  should be stored in.

- ...:

  Currently ignored.

## Value

[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
returns an
[Spectra::MsBackendMzR](https://rdrr.io/pkg/Spectra/man/MsBackend.html)\`
object.

## Details

`MsBackendMzR` objects don't contain any peaks data (i.e., *m/z* and
intensity values) but retrieve these from the original MS data files (in
mzML, mzXML or CDF format). Unless `consolidate = TRUE` is used, a
`MsBackendMzR` stash will therefore only contain the spectra metadata
(i.e., the spectra variables) but no peaks data. The reference to the
original MS data files is stored as spectra variable *dataStorage* and
if the files are no longer available in the directory specified by
*dataStorage* the restored object will not be valid, unless the new
location is provided with parameter `spectraPath`.

## Text-file format, `PlainTextParam`

The
[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
function with the `PlainTextParam` stores the spectra metadata (spectra
variables) of an `MsBackendMzR` to a plain tabulator delimited text file
with the name *ms_backend_spectra_data.txt* in the directory specified
with parameter `path` of the `PlainTextParam` object. Importantly, the
peaks data (the *m/z* and intensity values) are **not** exported with
[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html).

[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
restores a previously stashed `MsBackendMzR` object from the directory
specified with parameter `path` of the `PlainTextParam`.

The additional parameter `spectraPath` of
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
allows to define the path to the MS data files containing the full MS
data (i.e., the mzML, mzXML or CDF files referred to by the
`MsBackendMzR`).

## *alabaster*-based format, `AlabasterParam`

The
[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
with an `AlabasterParam` parameter object stashes the provided
`MsBackendMzR` object in an *alabster*-based format into the directory
defined with argument `param` of the `AlabasterParam`.
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
with `AlabasterParam` restores a previously stashed `MsBackend` object.
Optional parameter `spectraPath` allows to specify the storage path of
the MS data files referenced by the `MsBackendMzR` (in case they are no
longer in the same directory when saving the object).

In addition, the *alabaster* methods `saveObject()` and `readObject()`
can be used to save and read `MsBackendMzR` objects.

## Author

Philippine Louail, Johannes Rainer

## Examples

``` r

library(SpectraStash)
library(Spectra)
library(MsDataHub)

## Create a MsBackendMzR from test data
be <- backendInitialize(MsBackendMzR(), PestMix1_DDA.mzML())
#> see ?MsDataHub and browseVignettes('MsDataHub') for documentation
#> loading from cache
be
#> MsBackendMzR with 7602 spectra
#>        msLevel     rtime scanIndex
#>      <integer> <numeric> <integer>
#> 1            1     0.231         1
#> 2            1     0.351         2
#> 3            1     0.471         3
#> 4            1     0.591         4
#> 5            1     0.711         5
#> ...        ...       ...       ...
#> 7598         1   899.491      7598
#> 7599         1   899.613      7599
#> 7600         1   899.747      7600
#> 7601         1   899.872      7601
#> 7602         1   899.993      7602
#>  ... 34 more variables/columns.
#> 
#> file(s):
#> 87376588929_7861

## Define a folder where to stash the object
pth <- file.path(tempdir(), "mzr_stash")

## Stash the object to this folder in a plain text-based format
saveMsObject(be, PlainTextParam(pth))

## Restore the stashed object
res <- readMsObject(MsBackendMzR(), PlainTextParam(pth))
res
#> MsBackendMzR with 7602 spectra
#>        msLevel     rtime scanIndex
#>      <integer> <numeric> <integer>
#> 1            1     0.231         1
#> 2            1     0.351         2
#> 3            1     0.471         3
#> 4            1     0.591         4
#> 5            1     0.711         5
#> ...        ...       ...       ...
#> 7598         1   899.491      7598
#> 7599         1   899.613      7599
#> 7600         1   899.747      7600
#> 7601         1   899.872      7601
#> 7602         1   899.993      7602
#>  ... 27 more variables/columns.
#> 
#> file(s):
#> 87376588929_7861

## Clean-up
unlink(pth, recursive = TRUE)

## Store the data in *alabaster* format including also the original MS
## data files (`consolidate = TRUE`)
saveMsObject(be, AlabasterParam(pth), consolidate = TRUE)

## Get the directory content of the stash folder:
dir(pth)
#> [1] "87376588929_7861"  "OBJECT"            "_environment.json"
#> [4] "spectra_data"     

## Restore the object
res <- readMsObject(MsBackendMzR(), AlabasterParam(pth))
res
#> MsBackendMzR with 7602 spectra
#>        msLevel     rtime scanIndex
#>      <integer> <numeric> <integer>
#> 1            1     0.231         1
#> 2            1     0.351         2
#> 3            1     0.471         3
#> 4            1     0.591         4
#> 5            1     0.711         5
#> ...        ...       ...       ...
#> 7598         1   899.491      7598
#> 7599         1   899.613      7599
#> 7600         1   899.747      7600
#> 7601         1   899.872      7601
#> 7602         1   899.993      7602
#>  ... 27 more variables/columns.
#> 
#> file(s):
#> 87376588929_7861

## If the data is exported with `consolidate = FALSE` (the default), the
## new location of MS data files could be provided with parameter
## `spectraPath` of the `readMsObject()` function in case they are no
## longer in the path referenced by the stashed object.

## Clean-up
unlink(pth, recursive = TRUE)
```
