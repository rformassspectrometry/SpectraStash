# Stash for SQL-based backends

`MsBackendOfflineSql` and `MsBackendSql` backend classes defined in the
[*MsBackendSql*](https://bioconductor.org/packages/MsBackendSql)
Bioconductor package can be stashed (or read from) plain text file or
*alabaster*-based stash formats using the
[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
and
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
functions configuring the stash with a
[PlainTextParam](https://rdrr.io/pkg/MsStash/man/PlainTextParam.html) or
[AlabasterParam](https://rdrr.io/pkg/MsStash/man/AlabasterParam.html)
parameter object. The Alabaster format is the preferred stash format.

Additional properties of the stash formats are described in detail in
the sections below.

## Usage

``` r
# S4 method for class 'MsBackendOfflineSql,PlainTextParam'
saveMsObject(object, param, consolidate = FALSE, ...)

# S4 method for class 'MsBackendOfflineSql,PlainTextParam'
readMsObject(object, param, password = character(), ...)

# S4 method for class 'MsBackendSql,PlainTextParam'
saveMsObject(object, param, consolidate = FALSE, ...)

# S4 method for class 'MsBackendSql,PlainTextParam'
readMsObject(object, param, password = character())

# S4 method for class 'MsBackendOfflineSql'
saveObject(x, path, consolidate = FALSE, ...)

# S4 method for class 'MsBackendOfflineSql,AlabasterParam'
saveMsObject(object, param, consolidate = FALSE, ...)

# S4 method for class 'MsBackendOfflineSql,AlabasterParam'
readMsObject(object, param, password = character())

# S4 method for class 'MsBackendSql'
saveObject(x, path, consolidate = FALSE, ...)

# S4 method for class 'MsBackendSql,AlabasterParam'
saveMsObject(object, param, consolidate = FALSE, ...)

# S4 method for class 'MsBackendSql,AlabasterParam'
readMsObject(object, param, password = character())
```

## Arguments

- object:

  An `MsBackendOfflineSql` or `MsBackendSql` object.

- param:

  Either a `PlainTextParam` or `AlabasterParam`.

- consolidate:

  `logical(1)` whether the database file should be copied into the stash
  folder. This is currently only supported for some database formats and
  systems. See *notes* section for details.

- ...:

  Currently ignored.

- password:

  Optional `character(1)` with the password required to connect to the
  database. Passwords are never stored in a stash, thus, if required,
  the password to connect to the SQL database must be provided through
  this parameter.

- x:

  For
  [`saveObject()`](https://rdrr.io/pkg/alabaster.base/man/saveObject.html):
  a `MsBackendOfflineSql`.

- path:

  For
  [`saveObject()`](https://rdrr.io/pkg/alabaster.base/man/saveObject.html)
  and
  [`readObject()`](https://rdrr.io/pkg/alabaster.base/man/readObject.html):
  the path to the stash directory.

## Value

[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
returns a
[MsBackendSql::MsBackendOfflineSql](https://rdrr.io/pkg/MsBackendSql/man/MsBackendOfflineSql.html)
object or
[MsBackendSql::MsBackendSql](https://rdrr.io/pkg/MsBackendSql/man/MsBackendSql.html)
object.

## Note

For some SQL database systems it is possible to store also the database
into the stash folder (by setting `consolidate = TRUE` in the
[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
call). This is currently supported for:

- SQLite-based databases (using the *RSQLite* package)

`MsBackendSql` backends are converted to a `MsBackendOfflineSql` before
saving into the stash, because database connections can not be
serialized. Thus, both classes use the same *MsBackendSqlStash* format
(and both can hence be restored from the same stash).

## Alabaster format, `AlabasterParam`

[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
with an
[`AlabasterParam()`](https://rdrr.io/pkg/MsStash/man/AlabasterParam.html)
stores the backend to a stash folder in *alabaster* format. Individual
components of the backend are stored using base functionality of the
*alabaster.base* Bioconductor package into specific sub-folders within
the main stash directory. These are:

- *dbinfo* directory: contains a `data.frame` saved with
  *alabaster.base* with the database-specific information such as
  database name, host etc.

- *spectra_ids* directory: contains an `integer` vector saved with
  *alabaster.base* with the IDs (indices) of the individual spectra.

The remaining directories hold the content of the `MsBackendCached`
object the `MsBackendOfflineSql` extends (i.e., all locally cached
data). Using parameter `consolidate = TRUE` will also store the database
file within the folder (if supported).

In addition to the
[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
and
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
also the *alabaster.base*
[`saveObject()`](https://rdrr.io/pkg/alabaster.base/man/saveObject.html)
and
[`readObject()`](https://rdrr.io/pkg/alabaster.base/man/readObject.html)
methods are directly supported.

## Text-file format, `PlainTextParam`

[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
with a `PlainTextParam` stores the content of a `MsBackendOfflineSql` as
text files into the stash folder. This creates two text files:

- *ms_backend_dbinfo.txt*: a two-column tabulator delimited text file
  with columns `"key"` and `"value"` (first line being the header) with
  each row representing a key-value pair with the SQL database
  connection information. This includes `"dbname"` (the name of the
  database - for SQLite databases the SQLite database file name),
  `"dbdriver"` the database driver class (e.g. `"RSQLite::SQLiteDriver"`
  for SQLite databases), `"user"` with the database user, `"host"` with
  the host running the database and `"port"` with the respective port.

- *ms_backend_spectra_ids.txt*: a single column text file (first row
  being the *header* of the table) with the spectrum identifiers (of
  type `integer`).

Remaining content, such as eventually present locally cached data, are
stored through the
[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
function of the parent `MsBackendCached` object (see
[MsBackendCachedStash](https://rformassspectrometry.github.io/SpectraStash/reference/MsBackendCachedStash.md)
for details).

## Author

Johannes Rainer

## Examples

``` r

## Create an example `Spectra` object
library(Spectra)
library(MsDataHub)

s <- Spectra(MsDataHub::X20171016_POOL_POS_1_105.134.mzML())
#> see ?MsDataHub and browseVignettes('MsDataHub') for documentation
#> loading from cache

## Store the full data into a SQLite SQL database
library(RSQLite)
library(MsBackendSql)
dbname <- tempfile()
s <- setBackend(s, MsBackendOfflineSql(), dbname = dbname, drv = SQLite())
#> Importing data ... 
#> 
#> [==========================================================] 1/1 (100%) in  1s
#> 
#> Creating indices 
#> .
#> .
#> .
#> .
#>  Done

## Stash the `Spectra` object to a temporary folder in alabaster format
d <- file.path(tempdir(), "spectra_sql")
saveMsObject(s, AlabasterParam(d))

## List the content of the SpectraStash
dir(d)
#> [1] "OBJECT"                        "_environment.json"            
#> [3] "backend"                       "metadata"                     
#> [5] "processing"                    "processing_chunk_size"        
#> [7] "processing_queue_variables"    "spectra_processing_queue.json"

## List the content of the MsBackendOfflineSql stash, which is located
## within the *backend* folder
dir(file.path(d, "backend"))
#> [1] "OBJECT"            "dbinfo"            "local_data"       
#> [4] "nspectra"          "spectra_ids"       "spectra_variables"

## Restore the object from the stash
res <- readMsObject(Spectra(), AlabasterParam(d))
res
#> MSn data (Spectra) with 931 spectra in a MsBackendOfflineSql backend:
#>       msLevel precursorMz  polarity
#>     <integer>   <numeric> <integer>
#> 1           1          NA         1
#> 2           1          NA         1
#> 3           1          NA         1
#> 4           1          NA         1
#> 5           1          NA         1
#> ...       ...         ...       ...
#> 927         1          NA         1
#> 928         1          NA         1
#> 929         1          NA         1
#> 930         1          NA         1
#> 931         1          NA         1
#>  ... 35 more variables/columns.
#>  Use  'spectraVariables' to list all of them.
#> Database: /tmp/RtmpFEjqN8/file74f65b91ee7
#> Processing:
#>  Switch backend from MsBackendMzR to MsBackendOfflineSql [Mon Oct 26 12:17:00 2026] 

## Verify a SQL backend is used
class(res@backend)
#> [1] "MsBackendOfflineSql"
#> attr(,"package")
#> [1] "MsBackendSql"

## Repeat using the plain text file format. We need to first remove
## the previously generated stash, as overwriting an existing stash
## is not supported.
unlink(d, recursive = TRUE)

## Use `consolidate = TRUE` to store also the database into the stash
saveMsObject(s, PlainTextParam(d), consolidate = TRUE)

## List the content of the SpectraStash
dir(d)
#> [1] "file74f65b91ee7"                  "ms_backend_data.txt"             
#> [3] "ms_backend_dbinfo.txt"            "ms_backend_nspectra.txt"         
#> [5] "ms_backend_spectra_ids.txt"       "ms_backend_spectra_variables.txt"
#> [7] "spectra_processing_queue.json"    "spectra_slots.txt"               

## Restore the object from the stash
res <- readMsObject(Spectra(), PlainTextParam(d))
res
#> MSn data (Spectra) with 931 spectra in a MsBackendOfflineSql backend:
#>       msLevel precursorMz  polarity
#>     <integer>   <numeric> <integer>
#> 1           1          NA         1
#> 2           1          NA         1
#> 3           1          NA         1
#> 4           1          NA         1
#> 5           1          NA         1
#> ...       ...         ...       ...
#> 927         1          NA         1
#> 928         1          NA         1
#> 929         1          NA         1
#> 930         1          NA         1
#> 931         1          NA         1
#>  ... 35 more variables/columns.
#>  Use  'spectraVariables' to list all of them.
#> Database: /tmp/RtmpFEjqN8/spectra_sql/file74f65b91ee7
#> Processing:
#>  Switch backend from MsBackendMzR to MsBackendOfflineSql [Mon Oct 26 12:17:00 2026] 

## Verify a SQL backend is used
class(res@backend)
#> [1] "MsBackendOfflineSql"
#> attr(,"package")
#> [1] "MsBackendSql"
```
