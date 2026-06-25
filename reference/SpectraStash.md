# Spectra Stash

`Spectra` objects can be stashed to (or read from) plain text file-based
or *alabaster*-based formats using the
[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html) or
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
functions configured with the
[PlainTextParam](https://rdrr.io/pkg/MsStash/man/PlainTextParam.html) or
[AlabasterParam](https://rdrr.io/pkg/MsStash/man/AlabasterParam.html)
parameter objects, respectively. In both cases, the data from the
`Spectra` object is stored into the *stash* directory defined with the
parameter object. Depending on the used MS backend (and parameters
used), the stash can also contain the MS data files.

At present, `Spectra` objects using one of the following MS data
backends are supported:

- `MsBackendMzR`: see
  [MsBackendMzRStash](https://rformassspectrometry.github.io/SpectraStash/reference/MsBackendMzRStash.md)
  for details and options.

- `MsBackendHdf5Peaks`: see
  [MsBackendHdf5PeaksStash](https://rformassspectrometry.github.io/SpectraStash/reference/MsBackendHdf5PeaksStash.md)
  for details and options.

The data backend of any `Spectra` backend can eventually be changed to
one of the above backends using the
[`Spectra::setBackend()`](https://rdrr.io/pkg/ProtGenerics/man/backendInitialize.html)
method to support saving the object into a `Spectra` stash. Support for
additional backends respectively data representations might also be
provided by separate R packages.

Details on the stash formats are provided in the respective sections
below.

## Usage

``` r
# S4 method for class 'Spectra,PlainTextParam'
saveMsObject(object, param, ...)

# S4 method for class 'Spectra,PlainTextParam'
readMsObject(object, param, ...)

# S4 method for class 'Spectra'
saveObject(x, path, ...)

# S4 method for class 'Spectra,AlabasterParam'
saveMsObject(object, param, ...)

# S4 method for class 'Spectra,AlabasterParam'
readMsObject(object, param, ...)
```

## Arguments

- object:

  A `Spectra` object.

- param:

  Either a `PlainTextParam` or `AlabasterParam`.

- ...:

  additional arguments passed to the `saveMsObject` or `readMsObject`
  method of the `Spectra`'s `MsBackend`, such as for example
  `consolidate` or `spectraPath`. See the
  [`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
  and
  [`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
  documentation of the used `MsBackend` class for information on
  supported arguments.

- x:

  A `Spectra` object.

- path:

  For
  [`saveObject()`](https://rdrr.io/pkg/alabaster.base/man/saveObject.html):
  `character(1)` with the path where the object should be stored in.

## Value

[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
returns a
[Spectra::Spectra](https://rdrr.io/pkg/Spectra/man/Spectra.html) object.

## Text-file format, `PlainTextParam`

For this format, the data content of a `Spectra` object is stored into
the files:

- *spectra_slots.txt*: plain text file containning the *processing
  queue* variables (separated by a `"|"`), the processing log messages
  (separated by a `"|"`), the processing chunk size and the `MsBackend`
  class used.

- *spectra_processing_queue.json*: the object's processing queue
  serialized in JSON format. It can be unserialized using
  [`jsonlite::unserializeJSON()`](https://jeroen.r-universe.dev/jsonlite/reference/serializeJSON.html).

For information on the MS backend's data see the respective
documentation.

## *abalbaster*-based format, `AlabasterParam`

With `AlabasterParam`, the `Spectra` object will be exported (or
imported) through the *alabaster* framework as a set of JSON and/or HDF5
files. The content of each slot is stored to a separate file with the
name matching the slot name (converted to *snake_case*). The object's
`MsBackend` is stored into a sub-folder *backend* within the stash
folder.

For information on the MS backend's data stash see the respective
documentation.

## Author

Johannes Rainer, Philippine Louail

## Examples

``` r

## Create a Spectra object from two example MS data files (from MsDataHub)
library(Spectra)
library(MsDataHub)
s <- Spectra(
    c(X20171016_POOL_POS_1_105.134.mzML(),
      X20171016_POOL_POS_3_105.134.mzML()))
#> see ?MsDataHub and browseVignettes('MsDataHub') for documentation
#> loading from cache
#> see ?MsDataHub and browseVignettes('MsDataHub') for documentation
#> loading from cache
s
#> MSn data (Spectra) with 1862 spectra in a MsBackendMzR backend:
#>        msLevel     rtime scanIndex
#>      <integer> <numeric> <integer>
#> 1            1     0.280         1
#> 2            1     0.559         2
#> 3            1     0.838         3
#> 4            1     1.117         4
#> 5            1     1.396         5
#> ...        ...       ...       ...
#> 1858         1   258.636       927
#> 1859         1   258.915       928
#> 1860         1   259.194       929
#> 1861         1   259.473       930
#> 1862         1   259.752       931
#>  ... 34 more variables/columns.
#> 
#> file(s):
#> 5e1225b6b7_7859
#> 5e149b7c978_7860

## Filter the intensities of the Spectra removing peaks with an intensity
## below 100
s <- filterIntensity(s, intensity = 100)

## Define the format and location of the `Spectra` stash: use the
## *alabaster*-based format and store the stash in a folder named
## *spectra_stash* in a temporary directory
ap <- AlabasterParam(file.path(tempdir(), "spectra_stash"))

## Stash the `Spectra` object copying in addition the MS data files into the
## stash (`consolidate = TRUE`).
saveMsObject(s, ap, consolidate = TRUE)

## Show the content of the stash
dir(ap@path)
#> [1] "OBJECT"                        "_environment.json"            
#> [3] "backend"                       "metadata"                     
#> [5] "processing"                    "processing_chunk_size"        
#> [7] "processing_queue_variables"    "spectra_processing_queue.json"

## Read the `Spectra` object from the stash:
res <- readMsObject(Spectra(), ap)
res
#> MSn data (Spectra) with 1862 spectra in a MsBackendMzR backend:
#>        msLevel     rtime scanIndex
#>      <integer> <numeric> <integer>
#> 1            1     0.280         1
#> 2            1     0.559         2
#> 3            1     0.838         3
#> 4            1     1.117         4
#> 5            1     1.396         5
#> ...        ...       ...       ...
#> 1858         1   258.636       927
#> 1859         1   258.915       928
#> 1860         1   259.194       929
#> 1861         1   259.473       930
#> 1862         1   259.752       931
#>  ... 25 more variables/columns.
#> 
#> file(s):
#> 5e1225b6b7_7859
#> 5e149b7c978_7860
#> Lazy evaluation queue: 1 processing step(s)
#> Processing:
#>  Remove peaks with intensities outside [100, Inf] in spectra of MS level(s) 1. [Thu Jun 25 13:55:03 2026] 

## It is also possible to read individual contents from the stash. The
## directory *backend* contains for example the stashed `MsBackend` of the
## `Spectra` object. To read only the `MsBackend`:
ap2 <- AlabasterParam(file.path(tempdir(), "spectra_stash", "backend"))
b <- readMsObject(MsBackendMzR(), ap2)
b
#> MsBackendMzR with 1862 spectra
#>        msLevel     rtime scanIndex
#>      <integer> <numeric> <integer>
#> 1            1     0.280         1
#> 2            1     0.559         2
#> 3            1     0.838         3
#> 4            1     1.117         4
#> 5            1     1.396         5
#> ...        ...       ...       ...
#> 1858         1   258.636       927
#> 1859         1   258.915       928
#> 1860         1   259.194       929
#> 1861         1   259.473       930
#> 1862         1   259.752       931
#>  ... 25 more variables/columns.
#> 
#> file(s):
#> 5e1225b6b7_7859
#> 5e149b7c978_7860

## Alternatively, that data can also be read directly with the `readObject()`
## method from the *alabaster.base* package:
library(alabaster.base)
b <- readObject(file.path(ap@path, "backend"))
b
#> MsBackendMzR with 1862 spectra
#>        msLevel     rtime scanIndex
#>      <integer> <numeric> <integer>
#> 1            1     0.280         1
#> 2            1     0.559         2
#> 3            1     0.838         3
#> 4            1     1.117         4
#> 5            1     1.396         5
#> ...        ...       ...       ...
#> 1858         1   258.636       927
#> 1859         1   258.915       928
#> 1860         1   259.194       929
#> 1861         1   259.473       930
#> 1862         1   259.752       931
#>  ... 25 more variables/columns.
#> 
#> file(s):
#> 5e1225b6b7_7859
#> 5e149b7c978_7860
```
