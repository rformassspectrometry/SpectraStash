# MsBackendHdf5Peaks Stash

`MsBackendHdf5Peaks` classes can be stashed to (or read from) plain text
file-based or *alabaster*-based formats using the
[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
and
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
functions combined with the
[PlainTextParam](https://rdrr.io/pkg/MsStash/man/PlainTextParam.html)
and
[AlabasterParam](https://rdrr.io/pkg/MsStash/man/AlabasterParam.html)
parameter objects, respectively. In both cases, data files are stored
into the specified directory. By default, only the backend's spectra
metadata is stored in that folder. Setting parameter
`consolidate = TRUE` will also copy the HDF5-format peaks data files
(containing the *m/z* and intensity values) of the backend into the
folder generating a self-consistent stash. The paths to the data storage
files are also updated to relative paths enabling to directly restore
the object from the stash when the stash folder was copied to another
computer or location on the file system (i.e., without the use of
parameter `spectraPath`).

Details on the stored files are provided in the sections below.

## Usage

``` r
# S4 method for class 'MsBackendHdf5Peaks,PlainTextParam'
saveMsObject(object, param, consolidate = FALSE)

# S4 method for class 'MsBackendHdf5Peaks,PlainTextParam'
readMsObject(object, param, spectraPath = character())

# S4 method for class 'MsBackendHdf5Peaks'
saveObject(x, path, consolidate = FALSE, ...)

# S4 method for class 'MsBackendHdf5Peaks,AlabasterParam'
saveMsObject(object, param, consolidate = FALSE)

# S4 method for class 'MsBackendHdf5Peaks,AlabasterParam'
readMsObject(object, param, spectraPath = character())
```

## Arguments

- object:

  An `MsBackendHdf5Peaks` object.

- param:

  Either a `PlainTextParam` or `AlabasterParam`.

- consolidate:

  `logical(1)` whether in addition to the spectra metadata also the
  peaks data file (in HDF5 format) should be stored in the stash folder.
  Default is `consolidate = FALSE`.

- spectraPath:

  For
  [`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html):
  optional `character(1)` with the path to the peaks data in HDF5-format
  (in case they are on longer available in the folder referred to by the
  original stashed `MsBackendHdf5Peaks` object).

- x:

  An `MsBackendHdf5Peaks` object.

- path:

  For `saveObject()`: `character(1)` with the path where the object
  should be stored in.

- ...:

  Currently ignored.

## Value

[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
returns an
[Spectra::MsBackendHdf5Peaks](https://rdrr.io/pkg/Spectra/man/MsBackend.html)\`
object.

## Details

A `MsBackendHdf5Peaks` stash will by default only contain the spectra
metadata (spectra variables) but no *m/z* and intensity values. The
reference to the original HDF5-format peaks data files are stored as
spectra variable *dataStorage*. If these files were moved or if the
stash was copied to a different computer, the path to these original
data files needs to be provided to the
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
function with parameter `spectraPath`. Alternatively, with
`consolidate = TRUE`, it is also possible to **copy** the peaks data
files to the stash directory generating a self-contained data stash.
Note however that in this case two copies of all data files exist (in
the original location **and** the stash directory).

## Text-file format, `PlainTextParam`

The
[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
function with the `PlainTextParam` stores the spectra metadata (spectra
variables) of an `MsBackendHdf5Peaks` to a plain tabulator delimited
text file with the name *ms_backend_spectra_data.txt* in the directory
specified with parameter `path` of the `PlainTextParam` object.
Depending on parameter `consolidate` also the peaks data files (in HDF5
format) will be copied to the stash folder (with `consolidate = TRUE`).

## *abalbaster*-based format, `AlabasterParam`

With `AlabasterParam`, the spectra metadata will be exported (or
imported) through the *alabaster* framework. Similar to the
`PlainTextParam`, `consolidate = TRUE` will also copy the HDF5-format
peaks data files to the stash directory.

## Author

Johannes Rainer

## Examples

``` r

library(Spectra)
library(SpectraStash)
## Create an example MsBackendHdf5Peaks backend from a single mzML file
library(MsDataHub)
tmp <- backendInitialize(MsBackendMzR(), X20171016_POOL_POS_1_105.134.mzML())
#> see ?MsDataHub and browseVignettes('MsDataHub') for documentation
#> loading from cache
be_h5 <- backendInitialize(MsBackendHdf5Peaks(), data = spectraData(tmp),
    hdf5path = file.path(tempdir(), "h5_backend"))
be_h5
#> MsBackendHdf5Peaks with 931 spectra
#>       msLevel     rtime scanIndex
#>     <integer> <numeric> <integer>
#> 1           1     0.280         1
#> 2           1     0.559         2
#> 3           1     0.838         3
#> 4           1     1.117         4
#> 5           1     1.396         5
#> ...       ...       ...       ...
#> 927         1   258.641       927
#> 928         1   258.920       928
#> 929         1   259.199       929
#> 930         1   259.478       930
#> 931         1   259.757       931
#>  ... 34 more variables/columns.
#> 
#> file(s):
#>  5e1225b6b7_7859.h5

d <- file.path(tempdir(), "example_hdf5")
ptp <- PlainTextParam(path = d)

## Store the object into the stash, including the peaks data files.
saveMsObject(be_h5, ptp, consolidate = TRUE)

## List the content of the folder: ms_backend_spectra_data.txt file
## with the spectra metadata and an HDF5 file with the peaks data:
dir(d)
#> [1] "5e1225b6b7_7859.h5"          "ms_backend_spectra_data.txt"

## Restore the stashed object
res <- readMsObject(MsBackendHdf5Peaks(), ptp)

## Store the object in an alabaster-format stash
d <- file.path(tempdir(), "example_hdf5_2")

ap <- AlabasterParam(d)
saveMsObject(be_h5, ap)

## Check the content of the stash; with the default (`consolidate = FALSE`)
## no HDF5 data file was moved.
dir(d)
#> [1] "OBJECT"            "_environment.json" "mod_count"        
#> [4] "spectra_data"     

## Restore the object again
res <- readMsObject(MsBackendHdf5Peaks(), ap)
res
#> MsBackendHdf5Peaks with 931 spectra
#>       msLevel     rtime scanIndex
#>     <integer> <numeric> <integer>
#> 1           1     0.280         1
#> 2           1     0.559         2
#> 3           1     0.838         3
#> 4           1     1.117         4
#> 5           1     1.396         5
#> ...       ...       ...       ...
#> 927         1   258.641       927
#> 928         1   258.920       928
#> 929         1   259.199       929
#> 930         1   259.478       930
#> 931         1   259.757       931
#>  ... 25 more variables/columns.
#> 
#> file(s):
#>  5e1225b6b7_7859.h5
```
