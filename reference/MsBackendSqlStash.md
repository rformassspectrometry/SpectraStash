# Stash for SQL-based backends

`MsBackendOfflineSql` backend classes defined in the
[*MsBackendSql*](https://bioconductor.org/packages/MsBackendSql)
Bioconductor package can be stashed (or read from) plain text file or
*alabaster*-based stash formats using the
[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
and
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
functions configuring the stash with a
[PlainTextParam](https://rdrr.io/pkg/MsStash/man/PlainTextParam.html) or
[AlabasterParam](https://rdrr.io/pkg/MsStash/man/AlabasterParam.html)
parameter object.

Additional properties of the stash formats are described in detail in
the sections below.

## Usage

``` r
# S4 method for class 'MsBackendOfflineSql,PlainTextParam'
saveMsObject(object, param, consolidate = FALSE)

# S4 method for class 'MsBackendOfflineSql,PlainTextParam'
readMsObject(object, param, password = character(), ...)
```

## Arguments

- object:

  An `MsBackendOfflineSql` object.

- param:

  Either a `PlainTextParam` or `AlabasterParam`.

- consolidate:

  `logical(1)` whether the database file should be copied into the stash
  folder. This is currently only supported for some database formats and
  systems. See *notes* section for details.

- password:

  Optional `character(1)` with the password required to connect to the
  database. Passwords are never stored in a stash, thus, if required,
  the password to connect to the SQL database must be provided through
  this parameter.

- ...:

  Currently ignored.

## Value

[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
returns a
[MsBackendSql::MsBackendOfflineSql](https://rdrr.io/pkg/MsBackendSql/man/MsBackendOfflineSql.html)
object.

## Note

For some SQL database systems it is possible to store also the database
into the stash folder (by setting `consolidate = TRUE` in the
[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
call). This is currently supported for:

- SQLite-based databases (using the *RSQLite* package)

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

## Stash the `Spectra` object to a temporary folder
d <- file.path(tempdir(), "spectra_sql")
saveMsObject(s, PlainTextParam(d))

## List the content of the SpectraStash
dir(d)
#> [1] "ms_backend_data.txt"              "ms_backend_dbinfo.txt"           
#> [3] "ms_backend_nspectra.txt"          "ms_backend_spectra_ids.txt"      
#> [5] "ms_backend_spectra_variables.txt" "spectra_processing_queue.json"   
#> [7] "spectra_slots.txt"               

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
#> Database: /tmp/RtmpkjwKyT/file1adf5640d181
#> Processing:
#>  Switch backend from MsBackendMzR to MsBackendOfflineSql [Fri Oct 16 14:05:22 2026] 

## Verify a SQL backend is used
class(res@backend)
#> [1] "MsBackendOfflineSql"
#> attr(,"package")
#> [1] "MsBackendSql"
```
