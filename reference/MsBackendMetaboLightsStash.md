# Stash for backends for data from public repositories

Backend classes for public repository mass spectrometry data, such as
`MsBackendMetaboLights` from the
[*MsBackendMetaboLights*](https://bioconductor.org/packages/MsBackendMetaboLights)
package can be stored and restored from stash formats extending the
[MsBackendMzRStash](https://rformassspectrometry.github.io/SpectraStash/reference/MsBackendMzRStash.md).
Backends can be saved with
[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
and restored with
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html).
At present only the *alabaster*-based stash format is supported.

## Usage

``` r
# S4 method for class 'MsBackendMetaboLights'
saveObject(x, path, ...)

# S4 method for class 'MsBackendMetaboLights,AlabasterParam'
saveMsObject(object, param, ...)

# S4 method for class 'MsBackendMetaboLights,AlabasterParam'
readMsObject(object, param, offline = FALSE, ...)
```

## Arguments

- x:

  For
  [`saveObject()`](https://rdrr.io/pkg/alabaster.base/man/saveObject.html):
  a `MsBackendMetaboLights` object.

- path:

  For
  [`saveObject()`](https://rdrr.io/pkg/alabaster.base/man/saveObject.html)
  and
  [`readObject()`](https://rdrr.io/pkg/alabaster.base/man/readObject.html)

- ...:

  Ignored.

- object:

  An `MsBackendMetaboLights` object.

- param:

  An `AlabasterParam` object.

- offline:

  For
  [`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
  and
  [`readObject()`](https://rdrr.io/pkg/alabaster.base/man/readObject.html):
  `logical(1)` if online lookup and synchronization of the mass
  spectrometry data files should be disabled. Defaults to
  `offline = FALSE`. If set to `TRUE` all mass spectrometry data files
  need to be already present in the local cache.

## Value

[`readObject()`](https://rdrr.io/pkg/alabaster.base/man/readObject.html)
and
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
return a `MsBackendMetaboLights` backend.

## Note

[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
for `MsBackendMetaboLights` does not support (and does not require) the
`consolidate` parameter that most other backends implement to create
portable stashes. `MsBackendMetaboLights` backends retrieve and cache
the mass spectrometry data files if needed from the public repository
and are thus inherently portable.

## Alabaster format, `AlabasterParam`

Calling
[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html) on
a `MsBackendMetaboLights` with an `AlabasterParam` parameter object
stores the backend data in a directory specified with parameter `path`
of the parameter object. The stash folder content is identical to the
[MsBackendMzRStash](https://rformassspectrometry.github.io/SpectraStash/reference/MsBackendMzRStash.md)
with only the class definition of the *OBJECT* file being specific for
the stored backend class.

Restoring a `MsBackendMetaboLights` from the stash folder imports the
metadata and, if not available in the local cache, downloads the mass
spectrometry data files from the MetaboLights repository. Synchronizing
the locally cached data requires an active internet connection, even if
no data needs to be downloaded. Setting parameter `offline = TRUE`
avoids the synchronization, but requires the mass spectrometry data
files to be present in the local cache.

The alabaster-format stashes can also be created and restored using the
[`saveObject()`](https://rdrr.io/pkg/alabaster.base/man/saveObject.html)
and
[`readObject()`](https://rdrr.io/pkg/alabaster.base/man/readObject.html)
functions.

## Author

Johannes Rainer

## Examples

``` r

library(Spectra)
library(SpectraStash)
library(MsBackendMetaboLights)

## Retrieve mass spectrometry data files matching a specified file pattern
## for the data set MTBLS39 from MetaboLights
s <- Spectra(mtblsId = "MTBLS39", source = MsBackendMetaboLights(),
    filePattern = "73A.cdf")
#> Used data files from the assay's column "Raw Spectral Data File" since none were available in column "Derived Spectral Data File".

## Stash the `Spectra` object to a temporary folder.
d <- file.path(tempdir(), "metabolights_stash")
saveMsObject(s, AlabasterParam(d))

## List the content of the SpectraStash
dir(d)
#> [1] "OBJECT"                        "_environment.json"            
#> [3] "backend"                       "metadata"                     
#> [5] "processing"                    "processing_chunk_size"        
#> [7] "processing_queue_variables"    "spectra_processing_queue.json"

## List the content of the backend stash (located within the *backend*
## sub-folder)
dir(file.path(d, "backend"))
#> [1] "OBJECT"       "spectra_data"

## Restore the `Spectra` object (with the respective backend); using
## `offline = TRUE` to avoid the lookup of the data set on the MetaboLights
## repository - all mass spectrometry data files of the backend must then be
## already present in the local cache.
res <- readMsObject(Spectra(), AlabasterParam(d), offline = TRUE)
res
#> MSn data (Spectra) with 1584 spectra in a MsBackendMetaboLights backend:
#>        msLevel     rtime scanIndex
#>      <integer> <numeric> <integer>
#> 1            1   0.29600         1
#> 2            1   6.13152         2
#> 3            1  11.90310         3
#> 4            1  17.68512         4
#> 5            1  23.46515         5
#> ...        ...       ...       ...
#> 1580         1   2678.10       557
#> 1581         1   2682.73       558
#> 1582         1   2687.36       559
#> 1583         1   2691.96       560
#> 1584         1   2696.59       561
#>  ... 34 more variables/columns.
#> 
#> file(s):
#> MN073A.cdf
#> CS073A.cdf
#> AM073A.cdf
```
