#' @title Stash for `MsBackendMemory` and `MsBackendDataFrame`
#'
#' @name MsBackendMemoryStash
#'
#' @description
#'
#' The stash for the in-memory MS backends [Spectra::MsBackendMemory] and
#' [Spectra::MsBackendDataFrame] contains both the spectra variables
#' (spectra metadata) as well as the peaks data (*m/z* and intensity values).
#' Backend objects can be stashed and restored with the `saveMsObject()` and
#' `readMsObject()`, respectively. In addition, the `saveObject()` and
#' `readObject()` functions from *alabaster.base* are supported.
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
#' @param object An `MsBackendMemory` or `MsBackendDataFrame` object.
#'
#' @param param Either a `PlainTextParam` or `AlabasterParam`.
#'
#' @param path For `saveObject()`: `character(1)` with the path where the
#'     object should be stored into.
#'
#' @param x An `MsBackendMemory` or `MsBackendDataFrame` object.
#'
#' @param ... Currently ignored.
#'
#' @return `readMsObject()` returns a restored backend.
#'
#' @author Johannes Rainer
#'
#' @examples
#'
#' library(Spectra)
#'
#' ## Create an example `MsBackendMemory` object.
#' d <- data.frame(msLevel = c(1L, 2L, 1L, 1L),
#'     rtime = c(12.1, 12.2, 13.1, 13.4))
#' d$mz <- list(
#'     c(14.4, 155.2, 186.4),
#'     c(144.3, 231.3, 345.3, 453.1),
#'     c(111.2, 142.4, 143.1),
#'     c(143.3, 144.3, 153.3, 532.3, 641.5)
#' )
#' d$intensity <- list(
#'     c(323.2, 53.2, 35.5),
#'     c(43.3, 54.1, 33.1, 53.1),
#'     c(435.3, 35312.3, 5432.5),
#'     c(433.5, 55434.2, 43.4, 54362.1, 24435.3)
#' )
#' be <- backendInitialize(MsBackendMemory(), data = d)
#' be
#'
#' ## Stash the object in alabaster-format to a temporary folder
#' p <- AlabasterParam(file.path(tempdir(), "mem_stash"))
#' saveMsObject(be, p)
#'
#' ## Show directory content of the stash
#' dir(file.path(tempdir(), "mem_stash"))
#'
#' ## Restore the object from the stash
#' res <- readMsObject(MsBackendMemory(), p)
#' res
#'
#' ## The in-memory backends store their full MS data through an
#' ## [Spectra::MsBackendHdf5Peaks] backend: their peaks data is stored as a
#' ## (single) HDF5 file within the stash. A `MsBackendMemory` stash contains
#' ## therefore a complete stash of a `MsBackendHdf5Peaks`, which allows to
#' ## read the data also as a `MsBackendHdf5Peaks` backend:
#' res <- readMsObject(MsBackendHdf5Peaks(),
#'     AlabasterParam(file.path(tempdir(), "mem_stash", "backend")))
#' res
#'
#' ## In addition to the `saveMsObject()` and `readMsObject()` functions, also
#' ## the `saveObject()` and `readObject()` functions from *alabater.base* are
#' ## supported (for stashes in alabaster format).
#' library(alabaster.base)
#' res <- readObject(file.path(tempdir(), "mem_stash"))
#' res
#'
#' ## Storing and restoring a `MsBackendDataFrame` backend or using a stash in
#' ## plain text file-based format works analogously.
NULL

setClassUnion("MsBackendInMemory", c("MsBackendMemory", "MsBackendDataFrame"))

################################################################################
##    PlainTextParam
################################################################################

#' @rdname MsBackendMemoryStash
setMethod("saveMsObject", signature(object = "MsBackendInMemory",
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
              unlink(file.path(tempdir(), "peaks.h5"))
          })

#' @rdname MsBackendMemoryStash
setMethod("readMsObject", signature(object = "MsBackendInMemory",
                                    param = "PlainTextParam"),
          function(object, param, ...) {
              fl <- file.path(param@path, .MS_BACKEND_MZR_DATA_FILE)
              .check_directory_content(param@path, .MS_BACKEND_MZR_DATA_FILE)
              l2 <- readLines(fl, n = 2)
              .check_class_comment(l2, .MS_BACKEND_MZR_DATA_FILE,
                                   paste0("# ", class(object)[1L]))
              param@path <- file.path(param@path, "backend")
              res <- readMsObject(MsBackendHdf5Peaks(), param)
              res <- backendInitialize(object, data = spectraData(res))
              dropNaSpectraVariables(res)
          })

################################################################################
##    AlabasterParam
################################################################################

#' @rdname MsBackendMemoryStash
#'
#' @importClassesFrom Spectra MsBackendMemory
#'
#' @importClassesFrom Spectra MsBackendDataFrame
setMethod("saveObject", "MsBackendInMemory", function(x, path, ...) {
    tpe <- .in_memory_class[class(x)[1L]]
    x <- .to_hdf5_backend(x, tempdir())
    altSaveObject(x, file.path(path, "backend"), consolidate = TRUE)
    unlink(file.path(tempdir(), "peaks.h5"))
    saveObjectFile(path, tpe, extra = list(cast_from = "MsBackendHdf5Peaks"))
})

validateMsBackendMemory <- function(path = character(), metadata = list()) {
    .check_directory_content(path, c("OBJECT", "backend"))
}

#' @importFrom Spectra MsBackendMemory
#'
#' @importFrom Spectra MsBackendDataFrame
#'
#' @importFrom alabaster.base readObject
#'
#' @noRd
readMsBackendInMemory <- function(path = character(), metadata = list()) {
    validateMsBackendMemory(path, metadata)
    be <- readObject(file.path(path, "backend"))
    of <- readObjectFile(path)
    cl <- names(.in_memory_class)[.in_memory_class == of$type]
    be <- backendInitialize(do.call(cl, list()), data = spectraData(be))
    dropNaSpectraVariables(be)
}

#' @rdname MsBackendMemoryStash
setMethod("saveMsObject", signature(object = "MsBackendInMemory",
                                    param = "AlabasterParam"),
          function(object, param, ...) {
              saveObject(object, path = param@path)
          })

#' @rdname MsBackendCachedStash
setMethod("readMsObject", signature(object = "MsBackendInMemory",
                                    param = "AlabasterParam"),
          function(object, param, ...) {
              readMsBackendInMemory(path = param@path)
          })

################################################################################
##    Utility functions
################################################################################

.in_memory_class <- c(MsBackendMemory = "ms_backend_memory",
                      MsBackendDataFrame = "ms_backend_data_frame")

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
            warning("Replacing spectra variable 'scanIndex' with unique values",
                    call. = FALSE)
        x$scanIndex <- seq_along(x)
    }
    backendInitialize(MsBackendHdf5Peaks(), data = spectraData(x),
                      hdf5path = path, files = file, BPPARAM = SerialParam())
}
