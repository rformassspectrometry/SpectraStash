# Savely Store MS Data Objects in a Portable Stash

## Introduction

Data objects in R can be serialized to disk in R’s *rds* or *RData*
format using the base R [`save()`](https://rdrr.io/r/base/save.html)
function and re-imported using the
[`load()`](https://rdrr.io/r/base/load.html) function. This R-specific
binary data format can however not be used easily by other programming
languages preventing the exchange of R data objects between software or
programming languages. The *MsStash* package defines basic classes and
generic methods to export and import mass spectrometry (MS) data objects
in various storage formats aiming to facilitate data exchange between
software. The *SpectraStash* package implements portable data storage
formats (stashes) for data classes from the
*[Spectra](https://bioconductor.org/packages/3.24/Spectra)* package,
including the `Spectra` object and it’s various data backends.

## Installation

The package can be installed with the *BiocManager* package. To install
*BiocManager* use `install.packages("BiocManager")` and, after that,
`BiocManager::install("RforMassSpectrometry/SpectraStash")` to install
this package.

## A stash for `Spectra` objects

MS data objects can be saved and restored through the
[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
and
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
functions into (or from) MS data stashes. Supported stash formats and
their respective parameter objects are:

- `PlainTextParam`: storage of data in (a custom) plain text file
  format.
- `AlabasterParam`: storage of MS data using Bioconductor’s
  `r Biocpkg("alabaster.base")` framework using files in HDF5 and JSON
  format. MS stashes in this format fully support the functions
  [`saveObject()`](https://rdrr.io/pkg/alabaster.base/man/saveObject.html)
  and
  [`readObject()`](https://rdrr.io/pkg/alabaster.base/man/readObject.html)
  from *alabaster.base*.

See also the vignette from the
*[MsStash](https://bioconductor.org/packages/3.24/MsStash)* for details
on the formats and implementation notes.

As an example we create below a `Spectra` object from two example MS
data files from the *MsDataHub* package.

``` r

library(Spectra)
library(SpectraStash)
library(MsDataHub)
fls <- c(X20171016_POOL_POS_1_105.134.mzML(),
         X20171016_POOL_POS_3_105.134.mzML())
sps <- Spectra(fls)
sps
```

    ## MSn data (Spectra) with 1862 spectra in a MsBackendMzR backend:
    ##        msLevel     rtime scanIndex
    ##      <integer> <numeric> <integer>
    ## 1            1     0.280         1
    ## 2            1     0.559         2
    ## 3            1     0.838         3
    ## 4            1     1.117         4
    ## 5            1     1.396         5
    ## ...        ...       ...       ...
    ## 1858         1   258.636       927
    ## 1859         1   258.915       928
    ## 1860         1   259.194       929
    ## 1861         1   259.473       930
    ## 1862         1   259.752       931
    ##  ... 34 more variables/columns.
    ## 
    ## file(s):
    ## 58f29260479_7859
    ## 58f5a2bf9ae_7860

We next filter the data restricting to spectra and mass peaks with a
retention time between 20 and 200 seconds and an *m/z* between 110 and
120.

``` r

sps <- filterRt(sps, c(20, 200))
sps <- filterMzRange(sps, c(110, 120))
sps
```

    ## MSn data (Spectra) with 1290 spectra in a MsBackendMzR backend:
    ##        msLevel     rtime scanIndex
    ##      <integer> <numeric> <integer>
    ## 1            1    20.089        72
    ## 2            1    20.368        73
    ## 3            1    20.647        74
    ## 4            1    20.926        75
    ## 5            1    21.205        76
    ## ...        ...       ...       ...
    ## 1286         1   198.649       712
    ## 1287         1   198.928       713
    ## 1288         1   199.207       714
    ## 1289         1   199.486       715
    ## 1290         1   199.765       716
    ##  ... 34 more variables/columns.
    ## 
    ## file(s):
    ## 58f29260479_7859
    ## 58f5a2bf9ae_7860
    ## Lazy evaluation queue: 1 processing step(s)
    ## Processing:
    ##  Filter: select retention time [20..200] on MS level(s)  [Fri Jun 26 10:55:37 2026]
    ##  Filter: select peaks with an m/z within [110, 120] [Fri Jun 26 10:55:37 2026]

We next store this `Spectra` object to a *SpectraStash* using the
[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
function. We use an alabaster format and define the location of the
stash with the `path` parameter of `AlabasterParam`. For the present
example we save it to a temporary folder.

``` r

#' Define the location of the stash
d <- file.path(tempfile(), "spectra_stash")

#' Configure the format and location
ap <- AlabasterParam(d)

#' Save the `Spectra` object to the stash
saveMsObject(sps, ap)
```

The content of the stash folder is:

``` r

library(fs)
dir_tree(d)
```

    ## /tmp/Rtmpw4xmK3/file7a31277bfa8/spectra_stash
    ## ├── OBJECT
    ## ├── _environment.json
    ## ├── backend
    ## │   ├── OBJECT
    ## │   └── spectra_data
    ## │       ├── OBJECT
    ## │       └── basic_columns.h5
    ## ├── metadata
    ## │   ├── OBJECT
    ## │   └── list_contents.json.gz
    ## ├── processing
    ## │   ├── OBJECT
    ## │   └── contents.h5
    ## ├── processing_chunk_size
    ## │   ├── OBJECT
    ## │   └── contents.h5
    ## ├── processing_queue_variables
    ## │   ├── OBJECT
    ## │   └── contents.h5
    ## └── spectra_processing_queue.json

In alabaster format, each slot of the `Spectra` object is stored into
its own sub directory. `Spectra` objects don’t handle the MS data
itself, but rely on a `MsBackend` to provide this data. The `MsBackend`
used by the `Spectra` object is stored into it’s own stash located in
the *backend* directory of the SpectraStash. The `Spectra` object can be
restored again with
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html):

``` r

res <- readMsObject(Spectra(), ap)
res
```

    ## MSn data (Spectra) with 1290 spectra in a MsBackendMzR backend:
    ##        msLevel     rtime scanIndex
    ##      <integer> <numeric> <integer>
    ## 1            1    20.089        72
    ## 2            1    20.368        73
    ## 3            1    20.647        74
    ## 4            1    20.926        75
    ## 5            1    21.205        76
    ## ...        ...       ...       ...
    ## 1286         1   198.649       712
    ## 1287         1   198.928       713
    ## 1288         1   199.207       714
    ## 1289         1   199.486       715
    ## 1290         1   199.765       716
    ##  ... 25 more variables/columns.
    ## 
    ## file(s):
    ## 58f29260479_7859
    ## 58f5a2bf9ae_7860
    ## Lazy evaluation queue: 1 processing step(s)
    ## Processing:
    ##  Filter: select retention time [20..200] on MS level(s)  [Fri Jun 26 10:55:37 2026]
    ##  Filter: select peaks with an m/z within [110, 120] [Fri Jun 26 10:55:37 2026]

We need to specify the type of the object to restore with the first
parameter of the function - in our case
[`Spectra()`](https://rdrr.io/pkg/Spectra/man/Spectra.html). The full
`Spectra` object was restored, including the processing queue and
history.

We can also read (restore) only the `MsBackend` from the SpectraStash.
Since the present stash is in alabaster format we can either use
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html) or
also the
[`readObject()`](https://rdrr.io/pkg/alabaster.base/man/readObject.html)
from *alabaster.base*:

``` r

library(alabaster.base)
be <- readObject(file.path(d, "backend"))
be
```

    ## MsBackendMzR with 1290 spectra
    ##        msLevel     rtime scanIndex
    ##      <integer> <numeric> <integer>
    ## 1            1    20.089        72
    ## 2            1    20.368        73
    ## 3            1    20.647        74
    ## 4            1    20.926        75
    ## 5            1    21.205        76
    ## ...        ...       ...       ...
    ## 1286         1   198.649       712
    ## 1287         1   198.928       713
    ## 1288         1   199.207       714
    ## 1289         1   199.486       715
    ## 1290         1   199.765       716
    ##  ... 25 more variables/columns.
    ## 
    ## file(s):
    ## 58f29260479_7859
    ## 58f5a2bf9ae_7860

Or using
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html):

``` r

be <- readMsObject(MsBackendMzR(), AlabasterParam(file.path(d, "backend")))
be
```

    ## MsBackendMzR with 1290 spectra
    ##        msLevel     rtime scanIndex
    ##      <integer> <numeric> <integer>
    ## 1            1    20.089        72
    ## 2            1    20.368        73
    ## 3            1    20.647        74
    ## 4            1    20.926        75
    ## 5            1    21.205        76
    ## ...        ...       ...       ...
    ## 1286         1   198.649       712
    ## 1287         1   198.928       713
    ## 1288         1   199.207       714
    ## 1289         1   199.486       715
    ## 1290         1   199.765       716
    ##  ... 25 more variables/columns.
    ## 
    ## file(s):
    ## 58f29260479_7859
    ## 58f5a2bf9ae_7860

### Creating self-contained stashes

Our example `Spectra` object uses an `MsBackendMzR` backend which keeps
only limited information in memory and retrieves the peaks data (i.e.,
the *m/z* and intensity values) from the original MS data files upon
demand. The stash for `MsBackendMzR` objects contains therefore also
only the spectra metadata and a reference to the original MS data
files - but no peaks data.

If the original MS data files were moved to a different location or if
the SpectraStash folder was moved to another computer, the updated path
to the raw MS data files would need to be provided with the
`spectraPath` parameter of the
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
function. As an alternative, it is also possible to create a
*self-contained* stash setting `consolidate = TRUE` in
[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html).
We below save our `Spectra` object again, this time into a
self-contained stash.

``` r

d2 <- file.path(tempdir(), "spectra_stash2")
saveMsObject(sps, AlabasterParam(d2), consolidate = TRUE)
```

The `consolidate = TRUE` parameter is passed to the
[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
call of the `MsBackend`, which, for `MsBackendMzR` copies the original
MS data files **into** the stash folder:

``` r

dir_tree(d2)
```

    ## /tmp/Rtmpw4xmK3/spectra_stash2
    ## ├── OBJECT
    ## ├── _environment.json
    ## ├── backend
    ## │   ├── 58f29260479_7859
    ## │   ├── 58f5a2bf9ae_7860
    ## │   ├── OBJECT
    ## │   └── spectra_data
    ## │       ├── OBJECT
    ## │       └── basic_columns.h5
    ## ├── metadata
    ## │   ├── OBJECT
    ## │   └── list_contents.json.gz
    ## ├── processing
    ## │   ├── OBJECT
    ## │   └── contents.h5
    ## ├── processing_chunk_size
    ## │   ├── OBJECT
    ## │   └── contents.h5
    ## ├── processing_queue_variables
    ## │   ├── OBJECT
    ## │   └── contents.h5
    ## └── spectra_processing_queue.json

Note the two additional files in the *backend* folder - these are the
original MS data files in mzML format. Such a self-contained stash
folder allows to restore the full data even if the stash is moved to
another file system. Of course, depending on the size of the data set
and the respective raw MS data files, the stash folder can become very
large.

### Stashes for `Spectra` with in-memory backends

In addition to the *on-disk* backends `MsBackendMzR` and
`MsBackendHdf5Peaks`, *Spectra* defines also *in-memory* backends
`MsBackendMemory` and `MsBackendDataFrame`, which keep the full MS data
in memory. Below we change the backend of our `sps` object to
`MsBackendMemory`:

``` r

sps <- setBackend(sps, MsBackendMemory())
sps
```

    ## MSn data (Spectra) with 1290 spectra in a MsBackendMemory backend:
    ##        msLevel     rtime scanIndex
    ##      <integer> <numeric> <integer>
    ## 1            1    20.089        72
    ## 2            1    20.368        73
    ## 3            1    20.647        74
    ## 4            1    20.926        75
    ## 5            1    21.205        76
    ## ...        ...       ...       ...
    ## 1286         1   198.649       712
    ## 1287         1   198.928       713
    ## 1288         1   199.207       714
    ## 1289         1   199.486       715
    ## 1290         1   199.765       716
    ##  ... 34 more variables/columns.
    ## Lazy evaluation queue: 1 processing step(s)
    ## Processing:
    ##  Filter: select retention time [20..200] on MS level(s)  [Fri Jun 26 10:55:37 2026]
    ##  Filter: select peaks with an m/z within [110, 120] [Fri Jun 26 10:55:37 2026]
    ##  Switch backend from MsBackendMzR to MsBackendMemory [Fri Jun 26 10:55:39 2026]

We next stash this updated `Spectra` object removing first the stash
directory of the previous SpectraStash (because overwriting stash
directories is not allowed).

``` r

#' Remove the existing SepctraStash
unlink(d2, recursive = TRUE)

#' Store the `Spectra` object in alabaster format
saveMsObject(sps, AlabasterParam(d2))
```

Inspecting the content of the stash folder we can see a different
structure:

``` r

dir_tree(d2)
```

    ## /tmp/Rtmpw4xmK3/spectra_stash2
    ## ├── OBJECT
    ## ├── _environment.json
    ## ├── backend
    ## │   ├── OBJECT
    ## │   └── backend
    ## │       ├── OBJECT
    ## │       ├── mod_count
    ## │       │   ├── OBJECT
    ## │       │   └── contents.h5
    ## │       ├── peaks.h5
    ## │       └── spectra_data
    ## │           ├── OBJECT
    ## │           └── basic_columns.h5
    ## ├── metadata
    ## │   ├── OBJECT
    ## │   └── list_contents.json.gz
    ## ├── processing
    ## │   ├── OBJECT
    ## │   └── contents.h5
    ## ├── processing_chunk_size
    ## │   ├── OBJECT
    ## │   └── contents.h5
    ## ├── processing_queue_variables
    ## │   ├── OBJECT
    ## │   └── contents.h5
    ## └── spectra_processing_queue.json

The MS peaks data is now stored within a file *peaks.h5*, a file in a
HDF5 format used by the `MsBackendHdf5Peaks` backend: saving in-memory
backends changes the data first to a `MsBackendHdf5Peaks` backend which
is then stored into an additional *backend* sub-folder of the stash. We
can restore the `Spectra` object with:

``` r

readMsObject(Spectra(), AlabasterParam(d2))
```

    ## MSn data (Spectra) with 1290 spectra in a MsBackendMemory backend:
    ##        msLevel     rtime scanIndex
    ##      <integer> <numeric> <integer>
    ## 1            1    20.089         1
    ## 2            1    20.368         2
    ## 3            1    20.647         3
    ## 4            1    20.926         4
    ## 5            1    21.205         5
    ## ...        ...       ...       ...
    ## 1286         1   198.649      1286
    ## 1287         1   198.928      1287
    ## 1288         1   199.207      1288
    ## 1289         1   199.486      1289
    ## 1290         1   199.765      1290
    ##  ... 25 more variables/columns.
    ## Lazy evaluation queue: 1 processing step(s)
    ## Processing:
    ##  Filter: select retention time [20..200] on MS level(s)  [Fri Jun 26 10:55:37 2026]
    ##  Filter: select peaks with an m/z within [110, 120] [Fri Jun 26 10:55:37 2026]
    ##  Switch backend from MsBackendMzR to MsBackendMemory [Fri Jun 26 10:55:39 2026]

In addition, we can restore the `MsBackendMemory` with:

``` r

readMsObject(MsBackendMemory(), AlabasterParam(file.path(d2, "backend")))
```

    ## MsBackendMemory with 1290 spectra
    ##        msLevel     rtime scanIndex
    ##      <integer> <numeric> <integer>
    ## 1            1    20.089         1
    ## 2            1    20.368         2
    ## 3            1    20.647         3
    ## 4            1    20.926         4
    ## 5            1    21.205         5
    ## ...        ...       ...       ...
    ## 1286         1   198.649      1286
    ## 1287         1   198.928      1287
    ## 1288         1   199.207      1288
    ## 1289         1   199.486      1289
    ## 1290         1   199.765      1290
    ##  ... 25 more variables/columns.

and also the `MsBackendHdf5Peaks` which is used as the actual data
storage format for the in-memory `MsBackendMemory` (note the double
*backend* sub-folder):

``` r

readMsObject(MsBackendHdf5Peaks(),
             AlabasterParam(file.path(d2, "backend", "backend")))
```

    ## MsBackendHdf5Peaks with 1290 spectra
    ##        msLevel     rtime scanIndex
    ##      <integer> <numeric> <integer>
    ## 1            1    20.089         1
    ## 2            1    20.368         2
    ## 3            1    20.647         3
    ## 4            1    20.926         4
    ## 5            1    21.205         5
    ## ...        ...       ...       ...
    ## 1286         1   198.649      1286
    ## 1287         1   198.928      1287
    ## 1288         1   199.207      1288
    ## 1289         1   199.486      1289
    ## 1290         1   199.765      1290
    ##  ... 25 more variables/columns.
    ## 
    ## file(s):
    ##  peaks.h5

## Session information

``` r

sessionInfo()
```

    ## R version 4.6.0 (2026-04-24)
    ## Platform: x86_64-pc-linux-gnu
    ## Running under: Ubuntu 24.04.4 LTS
    ## 
    ## Matrix products: default
    ## BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
    ## LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
    ## 
    ## locale:
    ##  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
    ##  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
    ##  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
    ##  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
    ##  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
    ## [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
    ## 
    ## time zone: UTC
    ## tzcode source: system (glibc)
    ## 
    ## attached base packages:
    ## [1] stats4    stats     graphics  grDevices utils     datasets  methods  
    ## [8] base     
    ## 
    ## other attached packages:
    ##  [1] alabaster.base_1.13.0 fs_2.1.0              MsDataHub_1.13.0     
    ##  [4] SpectraStash_0.97.6   MsStash_0.99.0        Spectra_1.23.3       
    ##  [7] BiocParallel_1.47.0   S4Vectors_0.51.3      BiocGenerics_0.59.7  
    ## [10] generics_0.1.4        BiocStyle_2.41.0     
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] tidyselect_1.2.1         dplyr_1.2.1              blob_1.3.0              
    ##  [4] filelock_1.0.3           Biostrings_2.81.3        fastmap_1.2.0           
    ##  [7] BiocFileCache_3.3.0      digest_0.6.39            lifecycle_1.0.5         
    ## [10] cluster_2.1.8.2          ProtGenerics_1.45.0      KEGGREST_1.53.1         
    ## [13] RSQLite_3.53.2           magrittr_2.0.5           compiler_4.6.0          
    ## [16] rlang_1.2.0              sass_0.4.10              tools_4.6.0             
    ## [19] yaml_2.3.12              data.table_1.18.4        knitr_1.51              
    ## [22] htmlwidgets_1.6.4        bit_4.6.0                curl_7.1.0              
    ## [25] withr_3.0.3              purrr_1.2.2              desc_1.4.3              
    ## [28] ExperimentHub_3.3.0      Rhdf5lib_2.1.0           MASS_7.3-65             
    ## [31] cli_3.6.6                mzR_2.47.0               rmarkdown_2.31          
    ## [34] crayon_1.5.3             ragg_1.5.2               otel_0.2.0              
    ## [37] httr_1.4.8               ncdf4_1.24               DBI_1.3.0               
    ## [40] cachem_1.1.0             rhdf5_2.57.1             parallel_4.6.0          
    ## [43] AnnotationDbi_1.75.0     BiocManager_1.30.27      XVector_0.53.0          
    ## [46] alabaster.schemas_1.13.0 vctrs_0.7.3              jsonlite_2.0.0          
    ## [49] bookdown_0.47            IRanges_2.47.2           bit64_4.8.2             
    ## [52] clue_0.3-68              systemfonts_1.3.2        jquerylib_0.1.4         
    ## [55] glue_1.8.1               pkgdown_2.2.0.9000       codetools_0.2-20        
    ## [58] BiocVersion_3.24.0       tibble_3.3.1             pillar_1.11.1           
    ## [61] rappdirs_0.3.4           htmltools_0.5.9          Seqinfo_1.3.0           
    ## [64] rhdf5filters_1.25.0      R6_2.6.1                 dbplyr_2.6.0            
    ## [67] httr2_1.2.3              textshaping_1.0.5        evaluate_1.0.5          
    ## [70] Biobase_2.73.1           AnnotationHub_4.3.1      png_0.1-9               
    ## [73] memoise_2.0.1            bslib_0.11.0             MetaboCoreUtils_1.21.1  
    ## [76] Rcpp_1.1.1-1.1           xfun_0.59                MsCoreUtils_1.25.4      
    ## [79] pkgconfig_2.0.3
