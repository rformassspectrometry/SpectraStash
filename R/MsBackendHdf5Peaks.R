## Save and load MsBackendHdf5Peaks backends

#' @title MsBackendHdf5Peaks Stash
#'
#' @name MsBackendHdf5PeaksStash
#'
#' @description
#'
#' `MsBackendHdf5Peaks` classes can be stashed to (or read from) plain text
#' file-based or *alabaster*-based formats using the [saveMsObject()] and
#' [readMsObject()] functions combined with the [PlainTextParam] and
#' [AlabasterParam] parameter objects, respectively. In both cases, data files
#' are stored into the specified directory. By default, only the backend's
#' spectra metadata is stored in that folder. Setting parameter
#' `consolidate = TRUE` will also copy the HDF5-format peaks data files
#' (containing the *m/z* and intensity values) of the backend into the folder
#' generating a self-consistent stash. The paths to the data storage files are
#' also updated to relative paths enabling to directly restore the object from
#' the stash when the stash folder was copied to another computer or location
#' on the file system (i.e., without the use of parameter `spectraPath`).
#'
#' Details on the stored files are provided in the sections below.
#'
#' @details
#'
#' A `MsBackendHdf5Peaks` stash will by default only contain the spectra
#' metadata (spectra variables) but no *m/z* and intensity values. The reference
#' to the original HDF5-format peaks data files are stored as spectra variable
#' *dataStorage*. If these files were moved or if the stash was copied to a
#' different computer, the path to these original data files needs to be
#' provided to the `readMsObject()` function with parameter `spectraPath`.
#' Alternatively, with `consolidate = TRUE`, it is also possible to **copy** the
#' peaks data files to the stash directory generating a self-contained data
#' stash. Note however that in this case two copies of all data files exist (in
#' the original location **and** the stash directory).
#'
#' @section Text-file format, `PlainTextParam`:
#'
#' The `saveMsObject()` function with the `PlainTextParam` stores the spectra
#' metadata (spectra variables) of an `MsBackendHdf5Peaks` to a plain tabulator
#' delimited text file with the name *ms_backend_spectra_data.txt* in the
#' directory specified with parameter `path` of the `PlainTextParam` object.
#' Depending on parameter `consolidate` also the peaks data files (in HDF5
#' format) will be copied to the stash folder (with `consolidate = TRUE`).
#'
#' @section *abalbaster*-based format, `AlabasterParam`:
#'
#' With `AlabasterParam`, the spectra metadata will be exported (or imported)
#' through the *alabaster* framework. Similar to the `PlainTextParam`,
#' `consolidate = TRUE` will also copy the HDF5-format peaks data files to the
#' stash directory.
#'
#' @param consolidate `logical(1)` whether in addition to the spectra metadata
#'     also the peaks data file (in HDF5 format) should be stored in the stash
#'     folder. Default is `consolidate = FALSE`.
#'
#' @param object An `MsBackendHdf5Peaks` object.
#'
#' @param param Either a `PlainTextParam` or `AlabasterParam`.
#'
#' @param path For `saveObject()`: `character(1)` with the path where the
#'     object should be stored in.
#'
#' @param spectraPath For `readMsObject()`: optional `character(1)` with the
#'     path to the peaks data in HDF5-format (in case they are on longer
#'     available in the folder referred to by the original stashed
#'     `MsBackendHdf5Peaks` object).
#'
#' @param x An `MsBackendHdf5Peaks` object.
#'
#' @param ... Currently ignored.
#'
#' @return `readMsObject()` returns an [Spectra::MsBackendHdf5Peaks]` object.
#'
#' @author Johannes Rainer
#'
#' @examples
#'
#' library(Spectra)
#' library(SpectraStash)
#' ## Create an example MsBackendHdf5Peaks backend from a single mzML file
#' library(MsDataHub)
#' tmp <- backendInitialize(MsBackendMzR(), X20171016_POOL_POS_1_105.134.mzML())
#' be_h5 <- backendInitialize(MsBackendHdf5Peaks(), data = spectraData(tmp),
#'     hdf5path = file.path(tempdir(), "h5_backend"))
#' be_h5
#'
#' d <- file.path(tempdir(), "example_hdf5")
#' ptp <- PlainTextParam(path = d)
#'
#' ## Store the object into the stash, including the peaks data files.
#' saveMsObject(be_h5, ptp, consolidate = TRUE)
#'
#' ## List the content of the folder: ms_backend_spectra_data.txt file
#' ## with the spectra metadata and an HDF5 file with the peaks data:
#' dir(d)
#'
#' ## Restore the stashed object
#' res <- readMsObject(MsBackendHdf5Peaks(), ptp)
#'
#' ## Store the object in an alabaster-format stash
#' d <- file.path(tempdir(), "example_hdf5_2")
#'
#' ap <- AlabasterParam(d)
#' saveMsObject(be_h5, ap)
#'
#' ## Check the content of the stash; with the default (`consolidate = FALSE`)
#' ## no HDF5 data file was moved.
#' dir(d)
#'
#' ## Restore the object again
#' res <- readMsObject(MsBackendHdf5Peaks(), ap)
#' res
NULL

