## Stash for MsBackendCached

#' @title Stash for `MsBackendCached`
#'
#' @name MsBackendCachedStash
#'
#' @description
#'
#' The [Spectra::MsBackendCached] backend keeps a cache of spectra metadata
#' (spectra variables) in an internal `data.frame` adding thus support for
#' (temporarily) changing or adding spectra variables for purely read-only
#' `MsBackend` classes. This backend is used e.g. by the
#' [MsBackendSql::MsBackendSql] backend allowing to add or replace spectra
#' variables without affecting the content of the underlying data base used by
#' the `MsBackendSql`.
#'
#' The stash of a `MsBackendCached` contains therefore the local spectra data
#' cache (if present), the names of the available spectra variables and the
#' total number of spectra. Supported stash formats are listed in the sections
#' below.
#'
#' @details
#'
#' Notes for stash-functionality for `MsBackend` objects extending
#' `MsBackendCached`:
#'
#' - `saveMsObject()` and `saveObject()` will fail if the stash directory
#'   already exist. Thus, stash functions of backend implementations extending
#'   `MsBackendCached` should **first** call the `MsBackendCached`'s
#'   `saveMsObject()` or `saveObject()` **before** exporting their respective
#'   content to the stash directory.
#'
#' @section Text-file format, `PlainTextParam`:
#'
#' The data files written into the stash are:
#'
#' - *ms_backend_data.txt*: tabulator separated text file with the content of
#'   the `@localData` slot.
#' - *ms_backend_nspectra.txt*: the number of spectra.
#' - *ms_backend_spectra_variables.txt*: the names of the object's spectra
#'   variables (tabulator separated).
#'
#' @section *alabaster*-based format, `AlabasterParam`:
#'
#' The content from all slots of the `MsBackendCached` are stored using
#' functionality from the *alabaster.base* package into separate sub-folders
#' of the base stash directory. These are:
#'
#' - *local_data*: for the `data.frame` with the locally cached spectra
#'   variables (slot `@localData`).
#' - *nspectra*: (`integer(1)`) with the number of spectra.
#' - *spectra_variables*: (`character`) with the names of the object's spectra
#'   variables.
#'
#' @param object An `MsBackendCached` object.
#'
#' @param param Either a `PlainTextParam` or `AlabasterParam`.
#'
#' @param path For `saveObject()`: `character(1)` with the path where the
#'     object should be stored into.
#'
#' @param x An `MsBackendCached` object.
#'
#' @param ... Currently ignored.
#'
#' @return `readMsObject()` returns a [Spectra::MsBackendCached] object.
#'
#' @author Johannes Rainer
#'
#' @examples
#'
#' library(Spectra)
#'
#' ## Create an empty `MsBackendCached` object
#' be <- MsBackendCached()
#'
#' ## Stash the object in alabaster-format in a temporary directory
#' ap <- AlabasterParam(file.path(tempdir(), "cache-stash"))
#' saveMsObject(be, ap)
#'
#' ## The content of the stash folder:
#' dir(file.path(tempdir(), "cache-stash"))
#'
#' ## Restore the object
#' res <- readMsObject(MsBackendCached(), ap)
#' res
NULL

################################################################################
##    PlainTextParam
################################################################################

#' @importClassesFrom Spectra MsBackendCached
#'
#' @rdname MsBackendCachedStash
setMethod("saveMsObject", signature(object = "MsBackendCached",
                                    param = "PlainTextParam"),
          function(object, param, ...) {
              dir.create(param@path, showWarnings = FALSE, recursive = TRUE)
              fl <- file.path(param@path, "ms_backend_data.txt")
              .check_overwriting(fl)
              writeLines(paste0("# ", class(object)[1L]), con = fl)
              if (nrow(object@localData) && ncol(object@localData))
                  .write_spectra_data(object@localData, fl, append = TRUE)
              writeLines(as.character(object@nspectra),
                         file.path(param@path, "ms_backend_nspectra.txt"))
              writeLines(
                  paste0(object@spectraVariables, collapse = "\t"),
                  file.path(param@path, "ms_backend_spectra_variables.txt"))
          })

#' @importFrom Spectra MsBackendCached
#'
#' @importFrom Spectra backendInitialize
#'
#' @rdname MsBackendCachedStash
setMethod("readMsObject", signature(object = "MsBackendCached",
                                    param = "PlainTextParam"),
          function(object, param, ...) {
              fl <- file.path(param@path, "ms_backend_data.txt")
              if (!file.exists(fl))
                  stop("No 'ms_backend_data.txt' file found in the path.")
              l2 <- readLines(fl, n = 2)
              if (l2[1L] != "# MsBackendCached")
                  stop("Invalid class in 'ms_backend_data.txt' file. ",
                       "Expected \"MsBackendCached\" but got: ",
                       paste0("\"", sub("#( )*", "", l2[1L]), "\""))
              if (length(l2) > 1L) {
                  data <- read.table(file = fl, sep = "\t", header = TRUE)
                  rownames(data) <- NULL
              } else data <- data.frame()
              n <- as.integer(readLines(
                  file.path(param@path, "ms_backend_nspectra.txt"))[1L])
              sv <- strsplit(readLines(file.path(
                  param@path, "ms_backend_spectra_variables.txt"))[1L],
                  "\t")[[1L]]
              backendInitialize(MsBackendCached(), data = data,
                                nspectra = n, spectraVariables = sv)
          })

################################################################################
##    AlabasterParam
################################################################################

#' @rdname MsBackendCachedStash
setMethod("saveObject", "MsBackendCached", function(x, path, ...) {
    dir.create(path, showWarnings = FALSE, recursive = TRUE)
    saveObjectFile(path, "ms_backend_cached")
    altSaveObject(x@localData, path = file.path(path, "local_data"))
    altSaveObject(x@nspectra, path = file.path(path, "nspectra"))
    altSaveObject(x@spectraVariables,
                  path = file.path(path, "spectra_variables"))
})

validateMsBackendCached <- function(path = character(), metadata = list()) {
    .check_directory_content(path, c("OBJECT", "spectra_variables",
                                     "nspectra", "local_data"))
}

readMsBackendCached <- function(path = character(), metadata = list()) {
    validateMsBackendCached(path, metadata)
    ld <- altReadObject(file.path(path, "local_data"))
    sv <- altReadObject(file.path(path, "spectra_variables"))
    n <- altReadObject(file.path(path, "nspectra"))
    backendInitialize(MsBackendCached(), data = as.data.frame(ld),
                      spectraVariables = sv, nspectra = n)
}

#' @rdname MsBackendCachedStash
setMethod("saveMsObject", signature(object = "MsBackendCached",
                                    param = "AlabasterParam"),
          function(object, param, ...) {
              saveObject(object, path = param@path)
          })

#' @rdname MsBackendCachedStash
setMethod("readMsObject", signature(object = "MsBackendCached",
                                    param = "AlabasterParam"),
          function(object, param, ...) {
              readMsBackendCached(path = param@path)
          })
