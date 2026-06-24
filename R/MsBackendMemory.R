#' @title Stash for `MsBackendMemory`
#'
#' @name MsBackendMemoryStash
#'
#' @description
#'
#' The stash for [Spectra::MsBackendMemory] contains both the spectra variables
#' (spectra metadata) as well as the peaks data (*m/z* and intensity values).
#'
#' @details
#'
#' To support storing spectra **and** peaks variables, the `MsBackendMemory` is
#' converted to a [Spectra::MsBackendHdf5Peaks] object with the full peaks data
#' stored into a *peaks.h5* HDF5 file within the stash directory. Due to the
#' nested directory structure it is possible to load a `MsBackendMemory` stash
#' either as a `MsBackendMemory` or a `MsBackendHdf5Peaks`.
#'
#' @note
#'
#' Currently only peaks variables `"mz"` and `"intensity"` are supported.
#'
#' @section Text-file format, `PlainTextParam`:
#'
#' The `MsBackendMemory` stash contains a text-file format
#' [MsBackendHdf5PeaksStash] within a sub-folder *backend*. When loading,
#' the data is first imported as a `MsBackendHdf5Peaks` which is then converted
#' to the resulting `MsBackendMemory` (with all data materialized into memory).
#'
#' @section *alabaster*-based format, `AlabasterParam`:
#'
#' The full data is stored as an *alabaster*-format [MsBackendHdf5PeaksStash]
#' in a directory *backend* within the stash folder. Due to this nesting it is
#' possible to load the data either as `MsBackendMemory` or
#' `MsBackendHdf5Peaks`.
#'
#' @param object An `MsBackendMemory` object.
#'
#' @param param Either a `PlainTextParam` or `AlabasterParam`.
#'
#' @param path For `saveObject()`: `character(1)` with the path where the
#'     object should be stored into.
#'
#' @param x An `MsBackendMemory` object.
#'
#' @param ... Currently ignored.
#'
#' @author Johannes Rainer
#'
#' @examples
#'
#' library(Spectra)
#'
NULL

################################################################################
##    PlainTextParam
################################################################################

#' @rdname MsBackendMemoryStash
setMethod("saveMsObject", signature(object = "MsBackendMemory",
                                    param = "PlainTextParam"),
          function(object, param, ...) {
              object <- dropNaSpectraVariables(object)
              dir.create(param@path, showWarnings = FALSE, recursive = TRUE)
              fl <- file.path(param@path, .MS_BACKEND_MZR_DATA_FILE)
              .check_overwriting(fl)
              writeLines(paste0("# ", class(object)[1L]), con = fl)
              object <- .to_hdf5_backend(object, tempdir())
              param@path <- file.path(param@path, "backend")
              saveMsObject(object, param, consolidate = TRUE)
          })

#' @rdname MsBackendMemoryStash
setMethod("readMsObject", signature(object = "MsBackendMemory",
                                    param = "PlainTextParam"),
          function(object, param, ...) {
              fl <- file.path(param@path, .MS_BACKEND_MZR_DATA_FILE)
              .check_directory_content(param@path, .MS_BACKEND_MZR_DATA_FILE)
              l2 <- readLines(fl, n = 2)
              .check_class_comment(l2, .MS_BACKEND_MZR_DATA_FILE,
                                   "# MsBackendMemory")
              param@path <- file.path(param@path, "backend")
              object <- readMsObject(MsBackendHdf5Peaks(), param)
              object <- backendInitialize(MsBackendMemory(),
                                          data = spectraData(object))
              dropNaSpectraVariables(object)
          })

################################################################################
##    AlabasterParam
################################################################################

#' @rdname MsBackendMemoryStash
#'
#' @importClassesFrom Spectra MsBackendMemory
setMethod("saveObject", "MsBackendMemory", function(x, path, ...) {
    x <- .to_hdf5_backend(x, tempdir())
    altSaveObject(x, file.path(path, "backend"), consolidate = TRUE)
    unlink(file.path(tempdir(), "peaks.h5"))
    saveObjectFile(path, "ms_backend_memory",
                   extra = list(cast_from = "MsBackendHdf5Peaks"))
})

validateMsBackendMemory <- function(path = character(), metadata = list()) {
    .check_directory_content(path, c("OBJECT", "backend"))
}

#' @importFrom Spectra MsBackendMemory
#'
#' @importFrom alabaster.base readObject
#'
#' @noRd
readMsBackendMemory <- function(path = character(), metadata = list()) {
    validateMsBackendMemory(path, metadata)
    be <- readObject(file.path(path, "backend"))
    be <- backendInitialize(MsBackendMemory(), data = spectraData(be))
    dropNaSpectraVariables(be)
}

#' @rdname MsBackendMemoryStash
setMethod("saveMsObject", signature(object = "MsBackendMemory",
                                    param = "AlabasterParam"),
          function(object, param, ...) {
              saveObject(object, path = param@path)
          })

#' @rdname MsBackendCachedStash
setMethod("readMsObject", signature(object = "MsBackendMemory",
                                    param = "AlabasterParam"),
          function(object, param, ...) {
              readMsBackendMemory(path = param@path)
          })

################################################################################
##    Utility functions
################################################################################

#' Convert a backend to MsBackendHdf5.
#'
#' @importFrom BiocParallel SerialParam
#'
#' @importMethodsFrom Spectra peaksVariables
#'
#' @importMethodsFrom Spectra spectraData
#' @noRd
.to_hdf5_backend <- function(x, path = tempdir(), file = "peaks.h5") {
    if (!all(peaksVariables(x) %in% c("mz", "intensity")))
        stop("Currently only peaks variables \"mz\" and \"intensity\" are",
             " supported")
    if (anyDuplicated(x$scanIndex)) {
        if (!all(is.na(x$scanIndex)))
            warning("Replacing spectra variable 'scanIndex' with unique values")
        x$scanIndex <- seq_along(x)
    }
    backendInitialize(MsBackendHdf5Peaks(), data = spectraData(x),
                      hdf5path = path, files = file, BPPARAM = SerialParam())
}
