## Save/read MsBackendMzR instances to plain text file format.

#' @title MsBackendMzR Stash
#'
#' @name MsBackendMzR-stash
#'
#' @description
#'
#' `MsBackendMzR` classes can be stashed to (or read from) plain text
#' file-based or *alabaster*-based formats using the [saveMsObject()] and
#' [readMsObject()] functions combined with the [PlainTextParam] and
#' [AlabasterParam] parameter objects, respectively. The properties for both
#' formats are described in detail in the sections below.
#'
#' @section Text-file format, `PlainTextParam`:
#'
#' The `saveMsObject()` function with the `PlainTextParam` stores the spectra
#' metadata (spectra variables) of an `MsBackendMzR` to a plain tabulator
#' delimited text file with the name *ms_backend_spectra_data.txt* in the
#' directory specified with parameter `path` of the `PlainTextParam` object.
#' Importantly, the peaks data (the *m/z* and intensity values) are **not**
#' exported with `saveMsObject()`. `readMsObject()` restores a previously
#' stashed `MsBackendMzR` object from the directory specified with parameter
#' `path` of the `PlainTextParam`.
#'
#' The additional parameter `spectraPath` of `readMsObject()` allows to define
#' the path to the MS data files containing the full MS data (i.e., the mzML,
#' mzXML or CDF files referred to by the `MsBackendMzR`).
#'
#' @section *alabaster*-based format, `AlabasterParam`:
#'
#' @param object An `MsBackendMzR` object.
#'
#' @param param Either a `PlainTextParam` or `AlabasterParam`.
#'
#' @param spectraPath For `readMsObject()`: optional `character(1)` with the
#'     path to the MS data files (mzML, mzXML or CDF) in case they are on longer
#'     available in the folder referred to by the original stashed
#'     `MsBackendMzR` object.
#'
#' @param x An `MsBackendMzR` object.
#'
#' @param path For `saveObject()`: `character(1)` with the path where the
#'     object should be stored in.
#'
#' @return `readMsObject()` returns an [Spectra::MsBackendMzR]` object.
#'
#' @author Philippine Louail, Johannes Rainer
NULL

################################################################################
##    PlainTextParam
################################################################################

#' @importMethodsFrom MsStash saveMsObject
#'
#' @importClassesFrom Spectra MsBackendMzR
#'
#' @importMethodsFrom Spectra dropNaSpectraVariables
#'
#' @rdname MsBackendMzR-stash
setMethod("saveMsObject", signature(object = "MsBackendMzR",
                                    param = "PlainTextParam"),
          function(object, param) {
              object <- dropNaSpectraVariables(object)
              dir.create(param@path, showWarnings = FALSE, recursive = TRUE)
              fl <- file.path(param@path, .MS_BACKEND_MZR_DATA_FILE)
              .check_overwriting(fl)
              writeLines(paste0("# ", class(object)[1L]), con = fl)
              if (nrow(object@spectraData))
                  .write_spectra_data(object@spectraData, fl, append = TRUE)
          })

#' @importMethodsFrom MsStash readMsObject
#'
#' @importFrom methods validObject
#'
#' @importMethodsFrom Spectra dataStorageBasePath<-
#'
#' @importFrom S4Vectors DataFrame
#'
#' @rdname MsBackendMzR-stash
setMethod("readMsObject", signature(object = "MsBackendMzR",
                                    param = "PlainTextParam"),
          function(object, param, spectraPath = character()) {
              fl <- file.path(param@path, .MS_BACKEND_MZR_DATA_FILE)
              .check_directory_content(param@path, .MS_BACKEND_MZR_DATA_FILE)
              l2 <- readLines(fl, n = 2)
              .check_class_comment(l2, .MS_BACKEND_MZR_DATA_FILE,
                                   "# MsBackendMzR")
              if (length(l2) > 1L) {
                  object@spectraData <- DataFrame(.read_spectra_data(fl))
                  if (length(spectraPath))
                      dataStorageBasePath(object) <- spectraPath
              }
              validObject(object)
              object
          })

.MS_BACKEND_MZR_DATA_FILE <- "ms_backend_spectra_data.txt"

################################################################################
##    AlabasterParam
################################################################################

#' @importMethodsFrom alabaster.base saveObject
#'
#' @importFrom alabaster.base saveObjectFile
#'
#' @importFrom alabaster.base altSaveObject
#'
#' @rdname MsBackendMzR-stash
setMethod("saveObject", "MsBackendMzR", function(x, path, ...) {
    x <- dropNaSpectraVariables(x)
    dir.create(path, showWarnings = FALSE, recursive = TRUE)
    .check_overwriting(file.path(path, "OBJECT"))
    saveObjectFile(path, "ms_backend_mz_r")
    altSaveObject(x@spectraData, path = file.path(path, "spectra_data"))
})

#' @importFrom alabaster.base registerValidateObjectFunction
#'
#' @importFrom alabaster.base readObjectFile
#'
#' @noRd
validateMsBackendMzR <- function(path = character(), metadata = list()) {
    .check_directory_content(path, c("OBJECT", "spectra_data"))
    ob <- readObjectFile(path)
    if (ob$type != "ms_backend_mz_r")
        stop("Invalid OBJECT format. Expected \"ms_backend_mz_r\"",
             call. = FALSE)
}

#' @importFrom alabaster.base altReadObject
#'
#' @importFrom alabaster.base registerReadObjectFunction
#'
#' @importFrom Spectra MsBackendMzR
#'
#' @noRd
readMsBackendMzR <- function(path = character(), metadata = list(),
                             spectraPath = character()) {
    validateMsBackendMzR(path, metadata)
    be <- MsBackendMzR()
    be@spectraData <- altReadObject(file.path(path, "spectra_data"))
    if (length(spectraPath))
        dataStorageBasePath(be) <- spectraPath
    validObject(be)
    be
}