################################################################################
##    PlainTextParam
################################################################################

#' @importMethodsFrom Spectra dataStorageBasePath
#'
#' @importMethodsFrom Spectra dataStorageBasePath<-
#'
#' @importClassesFrom Spectra MsBackendHdf5Peaks
#'
#' @importMethodsFrom Spectra dataStorage
#'
#' @importFrom Spectra MsBackendHdf5Peaks
#'
#' @rdname MsBackendHdf5PeaksStash
setMethod("saveMsObject", signature(object = "MsBackendHdf5Peaks",
                                    param = "PlainTextParam"),
          function(object, param, consolidate = FALSE) {
              object <- dropNaSpectraVariables(object)
              dir.create(param@path, showWarnings = FALSE, recursive = TRUE)
              fl <- file.path(param@path, .MS_BACKEND_MZR_DATA_FILE)
              .check_overwriting(fl)
              l <- c(paste0("# ", class(object)[1L]),
                     paste0("# modCount=", paste0(object@modCount,
                                                  collapse = ",")))
              writeLines(l, con = fl)
              if (nrow(object@spectraData)) {
                  if (consolidate)
                      object <- .consolidate_data_storage(object, param@path)
                  .write_spectra_data(object@spectraData, fl, append = TRUE)
              }
          })

#' @rdname MsBackendHdf5PeaksStash
setMethod("readMsObject", signature(object = "MsBackendHdf5Peaks",
                                    param = "PlainTextParam"),
          function(object, param, spectraPath = character()) {
              fl <- file.path(param@path, .MS_BACKEND_MZR_DATA_FILE)
              .check_directory_content(param@path, .MS_BACKEND_MZR_DATA_FILE)
              l2 <- readLines(fl, n = 3)
              .check_class_comment(l2, .MS_BACKEND_MZR_DATA_FILE,
                                   "# MsBackendHdf5Peaks")
              mc <- strsplit(sub("# modCount=", "", l2[2L]), split = ",")[[1L]]
              object@modCount <- as.integer(mc)
              if (length(l2) > 2L) {
                  object@spectraData <- DataFrame(.read_spectra_data(fl))
                  if (length(spectraPath))
                      dataStorageBasePath(object) <- spectraPath
                  ## consolidated; update relative path to absolute stash path
                  if (all(grepl("^\\.(/|\\\\)",
                                unique(object@spectraData$dataStorage))))
                      dataStorageBasePath(object) <- param@path
              }
              validObject(object)
              object
          })

################################################################################
##    AlabasterParam
################################################################################

#' @rdname MsBackendHdf5PeaksStash
setMethod("saveObject", "MsBackendHdf5Peaks", function(x,
                                                       path,
                                                       consolidate = FALSE,
                                                       ...) {
    x <- dropNaSpectraVariables(x)
    dir.create(path, showWarnings = FALSE, recursive = TRUE)
    .check_overwriting(file.path(path, "OBJECT"))
    saveObjectFile(path, "ms_backend_hdf5_peaks")
    if (consolidate && nrow(x@spectraData))
        x <- .consolidate_data_storage(x, path)
    altSaveObject(x@spectraData, path = file.path(path, "spectra_data"))
    altSaveObject(x@modCount, path = file.path(path, "mod_count"))
})

validateMsBackendHdf5Peaks <- function(path = character(), metadata = list()) {
    .check_directory_content(path, c("OBJECT", "spectra_data", "mod_count"))
    ob <- readObjectFile(path)
    if (ob$type != "ms_backend_hdf5_peaks")
        stop("Invalid OBJECT format. Expected \"ms_backend_hdf5_peaks\"",
             call. = FALSE)
}

readMsBackendHdf5Peaks <- function(path = character(), metadata = list(),
                                   spectraPath = character()) {
    validateMsBackendHdf5Peaks(path, metadata)
    be <- MsBackendHdf5Peaks()
    be@spectraData <- altReadObject(file.path(path, "spectra_data"))
    be@modCount <- altReadObject(file.path(path, "mod_count"))
    if (nrow(be@spectraData)) {
        if (length(spectraPath))
            dataStorageBasePath(be) <- spectraPath
        if (all(grepl("^\\.(/|\\\\)", unique(be@spectraData$dataStorage))))
            dataStorageBasePath(be) <- path
    }
    validObject(be)
    be
}

#' @rdname MsBackendHdf5PeaksStash
setMethod("saveMsObject", signature(object = "MsBackendHdf5Peaks",
                                    param = "AlabasterParam"),
          function(object, param, consolidate = FALSE) {
              saveObject(object, path = param@path, consolidate = consolidate)
          })

#' @rdname MsBackendHdf5PeaksStash
setMethod("readMsObject", signature(object = "MsBackendHdf5Peaks",
                                    param = "AlabasterParam"),
          function(object, param, spectraPath = character()) {
              readMsBackendHdf5Peaks(path = param@path,
                                     spectraPath = spectraPath)
          })
