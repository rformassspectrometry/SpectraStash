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
#' @return `readMsObject()` returns an `MsBackendMzR()` object.
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
              fl <- file.path(param@path, "ms_backend_spectra_data.txt")
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
              fl <- file.path(param@path, "ms_backend_spectra_data.txt")
              if (!file.exists(fl))
                  stop("\"ms_backend_spectra_data.txt\" not found in ",
                       param@path, call. = FALSE)
              l2 <- readLines(fl, n = 2)
              .check_class_comment(l2, "ms_backend_spectra_data.txt",
                                   "# MsBackendMzR")
              if (length(l2) > 1L) {
                  object@spectraData <- DataFrame(.read_spectra_data(fl))
                  if (length(spectraPath))
                      dataStorageBasePath(object) <- spectraPath
              }
              validObject(object)
              object
          })
